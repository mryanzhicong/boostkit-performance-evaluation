#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASE_DIR="${SCRIPT_DIR}"
SOFTWARE_NAME="git"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-2.56.0}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"

# Official git repository, pinned release tag and its peeled commit.
GIT_REPOSITORY="${GIT_REPOSITORY:-https://github.com/git/git.git}"
GIT_TAG="${GIT_TAG:-v2.56.0}"
GIT_COMMIT="${GIT_COMMIT:-a018953688f1b10bddf91bff8747068f5f4746a4}"
GIT_CLONE_DEPTH="${GIT_CLONE_DEPTH:-1}"

# openEuler container runtime (same base image and loading method as MySQL).
GIT_IMAGE_ARCHIVE_DIR="${GIT_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
GIT_CA_ANCHORS_DIR="${GIT_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
GIT_CONTAINER_IMAGE=""
GIT_CONTAINER_NAME=""

# Formal workload: the fixed subset of the upstream t/perf suite that runs
# on the pinned shallow checkout, with the official default best-of-5
# repeats. p0000 (harness self-test), p0001 (history traversal) and p0006
# (needs HEAD^) are excluded because a depth-1 checkout would make them
# trivial or unusable; that limitation is documented in the README.
GIT_PERF_REPEAT_COUNT="${GIT_PERF_REPEAT_COUNT:-5}"
GIT_PERF_SCRIPTS=(
    p0002-read-cache.sh
    p0003-delta-base-cache.sh
    p0004-lazy-init-name-hash.sh
    p0005-status.sh
    p0007-write-cache.sh
    p0008-odb-fsync.sh
    p0009-diff-pathspec.sh
    p0071-sort.sh
    p0090-cache-tree.sh
    p0100-globbing.sh
)

# Lifecycle paths (assigned in configure_runtime_paths).
GIT_SRC_DIR=""
GIT_BIN=""
GIT_PERF_DIR=""

log_message() { printf '[git] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    [[ "${SOFTWARE_VERSION}" == "2.56.0" ]] || {
        log_message "ERROR: unsupported git version: ${SOFTWARE_VERSION}"
        return 10
    }
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64) EXPECTED_ARCH="x86_64" ;;
        aarch64|arm64) EXPECTED_ARCH="aarch64" ;;
        *) log_message "ERROR: unsupported architecture: ${EXPECTED_ARCH}"; return 10 ;;
    esac
    [[ "${EXPECTED_ARCH}" == "$(uname -m)" ]] || {
        log_message "ERROR: runner architecture differs from ${EXPECTED_ARCH}"
        return 20
    }
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log_message 'ERROR: unsafe run ID'
        return 10
    }
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/git/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${CASE_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${CASE_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    TMPDIR="${PERF_WORK_DIR}/tmp"
    GIT_SRC_DIR="${PERF_WORK_DIR}/git-src"
    GIT_BIN="${GIT_SRC_DIR}/bin-wrappers/git"
    GIT_PERF_DIR="${GIT_SRC_DIR}/t/perf"
    GIT_CONTAINER_NAME="boostkit-git-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    export SOFTWARE_VERSION PERF_VARIANT EXPECTED_ARCH PERF_RUN_ID PERF_WORK_DIR RESULTS_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
    export GIT_SRC_DIR GIT_CONTAINER_NAME
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

require_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the Git container'
        return 30
    fi
}

verify_git_image_release() {
    local release
    release="$(docker run --rm --network=none "${GIT_CONTAINER_IMAGE}" cat /etc/os-release)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    if ! grep -Eq '^ID="?openEuler"?$' <<< "${release}" || \
       ! grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}"; then
        log_message 'ERROR: loaded Git container image is not openEuler 24.03 LTS SP4'
        return 30
    fi
}

prepare_git_container_image() {
    local archive_name="openEuler-docker.${EXPECTED_ARCH}.tar.xz"
    local archive checksum expected actual load_output image_architecture
    local image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${archive_name}"

    if [[ -s "${GIT_IMAGE_ARCHIVE_DIR}/${archive_name}" ]]; then
        archive="${GIT_IMAGE_ARCHIVE_DIR}/${archive_name}"
        log_message "using local openEuler container image archive: ${archive}"
    else
        archive="${PERF_WORK_DIR}/${archive_name}"
        log_message "downloading openEuler container image archive: ${image_url}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}" "${image_url}" || return 30
    fi

    if [[ -s "${GIT_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum" ]]; then
        checksum="${GIT_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum"
    else
        checksum="${PERF_WORK_DIR}/${archive_name}.sha256sum"
        log_message "downloading official image checksum: ${image_url}.sha256sum"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
    fi
    expected="$(awk 'NR == 1 {print $1}' "${checksum}")"
    if [[ ! "${expected}" =~ ^[[:xdigit:]]{64}$ ]]; then
        log_message "ERROR: invalid official image checksum: ${checksum}"
        return 30
    fi
    actual="$(sha256sum "${archive}")"
    if [[ "${actual%% *}" != "${expected,,}" ]]; then
        log_message "ERROR: openEuler container image checksum mismatch: ${archive}"
        return 30
    fi

    log_message "loading verified openEuler container image: ${archive}"
    load_output="$(docker load --input "${archive}")" || return 30
    GIT_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [[ -z "${GIT_CONTAINER_IMAGE}" ]] || ! docker image inspect "${GIT_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${GIT_CONTAINER_IMAGE}")"
    case "${EXPECTED_ARCH}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${EXPECTED_ARCH}"; return 30 ;;
    esac
    verify_git_image_release || return $?
    export GIT_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${GIT_CONTAINER_IMAGE} (${image_architecture})"
}

# Create the private container. It runs until the stop stage removes it, is
# not CPU- or NUMA-pinned, uses the host network, and bind-mounts this task's
# work and result directories so every artifact stays on the host.
require_git_container() {
    local -a cert_mount=()
    require_docker || return $?
    if docker container inspect "${GIT_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${GIT_CONTAINER_NAME}"
        return 40
    fi
    if [[ -z "${GIT_CONTAINER_IMAGE}" ]]; then
        prepare_git_container_image || return $?
    fi
    if [[ -n "${PERF_PROXY:-}" ]]; then
        if [[ ! -d "${GIT_CA_ANCHORS_DIR}" ]]; then
            log_message "ERROR: proxy CA certificate directory is missing: ${GIT_CA_ANCHORS_DIR}"
            return 30
        fi
        cert_mount+=(--mount "type=bind,source=${GIT_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    log_message "starting Git container ${GIT_CONTAINER_NAME} (host network, no CPU/NUMA pinning)"
    docker run --detach --name "${GIT_CONTAINER_NAME}" \
        --label "boostkit.git.run-id=${PERF_RUN_ID}" \
        --network=host --user "$(id -u):$(id -g)" \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" \
        "${GIT_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [[ -n "${PERF_PROXY:-}" ]]; then
        log_message 'updating CA trust in the private Git container'
        docker exec --user 0 "${GIT_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the Git container'
            return 30
        }
    fi
    log_message 'switching private Git container repositories to the Huawei openEuler mirror'
    if docker exec --user 0 "${GIT_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        docker exec --user 0 "${GIT_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to update repositories in the Git container'
            return 30
        }
    fi
}

check_git_container() {
    [[ "$(docker inspect --format '{{.State.Running}}' "${GIT_CONTAINER_NAME}" 2>/dev/null)" == true ]] || {
        log_message "ERROR: managed Git container is not running: ${GIT_CONTAINER_NAME}"
        return 40
    }
}

# Run a command inside the container with the host proxy forwarded when one is
# configured (git clone and cargo inside the container need it).
container_exec() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec -e http_proxy="${PERF_PROXY}" -e https_proxy="${PERF_PROXY}" \
            -e TMPDIR="${TMPDIR}" "${GIT_CONTAINER_NAME}" "$@"
    else
        docker exec -e TMPDIR="${TMPDIR}" "${GIT_CONTAINER_NAME}" "$@"
    fi
}

container_exec_root() {
    docker exec --user 0 -e TMPDIR="${TMPDIR}" "${GIT_CONTAINER_NAME}" "$@"
}

remove_git_container() {
    if ! docker container inspect "${GIT_CONTAINER_NAME}" >/dev/null 2>&1; then
        return 0
    fi
    if [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.git.run-id"}}' "${GIT_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]]; then
        log_message "ERROR: refusing to remove container without this task's ownership label: ${GIT_CONTAINER_NAME}"
        return 50
    fi
    docker stop --time 30 "${GIT_CONTAINER_NAME}" >/dev/null || return 50
    docker rm "${GIT_CONTAINER_NAME}" >/dev/null || return 50
    log_message "removed managed Git container ${GIT_CONTAINER_NAME}"
}

