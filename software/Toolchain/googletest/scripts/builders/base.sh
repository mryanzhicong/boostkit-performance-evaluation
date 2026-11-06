#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

# Host responsibilities are limited to Docker plus download/verification of the
# pinned release archive and preparing the shared directories.  Every compiler,
# CMake invocation and measured binary runs inside this task's private openEuler
# container.
require_host_transfer_commands() {
    local missing=()
    local command_name
    for command_name in curl sha256sum tar; do
        command -v "${command_name}" >/dev/null 2>&1 || missing+=("${command_name}")
    done
    if (( ${#missing[@]} > 0 )); then
        log_message "WARNING: host download/verification tools are incomplete: ${missing[*]}; relying on the pre-placed offline archive"
    fi
    return 0
}

prepare_googletest_build_container() {
    local -a dnf_options=()
    require_host_transfer_commands
    require_googletest_docker || return 30
    start_googletest_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message 'installing the GoogleTest build toolchain inside the private container'
    googletest_container_exec_root dnf "${dnf_options[@]}" install -y \
        gcc gcc-c++ make cmake tar gzip coreutils findutils sed gawk grep \
        glibc-devel binutils python3 || {
        log_message "ERROR: container build dependencies failed to install"
        return 30
    }
}

sha256_of() {
    sha256sum "$1" | awk '{print $1}'
}

verify_source_archive() {
    local archive="$1" actual size
    [[ -f "${archive}" ]] || return 1
    actual="$(sha256_of "${archive}")"
    if [[ "${actual}" != "${GOOGLETEST_SOURCE_SHA256}" ]]; then
        log_message "ERROR: SHA-256 mismatch for $(basename "${archive}")"
        log_message "       expected ${GOOGLETEST_SOURCE_SHA256}"
        log_message "       actual   ${actual}"
        return 30
    fi
    size="$(stat -c%s "${archive}")"
    if [[ "${size}" != "${GOOGLETEST_SOURCE_SIZE}" ]]; then
        log_message "ERROR: size mismatch for $(basename "${archive}"): expected ${GOOGLETEST_SOURCE_SIZE}, got ${size}"
        return 30
    fi
    return 0
}

download_source_archive() {
    mkdir -p "$(dirname "${GOOGLETEST_SOURCE_ARCHIVE}")"
    local manifest="${GOOGLETEST_SOURCE_ARCHIVE}.sha256"
    if [[ -f "${GOOGLETEST_SOURCE_ARCHIVE}" && -f "${manifest}" ]]; then
        if [[ "$(cat "${manifest}")" == "${GOOGLETEST_SOURCE_SHA256}" ]] \
            && verify_source_archive "${GOOGLETEST_SOURCE_ARCHIVE}"; then
            log_message "reusing verified source archive ${GOOGLETEST_SOURCE_ARCHIVE}"
            return 0
        fi
        log_message "cached archive is not the pinned artifact; downloading again"
        rm -f "${GOOGLETEST_SOURCE_ARCHIVE}" "${manifest}"
    fi

    local candidate attempt tmp
    local -a candidates=()
    if [[ -n "${GOOGLETEST_OFFLINE_DIR}" && -d "${GOOGLETEST_OFFLINE_DIR}" ]]; then
        candidates+=("file://${GOOGLETEST_OFFLINE_DIR}/${GOOGLETEST_SOURCE_NAME}")
    fi
    for candidate in "${GOOGLETEST_SOURCE_URLS[@]}"; do
        candidates+=("${candidate}")
    done

    for candidate in "${candidates[@]}"; do
        for attempt in 1 2 3; do
            tmp="${TMPDIR}/download-$$-${attempt}.part"
            rm -f "${tmp}"
            if [[ "${candidate}" == file://* ]]; then
                local local_path="${candidate#file://}"
                if [[ ! -f "${local_path}" ]]; then
                    log_message "offline artifact not present: ${local_path}"
                    break
                fi
                cp -f "${local_path}" "${tmp}" || { rm -f "${tmp}"; break; }
            else
                log_message "downloading ${candidate} (attempt ${attempt}/3)"
                if ! curl -fL --retry 2 --retry-all-errors --retry-delay 2 \
                    --connect-timeout 20 --max-time 900 \
                    -o "${tmp}" "${candidate}"; then
                    log_message "download failed: ${candidate}"
                    rm -f "${tmp}"
                    continue
                fi
            fi
            if verify_source_archive "${tmp}"; then
                mv -f "${tmp}" "${GOOGLETEST_SOURCE_ARCHIVE}"
                printf '%s\n' "${GOOGLETEST_SOURCE_SHA256}" > "${manifest}"
                log_message "source archive verified from ${candidate}"
                return 0
            fi
            rm -f "${tmp}"
            log_message "artifact rejected (checksum/size): ${candidate}"
            break
        done
    done
    log_message "ERROR: could not obtain the pinned GoogleTest source archive from any candidate"
    for candidate in "${candidates[@]}"; do
        log_message "       tried: ${candidate}"
    done
    return 30
}

# The archive is unpacked and built inside the container; the host keeps only the
# verified archive and the shared directories.
extract_source() {
    if googletest_container_exec test -d "${GOOGLETEST_SRC_DIR}/googletest/include/gtest" 2>/dev/null; then
        log_message "reusing extracted GoogleTest source tree"
        return 0
    fi
    rm -rf "${GOOGLETEST_SRC_DIR}"
    mkdir -p "${GOOGLETEST_SRC_DIR}"
    log_message "extracting $(basename "${GOOGLETEST_SOURCE_ARCHIVE}") inside the private container"
    googletest_container_exec tar -xzf "${GOOGLETEST_SOURCE_ARCHIVE}" -C "${GOOGLETEST_SRC_DIR}" --strip-components=1 || {
        log_message "ERROR: failed to extract ${GOOGLETEST_SOURCE_ARCHIVE}"
        return 30
    }
    if ! googletest_container_exec test -f "${GOOGLETEST_SRC_DIR}/googletest/include/gtest/gtest.h"; then
        log_message "ERROR: extracted tree does not look like GoogleTest ${GOOGLETEST_VERSION}"
        return 30
    fi
}

build_googletest() {
    local log="${PERF_WORK_DIR}/cmake-configure.log"
    local gtest_lib="${GOOGLETEST_BUILD_DIR}/lib/libgtest.a"
    if googletest_container_exec test -f "${gtest_lib}" 2>/dev/null && \
        googletest_container_exec test -x "${GOOGLETEST_UPSTREAM_BIN}" 2>/dev/null; then
        log_message "reusing existing GoogleTest build in ${GOOGLETEST_BUILD_DIR}"
        return 0
    fi
    mkdir -p "${GOOGLETEST_BUILD_DIR}"
    log_message "configuring GoogleTest ${GOOGLETEST_VERSION} with CMake inside the private container"
    if ! googletest_container_exec cmake -S "${GOOGLETEST_SRC_DIR}" -B "${GOOGLETEST_BUILD_DIR}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_GMOCK=OFF \
        -DINSTALL_GTEST=OFF \
        -Dgtest_build_tests=ON \
        > "${log}" 2>&1; then
        report_failure_tail "${log}" build cmake-configure 30
        return 30
    fi
    log_message "building gtest, gtest_main and the upstream gtest_unittest with -j${GOOGLETEST_JOBS} inside the private container"
    if ! googletest_container_exec cmake --build "${GOOGLETEST_BUILD_DIR}" -j "${GOOGLETEST_JOBS}" \
        --target gtest gtest_main gtest_unittest > "${PERF_WORK_DIR}/cmake-build.log" 2>&1; then
        report_failure_tail "${PERF_WORK_DIR}/cmake-build.log" build cmake-build 30
        return 30
    fi
    if ! googletest_container_exec test -f "${gtest_lib}"; then
        log_message "ERROR: GoogleTest build did not produce ${gtest_lib}"
        return 30
    fi
    if ! googletest_container_exec test -x "${GOOGLETEST_UPSTREAM_BIN}"; then
        local discovered
        discovered="$(googletest_container_exec find "${GOOGLETEST_BUILD_DIR}" -name gtest_unittest -type f | head -n 1)"
        if [[ -z "${discovered}" ]]; then
            log_message "ERROR: upstream gtest_unittest binary was not produced"
            return 30
        fi
        GOOGLETEST_UPSTREAM_BIN="${discovered}"
        export GOOGLETEST_UPSTREAM_BIN
    fi
    log_message "GoogleTest build finished"
}

compile_matrices() {
    local log="${PERF_WORK_DIR}/compile-matrices.log"
    local gtest_lib="${GOOGLETEST_BUILD_DIR}/lib/libgtest.a"
    local source="${SCRIPT_DIR}/scripts/bench/matrix.cc"
    mkdir -p "${GOOGLETEST_MATRIX_BIN_DIR}"
    : > "${log}"
    local specs=(
        "matrix_1k:${GOOGLETEST_MATRIX_1K}:0:registered"
        "matrix_10k:${GOOGLETEST_MATRIX_10K}:0:registered"
        "assertion_loop_5m:0:${GOOGLETEST_ASSERTION_LOOP}:loop"
    )
    local spec scenario tests assertions mode binary
    for spec in "${specs[@]}"; do
        IFS=':' read -r scenario tests assertions mode <<< "${spec}"
        binary="${GOOGLETEST_MATRIX_BIN_DIR}/$(matrix_binary "${scenario}")"
        log_message "compiling assertion matrix ${scenario} inside the private container (tests=${tests}, assertions=${assertions})"
        if ! googletest_container_exec g++ -O2 -std=c++17 \
            -I "${GOOGLETEST_SRC_DIR}/googletest/include" \
            -DGT_MATRIX_TESTS="${tests}" \
            -DGT_MATRIX_ASSERT_LOOP="${assertions}" \
            -DGT_MATRIX_MODE="\"${mode}\"" \
            -o "${binary}" "${source}" "${gtest_lib}" -lpthread >> "${log}" 2>&1; then
            report_failure_tail "${log}" build "compile-${scenario}" 30
            return 30
        fi
        if ! googletest_container_exec test -x "${binary}"; then
            log_message "ERROR: assertion matrix binary was not produced: ${binary}"
            return 30
        fi
    done
    log_message "assertion matrices compiled"
}

# GoogleTest publishes no runtime version string, so the version record is the
# release archive identity plus the version the source distribution declares.
record_actual_version() {
    local actual reported
    actual="$(googletest_container_exec sed -n 's/^set(GOOGLETEST_VERSION[[:space:]]*\([0-9][0-9.]*\))$/\1/p' \
        "${GOOGLETEST_SRC_DIR}/CMakeLists.txt" | head -n 1)" || actual=""
    if [[ ! "${actual}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_message "ERROR: could not determine the GoogleTest version from the extracted source"
        return 40
    fi
    reported="$(googletest_version_string)"
    GOOGLETEST_VERSION_STRING="${reported}"
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual}" > "${PERF_ACTUAL_VERSION_FILE}"
    if [[ "${actual}" != "${GOOGLETEST_VERSION}" ]]; then
        log_message "ERROR: expected GoogleTest ${GOOGLETEST_VERSION}, source declares ${actual}"
        return 40
    fi
    log_message "actual GoogleTest version: ${actual} (${reported})"
}

smoke_check() {
    local log="${PERF_WORK_DIR}/smoke.log"
    : > "${log}"
    log_message "running build-stage smoke checks inside the private container"
    local binary="${GOOGLETEST_MATRIX_BIN_DIR}/$(matrix_binary matrix_1k)"
    if ! googletest_container_exec "${binary}" >> "${log}" 2>&1; then
        report_failure_tail "${log}" build smoke-matrix-1k 50
        return 50
    fi
    if ! grep -q "PASSED  \] ${GOOGLETEST_MATRIX_1K} tests." "${log}"; then
        log_message "ERROR: 1000-test matrix did not report the pinned passed count"
        report_failure_tail "${log}" build smoke-matrix-1k 50
        return 50
    fi
    local loop_bin="${GOOGLETEST_MATRIX_BIN_DIR}/$(matrix_binary assertion_loop_5m)"
    if ! googletest_container_exec "${loop_bin}" >> "${log}" 2>&1; then
        report_failure_tail "${log}" build smoke-assertion-loop 50
        return 50
    fi
    if ! grep -q "\[gt-matrix\] mode=loop registered_tests=0 assertions=${GOOGLETEST_ASSERTION_LOOP} rc=0" "${log}"; then
        log_message "ERROR: assertion-loop matrix did not report the pinned assertion count"
        report_failure_tail "${log}" build smoke-assertion-loop 50
        return 50
    fi
    if ! googletest_container_exec "${GOOGLETEST_UPSTREAM_BIN}" >> "${log}" 2>&1; then
        report_failure_tail "${log}" build smoke-upstream 50
        return 50
    fi
    if ! grep -q "PASSED  \] ${GOOGLETEST_UPSTREAM_TESTS} tests." "${log}"; then
        log_message "ERROR: upstream gtest_unittest did not report the pinned test count"
        report_failure_tail "${log}" build smoke-upstream 50
        return 50
    fi
    log_message "build-stage smoke checks passed"
}

build_googletest_base() {
    initialize_runtime || return $?
    log_message "starting base build for GoogleTest ${GOOGLETEST_VERSION} on ${EXPECTED_ARCH}"
    prepare_googletest_build_container || return $?
    download_source_archive || return 30
    extract_source || return 30
    build_googletest || return 30
    compile_matrices || return 30
    record_actual_version || return 40
    smoke_check || return 50
    log_message "base build for GoogleTest ${GOOGLETEST_VERSION} completed"
    return 0
}
