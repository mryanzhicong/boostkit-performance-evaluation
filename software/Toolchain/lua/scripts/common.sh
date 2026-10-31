#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="lua"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-5.5.1}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

LUA_VERSION="${SOFTWARE_VERSION}"
LUA_SOURCE_NAME="lua-${LUA_VERSION}.tar.gz"
LUA_TESTSUITE_NAME="lua-${LUA_VERSION}-tests.tar.gz"

# Official release archive: https://www.lua.org/ftp/lua-5.5.1.tar.gz
# Official checksum: https://www.lua.org/ftp/ (sha256 column), download.html.
LUA_SOURCE_SHA256="1c4b4068d67061f2a2231ad2b5422e77acea1487ea9890f6320af614f4373dce"
LUA_SOURCE_SIZE="398643"
# Official test suite: https://www.lua.org/tests/lua-5.5.1-tests.tar.gz
LUA_TESTSUITE_SHA256="da07b543872dc0bb2ff12aabd0c248578d78df3eb6b67efdc537a46d455c7f31"
LUA_TESTSUITE_SIZE="150553"

LUA_OFFICIAL_SOURCE_BASE="https://www.lua.org/ftp"
LUA_OFFICIAL_TESTSUITE_BASE="https://www.lua.org/tests"
LUA_OFFLINE_DIR="${LUA_OFFLINE_DIR:-/home/runner/software/lua}"
LUA_BUILD_TARGET="linux"
LUA_GENERATED_MODULES="${LUA_GENERATED_MODULES:-12000}"
LUA_RUN_TIMEOUT_SECONDS="${LUA_RUN_TIMEOUT_SECONDS:-1800}"

LUA_SOURCE_URLS=()
LUA_TESTSUITE_URLS=()
if [[ -n "${PERF_LUA_SOURCE_MIRROR:-}" ]]; then
    LUA_SOURCE_URLS+=("${PERF_LUA_SOURCE_MIRROR%/}/${LUA_SOURCE_NAME}")
fi
LUA_SOURCE_URLS+=("${LUA_OFFICIAL_SOURCE_BASE}/${LUA_SOURCE_NAME}")
if [[ -n "${PERF_LUA_TESTSUITE_MIRROR:-}" ]]; then
    LUA_TESTSUITE_URLS+=("${PERF_LUA_TESTSUITE_MIRROR%/}/${LUA_TESTSUITE_NAME}")
fi
LUA_TESTSUITE_URLS+=("${LUA_OFFICIAL_TESTSUITE_BASE}/${LUA_TESTSUITE_NAME}")

LUA_REPS="${PERF_REPS:-5}"
LUA_SCENARIOS_FILE="${SCRIPT_DIR}/benchmarks/scenarios.psv"

LUA_SRC_DIR=""
LUA_TESTS_DIR=""
LUA_DOWNLOADS_DIR=""
LUA_GENERATED_DIR=""
LUA_BIN=""
LUAC_BIN=""
RUNS_DIR=""
LUA_VERSION_STRING=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[lua] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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

validate_reps() {
    [[ "${LUA_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${LUA_REPS}"
        return 10
    }
    if (( LUA_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${LUA_REPS} is a local link-validation value; formal evidence requires 5"
    fi
}

configure_runtime_paths() {
    validate_variant || return $?
    validate_reps || return $?
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/lua/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    LUA_SRC_DIR="${PERF_WORK_DIR}/lua-src"
    LUA_TESTS_DIR="${PERF_WORK_DIR}/lua-tests"
    LUA_DOWNLOADS_DIR="${PERF_WORK_DIR}/downloads"
    LUA_GENERATED_DIR="${PERF_WORK_DIR}/generated/luac"
    LUA_BIN="${LUA_SRC_DIR}/src/lua"
    LUAC_BIN="${LUA_SRC_DIR}/src/luac"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR LUA_REPS LUA_OFFLINE_DIR LUA_GENERATED_MODULES
    export LUA_SRC_DIR LUA_TESTS_DIR LUA_DOWNLOADS_DIR LUA_GENERATED_DIR LUA_BIN LUAC_BIN RUNS_DIR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

scenario_expected_checksum() {
    local wanted_runner="$1" scenario dimension runner target scale check expected tolerance workload
    while IFS='|' read -r scenario dimension runner target scale check expected tolerance workload; do
        [[ -z "${scenario}" || "${scenario}" == \#* ]] && continue
        if [[ "${runner}" == "${wanted_runner}" ]]; then
            printf '%s\n' "${expected}"
            return 0
        fi
    done < "${LUA_SCENARIOS_FILE}"
    return 1
}

scenario_count() {
    local count=0 scenario dimension runner target scale check expected tolerance workload
    while IFS='|' read -r scenario dimension runner target scale check expected tolerance workload; do
        [[ -z "${scenario}" || "${scenario}" == \#* ]] && continue
        count=$((count + 1))
    done < "${LUA_SCENARIOS_FILE}"
    printf '%s\n' "${count}"
}
