#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="rocksdb"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-6.26.1}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
ROCKSDB_REPOSITORY="${ROCKSDB_REPOSITORY:-https://github.com/facebook/rocksdb.git}"
YCSB_REPOSITORY="${YCSB_REPOSITORY:-https://github.com/brianfrankcooper/YCSB.git}"
YCSB_REVISION="19e885f7cb780fdded0547853f7810a150554caf"
ROCKSDB_DATA_ROOT="${ROCKSDB_DATA_ROOT:-}"
ROCKSDB_IMAGE_ARCHIVE_DIR="${ROCKSDB_IMAGE_ARCHIVE_DIR:-/home/runner/software/rocksdb/openEuler-24.03-LTS-SP4}"
ROCKSDB_CONTAINER_IMAGE=""
ROCKSDB_CONTAINER_NAME=""
ROCKSDB_IMAGE_REF_FILE=""
ROCKSDB_NUMA_NODE="${ROCKSDB_NUMA_NODE:-3}"

STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

# Lifecycle paths (assigned in configure_runtime_paths).
SOURCE_DIR=""
YCSB_SOURCE_DIR=""
YCSB_DIST_DIR=""
MAVEN_REPO_DIR=""
MAVEN_SETTINGS_FILE=""
BENCH_DATA_DIR=""

log_message() {
    printf '[rocksdb] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    local runner_architecture

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
        *) EXPECTED_ARCH="${EXPECTED_ARCH,,}" ;;
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
    RESULTS_DIR="$(realpath -m -- "${RESULTS_DIR}")"
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/rocksdb/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    PERF_WORK_DIR="$(realpath -m -- "${PERF_WORK_DIR}")"
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/rocksdb/* ]]; then
        log_message "ERROR: RocksDB work directory must be task-private under /home/runner/boostkit-perf/rocksdb"
        return 20
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${ROCKSDB_DATA_ROOT}" ]]; then
        ROCKSDB_DATA_ROOT="${PERF_WORK_DIR}/data"
    fi
    ROCKSDB_DATA_ROOT="$(realpath -m -- "${ROCKSDB_DATA_ROOT}")"
    if [[ "${ROCKSDB_DATA_ROOT}" != "${PERF_WORK_DIR}/"* ]]; then
        log_message "ERROR: RocksDB data directory must be inside the task-private work directory"
        return 20
    fi
    if [[ ! "${ROCKSDB_NUMA_NODE}" =~ ^[0-9]+$ ]]; then
        log_message "ERROR: ROCKSDB_NUMA_NODE must be a non-negative NUMA node number"
        return 10
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/rocksdb-source"
    YCSB_SOURCE_DIR="${PERF_WORK_DIR}/ycsb-source"
    YCSB_DIST_DIR="${PERF_WORK_DIR}/ycsb-dist"
    MAVEN_REPO_DIR="${PERF_WORK_DIR}/maven-repository"
    MAVEN_SETTINGS_FILE="${PERF_WORK_DIR}/maven-settings.xml"
    BENCH_DATA_DIR="${ROCKSDB_DATA_ROOT}"
    ROCKSDB_IMAGE_REF_FILE="${PERF_WORK_DIR}/rocksdb-container-image-24.03-LTS-SP4.txt"
    ROCKSDB_CONTAINER_NAME="boostkit-rocksdb-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE ROCKSDB_BENCH_DATA_DIR="${BENCH_DATA_DIR}" TMPDIR
}

select_rocksdb_cpu_set() {
    python3 - "${ROCKSDB_NUMA_NODE}" <<'PY'
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

verify_rocksdb_image_release() {
    local release
    release="$(docker run --rm --network=none "${ROCKSDB_CONTAINER_IMAGE}" cat /etc/os-release)" || return 30
    if ! grep -Eq '^ID="?openEuler"?$' <<< "${release}" || \
       ! grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}"; then
        log_message "ERROR: loaded RocksDB image is not openEuler 24.03 LTS SP4"
        return 30
    fi
}

prepare_rocksdb_container_image() {
    local archive_name="openEuler-docker.${EXPECTED_ARCH}.tar.xz"
    local archive checksum expected actual load_output image_architecture
    local image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${archive_name}"

    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message "ERROR: an accessible Docker daemon is required for the RocksDB container"
        return 30
    fi
    if [[ -s "${ROCKSDB_IMAGE_REF_FILE}" ]]; then
        ROCKSDB_CONTAINER_IMAGE="$(<"${ROCKSDB_IMAGE_REF_FILE}")"
        if docker image inspect "${ROCKSDB_CONTAINER_IMAGE}" >/dev/null 2>&1; then
            verify_rocksdb_image_release || return $?
            return 0
        fi
        log_message "ERROR: recorded RocksDB image is no longer available"
        return 30
    fi
    if [[ -s "${ROCKSDB_IMAGE_ARCHIVE_DIR}/${archive_name}" ]]; then
        archive="${ROCKSDB_IMAGE_ARCHIVE_DIR}/${archive_name}"
        log_message "using local openEuler image archive: ${archive}"
    else
        archive="${PERF_WORK_DIR}/${archive_name}"
        log_message "downloading openEuler image archive: ${image_url}"
        curl -fSL --retry 3 --connect-timeout 30 -o "${archive}" "${image_url}" || return 30
    fi
    if [[ -s "${ROCKSDB_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum" ]]; then
        checksum="${ROCKSDB_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum"
    else
        checksum="${PERF_WORK_DIR}/${archive_name}.sha256sum"
        curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
    fi
    expected="$(awk 'NR == 1 {print $1}' "${checksum}")"
    if [[ ! "${expected}" =~ ^[[:xdigit:]]{64}$ ]]; then
        log_message "ERROR: invalid openEuler image checksum: ${checksum}"
        return 30
    fi
    actual="$(sha256sum "${archive}")"
    if [[ "${actual%% *}" != "${expected,,}" ]]; then
        log_message "ERROR: openEuler image checksum mismatch: ${archive}"
        return 30
    fi
    load_output="$(docker load --input "${archive}")" || return 30
    ROCKSDB_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [[ -z "${ROCKSDB_CONTAINER_IMAGE}" ]] || ! docker image inspect "${ROCKSDB_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${ROCKSDB_CONTAINER_IMAGE}")"
    case "${EXPECTED_ARCH}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${EXPECTED_ARCH}"; return 30 ;;
    esac
    verify_rocksdb_image_release || return $?
    printf '%s\n' "${ROCKSDB_CONTAINER_IMAGE}" > "${ROCKSDB_IMAGE_REF_FILE}"
    log_message "openEuler 24.03 LTS SP4 image is ready: ${ROCKSDB_CONTAINER_IMAGE}"
}

check_rocksdb_container() {
    if [[ "$(docker inspect --format '{{.State.Running}}' "${ROCKSDB_CONTAINER_NAME}" 2>/dev/null)" != true ]] || \
       [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.rocksdb.run-id"}}' "${ROCKSDB_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]]; then
        log_message "ERROR: managed RocksDB container is unavailable: ${ROCKSDB_CONTAINER_NAME}"
        return 50
    fi
}

initialize_runtime() {
    configure_runtime_paths || return $?
    if [[ -s "${PERF_WORK_DIR}/java-home.txt" ]]; then
        JAVA_HOME="$(< "${PERF_WORK_DIR}/java-home.txt")"
        if [[ ! -x "${JAVA_HOME}/bin/java" ]]; then
            log_message "ERROR: recorded JDK 11 is unavailable: ${JAVA_HOME}"
            return 30
        fi
        export JAVA_HOME PATH="${JAVA_HOME}/bin:${PATH}"
    fi
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}
