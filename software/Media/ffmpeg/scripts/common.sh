#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="ffmpeg"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-7.1.1}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

FFMPEG_SOURCE_URL="${FFMPEG_SOURCE_URL:-https://ffmpeg.org/releases/ffmpeg-${SOFTWARE_VERSION}.tar.gz}"
FFMPEG_ARCHIVE_SHA256="${FFMPEG_ARCHIVE_SHA256:-9a6e57a446b671012612aaeb9df5126794d5ac8f2015ca220934f99a6a4e0601}"
FFMPEG_ARCHIVE_NAME="ffmpeg-${SOFTWARE_VERSION}.tar.gz"
FFMPEG_ARCHIVE_DIR="${FFMPEG_ARCHIVE_DIR:-/home/runner/software/ffmpeg}"
FFMPEG_VIDEO_DIR="${FFMPEG_VIDEO_DIR:-/home/runner/software/ffmpeg/video}"
FFMPEG_IMAGE_ARCHIVE_DIR="${FFMPEG_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
FFMPEG_CA_ANCHORS_DIR="${FFMPEG_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
FFMPEG_CONTAINER_IMAGE_OVERRIDE="${FFMPEG_CONTAINER_IMAGE:-}"
FFMPEG_CONTAINER_IMAGE=""
FFMPEG_CONTAINER_NAME=""

FFMPEG_VIDEO_BQ="BQTerrace_1920x1080_60-dianbo.yuv"
FFMPEG_VIDEO_FILM="Film2012_1920x1080_25_8bit_8Mbps.yuv"
FFMPEG_VIDEO_MESSI="messi_1920x1080_25_1000.yuv"
FFMPEG_VIDEO_BQ_SHA256="5677e7ef3806d99d899d80157d69a1b875d99b089ce62a781c4f2ac6ea4d07a7"
FFMPEG_VIDEO_FILM_SHA256="27d9bc94719516e6224efa0a46abbd64c53c610b7a802ef83b045260d006a1fc"
FFMPEG_VIDEO_MESSI_SHA256="1097fcd4c6590e9affa93be5ed0b679f4d8c1366bdfa29381fa594f54b253c1b"

FFMPEG_FRAMES=30
FFMPEG_WIDTH=640
FFMPEG_HEIGHT=360
FFMPEG_PIXEL_FORMAT="rgb24"
FFMPEG_WARMUP_ITERATIONS=1
FFMPEG_ITERATIONS=20
FFMPEG_THREADS=1

FFMPEG_SOURCE_DIR=""
FFMPEG_INSTALL_DIR=""
FFMPEG_CLIPS_DIR=""
FFMPEG_EVIDENCE_DIR=""
FFMPEG_CSV_PATH=""
FFMPEG_RAW_LOG=""
FFMPEG_CONTAINER_IMAGE_FILE=""
FFMPEG_SOURCE_ARCHIVE=""
FFMPEG_SOURCE_ARCHIVE_SHA256_FILE=""

STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log() { printf '[ffmpeg] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

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

resolve_ffmpeg_video_dir() {
    local dir file ok
    for dir in "${FFMPEG_VIDEO_DIR}" "/home/runner/software/x264/video" "/home/test/Test/video"; do
        [[ -d "${dir}" ]] || continue
        ok=1
        for file in "${FFMPEG_VIDEO_BQ}" "${FFMPEG_VIDEO_FILM}" "${FFMPEG_VIDEO_MESSI}"; do
            [[ -f "${dir}/${file}" ]] || { ok=0; break; }
        done
        if (( ok == 1 )); then
            printf '%s\n' "${dir}"
            return 0
        fi
    done
    printf '%s\n' "${FFMPEG_VIDEO_DIR}"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/ffmpeg/local-${PERF_RUN_ID}"
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
    [[ "${FFMPEG_VIDEO_DIR}" == /* ]] || FFMPEG_VIDEO_DIR="$(pwd -P)/${FFMPEG_VIDEO_DIR}"
    [[ "${FFMPEG_ARCHIVE_DIR}" == /* ]] || FFMPEG_ARCHIVE_DIR="$(pwd -P)/${FFMPEG_ARCHIVE_DIR}"
    FFMPEG_VIDEO_DIR="$(resolve_ffmpeg_video_dir)"
    FFMPEG_SOURCE_DIR="${PERF_WORK_DIR}/ffmpeg-src"
    FFMPEG_INSTALL_DIR="${PERF_WORK_DIR}/ffmpeg-install"
    FFMPEG_CLIPS_DIR="${PERF_WORK_DIR}/clips"
    FFMPEG_EVIDENCE_DIR="${RESULTS_DIR}/benchmark_evidence"
    FFMPEG_CSV_PATH="${RESULTS_DIR}/result_bench-ffmpeg.csv"
    FFMPEG_RAW_LOG="${RESULTS_DIR}/benchmark_raw.log"
    FFMPEG_SOURCE_ARCHIVE="${PERF_WORK_DIR}/${FFMPEG_ARCHIVE_NAME}"
    FFMPEG_SOURCE_ARCHIVE_SHA256_FILE="${PERF_WORK_DIR}/ffmpeg-source.sha256"
    FFMPEG_CONTAINER_IMAGE_FILE="${PERF_WORK_DIR}/container-image.txt"
    FFMPEG_CONTAINER_NAME="boostkit-ffmpeg-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID
    export PERF_WORK_DIR RESULTS_DIR PERF_ACTUAL_VERSION_FILE
    export FFMPEG_SOURCE_DIR FFMPEG_INSTALL_DIR FFMPEG_CLIPS_DIR
    export FFMPEG_EVIDENCE_DIR FFMPEG_CSV_PATH FFMPEG_RAW_LOG
    export FFMPEG_VIDEO_DIR FFMPEG_CONTAINER_NAME
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${PERF_WORK_DIR}/tmp" \
        "${PERF_WORK_DIR}/home" "${FFMPEG_SOURCE_DIR}" "${FFMPEG_INSTALL_DIR}" \
        "${FFMPEG_CLIPS_DIR}" "${FFMPEG_EVIDENCE_DIR}"
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
        log 'ERROR: an accessible Docker daemon is required for the FFmpeg container'
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

verify_ffmpeg_image_release() {
    local release
    release="$(docker run --rm --network=none "${FFMPEG_CONTAINER_IMAGE}" cat /etc/os-release)" || return 30
    if ! grep -Eq '^ID="?openEuler"?$' <<< "${release}" || \
       ! grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}"; then
        log 'ERROR: loaded image is not openEuler 24.03 LTS SP4'
        return 30
    fi
}

verify_ffmpeg_image_arch() {
    local image_architecture
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${FFMPEG_CONTAINER_IMAGE}")" || return 30
    case "${EXPECTED_ARCH}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log "ERROR: image architecture ${image_architecture} differs from ${EXPECTED_ARCH}"; return 30 ;;
    esac
}

prepare_ffmpeg_container_image() {
    local archive_name="openEuler-docker.${EXPECTED_ARCH}.tar.xz"
    local image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${archive_name}"
    local archive checksum expected actual load_output
    if [[ -n "${FFMPEG_CONTAINER_IMAGE_OVERRIDE}" ]]; then
        FFMPEG_CONTAINER_IMAGE="${FFMPEG_CONTAINER_IMAGE_OVERRIDE}"
        log "using preloaded container image: ${FFMPEG_CONTAINER_IMAGE}"
        docker image inspect "${FFMPEG_CONTAINER_IMAGE}" >/dev/null 2>&1 || {
            log 'ERROR: requested preloaded container image does not exist'; return 30;
        }
        verify_ffmpeg_image_arch || return $?
        verify_ffmpeg_image_release || return $?
        return 0
    fi
    if [[ -s "${FFMPEG_IMAGE_ARCHIVE_DIR}/${archive_name}" ]]; then
        archive="${FFMPEG_IMAGE_ARCHIVE_DIR}/${archive_name}"
        log "using local openEuler image archive: ${archive}"
    else
        archive="${PERF_WORK_DIR}/${archive_name}"
        log "downloading openEuler image archive: ${image_url}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -- "${archive}.part" "${archive}" || return 30
    fi
    if [[ -s "${FFMPEG_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum" ]]; then
        checksum="${FFMPEG_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum"
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
    FFMPEG_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    [[ -n "${FFMPEG_CONTAINER_IMAGE}" ]] && docker image inspect "${FFMPEG_CONTAINER_IMAGE}" >/dev/null 2>&1 || {
        log 'ERROR: Docker did not load an inspectable image'; return 30;
    }
    verify_ffmpeg_image_arch || return $?
    verify_ffmpeg_image_release || return $?
}

require_ffmpeg_container() {
    local -a cert_mount=()
    require_docker || return $?
    if docker container inspect "${FFMPEG_CONTAINER_NAME}" >/dev/null 2>&1; then
        log "ERROR: refusing to reuse existing container: ${FFMPEG_CONTAINER_NAME}"
        return 40
    fi
    prepare_ffmpeg_container_image || return $?
    if [[ -n "${PERF_PROXY:-}" ]]; then
        [[ -d "${FFMPEG_CA_ANCHORS_DIR}" ]] || {
            log "ERROR: proxy CA directory is missing: ${FFMPEG_CA_ANCHORS_DIR}"; return 30;
        }
        cert_mount+=(--mount "type=bind,source=${FFMPEG_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    log "starting private FFmpeg container ${FFMPEG_CONTAINER_NAME} (no CPU, memory or NUMA limit)"
    docker run --detach --name "${FFMPEG_CONTAINER_NAME}" \
        --label "boostkit.ffmpeg.run-id=${PERF_RUN_ID}" \
        --network=host --user "$(id -u):$(id -g)" \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR},readonly" \
        --mount "type=bind,source=${FFMPEG_VIDEO_DIR},target=${FFMPEG_VIDEO_DIR},readonly" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" \
        "${FFMPEG_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec --user 0 "${FFMPEG_CONTAINER_NAME}" update-ca-trust extract || return 30
    fi
    if docker exec --user 0 "${FFMPEG_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        docker exec --user 0 "${FFMPEG_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || return 30
    fi
}

check_ffmpeg_container() {
    [[ "$(docker inspect --format '{{.State.Running}}' "${FFMPEG_CONTAINER_NAME}" 2>/dev/null)" == true ]] || {
        log "ERROR: managed FFmpeg container is not running: ${FFMPEG_CONTAINER_NAME}"
        return 40
    }
    [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.ffmpeg.run-id"}}' "${FFMPEG_CONTAINER_NAME}")" == "${PERF_RUN_ID}" ]] || {
        log 'ERROR: FFmpeg container label does not belong to this task'
        return 40
    }
}

container_exec() {
    local -a proxy=()
    if [[ -n "${PERF_PROXY:-}" ]]; then
        proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}")
    fi
    docker exec "${proxy[@]}" -e "TMPDIR=${PERF_WORK_DIR}/tmp" \
        -e "HOME=${PERF_WORK_DIR}/home" "${FFMPEG_CONTAINER_NAME}" "$@"
}

container_exec_root() {
    docker exec --user 0 -e "TMPDIR=${PERF_WORK_DIR}/tmp" "${FFMPEG_CONTAINER_NAME}" "$@"
}

remove_ffmpeg_container() {
    if ! docker container inspect "${FFMPEG_CONTAINER_NAME}" >/dev/null 2>&1; then
        return 0
    fi
    [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.ffmpeg.run-id"}}' "${FFMPEG_CONTAINER_NAME}" 2>/dev/null || true)" == "${PERF_RUN_ID}" ]] || {
        log 'ERROR: refusing to remove a container without this task label'
        return 70
    }
    docker stop --time 30 "${FFMPEG_CONTAINER_NAME}" >/dev/null || return 70
    docker rm "${FFMPEG_CONTAINER_NAME}" >/dev/null || return 70
    log "removed managed FFmpeg container ${FFMPEG_CONTAINER_NAME}"
}
