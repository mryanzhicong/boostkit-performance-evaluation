#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASE_DIR="${SCRIPT_DIR}"
SOFTWARE_NAME="clang"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-23.1.4}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"

# Official LLVM release endpoint (prebuilt release tarballs).
LLVM_RELEASE_BASE="${LLVM_RELEASE_BASE:-https://github.com/llvm/llvm-project/releases/download}"

# Fixed benchmark workload from the official SQLite release area. SQLite
# publishes SHA3-256 checksums (not SHA-256), verified through python3.
SQLITE_BENCHMARK_BASE="${SQLITE_BENCHMARK_BASE:-https://www.sqlite.org/2026}"
SQLITE_AMALGAMATION_PACKAGE="${SQLITE_AMALGAMATION_PACKAGE:-sqlite-amalgamation-3540100.zip}"
SQLITE_AMALGAMATION_SHA3_256="${SQLITE_AMALGAMATION_SHA3_256:-92281c86e2957f9b9305890f9ac04204caa7b677cc868dc326d942689df28e30}"
SQLITE_SOURCE_PACKAGE="${SQLITE_SOURCE_PACKAGE:-sqlite-src-3540100.zip}"
SQLITE_SOURCE_SHA3_256="${SQLITE_SOURCE_SHA3_256:-877c6f4996ce7adb368686bce21638de9e3d91534832ad3d9d119037d1bc22ad}"
SQLITE_BENCHMARK_VERSION="${SQLITE_BENCHMARK_VERSION:-3.54.1}"
CLANG_ARCHIVE_DIR="${CLANG_ARCHIVE_DIR:-/home/runner/software/clang}"

# Formal workload: three compile options over the SQLite amalgamation and
# two speedtest1 database sizes, five rounds each.
CLANG_ROUNDS="${CLANG_ROUNDS:-5}"
CLANG_COMPILE_OPTIONS=("-O0" "-O2" "-Os")
CLANG_SPEEDTEST_SIZES=(100000 500000)

# Lifecycle paths (assigned in configure_runtime_paths).
LLVM_ROOT=""
CLANG_BIN=""
CLANGXX_BIN=""
BENCHMARK_DIR=""
AMALGAMATION_DIR=""
SQLITE_SOURCE_DIR=""
SQLITE3_C=""
SQLITE3_H=""
SPEEDTEST1_C=""
SPEEDTEST1_BIN=""

log_message() { printf '[clang] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

llvm_archive_for_version() {
    case "${SOFTWARE_VERSION}:${EXPECTED_ARCH}" in
        23.1.4:x86_64)
            LLVM_ARCHIVE_NAME="LLVM-23.1.4-Linux-X64.tar.xz"
            LLVM_ARCHIVE_SHA256="25d814fda50d5fb0084b42be09605d8b1595d49d5e2e03a3345d7e112ff6f9f3"
            ;;
        23.1.4:aarch64)
            LLVM_ARCHIVE_NAME="LLVM-23.1.4-Linux-ARM64.tar.xz"
            LLVM_ARCHIVE_SHA256="9b27cf263d711aa6ebfd4045ab241d947bd09b3cd19ffa5728f48a80c9eb3a91"
            ;;
        *)
            log_message "ERROR: no verified LLVM release is declared for ${SOFTWARE_VERSION} on ${EXPECTED_ARCH}"
            return 10
            ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64) EXPECTED_ARCH="x86_64" ;;
        aarch64|arm64) EXPECTED_ARCH="aarch64" ;;
        *) log_message "ERROR: unsupported architecture: ${EXPECTED_ARCH}"; return 10 ;;
    esac
    [[ "${EXPECTED_ARCH}" == "$(uname -m)" ]] || {
        log_message "ERROR: runner architecture differs from ${EXPECTED_ARCH}"
        return 20
    }
    llvm_archive_for_version || return $?
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log_message 'ERROR: unsafe run ID'
        return 10
    }
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/clang/local-${PERF_RUN_ID}"
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
    LLVM_ROOT="${PERF_WORK_DIR}/llvm"
    CLANG_BIN="${LLVM_ROOT}/bin/clang"
    CLANGXX_BIN="${LLVM_ROOT}/bin/clang++"
    BENCHMARK_DIR="${PERF_WORK_DIR}/benchmark"
    AMALGAMATION_DIR="${BENCHMARK_DIR}/amalgamation"
    SQLITE_SOURCE_DIR="${BENCHMARK_DIR}/sqlite-src"
    SPEEDTEST1_BIN="${BENCHMARK_DIR}/speedtest1"
    SQLITE3_C="${AMALGAMATION_DIR}/sqlite3.c"
    SQLITE3_H="${AMALGAMATION_DIR}/sqlite3.h"
    SPEEDTEST1_C="${SQLITE_SOURCE_DIR}/speedtest1.c"
    export SOFTWARE_VERSION PERF_VARIANT EXPECTED_ARCH PERF_RUN_ID PERF_WORK_DIR RESULTS_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}" "${TMPDIR}"
}

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else
        "$@"
    fi
}

verify_sha256() {
    local file_path="$1" expected="$2" actual
    actual="$(sha256sum "${file_path}" | cut -d' ' -f1)"
    [[ "${actual}" == "${expected}" ]] || {
        log_message "ERROR: checksum mismatch for ${file_path}: expected ${expected}, got ${actual}"
        return 30
    }
}

verify_sha3_256() {
    local file_path="$1" expected="$2" actual
    actual="$(python3 - "${file_path}" <<'PY'
import hashlib
import sys

with open(sys.argv[1], "rb") as archive:
    print(hashlib.sha3_256(archive.read()).hexdigest())
PY
)"
    [[ "${actual}" == "${expected}" ]] || {
        log_message "ERROR: SHA3-256 mismatch for ${file_path}: expected ${expected}, got ${actual}"
        return 30
    }
}
