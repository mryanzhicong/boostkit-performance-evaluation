#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="php"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-8.5.12}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

PHP_SOURCE_NAME="php-${SOFTWARE_VERSION}.tar.gz"
# Official release archive: https://www.php.net/distributions/php-8.5.12.tar.gz
# Official SHA-256 comes from https://www.php.net/releases/index.php?json&version=8.5
PHP_SOURCE_SHA256="81a0f450349e84b08eb43faa85f8a4c835684f3cc1c50471775d1317a046c525"
PHP_SOURCE_SIZE="24469403"
PHP_OFFICIAL_SOURCE_BASE="https://www.php.net/distributions"
PHP_OFFLINE_DIR="${PHP_OFFLINE_DIR:-/home/runner/software/php}"
PHP_BUILD_JOBS="${PHP_BUILD_JOBS:-$(nproc)}"
# Minimal CLI build, fixed here and in the README: no FPM, no HTTP SAPI, no
# third-party extensions.  PHP 8.5 always compiles Zend OPcache into the CLI
# binary (there is no shared opcache.so any more), so the opcache scenarios
# only toggle opcache.enable_cli / the file cache at run time; the JIT is
# disabled at build time to keep the baseline free of JIT-compiled code.
PHP_CONFIGURE_FLAGS=(
    --disable-all
    --enable-cli
    --disable-opcache-jit
)
PHP_RUN_TIMEOUT_SECONDS="${PHP_RUN_TIMEOUT_SECONDS:-1800}"
PHP_REPS="${PERF_REPS:-5}"
PHP_GENERATED_MODULES="${PHP_GENERATED_MODULES:-1000}"

PHP_SOURCE_URLS=()
if [[ -n "${PERF_PHP_SOURCE_MIRROR:-}" ]]; then
    PHP_SOURCE_URLS+=("${PERF_PHP_SOURCE_MIRROR%/}/${PHP_SOURCE_NAME}")
fi
PHP_SOURCE_URLS+=("${PHP_OFFICIAL_SOURCE_BASE}/${PHP_SOURCE_NAME}")

PHP_SCENARIOS_FILE="${SCRIPT_DIR}/benchmarks/scenarios.psv"

PHP_SRC_DIR=""
PHP_INSTALL_DIR=""
PHP_BIN=""
PHP_OPCACHE_SO=""
PHP_OPCACHE_INI=""
PHP_OPCACHE_CACHE_DIR=""
PHP_GENERATED_DIR=""
PHP_BUILD_DIR=""
PHP_DOWNLOADS_DIR=""
PHP_VERSION_STRING=""
PHP_CONFIGURE_SUMMARY=""
RUNS_DIR=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[php] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
        *)
            log_message "ERROR: invalid build variant: ${PERF_VARIANT}"
            return 10
            ;;
    esac
}

validate_reps() {
    [[ "${PHP_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${PHP_REPS}"
        return 10
    }
    if (( PHP_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${PHP_REPS} is a local link-validation value; formal evidence requires 5"
    fi
}

configure_runtime_paths() {
    validate_variant || return $?
    validate_reps || return $?
    [[ "${SOFTWARE_VERSION}" == "8.5.12" ]] || {
        log_message "ERROR: unsupported PHP version: ${SOFTWARE_VERSION}"
        return 10
    }
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    local runner_architecture
    runner_architecture="$(normalize_architecture "$(uname -m)")"
    EXPECTED_ARCH="$(normalize_architecture "${EXPECTED_ARCH}")"
    case "${EXPECTED_ARCH}" in
        x86_64|aarch64) ;;
        *)
            log_message "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
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
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/php/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    TMPDIR="${PERF_WORK_DIR}/tmp"
    PHP_SRC_DIR="${PERF_WORK_DIR}/php-src/php-${SOFTWARE_VERSION}"
    PHP_INSTALL_DIR="${PERF_WORK_DIR}/php-install"
    PHP_BIN="${PHP_INSTALL_DIR}/bin/php"
    PHP_OPCACHE_INI="${PERF_WORK_DIR}/opcache.ini"
    PHP_OPCACHE_CACHE_DIR="${PERF_WORK_DIR}/opcache-file-cache"
    PHP_GENERATED_DIR="${PERF_WORK_DIR}/generated/modules"
    PHP_BUILD_DIR="${PERF_WORK_DIR}/build"
    PHP_DOWNLOADS_DIR="${PERF_WORK_DIR}/downloads"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID PERF_WORK_DIR
    export RESULTS_DIR PERF_ACTUAL_VERSION_FILE TMPDIR PHP_REPS PHP_OFFLINE_DIR
    export PHP_GENERATED_MODULES PHP_GENERATED_DIR PHP_SRC_DIR PHP_INSTALL_DIR
    export PHP_BIN PHP_OPCACHE_INI PHP_OPCACHE_CACHE_DIR PHP_BUILD_DIR RUNS_DIR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

scenario_count() {
    local count=0 scenario dimension runner target scale check expected tolerance workload
    while IFS='|' read -r scenario dimension runner target scale check expected tolerance workload; do
        [[ -z "${scenario}" || "${scenario}" == \#* ]] && continue
        count=$((count + 1))
    done < "${PHP_SCENARIOS_FILE}"
    printf '%s\n' "${count}"
}
