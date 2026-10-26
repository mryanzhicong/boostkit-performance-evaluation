#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-7.0.15}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
REDIS_DATA_ROOT="${REDIS_DATA_ROOT:-}"
REDIS_SOURCE_URL="${REDIS_SOURCE_URL:-https://github.com/redis/redis.git}"
REDIS_SERVICE_PORT="${REDIS_SERVICE_PORT:-}"
REDIS_BASE_PORT="${REDIS_SERVICE_PORT}"
REDIS_INSTANCE_COUNT="${REDIS_INSTANCE_COUNT:-1}"
REDIS_INSTANCE_ID=1
REDIS_NUMA_NODE="${REDIS_NUMA_NODE:-3}"
REDIS_IMAGE_ARCHIVE_DIR="${REDIS_IMAGE_ARCHIVE_DIR:-/home/runner/software/redis/openEuler-24.03-LTS-SP4}"
REDIS_CONTAINER_IMAGE=""
REDIS_CONTAINER_NAME=""
REDIS_IMAGE_REF_FILE=""
REDIS_INSTANCE_COUNT_FILE=""

SOURCE_DIR=""
REDIS_SERVER_BIN=""
REDIS_BENCHMARK_BIN=""
REDIS_CLI_BIN=""
SERVICE_DIR=""
REDIS_INSTANCES_DIR=""
PID_FILE=""
LOG_FILE=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[redis] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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

configure_redis_instance() {
    local instance_id="$1"
    if [[ ! "${instance_id}" =~ ^[1-9][0-9]*$ ]] || (( instance_id > REDIS_INSTANCE_COUNT )); then
        log_message "ERROR: Redis instance ${instance_id} is not enabled"
        return 10
    fi
    REDIS_INSTANCE_ID="${instance_id}"
    SERVICE_DIR="${REDIS_INSTANCES_DIR}/${instance_id}"
    PID_FILE="${SERVICE_DIR}/redis.pid"
    LOG_FILE="${SERVICE_DIR}/redis.log"
    REDIS_CONTAINER_NAME="boostkit-redis-${EXPECTED_ARCH}-${PERF_RUN_ID}-${instance_id}"
    REDIS_SERVICE_PORT="$((REDIS_BASE_PORT + instance_id - 1))"
}

configure_runtime_paths() {
    validate_variant || return $?
    local checksum runner_architecture

    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi

    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64)
            EXPECTED_ARCH="x86_64"
            ;;
        aarch64|arm64)
            EXPECTED_ARCH="aarch64"
            ;;
        *)
            log_message "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    runner_architecture="$(uname -m)"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/redis/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    if [[ -n "${REDIS_DATA_ROOT}" && "${REDIS_DATA_ROOT}" != "${PERF_WORK_DIR}/instances" ]]; then
        log_message "ERROR: REDIS_DATA_ROOT must be this task's instance directory: ${PERF_WORK_DIR}/instances"
        return 10
    fi
    REDIS_DATA_ROOT="${PERF_WORK_DIR}/instances"
    REDIS_INSTANCES_DIR="${REDIS_DATA_ROOT}"
    REDIS_IMAGE_REF_FILE="${PERF_WORK_DIR}/redis-container-image-24.03-LTS-SP4.txt"
    REDIS_INSTANCE_COUNT_FILE="${PERF_WORK_DIR}/redis-instance-count.txt"
    if [[ ! "${REDIS_INSTANCE_COUNT}" =~ ^[1-9][0-9]*$ ]] || (( REDIS_INSTANCE_COUNT > 128 )); then
        log_message "ERROR: REDIS_INSTANCE_COUNT must be between 1 and 128"
        return 10
    fi
    if [[ ! "${REDIS_NUMA_NODE}" =~ ^[0-9]+$ ]]; then
        log_message "ERROR: REDIS_NUMA_NODE must be a non-negative NUMA node number"
        return 10
    fi
    if [[ -z "${REDIS_BASE_PORT}" ]]; then
        checksum="$(printf '%s' "${PERF_RUN_ID}" | cksum)"
        REDIS_BASE_PORT="$((20000 + ${checksum%% *} % 20000))"
    fi
    if [[ ! "${REDIS_BASE_PORT}" =~ ^[1-9][0-9]{0,4}$ ]] || \
       (( REDIS_BASE_PORT < 1024 || REDIS_BASE_PORT + REDIS_INSTANCE_COUNT - 1 > 65535 )); then
        log_message "ERROR: REDIS_SERVICE_PORT must leave valid ports for all instances: ${REDIS_BASE_PORT}"
        return 10
    fi

    SOURCE_DIR="${PERF_WORK_DIR}/redis-source"
    REDIS_SERVER_BIN="${SOURCE_DIR}/src/redis-server"
    REDIS_BENCHMARK_BIN="${SOURCE_DIR}/src/redis-benchmark"
    REDIS_CLI_BIN="${SOURCE_DIR}/src/redis-cli"
    configure_redis_instance 1 || return $?

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE REDIS_SERVICE_PORT REDIS_DATA_ROOT REDIS_NUMA_NODE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

load_started_instance_count() {
    local started_count
    [[ -f "${REDIS_INSTANCE_COUNT_FILE}" ]] || return 0
    started_count="$(<"${REDIS_INSTANCE_COUNT_FILE}")"
    if [[ ! "${started_count}" =~ ^[1-9][0-9]*$ ]] || (( started_count > 128 )); then
        log_message "ERROR: invalid Redis instance count record: ${REDIS_INSTANCE_COUNT_FILE}"
        return 10
    fi
    REDIS_INSTANCE_COUNT="${started_count}"
}

select_redis_cpu_set() {
    python3 - "${REDIS_NUMA_NODE}" <<'PY'
import os
import sys
from pathlib import Path

node = int(sys.argv[1])
cpus = [
    cpu for cpu in sorted(os.sched_getaffinity(0))
    if (Path(f"/sys/devices/system/cpu/cpu{cpu}") / f"node{node}").exists()
]
if len(cpus) < 2:
    raise SystemExit(f"NUMA node {node} has fewer than two available CPUs")
print(",".join(map(str, cpus)), node)
PY
}

verify_redis_image_release() {
    local release
    release="$(docker run --rm --network=none "${REDIS_CONTAINER_IMAGE}" cat /etc/os-release)" || {
        log_message "ERROR: cannot read the loaded openEuler image release"
        return 30
    }
    if ! grep -Eq '^ID="?openEuler"?$' <<< "${release}" || \
       ! grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}"; then
        log_message "ERROR: loaded Redis image is not openEuler 24.03 LTS SP4"
        return 30
    fi
}

prepare_redis_container_image() {
    local archive_name="openEuler-docker.${EXPECTED_ARCH}.tar.xz"
    local archive checksum expected actual load_output image_architecture
    local image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${archive_name}"

    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message "ERROR: an accessible Docker daemon is required for Redis containers"
        return 30
    fi
    if [[ -s "${REDIS_IMAGE_REF_FILE}" ]]; then
        REDIS_CONTAINER_IMAGE="$(<"${REDIS_IMAGE_REF_FILE}")"
        if docker image inspect "${REDIS_CONTAINER_IMAGE}" >/dev/null 2>&1; then
            verify_redis_image_release || return $?
            log_message "reusing verified openEuler container image: ${REDIS_CONTAINER_IMAGE}"
            return 0
        fi
        log_message "ERROR: previously loaded Redis image is no longer available: ${REDIS_CONTAINER_IMAGE}"
        return 30
    fi
    if [[ -s "${REDIS_IMAGE_ARCHIVE_DIR}/${archive_name}" ]]; then
        archive="${REDIS_IMAGE_ARCHIVE_DIR}/${archive_name}"
        log_message "using local openEuler container image archive: ${archive}"
    else
        archive="${PERF_WORK_DIR}/${archive_name}"
        log_message "downloading openEuler container image archive: ${image_url}"
        curl -fSL --retry 3 --connect-timeout 30 -o "${archive}" "${image_url}" || return 30
    fi
    if [[ -s "${REDIS_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum" ]]; then
        checksum="${REDIS_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum"
    else
        checksum="${PERF_WORK_DIR}/${archive_name}.sha256sum"
        log_message "downloading official image checksum: ${image_url}.sha256sum"
        curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
    fi
    expected="$(awk 'NR == 1 {print $1}' "${checksum}")"
    if [[ ! "${expected}" =~ ^[[:xdigit:]]{64}$ ]]; then
        log_message "ERROR: invalid official image checksum: ${checksum}"
        return 30
    fi
    actual="$(sha256sum "${archive}")"
    if [[ "${actual%% *}" != "${expected,,}" ]]; then
        log_message "ERROR: openEuler container image checksum mismatch: ${archive}"
        return 30
    fi
    log_message "loading verified openEuler container image: ${archive}"
    load_output="$(docker load --input "${archive}")" || return 30
    REDIS_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [[ -z "${REDIS_CONTAINER_IMAGE}" ]] || ! docker image inspect "${REDIS_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${REDIS_CONTAINER_IMAGE}")"
    case "${EXPECTED_ARCH}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${EXPECTED_ARCH}"; return 30 ;;
    esac
    verify_redis_image_release || return $?
    printf '%s\n' "${REDIS_CONTAINER_IMAGE}" > "${REDIS_IMAGE_REF_FILE}"
    log_message "openEuler container image is ready: ${REDIS_CONTAINER_IMAGE} (${image_architecture})"
}

check_redis_container() {
    [[ "$(docker inspect --format '{{.State.Running}}' "${REDIS_CONTAINER_NAME}" 2>/dev/null)" == true ]] || {
        log_message "ERROR: managed Redis container is not running: ${REDIS_CONTAINER_NAME}"
        return 40
    }
}

remove_redis_container() {
    if ! docker container inspect "${REDIS_CONTAINER_NAME}" >/dev/null 2>&1; then
        return 0
    fi
    if [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.redis.run-id"}}' "${REDIS_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]]; then
        log_message "ERROR: refusing to remove container without this task's ownership label: ${REDIS_CONTAINER_NAME}"
        return 50
    fi
    docker stop --time 30 "${REDIS_CONTAINER_NAME}" >/dev/null || return 50
    docker rm "${REDIS_CONTAINER_NAME}" >/dev/null || return 50
    log_message "removed managed Redis container ${REDIS_CONTAINER_NAME}"
}
