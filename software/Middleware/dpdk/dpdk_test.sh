#!/usr/bin/env bash
# DPDK performance case (official source tarball with an in-process
# data-plane benchmark harness).
#
# DPDK is a C library framework whose official distribution channel is
# the source tarball from dpdk.org (fast.dpdk.org/rel), so the software
# under test is the library set built from that tarball (SHA-256
# verified; configured with the official meson defaults and compiled
# entirely inside the isolated work directory — nothing is installed
# system-wide).  The benchmark harness is compiled against that build
# via pkg-config — the same source-build approach the x264/x265 and
# jemalloc cases use — and drives the three core data-plane libraries
# every DPDK packet application is built on:
#
#   ring: rte_ring MP/MC burst enqueue/dequeue on a shared ring — the
#         inter-core queueing primitive at the heart of every packet
#         pipeline.  1 op = one element enqueued and dequeued.
#   hash: rte_hash lookups against a preloaded 256k-entry flow table
#         (16-byte keys, 7/8 hits) — the flow-table lookup shape of
#         OVS/vSwitch class applications.
#   lpm:  rte_lpm IPv4 lookups against 64k /24 routes (7/8 hits) — the
#         FIB lookup shape of every DPDK route benchmark.
#
# EAL is initialized with "--no-huge --in-memory -l 0 -m 1024" so runs
# never depend on host hugepage configuration or create runtime files,
# and worker threads are plain pthreads (the libraries are safe from
# any threads; all writes happen during prefill).
#
# Scenarios are the three workloads crossed with the mysql-style thread
# ladder (1/4/16/64).  Every operation is timed with
# clock_gettime(CLOCK_MONOTONIC), so latencies are in nanoseconds on
# every architecture.  Each run reports operation throughput and
# sampled per-operation latency percentiles.
#
# The four framework stages map to: fetch+verify the tarball, build the
# libraries and the harness (build), smoke-run the harness end to end
# (start), run the full scenario matrix (test), and drop the benchmark
# data (stop).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="dpdk"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-26.07}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

# Official dpdk.org release server (the official DPDK distribution).
DPDK_RELEASE_BASE="${DPDK_RELEASE_BASE:-https://fast.dpdk.org/rel}"
DPDK_OFFLINE_DIR="${DPDK_OFFLINE_DIR:-/home/runner/software/dpdk}"

# Benchmark matrix: workloads crossed with the thread ladder.
DPDK_WORKLOADS=("ring" "hash" "lpm")
DPDK_THREADS_LADDER=(1 4 16 64)
DPDK_WARMUP_SECONDS="${DPDK_WARMUP_SECONDS:-5}"
DPDK_DURATION_SECONDS="${DPDK_DURATION_SECONDS:-30}"
DPDK_BUILD_JOBS="${DPDK_BUILD_JOBS:-$(nproc)}"

# Lifecycle paths (assigned in configure_runtime_paths).
SOURCE_DIR=""
BUILD_DIR=""
INSTALL_DIR=""
BENCHMARK_BIN=""
BENCHMARK_DIR=""
RUNS_DIR=""

log() {
    printf '[dpdk] %s\n' "$*"
}

configure_runtime_paths() {
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64)
            EXPECTED_ARCH="x86_64"
            ;;
        aarch64|arm64)
            EXPECTED_ARCH="aarch64"
            ;;
        *)
            EXPECTED_ARCH="${EXPECTED_ARCH,,}"
            ;;
    esac
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/dpdk/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/dpdk-${SOFTWARE_VERSION}"
    BUILD_DIR="${PERF_WORK_DIR}/build"
    INSTALL_DIR="${PERF_WORK_DIR}/install"
    BENCHMARK_BIN="${PERF_WORK_DIR}/dpdk_benchmark"
    BENCHMARK_DIR="${PERF_WORK_DIR}/benchmark"
    RUNS_DIR="${BENCHMARK_DIR}/runs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}"
}

require_dpdk_tools() {
    local command_name package
    local packages=()

    for command_name in curl sha256sum tar xz gcc meson ninja pkg-config grep sed tee python3 stat sudo; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            curl) package="curl" ;;
            sha256sum|tee|stat) package="coreutils" ;;
            tar) package="tar" ;;
            xz) package="xz" ;;
            gcc) package="gcc" ;;
            meson) package="meson" ;;
            ninja) package="ninja-build" ;;
            pkg-config) package="pkgconf" ;;
            grep) package="grep" ;;
            sed) package="sed" ;;
            python3) package="python3" ;;
            sudo) package="sudo" ;;
        esac
        log "missing required dpdk test command: ${command_name}"
        packages+=("${package}")
    done

    # meson needs the pyelftools module (python3 -m elftools)
    if ! python3 -c "import elftools" >/dev/null 2>&1; then
        log "missing required dpdk test python module: elftools"
        packages+=("python3-pyelftools")
    fi

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log "ERROR: dnf is required to install dpdk test prerequisites"
        return 30
    fi

    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log "installing missing dpdk test packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log "ERROR: sudo is required to install dpdk test prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log "ERROR: failed to install dpdk test prerequisites"
        return 30
    fi

    for command_name in curl sha256sum tar xz gcc meson ninja pkg-config python3; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "ERROR: required dpdk test command remains unavailable: ${command_name}"
            return 30
        fi
    done
    if ! python3 -c "import elftools" >/dev/null 2>&1; then
        log "ERROR: required dpdk test python module remains unavailable: elftools"
        return 30
    fi
}

download_archive() {
    local archive_path="$1"
    local download_url="$2"

    log "downloading ${download_url}" >&2
    if command -v curl >/dev/null 2>&1; then
        if ! curl -fSL --retry 3 --connect-timeout 30 -o "${archive_path}" "${download_url}"; then
            rm -f "${archive_path}"
            log "ERROR: failed to download ${download_url}" >&2
            return 30
        fi
    elif ! wget -q -O "${archive_path}" "${download_url}"; then
        rm -f "${archive_path}"
        log "ERROR: failed to download ${download_url}" >&2
        return 30
    fi
}

verify_sha256() {
    local archive_path="$1"
    local expected_sha256="$2"
    local actual_sha256

    actual_sha256="$(sha256sum "${archive_path}")"
    actual_sha256="${actual_sha256%% *}"
    if [[ "${actual_sha256}" != "${expected_sha256}" ]]; then
        log "ERROR: checksum mismatch for ${archive_path}: expected ${expected_sha256}, got ${actual_sha256}" >&2
        return 30
    fi
}

# The checksums are taken from the official release artifacts
# (downloaded from the official dpdk.org release URL and verified
# locally).  Adding a version means adding its entry here.
dpdk_tarball_sha256() {
    case "${SOFTWARE_VERSION}" in
        26.07)
            printf '%s\n' "7141a8b5bad9d7d965483ac0d75317ac0c21dcee1d13d373693c655f9e3fabe6" ;;
        *)
            log "ERROR: no verified dpdk release is declared for ${SOFTWARE_VERSION}"
            return 10
            ;;
    esac
}

fetch_dpdk_source() {
    local archive_name="dpdk-${SOFTWARE_VERSION}.tar.xz"
    local archive_path="${PERF_WORK_DIR}/${archive_name}"
    local expected_sha256

    if [[ -s "${SOURCE_DIR}/meson.build" ]]; then
        log "using cached source tree ${SOURCE_DIR}"
        return 0
    fi
    expected_sha256="$(dpdk_tarball_sha256)" || return $?
    if [[ ! -s "${archive_path}" ]]; then
        if [[ -f "${DPDK_OFFLINE_DIR}/${archive_name}" ]]; then
            log "using local dpdk source ${DPDK_OFFLINE_DIR}/${archive_name}" >&2
            cp "${DPDK_OFFLINE_DIR}/${archive_name}" "${archive_path}" || return 30
        else
            download_archive "${archive_path}" \
                "${DPDK_RELEASE_BASE}/${archive_name}" || return 30
        fi
    fi
    verify_sha256 "${archive_path}" "${expected_sha256}" || return 30
    tar -xJf "${archive_path}" -C "${PERF_WORK_DIR}" || return 30
    if [[ ! -f "${SOURCE_DIR}/meson.build" ]]; then
        log "ERROR: the extracted source tree has no meson.build"
        return 30
    fi
    log "official dpdk ${SOFTWARE_VERSION} source tree is ready"
}

# EAL refuses to load plugins from any path with a world-writable
# ancestor (security check), so reject such work directories up front
# with a clear message instead of failing at the first smoke run.
check_workdir_writable_safety() {
    local current="${PERF_WORK_DIR%/}"
    local mode_bits

    while [[ "${current}" != "/" && -n "${current}" ]]; do
        if [[ -d "${current}" ]]; then
            mode_bits="$(stat -c '%a' "${current}")"
            if [[ $((8#${mode_bits} & 2)) -ne 0 ]]; then
                log "ERROR: ${current} is world-writable, and DPDK EAL refuses plugin paths under world-writable directories; use a work directory such as the default /home/runner/boostkit-perf/dpdk/local-*"
                return 20
            fi
        fi
        current="$(dirname "${current}")"
    done
}

dpdk_pkgconfig_dir() {
    find "${INSTALL_DIR}" -name libdpdk.pc -exec dirname {} \; | head -n 1
}

build_dpdk_library() {
    local pkgconfig_dir

    if [[ ! -d "${BUILD_DIR}" ]]; then
        log "configuring and building dpdk (meson defaults, prefix isolated)"
        # max_numa_nodes=1 is the officially documented single-NUMA-node
        # build; it removes the optional libnuma dependency and makes the
        # build identical on every host.
        if ! (cd "${SOURCE_DIR}" && meson setup "${BUILD_DIR}" \
                --prefix="${INSTALL_DIR}" \
                -Dmax_numa_nodes=1) > "${PERF_WORK_DIR}/meson-setup.log" 2>&1; then
            log "ERROR: meson setup failed (see ${PERF_WORK_DIR}/meson-setup.log)"
            return 40
        fi
        if ! ninja -C "${BUILD_DIR}" -j"${DPDK_BUILD_JOBS}" \
                > "${PERF_WORK_DIR}/ninja.log" 2>&1; then
            log "ERROR: ninja failed (see ${PERF_WORK_DIR}/ninja.log)"
            return 40
        fi
        if ! meson install -C "${BUILD_DIR}" \
                > "${PERF_WORK_DIR}/install.log" 2>&1; then
            log "ERROR: meson install failed (see ${PERF_WORK_DIR}/install.log)"
            return 40
        fi
    fi
    pkgconfig_dir="$(dpdk_pkgconfig_dir)"
    if [[ -z "${pkgconfig_dir}" ]]; then
        log "ERROR: the built dpdk installation has no libdpdk.pc"
        return 40
    fi
    log "dpdk libraries are staged under ${INSTALL_DIR}"
}

compile_benchmark() {
    local source="${SCRIPT_DIR}/src/dpdk_benchmark.c"
    local pkgconfig_dir
    local libdir
    local cflags
    local libs

    if [[ ! -f "${source}" ]]; then
        log "ERROR: the benchmark source is missing: ${source}"
        return 40
    fi
    pkgconfig_dir="$(dpdk_pkgconfig_dir)"
    if [[ -z "${pkgconfig_dir}" ]]; then
        log "ERROR: the dpdk installation has no libdpdk.pc"
        return 40
    fi
    export PKG_CONFIG_PATH="${pkgconfig_dir}"
    libdir="$(pkg-config --variable=libdir libdpdk)"
    cflags="$(pkg-config --cflags libdpdk)"
    libs="$(pkg-config --libs libdpdk)"
    if [[ -z "${libdir}" || -z "${libs}" ]]; then
        log "ERROR: pkg-config could not resolve the dpdk libraries"
        return 40
    fi
    if ! gcc -O2 -Wall -Wextra ${cflags} \
            -o "${BENCHMARK_BIN}" \
            "${source}" \
            ${libs} \
            -Wl,-rpath,"${libdir}" \
            -lpthread; then
        log "ERROR: failed to compile the data-plane benchmark harness"
        return 40
    fi
    if [[ ! -x "${BENCHMARK_BIN}" ]]; then
        log "ERROR: the compiled benchmark binary is missing"
        return 40
    fi
}

build_dpdk() {
    local actual_version
    local version_major
    local version_minor
    local version_rest
    local runner_architecture

    initialize_runtime || return $?
    runner_architecture="$(uname -m)"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    require_dpdk_tools || return $?
    check_workdir_writable_safety || return $?
    if [[ -e "${BENCHMARK_BIN}" ]]; then
        log "ERROR: build output is not clean under ${BENCHMARK_BIN}"
        return 20
    fi

    fetch_dpdk_source || return $?
    build_dpdk_library || return $?
    compile_benchmark || return $?

    # rte_version() reports "DPDK <major>.<minor>.<patch>"; the
    # major.minor part must match the requested version exactly.
    actual_version="$("${BENCHMARK_BIN}" --version | sed -nE 's/^dpdk-version=DPDK //p' | head -n 1)"
    version_major="${actual_version%%.*}"
    version_rest="${actual_version#*.}"
    version_minor="${version_rest%%.*}"
    if [[ -z "${actual_version}" || "${version_major}.${version_minor}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: staged dpdk is ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "dpdk ${actual_version} staged with the compiled data-plane benchmark harness"
}

validate_run_report() {
    local report="$1"

    python3 - "${report}" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as report:
    payload = json.load(report)
for field in ("operations", "operations_per_second", "avg_op_ns", "p99_op_ns"):
    value = payload[field]
    assert isinstance(value, (int, float)) and value > 0, (field, value)
assert payload["duration_seconds"] > 0
PY
}

start_dpdk_runtime() {
    initialize_runtime || return $?
    if [[ ! -x "${BENCHMARK_BIN}" ]]; then
        log "ERROR: the benchmark harness is not built (run build first)"
        return 40
    fi
    if [[ -e "${BENCHMARK_DIR}" ]]; then
        log "ERROR: benchmark directory is not clean: ${BENCHMARK_DIR}"
        return 20
    fi

    # Smoke-run each workload once so the test stage only ever times a
    # verified harness.
    mkdir -p "${BENCHMARK_DIR}"
    local workload
    for workload in "${DPDK_WORKLOADS[@]}"; do
        log "smoke-running the ${workload} workload harness"
        if ! "${BENCHMARK_BIN}" \
                --workload "${workload}" \
                --threads 2 \
                --warmup-seconds 1 \
                --duration-seconds 2 \
                --scenario "smoke ${workload}" \
                --output "${BENCHMARK_DIR}/smoke-${workload}.json"; then
            rm -rf "${BENCHMARK_DIR}"
            log "ERROR: the ${workload} smoke run failed"
            return 40
        fi
        if ! validate_run_report "${BENCHMARK_DIR}/smoke-${workload}.json"; then
            rm -rf "${BENCHMARK_DIR}"
            log "ERROR: the ${workload} smoke run report is invalid"
            return 40
        fi
    done
    rm -rf "${BENCHMARK_DIR}"
    log "dpdk benchmark runtime is ready"
}

run_dpdk_benchmarks() {
    local raw_output
    local workload threads run_file

    initialize_runtime || return $?
    require_dpdk_tools || return $?
    if [[ ! -x "${BENCHMARK_BIN}" ]]; then
        log "ERROR: the benchmark harness is not built (run build first)"
        return 50
    fi

    raw_output="${RESULTS_DIR}/dpdk_dataplane_raw.log"
    mkdir -p "${BENCHMARK_DIR}"
    rm -rf "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"
    log "running the data-plane scenario matrix (warmup=${DPDK_WARMUP_SECONDS}s, duration=${DPDK_DURATION_SECONDS}s)"

    if ! (
        for workload in "${DPDK_WORKLOADS[@]}"; do
            for threads in "${DPDK_THREADS_LADDER[@]}"; do
                run_file="${RUNS_DIR}/${workload}-t${threads}.json"
                "${BENCHMARK_BIN}" \
                    --workload "${workload}" \
                    --threads "${threads}" \
                    --warmup-seconds "${DPDK_WARMUP_SECONDS}" \
                    --duration-seconds "${DPDK_DURATION_SECONDS}" \
                    --scenario "${workload}" \
                    --output "${run_file}" || exit 50
                validate_run_report "${run_file}" || exit 50
            done
        done
    ) 2>&1 | tee "${raw_output}"; then
        log "ERROR: the data-plane benchmark matrix failed (see ${raw_output})"
        return 50
    fi

    python3 "${SCRIPT_DIR}/scripts/collect_dpdk_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" || return 50
    log "data-plane benchmark matrix completed"
}

stop_dpdk_runtime() {
    initialize_runtime || return $?
    log "dpdk benchmark has no background service to stop"
    if [[ -d "${BENCHMARK_DIR}" ]]; then
        rm -rf "${BENCHMARK_DIR}"
        log "benchmark run data removed from ${BENCHMARK_DIR}"
    fi
}

standalone_runtime() {
    python3 "${SCRIPT_DIR}/scripts/standalone_runtime.py" "$@"
}

cleanup_standalone_workdir() {
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 1 ]]; then
        log "keeping standalone work directory: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${STANDALONE_OWNS_WORK_DIR}" -ne 1 ]]; then
        log "external work directory was not removed: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/dpdk/local-* || \
          "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/dpdk" ]]; then
        log "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    fi
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        rm -rf -- "${PERF_WORK_DIR}" || return 70
    fi
    log "cleaned standalone work directory: ${PERF_WORK_DIR}"
}

emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then
        stop_dpdk_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_dpdk_standalone() {
    local stage_status=0 failed_stage="" cleanup_status="passed" finalize_status=0
    local command_status="passed"

    configure_runtime_paths || return $?
    STANDALONE_STOP_DONE=0
    STANDALONE_CLEANUP_DONE=0
    trap emergency_standalone_cleanup EXIT
    initialize_runtime || return $?

    if standalone_runtime system "${RESULTS_DIR}/system_info.json" && \
        standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json"; then
        :
    else
        stage_status=$?
        failed_stage="prepare"
    fi

    if [[ "${stage_status}" -eq 0 ]]; then
        if build_dpdk; then
            if standalone_runtime build-info \
                "${RESULTS_DIR}/build_info.json" \
                "${SOFTWARE_VERSION}" \
                "${PERF_ACTUAL_VERSION_FILE}" \
                "${EXPECTED_ARCH}" \
                "${PERF_RUN_ID}"; then
                :
            else
                stage_status=$?
                failed_stage="build"
            fi
        else
            stage_status=$?
            failed_stage="build"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if start_dpdk_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_dpdk_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_dpdk_runtime; then
        cleanup_status="failed"
    fi
    STANDALONE_STOP_DONE=1
    if ! standalone_runtime runtime "${RESULTS_DIR}/runtime_after.json"; then
        cleanup_status="failed"
    fi
    if ! cleanup_standalone_workdir; then
        cleanup_status="failed"
    fi
    STANDALONE_CLEANUP_DONE=1

    if [[ "${stage_status}" -ne 0 ]]; then
        command_status="failed"
    fi
    if standalone_runtime finalize \
        "${RESULTS_DIR}" \
        "${SOFTWARE_VERSION}" \
        "${EXPECTED_ARCH}" \
        "${PERF_RUN_ID}" \
        "${command_status}" \
        "${cleanup_status}" \
        "${failed_stage}"; then
        finalize_status=0
    else
        finalize_status=$?
    fi
    trap - EXIT
    if [[ "${stage_status}" -ne 0 ]]; then
        return "${stage_status}"
    fi
    if [[ "${cleanup_status}" != "passed" ]]; then
        return 70
    fi
    return "${finalize_status}"
}

usage() {
    cat <<USAGE
Usage: $(basename "$0") [OPTIONS]

Build the official dpdk ${SOFTWARE_VERSION} source tarball inside an
isolated work directory, compile the data-plane benchmark harness against
it, and run the workload x thread-count matrix as a standalone performance
evaluation. Results default to results/<version>/<run-id>/ inside this
directory.

Options:
  --version VERSION       dpdk version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR,
  DPDK_BUILD_JOBS, DPDK_WARMUP_SECONDS, DPDK_DURATION_SECONDS
USAGE
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version)
                if [[ "$#" -lt 2 ]]; then
                    log "ERROR: --version requires a value"
                    return 10
                fi
                SOFTWARE_VERSION="$2"
                shift 2
                ;;
            --results-dir)
                if [[ "$#" -lt 2 ]]; then
                    log "ERROR: --results-dir requires a value"
                    return 10
                fi
                RESULTS_DIR="$2"
                shift 2
                ;;
            --keep-workdir)
                STANDALONE_KEEP_WORK_DIR=1
                shift
                ;;
            -h|--help)
                usage
                return 0
                ;;
            *)
                log "ERROR: unsupported option: $1"
                usage
                return 10
                ;;
        esac
    done

    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" || return 10
    : > "${RESULTS_DIR}/results.log"
    local pipeline_status=0
    set +e
    run_dpdk_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
