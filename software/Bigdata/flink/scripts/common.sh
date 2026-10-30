#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASE_DIR="${SCRIPT_DIR}"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.16.3}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"

FLINK_RELEASE="flink-${SOFTWARE_VERSION}-bin-scala_2.12.tgz"
FLINK_SHA512="12c4333b3589bfe0ba9e2c394c1f71683d932c7733deba12d08dbf9cff6d4fd1cb3a3d08177b2382bccf6287637a224fb7ed0e612502a37efcd4b5520c275082"
NEXMARK_REPOSITORY="https://github.com/nexmark/nexmark.git"
NEXMARK_REVISION="6b3646c3baec701f1fa74baf938d235f742e5d3c"
FLINK_ARCHIVE_DIR="${FLINK_ARCHIVE_DIR:-/home/runner/software/flink}"

log_message() { printf '[flink] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    [[ "${SOFTWARE_VERSION}" == 1.16.3 ]] || { log_message "ERROR: unsupported Flink version: ${SOFTWARE_VERSION}"; return 10; }
    [[ "${EXPECTED_ARCH}" == "$(uname -m)" ]] || { log_message "ERROR: runner architecture differs from ${EXPECTED_ARCH}"; return 20; }
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || { log_message 'ERROR: unsafe run ID'; return 10; }
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/flink/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${CASE_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${CASE_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    TMPDIR="${PERF_WORK_DIR}/tmp"
    FLINK_HOME="${PERF_WORK_DIR}/flink-${SOFTWARE_VERSION}"
    NEXMARK_SOURCE="${PERF_WORK_DIR}/nexmark-source"
    NEXMARK_HOME="${PERF_WORK_DIR}/nexmark"
    FLINK_DATA="${PERF_WORK_DIR}/data"
    FLINK_PID_DIR="${PERF_WORK_DIR}/pids/main"
    FLINK_REST_PORT="$((20000 + $(printf '%s' "${PERF_RUN_ID}" | cksum | cut -d ' ' -f 1) % 20000))"
    FLINK_RPC_PORT="$((FLINK_REST_PORT + 1))"
    NEXMARK_METRIC_PORT="$((FLINK_REST_PORT + 2))"
    export SOFTWARE_VERSION PERF_VARIANT EXPECTED_ARCH PERF_RUN_ID PERF_WORK_DIR RESULTS_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR FLINK_HOME FLINK_PID_DIR NEXMARK_HOME
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}" "${TMPDIR}" \
        "${FLINK_DATA}/tmp" "${FLINK_DATA}/rocksdb" "${FLINK_DATA}/checkpoint"
}

load_java() {
    local java_file="${PERF_WORK_DIR}/java-home.txt"
    [[ -s "${java_file}" ]] || { log_message "ERROR: JDK path is missing: ${java_file}"; return 40; }
    JAVA_HOME="$(< "${java_file}")"
    [[ -x "${JAVA_HOME}/bin/java" ]] || { log_message "ERROR: JDK is missing: ${JAVA_HOME}"; return 40; }
    PATH="${JAVA_HOME}/bin:${PATH}"
    export JAVA_HOME PATH
}

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else
        "$@"
    fi
}
