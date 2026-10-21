#!/usr/bin/env bash
set -euo pipefail

if [[ "${FAISS_COMMON_LOADED:-0}" == 1 ]]; then
    return 0
fi
FAISS_COMMON_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.14.3}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
FAISS_SOURCE_URL="${FAISS_SOURCE_URL:-https://github.com/facebookresearch/faiss.git}"
FAISS_BENCH_PROFILE="${FAISS_BENCH_PROFILE:-hnsw}"
readonly SRA_SOURCE_URL="https://atomgit.com/liuliuyiyidingding/sra_test.git"
readonly SRA_REVISION="9a941bc3fb72c1e0d8dc48e6deb7df33e3e23abf"
readonly DATA_DIRECTORY="/home/runner/software/faiss/data"
readonly MKL_INSTALLER_NAME="intel-onemkl-2026.1.0.237_offline.sh"
readonly MKL_INSTALLER_URL="https://registrationcenter-download.intel.com/akdlm/IRC_NAS/17f37e16-768e-40d2-bcf8-c252dc6c5499/${MKL_INSTALLER_NAME}"
readonly MKL_OFFLINE_DIRECTORY="/home/runner/software/faiss"
readonly ALL_ALGORITHMS=(hnsw ivfpq ivfpqfs pqfs ivfflat ivfrabitq ivfrabitqfs)

SOURCE_DIR=""
BUILD_DIR=""
SRA_DIR=""
MKL_LIBRARY_DIR=""
OPENBLAS_CFLAGS=""
OPENBLAS_LIBS=""
ACTIVE_ALGORITHMS=()
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"


log_message() {
    printf '[faiss] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
}


validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

configure_benchmark_profile() {
    case "${FAISS_BENCH_PROFILE}" in
        hnsw) ACTIVE_ALGORITHMS=(hnsw) ;;
        all) ACTIVE_ALGORITHMS=("${ALL_ALGORITHMS[@]}") ;;
        *)
            log_message "ERROR: unsupported Faiss benchmark profile: ${FAISS_BENCH_PROFILE} (expected hnsw or all)"
            return 10
            ;;
    esac
}


normalize_architecture() {
    local architecture
    architecture="${1,,}"
    case "${architecture}" in
        x86_64|amd64)
            printf 'x86_64\n'
            ;;
        aarch64|arm64)
            printf 'aarch64\n'
            ;;
        *)
            printf '%s\n' "${architecture}"
            ;;
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/faiss/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi

    SOURCE_DIR="${PERF_WORK_DIR}/faiss-source"
    BUILD_DIR="${PERF_WORK_DIR}/faiss-build"
    SRA_DIR="${PERF_WORK_DIR}/sra-test"

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
}


initialize_runtime() {
    if configure_runtime_paths; then
        :
    else
        return $?
    fi
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" \
        "${TMPDIR}"
}
