#!/usr/bin/env bash
# Base build: unmodified upstream simdjson 4.6.11, built and measured inside the
# private openEuler container.  The host only downloads and verifies the three
# pinned archives and invokes Docker.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

simdjson_check_inputs() {
    local arch
    arch="$(simdjson_arch "${EXPECTED_ARCH}")"
    [[ "${arch}" == "$(simdjson_arch "$(uname -m)")" ]] || {
        log_message "ERROR: requested architecture ${arch} differs from host $(uname -m)"
        return 20
    }
    [[ "${SOFTWARE_VERSION}" == "4.6.11" ]] || {
        log_message "ERROR: only simdjson 4.6.11 is supported, got ${SOFTWARE_VERSION}"
        return 10
    }
    [[ "$(id -u)" -ne 0 ]] || log_message 'WARNING: running as root; containers will run as root as well'
}

simdjson_install_dependencies() {
    log_message 'installing build dependencies inside the private container'
    simdjson_container_exec_root dnf install -y --setopt=install_weak_deps=False \
        cmake gcc gcc-c++ make unzip tar python3 findutils coreutils which diffutils gzip \
        || {
        log_message 'ERROR: dnf install failed inside the container'
        return 30
    }
}

simdjson_unpack_sources() {
    local downloads src build data_dir
    downloads="$(simdjson_downloads_dir)"
    src="$(simdjson_source_dir)"
    build="$(simdjson_benchmark_source_dir)"
    data_dir="$(simdjson_data_dir)"
    if [[ -e "${src}" || -e "${build}" ]]; then
        log_message 'ERROR: source or dependency directory already exists in the work directory'
        return 20
    fi
    mkdir -p "${PERF_WORK_DIR}/deps"
    simdjson_container_exec tar xzf "${downloads}/${SIMDJSON_SOURCE_ARCHIVE}" -C "${PERF_WORK_DIR}" || return 30
    simdjson_container_exec unzip -q "${downloads}/${SIMDJSON_BENCHMARK_ARCHIVE}" -d "${PERF_WORK_DIR}/deps" || return 30
    simdjson_container_exec unzip -q "${downloads}/${SIMDJSON_DATA_ARCHIVE}" -d "${PERF_WORK_DIR}/deps" || return 30
    # The corpus archive is pinned to a commit, so its top level directory is
    # simdjson-data-<full commit>; normalise it to the short name used everywhere.
    simdjson_container_exec bash -c '
        set -e
        deps="$1"
        short="${deps}/simdjson-data-3519499"
        if [ ! -d "${short}" ]; then
            found="$(find "${deps}" -maxdepth 1 -type d -name "simdjson-data-*" | head -n 1)"
            [ -n "${found}" ] || { echo "no simdjson-data directory after unpack" >&2; exit 1; }
            mv "${found}" "${short}"
        fi' _ "${PERF_WORK_DIR}/deps" || return 30
    simdjson_container_exec test -s "${src}/CMakeLists.txt" || { log_message "ERROR: missing ${src}/CMakeLists.txt"; return 40; }
    simdjson_container_exec test -s "${build}/CMakeLists.txt" || { log_message "ERROR: missing ${build}/CMakeLists.txt"; return 40; }
    simdjson_container_exec test -s "${data_dir}/gsoc-2018.json" || { log_message "ERROR: missing ${data_dir}/gsoc-2018.json"; return 40; }
    simdjson_container_exec test -s "${src}/jsonexamples/twitter.json" || { log_message "ERROR: missing bundled twitter.json"; return 40; }
}

simdjson_compile() {
    local build src gb_data
    build="$(simdjson_build_dir)"
    src="$(simdjson_source_dir)"
    gb_data="$(simdjson_data_dir)"
    log_message "configuring the offline benchmark harness in ${build}"
    simdjson_container_exec cmake -S "${SCRIPT_DIR}/scripts/benchmarks" -B "${build}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DSIMDJSON_SRC="${src}" \
        -DGOOGLE_BENCHMARK_SRC="$(simdjson_benchmark_source_dir)" \
        -DSIMDJSON_DATA_DIR="${gb_data}" \
        > "${RESULTS_DIR}/cmake-configure.log" 2>&1 || {
        log_message 'ERROR: cmake configure failed'
        simdjson_container_exec tail -n 40 "${RESULTS_DIR}/cmake-configure.log" || true
        return 30
    }
    log_message 'building the five official benchmark executables'
    simdjson_container_exec bash -c 'cmake --build "$1" -j "$(nproc)"' _ "${build}" \
        > "${RESULTS_DIR}/cmake-build.log" 2>&1 || {
        log_message 'ERROR: cmake build failed'
        simdjson_container_exec tail -n 60 "${RESULTS_DIR}/cmake-build.log" || true
        return 30
    }
    local target
    for target in "${SIMDJSON_TARGETS[@]}"; do
        simdjson_container_exec test -x "${build}/${target}" || {
            log_message "ERROR: expected executable is missing: ${build}/${target}"
            return 40
        }
    done
}

simdjson_detect_version() {
    local src version
    src="$(simdjson_source_dir)"
    version="$(simdjson_container_exec bash -c 'grep -m1 "^#define SIMDJSON_VERSION " "$1/include/simdjson/simdjson_version.h" | cut -d\" -f2' _ "${src}")" || return 40
    if [[ "${version}" != "4.6.11" ]]; then
        log_message "ERROR: built source reports version ${version}, expected 4.6.11"
        return 40
    fi
    printf '4.6.11\n' > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "verified simdjson source version: ${version}"
}

simdjson_smoke_test() {
    local src build log
    src="$(simdjson_source_dir)"
    build="$(simdjson_build_dir)"
    log="${RESULTS_DIR}/smoke.log"
    simdjson_container_exec "${build}/parse" -n 10 -t "${src}/jsonexamples/twitter.json" \
        > "${log}" 2> "${RESULTS_DIR}/smoke.err" || {
        log_message 'ERROR: smoke parse run failed'
        cat "${RESULTS_DIR}/smoke.err" 2>/dev/null || true
        cat "${log}" || true
        return 50
    }
    python3 - "${log}" <<'PY'
import math
import re
import sys

text = open(sys.argv[1], encoding="utf-8", errors="replace").read()
values = []
for line in text.splitlines():
    if not line.startswith('"'):
        continue
    fields = [item for item in line.split("\t") if item.strip()]
    numbers = []
    for field in fields[1:]:
        try:
            numbers.append(float(field))
        except ValueError:
            pass
    values.append(numbers[-3:])
if not values or any(len(v) != 3 for v in values):
    raise SystemExit("smoke check: no GB/s row in the parse output")
watts = [number for row in values for number in row]
if not all(math.isfinite(number) and number > 0 for number in watts):
    raise SystemExit(f"smoke check: non-positive GB/s value: {watts}")
print(f"smoke check: {len(values)} file row(s), GB/s {watts}", file=sys.stderr)
PY
}

build_simdjson_base() {
    local run_id="${PERF_RUN_ID}" arch downloads
    simdjson_check_inputs || return $?
    arch="$(simdjson_arch "${EXPECTED_ARCH}")"
    downloads="$(simdjson_downloads_dir)"
    log_message "base build: simdjson ${SOFTWARE_VERSION} on ${arch} (run ${run_id})"

    require_simdjson_docker || return $?
    mkdir -p "${downloads}"
    : > "${downloads}/sha256sums.txt"
    simdjson_fetch_archive "${SIMDJSON_SOURCE_ARCHIVE}" "${SIMDJSON_SOURCE_URL}" "${SIMDJSON_SOURCE_SHA256}" "${downloads}" || return $?
    simdjson_fetch_archive "${SIMDJSON_BENCHMARK_ARCHIVE}" "${SIMDJSON_BENCHMARK_URL}" "${SIMDJSON_BENCHMARK_SHA256}" "${downloads}" || return $?
    simdjson_fetch_archive "${SIMDJSON_DATA_ARCHIVE}" "${SIMDJSON_DATA_URL}" "${SIMDJSON_DATA_SHA256}" "${downloads}" || return $?
    ( cd "${downloads}" && sha256sum -c sha256sums.txt >/dev/null ) || {
        log_message 'ERROR: archive manifest verification failed'
        return 30
    }

    start_simdjson_container || return $?
    SIMDJSON_BUILD_RUN_ID="${run_id}"
    trap 'remove_simdjson_container || true' EXIT

    simdjson_install_dependencies || return $?
    simdjson_unpack_sources || return $?
    simdjson_compile || return $?
    simdjson_smoke_test || return 50
    simdjson_detect_version || return $?
    simdjson_write_build_variant base || return $?

    trap - EXIT
    log_message "base build finished; container ${SIMDJSON_CONTAINER_NAME} is retained for the start/test stages"
}
