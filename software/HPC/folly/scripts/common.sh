#!/usr/bin/env bash
# Shared variables and helpers for the folly variant-aware stage split.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="folly"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-2022.11.14.00}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
FOLLY_SOURCE_URL="${FOLLY_SOURCE_URL:-https://github.com/facebook/folly.git}"
FAST_FLOAT_SOURCE_URL="${FAST_FLOAT_SOURCE_URL:-https://github.com/fastfloat/fast_float.git}"
FAST_FLOAT_VERSION="v8.2.10"
ACCLIB_SOURCE_ROOT="/home/runner/software/folly/AccLibBenchmark"
COMPILER_BINARY="g++"
COMPILER_VERSION_STRING=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"

# Lifecycle paths (assigned in configure_runtime_paths).
SOURCE_DIR=""
FAST_FLOAT_DIR=""
BENCH_DIR=""
SERVER_BINARY=""
CLIENT_BINARY=""
SERVICE_DIR=""

log_message() { printf '[folly] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

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
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log_message "ERROR: PERF_RUN_ID contains unsafe characters"
        return 10
    }
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/folly/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    [[ -n "${PERF_ACTUAL_VERSION_FILE}" ]] || PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    SOURCE_DIR="${PERF_WORK_DIR}/folly-source"
    FAST_FLOAT_DIR="${PERF_WORK_DIR}/fast_float"
    BENCH_DIR="${PERF_WORK_DIR}/fbthrift_folly_benchmark"
    SERVER_BINARY="${BENCH_DIR}/build/press_server"
    CLIENT_BINARY="${BENCH_DIR}/build/press_client"
    SERVICE_DIR="${PERF_WORK_DIR}/service"
    export TMPDIR="${PERF_WORK_DIR}/tmp"
    local prefix="${PERF_WORK_DIR}/install"
    export LD_LIBRARY_PATH="${prefix}/fbthrift/lib:${prefix}/fbthrift/lib64:${prefix}/wangle/lib:${prefix}/wangle/lib64:${prefix}/fizz/lib:${prefix}/fizz/lib64:${prefix}/folly/lib:${prefix}/folly/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    [[ "$(normalize_architecture "$(uname -m)")" == "$(normalize_architecture "${EXPECTED_ARCH}")" ]] || {
        log_message "ERROR: runner architecture differs from ${EXPECTED_ARCH}"
        return 20
    }
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${SERVICE_DIR}"
}
