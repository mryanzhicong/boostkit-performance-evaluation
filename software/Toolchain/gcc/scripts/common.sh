#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-14.4.0}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
GCC_SOURCE_BASE="${GCC_SOURCE_BASE:-https://gcc.gnu.org/pub/gcc/releases}"
GCC_OFFLINE_DIR="${GCC_OFFLINE_DIR:-/home/runner/software/gcc}"
GCC_BENCHMARK_DATA_ROOT="${GCC_BENCHMARK_DATA_ROOT:-}"
SPEC_CPU2017_ISO="${SPEC_CPU2017_ISO:-/home/runner/software/gcc/cpu2017-1.0.5.iso}"
SPEC_COPIES=384

SRC_DIR=""
BUILD_DIR=""
INSTALL_DIR=""
GCC_BIN=""
GXX_BIN=""
GFORTRAN_BIN=""
GCC_VERSION_STRING=""
GCC_SOURCE_SHA256=""
SPEC_CONFIG_NAME=""
BENCHMARK_DATA_DIR=""
SPEC_MOUNT_DIR=""
SPEC_DIR=""
SPEC_OUTPUT_ROOT=""
SPEC_RESULT_DIR=""
SPEC_CONFIG_PATH=""
ASLR_STATE_FILE=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[gcc] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    local runner_architecture
    runner_architecture="$(normalize_architecture "$(uname -m)")"
    case "${runner_architecture}" in
        x86_64|aarch64) ;;
        *)
            log_message "ERROR: unsupported runner architecture: $(uname -m)"
            return 20
            ;;
    esac
    [[ "${runner_architecture}" == "${EXPECTED_ARCH}" ]] || {
        log_message "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    }
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/gcc/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    if [[ -z "${GCC_BENCHMARK_DATA_ROOT}" ]]; then
        GCC_BENCHMARK_DATA_ROOT="${PERF_WORK_DIR}/data"
    fi
    SRC_DIR="${PERF_WORK_DIR}/gcc-src"
    BUILD_DIR="${PERF_WORK_DIR}/gcc-build"
    INSTALL_DIR="${PERF_WORK_DIR}/gcc-install"
    GCC_BIN="${INSTALL_DIR}/bin/gcc"
    GXX_BIN="${INSTALL_DIR}/bin/g++"
    GFORTRAN_BIN="${INSTALL_DIR}/bin/gfortran"
    BENCHMARK_DATA_DIR="${GCC_BENCHMARK_DATA_ROOT%/}/gcc-${PERF_RUN_ID}"
    SPEC_MOUNT_DIR="${BENCHMARK_DATA_DIR}/cpu2017-media"
    SPEC_DIR="${BENCHMARK_DATA_DIR}/cpu2017"
    if [[ "${EXPECTED_ARCH}" == "x86_64" ]]; then
        SPEC_CONFIG_NAME="spec-gcc-x86.cfg"
    else
        SPEC_CONFIG_NAME="spec-gcc-aarch64.cfg"
    fi
    SPEC_CONFIG_PATH="${SPEC_DIR}/config/${SPEC_CONFIG_NAME}"
    ASLR_STATE_FILE="${BENCHMARK_DATA_DIR}/randomize_va_space.before"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}
