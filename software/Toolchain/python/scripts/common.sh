#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-3.14.3}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
CPYTHON_SOURCE_URL="${CPYTHON_SOURCE_URL:-https://github.com/python/cpython.git}"
PYPI_INDEX_URL="https://mirrors.huaweicloud.com/repository/pypi/simple"
PYPI_TRUSTED_HOST="mirrors.huaweicloud.com"
PYPERFORMANCE_VERSION="1.13.0"
PYPERFORMANCE_WARMUP="3"
CONFIGURE_OPTIONS="--enable-optimizations --with-lto"

# Optimized variant source point: the CinderX branch tip is resolved and pinned
# to an explicit commit during the build, then recorded for later stages.
CINDERX_REPOSITORY="${CINDERX_REPOSITORY:-https://gitcode.com/openeuler/cinderx.git}"
CINDERX_REF="${CINDERX_REF:-master}"
CINDERX_BUILD_TYPE="${CINDERX_BUILD_TYPE:-Release}"
CINDERX_BUILD_JOBS="${CINDERX_BUILD_JOBS:-}"
CINDERX_LOCAL_DEPS="${CINDERX_LOCAL_DEPS:-}"
CINDERX_ENABLE_PGO="${CINDERX_ENABLE_PGO:-0}"
CINDERX_ENABLE_LTO="${CINDERX_ENABLE_LTO:-0}"
CINDERX_PLUGIN_ENV="${CINDERX_PLUGIN_ENV:-1}"
CINDERX_PYTHONJITAUTO="${CINDERX_PYTHONJITAUTO:-auto:2}"

SOURCE_DIR=""
INSTALL_DIR=""
BENCH_WORK_DIR=""
PYTHON_BIN=""
GCC_VERSION_STRING=""
CINDERX_SOURCE_DIR="${CINDERX_SOURCE_DIR:-}"
CINDERX_SOURCE_RECORD="${CINDERX_SOURCE_RECORD:-}"
CINDERX_CC="${CINDERX_CC:-}"
CINDERX_CXX="${CINDERX_CXX:-}"
CINDERX_GCOV=""
CINDERX_GCC_LIBDIR=""
CINDERX_VERSION=""
PYTHON_EXPECTED_COMMIT=""
PYTHON_EXPECTED_BRANCH=""
PYTHON_EXPECTED_TREE=""
PYTHON_EXPECTED_PARENT=""
PYTHON_EXPECTED_PARENT_TREE=""
PYTHON_EXPECTED_RANGE=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[python] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    }
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/python/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/cpython-source"
    INSTALL_DIR="${PERF_WORK_DIR}/cpython-install"
    BENCH_WORK_DIR="${PERF_WORK_DIR}/pyperformance-work"
    PYTHON_BIN="${INSTALL_DIR}/bin/python3"
    CINDERX_SOURCE_DIR="${CINDERX_SOURCE_DIR:-${PERF_WORK_DIR}/cinderx-source}"
    CINDERX_SOURCE_RECORD="${CINDERX_SOURCE_RECORD:-${RESULTS_DIR}/cinderx-source.txt}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR CINDERX_SOURCE_DIR CINDERX_SOURCE_RECORD
    export CINDERX_REPOSITORY CINDERX_REF CONFIGURE_OPTIONS
}

initialize_runtime() {
    configure_runtime_paths
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

# Read one key from the optimized source record written during the build.
# The key set is closed so the value can never become a sed expression.
python_source_record_value() {
    local key="$1"
    local record="${2:-${CINDERX_SOURCE_RECORD}}"
    case "${key}" in
        ref|branch|head|head_tree|parent|parent_tree|range) ;;
        *)
            log_message "ERROR: unsupported source record key: ${key}"
            return 1
            ;;
    esac
    [[ -f "${record}" ]] || return 1
    sed -n "s/^${key}=//p" "${record}" | head -n 1
}

# Load the pinned optimized source point for start/test/parse. This is
# idempotent: every call re-reads the same record and re-exports the same
# EXPECTED_* values. A missing record or a ref/branch mismatch is fatal so a
# run can never silently fall back to the native interpreter.
python_load_expected_source() {
    [[ "${PERF_VARIANT}" == optimized ]] || return 0

    [[ -f "${CINDERX_SOURCE_RECORD}" ]] || {
        log_message "ERROR: optimized source record is missing: ${CINDERX_SOURCE_RECORD}"
        return 30
    }

    local head tree branch ref parent parent_tree range
    head="$(python_source_record_value head || true)"
    tree="$(python_source_record_value head_tree || true)"
    branch="$(python_source_record_value branch || true)"
    ref="$(python_source_record_value ref || true)"
    parent="$(python_source_record_value parent || true)"
    parent_tree="$(python_source_record_value parent_tree || true)"
    range="$(python_source_record_value range || true)"

    [[ "${head}" =~ ^[0-9a-f]{40}$ ]] || {
        log_message "ERROR: source record has no valid commit: ${head}"
        return 30
    }
    [[ "${tree}" =~ ^[0-9a-f]{40}$ ]] || {
        log_message "ERROR: source record has no valid commit tree: ${tree}"
        return 30
    }
    [[ -n "${branch}" ]] || {
        log_message "ERROR: source record has no branch"
        return 30
    }
    [[ "${ref}" == "${CINDERX_REF}" ]] || {
        log_message "ERROR: source record ref ${ref} does not match requested ${CINDERX_REF}"
        return 30
    }
    [[ "${branch}" == detached || "${branch}" == "${CINDERX_REF}" ]] || {
        log_message "ERROR: source record branch ${branch} does not match requested ${CINDERX_REF}"
        return 30
    }
    [[ "${parent}" =~ ^[0-9a-f]{40}$ ]] || {
        log_message "ERROR: source record has no valid parent commit: ${parent}"
        return 30
    }
    [[ "${parent_tree}" =~ ^[0-9a-f]{40}$ ]] || {
        log_message "ERROR: source record has no valid parent tree: ${parent_tree}"
        return 30
    }

    local expected_range="${parent}..${head}"
    [[ -z "${range}" || "${range}" == "${expected_range}" ]] || {
        log_message "ERROR: source record range ${range} does not match ${expected_range}"
        return 30
    }

    PYTHON_EXPECTED_COMMIT="${head}"
    PYTHON_EXPECTED_BRANCH="${branch}"
    PYTHON_EXPECTED_TREE="${tree}"
    PYTHON_EXPECTED_PARENT="${parent}"
    PYTHON_EXPECTED_PARENT_TREE="${parent_tree}"
    PYTHON_EXPECTED_RANGE="${expected_range}"
    export PYTHON_EXPECTED_COMMIT PYTHON_EXPECTED_BRANCH PYTHON_EXPECTED_TREE
    export PYTHON_EXPECTED_PARENT PYTHON_EXPECTED_PARENT_TREE PYTHON_EXPECTED_RANGE
}

# Switch the measurement environment to the optimized variant. Base keeps the
# original environment so its command and results stay byte-identical.
python_apply_measurement_environment() {
    [[ "${PERF_VARIANT}" == optimized ]] || return 0
    export CINDERX_PLUGIN_ENABLE="${CINDERX_PLUGIN_ENV}"
    export PYTHONJITAUTO="${CINDERX_PYTHONJITAUTO}"
    log_message "CinderX measurement environment: CINDERX_PLUGIN_ENABLE=${CINDERX_PLUGIN_ENABLE} PYTHONJITAUTO=${PYTHONJITAUTO}"
}

# Comma-separated variable list handed to pyperformance --inherit-environ.
# The network variables are needed while the benchmark venv installs its
# requirements; the CinderX variables are needed by every benchmark worker.
python_measurement_inherit_environ() {
    local value="PIP_INDEX_URL,PIP_TRUSTED_HOST,http_proxy,https_proxy,no_proxy,all_proxy,HTTP_PROXY,HTTPS_PROXY,NO_PROXY,ALL_PROXY"
    if [[ "${PERF_VARIANT}" == optimized ]]; then
        value="${value},CINDERX_PLUGIN_ENABLE,PYTHONJITAUTO,LD_LIBRARY_PATH"
    fi
    printf '%s\n' "${value}"
}
