#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="rocksdb"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-6.26.1}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
ROCKSDB_REPOSITORY="${ROCKSDB_REPOSITORY:-https://github.com/facebook/rocksdb.git}"
YCSB_REPOSITORY="${YCSB_REPOSITORY:-https://github.com/brianfrankcooper/YCSB.git}"
YCSB_REVISION="19e885f7cb780fdded0547853f7810a150554caf"
ROCKSDB_DATA_ROOT="${ROCKSDB_DATA_ROOT:-}"

STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

# Lifecycle paths (assigned in configure_runtime_paths).
SOURCE_DIR=""
YCSB_SOURCE_DIR=""
YCSB_DIST_DIR=""
MAVEN_REPO_DIR=""
MAVEN_SETTINGS_FILE=""
BENCH_DATA_DIR=""

log_message() {
    printf '[rocksdb] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
}

normalize_architecture() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    local runner_architecture

    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64) EXPECTED_ARCH="x86_64" ;;
        aarch64|arm64) EXPECTED_ARCH="aarch64" ;;
        *) EXPECTED_ARCH="${EXPECTED_ARCH,,}" ;;
    esac
    runner_architecture="$(uname -m)"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log_message "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/rocksdb/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    PERF_WORK_DIR="$(realpath -m -- "${PERF_WORK_DIR}")"
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/rocksdb/* ]]; then
        log_message "ERROR: RocksDB work directory must be task-private under /home/runner/boostkit-perf/rocksdb"
        return 20
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${ROCKSDB_DATA_ROOT}" ]]; then
        ROCKSDB_DATA_ROOT="${PERF_WORK_DIR}/data"
    fi
    ROCKSDB_DATA_ROOT="$(realpath -m -- "${ROCKSDB_DATA_ROOT}")"
    if [[ "${ROCKSDB_DATA_ROOT}" != "${PERF_WORK_DIR}/"* ]]; then
        log_message "ERROR: RocksDB data directory must be inside the task-private work directory"
        return 20
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/rocksdb-source"
    YCSB_SOURCE_DIR="${PERF_WORK_DIR}/ycsb-source"
    YCSB_DIST_DIR="${PERF_WORK_DIR}/ycsb-dist"
    MAVEN_REPO_DIR="${PERF_WORK_DIR}/maven-repository"
    MAVEN_SETTINGS_FILE="${PERF_WORK_DIR}/maven-settings.xml"
    BENCH_DATA_DIR="${ROCKSDB_DATA_ROOT}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE ROCKSDB_BENCH_DATA_DIR="${BENCH_DATA_DIR}" TMPDIR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    if [[ -s "${PERF_WORK_DIR}/java-home.txt" ]]; then
        JAVA_HOME="$(< "${PERF_WORK_DIR}/java-home.txt")"
        if [[ ! -x "${JAVA_HOME}/bin/java" ]]; then
            log_message "ERROR: recorded JDK 11 is unavailable: ${JAVA_HOME}"
            return 30
        fi
        export JAVA_HOME PATH="${JAVA_HOME}/bin:${PATH}"
    fi
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}
