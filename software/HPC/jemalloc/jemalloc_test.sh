#!/usr/bin/env bash
# jemalloc performance case (official source tarball with an in-process
# allocation benchmark harness).
#
# jemalloc is a C library whose official distribution channel is the
# GitHub release source tarball, so the software under test is the
# library built from that tarball (SHA-256 verified; configured,
# compiled and installed entirely inside the isolated work directory —
# nothing is installed system-wide).  The benchmark harness is compiled
# against that build with gcc — the same source-build approach the
# x264/x265 cases use — and drives jemalloc with the two classic
# allocator workload families the industry and the academic allocator
# literature rely on:
#
#   small: short-lived small objects (16-512 B) recycled through a
#          per-thread slot ring — the thread-cache (tcache) fast path
#          that dominates general-purpose application traffic.
#
#   mixed:  a large object arena with log-uniform sizes from 16 B to
#          256 KiB and random replacement — arena grow/shrink,
#          size-class coverage and fragmentation handling.
#
# Scenarios are the two workloads crossed with the mysql-style thread
# ladder (1/4/16/64).  Every operation (free victim + malloc + touch)
# is timed with clock_gettime(CLOCK_MONOTONIC), so latencies are in
# nanoseconds on every architecture.  Each run reports operation
# throughput and sampled per-operation latency percentiles.
#
# The four framework stages map to: fetch+verify the tarball, build the
# library and the harness (build), smoke-run the harness end to end
# (start), run the full scenario matrix (test), and drop the benchmark
# data (stop).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="jemalloc"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-5.3.1}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

# Official GitHub releases (the official jemalloc distribution).
JEMALLOC_RELEASE_BASE="${JEMALLOC_RELEASE_BASE:-https://github.com/jemalloc/jemalloc/releases/download}"
JEMALLOC_OFFLINE_DIR="${JEMALLOC_OFFLINE_DIR:-/home/runner/software/jemalloc}"

# Benchmark matrix: workloads crossed with the thread ladder.
JEMALLOC_WORKLOADS=("small" "mixed")
JEMALLOC_THREADS_LADDER=(1 4 16 64)
JEMALLOC_WARMUP_SECONDS="${JEMALLOC_WARMUP_SECONDS:-5}"
JEMALLOC_DURATION_SECONDS="${JEMALLOC_DURATION_SECONDS:-30}"
JEMALLOC_BUILD_JOBS="${JEMALLOC_BUILD_JOBS:-$(nproc)}"

# Lifecycle paths (assigned in configure_runtime_paths).
SOURCE_DIR=""
BUILD_DIR=""
INSTALL_DIR=""
BENCHMARK_BIN=""
BENCHMARK_DIR=""
RUNS_DIR=""

log() {
    printf '[jemalloc] %s\n' "$*"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/jemalloc/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/jemalloc-${SOFTWARE_VERSION}"
    BUILD_DIR="${PERF_WORK_DIR}/build"
    INSTALL_DIR="${PERF_WORK_DIR}/install"
    BENCHMARK_BIN="${PERF_WORK_DIR}/jemalloc_benchmark"
    BENCHMARK_DIR="${PERF_WORK_DIR}/benchmark"
    RUNS_DIR="${BENCHMARK_DIR}/runs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}"
}

require_jemalloc_tools() {
    local command_name package
    local packages=()

    for command_name in curl sha256sum tar bzip2 gcc make grep sed tee python3 sudo; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            curl) package="curl" ;;
            sha256sum|tee) package="coreutils" ;;
            tar) package="tar" ;;
            bzip2) package="bzip2" ;;
            gcc) package="gcc" ;;
            make) package="make" ;;
            grep) package="grep" ;;
            sed) package="sed" ;;
            python3) package="python3" ;;
            sudo) package="sudo" ;;
        esac
        log "missing required jemalloc test command: ${command_name}"
        packages+=("${package}")
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log "ERROR: dnf is required to install jemalloc test prerequisites"
        return 30
    fi

    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log "installing missing jemalloc test packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log "ERROR: sudo is required to install jemalloc test prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log "ERROR: failed to install jemalloc test prerequisites"
        return 30
    fi

    for command_name in curl sha256sum tar bzip2 gcc make grep sed tee python3; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "ERROR: required jemalloc test command remains unavailable: ${command_name}"
            return 30
        fi
    done
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
# (downloaded from the official GitHub release URL and verified
# locally).  Adding a version means adding its entry here.
jemalloc_tarball_sha256() {
    case "${SOFTWARE_VERSION}" in
        5.3.1)
            printf '%s\n' "3826bc80232f22ed5c4662f3034f799ca316e819103bdc7bb99018a421706f92" ;;
        *)
            log "ERROR: no verified jemalloc release is declared for ${SOFTWARE_VERSION}"
            return 10
            ;;
    esac
}

fetch_jemalloc_source() {
    local archive_name="jemalloc-${SOFTWARE_VERSION}.tar.bz2"
    local archive_path="${PERF_WORK_DIR}/${archive_name}"
    local expected_sha256

    if [[ -s "${SOURCE_DIR}/configure" ]]; then
        log "using cached source tree ${SOURCE_DIR}"
        return 0
    fi
    expected_sha256="$(jemalloc_tarball_sha256)" || return $?
    if [[ ! -s "${archive_path}" ]]; then
        if [[ -f "${JEMALLOC_OFFLINE_DIR}/${archive_name}" ]]; then
            log "using local jemalloc source ${JEMALLOC_OFFLINE_DIR}/${archive_name}" >&2
            cp "${JEMALLOC_OFFLINE_DIR}/${archive_name}" "${archive_path}" || return 30
        else
            download_archive "${archive_path}" \
                "${JEMALLOC_RELEASE_BASE}/${SOFTWARE_VERSION}/${archive_name}" || return 30
        fi
    fi
    verify_sha256 "${archive_path}" "${expected_sha256}" || return 30
    tar -xjf "${archive_path}" -C "${PERF_WORK_DIR}" || return 30
    if [[ ! -f "${SOURCE_DIR}/configure" ]]; then
        log "ERROR: the extracted source tree has no configure script"
        return 30
    fi
    log "official jemalloc ${SOFTWARE_VERSION} source tree is ready"
}

build_jemalloc_library() {
    if [[ ! -f "${INSTALL_DIR}/lib/libjemalloc.a" ]]; then
        log "configuring and building jemalloc (out-of-tree, prefix isolated)"
        mkdir -p "${BUILD_DIR}"
        (cd "${BUILD_DIR}" && "${SOURCE_DIR}/configure" \
            --prefix="${INSTALL_DIR}" \
            --srcdir="${SOURCE_DIR}") > "${PERF_WORK_DIR}/configure.log" 2>&1 || {
            log "ERROR: configure failed (see ${PERF_WORK_DIR}/configure.log)"
            return 40
        }
        make -C "${BUILD_DIR}" -j"${JEMALLOC_BUILD_JOBS}" \
            > "${PERF_WORK_DIR}/build.log" 2>&1 || {
            log "ERROR: make failed (see ${PERF_WORK_DIR}/build.log)"
            return 40
        }
        make -C "${BUILD_DIR}" install_bin install_lib install_include \
            > "${PERF_WORK_DIR}/install.log" 2>&1 || {
            log "ERROR: install failed (see ${PERF_WORK_DIR}/install.log)"
            return 40
        }
    fi
    if [[ ! -f "${INSTALL_DIR}/lib/libjemalloc.a" ]]; then
        log "ERROR: the built jemalloc library is missing"
        return 40
    fi
    log "jemalloc library is staged under ${INSTALL_DIR}"
}

compile_benchmark() {
    local source="${SCRIPT_DIR}/src/jemalloc_benchmark.c"

    if [[ ! -f "${source}" ]]; then
        log "ERROR: the benchmark source is missing: ${source}"
        return 40
    fi
    if ! gcc -O2 -Wall -Wextra \
            -I "${INSTALL_DIR}/include" \
            -o "${BENCHMARK_BIN}" \
            "${source}" \
            "${INSTALL_DIR}/lib/libjemalloc.a" \
            -lpthread -lm; then
        log "ERROR: failed to compile the allocation benchmark harness"
        return 40
    fi
    if [[ ! -x "${BENCHMARK_BIN}" ]]; then
        log "ERROR: the compiled benchmark binary is missing"
        return 40
    fi
}

build_jemalloc() {
    local actual_version
    local runner_architecture

    initialize_runtime || return $?
    runner_architecture="$(uname -m)"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    require_jemalloc_tools || return $?
    if [[ -e "${BENCHMARK_BIN}" ]]; then
        log "ERROR: build output is not clean under ${BENCHMARK_BIN}"
        return 20
    fi

    fetch_jemalloc_source || return $?
    build_jemalloc_library || return $?
    compile_benchmark || return $?

    # mallctl("version") reports "<release>-<rev>-<hash>"; the release
    # prefix must match the requested version exactly.
    actual_version="$("${BENCHMARK_BIN}" --version | sed -nE 's/^jemalloc-version=//p' | head -n 1)"
    if [[ -z "${actual_version}" || "${actual_version%%-*}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: staged jemalloc is ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "jemalloc ${actual_version} staged with the compiled allocation benchmark harness"
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

start_jemalloc_runtime() {
    initialize_runtime || return $?
    if [[ ! -x "${BENCHMARK_BIN}" ]]; then
        log "ERROR: the benchmark harness is not built (run build first)"
        return 40
    fi
    if [[ -e "${BENCHMARK_DIR}" ]]; then
        log "ERROR: benchmark directory is not clean: ${BENCHMARK_DIR}"
        return 20
    fi

    # Smoke-run both workloads once so the test stage only ever times a
    # verified harness.
    mkdir -p "${BENCHMARK_DIR}"
    local workload
    for workload in "${JEMALLOC_WORKLOADS[@]}"; do
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
    log "jemalloc benchmark runtime is ready"
}

run_jemalloc_benchmarks() {
    local raw_output
    local workload threads run_file

    initialize_runtime || return $?
    require_jemalloc_tools || return $?
    if [[ ! -x "${BENCHMARK_BIN}" ]]; then
        log "ERROR: the benchmark harness is not built (run build first)"
        return 50
    fi

    raw_output="${RESULTS_DIR}/jemalloc_alloc_raw.log"
    mkdir -p "${BENCHMARK_DIR}"
    rm -rf "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"
    log "running the allocation scenario matrix (warmup=${JEMALLOC_WARMUP_SECONDS}s, duration=${JEMALLOC_DURATION_SECONDS}s)"

    if ! (
        for workload in "${JEMALLOC_WORKLOADS[@]}"; do
            for threads in "${JEMALLOC_THREADS_LADDER[@]}"; do
                run_file="${RUNS_DIR}/${workload}-t${threads}.json"
                "${BENCHMARK_BIN}" \
                    --workload "${workload}" \
                    --threads "${threads}" \
                    --warmup-seconds "${JEMALLOC_WARMUP_SECONDS}" \
                    --duration-seconds "${JEMALLOC_DURATION_SECONDS}" \
                    --scenario "${workload}" \
                    --output "${run_file}" || exit 50
                validate_run_report "${run_file}" || exit 50
            done
        done
    ) 2>&1 | tee "${raw_output}"; then
        log "ERROR: the allocation benchmark matrix failed (see ${raw_output})"
        return 50
    fi

    python3 "${SCRIPT_DIR}/scripts/collect_jemalloc_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" || return 50
    log "allocation benchmark matrix completed"
}

stop_jemalloc_runtime() {
    initialize_runtime || return $?
    log "jemalloc benchmark has no background service to stop"
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
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/jemalloc/local-* || \
          "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/jemalloc" ]]; then
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
        stop_jemalloc_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_jemalloc_standalone() {
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
        if build_jemalloc; then
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
        if start_jemalloc_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_jemalloc_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_jemalloc_runtime; then
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

Build the official jemalloc ${SOFTWARE_VERSION} source tarball inside an
isolated work directory, compile the allocation benchmark harness against
it, and run the workload x thread-count matrix as a standalone performance
evaluation. Results default to results/<version>/<run-id>/ inside this
directory.

Options:
  --version VERSION       jemalloc version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR,
  JEMALLOC_BUILD_JOBS, JEMALLOC_WARMUP_SECONDS, JEMALLOC_DURATION_SECONDS
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
    run_jemalloc_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
