#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

DOWNLOAD_ATTEMPTS=3

# Host-side prerequisites are limited to Docker plus the download/verification
# tools; every compiler, CMake invocation and benchmark runs in the container.
require_host_transfer_commands() {
    local command_name
    for command_name in curl sha256sum tar python3; do
        command -v "${command_name}" >/dev/null 2>&1 && continue
        log_message "WARNING: host tool is missing: ${command_name}; relying on the pre-placed offline archive"
    done
    return 0
}

prepare_flatbuffers_build_container() {
    local -a dnf_options=()
    require_host_transfer_commands
    require_flatbuffers_docker || return 30
    start_flatbuffers_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message 'installing FlatBuffers build dependencies inside the private container'
    flatbuffers_container_exec_root dnf "${dnf_options[@]}" --setopt=install_weak_deps=False install -y \
        cmake gcc gcc-c++ make tar gzip diffutils coreutils findutils sed gawk \
        grep util-linux file glibc-devel binutils python3 || {
        log_message "ERROR: container build dependencies failed"
        return 30
    }
}

package_for_command() {
    case "$1" in
        curl) printf 'curl\n' ;;
        tar) printf 'tar\n' ;;
        xz) printf 'xz\n' ;;
        sha256sum) printf 'coreutils\n' ;;
        cmake) printf 'cmake\n' ;;
        make) printf 'make\n' ;;
        cc) printf 'gcc\n' ;;
        c++) printf 'gcc-c++\n' ;;
        python3) printf 'python3\n' ;;
        nproc) printf 'coreutils\n' ;;
        *) printf '\n' ;;
    esac
}

install_commands() {
    local missing=() candidate command
    for command in "$@"; do
        command -v "${command}" >/dev/null 2>&1 || missing+=("${command}")
    done
    if (( ${#missing[@]} == 0 )); then
        return 0
    fi
    log_message "installing missing build prerequisites: ${missing[*]}"
    local packages=()
    for command in "${missing[@]}"; do
        candidate="$(package_for_command "${command}")"
        if [[ -n "${candidate}" ]]; then
            packages+=("${candidate}")
        fi
    done
    if (( ${#packages[@]} > 0 )); then
        if command -v dnf >/dev/null 2>&1; then
            dnf install -y -q "${packages[@]}" || {
                log_message "ERROR: dnf install failed for: ${packages[*]}"
                return 30
            }
        elif command -v apt-get >/dev/null 2>&1; then
            DEBIAN_FRONTEND=noninteractive apt-get update -qq || true
            DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${packages[@]}" || {
                log_message "ERROR: apt-get install failed for: ${packages[*]}"
                return 30
            }
        else
            log_message "ERROR: no supported package manager and missing commands: ${missing[*]}"
            return 30
        fi
    fi
    for command in "$@"; do
        command -v "${command}" >/dev/null 2>&1 || {
            log_message "ERROR: required command still missing after install: ${command}"
            return 30
        }
    done
    log_message "build prerequisites satisfied: $*"
}

sha256_of() {
    sha256sum "$1" | awk '{print $1}'
}

verify_source_archive() {
    local archive="$1" actual
    [[ -f "${archive}" ]] || return 1
    actual="$(sha256_of "${archive}")"
    if [[ "${actual}" != "${FLATBUFFERS_SOURCE_SHA256}" ]]; then
        log_message "ERROR: SHA-256 mismatch for $(basename "${archive}")"
        log_message "       expected ${FLATBUFFERS_SOURCE_SHA256}"
        log_message "       actual   ${actual}"
        return 30
    fi
    local size
    size="$(stat -c%s "${archive}")"
    if [[ "${size}" != "${FLATBUFFERS_SOURCE_SIZE}" ]]; then
        log_message "ERROR: size mismatch for $(basename "${archive}"): expected ${FLATBUFFERS_SOURCE_SIZE}, got ${size}"
        return 30
    fi
    return 0
}

download_source_archive() {
    mkdir -p "$(dirname "${FLATBUFFERS_SOURCE_ARCHIVE}")"
    local manifest="${FLATBUFFERS_SOURCE_ARCHIVE}.sha256"
    if [[ -f "${FLATBUFFERS_SOURCE_ARCHIVE}" && -f "${manifest}" ]]; then
        if [[ "$(cat "${manifest}")" == "${FLATBUFFERS_SOURCE_SHA256}" ]] \
            && verify_source_archive "${FLATBUFFERS_SOURCE_ARCHIVE}"; then
            log_message "reusing verified source archive ${FLATBUFFERS_SOURCE_ARCHIVE}"
            return 0
        fi
        log_message "cached archive is not the pinned artifact; downloading again"
        rm -f "${FLATBUFFERS_SOURCE_ARCHIVE}" "${manifest}"
    fi

    local candidate url attempt tmp
    local -a candidates=()
    if [[ -n "${FLATBUFFERS_OFFLINE_DIR}" && -d "${FLATBUFFERS_OFFLINE_DIR}" ]]; then
        for candidate in "${FLATBUFFERS_OFFLINE_DIR}/${FLATBUFFERS_SOURCE_NAME}" \
            "${FLATBUFFERS_OFFLINE_DIR}/${FLATBUFFERS_TAG}.tar.gz"; do
            candidates+=("file://${candidate}")
        done
    fi
    for url in "${FLATBUFFERS_SOURCE_URLS[@]}"; do
        candidates+=("${url}")
    done

    for candidate in "${candidates[@]}"; do
        for attempt in $(seq 1 "${DOWNLOAD_ATTEMPTS}"); do
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
                log_message "downloading ${candidate} (attempt ${attempt}/${DOWNLOAD_ATTEMPTS})"
                if ! curl -fL --retry 2 --retry-all-errors --retry-delay 2 \
                    --connect-timeout 20 --max-time 900 \
                    -o "${tmp}" "${candidate}"; then
                    log_message "download failed: ${candidate}"
                    rm -f "${tmp}"
                    continue
                fi
            fi
            if verify_source_archive "${tmp}"; then
                mv -f "${tmp}" "${FLATBUFFERS_SOURCE_ARCHIVE}"
                printf '%s\n' "${FLATBUFFERS_SOURCE_SHA256}" > "${manifest}"
                log_message "source archive verified from ${candidate}"
                return 0
            fi
            rm -f "${tmp}"
            log_message "artifact rejected (checksum/size): ${candidate}"
            break
        done
    done
    log_message "ERROR: could not obtain the pinned FlatBuffers source archive from any candidate"
    for candidate in "${candidates[@]}"; do
        log_message "       tried: ${candidate}"
    done
    return 30
}

extract_source() {
    if flatbuffers_container_exec test -d "${FLATBUFFERS_SRC_DIR}/include/flatbuffers" && \
        flatbuffers_container_exec test -f "${FLATBUFFERS_SRC_DIR}/benchmarks/cpp/flatbuffers/bench.fbs"; then
        log_message "reusing extracted FlatBuffers source tree"
        return 0
    fi
    rm -rf "${FLATBUFFERS_SRC_DIR}"
    mkdir -p "${FLATBUFFERS_SRC_DIR}"
    log_message "extracting $(basename "${FLATBUFFERS_SOURCE_ARCHIVE}") inside the private container"
    flatbuffers_container_exec tar -xzf "${FLATBUFFERS_SOURCE_ARCHIVE}" -C "${FLATBUFFERS_SRC_DIR}" --strip-components=1 || {
        log_message "ERROR: failed to extract ${FLATBUFFERS_SOURCE_ARCHIVE}"
        return 30
    }
    if ! flatbuffers_container_exec test -f "${FLATBUFFERS_SRC_DIR}/CMakeLists.txt" || \
        ! flatbuffers_container_exec test -f "${FLATBUFFERS_SRC_DIR}/include/flatbuffers/flatbuffers.h"; then
        log_message "ERROR: extracted tree does not look like FlatBuffers ${FLATBUFFERS_VERSION}"
        return 30
    fi
}

build_flatbuffers() {
    local log="${PERF_WORK_DIR}/cmake-configure.log"
    if flatbuffers_container_exec test -x "${FLATBUFFERS_FLATC}" && \
        flatbuffers_container_exec test -f "${FLATBUFFERS_BUILD_DIR}/libflatbuffers.a"; then
        log_message "reusing existing FlatBuffers build in ${FLATBUFFERS_BUILD_DIR}"
        return 0
    fi
    mkdir -p "${FLATBUFFERS_BUILD_DIR}"
    log_message "configuring FlatBuffers ${FLATBUFFERS_VERSION} with CMake inside the private container"
    if ! flatbuffers_container_exec_at "${PERF_WORK_DIR}" \
        cmake -S "${FLATBUFFERS_SRC_DIR}" -B "${FLATBUFFERS_BUILD_DIR}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DFLATBUFFERS_BUILD_TESTS=OFF \
        -DFLATBUFFERS_BUILD_BENCHMARKS=OFF \
        -DFLATBUFFERS_BUILD_SHAREDLIB=OFF \
        -DFLATBUFFERS_BUILD_FLATC=ON \
        -DFLATBUFFERS_BUILD_FLATLIB=ON \
        -DFLATBUFFERS_BUILD_FLATHASH=OFF \
        -DFLATBUFFERS_BUILD_GRPC=OFF \
        -DFLATBUFFERS_INSTALL=OFF \
        > "${log}" 2>&1; then
        report_failure_tail "${log}" build cmake-configure 30
        return 30
    fi
    log_message "building flatbuffers static library and flatc with -j${FLATBUFFERS_JOBS} inside the private container"
    if ! flatbuffers_container_exec_at "${PERF_WORK_DIR}" \
        cmake --build "${FLATBUFFERS_BUILD_DIR}" -j "${FLATBUFFERS_JOBS}" \
        --target flatbuffers flatc > "${PERF_WORK_DIR}/cmake-build.log" 2>&1; then
        report_failure_tail "${PERF_WORK_DIR}/cmake-build.log" build cmake-build 30
        return 30
    fi
    if ! flatbuffers_container_exec test -x "${FLATBUFFERS_FLATC}" || \
        ! flatbuffers_container_exec test -f "${FLATBUFFERS_BUILD_DIR}/libflatbuffers.a"; then
        log_message "ERROR: FlatBuffers build did not produce flatc and libflatbuffers.a"
        return 30
    fi
    log_message "FlatBuffers build finished: $(flatbuffers_version_string)"
}

generate_headers() {
    local log="${PERF_WORK_DIR}/flatc-generate.log"
    mkdir -p "${FLATBUFFERS_GEN_DIR}/benchmarks/cpp/flatbuffers" "${FLATBUFFERS_GEN_DIR}/driver"
    : > "${log}"
    log_message "generating C++ headers with flatc from the upstream schema and the case schema inside the private container"
    if ! flatbuffers_container_exec_at "${PERF_WORK_DIR}" "${FLATBUFFERS_FLATC}" --cpp \
        -o "${FLATBUFFERS_GEN_DIR}/benchmarks/cpp/flatbuffers" \
        "${FLATBUFFERS_SRC_DIR}/benchmarks/cpp/flatbuffers/bench.fbs" >> "${log}" 2>&1; then
        report_failure_tail "${log}" build flatc-bench-schema 30
        return 30
    fi
    if ! flatbuffers_container_exec_at "${PERF_WORK_DIR}" "${FLATBUFFERS_FLATC}" --cpp \
        -o "${FLATBUFFERS_GEN_DIR}/driver" \
        "${SCRIPT_DIR}/scripts/bench/driver.fbs" >> "${log}" 2>&1; then
        report_failure_tail "${log}" build flatc-driver-schema 30
        return 30
    fi
    local -a expected=(
        "${FLATBUFFERS_GEN_DIR}/benchmarks/cpp/flatbuffers/bench_generated.h"
        "${FLATBUFFERS_GEN_DIR}/driver/driver_generated.h"
    )
    local header
    for header in "${expected[@]}"; do
        if ! flatbuffers_container_exec test -s "${header}"; then
            log_message "ERROR: flatc did not produce ${header}"
            report_failure_tail "${log}" build flatc-output 30
            return 30
        fi
    done
    log_message "flatc generated bench_generated.h and driver_generated.h"
}

compile_benchmarks() {
    local log="${PERF_WORK_DIR}/compile-benchmarks.log"
    local cxx="${CXX:-c++}"
    local -a common_flags=(
        -O2 -std=c++17 -Wno-deprecated-declarations
        -I "${FLATBUFFERS_GEN_DIR}/driver"
        -I "${FLATBUFFERS_GEN_DIR}"
        -I "${FLATBUFFERS_SRC_DIR}"
        -I "${FLATBUFFERS_SRC_DIR}/include"
    )
    mkdir -p "$(dirname "${FLATBUFFERS_DRIVER_BIN}")"
    : > "${log}"
    log_message "compiling the case-owned multi-scale driver inside the private container"
    if ! flatbuffers_container_exec_at "${PERF_WORK_DIR}" "${cxx}" "${common_flags[@]}" \
        -o "${FLATBUFFERS_DRIVER_BIN}" \
        "${SCRIPT_DIR}/scripts/bench/driver.cpp" \
        "${FLATBUFFERS_BUILD_DIR}/libflatbuffers.a" >> "${log}" 2>&1; then
        report_failure_tail "${log}" build compile-driver 30
        return 30
    fi
    log_message "compiling the upstream benchmarks/cpp flatbuffers benchmark inside the private container"
    if ! flatbuffers_container_exec_at "${PERF_WORK_DIR}" "${cxx}" "${common_flags[@]}" \
        -o "${FLATBUFFERS_UPSTREAM_BIN}" \
        "${SCRIPT_DIR}/scripts/bench/upstream_runner.cpp" \
        "${FLATBUFFERS_SRC_DIR}/benchmarks/cpp/flatbuffers/fb_bench.cpp" \
        "${FLATBUFFERS_BUILD_DIR}/libflatbuffers.a" >> "${log}" 2>&1; then
        report_failure_tail "${log}" build compile-upstream-bench 30
        return 30
    fi
    local binary
    for binary in "${FLATBUFFERS_DRIVER_BIN}" "${FLATBUFFERS_UPSTREAM_BIN}"; do
        if ! flatbuffers_container_exec test -x "${binary}"; then
            log_message "ERROR: benchmark binary was not produced: ${binary}"
            return 30
        fi
    done
    log_message "benchmark binaries compiled"
}

record_actual_version() {
    local reported
    reported="$(flatbuffers_version_string)"
    FLATBUFFERS_VERSION_STRING="${reported}"
    local actual
    if ! actual="$(decode_flatbuffers_version "${reported}")"; then
        log_message "ERROR: could not decode the FlatBuffers version from: ${reported}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual}" > "${PERF_ACTUAL_VERSION_FILE}"
    if [[ "${actual}" != "${FLATBUFFERS_VERSION}" ]]; then
        log_message "ERROR: expected FlatBuffers ${FLATBUFFERS_VERSION}, flatc reports ${actual}"
        return 40
    fi
    log_message "actual FlatBuffers version: ${actual} (${reported})"
}

smoke_check() {
    local log="${PERF_WORK_DIR}/smoke.log"
    : > "${log}"
    log_message "running build-stage smoke checks inside the private container"
    if ! flatbuffers_container_exec_at "${PERF_WORK_DIR}" \
        "${FLATBUFFERS_DRIVER_BIN}" --mode merged --elements 1000 --iterations 100 >> "${log}" 2>&1; then
        report_failure_tail "${log}" build smoke-driver 50
        return 50
    fi
    if ! grep -q "checksum=49950000 expected=49950000" "${log}"; then
        log_message "ERROR: driver smoke check reported an unexpected checksum"
        report_failure_tail "${log}" build smoke-driver 50
        return 50
    fi
    if ! flatbuffers_container_exec_at "${PERF_WORK_DIR}" \
        "${FLATBUFFERS_UPSTREAM_BIN}" 1 >> "${log}" 2>&1; then
        report_failure_tail "${log}" build smoke-upstream 50
        return 50
    fi
    if ! grep -q "checksum_ok=1" "${log}"; then
        log_message "ERROR: upstream benchmark smoke check failed its checksum"
        report_failure_tail "${log}" build smoke-upstream 50
        return 50
    fi
    log_message "build-stage smoke checks passed"
}

build_flatbuffers_base() {
    initialize_runtime || return $?
    log_message "starting base build for FlatBuffers ${FLATBUFFERS_VERSION} on ${EXPECTED_ARCH}"
    prepare_flatbuffers_build_container || return 30
    download_source_archive || return 30
    extract_source || return 30
    build_flatbuffers || return 30
    generate_headers || return 30
    compile_benchmarks || return 30
    record_actual_version || return 40
    smoke_check || return 50
    log_message "base build for FlatBuffers ${FLATBUFFERS_VERSION} completed"
    return 0
}
