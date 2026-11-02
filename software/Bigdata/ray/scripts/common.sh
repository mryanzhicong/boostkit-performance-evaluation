#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME=ray
SOFTWARE_VERSION="${SOFTWARE_VERSION:-2.55.1}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
RAY_OFFLINE_DIR="${RAY_OFFLINE_DIR:-/home/runner/software/ray}"
RAY_IMAGE_ARCHIVE_DIR="${RAY_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
RAY_CA_ANCHORS_DIR="${RAY_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
RAY_CONTAINER_IMAGE=""
RAY_CONTAINER_NAME=""
RAY_SHUFFLE_SHA256=38bac871b718d2192e325054bb0fadaad2c29b07263c893a083e15de564c55f6
RAY_SHUFFLE_URL="https://raw.githubusercontent.com/ray-project/ray/ray-${SOFTWARE_VERSION}/release/nightly_tests/shuffle/shuffle_test.py"
RAY_NUM_CPUS=16
RAY_NUM_PARTITIONS=50
RAY_PARTITION_SIZE=80000000
RAY_OBJECT_STORE_BYTES=17179869184
RAY_WARMUP_ROUNDS=1
RAY_FORMAL_ROUNDS=7

log_message() { printf '[ray] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: unsupported build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    [[ "${SOFTWARE_VERSION}" == 2.55.1 ]] || { log_message "ERROR: unsupported Ray version: ${SOFTWARE_VERSION}"; return 10; }
    [[ "${EXPECTED_ARCH}" == "$(uname -m)" ]] || { log_message "ERROR: runner architecture is not ${EXPECTED_ARCH}"; return 20; }
    PERF_RUN_ID="${PERF_RUN_ID:-local-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || return 10
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/ray/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${PERF_WORK_DIR}/actual-version.txt}"
    TMPDIR="${PERF_WORK_DIR}/tmp"
    RAY_VENV="${PERF_WORK_DIR}/ray-venv"
    RAY_SHUFFLE_SCRIPT="${PERF_WORK_DIR}/shuffle_test.py"
    RAY_RUNNER_SCRIPT="${PERF_WORK_DIR}/run_shuffle.py"
    RAY_CONTAINER_NAME="boostkit-ray-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    export SOFTWARE_VERSION PERF_VARIANT EXPECTED_ARCH PERF_RUN_ID PERF_WORK_DIR RESULTS_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR RAY_VENV RAY_SHUFFLE_SCRIPT RAY_RUNNER_SCRIPT
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}" "${TMPDIR}"
}

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else
        "$@"
    fi
}

require_ray_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for Ray'
        return 30
    fi
}

prepare_ray_container_image() {
    local archive_name="openEuler-docker.${EXPECTED_ARCH}.tar.xz"
    local archive checksum expected actual load_output image_architecture release
    local image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${archive_name}"
    if [[ -s "${RAY_IMAGE_ARCHIVE_DIR}/${archive_name}" ]]; then
        archive="${RAY_IMAGE_ARCHIVE_DIR}/${archive_name}"
        log_message "using local openEuler image archive: ${archive}"
    else
        archive="${PERF_WORK_DIR}/${archive_name}"
        log_message "downloading openEuler image archive: ${image_url}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}" "${image_url}" || return 30
    fi
    if [[ -s "${RAY_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum" ]]; then
        checksum="${RAY_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum"
    else
        checksum="${PERF_WORK_DIR}/${archive_name}.sha256sum"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
    fi
    expected="$(awk 'NR == 1 {print $1}' "${checksum}")"
    [[ "${expected}" =~ ^[[:xdigit:]]{64}$ ]] || { log_message 'ERROR: invalid openEuler image checksum'; return 30; }
    actual="$(sha256sum "${archive}")"
    [[ "${actual%% *}" == "${expected,,}" ]] || { log_message 'ERROR: openEuler image checksum mismatch'; return 30; }
    load_output="$(docker load --input "${archive}")" || return 30
    RAY_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    [[ -n "${RAY_CONTAINER_IMAGE}" ]] && docker image inspect "${RAY_CONTAINER_IMAGE}" >/dev/null 2>&1 || {
        log_message 'ERROR: Docker did not load an inspectable image'; return 30;
    }
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${RAY_CONTAINER_IMAGE}")"
    case "${EXPECTED_ARCH}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log_message "ERROR: image architecture ${image_architecture} differs from ${EXPECTED_ARCH}"; return 30 ;;
    esac
    release="$(docker run --rm --network=none "${RAY_CONTAINER_IMAGE}" cat /etc/os-release)" || return 30
    if ! grep -Eq '^ID="?openEuler"?$' <<< "${release}" || \
       ! grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}"; then
        log_message 'ERROR: loaded image is not openEuler 24.03 LTS SP4'
        return 30
    fi
    log_message "openEuler container image is ready: ${RAY_CONTAINER_IMAGE} (${image_architecture})"
}

start_ray_container() {
    local -a cert_mount=()
    require_ray_docker || return $?
    if docker container inspect "${RAY_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse existing container: ${RAY_CONTAINER_NAME}"
        return 40
    fi
    prepare_ray_container_image || return $?
    if [[ -n "${PERF_PROXY:-}" ]]; then
        [[ -d "${RAY_CA_ANCHORS_DIR}" ]] || {
            log_message "ERROR: proxy CA directory is missing: ${RAY_CA_ANCHORS_DIR}"; return 30;
        }
        cert_mount+=(--mount "type=bind,source=${RAY_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    log_message "starting private Ray container ${RAY_CONTAINER_NAME} (single node, 20 GiB /dev/shm)"
    docker run --detach --name "${RAY_CONTAINER_NAME}" \
        --label "boostkit.ray.run-id=${PERF_RUN_ID}" \
        --network=host --shm-size=20g --user "$(id -u):$(id -g)" \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${RAY_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec --user 0 "${RAY_CONTAINER_NAME}" update-ca-trust extract || return 30
    fi
    docker exec --user 0 "${RAY_CONTAINER_NAME}" sed -i \
        -e '/^meta/ s/^\(.*\)$/#\1/g' \
        -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
        /etc/yum.repos.d/openEuler.repo || return 30
}

check_ray_container() {
    [[ "$(docker inspect --format '{{.State.Running}}' "${RAY_CONTAINER_NAME}" 2>/dev/null)" == true ]] || {
        log_message "ERROR: managed Ray container is not running: ${RAY_CONTAINER_NAME}"; return 40;
    }
}

ray_container_exec() {
    local -a proxy=()
    [[ -z "${PERF_PROXY:-}" ]] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" \
        -e no_proxy=localhost,127.0.0.1,::1)
    docker exec "${proxy[@]}" -e "TMPDIR=${TMPDIR}" -e PYTHONPATH= \
        -e "PIP_INDEX_URL=${PIP_INDEX_URL:-https://repo.huaweicloud.com/repository/pypi/simple}" \
        -e "PIP_CACHE_DIR=${PERF_WORK_DIR}/pip-cache" \
        -e "HOME=${PERF_WORK_DIR}" "${RAY_CONTAINER_NAME}" "$@"
}

ray_container_exec_root() {
    docker exec --user 0 "${RAY_CONTAINER_NAME}" "$@"
}

remove_ray_container() {
    if ! command -v docker >/dev/null 2>&1 || \
       ! docker container inspect "${RAY_CONTAINER_NAME}" >/dev/null 2>&1; then
        return 0
    fi
    if [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.ray.run-id"}}' "${RAY_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]]; then
        log_message "ERROR: refusing to remove container without this task's label: ${RAY_CONTAINER_NAME}"
        return 70
    fi
    docker stop --time 30 "${RAY_CONTAINER_NAME}" >/dev/null || return 70
    docker rm "${RAY_CONTAINER_NAME}" >/dev/null || return 70
    log_message "removed managed Ray container ${RAY_CONTAINER_NAME}"
}
