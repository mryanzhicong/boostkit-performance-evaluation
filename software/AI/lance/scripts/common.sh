#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-13.0.0}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
LANCE_IMAGE_ARCHIVE_DIR="${LANCE_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
LANCE_CA_ANCHORS_DIR="${LANCE_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
LANCE_DATA_ARCHIVE_DIR="${LANCE_DATA_ARCHIVE_DIR:-/home/runner/software/lance}"
LANCE_CONTAINER_IMAGE=""
LANCE_CONTAINER_NAME=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"

log() { printf '[lance] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

configure_runtime_paths() {
    [[ "${SOFTWARE_VERSION}" == 13.0.0 ]] || { log 'ERROR: only Lance 13.0.0 is supported'; return 10; }
    case "${PERF_VARIANT}" in base|optimized) ;; *) log 'ERROR: unsupported variant'; return 10 ;; esac
    PERF_RUN_ID="${PERF_RUN_ID:-local-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || { log 'ERROR: unsafe run ID'; return 10; }
    EXPECTED_ARCH="$(normalize_arch "${EXPECTED_ARCH}")"
    case "${EXPECTED_ARCH}" in x86_64|aarch64) ;; *) log 'ERROR: unsupported architecture'; return 10 ;; esac
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/lance/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    elif [[ "${PERF_WORK_DIR}" != /* ]]; then
        log 'ERROR: PERF_WORK_DIR must be absolute'; return 10
    fi
    [[ "${PERF_WORK_DIR}" != / && "${PERF_WORK_DIR}" != /home/runner && "${PERF_WORK_DIR}" != /home/runner/boostkit-perf ]] || {
        log 'ERROR: PERF_WORK_DIR is too broad'; return 10;
    }
    LANCE_SOURCE_DIR="${PERF_WORK_DIR}/lance-13.0.0"
    LANCE_VENV="${PERF_WORK_DIR}/venv"
    LANCE_DATA_DIR="${PERF_WORK_DIR}/data"
    LANCE_CONTAINER_NAME="boostkit-lance-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    TMPDIR="${PERF_WORK_DIR}/tmp"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    export SOFTWARE_VERSION PERF_VARIANT EXPECTED_ARCH PERF_RUN_ID PERF_WORK_DIR RESULTS_DIR
    export LANCE_SOURCE_DIR LANCE_VENV LANCE_DATA_DIR TMPDIR PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}" "${TMPDIR}" "${LANCE_DATA_DIR}"
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
        log 'ERROR: accessible Docker daemon required'; return 30;
    }
}

prepare_lance_image() {
    local name="openEuler-docker.${EXPECTED_ARCH}.tar.xz" archive checksum expected actual loaded image_arch release
    local url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${name}"
    if [[ -s "${LANCE_IMAGE_ARCHIVE_DIR}/${name}" ]]; then
        archive="${LANCE_IMAGE_ARCHIVE_DIR}/${name}"
    else
        archive="${PERF_WORK_DIR}/${name}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}" "${url}" || return 30
    fi
    if [[ -s "${LANCE_IMAGE_ARCHIVE_DIR}/${name}.sha256sum" ]]; then
        checksum="${LANCE_IMAGE_ARCHIVE_DIR}/${name}.sha256sum"
    else
        checksum="${PERF_WORK_DIR}/${name}.sha256sum"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${url}.sha256sum" || return 30
    fi
    expected="$(awk 'NR==1 {print $1}' "${checksum}")"
    [[ "${expected}" =~ ^[[:xdigit:]]{64}$ ]] || { log 'ERROR: invalid image SHA-256'; return 30; }
    actual="$(sha256sum "${archive}")"
    [[ "${actual%% *}" == "${expected,,}" ]] || { log 'ERROR: image SHA-256 mismatch'; return 30; }
    loaded="$(docker load --input "${archive}")" || return 30
    LANCE_CONTAINER_IMAGE="$(printf '%s\n' "${loaded}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    [[ -n "${LANCE_CONTAINER_IMAGE}" ]] || return 30
    image_arch="$(docker image inspect --format '{{.Architecture}}' "${LANCE_CONTAINER_IMAGE}")" || return 30
    case "${EXPECTED_ARCH}:${image_arch}" in x86_64:amd64|aarch64:arm64) ;; *) log 'ERROR: image architecture mismatch'; return 30 ;; esac
    release="$(docker run --rm --network=none "${LANCE_CONTAINER_IMAGE}" cat /etc/os-release)" || return 30
    grep -Eq '^ID="?openEuler"?$' <<< "${release}" && grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}" || {
        log 'ERROR: image is not openEuler 24.03 LTS SP4'; return 30;
    }
    log "openEuler image ready: ${LANCE_CONTAINER_IMAGE}"
}

require_lance_container() {
    local -a cert_mount=()
    require_docker || return $?
    docker container inspect "${LANCE_CONTAINER_NAME}" >/dev/null 2>&1 && {
        log 'ERROR: refusing to reuse an existing container'; return 40;
    }
    prepare_lance_image || return $?
    if [[ -n "${PERF_PROXY:-}" ]]; then
        [[ -d "${LANCE_CA_ANCHORS_DIR}" ]] || { log 'ERROR: proxy CA anchors missing'; return 30; }
        cert_mount+=(--mount "type=bind,source=${LANCE_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    docker run --detach --name "${LANCE_CONTAINER_NAME}" \
        --label "boostkit.lance.run-id=${PERF_RUN_ID}" --network=host \
        --user "$(id -u):$(id -g)" \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${LANCE_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec --user 0 "${LANCE_CONTAINER_NAME}" update-ca-trust extract || return 30
    fi
    if docker exec --user 0 "${LANCE_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        docker exec --user 0 "${LANCE_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || return 30
    fi
}

check_lance_container() {
    [[ "$(docker inspect --format '{{.State.Running}}' "${LANCE_CONTAINER_NAME}" 2>/dev/null)" == true ]] || {
        log 'ERROR: managed Lance container is not running'; return 40;
    }
}

container_exec() {
    local -a proxy=()
    if [[ -n "${PERF_PROXY:-}" ]]; then
        proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}")
    fi
    docker exec "${proxy[@]}" -e "TMPDIR=${TMPDIR}" \
        -e "CARGO_HOME=${PERF_WORK_DIR}/cargo" \
        -e "RUSTUP_HOME=${PERF_WORK_DIR}/rustup" \
        "${LANCE_CONTAINER_NAME}" "$@"
}

container_exec_root() {
    local -a proxy=()
    [[ -z "${PERF_PROXY:-}" ]] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}")
    docker exec --user 0 "${proxy[@]}" "${LANCE_CONTAINER_NAME}" "$@"
}

remove_lance_container() {
    docker container inspect "${LANCE_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.lance.run-id"}}' "${LANCE_CONTAINER_NAME}" 2>/dev/null)" == "${PERF_RUN_ID}" ]] || {
        log 'ERROR: refusing to remove container without this run label'; return 70;
    }
    docker stop --time 30 "${LANCE_CONTAINER_NAME}" >/dev/null || return 70
    docker rm "${LANCE_CONTAINER_NAME}" >/dev/null || return 70
}
