#!/usr/bin/env bash
# Build RocksDB and run its db_bench tool in a task-private data directory.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-11.8.1}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
ROCKSDB_REPOSITORY="${ROCKSDB_REPOSITORY:-https://github.com/facebook/rocksdb.git}"
ROCKSDB_DATA_ROOT="${ROCKSDB_DATA_ROOT:-/home/runner/rocksdb-data}"
ROCKSDB_BENCH_PROFILES="${ROCKSDB_BENCH_PROFILES:-64:128,64:512,128:1024}"
ROCKSDB_BENCH_NUM="${ROCKSDB_BENCH_NUM:-10000000}"
ROCKSDB_BENCH_DURATION_SECONDS="${ROCKSDB_BENCH_DURATION_SECONDS:-60}"
ROCKSDB_BENCH_READWRITE_PERCENT="${ROCKSDB_BENCH_READWRITE_PERCENT:-70}"
ROCKSDB_BENCH_CACHE_SIZE_BYTES="${ROCKSDB_BENCH_CACHE_SIZE_BYTES:-1073741824}"

STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
SOURCE_DIR=""
BUILD_DIR=""
DB_BENCH_BIN=""
BENCH_DATA_DIR=""

log() {
    printf '[rocksdb] %s\n' "$*"
}

initialize_runtime() {
    local runner_architecture

    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64) EXPECTED_ARCH="x86_64" ;;
        aarch64|arm64) EXPECTED_ARCH="aarch64" ;;
        *) EXPECTED_ARCH="${EXPECTED_ARCH,,}" ;;
    esac
    runner_architecture="$(uname -m)"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
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
    SOURCE_DIR="${PERF_WORK_DIR}/rocksdb-source"
    BUILD_DIR="${PERF_WORK_DIR}/rocksdb-build"
    DB_BENCH_BIN="${BUILD_DIR}/db_bench"
    BENCH_DATA_DIR="${ROCKSDB_DATA_ROOT}/${SOFTWARE_VERSION}/${EXPECTED_ARCH}/${PERF_RUN_ID}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE ROCKSDB_BENCH_DATA_DIR="${BENCH_DATA_DIR}"
    export ROCKSDB_BENCH_PROFILES ROCKSDB_BENCH_NUM
    export ROCKSDB_BENCH_DURATION_SECONDS ROCKSDB_BENCH_READWRITE_PERCENT
    export ROCKSDB_BENCH_CACHE_SIZE_BYTES
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}"
}

install_rocksdb_dependencies() {
    local command_name package
    local packages=()

    for command_name in git cmake gcc g++ make nproc python3 sed; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            git) package="git" ;;
            cmake) package="cmake" ;;
            gcc) package="gcc" ;;
            g++) package="gcc-c++" ;;
            make) package="make" ;;
            nproc) package="coreutils" ;;
            python3) package="python3" ;;
            sed) package="sed" ;;
        esac
        packages+=("${package}")
    done
    for package in gflags-devel snappy-devel zlib-devel bzip2-devel lz4-devel zstd-devel libatomic; do
        if ! rpm -q "${package}" >/dev/null 2>&1; then
            packages+=("${package}")
        fi
    done
    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    log "installing missing RocksDB dependencies: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf install -y "${packages[@]}" || return 30
    elif command -v sudo >/dev/null 2>&1 && sudo -n dnf install -y "${packages[@]}"; then
        :
    else
        log "ERROR: cannot install required RocksDB dependencies"
        return 30
    fi
}

build_rocksdb() {
    local source_tag actual_version major minor patch

    initialize_runtime || return $?
    install_rocksdb_dependencies || return $?
    source_tag="v${SOFTWARE_VERSION#v}"
    rm -rf "${SOURCE_DIR}" "${BUILD_DIR}"
    log "cloning RocksDB ${source_tag} from ${ROCKSDB_REPOSITORY}"
    if ! git clone --branch "${source_tag}" --depth 1 "${ROCKSDB_REPOSITORY}" "${SOURCE_DIR}"; then
        log "ERROR: failed to clone RocksDB ${source_tag}"
        return 40
    fi
    log "building official db_bench target"
    if ! cmake -S "${SOURCE_DIR}" -B "${BUILD_DIR}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DFAIL_ON_WARNINGS=OFF; then
        log "ERROR: CMake configuration failed"
        return 40
    fi
    if ! cmake --build "${BUILD_DIR}" --target db_bench --parallel "$(nproc)"; then
        log "ERROR: db_bench build failed"
        return 40
    fi
    if [[ ! -x "${DB_BENCH_BIN}" ]]; then
        DB_BENCH_BIN="$(find "${BUILD_DIR}" -type f -name db_bench -executable -print -quit)"
    fi
    if [[ -z "${DB_BENCH_BIN}" || ! -x "${DB_BENCH_BIN}" ]]; then
        log "ERROR: db_bench was not created"
        return 40
    fi
    major="$(sed -nE 's/^#define[[:space:]]+ROCKSDB_MAJOR[[:space:]]+([0-9]+).*/\1/p' "${SOURCE_DIR}/include/rocksdb/version.h")"
    minor="$(sed -nE 's/^#define[[:space:]]+ROCKSDB_MINOR[[:space:]]+([0-9]+).*/\1/p' "${SOURCE_DIR}/include/rocksdb/version.h")"
    patch="$(sed -nE 's/^#define[[:space:]]+ROCKSDB_PATCH[[:space:]]+([0-9]+).*/\1/p' "${SOURCE_DIR}/include/rocksdb/version.h")"
    actual_version="${major}.${minor}.${patch}"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION#v}" ]]; then
        log "ERROR: built RocksDB is ${actual_version}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
}

prepare_rocksdb_benchmark_data() {
    initialize_runtime || return $?
    if [[ ! -x "${DB_BENCH_BIN}" ]]; then
        log "ERROR: db_bench is not built"
        return 40
    fi
    if [[ -e "${BENCH_DATA_DIR}" ]]; then
        log "ERROR: benchmark data directory already exists: ${BENCH_DATA_DIR}"
        return 20
    fi
    mkdir -p "${BENCH_DATA_DIR}"
    log "prepared task-private benchmark data directory: ${BENCH_DATA_DIR}"
}

run_rocksdb_benchmarks() {
    initialize_runtime || return $?
    if [[ ! -x "${DB_BENCH_BIN}" || ! -d "${BENCH_DATA_DIR}" ]]; then
        log "ERROR: build or benchmark data preparation is incomplete"
        return 50
    fi
    python3 "${SCRIPT_DIR}/scripts/run_db_bench.py" \
        "${DB_BENCH_BIN}" "${RESULTS_DIR}/results.json" \
        "${RESULTS_DIR}/db_bench_raw.log" || return 50
}

cleanup_rocksdb_benchmark_data() {
    initialize_runtime || return $?
    if [[ ! -e "${BENCH_DATA_DIR}" ]]; then
        log "benchmark data directory is already absent"
        return 0
    fi
    if [[ "${BENCH_DATA_DIR}" != "${ROCKSDB_DATA_ROOT}/${SOFTWARE_VERSION}/${EXPECTED_ARCH}/${PERF_RUN_ID}" ]]; then
        log "ERROR: refusing to remove unexpected data directory: ${BENCH_DATA_DIR}"
        return 70
    fi
    rm -rf -- "${BENCH_DATA_DIR}"
    log "removed task-private benchmark data directory: ${BENCH_DATA_DIR}"
}

cleanup_standalone_work_directory() {
    if [[ "${STANDALONE_OWNS_WORK_DIR}" -ne 1 || "${STANDALONE_KEEP_WORK_DIR}" -eq 1 ]]; then
        return 0
    fi
    if [[ "${PERF_WORK_DIR}" != /tmp/rocksdb-perf/local-* ]]; then
        log "ERROR: refusing to remove unexpected standalone work directory: ${PERF_WORK_DIR}"
        return 70
    fi
    rm -rf -- "${PERF_WORK_DIR}"
    log "removed standalone build directory: ${PERF_WORK_DIR}"
}

standalone_runtime() {
    python3 "${SCRIPT_DIR}/scripts/standalone_runtime.py" "$@"
}

run_rocksdb_standalone() {
    local status=0 cleanup_status="passed" failed_stage=""

    initialize_runtime || return $?
    trap 'cleanup_rocksdb_benchmark_data >/dev/null 2>&1 || true; cleanup_standalone_work_directory >/dev/null 2>&1 || true' EXIT
    standalone_runtime system "${RESULTS_DIR}/system_info.json" || { status=$?; failed_stage="prepare"; }
    if [[ "${status}" -eq 0 ]]; then
        standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json" || { status=$?; failed_stage="prepare"; }
    fi
    if [[ "${status}" -eq 0 ]]; then
        build_rocksdb || { status=$?; failed_stage="build"; }
    fi
    if [[ "${status}" -eq 0 ]]; then
        standalone_runtime build-info "${RESULTS_DIR}/build_info.json" "${SOFTWARE_VERSION}" \
            "${PERF_ACTUAL_VERSION_FILE}" "${EXPECTED_ARCH}" "${PERF_RUN_ID}" || { status=$?; failed_stage="build"; }
    fi
    if [[ "${status}" -eq 0 ]]; then
        prepare_rocksdb_benchmark_data || { status=$?; failed_stage="start"; }
    fi
    if [[ "${status}" -eq 0 ]]; then
        run_rocksdb_benchmarks || { status=$?; failed_stage="test"; }
    fi
    cleanup_rocksdb_benchmark_data || cleanup_status="failed"
    standalone_runtime runtime "${RESULTS_DIR}/runtime_after.json" || cleanup_status="failed"
    if [[ "${status}" -eq 0 ]]; then
        standalone_runtime finalize "${RESULTS_DIR}" "${SOFTWARE_VERSION}" "${EXPECTED_ARCH}" \
            "${PERF_RUN_ID}" passed "${cleanup_status}" "" || status=$?
    else
        standalone_runtime finalize "${RESULTS_DIR}" "${SOFTWARE_VERSION}" "${EXPECTED_ARCH}" \
            "${PERF_RUN_ID}" failed "${cleanup_status}" "${failed_stage}" || true
    fi
    cleanup_standalone_work_directory || status=$?
    trap - EXIT
    return "${status}"
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version) SOFTWARE_VERSION="$2"; shift 2 ;;
            --results-dir) RESULTS_DIR="$2"; shift 2 ;;
            --keep-workdir) STANDALONE_KEEP_WORK_DIR=1; shift ;;
            -h|--help)
                printf 'Usage: %s [--version VERSION] [--results-dir DIRECTORY] [--keep-workdir]\n' "$(basename "$0")"
                return 0
                ;;
            *) log "ERROR: unsupported option: $1"; return 10 ;;
        esac
    done
    run_rocksdb_standalone
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
