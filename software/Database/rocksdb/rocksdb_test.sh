#!/usr/bin/env bash
# RocksDB performance case (official source build).
#
# The software under test is cloned from the official facebook/rocksdb
# repository at a release tag and built with CMake, so the exact release under
# evaluation can be pinned.  The `db_bench` tool produced by that build is the
# performance driver: it runs LSM-tree KV workloads (fillseq, readrandom,
# overwrite, readwhilewriting) plus auxiliary micro benchmarks (thread scaling,
# compression type sweep, value size sweep) without a persistent server.
#
# The four framework stages map to: clone + build db_bench (build), prepare the
# throwaway data directory (start), run the KV and micro benchmarks and
# aggregate their metrics (test), and remove the throwaway data (stop).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="rocksdb"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-11.8.1}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

# Official upstream repository and db_bench workload parameters.
ROCKSDB_REPOSITORY="${ROCKSDB_REPOSITORY:-https://github.com/facebook/rocksdb.git}"
DATA_NUM="${DATA_NUM:-1000000}"
KEY_SIZE="${KEY_SIZE:-16}"
VALUE_SIZE="${VALUE_SIZE:-1024}"
ITERATIONS="${ITERATIONS:-1}"

# Lifecycle paths (assigned in configure_runtime_paths).
SRC_DIR=""
BUILD_DIR=""
DB_BENCH_BIN=""
BENCH_TMPDIR=""

log() {
    printf '[rocksdb] %s\n' "$*"
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
        PERF_WORK_DIR="/tmp/rocksdb-perf/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SRC_DIR="${PERF_WORK_DIR}/rocksdb-src"
    BUILD_DIR="${PERF_WORK_DIR}/rocksdb-build"
    DB_BENCH_BIN="${BUILD_DIR}/db_bench"
    BENCH_TMPDIR="${PERF_WORK_DIR}/bench-data"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${BENCH_TMPDIR}"
}

require_rocksdb_tools() {
    local command_name package
    local packages=()

    for command_name in git cmake make g++ gcc python3 sed grep nproc; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            git) package="git" ;;
            cmake) package="cmake" ;;
            make) package="make" ;;
            g++) package="gcc-c++" ;;
            gcc) package="gcc" ;;
            python3) package="python3" ;;
            sed) package="sed" ;;
            grep) package="grep" ;;
            nproc) package="coreutils" ;;
        esac
        log "missing required RocksDB build command: ${command_name}"
        packages+=("${package}")
    done

    for package in gflags-devel snappy-devel zstd-devel zlib-devel libatomic; do
        if ! rpm -q "${package}" >/dev/null 2>&1; then
            log "missing required RocksDB build package: ${package}"
            packages+=("${package}")
        fi
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log "ERROR: dnf is required to install RocksDB build prerequisites"
        return 30
    fi

    log "installing missing RocksDB build packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log "ERROR: sudo is required to install RocksDB build prerequisites"
        return 30
    elif ! sudo -n dnf install -y "${packages[@]}"; then
        log "ERROR: failed to install RocksDB build prerequisites"
        return 30
    fi

    for command_name in git cmake make g++ gcc python3 sed grep nproc; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "ERROR: required RocksDB build command remains unavailable: ${command_name}"
            return 30
        fi
    done
    for package in gflags-devel snappy-devel zstd-devel zlib-devel libatomic; do
        if ! rpm -q "${package}" >/dev/null 2>&1; then
            log "ERROR: required RocksDB build package remains unavailable: ${package}"
            return 30
        fi
    done
}

build_rocksdb() {
    local ver_tag
    local version_header
    local major minor patch actual_version
    local runner_architecture

    initialize_runtime || return $?
    runner_architecture="$(uname -m)"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    require_rocksdb_tools || return $?

    if [[ -x "${DB_BENCH_BIN}" ]]; then
        log "ERROR: build output is not clean under ${PERF_WORK_DIR}"
        return 20
    fi

    ver_tag="${SOFTWARE_VERSION}"
    [[ "${ver_tag:0:1}" == "v" ]] || ver_tag="v${ver_tag}"

    log "cloning RocksDB tag ${ver_tag} from ${ROCKSDB_REPOSITORY}"
    rm -rf "${SRC_DIR}" "${BUILD_DIR}"
    if ! git clone --branch "${ver_tag}" --depth 1 "${ROCKSDB_REPOSITORY}" "${SRC_DIR}"; then
        log "ERROR: failed to clone RocksDB tag ${ver_tag}"
        return 40
    fi

    log "configuring RocksDB with CMake"
    mkdir -p "${BUILD_DIR}"
    if ! (
        cd "${BUILD_DIR}"
        cmake -DCMAKE_BUILD_TYPE=Release \
            -DFAIL_ON_WARNINGS=OFF \
            -DWITH_SNAPPY=ON \
            -DWITH_ZSTD=ON \
            -DWITH_ZLIB=ON \
            "${SRC_DIR}"
    ); then
        log "ERROR: cmake configuration failed"
        return 40
    fi

    log "building db_bench"
    if ! ( cd "${BUILD_DIR}" && make -j"$(nproc)" db_bench ); then
        log "ERROR: make db_bench failed"
        return 40
    fi

    if [[ ! -x "${DB_BENCH_BIN}" ]]; then
        DB_BENCH_BIN="$(find "${BUILD_DIR}" -name db_bench -type f -executable 2>/dev/null | head -n 1)"
    fi
    if [[ -z "${DB_BENCH_BIN}" || ! -x "${DB_BENCH_BIN}" ]]; then
        log "ERROR: db_bench not found after build"
        return 40
    fi

    version_header="${SRC_DIR}/include/rocksdb/version.h"
    major="$(sed -nE 's/^#define[[:space:]]+ROCKSDB_MAJOR[[:space:]]+([0-9]+).*/\1/p' "${version_header}")"
    minor="$(sed -nE 's/^#define[[:space:]]+ROCKSDB_MINOR[[:space:]]+([0-9]+).*/\1/p' "${version_header}")"
    patch="$(sed -nE 's/^#define[[:space:]]+ROCKSDB_PATCH[[:space:]]+([0-9]+).*/\1/p' "${version_header}")"
    actual_version="${major}.${minor}.${patch}"
    if [[ ! "${actual_version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log "ERROR: cannot determine RocksDB version from ${version_header}"
        return 40
    fi
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: built RocksDB is ${actual_version}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "RocksDB ${actual_version} built (db_bench at ${DB_BENCH_BIN})"
}

start_rocksdb_service() {
    initialize_runtime || return $?
    if [[ ! -x "${DB_BENCH_BIN}" ]]; then
        log "ERROR: db_bench is not built (run build first)"
        return 40
    fi
    mkdir -p "${BENCH_TMPDIR}"
    log "benchmark environment ready (${BENCH_TMPDIR})"
}

run_rocksdb_benchmarks() {
    initialize_runtime || return $?
    if [[ ! -x "${DB_BENCH_BIN}" ]]; then
        log "ERROR: db_bench is not built (run build first)"
        return 50
    fi

    log "running KV operations benchmark"
    python3 "${SCRIPT_DIR}/scripts/benchmark_kv.py" \
        "${DB_BENCH_BIN}" "${RESULTS_DIR}/benchmark_kv.json" \
        "${DATA_NUM}" "${KEY_SIZE}" "${VALUE_SIZE}" "${ITERATIONS}" || return 50

    log "running micro benchmark"
    python3 "${SCRIPT_DIR}/scripts/micro_benchmark.py" \
        "${DB_BENCH_BIN}" "${RESULTS_DIR}/micro_benchmark.json" \
        "${DATA_NUM}" "${KEY_SIZE}" "${VALUE_SIZE}" "${ITERATIONS}" || return 50

    log "aggregating results"
    python3 "${SCRIPT_DIR}/scripts/aggregate_results.py" \
        "${RESULTS_DIR}" "${RESULTS_DIR}/results.json" || return 50

    log "RocksDB benchmarks completed"
}

stop_rocksdb_service() {
    initialize_runtime || return $?
    if [[ -d "${BENCH_TMPDIR}" ]]; then
        rm -rf "${BENCH_TMPDIR}"
        log "removed benchmark data directory: ${BENCH_TMPDIR}"
    else
        log "no benchmark data directory; nothing to stop"
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
    if [[ "${PERF_WORK_DIR}" != /tmp/rocksdb-perf/local-* || \
          "${PERF_WORK_DIR}" == "/tmp/rocksdb-perf" ]]; then
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
        stop_rocksdb_service
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_rocksdb_standalone() {
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
        if build_rocksdb; then
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
        if start_rocksdb_service; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_rocksdb_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_rocksdb_service; then
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

Build RocksDB from the official source release and run db_bench KV and micro
benchmarks as a standalone performance evaluation.
Results default to results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       RocksDB version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR, ROCKSDB_REPOSITORY,
  DATA_NUM, KEY_SIZE, VALUE_SIZE, ITERATIONS
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
    mkdir -p "${RESULTS_DIR}" || return $?
    : > "${RESULTS_DIR}/results.log"
    local pipeline_status=0
    set +e
    run_rocksdb_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi