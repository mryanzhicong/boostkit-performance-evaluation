#!/usr/bin/env bash
#
# Shared configuration and helpers for the catj case.
#
# The case measures the upstream catj 1.0.4 CLI flattening fixed JSON inputs at
# three scales and in both input modes.  Everything that is compared across
# architectures is pinned here: the Node.js patch release, the catj tarball, the
# vendored dependency tree, the generated input hashes and the repetition count.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="catj"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.0.4}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# ---------------------------------------------------------------------------
# Pinned Node.js runtime.  Both architectures use the official archive of the
# same patch release and the same SHA-256.  The archive is pre-placed on the
# runner; the mirrors below are the fallback order.
# ---------------------------------------------------------------------------
NODE_VERSION="v22.23.4"
NODE_SHA256_X86_64="1805bcd35e6815559bd2eb97db438d3fdb0eb3a5e6a977b7c1badca76337e9ce"
NODE_SHA256_AARCH64="6287aa46b6c375d816e63ae66d024fbbfd70404825aabdfdf898a970871d2f4b"
NODE_TARBALL_X86_64="node-${NODE_VERSION}-linux-x64.tar.xz"
NODE_TARBALL_AARCH64="node-${NODE_VERSION}-linux-arm64.tar.xz"
NODE_URLS_X86_64=(
    "https://mirrors.huaweicloud.com/nodejs/latest-v22.x/${NODE_TARBALL_X86_64}"
    "https://registry.npmmirror.com/-/binary/node/latest-v22.x/${NODE_TARBALL_X86_64}"
)
NODE_URLS_AARCH64=(
    "https://mirrors.huaweicloud.com/nodejs/latest-v22.x/${NODE_TARBALL_AARCH64}"
    "https://registry.npmmirror.com/-/binary/node/latest-v22.x/${NODE_TARBALL_AARCH64}"
)

# ---------------------------------------------------------------------------
# Vendored upstream release and dependency tree.  The npm tarball and the
# flattened node_modules archive are shipped with the case so the build works
# without a registry; the registry URLs are only a fallback for the tarball.
# ---------------------------------------------------------------------------
CATJ_TARBALL="catj-${SOFTWARE_VERSION}.tgz"
CATJ_SHA256="bc3c7c18e24aa412f705ce2676534aeac25b42f01ec71f5fd3b5ddad518f3e6c"
CATJ_TARBALL_URLS=(
    "https://registry.npmmirror.com/catj/-/catj-${SOFTWARE_VERSION}.tgz"
    "https://mirrors.huaweicloud.com/repository/npm/catj/-/catj-${SOFTWARE_VERSION}.tgz"
)
DEPS_TARBALL="catj-node_modules-1.0.4.tar.gz"
DEPS_SHA256="c9a154e32f88703a2362713c1e3426da182e37651c2a419ab49bce60f3e12fce"
CATJ_PACKAGE_SHA256="87e0e456907e344c38913b6b5ef9fae41e1936a85bdf90da59e1c0f80d51187c"
CATJ_CLI_SHA256="735fad756dbb41159a0d0180f0b40510cd249f88324c055440a01d4234b42b7b"
CATJ_DEPENDENCIES=(
    "colors=1.4.0"
    "minimist=0.0.10"
    "optimist=0.6.1"
    "wordwrap=0.0.3"
)

CATJ_OFFLINE_DIR="${PERF_CATJ_OFFLINE_DIR:-/home/runner/software/catj}"
CATJ_SCENARIOS=(
    flatten_file_5000
    flatten_stdin_5000
    flatten_file_25000
    flatten_stdin_25000
    flatten_file_100000
    flatten_stdin_100000
)

BUILD_JOBS="${PERF_BUILD_JOBS:-$(nproc)}"
CATJ_REPS="${PERF_REPS:-5}"
CATJ_WARMUPS="${PERF_WARMUPS:-1}"
CATJ_STATISTIC="median"
CATJ_OFFLINE_MEASUREMENT="true"

NODE_HOME=""
NODE_DIR=""
NODE_BIN=""
APP_DIR=""
INPUT_DIR=""
RUNS_DIR=""
SCENARIOS_FILE=""
RUNTIME_JSON=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[catj] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
}

normalize_architecture() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

node_tarball() {
    case "$(normalize_architecture "${EXPECTED_ARCH}")" in
        aarch64) printf '%s\n' "${NODE_TARBALL_AARCH64}" ;;
        *) printf '%s\n' "${NODE_TARBALL_X86_64}" ;;
    esac
}

node_sha256() {
    case "$(normalize_architecture "${EXPECTED_ARCH}")" in
        aarch64) printf '%s\n' "${NODE_SHA256_AARCH64}" ;;
        *) printf '%s\n' "${NODE_SHA256_X86_64}" ;;
    esac
}

node_urls() {
    case "$(normalize_architecture "${EXPECTED_ARCH}")" in
        aarch64) printf '%s\n' "${NODE_URLS_AARCH64[@]}" ;;
        *) printf '%s\n' "${NODE_URLS_X86_64[@]}" ;;
    esac
}

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

validate_reps() {
    if [[ ! "${CATJ_REPS}" =~ ^[0-9]+$ ]] || [[ "${CATJ_REPS}" -lt 1 ]]; then
        log_message "ERROR: PERF_REPS must be a positive integer, got ${CATJ_REPS}"
        return 20
    fi
    if [[ ! "${CATJ_WARMUPS}" =~ ^[0-9]+$ ]]; then
        log_message "ERROR: PERF_WARMUPS must be a non-negative integer, got ${CATJ_WARMUPS}"
        return 20
    fi
}

check_architecture() {
    local actual expected
    actual="$(normalize_architecture "$(uname -m)")"
    expected="$(normalize_architecture "${EXPECTED_ARCH}")"
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: expected architecture ${expected}, runner is ${actual}"
        return 20
    fi
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
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/${SOFTWARE_NAME}/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi

    NODE_HOME="${PERF_WORK_DIR}/node"
    NODE_DIR="${NODE_HOME}/node-${NODE_VERSION}-$( [ "$(normalize_architecture "${EXPECTED_ARCH}")" = "aarch64" ] && printf 'linux-arm64' || printf 'linux-x64' )"
    NODE_BIN="${NODE_DIR}/bin/node"
    APP_DIR="${PERF_WORK_DIR}/app"
    INPUT_DIR="${PERF_WORK_DIR}/inputs"
    RUNS_DIR="${RESULTS_DIR}/runs"
    SCENARIOS_FILE="${SCRIPT_DIR}/fixtures/scenarios.json"
    RUNTIME_JSON="${PERF_WORK_DIR}/runtime.json"

    export SOFTWARE_NAME SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    export PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export NODE_VERSION NODE_HOME NODE_DIR NODE_BIN APP_DIR INPUT_DIR
    export RUNS_DIR SCENARIOS_FILE RUNTIME_JSON
    export CATJ_REPS CATJ_WARMUPS BUILD_JOBS CATJ_OFFLINE_DIR CATJ_STATISTIC
    export CATJ_TARBALL CATJ_SHA256 DEPS_TARBALL DEPS_SHA256
    export CATJ_OFFLINE_MEASUREMENT
    export CATJ_SCENARIOS_FILE="${SCENARIOS_FILE}"
    export CATJ_RUNTIME_JSON="${RUNTIME_JSON}"
    export CATJ_APP_DIR="${APP_DIR}"
    export CATJ_INPUT_DIR="${INPUT_DIR}"
    export CATJ_NODE_BIN="${NODE_BIN}"
    export CATJ_TARBALL_SHA256="${CATJ_SHA256}"
    export CATJ_DEPS_SHA256="${DEPS_SHA256}"
    export NODE_ARCHIVE_SHA256="$(node_sha256)"
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${RUNS_DIR}"
}

# Environment shared by every timed scenario.  FORCE_COLOR=0 makes the captured
# stdout byte-identical on both architectures, and the BLAS/OpenMP variables
# neutralise thread pools that would otherwise depend on the runner.
catj_measurement_env() {
    export NODE_ENV=production
    export FORCE_COLOR=0
    export NO_COLOR=1
    export TZ=UTC
    export LANG=C
    export LC_ALL=C
    export OMP_NUM_THREADS=1
    export UV_THREADPOOL_SIZE=1
    export HOME="${PERF_WORK_DIR}/home"
    mkdir -p "${HOME}" "${TMPDIR}"
    export DEBUGINFOD_URLS=""
    export http_proxy="http://127.0.0.1:9"
    export https_proxy="http://127.0.0.1:9"
    export HTTP_PROXY="http://127.0.0.1:9"
    export HTTPS_PROXY="http://127.0.0.1:9"
    export no_proxy=""
    export NO_PROXY=""
}

scenario_timeout() {
    case "$1" in
        flatten_file_100000|flatten_stdin_100000) printf '180\n' ;;
        *) printf '120\n' ;;
    esac
}

count_scenario_entries() {
    python3 - "${SCENARIOS_FILE}" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    payload = json.load(handle)
print(len(payload["scenarios"]))
PY
}

known_scenarios_csv() {
    local name out=""
    for name in "${CATJ_SCENARIOS[@]}"; do
        if [[ -n "${out}" ]]; then
            out+=","
        fi
        out+="${name}"
    done
    printf '%s\n' "${out}"
}

file_sha256() {
    sha256sum "$1" | awk '{print $1}'
}
