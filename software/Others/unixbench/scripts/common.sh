#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-6.0.1}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
UNIXBENCH_ARCHIVE_DIR="${UNIXBENCH_ARCHIVE_DIR:-/home/runner/software/unixbench}"
UNIXBENCH_ARCHIVE_URL="https://github.com/kdlucas/byte-unixbench/archive/refs/tags/v6.0.1.tar.gz"
UNIXBENCH_ARCHIVE_SHA256="e52257ae9ba6294a0c5804d802745294cf536e8c8d9383aabff7a8b039e31faa"
UNIXBENCH_IMAGE_ARCHIVE_DIR="${UNIXBENCH_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
UNIXBENCH_CA_ANCHORS_DIR="${UNIXBENCH_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
UNIXBENCH_CONTAINER_IMAGE=""
UNIXBENCH_CONTAINER_NAME=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log() { printf '[unixbench] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

configure_runtime_paths() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
    PERF_RUN_ID="${PERF_RUN_ID:-local-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || { log 'ERROR: unsafe run ID'; return 10; }
    EXPECTED_ARCH="$(normalize_arch "${EXPECTED_ARCH}")"
    case "${EXPECTED_ARCH}" in
        x86_64|aarch64) ;;
        *) log "ERROR: unsupported architecture: ${EXPECTED_ARCH}"; return 10 ;;
    esac
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/unixbench/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    elif [[ "${PERF_WORK_DIR}" != /* ]]; then
        log 'ERROR: PERF_WORK_DIR must be an absolute path'
        return 10
    fi
    [[ "${PERF_WORK_DIR}" != / && "${PERF_WORK_DIR}" != /home/runner && "${PERF_WORK_DIR}" != /home/runner/boostkit-perf ]] || {
        log 'ERROR: PERF_WORK_DIR is too broad for a private run'
        return 10
    }
    TMPDIR="${PERF_WORK_DIR}/tmp"
    UB_RESULTDIR="${RESULTS_DIR}/unixbench-official"
    UB_TMPDIR="${PERF_WORK_DIR}/unixbench-tmp"
    UB_OUTPUT_FILE_NAME="unixbench-index"
    UNIXBENCH_SOURCE_DIR="${PERF_WORK_DIR}/byte-unixbench-6.0.1"
    UNIXBENCH_RUN_DIR="${UNIXBENCH_SOURCE_DIR}/UnixBench"
    UNIXBENCH_CONTAINER_NAME="boostkit-unixbench-$(normalize_arch "${EXPECTED_ARCH}")-${PERF_RUN_ID}"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR UB_RESULTDIR UB_TMPDIR UB_OUTPUT_FILE_NAME
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${UB_RESULTDIR}" "${UB_TMPDIR}"
}

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else
        "$@"
    fi
}

require_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log 'ERROR: an accessible Docker daemon is required for the UnixBench container'
        return 30
    fi
}

verify_unixbench_image_release() {
    local release
    release="$(docker run --rm --network=none "${UNIXBENCH_CONTAINER_IMAGE}" cat /etc/os-release)" || return 30
    if ! grep -Eq '^ID="?openEuler"?$' <<< "${release}" || \
       ! grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}"; then
        log 'ERROR: loaded image is not openEuler 24.03 LTS SP4'
        return 30
    fi
}

prepare_unixbench_container_image() {
    local archive_name="openEuler-docker.${EXPECTED_ARCH}.tar.xz"
    local archive checksum expected actual load_output image_architecture
    local image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${archive_name}"
    if [[ -s "${UNIXBENCH_IMAGE_ARCHIVE_DIR}/${archive_name}" ]]; then
        archive="${UNIXBENCH_IMAGE_ARCHIVE_DIR}/${archive_name}"
        log "using local openEuler image archive: ${archive}"
    else
        archive="${PERF_WORK_DIR}/${archive_name}"
        log "downloading openEuler image archive: ${image_url}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}" "${image_url}" || return 30
    fi
    if [[ -s "${UNIXBENCH_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum" ]]; then
        checksum="${UNIXBENCH_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum"
    else
        checksum="${PERF_WORK_DIR}/${archive_name}.sha256sum"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
    fi
    expected="$(awk 'NR == 1 {print $1}' "${checksum}")"
    [[ "${expected}" =~ ^[[:xdigit:]]{64}$ ]] || { log 'ERROR: invalid image checksum'; return 30; }
    actual="$(sha256sum "${archive}")"
    [[ "${actual%% *}" == "${expected,,}" ]] || { log 'ERROR: image checksum mismatch'; return 30; }
    load_output="$(docker load --input "${archive}")" || return 30
    UNIXBENCH_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    [[ -n "${UNIXBENCH_CONTAINER_IMAGE}" ]] && docker image inspect "${UNIXBENCH_CONTAINER_IMAGE}" >/dev/null 2>&1 || {
        log 'ERROR: Docker did not load an inspectable image'; return 30;
    }
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${UNIXBENCH_CONTAINER_IMAGE}")"
    case "${EXPECTED_ARCH}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log "ERROR: image architecture ${image_architecture} differs from ${EXPECTED_ARCH}"; return 30 ;;
    esac
    verify_unixbench_image_release || return $?
    log "openEuler container image is ready: ${UNIXBENCH_CONTAINER_IMAGE}"
}

require_unixbench_container() {
    local -a cert_mount=()
    require_docker || return $?
    if docker container inspect "${UNIXBENCH_CONTAINER_NAME}" >/dev/null 2>&1; then
        log "ERROR: refusing to reuse existing container: ${UNIXBENCH_CONTAINER_NAME}"
        return 40
    fi
    prepare_unixbench_container_image || return $?
    if [[ -n "${PERF_PROXY:-}" ]]; then
        [[ -d "${UNIXBENCH_CA_ANCHORS_DIR}" ]] || {
            log "ERROR: proxy CA directory is missing: ${UNIXBENCH_CA_ANCHORS_DIR}"; return 30;
        }
        cert_mount+=(--mount "type=bind,source=${UNIXBENCH_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    log "starting private UnixBench container ${UNIXBENCH_CONTAINER_NAME} (no CPU or memory limit)"
    docker run --detach --name "${UNIXBENCH_CONTAINER_NAME}" \
        --label "boostkit.unixbench.run-id=${PERF_RUN_ID}" \
        --network=host --user "$(id -u):$(id -g)" \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" \
        "${UNIXBENCH_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec --user 0 "${UNIXBENCH_CONTAINER_NAME}" update-ca-trust extract || return 30
    fi
    if docker exec --user 0 "${UNIXBENCH_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        docker exec --user 0 "${UNIXBENCH_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || return 30
    fi
}

check_unixbench_container() {
    [[ "$(docker inspect --format '{{.State.Running}}' "${UNIXBENCH_CONTAINER_NAME}" 2>/dev/null)" == true ]] || {
        log "ERROR: managed UnixBench container is not running: ${UNIXBENCH_CONTAINER_NAME}"; return 40;
    }
}

container_exec() {
    local -a proxy=()
    if [[ -n "${PERF_PROXY:-}" ]]; then
        proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}")
    fi
    docker exec "${proxy[@]}" -e "TMPDIR=${TMPDIR}" \
        -e "UB_RESULTDIR=${UB_RESULTDIR}" -e "UB_TMPDIR=${UB_TMPDIR}" \
        -e "UB_OUTPUT_FILE_NAME=${UB_OUTPUT_FILE_NAME}" \
        "${UNIXBENCH_CONTAINER_NAME}" "$@"
}

container_exec_root() {
    docker exec --user 0 "${UNIXBENCH_CONTAINER_NAME}" "$@"
}

remove_unixbench_container() {
    if ! docker container inspect "${UNIXBENCH_CONTAINER_NAME}" >/dev/null 2>&1; then
        return 0
    fi
    if [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.unixbench.run-id"}}' "${UNIXBENCH_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]]; then
        log "ERROR: refusing to remove container without this task's label: ${UNIXBENCH_CONTAINER_NAME}"
        return 70
    fi
    docker stop --time 30 "${UNIXBENCH_CONTAINER_NAME}" >/dev/null || return 70
    docker rm "${UNIXBENCH_CONTAINER_NAME}" >/dev/null || return 70
    log "removed managed UnixBench container ${UNIXBENCH_CONTAINER_NAME}"
}
