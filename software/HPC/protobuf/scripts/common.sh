#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-33.0}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
PROTOBUF_SOURCE_URL="${PROTOBUF_SOURCE_URL:-https://github.com/protocolbuffers/protobuf.git}"
BENCHMARK_SOURCE_URL="https://gitcode.com/boostkit/AccLibBenchmark.git"
BENCHMARK_SOURCE_REVISION="01d083c6633babb2fb1307d93f596f10dda36778"
GOOGLE_BENCHMARK_URL="https://github.com/google/benchmark.git"
GOOGLE_BENCHMARK_VERSION="v1.8.3"

SOURCE_DIR=""
BUILD_DIR=""
INSTALL_DIR=""
PROTOC_BIN=""
BENCHMARK_REPO_DIR=""
BENCHMARK_SOURCE_DIR=""
BENCHMARK_BUILD_DIR=""
BENCHMARK_BIN=""
FIXTURE_DUMP_BIN=""
GOOGLE_BENCHMARK_SOURCE_DIR=""
GOOGLE_BENCHMARK_BUILD_DIR=""
GOOGLE_BENCHMARK_INSTALL_DIR=""
CXX_BINARY="${CXX:-g++}"
CXX_VERSION=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[protobuf] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
}

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

normalized_architecture() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/protobuf/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/protobuf-source"
    BUILD_DIR="${PERF_WORK_DIR}/build"
    INSTALL_DIR="${PERF_WORK_DIR}/install"
    PROTOC_BIN="${INSTALL_DIR}/bin/protoc"
    BENCHMARK_REPO_DIR="${PERF_WORK_DIR}/AccLibBenchmark"
    BENCHMARK_SOURCE_DIR="${BENCHMARK_REPO_DIR}/protobuf-benchmark"
    BENCHMARK_BUILD_DIR="${PERF_WORK_DIR}/benchmark-build"
    BENCHMARK_BIN="${BENCHMARK_BUILD_DIR}/bm"
    FIXTURE_DUMP_BIN="${BENCHMARK_BUILD_DIR}/protobuf_fixture_dump"
    GOOGLE_BENCHMARK_SOURCE_DIR="${PERF_WORK_DIR}/google-benchmark-source"
    GOOGLE_BENCHMARK_BUILD_DIR="${PERF_WORK_DIR}/google-benchmark-build"
    GOOGLE_BENCHMARK_INSTALL_DIR="${PERF_WORK_DIR}/google-benchmark-install"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${PERF_WORK_DIR}/tmp"
    export TMPDIR="${PERF_WORK_DIR}/tmp"
}
