#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="dpdk"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-26.11.0}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
DPDK_IMAGE_ARCHIVE_DIR="${DPDK_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
DPDK_CA_ANCHORS_DIR="${DPDK_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
DPDK_OFFLINE_DIR="${DPDK_OFFLINE_DIR:-/home/runner/software/dpdk}"
DPDK_TARBALL_NAME="dpdk-26.11.tar.xz"
DPDK_SOURCE_URL="${DPDK_SOURCE_URL:-https://fast.dpdk.org/rel/dpdk-26.11.tar.xz}"
DPDK_EXPECTED_MD5="${DPDK_EXPECTED_MD5:-061ed6050c8d0e6c407ce0b270dd39c3}"
DPDK_MEM_MB="${DPDK_MEM_MB:-4096}"
DPDK_CONTAINER_IMAGE=""
DPDK_CONTAINER_NAME=""
DPDK_CONTAINER_LABEL="boostkit.dpdk.run-id"
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"

log() { printf '[dpdk] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

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
        *) log "ERROR: unsupported variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

configure_runtime_paths() {
    [[ "${SOFTWARE_VERSION}" == "26.11.0" ]] || {
        log "ERROR: only DPDK 26.11.0 is supported (got ${SOFTWARE_VERSION})"
        return 10
    }
    validate_variant || return $?
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/dpdk/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    elif [[ "${PERF_WORK_DIR}" != /* ]]; then
        log 'ERROR: PERF_WORK_DIR must be absolute'
        return 10
    fi
    case "${PERF_WORK_DIR}" in
        /|/tmp|/home|/home/runner|/home/runner/boostkit-perf)
            log "ERROR: PERF_WORK_DIR is too broad: ${PERF_WORK_DIR}"
            return 10
            ;;
    esac
    DPDK_HOME_DIR="${PERF_WORK_DIR}/home"
    DPDK_RUNTIME_DIR="${PERF_WORK_DIR}/run"
    DPDK_SOURCE_DIR="${PERF_WORK_DIR}/dpdk-26.11"
    DPDK_BUILD_DIR="${PERF_WORK_DIR}/build-cpu"
    DPDK_TEST_BIN="${DPDK_BUILD_DIR}/app/dpdk-test"
    DPDK_CONTAINER_NAME="boostkit-dpdk-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    DPDK_IMAGE_STATE_FILE="${PERF_WORK_DIR}/container-image.txt"
    DPDK_CPU_STATE_FILE="${PERF_WORK_DIR}/cpu-selection.json"
    DPDK_TSC_STATE_FILE="${PERF_WORK_DIR}/tsc-hz.txt"
    DPDK_SHA_STATE_FILE="${PERF_WORK_DIR}/source-sha256.txt"
    DPDK_CACHELINE_STATE_FILE="${PERF_WORK_DIR}/cache-line-size.txt"
    TMPDIR="${PERF_WORK_DIR}/tmp"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    export SOFTWARE_NAME SOFTWARE_VERSION PERF_VARIANT EXPECTED_ARCH PERF_RUN_ID
    export PERF_WORK_DIR RESULTS_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export DPDK_HOME_DIR DPDK_RUNTIME_DIR DPDK_SOURCE_DIR DPDK_BUILD_DIR DPDK_TEST_BIN
    export DPDK_CONTAINER_NAME DPDK_IMAGE_STATE_FILE DPDK_CPU_STATE_FILE
    export DPDK_TSC_STATE_FILE DPDK_SHA_STATE_FILE DPDK_CACHELINE_STATE_FILE DPDK_MEM_MB
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}" "${TMPDIR}" "${DPDK_HOME_DIR}" "${DPDK_RUNTIME_DIR}"
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
        log 'ERROR: accessible Docker daemon required'
        return 30
    }
}

prepare_dpdk_image() {
    local name="openEuler-docker.${EXPECTED_ARCH}.tar.xz"
    local url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${name}"
    local archive checksum expected actual loaded image_arch release
    if [[ -s "${DPDK_IMAGE_ARCHIVE_DIR}/${name}" ]]; then
        archive="${DPDK_IMAGE_ARCHIVE_DIR}/${name}"
    else
        archive="${PERF_WORK_DIR}/${name}"
        rm -f -- "${archive}.part"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
            -o "${archive}.part" "${url}" || { rm -f -- "${archive}.part"; return 30; }
        mv -- "${archive}.part" "${archive}" || return 30
    fi
    if [[ -s "${DPDK_IMAGE_ARCHIVE_DIR}/${name}.sha256sum" ]]; then
        checksum="${DPDK_IMAGE_ARCHIVE_DIR}/${name}.sha256sum"
    else
        checksum="${PERF_WORK_DIR}/${name}.sha256sum"
        rm -f -- "${checksum}.part"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
            -o "${checksum}.part" "${url}.sha256sum" || { rm -f -- "${checksum}.part"; return 30; }
        mv -- "${checksum}.part" "${checksum}" || return 30
    fi
    expected="$(awk 'NR==1 {print $1}' "${checksum}")"
    [[ "${expected}" =~ ^[[:xdigit:]]{64}$ ]] || { log 'ERROR: invalid image SHA-256'; return 30; }
    actual="$(sha256sum "${archive}")"
    [[ "${actual%% *}" == "${expected,,}" ]] || { log 'ERROR: image SHA-256 mismatch'; return 30; }
    loaded="$(docker load --input "${archive}")" || return 30
    DPDK_CONTAINER_IMAGE="$(printf '%s\n' "${loaded}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    [[ -n "${DPDK_CONTAINER_IMAGE}" ]] || return 30
    image_arch="$(docker image inspect --format '{{.Architecture}}' "${DPDK_CONTAINER_IMAGE}")" || return 30
    case "${EXPECTED_ARCH}:${image_arch}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log "ERROR: image architecture mismatch (${EXPECTED_ARCH} vs ${image_arch})"; return 30 ;;
    esac
    release="$(docker run --rm --network=none "${DPDK_CONTAINER_IMAGE}" cat /etc/os-release)" || return 30
    grep -Eq '^ID="?openEuler"?$' <<< "${release}" && grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}" || {
        log 'ERROR: image is not openEuler 24.03 LTS SP4'
        return 30
    }
    printf '%s\n' "${DPDK_CONTAINER_IMAGE}" > "${DPDK_IMAGE_STATE_FILE}"
    log "openEuler image ready: ${DPDK_CONTAINER_IMAGE}"
}

require_dpdk_container() {
    local -a cert_mount=() git_mount=() offline_mount=()
    require_docker || return $?
    docker container inspect "${DPDK_CONTAINER_NAME}" >/dev/null 2>&1 && {
        log "ERROR: refusing to reuse or overwrite an existing container: ${DPDK_CONTAINER_NAME}"
        return 40
    }
    prepare_dpdk_image || return $?
    if [[ -n "${PERF_PROXY:-}" ]]; then
        [[ -d "${DPDK_CA_ANCHORS_DIR}" ]] || { log 'ERROR: proxy CA anchors missing'; return 30; }
        cert_mount+=(--mount "type=bind,source=${DPDK_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    if [[ -f /home/runner/.gitconfig ]]; then
        git_mount+=(--mount type=bind,source=/home/runner/.gitconfig,target=/home/runner/.gitconfig,readonly)
    fi
    if [[ -d "${DPDK_OFFLINE_DIR}" ]]; then
        offline_mount+=(--mount "type=bind,source=${DPDK_OFFLINE_DIR},target=${DPDK_OFFLINE_DIR},readonly")
    fi
    docker run --detach --name "${DPDK_CONTAINER_NAME}" \
        --label "${DPDK_CONTAINER_LABEL}=${PERF_RUN_ID}" \
        --network=host \
        --ulimit nofile=65535:65535 \
        --user "$(id -u):$(id -g)" \
        -e "HOME=${DPDK_HOME_DIR}" \
        -e "XDG_CACHE_HOME=${DPDK_HOME_DIR}/.cache" \
        -e "XDG_RUNTIME_DIR=${DPDK_RUNTIME_DIR}" \
        -e "TMPDIR=${TMPDIR}" \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR},readonly" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${git_mount[@]}" "${offline_mount[@]}" \
        "${DPDK_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec --user 0 "${DPDK_CONTAINER_NAME}" update-ca-trust extract || return 30
    fi
    if docker exec --user 0 "${DPDK_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        docker exec --user 0 "${DPDK_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || return 30
    fi
}

check_dpdk_container() {
    local running label
    running="$(docker inspect --format '{{.State.Running}}' "${DPDK_CONTAINER_NAME}" 2>/dev/null || true)"
    [[ "${running}" == true ]] || {
        log "ERROR: managed DPDK container is not running: ${DPDK_CONTAINER_NAME}"
        return 40
    }
    label="$(docker inspect --format "{{index .Config.Labels \"${DPDK_CONTAINER_LABEL}\"}}" "${DPDK_CONTAINER_NAME}" 2>/dev/null || true)"
    [[ "${label}" == "${PERF_RUN_ID}" ]] || {
        log "ERROR: container label mismatch on ${DPDK_CONTAINER_NAME}"
        return 40
    }
}

container_exec() {
    local -a proxy=()
    if [[ -n "${PERF_PROXY:-}" ]]; then
        proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}")
    fi
    docker exec "${proxy[@]}" \
        -e "HOME=${DPDK_HOME_DIR}" \
        -e "XDG_CACHE_HOME=${DPDK_HOME_DIR}/.cache" \
        -e "XDG_RUNTIME_DIR=${DPDK_RUNTIME_DIR}" \
        -e "TMPDIR=${TMPDIR}" \
        "${DPDK_CONTAINER_NAME}" "$@"
}

container_exec_root() {
    local -a proxy=()
    [[ -z "${PERF_PROXY:-}" ]] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}")
    docker exec --user 0 "${proxy[@]}" "${DPDK_CONTAINER_NAME}" "$@"
}

remove_dpdk_container() {
    local label
    docker container inspect "${DPDK_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    label="$(docker inspect --format "{{index .Config.Labels \"${DPDK_CONTAINER_LABEL}\"}}" "${DPDK_CONTAINER_NAME}" 2>/dev/null || true)"
    [[ "${label}" == "${PERF_RUN_ID}" ]] || {
        log "ERROR: refusing to remove container without matching run label: ${DPDK_CONTAINER_NAME}"
        return 70
    }
    if [[ -n "${RESULTS_DIR:-}" && -d "${RESULTS_DIR}" ]]; then
        docker logs "${DPDK_CONTAINER_NAME}" > "${RESULTS_DIR}/container.log" 2>&1 || true
    fi
    docker stop --time 30 "${DPDK_CONTAINER_NAME}" >/dev/null || return 70
    docker rm "${DPDK_CONTAINER_NAME}" >/dev/null || return 70
}

verify_dpdk_tarball() {
    local path="$1" expected actual
    expected="${DPDK_EXPECTED_MD5,,}"
    [[ "${expected}" =~ ^[[:xdigit:]]{32}$ ]] || {
        log "ERROR: invalid expected DPDK MD5: ${DPDK_EXPECTED_MD5}"
        return 30
    }
    [[ -s "${path}" ]] || return 1
    actual="$(md5sum "${path}")"
    [[ "${actual%% *}" == "${expected}" ]] || return 1
    return 0
}

acquire_dpdk_tarball() {
    local local_archive="${DPDK_OFFLINE_DIR}/${DPDK_TARBALL_NAME}"
    local archive="${PERF_WORK_DIR}/${DPDK_TARBALL_NAME}"
    local temp_archive="${archive}.part"
    if [[ -e "${archive}" ]]; then
        if verify_dpdk_tarball "${archive}"; then
            log "using verified private DPDK tarball: ${archive}"
            return 0
        fi
        log "WARNING: removing invalid private DPDK tarball: ${archive}"
        rm -f -- "${archive}"
    fi
    rm -f -- "${temp_archive}"
    if [[ -s "${local_archive}" ]]; then
        log "checking offline DPDK tarball: ${local_archive}"
        if verify_dpdk_tarball "${local_archive}"; then
            cp -- "${local_archive}" "${temp_archive}" || { rm -f -- "${temp_archive}"; return 30; }
            verify_dpdk_tarball "${temp_archive}" || { rm -f -- "${temp_archive}"; return 30; }
            mv -- "${temp_archive}" "${archive}" || { rm -f -- "${temp_archive}"; return 30; }
            log "prepared verified DPDK tarball from offline directory: ${archive}"
            return 0
        fi
        log "WARNING: offline DPDK tarball failed MD5 verification, falling back to upstream download"
    fi
    log "downloading ${DPDK_TARBALL_NAME} from ${DPDK_SOURCE_URL}"
    with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
        -o "${temp_archive}" "${DPDK_SOURCE_URL}" || {
        rm -f -- "${temp_archive}"
        log 'ERROR: DPDK tarball download failed'
        return 30
    }
    if ! verify_dpdk_tarball "${temp_archive}"; then
        rm -f -- "${temp_archive}"
        log "ERROR: downloaded DPDK tarball failed MD5 verification (expected ${DPDK_EXPECTED_MD5})"
        return 30
    fi
    mv -- "${temp_archive}" "${archive}" || { rm -f -- "${temp_archive}"; return 30; }
    log "downloaded and verified DPDK tarball: ${archive}"
}
