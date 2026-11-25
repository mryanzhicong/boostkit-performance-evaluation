#!/usr/bin/env bash
# Base build: unmodified upstream RapidJSON 1.1.0 built and measured inside the
# private openEuler container.  The host only downloads and verifies the pinned
# archives, invokes Docker and runs the strict result parser.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

rapidjson_check_inputs() {
    local arch
    arch="$(rapidjson_arch "${EXPECTED_ARCH}")"
    [[ "${arch}" == "$(rapidjson_arch "$(uname -m)")" ]] || {
        log_message "ERROR: requested architecture ${arch} differs from host $(uname -m)"
        return 20
    }
    [[ "${SOFTWARE_VERSION}" == "1.1.0" ]] || {
        log_message "ERROR: only rapidjson 1.1.0 is supported, got ${SOFTWARE_VERSION}"
        return 10
    }
    [[ "$(id -u)" -ne 0 ]] || log_message 'WARNING: running as root; containers will run as root as well'
}

rapidjson_install_dependencies() {
    log_message 'installing build dependencies inside the private container'
    rapidjson_container_exec_root dnf install -y --setopt=install_weak_deps=False \
        cmake gcc gcc-c++ make tar gzip patch findutils which coreutils python3 \
        || {
        log_message 'ERROR: dnf install failed inside the container'
        return 30
    }
}

rapidjson_unpack_sources() {
    local downloads base opt gtest_archive src
    downloads="$(rapidjson_downloads_dir)"
    base="${PERF_WORK_DIR}/${RAPIDJSON_SOURCE_ROOT}"
    opt="${PERF_WORK_DIR}/${RAPIDJSON_OPTIMIZED_ROOT}"
    gtest_archive="${downloads}/${RAPIDJSON_GTEST_ARCHIVE}"
    if rapidjson_container_exec test -e "${base}" || rapidjson_container_exec test -e "${opt}"; then
        log_message 'ERROR: source directory already exists in the work directory'
        return 20
    fi
    rapidjson_container_exec tar xzf "${downloads}/${RAPIDJSON_SOURCE_ARCHIVE}" -C "${PERF_WORK_DIR}" || return 30
    rapidjson_container_exec mv "${PERF_WORK_DIR}/${RAPIDJSON_SOURCE_TAR_ROOT}" "${base}" || return 30
    rapidjson_container_exec cp -a "${base}" "${opt}" || return 30
    # rapidjson's FindGTestSrc adds thirdparty/gtest/googletest as a subdirectory,
    # so the archive has to be unpacked one level down with --strip-components=1.
    for src in "${base}" "${opt}"; do
        rapidjson_container_exec mkdir -p "${src}/thirdparty/gtest" || return 30
        rapidjson_container_exec tar xzf "${gtest_archive}" -C "${src}/thirdparty/gtest" --strip-components=1 || return 30
        rapidjson_container_exec test -s "${src}/thirdparty/gtest/googletest/CMakeLists.txt" || {
            log_message "ERROR: GoogleTest sources are missing below ${src}/thirdparty/gtest"
            return 40
        }
    done
    rapidjson_container_exec test -s "${base}/CMakeLists.txt" || { log_message "ERROR: missing ${base}/CMakeLists.txt"; return 40; }
    rapidjson_container_exec test -s "${base}/bin/data/sample.json" || { log_message 'ERROR: missing bundled sample.json'; return 40; }
    rapidjson_container_exec test -s "${base}/bin/types/paragraphs.json" || { log_message 'ERROR: missing bundled paragraphs.json'; return 40; }
}

# Only the optimized variant applies the case-owned Kunpeng patch; the base tree
# keeps the upstream include tree byte for byte.
rapidjson_apply_patch() {
    local opt patch
    opt="$(rapidjson_source_dir optimized)"
    patch="${SCRIPT_DIR}/fixtures/${RAPIDJSON_PATCH_FILE}"
    log_message "applying ${RAPIDJSON_PATCH_FILE} to ${opt}"
    rapidjson_container_exec_at "${opt}" bash -c '
        set -e
        patch -p1 --forward --no-backup-if-mismatch < "$1"
        grep -q "ScanCopyUnescapedString(EncodedInputStream<UTF8<>, MemoryStream>&" include/rapidjson/reader.h
        grep -q "Writer<StringBuffer>::WriteString" include/rapidjson/writer.h
    ' _ "${patch}" || {
        log_message 'ERROR: the Kunpeng patch did not apply cleanly or its fast paths are missing'
        return 30
    }
    log_message 'Kunpeng patch applied and both fast paths are present'
}

rapidjson_compile() {
    local variant src build extra="" arch
    variant="${PERF_VARIANT}"
    arch="$(rapidjson_arch "${EXPECTED_ARCH}")"
    src="$(rapidjson_source_dir)"
    build="$(rapidjson_build_dir)"
    if [[ "${variant}" == "optimized" && "${arch}" == "aarch64" ]]; then
        extra=" -march=armv8.2-a+simd -DRAPIDJSON_NEON"
    fi
    log_message "configuring RapidJSON ${variant} (${arch}) in ${build}"
    if ! rapidjson_container_exec cmake -S "${src}" -B "${build}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_FLAGS="-O3" \
        -DCMAKE_CXX_FLAGS_RELEASE="-O3 -DNDEBUG -Wno-error${extra}" \
        -DGOOGLETEST_VERSION=1.12.1 \
        -DRAPIDJSON_BUILD_DOC=OFF -DRAPIDJSON_BUILD_EXAMPLES=OFF \
        -DRAPIDJSON_BUILD_TESTS=ON -DRAPIDJSON_BUILD_THIRDPARTY_GTEST=ON \
        > "${RESULTS_DIR}/cmake-configure.log" 2>&1; then
        log_message 'ERROR: cmake configure failed'
        tail -n 40 "${RESULTS_DIR}/cmake-configure.log" 2>/dev/null || true
        return 30
    fi
    log_message 'building the perftest and unittest targets'
    if ! rapidjson_container_exec bash -c 'cmake --build "$1" -j "$(nproc)" --target perftest unittest' \
        _ "${build}" > "${RESULTS_DIR}/cmake-build.log" 2>&1; then
        log_message 'ERROR: cmake build failed'
        tail -n 60 "${RESULTS_DIR}/cmake-build.log" 2>/dev/null || true
        return 30
    fi
    local binary
    for binary in perftest unittest; do
        rapidjson_container_exec test -x "${build}/bin/${binary}" || {
            log_message "ERROR: expected executable is missing: ${build}/bin/${binary}"
            return 40
        }
    done
}

rapidjson_smoke_test() {
    local src build xml log err filter suffix name count
    src="$(rapidjson_source_dir)"
    build="$(rapidjson_build_dir)"
    xml="${RESULTS_DIR}/smoke.xml"
    log="${RESULTS_DIR}/smoke.log"
    err="${RESULTS_DIR}/smoke.err"
    filter="$(rapidjson_gtest_filter "${RAPIDJSON_SMOKE_CASE}")"
    rm -f -- "${xml}"
    if ! rapidjson_container_exec_at "${src}/bin" "${build}/bin/perftest" \
        --gtest_filter="${filter}" --gtest_repeat=1 \
        --gtest_output=xml:"${xml}" > "${log}" 2> "${err}"; then
        log_message 'ERROR: the perftest smoke run failed'
        tail -n 20 "${err}" 2>/dev/null || true
        tail -n 20 "${log}" 2>/dev/null || true
        return 40
    fi
    count="$(grep -c '<testcase ' "${xml}" 2>/dev/null || true)"
    if [[ "${count:-0}" != "1" ]]; then
        log_message "ERROR: the perftest smoke XML has ${count:-0} testcase entries, expected exactly 1"
        return 40
    fi
    if ! grep -q 'failures="0"' "${xml}" || grep -q '<failure' "${xml}"; then
        log_message 'ERROR: the perftest smoke XML reports a failure'
        return 40
    fi
    name="$(sed -n 's/.*<testcase name="\([^"]*\)".*/\1/p' "${xml}" | head -n 1)"
    for suffix in "${RAPIDJSON_ARCH_SUFFIXES[@]}"; do
        if [[ "${name}" == "${RAPIDJSON_SMOKE_CASE}_${suffix}" ]]; then
            RAPIDJSON_ARCH_SUFFIX="${suffix}"
            break
        fi
    done
    if [[ -z "${RAPIDJSON_ARCH_SUFFIX}" ]]; then
        log_message "ERROR: unexpected smoke testcase name: ${name:-<none>}"
        return 40
    fi
    log_message "smoke test passed: ${name}"
}

rapidjson_detect_version() {
    local src version
    src="$(rapidjson_source_dir)"
    version="$(rapidjson_container_exec bash -c '
        set -e
        header="$1/include/rapidjson/rapidjson.h"
        major=$(sed -n "s/^#define RAPIDJSON_MAJOR_VERSION \([0-9][0-9]*\)$/\1/p" "${header}" | head -n 1)
        minor=$(sed -n "s/^#define RAPIDJSON_MINOR_VERSION \([0-9][0-9]*\)$/\1/p" "${header}" | head -n 1)
        patch=$(sed -n "s/^#define RAPIDJSON_PATCH_VERSION \([0-9][0-9]*\)$/\1/p" "${header}" | head -n 1)
        if [ -z "${major}" ] || [ -z "${minor}" ] || [ -z "${patch}" ]; then
            echo "cannot read the RapidJSON version macros from ${header}" >&2
            exit 1
        fi
        printf "%s.%s.%s\n" "${major}" "${minor}" "${patch}"
    ' _ "${src}")" || return 40
    if [[ "${version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: built source reports version ${version}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    [[ -n "${PERF_ACTUAL_VERSION_FILE}" ]] || {
        log_message 'ERROR: PERF_ACTUAL_VERSION_FILE is not set'
        return 40
    }
    printf '%s\n' "${version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "verified rapidjson source version: ${version}"
}

build_rapidjson_base() {
    local run_id="${PERF_RUN_ID}"
    rapidjson_check_inputs || return $?
    log_message "base build: rapidjson ${SOFTWARE_VERSION} on $(rapidjson_arch "${EXPECTED_ARCH}") (run ${run_id})"

    require_rapidjson_docker || return $?
    rapidjson_fetch_inputs || return $?
    start_rapidjson_container || return $?
    trap 'remove_rapidjson_container || true' EXIT

    rapidjson_install_dependencies || return $?
    rapidjson_unpack_sources || return $?
    rapidjson_compile || return $?
    rapidjson_smoke_test || return $?
    rapidjson_detect_version || return $?
    rapidjson_write_build_variant || return $?

    trap - EXIT
    log_message "base build finished; container ${RAPIDJSON_CONTAINER_NAME} is retained for the start/test stages"
}
