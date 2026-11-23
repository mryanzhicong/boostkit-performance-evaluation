#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="opus"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.6.1}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

OPUS_SOURCE_URL="${OPUS_SOURCE_URL:-https://downloads.xiph.org/releases/opus/opus-${SOFTWARE_VERSION}.tar.gz}"
OPUS_ARCHIVE_NAME="opus-${SOFTWARE_VERSION}.tar.gz"
OPUS_ARCHIVE_SHA256="6ffcb593207be92584df15b32466ed64bbec99109f007c82205f0194572411a1"
OPUS_ASSET_DIR="${OPUS_ASSET_DIR:-/home/runner/software/opus}"
OPUS_AUDIO_DIR="${OPUS_AUDIO_DIR:-${OPUS_ASSET_DIR}/audio}"
OPUS_REFERENCE_DIR="${OPUS_REFERENCE_DIR:-${SCRIPT_DIR}/scripts/reference}"
OPUS_IMAGE_ARCHIVE_DIR="${OPUS_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
OPUS_CA_ANCHORS_DIR="${OPUS_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
OPUS_CONTAINER_IMAGE_OVERRIDE="${OPUS_CONTAINER_IMAGE:-}"
OPUS_CONTAINER_IMAGE=""
OPUS_CONTAINER_NAME=""

OPUS_AUDIO_NAME="speech_orig"
OPUS_AUDIO_FILE="${OPUS_AUDIO_DIR}/${OPUS_AUDIO_NAME}.wav"
OPUS_AUDIO_SECONDS="10.8"
OPUS_FRAMES=518400
OPUS_ITERATIONS=20

OPUS_WORK_SCRIPTS=""
OPUS_SOURCE_DIR=""
OPUS_BUILD_DIR=""
OPUS_DEMO=""
OPUS_CSV_PATH=""
OPUS_CONTAINER_CSV=""
OPUS_CONTAINER_EVIDENCE=""
OPUS_EVIDENCE_DIR=""
OPUS_RAW_LOG=""
OPUS_CONTAINER_IMAGE_FILE=""

STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log() { printf '[opus] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

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
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/opus/local-${PERF_RUN_ID}"
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
    [[ "${OPUS_ASSET_DIR}" == /* ]] || OPUS_ASSET_DIR="$(pwd -P)/${OPUS_ASSET_DIR}"
    [[ "${OPUS_AUDIO_DIR}" == /* ]] || OPUS_AUDIO_DIR="$(pwd -P)/${OPUS_AUDIO_DIR}"
    OPUS_WORK_SCRIPTS="${PERF_WORK_DIR}/scripts"
    OPUS_SOURCE_DIR="${PERF_WORK_DIR}/opus-${SOFTWARE_VERSION}"
    OPUS_BUILD_DIR="${OPUS_SOURCE_DIR}/build-fixed-auto"
    OPUS_DEMO="${OPUS_BUILD_DIR}/.libs/opus_demo"
    OPUS_CONTAINER_CSV="${OPUS_WORK_SCRIPTS}/result_bench-opus.csv"
    OPUS_CONTAINER_EVIDENCE="${OPUS_WORK_SCRIPTS}/.work/evidence.json"
    OPUS_CSV_PATH="${RESULTS_DIR}/result_bench-opus.csv"
    OPUS_EVIDENCE_DIR="${RESULTS_DIR}/benchmark_evidence"
    OPUS_RAW_LOG="${RESULTS_DIR}/benchmark_raw.log"
    OPUS_CONTAINER_IMAGE_FILE="${PERF_WORK_DIR}/container-image.txt"
    OPUS_CONTAINER_NAME="boostkit-opus-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID
    export PERF_WORK_DIR RESULTS_DIR PERF_ACTUAL_VERSION_FILE
    export OPUS_ASSET_DIR OPUS_AUDIO_DIR OPUS_REFERENCE_DIR
    export OPUS_WORK_SCRIPTS OPUS_SOURCE_DIR OPUS_BUILD_DIR OPUS_DEMO
    export OPUS_CSV_PATH OPUS_CONTAINER_CSV OPUS_CONTAINER_EVIDENCE
    export OPUS_EVIDENCE_DIR OPUS_RAW_LOG OPUS_CONTAINER_NAME
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${PERF_WORK_DIR}/tmp" \
        "${PERF_WORK_DIR}/home" "${OPUS_WORK_SCRIPTS}" "${OPUS_EVIDENCE_DIR}"
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
        log 'ERROR: an accessible Docker daemon is required for the Opus container'
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

verify_opus_image_release() {
    local release
    release="$(docker run --rm --network=none "${OPUS_CONTAINER_IMAGE}" cat /etc/os-release)" || return 30
    if ! grep -Eq '^ID="?openEuler"?$' <<< "${release}" || \
       ! grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}"; then
        log 'ERROR: loaded image is not openEuler 24.03 LTS SP4'
        return 30
    fi
}

verify_opus_image_arch() {
    local image_architecture
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${OPUS_CONTAINER_IMAGE}")" || return 30
    case "${EXPECTED_ARCH}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log "ERROR: image architecture ${image_architecture} differs from ${EXPECTED_ARCH}"; return 30 ;;
    esac
}

prepare_opus_container_image() {
    local archive_name="openEuler-docker.${EXPECTED_ARCH}.tar.xz"
    local image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${archive_name}"
    local archive checksum expected actual load_output
    if [[ -n "${OPUS_CONTAINER_IMAGE_OVERRIDE}" ]]; then
        OPUS_CONTAINER_IMAGE="${OPUS_CONTAINER_IMAGE_OVERRIDE}"
        log "using preloaded container image: ${OPUS_CONTAINER_IMAGE}"
        docker image inspect "${OPUS_CONTAINER_IMAGE}" >/dev/null 2>&1 || {
            log 'ERROR: requested preloaded container image does not exist'; return 30;
        }
        verify_opus_image_arch || return $?
        verify_opus_image_release || return $?
        return 0
    fi
    if [[ -s "${OPUS_IMAGE_ARCHIVE_DIR}/${archive_name}" ]]; then
        archive="${OPUS_IMAGE_ARCHIVE_DIR}/${archive_name}"
        log "using local openEuler image archive: ${archive}"
    else
        archive="${PERF_WORK_DIR}/${archive_name}"
        log "downloading openEuler image archive: ${image_url}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -- "${archive}.part" "${archive}" || return 30
    fi
    if [[ -s "${OPUS_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum" ]]; then
        checksum="${OPUS_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum"
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
    OPUS_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    [[ -n "${OPUS_CONTAINER_IMAGE}" ]] && docker image inspect "${OPUS_CONTAINER_IMAGE}" >/dev/null 2>&1 || {
        log 'ERROR: Docker did not load an inspectable image'; return 30;
    }
    verify_opus_image_arch || return $?
    verify_opus_image_release || return $?
}

require_opus_container() {
    local -a cert_mount=()
    require_docker || return $?
    if docker container inspect "${OPUS_CONTAINER_NAME}" >/dev/null 2>&1; then
        log "ERROR: refusing to reuse existing container: ${OPUS_CONTAINER_NAME}"
        return 40
    fi
    prepare_opus_container_image || return $?
    if [[ -n "${PERF_PROXY:-}" ]]; then
        [[ -d "${OPUS_CA_ANCHORS_DIR}" ]] || {
            log "ERROR: proxy CA directory is missing: ${OPUS_CA_ANCHORS_DIR}"; return 30;
        }
        cert_mount+=(--mount "type=bind,source=${OPUS_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    log "starting private Opus container ${OPUS_CONTAINER_NAME} (no CPU, memory or NUMA limit)"
    docker run --detach --name "${OPUS_CONTAINER_NAME}" \
        --label "boostkit.opus.run-id=${PERF_RUN_ID}" \
        --network=host --user "$(id -u):$(id -g)" \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR},readonly" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" \
        "${OPUS_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec --user 0 "${OPUS_CONTAINER_NAME}" update-ca-trust extract || return 30
    fi
    if docker exec --user 0 "${OPUS_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        docker exec --user 0 "${OPUS_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || return 30
    fi
}

check_opus_container() {
    [[ "$(docker inspect --format '{{.State.Running}}' "${OPUS_CONTAINER_NAME}" 2>/dev/null)" == true ]] || {
        log "ERROR: managed Opus container is not running: ${OPUS_CONTAINER_NAME}"
        return 40
    }
    [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.opus.run-id"}}' "${OPUS_CONTAINER_NAME}")" == "${PERF_RUN_ID}" ]] || {
        log 'ERROR: Opus container label does not belong to this task'
        return 40
    }
}

container_exec() {
    local -a proxy=()
    if [[ -n "${PERF_PROXY:-}" ]]; then
        proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}")
    fi
    docker exec "${proxy[@]}" -e "TMPDIR=${PERF_WORK_DIR}/tmp" \
        -e "HOME=${PERF_WORK_DIR}/home" "${OPUS_CONTAINER_NAME}" "$@"
}

container_exec_root() {
    docker exec --user 0 -e "TMPDIR=${PERF_WORK_DIR}/tmp" "${OPUS_CONTAINER_NAME}" "$@"
}

remove_opus_container() {
    if ! docker container inspect "${OPUS_CONTAINER_NAME}" >/dev/null 2>&1; then
        return 0
    fi
    [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.opus.run-id"}}' "${OPUS_CONTAINER_NAME}" 2>/dev/null || true)" == "${PERF_RUN_ID}" ]] || {
        log 'ERROR: refusing to remove a container without this task label'
        return 70
    }
    docker stop --time 30 "${OPUS_CONTAINER_NAME}" >/dev/null || return 70
    docker rm "${OPUS_CONTAINER_NAME}" >/dev/null || return 70
    log "removed managed Opus container ${OPUS_CONTAINER_NAME}"
}
