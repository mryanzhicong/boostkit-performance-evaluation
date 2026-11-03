#!/usr/bin/env bash
# Build the pinned fbthrift ProtocolBench from verified upstream sources.
#
# Dependency chain (all versions pinned, see README.md):
#   fmt 12.1.0 -> fast_float 8.0.0 (headers) -> google benchmark v1.9.5
#   -> folly v2026.10.26.00 -> fbthrift v2026.10.26.00 (THRIFT_RPC=OFF,
#   THRIFT_BENCHMARKS=ON) -> install/bin/ProtocolBench
#
# fizz / wangle / mvfst / fb303 are not built: they belong to the RPC transport
# stack behind THRIFT_RPC, while ProtocolBench only exercises codegen and
# (de)serialization, so linking them would add build risk without touching the
# measured path.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

fetch_all_sources() {
    local -a urls=()
    mapfile -t urls < <(github_archive_urls facebook fbthrift "${FBTHRIFT_TAG}")
    download_verified "fbthrift ${FBTHRIFT_TAG}" \
        "fbthrift-${FBTHRIFT_TAG}.tar.gz" "${FBTHRIFT_SHA256}" "${urls[@]}" || return 30
    mapfile -t urls < <(github_archive_urls facebook folly "${FOLLY_TAG}")
    download_verified "folly ${FOLLY_TAG}" \
        "folly-${FOLLY_TAG}.tar.gz" "${FOLLY_SHA256}" "${urls[@]}" || return 30
    mapfile -t urls < <(github_archive_urls fmtlib fmt "${FMT_TAG}")
    download_verified "fmt ${FMT_TAG}" \
        "fmt-${FMT_TAG}.tar.gz" "${FMT_SHA256}" "${urls[@]}" || return 30
    mapfile -t urls < <(github_archive_urls fastfloat fast_float "${FASTFLOAT_TAG}")
    download_verified "fast_float ${FASTFLOAT_TAG}" \
        "fast_float-${FASTFLOAT_TAG}.tar.gz" "${FASTFLOAT_SHA256}" "${urls[@]}" || return 30
    mapfile -t urls < <(github_archive_urls google benchmark "${BENCHMARK_TAG}")
    download_verified "google benchmark ${BENCHMARK_TAG}" \
        "benchmark-${BENCHMARK_TAG}.tar.gz" "${BENCHMARK_SHA256}" "${urls[@]}" || return 30

    extract_verified_archive "fbthrift ${FBTHRIFT_TAG}" \
        "fbthrift-${FBTHRIFT_TAG}.tar.gz" "${FBTHRIFT_TOP_DIR}" "${FBTHRIFT_SOURCE_DIR}" || return 30
    extract_verified_archive "folly ${FOLLY_TAG}" \
        "folly-${FOLLY_TAG}.tar.gz" "${FOLLY_TOP_DIR}" "${FOLLY_SOURCE_DIR}" || return 30
    extract_verified_archive "fmt ${FMT_TAG}" \
        "fmt-${FMT_TAG}.tar.gz" "${FMT_TOP_DIR}" "${FMT_SOURCE_DIR}" || return 30
    extract_verified_archive "fast_float ${FASTFLOAT_TAG}" \
        "fast_float-${FASTFLOAT_TAG}.tar.gz" "${FASTFLOAT_TOP_DIR}" "${FASTFLOAT_SOURCE_DIR}" || return 30
    extract_verified_archive "google benchmark ${BENCHMARK_TAG}" \
        "benchmark-${BENCHMARK_TAG}.tar.gz" "${BENCHMARK_TOP_DIR}" "${BENCHMARK_SOURCE_DIR}" || return 30
}

verify_source_identity() {
    verify_file_fingerprint "fbthrift ProtocolBench.cpp" \
        "${FBTHRIFT_SOURCE_DIR}/thrift/lib/cpp2/test/ProtocolBench.cpp" \
        "${FBTHRIFT_PROTOCOLBENCH_SHA256}" || return 30
    verify_file_fingerprint "fbthrift ProtocolBenchData.thrift" \
        "${FBTHRIFT_SOURCE_DIR}/thrift/lib/cpp2/test/ProtocolBenchData.thrift" \
        "${FBTHRIFT_PROTOCOLBENCH_DATA_SHA256}" || return 30
    verify_file_fingerprint "folly CMakeLists.txt" \
        "${FOLLY_SOURCE_DIR}/CMakeLists.txt" \
        "${FOLLY_CMAKELISTS_SHA256}" || return 30
    log_message "verified pinned fbthrift commit ${FBTHRIFT_COMMIT} and folly ${FOLLY_TAG} sources"
}

build_fmt() {
    log_message "building fmt ${FMT_TAG}"
    run_cmake -S "${FMT_SOURCE_DIR}" -B "${FMT_BUILD_DIR}" -G "${CMAKE_GENERATOR}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DFMT_TEST=OFF -DFMT_DOC=OFF || return 30
    run_cmake --build "${FMT_BUILD_DIR}" -j "${PERF_BUILD_JOBS}" || return 30
    run_cmake --install "${FMT_BUILD_DIR}" || return 30
}

install_fast_float_headers() {
    log_message "installing fast_float ${FASTFLOAT_TAG} headers"
    run_cmake -S "${FASTFLOAT_SOURCE_DIR}" -B "${FASTFLOAT_BUILD_DIR}" -G "${CMAKE_GENERATOR}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
        -DFASTFLOAT_TEST=OFF -DFASTFLOAT_SANITIZE=OFF || return 30
    run_cmake --install "${FASTFLOAT_BUILD_DIR}" || return 30
}

build_google_benchmark() {
    log_message "building google benchmark ${BENCHMARK_TAG}"
    run_cmake -S "${BENCHMARK_SOURCE_DIR}" -B "${BENCHMARK_BUILD_DIR}" -G "${CMAKE_GENERATOR}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DBENCHMARK_ENABLE_TESTING=OFF || return 30
    run_cmake --build "${BENCHMARK_BUILD_DIR}" -j "${PERF_BUILD_JOBS}" || return 30
    run_cmake --install "${BENCHMARK_BUILD_DIR}" || return 30
}

build_folly() {
    local arch_flags
    arch_flags="$(resolve_arch_flags)"
    log_message "building folly ${FOLLY_TAG} (arch flags: ${arch_flags:-none})"
    run_cmake -S "${FOLLY_SOURCE_DIR}" -B "${FOLLY_BUILD_DIR}" -G "${CMAKE_GENERATOR}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
        -DCMAKE_PREFIX_PATH="${INSTALL_PREFIX}" \
        -DCMAKE_C_FLAGS="${arch_flags}" \
        -DCMAKE_CXX_FLAGS="${arch_flags}" \
        -DBUILD_SHARED_LIBS=OFF \
        -DBOOST_LINK_STATIC=ON \
        -DBUILD_TESTS=OFF \
        -DBUILD_BENCHMARKS=OFF || return 30
    run_cmake --build "${FOLLY_BUILD_DIR}" -j "${PERF_BUILD_JOBS}" || return 30
    run_cmake --install "${FOLLY_BUILD_DIR}" || return 30
}

build_fbthrift() {
    local arch_flags
    arch_flags="$(resolve_arch_flags)"
    log_message "building fbthrift ${FBTHRIFT_TAG} (ProtocolBench only, THRIFT_RPC=OFF)"
    run_cmake -S "${FBTHRIFT_SOURCE_DIR}" -B "${FBTHRIFT_BUILD_DIR}" -G "${CMAKE_GENERATOR}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
        -DCMAKE_PREFIX_PATH="${INSTALL_PREFIX}" \
        -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
        -DCMAKE_C_FLAGS="${arch_flags}" \
        -DCMAKE_CXX_FLAGS="${arch_flags}" \
        -DTHRIFT_RPC=OFF \
        -DTHRIFT_TESTS=OFF \
        -DTHRIFT_BENCHMARKS=ON \
        -DTHRIFT_PY_DEPRECATED=OFF || return 30
    run_cmake --build "${FBTHRIFT_BUILD_DIR}" -j "${PERF_BUILD_JOBS}" || return 30
    run_cmake --install "${FBTHRIFT_BUILD_DIR}" || return 30
}

verify_protocol_bench() {
    fbthrift_container_exec test -x "${PROTOCOL_BENCH_BIN}" || {
        log_message "ERROR: ProtocolBench was not installed at ${PROTOCOL_BENCH_BIN}"
        return 30
    }
    local listing="${BUILD_ROOT}/ProtocolBench-cases.txt"
    log_message "listing ProtocolBench cases inside the private container"
    fbthrift_container_exec env LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}" \
        "${PROTOCOL_BENCH_BIN}" --benchmark_list_tests=true > "${listing}" 2>&1 || {
        log_message "ERROR: ProtocolBench cannot list its benchmarks"
        return 30
    }
    local scenario group benchmark filter count=0
    while IFS=$'\t' read -r scenario group benchmark filter; do
        [[ -n "${scenario:-}" ]] || continue
        if ! grep -Fxq -- "${benchmark}" "${listing}"; then
            log_message "ERROR: ProtocolBench does not provide the declared benchmark ${benchmark}"
            return 30
        fi
        count=$((count + 1))
    done < "${SCENARIOS_FILE}"
    if (( count < 6 || count > 10 )); then
        log_message "ERROR: scenario matrix must declare 6..10 scenarios, found ${count}"
        return 30
    fi
    log_message "ProtocolBench lists all ${count} declared benchmark cases"
}

write_dependencies_json() {
    local output="${RESULTS_DIR}/dependencies.json"
    local os_name="" compiler="" cmake_version=""
    os_name="$(fbthrift_container_exec sed -n 's/^PRETTY_NAME=//p' /etc/os-release 2>/dev/null | tr -d '"' | head -n 1)"
    compiler="$(fbthrift_container_exec "${CXX:-c++}" --version 2>/dev/null | head -n 1)"
    cmake_version="$(fbthrift_container_exec "${PERF_CMAKE_BIN}" --version 2>/dev/null | head -n 1 | awk '{print $3}')"
    local -a packages=()
    local cpu_model=""
    cpu_model="$(fbthrift_container_exec awk -F': ' '/model name/{print $2; exit}' /proc/cpuinfo 2>/dev/null)"
    python3 - "${output}" "${SOFTWARE_VERSION}" "${FBTHRIFT_TAG}" "${FBTHRIFT_COMMIT}" \
        "${os_name:-unknown}" "${compiler:-unknown}" "${cmake_version:-unknown}" \
        "${cpu_model:-unknown}" "${PERF_BUILD_JOBS}" "${DEPENDENCY_RECORDS[@]}" <<'PY'
import json
import sys

(output, version, tag, commit, os_name, compiler, cmake_version,
 cpu_model, jobs, *records) = sys.argv[1:]
dependencies = []
for record in records:
    label, kind, source, sha256 = record.split("|", 3)
    dependencies.append({
        "name": label,
        "source_kind": kind,
        "source": source,
        "sha256": sha256,
    })
payload = {
    "software": "fbthrift",
    "version": version,
    "source_tag": tag,
    "source_commit": commit,
    "build": {
        "os": os_name,
        "compiler": compiler,
        "cmake": cmake_version,
        "cpu_model": cpu_model,
        "jobs": int(jobs),
        "thrift_rpc": "OFF",
        "thrift_benchmarks": "ON",
        "install_prefix": "PERF_WORK_DIR/install",
    },
    "dependencies": dependencies,
}
with open(output, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, ensure_ascii=False, indent=2)
    handle.write("\n")
PY
    log_message "recorded dependency provenance in ${output}"
}

write_actual_version() {
    # The tested revision is read back from the extracted pinned source tree
    # (archive SHA-256 + content fingerprints already verified above), because
    # fbthrift's CMake project() declares a constant 1.0.0 and installs no
    # version file that carries the weekly date tag.
    local recorded_top actual
    local marker="${FBTHRIFT_SOURCE_DIR}/.fbthrift-source-top"
    [[ -f "${marker}" ]] || {
        log_message "ERROR: pinned fbthrift source marker is missing: ${marker}"
        return 30
    }
    recorded_top="$(head -n 1 "${marker}")"
    actual="${recorded_top#fbthrift-}"
    if [[ -z "${actual}" || "${actual}" == "${recorded_top}" ]]; then
        log_message "ERROR: cannot derive the fbthrift version from ${recorded_top}"
        return 30
    fi
    if [[ "${actual}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: requested version ${SOFTWARE_VERSION}, built source ${actual}"
        return 30
    fi
    verify_protocol_bench || return 30
    printf '%s\n' "${actual}" > "${PERF_ACTUAL_VERSION_FILE}" || return 30
    log_message "actual fbthrift source version: ${actual} (tag ${FBTHRIFT_TAG})"
}

build_fbthrift_base() {
    validate_variant || return $?
    initialize_runtime || return $?
    prepare_fbthrift_build_container || return 30
    require_build_tools || return 30
    install_system_dependencies || return 30
    # Resolve the generator after installing dependencies: the dnf branch inside
    # the container installs ninja-build, and picking it up keeps the build fast
    # instead of falling back to Unix Makefiles on the first run of a fresh image.
    resolve_cmake_generator
    fetch_all_sources || return 30
    verify_source_identity || return 30
    build_fmt || return 30
    install_fast_float_headers || return 30
    build_google_benchmark || return 30
    build_folly || return 30
    build_fbthrift || return 30
    write_actual_version || return 30
    write_dependencies_json || return 30
    log_message "base build finished: ${PROTOCOL_BENCH_BIN}"
}
