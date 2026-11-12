#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="torchvision"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-0.24.1}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

TORCH_VERSION="2.9.1"
TORCHVISION_VERSION="0.24.1"
NUMPY_VERSION="2.4.6"
PILLOW_VERSION="13.0.0"

TORCHVISION_ASSET_DIR="${TORCHVISION_ASSET_DIR:-/home/runner/software/torchvision}"
TORCHVISION_VIDEO_DIR="${TORCHVISION_VIDEO_DIR:-${TORCHVISION_ASSET_DIR}/video}"
TORCHVISION_WEIGHT_DIR="${TORCHVISION_WEIGHT_DIR:-${TORCHVISION_ASSET_DIR}/weights}"
TORCHVISION_WHEEL_DIR="${TORCHVISION_WHEEL_DIR:-${TORCHVISION_ASSET_DIR}}"
TORCHVISION_IMAGE_ARCHIVE_DIR="${TORCHVISION_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
TORCHVISION_CA_ANCHORS_DIR="${TORCHVISION_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
TORCHVISION_CONTAINER_IMAGE_OVERRIDE="${TORCHVISION_CONTAINER_IMAGE:-}"
TORCHVISION_CONTAINER_IMAGE=""
TORCHVISION_CONTAINER_NAME=""

TORCHVISION_VIDEO_BQ="BQTerrace_1920x1080_60-dianbo.yuv"
TORCHVISION_VIDEO_FILM="Film2012_1920x1080_25_8bit_8Mbps.yuv"
TORCHVISION_VIDEO_MESSI="messi_1920x1080_25_1000.yuv"
TORCHVISION_VIDEO_BQ_SHA256="5677e7ef3806d99d899d80157d69a1b875d99b089ce62a781c4f2ac6ea4d07a7"
TORCHVISION_VIDEO_FILM_SHA256="27d9bc94719516e6224efa0a46abbd64c53c610b7a802ef83b045260d006a1fc"
TORCHVISION_VIDEO_MESSI_SHA256="1097fcd4c6590e9affa93be5ed0b679f4d8c1366bdfa29381fa594f54b253c1b"

TORCHVISION_weight_v2_file="mobilenet_v2_qnnpack_37f702c5.pth"
TORCHVISION_weight_v2_url="https://download.pytorch.org/models/quantized/mobilenet_v2_qnnpack_37f702c5.pth"
TORCHVISION_weight_v2_sha256="a9225f174880dcd1a662adaa01ea71b06b6a78822d3a4a5a4bd2d4ee5709a8da"
TORCHVISION_weight_v3_file="mobilenet_v3_large_qnnpack-5bcacf28.pth"
TORCHVISION_weight_v3_url="https://download.pytorch.org/models/quantized/mobilenet_v3_large_qnnpack-5bcacf28.pth"
TORCHVISION_weight_v3_sha256="5bcacf2876b29c80e6ef777b76ae2a9cbde265af9b51e287c9b7f04a38cb53b1"

TORCHVISION_MODEL_V2="mobilenet_v2"
TORCHVISION_MODEL_V3="mobilenet_v3_large"
TORCHVISION_THREADS=1
TORCHVISION_WARMUP_ITERATIONS=3
TORCHVISION_ITERATIONS=20
TORCHVISION_BATCH_SIZE=1
TORCHVISION_INPUT_SIZE=224

STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

# Lifecycle paths, assigned by configure_runtime_paths.
TORCHVISION_DEPS_DIR=""
TORCHVISION_WHEEL_CACHE=""
TORCHVISION_TORCH_HOME=""
TORCHVISION_TORCH_WHEEL=""
TORCHVISION_TORCH_WHEEL_URL=""
TORCHVISION_EVIDENCE_DIR=""
TORCHVISION_CSV_PATH=""
TORCHVISION_CONTAINER_IMAGE_FILE=""

log() { printf '[torchvision] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

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
        PERF_WORK_DIR="/home/runner/boostkit-perf/torchvision/local-${PERF_RUN_ID}"
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
    [[ "${TORCHVISION_VIDEO_DIR}" == /* ]] || TORCHVISION_VIDEO_DIR="$(pwd -P)/${TORCHVISION_VIDEO_DIR}"
    [[ "${TORCHVISION_WEIGHT_DIR}" == /* ]] || TORCHVISION_WEIGHT_DIR="$(pwd -P)/${TORCHVISION_WEIGHT_DIR}"
    [[ "${TORCHVISION_IMAGE_ARCHIVE_DIR}" == /* ]] || TORCHVISION_IMAGE_ARCHIVE_DIR="$(pwd -P)/${TORCHVISION_IMAGE_ARCHIVE_DIR}"
    TMPDIR="${PERF_WORK_DIR}/tmp"
    TORCHVISION_DEPS_DIR="${PERF_WORK_DIR}/pydeps"
    TORCHVISION_WHEEL_CACHE="${PERF_WORK_DIR}/wheels"
    TORCHVISION_TORCH_HOME="${PERF_WORK_DIR}/torch-cache"
    TORCHVISION_TORCH_WHEEL="torch-${TORCH_VERSION}+cpu-cp311-cp311-manylinux_2_28_${EXPECTED_ARCH}.whl"
    TORCHVISION_TORCH_WHEEL_URL="https://download.pytorch.org/whl/cpu/${TORCHVISION_TORCH_WHEEL/+/%2B}"
    TORCHVISION_EVIDENCE_DIR="${RESULTS_DIR}/benchmark_evidence"
    TORCHVISION_CSV_PATH="${RESULTS_DIR}/result_bench-torchvision.csv"
    TORCHVISION_CONTAINER_IMAGE_FILE="${PERF_WORK_DIR}/container-image.txt"
    TORCHVISION_CONTAINER_NAME="boostkit-torchvision-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR TORCH_VERSION TORCHVISION_VERSION
    export TORCHVISION_VIDEO_DIR TORCHVISION_WEIGHT_DIR TORCHVISION_DEPS_DIR
    export TORCHVISION_TORCH_HOME TORCHVISION_EVIDENCE_DIR TORCHVISION_CSV_PATH
    export TORCHVISION_CONTAINER_NAME
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" \
        "${PERF_WORK_DIR}/home" "${TORCHVISION_DEPS_DIR}" \
        "${TORCHVISION_WHEEL_CACHE}" "${TORCHVISION_TORCH_HOME}/hub/checkpoints"
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
        log 'ERROR: an accessible Docker daemon is required for the torchvision container'
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

verify_torchvision_image_release() {
    local release
    release="$(docker run --rm --network=none "${TORCHVISION_CONTAINER_IMAGE}" cat /etc/os-release)" || return 30
    if ! grep -Eq '^ID="?openEuler"?$' <<< "${release}" || \
       ! grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}"; then
        log 'ERROR: loaded image is not openEuler 24.03 LTS SP4'
        return 30
    fi
}

verify_torchvision_image_arch() {
    local image_architecture
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${TORCHVISION_CONTAINER_IMAGE}")" || return 30
    case "${EXPECTED_ARCH}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log "ERROR: image architecture ${image_architecture} differs from ${EXPECTED_ARCH}"; return 30 ;;
    esac
}

prepare_torchvision_container_image() {
    local archive_name="openEuler-docker.${EXPECTED_ARCH}.tar.xz"
    local image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${archive_name}"
    local archive checksum expected actual load_output
    if [[ -n "${TORCHVISION_CONTAINER_IMAGE_OVERRIDE}" ]]; then
        TORCHVISION_CONTAINER_IMAGE="${TORCHVISION_CONTAINER_IMAGE_OVERRIDE}"
        log "using preloaded container image: ${TORCHVISION_CONTAINER_IMAGE}"
        docker image inspect "${TORCHVISION_CONTAINER_IMAGE}" >/dev/null 2>&1 || {
            log 'ERROR: requested preloaded container image does not exist'; return 30;
        }
        verify_torchvision_image_arch || return $?
        verify_torchvision_image_release || return $?
        return 0
    fi
    if [[ -s "${TORCHVISION_IMAGE_ARCHIVE_DIR}/${archive_name}" ]]; then
        archive="${TORCHVISION_IMAGE_ARCHIVE_DIR}/${archive_name}"
        log "using local openEuler image archive: ${archive}"
    else
        archive="${PERF_WORK_DIR}/${archive_name}"
        log "downloading openEuler image archive: ${image_url}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -- "${archive}.part" "${archive}" || return 30
    fi
    if [[ -s "${TORCHVISION_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum" ]]; then
        checksum="${TORCHVISION_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum"
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
    TORCHVISION_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    [[ -n "${TORCHVISION_CONTAINER_IMAGE}" ]] && docker image inspect "${TORCHVISION_CONTAINER_IMAGE}" >/dev/null 2>&1 || {
        log 'ERROR: Docker did not load an inspectable image'; return 30;
    }
    verify_torchvision_image_arch || return $?
    verify_torchvision_image_release || return $?
    log "openEuler container image is ready: ${TORCHVISION_CONTAINER_IMAGE}"
}

require_torchvision_container() {
    local -a mount_options=()
    local -a cert_mount=()
    require_docker || return $?
    if docker container inspect "${TORCHVISION_CONTAINER_NAME}" >/dev/null 2>&1; then
        log "ERROR: refusing to reuse existing container: ${TORCHVISION_CONTAINER_NAME}"
        return 40
    fi
    prepare_torchvision_container_image || return $?
    if [[ -n "${PERF_PROXY:-}" ]]; then
        [[ -d "${TORCHVISION_CA_ANCHORS_DIR}" ]] || {
            log "ERROR: proxy CA directory is missing: ${TORCHVISION_CA_ANCHORS_DIR}"; return 30;
        }
        cert_mount+=(--mount "type=bind,source=${TORCHVISION_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mount_options+=(
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}"
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}"
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR},readonly"
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly
        --mount type=bind,source=/etc/group,target=/etc/group,readonly
    )
    if [[ -d "${TORCHVISION_VIDEO_DIR}" ]]; then
        mount_options+=(--mount "type=bind,source=${TORCHVISION_VIDEO_DIR},target=${TORCHVISION_VIDEO_DIR},readonly")
    fi
    if [[ -d "${TORCHVISION_WEIGHT_DIR}" ]]; then
        mount_options+=(--mount "type=bind,source=${TORCHVISION_WEIGHT_DIR},target=${TORCHVISION_WEIGHT_DIR},readonly")
    fi
    log "starting private torchvision container ${TORCHVISION_CONTAINER_NAME} (no CPU, memory or NUMA limit)"
    docker run --detach --name "${TORCHVISION_CONTAINER_NAME}" \
        --label "boostkit.torchvision.run-id=${PERF_RUN_ID}" \
        --network=host --user "$(id -u):$(id -g)" \
        "${mount_options[@]}" \
        "${cert_mount[@]}" \
        "${TORCHVISION_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec --user 0 "${TORCHVISION_CONTAINER_NAME}" update-ca-trust extract || return 30
    fi
    if docker exec --user 0 "${TORCHVISION_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        docker exec --user 0 "${TORCHVISION_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || return 30
    fi
}

check_torchvision_container() {
    local label
    if [[ "$(docker inspect --format '{{.State.Running}}' "${TORCHVISION_CONTAINER_NAME}" 2>/dev/null)" != true ]]; then
        log "ERROR: managed torchvision container is not running: ${TORCHVISION_CONTAINER_NAME}"
        return 40
    fi
    label="$(docker inspect --format '{{index .Config.Labels "boostkit.torchvision.run-id"}}' "${TORCHVISION_CONTAINER_NAME}")" || return 40
    if [[ "${label}" != "${PERF_RUN_ID}" ]]; then
        log "ERROR: container label does not belong to this task: ${TORCHVISION_CONTAINER_NAME}"
        return 40
    fi
}

container_exec() {
    local -a proxy=()
    if [[ -n "${PERF_PROXY:-}" ]]; then
        proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}")
    fi
    docker exec "${proxy[@]}" \
        -e "TMPDIR=${TMPDIR}" -e "HOME=${PERF_WORK_DIR}/home" \
        -e "PYTHONPATH=${TORCHVISION_DEPS_DIR}" \
        -e "TORCH_HOME=${TORCHVISION_TORCH_HOME}" \
        "${TORCHVISION_CONTAINER_NAME}" "$@"
}

container_exec_root() {
    docker exec --user 0 -e "TMPDIR=${TMPDIR}" -e "HOME=${PERF_WORK_DIR}/home" \
        "${TORCHVISION_CONTAINER_NAME}" "$@"
}

remove_torchvision_container() {
    local label
    if ! docker container inspect "${TORCHVISION_CONTAINER_NAME}" >/dev/null 2>&1; then
        return 0
    fi
    label="$(docker inspect --format '{{index .Config.Labels "boostkit.torchvision.run-id"}}' "${TORCHVISION_CONTAINER_NAME}" 2>/dev/null || true)"
    if [[ "${label}" != "${PERF_RUN_ID}" ]]; then
        log "ERROR: refusing to remove container without this task's label: ${TORCHVISION_CONTAINER_NAME}"
        return 70
    fi
    docker stop --time 30 "${TORCHVISION_CONTAINER_NAME}" >/dev/null || return 70
    docker rm "${TORCHVISION_CONTAINER_NAME}" >/dev/null || return 70
    log "removed managed torchvision container ${TORCHVISION_CONTAINER_NAME}"
}
