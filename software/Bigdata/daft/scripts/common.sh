#!/usr/bin/env bash
if [[ "${DAFT_COMMON_LOADED:-0}" == 1 ]]; then return 0; fi
DAFT_COMMON_LOADED=1
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-0.7.2}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
DAFT_DATA_ROOT="${DAFT_DATA_ROOT:-/home/runner/software/daft/tpch-data}"
DAFT_IMAGE_ARCHIVE_DIR="${DAFT_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
DAFT_CA_ANCHORS_DIR="${DAFT_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
DAFT_WHEEL_DIR="${DAFT_WHEEL_DIR:-/home/runner/software/daft/wheels}"
DAFT_SOURCE_URL="${DAFT_SOURCE_URL:-https://github.com/Eventual-Inc/Daft.git}"
DAFT_SF="${DAFT_SF:-100}"
DAFT_ROUNDS="${DAFT_ROUNDS:-4}"
DAFT_PREPARE_DATA=0

log() { printf '[daft] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }
normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}
validate_variant() {
    case "${PERF_VARIANT}" in base|optimized) ;; *) log "ERROR: invalid variant ${PERF_VARIANT}"; return 10 ;; esac
}
configure_runtime_paths() {
    validate_variant || return $?
    [[ "${SOFTWARE_VERSION}" == 0.7.2 ]] || { log 'ERROR: only Daft 0.7.2 is supported'; return 10; }
    [[ "${DAFT_SF}" =~ ^[1-9][0-9]*$ && "${DAFT_ROUNDS}" =~ ^[0-9]+$ ]] &&
        (( DAFT_ROUNDS >= 2 )) || {
        log 'ERROR: DAFT_SF must be a positive integer and DAFT_ROUNDS at least 2'; return 10;
    }
    [[ "${DAFT_DATA_ROOT}" == /home/runner/software/daft/* ]] || {
        log 'ERROR: DAFT_DATA_ROOT must be under /home/runner/software/daft'; return 10;
    }
    EXPECTED_ARCH="$(normalize_arch "${EXPECTED_ARCH}")"
    [[ "${EXPECTED_ARCH}" == x86_64 || "${EXPECTED_ARCH}" == aarch64 ]] || return 10
    PERF_RUN_ID="${PERF_RUN_ID:-local-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || return 10
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/daft/local-${PERF_RUN_ID}"
    fi
    [[ "${PERF_WORK_DIR}" == /home/runner/boostkit-perf/daft/* ]] || {
        log 'ERROR: work directory must be a private Daft subdirectory'; return 10;
    }
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    DAFT_CONTAINER_NAME="boostkit-daft-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    DAFT_VENV="${PERF_WORK_DIR}/venv"
    DAFT_SOURCE="${PERF_WORK_DIR}/daft-source"
    DAFT_PARQUET="${DAFT_DATA_ROOT}/${DAFT_SF}_0/${DAFT_SF}/parquet"
    DAFT_MANIFEST="${DAFT_PARQUET}.sha256"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    TMPDIR="${PERF_WORK_DIR}/tmp"
    export SOFTWARE_VERSION PERF_VARIANT EXPECTED_ARCH PERF_RUN_ID PERF_WORK_DIR RESULTS_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR DAFT_DATA_ROOT DAFT_SF DAFT_ROUNDS
}
initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}" "${TMPDIR}" "${DAFT_DATA_ROOT}"
}
with_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else "$@"; fi
}
require_docker() {
    command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1 || {
        log 'ERROR: accessible Docker daemon is required'; return 30;
    }
}
prepare_image() {
    local archive_name="openEuler-docker.${EXPECTED_ARCH}.tar.xz" archive checksum expected actual loaded arch release
    local url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${archive_name}"
    archive="${DAFT_IMAGE_ARCHIVE_DIR}/${archive_name}"
    if [[ ! -s "${archive}" ]]; then
        archive="${PERF_WORK_DIR}/${archive_name}"
        with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}" "${url}" || return 30
    fi
    checksum="${DAFT_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum"
    if [[ ! -s "${checksum}" ]]; then
        checksum="${PERF_WORK_DIR}/${archive_name}.sha256sum"
        with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${url}.sha256sum" || return 30
    fi
    expected="$(awk 'NR==1 {print $1}' "${checksum}")"
    [[ "${expected}" =~ ^[[:xdigit:]]{64}$ ]] || return 30
    actual="$(sha256sum "${archive}")"
    [[ "${actual%% *}" == "${expected,,}" ]] || { log 'ERROR: container image checksum mismatch'; return 30; }
    loaded="$(docker load --input "${archive}")" || return 30
    DAFT_CONTAINER_IMAGE="$(sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' <<< "${loaded}" | tail -1)"
    [[ -n "${DAFT_CONTAINER_IMAGE}" ]] || return 30
    arch="$(docker image inspect --format '{{.Architecture}}' "${DAFT_CONTAINER_IMAGE}")" || return 30
    case "${EXPECTED_ARCH}:${arch}" in x86_64:amd64|aarch64:arm64) ;; *) log "ERROR: image architecture ${arch} differs"; return 30 ;; esac
    release="$(docker run --rm --network=none "${DAFT_CONTAINER_IMAGE}" cat /etc/os-release)" || return 30
    grep -Eq '^ID="?openEuler"?$' <<< "${release}" || return 30
    grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}" || return 30
}
start_container() {
    local -a mounts=()
    require_docker || return $?
    if docker container inspect "${DAFT_CONTAINER_NAME}" >/dev/null 2>&1; then
        log "ERROR: refusing to reuse ${DAFT_CONTAINER_NAME}"; return 40
    fi
    prepare_image || return $?
    if [[ -n "${PERF_PROXY:-}" ]]; then
        [[ -d "${DAFT_CA_ANCHORS_DIR}" ]] || { log 'ERROR: proxy CA anchors missing'; return 30; }
        mounts+=(--mount "type=bind,source=${DAFT_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    if [[ -d "${DAFT_WHEEL_DIR}/${EXPECTED_ARCH}" ]]; then
        mounts+=(--mount "type=bind,source=${DAFT_WHEEL_DIR}/${EXPECTED_ARCH},target=${DAFT_WHEEL_DIR}/${EXPECTED_ARCH},readonly")
    fi
    docker run --detach --name "${DAFT_CONTAINER_NAME}" \
        --label "boostkit.daft.run-id=${PERF_RUN_ID}" --network=host \
        --user "$(id -u):$(id -g)" \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${DAFT_DATA_ROOT},target=${DAFT_DATA_ROOT}$( [[ "${DAFT_PREPARE_DATA}" == 1 ]] || printf ',readonly')" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${mounts[@]}" "${DAFT_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec --user 0 "${DAFT_CONTAINER_NAME}" update-ca-trust extract || return 30
    fi
    docker exec --user 0 "${DAFT_CONTAINER_NAME}" sed -i \
        -e '/^meta/ s/^\(.*\)$/#\1/g' \
        -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
        /etc/yum.repos.d/openEuler.repo || return 30
}
container_exec() {
    local -a proxy=()
    if [[ -n "${PERF_PROXY:-}" ]]; then
        proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}")
    fi
    docker exec "${proxy[@]}" -e "HOME=${PERF_WORK_DIR}" -e "TMPDIR=${TMPDIR}" \
        "${DAFT_CONTAINER_NAME}" "$@"
}
container_exec_clean() {
    docker exec -e "HOME=${PERF_WORK_DIR}" -e "TMPDIR=${TMPDIR}" \
        "${DAFT_CONTAINER_NAME}" "$@"
}
check_container() {
    [[ "$(docker inspect --format '{{.State.Running}}' "${DAFT_CONTAINER_NAME}" 2>/dev/null)" == true ]] || {
        log "ERROR: private container is not running: ${DAFT_CONTAINER_NAME}"; return 40;
    }
}
remove_container() {
    docker container inspect "${DAFT_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.daft.run-id"}}' "${DAFT_CONTAINER_NAME}")" == "${PERF_RUN_ID}" ]] || {
        log 'ERROR: refusing to remove another task container'; return 70;
    }
    docker stop --time 30 "${DAFT_CONTAINER_NAME}" >/dev/null || return 70
    docker rm "${DAFT_CONTAINER_NAME}" >/dev/null || return 70
}
