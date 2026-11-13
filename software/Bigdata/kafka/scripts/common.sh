#!/usr/bin/env bash
set -euo pipefail

CASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-2.5.0}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
KAFKA_OFFLINE_DIR="${KAFKA_OFFLINE_DIR:-/home/runner/software/kafka}"
KAFKA_IMAGE_ARCHIVE_DIR="${KAFKA_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
KAFKA_CA_ANCHORS_DIR="${KAFKA_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
KAFKA_ARCHIVE_SHA512=447a7057bcd9faca98b6f4807bd6019ef73eee90efdc1e7b10005f669e2537a8a190cb8b9c9f4c20db1d95b13d0f0487e9cc560d0759532058439ce7f722c7cd
ZOOKEEPER_ARCHIVE_SHA512=caff5111bb6876b7124760bc006e6fa2523efa54b99321a3c9cd8192ea0d5596abc7d70a054b1aac9b20a411407dae7611c7aba870c23bff28eb1643ba499199
KAFKA_RECORDS=${KAFKA_RECORDS:-10000000}
KAFKA_RECORD_SIZE=${KAFKA_RECORD_SIZE:-1024}
KAFKA_PARTITIONS=${KAFKA_PARTITIONS:-72}

log_message() { printf '[kafka] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }
log_error() { printf '[kafka] [%s] ERROR: %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*" >&2; }

configure_runtime_paths() {
    [[ "${SOFTWARE_VERSION}" == 2.5.0 ]] || { log_message "ERROR: unsupported version: ${SOFTWARE_VERSION}"; return 10; }
    [[ "${PERF_VARIANT}" == base || "${PERF_VARIANT}" == optimized ]] || return 10
    [[ "${EXPECTED_ARCH}" == "$(uname -m)" ]] || { log_message 'ERROR: runner architecture differs'; return 20; }
    PERF_RUN_ID="${PERF_RUN_ID:-local-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || return 10
    PERF_WORK_DIR="${PERF_WORK_DIR:-/home/runner/boostkit-perf/kafka/local-${PERF_RUN_ID}}"
    RESULTS_DIR="${RESULTS_DIR:-${CASE_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}}"
    [[ "${RESULTS_DIR}" == /* ]] || RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${PERF_WORK_DIR}/actual-version.txt}"
    KAFKA_HOME="${PERF_WORK_DIR}/kafka_2.12-${SOFTWARE_VERSION}"
    ZOOKEEPER_HOME="${PERF_WORK_DIR}/apache-zookeeper-3.6.2-bin"
    KAFKA_CONTAINER_NAME="boostkit-kafka-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    KAFKA_IMAGE_FILE="${PERF_WORK_DIR}/container-image.txt"
    local checksum
    checksum="$(printf '%s' "${PERF_RUN_ID}" | cksum)"
    KAFKA_PORT="$((20000 + ${checksum%% *} % 20000))"
    ZOOKEEPER_PORT="$((KAFKA_PORT + 1))"
    export PERF_WORK_DIR RESULTS_DIR PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}/tmp" "${RESULTS_DIR}"
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
        log_message 'ERROR: accessible Docker daemon is required'; return 30;
    }
}

kafka_exec() {
    docker exec -e "HOME=${PERF_WORK_DIR}" -e "TMPDIR=${PERF_WORK_DIR}/tmp" \
        -e "KAFKA_HEAP_OPTS=${KAFKA_TOOLS_HEAP_OPTS:--Xmx4096M}" \
        "${KAFKA_CONTAINER_NAME}" "$@"
}

kafka_exec_root() {
    local -a proxy=()
    [[ -z "${PERF_PROXY:-}" ]] || proxy=(--setopt="proxy=${PERF_PROXY}")
    docker exec --user 0 "${KAFKA_CONTAINER_NAME}" dnf "${proxy[@]}" "$@"
}

check_container() {
    [[ "$(docker inspect --format '{{.State.Running}}' "${KAFKA_CONTAINER_NAME}" 2>/dev/null)" == true ]] || {
        log_message "ERROR: managed container is not running: ${KAFKA_CONTAINER_NAME}"; return 40;
    }
}
