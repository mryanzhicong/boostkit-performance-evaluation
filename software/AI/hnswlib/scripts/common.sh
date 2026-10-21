#!/usr/bin/env bash
set -euo pipefail

if [[ "${HNSWLIB_COMMON_LOADED:-0}" == 1 ]]; then
    return 0
fi
HNSWLIB_COMMON_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-0.8.0}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
HNSWLIB_SOURCE_URL="${HNSWLIB_SOURCE_URL:-https://github.com/nmslib/hnswlib.git}"
HNSWLIB_DATA_ROOT="${HNSWLIB_DATA_ROOT:-/home/runner/software/hnswlib/data}"
readonly SRA_SOURCE_URL="https://atomgit.com/liuliuyiyidingding/sra_test.git"
readonly SRA_REVISION="9a941bc3fb72c1e0d8dc48e6deb7df33e3e23abf"

SOURCE_DIR=""
SRA_DIR=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"


log() {
    printf '[hnswlib] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
}


validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    local actual_architecture

    if [[ "${SOFTWARE_VERSION}" != "0.8.0" ]]; then
        log "ERROR: only hnswlib 0.8.0 is supported, requested ${SOFTWARE_VERSION}"
        return 10
    fi
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
        *)
            log "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    case "$(uname -m)" in
        x86_64|amd64) actual_architecture="x86_64" ;;
        aarch64|arm64) actual_architecture="aarch64" ;;
        *) actual_architecture="$(uname -m)" ;;
    esac
    if [[ "${actual_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log "ERROR: expected ${EXPECTED_ARCH}, runner is ${actual_architecture}"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/hnswlib/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    XDG_CACHE_HOME="${PERF_WORK_DIR}/cache"

    SOURCE_DIR="${PERF_WORK_DIR}/hnswlib-source"
    SRA_DIR="${PERF_WORK_DIR}/sra-test"

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR HNSWLIB_DATA_ROOT
    export PERF_ACTUAL_VERSION_FILE TMPDIR XDG_CACHE_HOME
}


initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${XDG_CACHE_HOME}" \
        "${HNSWLIB_DATA_ROOT}" || return $?
}
