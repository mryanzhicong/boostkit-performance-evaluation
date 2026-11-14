#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.38.6}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
PERF_GITHUB_DOWNLOAD_PROXY="${PERF_GITHUB_DOWNLOAD_PROXY:-}"

K6_VERSION="2.2.0"
ENVOY_OFFLINE_DIR="${ENVOY_OFFLINE_DIR:-/home/runner/software/envoy}"
ENVOY_IMAGE_ARCHIVE_DIR="${ENVOY_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
ENVOY_CA_ANCHORS_DIR="${ENVOY_CA_ANCHORS_DIR:-/home/runner/software/anchors}"

INSTALL_DIR=""
ENVOY_BIN=""
K6_BIN=""
RUNTIME_DIR=""
ENVOY_CONTAINER_IMAGE=""
ENVOY_CONTAINER_NAME=""
ENVOY_IMAGE_REF_FILE=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[envoy] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    local actual_arch expected_arch

    expected_arch="$(normalize_architecture "${EXPECTED_ARCH}")"
    case "${expected_arch}" in
        x86_64) K6_ARCH="amd64" ;;
        aarch64) K6_ARCH="arm64" ;;
        *)
            log_message "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    EXPECTED_ARCH="${expected_arch}"
    actual_arch="$(normalize_architecture "$(uname -m)")"
    [[ "${actual_arch}" == "${EXPECTED_ARCH}" ]] || {
        log_message "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${actual_arch}"
        return 20
    }

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
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/envoy/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"

    INSTALL_DIR="${PERF_WORK_DIR}/envoy-install"
    ENVOY_BIN="${INSTALL_DIR}/envoy"
    K6_BIN="${PERF_WORK_DIR}/tools/k6"
    RUNTIME_DIR="${PERF_WORK_DIR}/runtime"
    ENVOY_IMAGE_REF_FILE="${PERF_WORK_DIR}/envoy-container-image-24.03-LTS-SP4.txt"
    ENVOY_CONTAINER_NAME="boostkit-envoy-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
    export ENVOY_IMAGE_REF_FILE ENVOY_CONTAINER_NAME
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" || return 30
}

verify_envoy_image_release() {
    local release
    release="$(docker run --rm --network=none "${ENVOY_CONTAINER_IMAGE}" cat /etc/os-release)" || return 30
    if ! grep -Eq '^ID="?openEuler"?$' <<< "${release}" || \
       ! grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}"; then
        log_message "ERROR: loaded Envoy container image is not openEuler 24.03 LTS SP4"
        return 30
    fi
}

prepare_envoy_container_image() {
    local archive_name="openEuler-docker.${EXPECTED_ARCH}.tar.xz"
    local archive checksum expected actual load_output image_architecture
    local image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${archive_name}"

    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message "ERROR: an accessible Docker daemon is required for the Envoy container"
        return 30
    fi
    if [[ -s "${ENVOY_IMAGE_REF_FILE}" ]]; then
        ENVOY_CONTAINER_IMAGE="$(<"${ENVOY_IMAGE_REF_FILE}")"
        if docker image inspect "${ENVOY_CONTAINER_IMAGE}" >/dev/null 2>&1; then
            verify_envoy_image_release || return $?
            return 0
        fi
        log_message "ERROR: recorded Envoy image is no longer available"
        return 30
    fi
    if [[ -s "${ENVOY_IMAGE_ARCHIVE_DIR}/${archive_name}" ]]; then
        archive="${ENVOY_IMAGE_ARCHIVE_DIR}/${archive_name}"
        log_message "using local openEuler image archive: ${archive}"
    else
        archive="${PERF_WORK_DIR}/${archive_name}"
        log_message "downloading openEuler image archive: ${image_url}"
        curl -fSL --retry 3 --connect-timeout 30 -o "${archive}" "${image_url}" || return 30
    fi
    if [[ -s "${ENVOY_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum" ]]; then
        checksum="${ENVOY_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum"
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
    ENVOY_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [[ -z "${ENVOY_CONTAINER_IMAGE}" ]] || ! docker image inspect "${ENVOY_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${ENVOY_CONTAINER_IMAGE}")"
    case "${EXPECTED_ARCH}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${EXPECTED_ARCH}"; return 30 ;;
    esac
    verify_envoy_image_release || return $?
    printf '%s\n' "${ENVOY_CONTAINER_IMAGE}" > "${ENVOY_IMAGE_REF_FILE}"
    log_message "openEuler 24.03 LTS SP4 image is ready: ${ENVOY_CONTAINER_IMAGE}"
}

check_envoy_container() {
    command -v docker >/dev/null 2>&1 || {
        log_message "ERROR: Docker is required for the Envoy benchmark container"
        return 50
    }
    if [[ "$(docker inspect --format '{{.State.Running}}' "${ENVOY_CONTAINER_NAME}" 2>/dev/null)" != true ]] || \
       [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.envoy.run-id"}}' "${ENVOY_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]]; then
        log_message "ERROR: managed Envoy container is unavailable: ${ENVOY_CONTAINER_NAME}"
        return 50
    fi
}

remove_envoy_container() {
    local label
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${ENVOY_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    label="$(docker inspect --format '{{index .Config.Labels "boostkit.envoy.run-id"}}' "${ENVOY_CONTAINER_NAME}" 2>/dev/null)"
    if [[ "${label}" != "${PERF_RUN_ID}" ]]; then
        log_message "ERROR: refusing to remove a container that belongs to another run: ${ENVOY_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${ENVOY_CONTAINER_NAME}" >/dev/null || return 70
    docker rm "${ENVOY_CONTAINER_NAME}" >/dev/null || return 70
    log_message "removed task-private Envoy container: ${ENVOY_CONTAINER_NAME}"
}
