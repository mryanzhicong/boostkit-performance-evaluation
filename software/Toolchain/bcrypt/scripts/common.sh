#!/usr/bin/env bash
#
# Shared configuration and helpers for the bcrypt case.
#
# The case measures the pinned bcrypt 6.0.0 release (cost=10 hash/compare, plus
# cost=12 hashing) on a pinned Node.js runtime.  The release ships prebuilt
# N-API binaries for both target architectures; their SHA-256 values are pinned
# here and re-verified before every measurement.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="bcrypt"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-6.0.0}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

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

BCRYPT_TARBALL="bcrypt-${SOFTWARE_VERSION}.tgz"
BCRYPT_SHA256="3b2478cda06f066c744e06cd0b68f55e14cc546c19ee2b80be600dfc65b5ae20"
BCRYPT_TARBALL_URLS=(
    "https://registry.npmmirror.com/bcrypt/-/bcrypt-${SOFTWARE_VERSION}.tgz"
    "https://mirrors.huaweicloud.com/repository/npm/bcrypt/-/bcrypt-${SOFTWARE_VERSION}.tgz"
)
DEPS_TARBALL="bcrypt-node_modules-6.0.0.tar.gz"
DEPS_SHA256="ac85950fb1fc53fefb774b9272e15313bf05d0e508173fb02727122ae7949329"
BCRYPT_PACKAGE_SHA256="33510b2b8859265a413ab101cdf961b1c9b076d93496f52d8ac7eacc007859a4"
BCRYPT_JS_SHA256="427843f9f572915536dffb47cbeddfdeb8f1c24ddf5db75d76021c1efa522c48"
BCRYPT_BINDING_SHA256="b55c2f501c320237f9a2340994b4645a471d641af3d341b9d9f3eb404b3bda5d"
NATIVE_X86_64_SHA256="d640649833b5f0504096b747ae1a66e0780291edc5c33b541696b2cf2aabb5e3"
NATIVE_AARCH64_SHA256="68f3cf61756809c6d466c186aaa2bc1cbc17911f248c361a5284aa4e769fcc52"
BCRYPT_DEPENDENCIES=(
    "node-addon-api=8.9.2"
    "node-gyp-build=4.8.4"
)

BCRYPT_OFFLINE_DIR="${PERF_BCRYPT_OFFLINE_DIR:-/home/runner/software/bcrypt}"
BCRYPT_SCENARIOS=(
    hash_sync_cost10
    hash_async_cost10
    compare_sync_cost10
    compare_async_cost10
    hash_sync_cost12
    compare_async_cost12
)
BCRYPT_COST_SCENARIOS=(hash_sync_cost12 compare_async_cost12)

BUILD_JOBS="${PERF_BUILD_JOBS:-$(nproc)}"
BCRYPT_REPS="${PERF_REPS:-5}"
BCRYPT_WARMUPS="${PERF_WARMUPS:-1}"
BCRYPT_STATISTIC="median"
BCRYPT_OFFLINE_MEASUREMENT="true"

NODE_HOME=""
NODE_DIR=""
NODE_BIN=""
APP_DIR=""
RUNS_DIR=""
SCENARIOS_FILE=""
RUNTIME_JSON=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[bcrypt] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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

native_sha256() {
    case "$(normalize_architecture "${EXPECTED_ARCH}")" in
        aarch64) printf '%s\n' "${NATIVE_AARCH64_SHA256}" ;;
        *) printf '%s\n' "${NATIVE_X86_64_SHA256}" ;;
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
    if [[ ! "${BCRYPT_REPS}" =~ ^[0-9]+$ ]] || [[ "${BCRYPT_REPS}" -lt 1 ]]; then
        log_message "ERROR: PERF_REPS must be a positive integer, got ${BCRYPT_REPS}"
        return 20
    fi
    if [[ ! "${BCRYPT_WARMUPS}" =~ ^[0-9]+$ ]]; then
        log_message "ERROR: PERF_WARMUPS must be a non-negative integer, got ${BCRYPT_WARMUPS}"
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
    if [[ "$(normalize_architecture "${EXPECTED_ARCH}")" == "aarch64" ]]; then
        NODE_DIR="${NODE_HOME}/node-${NODE_VERSION}-linux-arm64"
    else
        NODE_DIR="${NODE_HOME}/node-${NODE_VERSION}-linux-x64"
    fi
    NODE_BIN="${NODE_DIR}/bin/node"
    APP_DIR="${PERF_WORK_DIR}/app"
    RUNS_DIR="${RESULTS_DIR}/runs"
    SCENARIOS_FILE="${SCRIPT_DIR}/fixtures/scenarios.json"
    RUNTIME_JSON="${PERF_WORK_DIR}/runtime.json"

    export SOFTWARE_NAME SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    export PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export NODE_VERSION NODE_HOME NODE_DIR NODE_BIN APP_DIR
    export RUNS_DIR SCENARIOS_FILE RUNTIME_JSON
    export BCRYPT_REPS BCRYPT_WARMUPS BUILD_JOBS BCRYPT_OFFLINE_DIR BCRYPT_STATISTIC
    export BCRYPT_TARBALL BCRYPT_SHA256 DEPS_TARBALL DEPS_SHA256 BCRYPT_OFFLINE_MEASUREMENT
    export BCRYPT_SCENARIOS_FILE="${SCENARIOS_FILE}"
    export BCRYPT_RUNTIME_JSON="${RUNTIME_JSON}"
    export BCRYPT_APP_DIR="${APP_DIR}"
    export BCRYPT_NODE_BIN="${NODE_BIN}"
    export BCRYPT_TARBALL_SHA256="${BCRYPT_SHA256}"
    export BCRYPT_DEPS_SHA256="${DEPS_SHA256}"
    export BCRYPT_NATIVE_SHA256="$(native_sha256)"
    export NODE_ARCHIVE_SHA256="$(node_sha256)"
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${RUNS_DIR}"
}

# Environment shared by every timed scenario.  The libuv thread pool is pinned
# to one thread so the C++ work never overlaps between operations, and CPU
# affinity variables do not leak into the measurement.
bcrypt_measurement_env() {
    export UV_THREADPOOL_SIZE=1
    export TZ=UTC
    export LANG=C
    export LC_ALL=C
    export NODE_ENV=production
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
        hash_sync_cost12|compare_async_cost12) printf '300\n' ;;
        *) printf '180\n' ;;
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

scenario_fields() {
    python3 - "${SCENARIOS_FILE}" "$1" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    payload = json.load(handle)
scenario = next(item for item in payload["scenarios"] if item["id"] == sys.argv[2])
print(f"{scenario['op']} {scenario['api']} {scenario['cost']} {scenario['ops']}")
PY
}

known_scenarios_csv() {
    local name out=""
    for name in "${BCRYPT_SCENARIOS[@]}"; do
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
