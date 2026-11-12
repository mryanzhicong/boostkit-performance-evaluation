#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="uavs3d"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.2}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

UAVS3D_ARCHIVE_DIR="${UAVS3D_ARCHIVE_DIR:-/home/runner/software/uavs3d}"
UAVS3D_VIDEO_DIR="${UAVS3D_VIDEO_DIR:-/home/runner/software/uavs3d/video}"
UAVS3D_IMAGE_ARCHIVE_DIR="${UAVS3D_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
UAVS3D_CA_ANCHORS_DIR="${UAVS3D_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
UAVS3D_CONTAINER_IMAGE_OVERRIDE="${UAVS3D_CONTAINER_IMAGE:-}"
UAVS3D_CONTAINER_IMAGE=""
UAVS3D_CONTAINER_NAME=""

UAVS3D_VIDEO_NAME="Film2012_1920x1080_25_8bit_8Mbps.yuv"
UAVS3D_STREAM_NAME="Film2012_1080p_q32.avs3"
UAVS3D_DECODER_ARCHIVE="uavs3d-1.2.tar.gz"
UAVS3D_ENCODER_ARCHIVE="uavs3e-1.3.tar.gz"
UAVS3D_DECODER_URL="https://codeload.github.com/uavs3/uavs3d/tar.gz/refs/tags/1.2"
UAVS3D_ENCODER_URL="https://codeload.github.com/uavs3/uavs3e/tar.gz/refs/tags/v1.3"
UAVS3D_DECODER_SHA256="faa1f1f82badc0603d9944bb5af7b961dd42236e2c3a7aa8fcfc080bbeb5b157"
UAVS3D_ENCODER_SHA256="4c69ba570a8b05561cd279bebf5f403c34ddaaeb0bd66cf7da55bfb576010fc8"

UAVS3D_WIDTH=1920
UAVS3D_HEIGHT=1080
UAVS3D_FRAMES=120
UAVS3D_FPS=25
UAVS3D_QP=32
UAVS3D_THREADS=(16 24)
UAVS3D_ITERATIONS=20
UAVS3D_WARMUP_ITERATIONS=1
UAVS3D_WPP_THREADS=4
UAVS3D_FRM_THREADS=2
UAVS3D_SPEED_LEVEL=4
UAVS3D_GOP=7
UAVS3D_PRESET=0
UAVS3D_BUILD_JOBS=8

STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

# Lifecycle paths, assigned by configure_runtime_paths.
UAVS3D_SOURCE_ROOT=""
UAVS3D_DECODER_SOURCE_DIR=""
UAVS3D_ENCODER_SOURCE_DIR=""
UAVS3D_DECODER_BIN=""
UAVS3D_ENCODER_BIN=""
UAVS3D_MEDIA_DIR=""
UAVS3D_STREAM_PATH=""
UAVS3D_MANIFEST_PATH=""
UAVS3D_PREPARE_LOG=""
UAVS3D_EVIDENCE_DIR=""
UAVS3D_CSV_PATH=""
UAVS3D_CONTAINER_IMAGE_FILE=""

log() { printf '[uavs3d] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    }
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/uavs3d/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    elif [[ "${PERF_WORK_DIR}" != /* ]]; then
        log 'ERROR: PERF_WORK_DIR must be an absolute path'
        return 10
    fi
    case "${PERF_WORK_DIR}" in
        /|/home|/home/runner|/home/runner/boostkit-perf)
            log "ERROR: PERF_WORK_DIR is too broad for a private run: ${PERF_WORK_DIR}"
            return 10 ;;
    esac
    [[ "${UAVS3D_VIDEO_DIR}" == /* ]] || UAVS3D_VIDEO_DIR="$(pwd -P)/${UAVS3D_VIDEO_DIR}"
    [[ "${UAVS3D_ARCHIVE_DIR}" == /* ]] || UAVS3D_ARCHIVE_DIR="$(pwd -P)/${UAVS3D_ARCHIVE_DIR}"
    [[ "${UAVS3D_IMAGE_ARCHIVE_DIR}" == /* ]] || UAVS3D_IMAGE_ARCHIVE_DIR="$(pwd -P)/${UAVS3D_IMAGE_ARCHIVE_DIR}"
    TMPDIR="${PERF_WORK_DIR}/tmp"
    UAVS3D_SOURCE_ROOT="${PERF_WORK_DIR}/sources"
    UAVS3D_DECODER_SOURCE_DIR="${UAVS3D_SOURCE_ROOT}/uavs3d-${SOFTWARE_VERSION}"
    UAVS3D_ENCODER_SOURCE_DIR="${UAVS3D_SOURCE_ROOT}/uavs3e-1.3"
    UAVS3D_DECODER_BIN="${UAVS3D_DECODER_SOURCE_DIR}/build/uavs3dec"
    UAVS3D_ENCODER_BIN="${UAVS3D_ENCODER_SOURCE_DIR}/build/uavs3enc"
    UAVS3D_MEDIA_DIR="${PERF_WORK_DIR}/media"
    UAVS3D_STREAM_PATH="${UAVS3D_MEDIA_DIR}/${UAVS3D_STREAM_NAME}"
    UAVS3D_MANIFEST_PATH="${UAVS3D_MEDIA_DIR}/manifest.json"
    UAVS3D_PREPARE_LOG="${UAVS3D_MEDIA_DIR}/prepare_inputs.log"
    UAVS3D_EVIDENCE_DIR="${RESULTS_DIR}/decode_evidence"
    UAVS3D_CSV_PATH="${RESULTS_DIR}/result_bench-uavs3d.csv"
    UAVS3D_CONTAINER_IMAGE_FILE="${PERF_WORK_DIR}/container-image.txt"
    UAVS3D_CONTAINER_NAME="boostkit-uavs3d-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR UAVS3D_VIDEO_DIR
    export UAVS3D_CONTAINER_NAME UAVS3D_DECODER_BIN UAVS3D_ENCODER_BIN
    export UAVS3D_STREAM_PATH UAVS3D_MANIFEST_PATH UAVS3D_EVIDENCE_DIR UAVS3D_CSV_PATH
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" \
        "${PERF_WORK_DIR}/home" "${UAVS3D_SOURCE_ROOT}" "${UAVS3D_MEDIA_DIR}"
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
        log 'ERROR: an accessible Docker daemon is required for the uavs3d container'
        return 30
    fi
}

require_host_commands() {
    local command_name
    for command_name in docker curl sha256sum tar python3; do
        command -v "${command_name}" >/dev/null 2>&1 || {
            log "ERROR: required host command is missing: ${command_name}"
            return 30
        }
    done
}

verify_uavs3d_image_release() {
    local release
    release="$(docker run --rm --network=none "${UAVS3D_CONTAINER_IMAGE}" cat /etc/os-release)" || return 30
    if ! grep -Eq '^ID="?openEuler"?$' <<< "${release}" || \
       ! grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}"; then
        log 'ERROR: loaded image is not openEuler 24.03 LTS SP4'
        return 30
    fi
}

verify_uavs3d_image_arch() {
    local image_architecture
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${UAVS3D_CONTAINER_IMAGE}")" || return 30
    case "${EXPECTED_ARCH}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log "ERROR: image architecture ${image_architecture} differs from ${EXPECTED_ARCH}"; return 30 ;;
    esac
}

prepare_uavs3d_container_image() {
    local archive_name="openEuler-docker.${EXPECTED_ARCH}.tar.xz"
    local image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${archive_name}"
    local archive checksum expected actual load_output
    if [[ -n "${UAVS3D_CONTAINER_IMAGE_OVERRIDE}" ]]; then
        UAVS3D_CONTAINER_IMAGE="${UAVS3D_CONTAINER_IMAGE_OVERRIDE}"
        log "using preloaded container image: ${UAVS3D_CONTAINER_IMAGE}"
        docker image inspect "${UAVS3D_CONTAINER_IMAGE}" >/dev/null 2>&1 || {
            log 'ERROR: requested preloaded container image does not exist'; return 30;
        }
        verify_uavs3d_image_arch || return $?
        verify_uavs3d_image_release || return $?
        return 0
    fi
    if [[ -s "${UAVS3D_IMAGE_ARCHIVE_DIR}/${archive_name}" ]]; then
        archive="${UAVS3D_IMAGE_ARCHIVE_DIR}/${archive_name}"
        log "using local openEuler image archive: ${archive}"
    else
        archive="${PERF_WORK_DIR}/${archive_name}"
        log "downloading openEuler image archive: ${image_url}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -- "${archive}.part" "${archive}" || return 30
    fi
    if [[ -s "${UAVS3D_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum" ]]; then
        checksum="${UAVS3D_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum"
    else
        checksum="${PERF_WORK_DIR}/${archive_name}.sha256sum"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}.part" "${image_url}.sha256sum" || return 30
        mv -- "${checksum}.part" "${checksum}" || return 30
    fi
    expected="$(awk 'NR == 1 {print $1}' "${checksum}")"
    [[ "${expected}" =~ ^[[:xdigit:]]{64}$ ]] || { log 'ERROR: invalid image checksum'; return 30; }
    actual="$(sha256sum "${archive}")"
    [[ "${actual%% *}" == "${expected,,}" ]] || { log 'ERROR: image checksum mismatch'; return 30; }
    load_output="$(docker load --input "${archive}")" || return 30
    UAVS3D_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    [[ -n "${UAVS3D_CONTAINER_IMAGE}" ]] && docker image inspect "${UAVS3D_CONTAINER_IMAGE}" >/dev/null 2>&1 || {
        log 'ERROR: Docker did not load an inspectable image'; return 30;
    }
    verify_uavs3d_image_arch || return $?
    verify_uavs3d_image_release || return $?
    log "openEuler container image is ready: ${UAVS3D_CONTAINER_IMAGE}"
}

require_uavs3d_container() {
    local -a mount_options=()
    local -a cert_mount=()
    require_docker || return $?
    if docker container inspect "${UAVS3D_CONTAINER_NAME}" >/dev/null 2>&1; then
        log "ERROR: refusing to reuse existing container: ${UAVS3D_CONTAINER_NAME}"
        return 40
    fi
    prepare_uavs3d_container_image || return $?
    if [[ -n "${PERF_PROXY:-}" ]]; then
        [[ -d "${UAVS3D_CA_ANCHORS_DIR}" ]] || {
            log "ERROR: proxy CA directory is missing: ${UAVS3D_CA_ANCHORS_DIR}"; return 30;
        }
        cert_mount+=(--mount "type=bind,source=${UAVS3D_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mount_options+=(
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}"
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}"
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR},readonly"
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly
        --mount type=bind,source=/etc/group,target=/etc/group,readonly
    )
    if [[ -d "${UAVS3D_VIDEO_DIR}" ]]; then
        mount_options+=(--mount "type=bind,source=${UAVS3D_VIDEO_DIR},target=${UAVS3D_VIDEO_DIR},readonly")
    fi
    log "starting private uavs3d container ${UAVS3D_CONTAINER_NAME} (no CPU, memory or NUMA limit)"
    docker run --detach --name "${UAVS3D_CONTAINER_NAME}" \
        --label "boostkit.uavs3d.run-id=${PERF_RUN_ID}" \
        --network=host --user "$(id -u):$(id -g)" \
        "${mount_options[@]}" \
        "${cert_mount[@]}" \
        "${UAVS3D_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec --user 0 "${UAVS3D_CONTAINER_NAME}" update-ca-trust extract || return 30
    fi
    if docker exec --user 0 "${UAVS3D_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        docker exec --user 0 "${UAVS3D_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || return 30
    fi
}

check_uavs3d_container() {
    local label
    if [[ "$(docker inspect --format '{{.State.Running}}' "${UAVS3D_CONTAINER_NAME}" 2>/dev/null)" != true ]]; then
        log "ERROR: managed uavs3d container is not running: ${UAVS3D_CONTAINER_NAME}"
        return 40
    fi
    label="$(docker inspect --format '{{index .Config.Labels "boostkit.uavs3d.run-id"}}' "${UAVS3D_CONTAINER_NAME}")" || return 40
    if [[ "${label}" != "${PERF_RUN_ID}" ]]; then
        log "ERROR: container label does not belong to this task: ${UAVS3D_CONTAINER_NAME}"
        return 40
    fi
}

container_exec() {
    local -a proxy=()
    if [[ -n "${PERF_PROXY:-}" ]]; then
        proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}")
    fi
    docker exec "${proxy[@]}" -e "TMPDIR=${TMPDIR}" -e "HOME=${PERF_WORK_DIR}/home" \
        "${UAVS3D_CONTAINER_NAME}" "$@"
}

container_exec_root() {
    docker exec --user 0 -e "TMPDIR=${TMPDIR}" -e "HOME=${PERF_WORK_DIR}/home" \
        "${UAVS3D_CONTAINER_NAME}" "$@"
}

remove_uavs3d_container() {
    local label
    if ! docker container inspect "${UAVS3D_CONTAINER_NAME}" >/dev/null 2>&1; then
        return 0
    fi
    label="$(docker inspect --format '{{index .Config.Labels "boostkit.uavs3d.run-id"}}' "${UAVS3D_CONTAINER_NAME}" 2>/dev/null || true)"
    if [[ "${label}" != "${PERF_RUN_ID}" ]]; then
        log "ERROR: refusing to remove container without this task's label: ${UAVS3D_CONTAINER_NAME}"
        return 70
    fi
    docker stop --time 30 "${UAVS3D_CONTAINER_NAME}" >/dev/null || return 70
    docker rm "${UAVS3D_CONTAINER_NAME}" >/dev/null || return 70
    log "removed managed uavs3d container ${UAVS3D_CONTAINER_NAME}"
}
