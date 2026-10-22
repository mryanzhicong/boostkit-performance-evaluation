#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-7.0.15}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
REDIS_DATA_ROOT="${REDIS_DATA_ROOT:-}"
REDIS_SOURCE_URL="${REDIS_SOURCE_URL:-https://github.com/redis/redis.git}"
REDIS_SERVICE_PORT="${REDIS_SERVICE_PORT:-}"

SOURCE_DIR=""
REDIS_SERVER_BIN=""
REDIS_BENCHMARK_BIN=""
REDIS_CLI_BIN=""
SERVICE_DIR=""
PID_FILE=""
LOG_FILE=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[redis] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    local checksum runner_architecture

    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
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
            log_message "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/redis/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    if [[ -z "${REDIS_DATA_ROOT}" ]]; then
        REDIS_DATA_ROOT="${PERF_WORK_DIR}/data"
    fi
    if [[ -z "${REDIS_SERVICE_PORT}" ]]; then
        checksum="$(printf '%s' "${PERF_RUN_ID}" | cksum)"
        REDIS_SERVICE_PORT="$((20000 + ${checksum%% *} % 20000))"
    fi
    if [[ ! "${REDIS_SERVICE_PORT}" =~ ^[0-9]+$ ]] || \
       (( REDIS_SERVICE_PORT < 1024 || REDIS_SERVICE_PORT > 65535 )); then
        log_message "ERROR: REDIS_SERVICE_PORT must be an unprivileged TCP port: ${REDIS_SERVICE_PORT}"
        return 10
    fi

    SOURCE_DIR="${PERF_WORK_DIR}/redis-source"
    REDIS_SERVER_BIN="${SOURCE_DIR}/src/redis-server"
    REDIS_BENCHMARK_BIN="${SOURCE_DIR}/src/redis-benchmark"
    REDIS_CLI_BIN="${SOURCE_DIR}/src/redis-cli"
    SERVICE_DIR="${REDIS_DATA_ROOT}"
    PID_FILE="${SERVICE_DIR}/redis.pid"
    LOG_FILE="${SERVICE_DIR}/redis.log"

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE REDIS_SERVICE_PORT REDIS_DATA_ROOT
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}
