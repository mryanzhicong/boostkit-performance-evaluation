#!/usr/bin/env bash
set -euo pipefail

CASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="doris"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-2.1.2}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

DORIS_OFFLINE_DIR="${DORIS_OFFLINE_DIR:-/home/runner/software/doris}"
DORIS_IMAGE_ARCHIVE_DIR="${DORIS_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
DORIS_JDK_OFFLINE_DIR="${DORIS_JDK_OFFLINE_DIR:-/home/runner/software/bishengjdk}"
DORIS_PYTHON_OFFLINE_DIR="${DORIS_PYTHON_OFFLINE_DIR:-/home/runner/software/python}"
DORIS_TPCH_OFFLINE_DIR="${DORIS_TPCH_OFFLINE_DIR:-/home/runner/software/tpch}"
DORIS_CA_ANCHORS_DIR="${DORIS_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
DORIS_RELEASE_BASE_URL="https://apache-doris-releases.oss-accelerate.aliyuncs.com"
BISHENG_JDK_RELEASE="8u472-b11"
BISHENG_JDK_BASE_URL="https://repo.huaweicloud.com/kunpeng/archive/compiler/bisheng_jdk"

DORIS_CPUSET="${DORIS_CPUSET:-0-31}"
DORIS_MEMSET="${DORIS_MEMSET:-0}"
DORIS_MEMORY="${DORIS_MEMORY:-128g}"
DORIS_MEMORY_SWAP="${DORIS_MEMORY_SWAP:-128g}"

DORIS_FE_HEAP="${DORIS_FE_HEAP:--Xmx8g -Xms8g}"
DORIS_PARALLEL_PIPELINE_TASKS="${DORIS_PARALLEL_PIPELINE_TASKS:-32}"
DORIS_EXEC_MEM_LIMIT="${DORIS_EXEC_MEM_LIMIT:-107374182400}"
DORIS_QUERY_TIMEOUT="${DORIS_QUERY_TIMEOUT:-7200}"
DORIS_SF="${DORIS_SF:-1}"
DORIS_ROUNDS="${DORIS_ROUNDS:-3}"
DORIS_DATABASE="tpch_sf${DORIS_SF}"

log_message() { printf '[doris] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }
log_error() { printf '[doris] [%s] ERROR: %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*" >&2; }

# SHA-256 of the official apache-doris-2.1.2-bin-<arch>.tar.gz archives.
doris_package_sha256() {
    case "$1" in
        x86_64) printf '%s' '90384e528fea35f9ef58c4840cd12d73d3fdcaeba1c96c9ef5ac1b4d2caf7e41' ;;
        aarch64) printf '%s' 'ae7b69e8f040fdecb6e9f3b496aca38c169d1668b37e1cee4293776d00f4f0f9' ;;
        *) return 1 ;;
    esac
}

doris_release_name() {
    case "${EXPECTED_ARCH}" in
        x86_64) printf 'apache-doris-%s-bin-x64.tar.gz' "${SOFTWARE_VERSION}" ;;
        aarch64) printf 'apache-doris-%s-bin-arm64.tar.gz' "${SOFTWARE_VERSION}" ;;
        *) return 1 ;;
    esac
}

configure_runtime_paths() {
    [[ "${SOFTWARE_VERSION}" == "2.1.2" ]] || {
        log_error "unsupported Doris version: ${SOFTWARE_VERSION}"; return 10;
    }
    [[ "${PERF_VARIANT}" == base || "${PERF_VARIANT}" == optimized ]] || return 10
    [[ "${EXPECTED_ARCH}" == "$(uname -m)" ]] || {
        log_error "EXPECTED_ARCH ${EXPECTED_ARCH} differs from runner architecture $(uname -m)"; return 20;
    }
    DORIS_RELEASE="$(doris_release_name)" || { log_error "unsupported architecture: ${EXPECTED_ARCH}"; return 20; }
    PERF_RUN_ID="${PERF_RUN_ID:-local-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || return 10
    PERF_WORK_DIR="${PERF_WORK_DIR:-/home/runner/boostkit-perf/doris/local-${PERF_RUN_ID}}"
    RESULTS_DIR="${RESULTS_DIR:-${CASE_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}}"
    [[ "${RESULTS_DIR}" == /* ]] || RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${PERF_WORK_DIR}/actual-version.txt}"
    case "${EXPECTED_ARCH}" in
        x86_64) DORIS_DIR_SUFFIX=x64 ;;
        aarch64) DORIS_DIR_SUFFIX=arm64 ;;
    esac
    DORIS_HOME="${PERF_WORK_DIR}/apache-doris-${SOFTWARE_VERSION}-bin-${DORIS_DIR_SUFFIX}"
    DORIS_FE="${DORIS_HOME}/fe"
    DORIS_BE="${DORIS_HOME}/be"
    DORIS_JDK_HOME="${PERF_WORK_DIR}/bisheng-jdk"
    DORIS_DATA="${PERF_WORK_DIR}/data/doris"
    DORIS_LOG_DIR="${PERF_WORK_DIR}/logs"
    DORIS_RESULT_DIR="${RESULTS_DIR}/doris-official"
    DORIS_CONTAINER_NAME="boostkit-doris-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    DORIS_IMAGE_FILE="${PERF_WORK_DIR}/container-image.txt"
    local checksum offset
    checksum="$(printf '%s' "${PERF_RUN_ID}" | cksum)"
    offset="$(( ${checksum%% *} % 900 ))"
    DORIS_QUERY_PORT="$((29000 + offset))"
    DORIS_HTTP_PORT="$((DORIS_QUERY_PORT + 1))"
    DORIS_RPC_PORT="$((DORIS_QUERY_PORT + 2))"
    DORIS_EDIT_LOG_PORT="$((DORIS_QUERY_PORT + 3))"
    DORIS_BE_PORT="$((DORIS_QUERY_PORT + 4))"
    DORIS_WEBSERVER_PORT="$((DORIS_QUERY_PORT + 5))"
    DORIS_HEARTBEAT_PORT="$((DORIS_QUERY_PORT + 6))"
    DORIS_BRPC_PORT="$((DORIS_QUERY_PORT + 7))"
    [[ "${DORIS_ROUNDS}" =~ ^[1-9][0-9]*$ ]] || { log_error "DORIS_ROUNDS must be positive"; return 10; }
    [[ "${DORIS_SF}" =~ ^[1-9][0-9]*$ ]] || { log_error "DORIS_SF must be positive"; return 10; }
    export PERF_WORK_DIR RESULTS_DIR PERF_ACTUAL_VERSION_FILE
    export DORIS_HOME DORIS_FE DORIS_BE DORIS_JDK_HOME DORIS_DATA DORIS_LOG_DIR DORIS_RESULT_DIR
    export DORIS_CONTAINER_NAME DORIS_QUERY_PORT DORIS_HTTP_PORT DORIS_RPC_PORT DORIS_EDIT_LOG_PORT
    export DORIS_BE_PORT DORIS_WEBSERVER_PORT DORIS_HEARTBEAT_PORT DORIS_BRPC_PORT
    export DORIS_PARALLEL_PIPELINE_TASKS DORIS_EXEC_MEM_LIMIT DORIS_QUERY_TIMEOUT
    export DORIS_SF DORIS_ROUNDS DORIS_DATABASE DORIS_RELEASE DORIS_FE_HEAP
    export DORIS_CPUSET DORIS_MEMSET DORIS_MEMORY DORIS_MEMORY_SWAP
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}/tmp" "${DORIS_LOG_DIR}" "${DORIS_RESULT_DIR}"
}

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else
        "$@"
    fi
}

require_docker() {
    command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1 || {
        log_error 'an accessible Docker daemon is required'; return 30;
    }
}

doris_exec() {
    docker exec -e "HOME=${PERF_WORK_DIR}" -e "TMPDIR=${PERF_WORK_DIR}/tmp" \
        -e "PYTHONPATH=${PERF_WORK_DIR}/python" \
        -e "JAVA_HOME=${DORIS_JDK_HOME}" \
        -e "PATH=${DORIS_JDK_HOME}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
        "${DORIS_CONTAINER_NAME}" "$@"
}

doris_exec_root() {
    local -a proxy=()
    [[ -z "${PERF_PROXY:-}" ]] || proxy=(--setopt="proxy=${PERF_PROXY}")
    docker exec --user 0 "${DORIS_CONTAINER_NAME}" dnf "${proxy[@]}" "$@"
}

check_container() {
    [[ "$(docker inspect --format '{{.State.Running}}' "${DORIS_CONTAINER_NAME}" 2>/dev/null)" == true ]] || {
        log_error "managed container is not running: ${DORIS_CONTAINER_NAME}"; return 40;
    }
    local label
    label="$(docker inspect --format '{{index .Config.Labels "boostkit.doris.run-id"}}' "${DORIS_CONTAINER_NAME}" 2>/dev/null)"
    [[ "${label}" == "${PERF_RUN_ID}" ]] || {
        log_error "container label differs from run id ${PERF_RUN_ID}"; return 40;
    }
}
