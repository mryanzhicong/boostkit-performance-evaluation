#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JEMALLOC_VERSION=5.4.0
JEMALLOC_IMAGE_DIR=/home/runner/software/openEuler-24.03-LTS-SP4
JEMALLOC_SOURCE_DIR=/home/runner/software/jemalloc
JEMALLOC_IMAGE=""
JEMALLOC_CONTAINER=""

jemalloc_log() { printf '[jemalloc] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

jemalloc_arch() {
    case "$1" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) jemalloc_log "ERROR: unsupported architecture: $1" >&2; return 20 ;;
    esac
}

jemalloc_proxy_curl() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" curl "$@"
    else
        curl "$@"
    fi
}

jemalloc_load_image() {
    local arch="$1" work_dir="$2" archive checksum expected actual loaded image_arch release
    local archive_name="openEuler-docker.${arch}.tar.xz"
    local url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    archive="${JEMALLOC_IMAGE_DIR}/${archive_name}"
    checksum="${JEMALLOC_IMAGE_DIR}/${archive_name}.sha256sum"
    if [[ ! -s "${archive}" ]]; then
        archive="${work_dir}/${archive_name}"
        jemalloc_log "downloading openEuler image ${url}"
        jemalloc_proxy_curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${url}"
        mv -- "${archive}.part" "${archive}"
    else
        jemalloc_log "using local openEuler image ${archive}"
    fi
    if [[ ! -s "${checksum}" ]]; then
        checksum="${work_dir}/${archive_name}.sha256sum"
        jemalloc_proxy_curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${url}.sha256sum"
    fi
    expected="$(awk 'NR == 1 {print $1}' "${checksum}")"
    [[ "${expected}" =~ ^[[:xdigit:]]{64}$ ]] || { jemalloc_log 'ERROR: invalid image checksum'; return 30; }
    actual="$(sha256sum "${archive}")"
    [[ "${actual%% *}" == "${expected,,}" ]] || { jemalloc_log 'ERROR: image checksum mismatch'; return 30; }
    loaded="$(docker load --input "${archive}")"
    JEMALLOC_IMAGE="$(printf '%s\n' "${loaded}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    [[ -n "${JEMALLOC_IMAGE}" ]] && docker image inspect "${JEMALLOC_IMAGE}" >/dev/null
    image_arch="$(docker image inspect --format '{{.Architecture}}' "${JEMALLOC_IMAGE}")"
    case "${arch}:${image_arch}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) jemalloc_log "ERROR: image architecture ${image_arch} differs from ${arch}"; return 30 ;;
    esac
    release="$(docker run --rm --network=none "${JEMALLOC_IMAGE}" cat /etc/os-release)"
    grep -Eq '^ID="?openEuler"?$' <<< "${release}" &&
        grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}" || {
        jemalloc_log 'ERROR: image is not openEuler 24.03 LTS SP4'; return 30;
    }
}

jemalloc_start_container() {
    local work_dir="$1" run_id="$2"
    local -a cert_mount=()
    JEMALLOC_CONTAINER="boostkit-jemalloc-$(jemalloc_arch "$(uname -m)")-${run_id}"
    [[ "${run_id}" =~ ^[A-Za-z0-9._-]+$ ]] || { jemalloc_log 'ERROR: unsafe run ID'; return 10; }
    if docker container inspect "${JEMALLOC_CONTAINER}" >/dev/null 2>&1; then
        jemalloc_log "ERROR: refusing to reuse container ${JEMALLOC_CONTAINER}"
        return 40
    fi
    if [[ -n "${PERF_PROXY:-}" ]]; then
        [[ -d /home/runner/software/anchors ]] || { jemalloc_log 'ERROR: proxy CA anchors are missing'; return 30; }
        cert_mount+=(--mount type=bind,source=/home/runner/software/anchors,target=/etc/pki/ca-trust/source/anchors,readonly)
    fi
    docker run --detach --name "${JEMALLOC_CONTAINER}" \
        --label "boostkit.jemalloc.run-id=${run_id}" \
        --network=host --user "$(id -u):$(id -g)" \
        --mount "type=bind,source=${work_dir},target=${work_dir}" \
        "${cert_mount[@]}" "${JEMALLOC_IMAGE}" sleep infinity >/dev/null || return 40
    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec --user 0 "${JEMALLOC_CONTAINER}" update-ca-trust extract || {
            jemalloc_stop_container "${run_id}" || true
            return 30
        }
    fi
    if docker exec --user 0 "${JEMALLOC_CONTAINER}" test -f /etc/yum.repos.d/openEuler.repo; then
        docker exec --user 0 "${JEMALLOC_CONTAINER}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            jemalloc_stop_container "${run_id}" || true
            return 30
        }
    fi
}

jemalloc_existing_container() {
    local arch="$1" run_id="$2" label running
    [[ "${run_id}" =~ ^[A-Za-z0-9._-]+$ ]] || { jemalloc_log 'ERROR: unsafe run ID'; return 10; }
    JEMALLOC_CONTAINER="boostkit-jemalloc-${arch}-${run_id}"
    running="$(docker inspect --format '{{.State.Running}}' "${JEMALLOC_CONTAINER}" 2>/dev/null)" || {
        jemalloc_log "ERROR: managed container is missing: ${JEMALLOC_CONTAINER}"; return 40;
    }
    [[ "${running}" == true ]] || { jemalloc_log "ERROR: managed container is not running: ${JEMALLOC_CONTAINER}"; return 40; }
    label="$(docker inspect --format '{{index .Config.Labels "boostkit.jemalloc.run-id"}}' "${JEMALLOC_CONTAINER}")" || return 40
    [[ "${label}" == "${run_id}" ]] || { jemalloc_log "ERROR: container ownership label differs: ${JEMALLOC_CONTAINER}"; return 40; }
}

jemalloc_container_exec() {
    local -a proxy=()
    [[ -z "${PERF_PROXY:-}" ]] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}")
    docker exec "${proxy[@]}" "${JEMALLOC_CONTAINER}" "$@"
}

jemalloc_stop_container() {
    local run_id="$1" label
    [[ -n "${JEMALLOC_CONTAINER}" ]] || return 0
    docker container inspect "${JEMALLOC_CONTAINER}" >/dev/null 2>&1 || return 0
    label="$(docker inspect --format '{{index .Config.Labels "boostkit.jemalloc.run-id"}}' "${JEMALLOC_CONTAINER}")"
    [[ "${label}" == "${run_id}" ]] || { jemalloc_log 'ERROR: container ownership label differs'; return 70; }
    docker stop --time 30 "${JEMALLOC_CONTAINER}" >/dev/null
    docker rm "${JEMALLOC_CONTAINER}" >/dev/null
}
