#!/usr/bin/env bash
# Shared variables and helpers for the fbthrift RPC performance case.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="fbthrift"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-2022.11.14.00}"
STACK_VERSION="${STACK_VERSION:-v${SOFTWARE_VERSION}}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# Upstream sources (GitHub facebook/* at the pinned weekly tag).
FOLLY_SOURCE_URL="${FOLLY_SOURCE_URL:-https://github.com/facebook/folly.git}"
FIZZ_SOURCE_URL="${FIZZ_SOURCE_URL:-https://github.com/facebookincubator/fizz.git}"
WANGLE_SOURCE_URL="${WANGLE_SOURCE_URL:-https://github.com/facebook/wangle.git}"
THRIFT_SOURCE_URL="${THRIFT_SOURCE_URL:-https://github.com/facebook/fbthrift.git}"
FAST_FLOAT_SOURCE_URL="${FAST_FLOAT_SOURCE_URL:-https://github.com/fastfloat/fast_float.git}"
# fast_float publishes semantic tags, not date tags: v8.2.10 is the release the
# boostkit AccLibBenchmark fixture is built against (commit 34164f547b7d).
FAST_FLOAT_TAG="${FAST_FLOAT_TAG:-v8.2.10}"
FAST_FLOAT_VERSION="${FAST_FLOAT_VERSION:-v8.2.10}"

# Runner-local offline inputs.  AccLibBenchmark/fbthrift_folly_benchmark is a
# private fixture: it is copied into PERF_WORK_DIR, never committed here.
FBTHRIFT_OFFLINE_DIR="${FBTHRIFT_OFFLINE_DIR:-/home/runner/software/fbthrift}"
FBTHRIFT_LEGACY_OFFLINE_DIR="${FBTHRIFT_LEGACY_OFFLINE_DIR:-/home/runner/software/folly}"
FBTHRIFT_ACCLIB_DIR="${FBTHRIFT_ACCLIB_DIR:-}"
FBTHRIFT_CLANG16_TARBALL="${FBTHRIFT_CLANG16_TARBALL:-}"
FBTHRIFT_CLANG16_DIR="${FBTHRIFT_CLANG16_DIR:-}"
CLANG16_VERSION="16.0.6"

# Matrix and runtime knobs (wiki defaults: 165 cases, 120 s per case, NUMA 1).
FBTHRIFT_MATRIX="${FBTHRIFT_MATRIX:-full}"
FBTHRIFT_TEST_SECONDS="${FBTHRIFT_TEST_SECONDS:-120}"
FBTHRIFT_RPC_TIMEOUT_MS="${FBTHRIFT_RPC_TIMEOUT_MS:-2000}"
FBTHRIFT_CPU_THREADS="${FBTHRIFT_CPU_THREADS:-40}"
FBTHRIFT_IO_THREADS="${FBTHRIFT_IO_THREADS:-40}"
FBTHRIFT_NUMA_NODE="${FBTHRIFT_NUMA_NODE:-1}"
FBTHRIFT_EXTRA_CLIENT_ARGS="${FBTHRIFT_EXTRA_CLIENT_ARGS:-}"

COMPILER_BINARY="clang++"
COMPILER_VERSION_STRING=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"

# Lifecycle paths (assigned in configure_runtime_paths).
SOURCE_DIR=""
FIZZ_DIR=""
WANGLE_DIR=""
THRIFT_DIR=""
FAST_FLOAT_DIR=""
STACK_INSTALL=""
BENCH_DIR=""
SERVER_BINARY=""
CLIENT_BINARY=""
SERVICE_DIR=""
CLANG_ROOT=""
ACCLIB_SOURCE=""

log_message() { printf '[fbthrift] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

normalize_architecture() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

resolve_acclib_dir() {
    local candidate
    if [ -n "${FBTHRIFT_ACCLIB_DIR}" ]; then
        printf '%s\n' "${FBTHRIFT_ACCLIB_DIR}"
        return 0
    fi
    for candidate in "${FBTHRIFT_OFFLINE_DIR}/AccLibBenchmark" \
                     "${FBTHRIFT_LEGACY_OFFLINE_DIR}/AccLibBenchmark"; do
        if [ -f "${candidate}/fbthrift_folly_benchmark/CMakeLists.txt" ]; then
            printf '%s\n' "${candidate}"
            return 0
        fi
    done
    printf '%s\n' "${FBTHRIFT_OFFLINE_DIR}/AccLibBenchmark"
}

configure_runtime_paths() {
    validate_variant || return $?
    if [ -z "${PERF_RUN_ID}" ]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log_message 'ERROR: PERF_RUN_ID contains unsafe characters'
        return 10
    }
    if [ -z "${RESULTS_DIR}" ]; then
        if [ "${PERF_VARIANT}" = optimized ]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    if [ -z "${PERF_WORK_DIR}" ]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/fbthrift/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    [ -n "${PERF_ACTUAL_VERSION_FILE}" ] || PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    SOURCE_DIR="${PERF_WORK_DIR}/folly-source"
    FIZZ_DIR="${PERF_WORK_DIR}/fizz-source"
    WANGLE_DIR="${PERF_WORK_DIR}/wangle-source"
    THRIFT_DIR="${PERF_WORK_DIR}/fbthrift-source"
    FAST_FLOAT_DIR="${PERF_WORK_DIR}/fast_float"
    STACK_INSTALL="${PERF_WORK_DIR}/install"
    BENCH_DIR="${PERF_WORK_DIR}/fbthrift_folly_benchmark"
    SERVER_BINARY="${BENCH_DIR}/build/press_server"
    CLIENT_BINARY="${BENCH_DIR}/build/press_client"
    SERVICE_DIR="${PERF_WORK_DIR}/service"
    CLANG_ROOT="${PERF_WORK_DIR}/clang16"
    ACCLIB_SOURCE="$(resolve_acclib_dir)"
    export TMPDIR="${PERF_WORK_DIR}/tmp"
    export LD_LIBRARY_PATH="${STACK_INSTALL}/fbthrift/lib:${STACK_INSTALL}/fbthrift/lib64:${STACK_INSTALL}/wangle/lib:${STACK_INSTALL}/wangle/lib64:${STACK_INSTALL}/fizz/lib:${STACK_INSTALL}/fizz/lib64:${STACK_INSTALL}/folly/lib:${STACK_INSTALL}/folly/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
    export ACCLIB_SOURCE
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    [[ "$(normalize_architecture "$(uname -m)")" == "$(normalize_architecture "${EXPECTED_ARCH}")" ]] || {
        log_message "ERROR: runner architecture differs from ${EXPECTED_ARCH}"
        return 20
    }
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${SERVICE_DIR}"
}

# Validate the requested NUMA node against the container topology; fall back to
# node 0 (and record it) when the requested node does not exist.
resolve_numa_node() {
    local requested="${FBTHRIFT_NUMA_NODE}"
    local nodes
    nodes="$(numactl --hardware 2>/dev/null | sed -nE 's/^available: ([0-9]+) nodes.*/\1/p')" || nodes=""
    if [ -z "${nodes}" ]; then
        printf '0\n'
        return 0
    fi
    if [[ "${requested}" =~ ^[0-9]+$ ]] && [ "${requested}" -lt "${nodes}" ]; then
        printf '%s\n' "${requested}"
    else
        log_message "WARNING: NUMA node ${requested} is unavailable (${nodes} nodes); falling back to node 0" >&2
        printf '0\n'
    fi
}

# >>> container-runtime:begin
# ==============================================================================
# Private openEuler container runtime
# ==============================================================================
# Every stage of this case runs inside a per-run openEuler 24.03 LTS SP4
# container.  The host keeps only Docker, download/verification tooling, the
# framework and the strict result parser; package installation, source
# extraction, builds, the measured process tree and cleanup happen inside the
# container.  The contract mirrors software/Database/mysql,
# software/Bigdata/ray and software/Others/unixbench.
#
# Generated by adaptation/scripts/add-container-block.py -- do not hand edit the
# region between the markers; change the template instead.
FBTHRIFT_IMAGE_ARCHIVE_DIR="${FBTHRIFT_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
FBTHRIFT_CA_ANCHORS_DIR="${FBTHRIFT_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
FBTHRIFT_CONTAINER_IMAGE="${FBTHRIFT_CONTAINER_IMAGE:-}"
FBTHRIFT_CONTAINER_NAME="${FBTHRIFT_CONTAINER_NAME:-}"
FBTHRIFT_CONTAINER_HOME="${FBTHRIFT_CONTAINER_HOME:-}"
declare -p FBTHRIFT_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || FBTHRIFT_CONTAINER_EXTRA_ARGS=()

fbthrift_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

fbthrift_configure_container() {
    local arch
    arch="$(fbthrift_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${FBTHRIFT_CONTAINER_NAME}" ] || FBTHRIFT_CONTAINER_NAME="boostkit-fbthrift-${arch}-${PERF_RUN_ID}"
    [ -n "${FBTHRIFT_CONTAINER_HOME}" ] || FBTHRIFT_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export FBTHRIFT_CONTAINER_NAME FBTHRIFT_CONTAINER_HOME
}

fbthrift_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_fbthrift_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_fbthrift_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${FBTHRIFT_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_fbthrift_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(fbthrift_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${FBTHRIFT_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${FBTHRIFT_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        fbthrift_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        fbthrift_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
    fi
    if [ -s "${checksum}" ]; then
        ( cd "$(dirname "${archive}")" && sha256sum -c "$(basename "${checksum}")" ) >/dev/null || {
            log_message "ERROR: container image checksum mismatch: ${archive}"
            return 30
        }
    else
        log_message "WARNING: no checksum file next to ${archive}; relying on the pinned path only"
    fi
    log_message "loading verified openEuler container image: ${archive}"
    load_output="$(docker load --input "${archive}")" || return 30
    FBTHRIFT_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${FBTHRIFT_CONTAINER_IMAGE}" ] || ! docker image inspect "${FBTHRIFT_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${FBTHRIFT_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_fbthrift_container_image_release || return $?
    export FBTHRIFT_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${FBTHRIFT_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_fbthrift_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-fbthrift-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${FBTHRIFT_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.fbthrift.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_fbthrift_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    fbthrift_configure_container
    require_fbthrift_docker || return $?
    if docker container inspect "${FBTHRIFT_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${FBTHRIFT_CONTAINER_NAME}"
        return 40
    fi
    sweep_fbthrift_stale_containers || true
    prepare_fbthrift_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${FBTHRIFT_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${FBTHRIFT_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${FBTHRIFT_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${FBTHRIFT_CONTAINER_HOME}" || return 40
    log_message "starting private container ${FBTHRIFT_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${FBTHRIFT_CONTAINER_NAME}" \
        --label "boostkit.fbthrift.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${FBTHRIFT_CONTAINER_EXTRA_ARGS[@]}" \
        "${FBTHRIFT_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${FBTHRIFT_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${FBTHRIFT_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${FBTHRIFT_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${FBTHRIFT_CONTAINER_NAME}"
}

check_fbthrift_container() {
    fbthrift_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${FBTHRIFT_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${FBTHRIFT_CONTAINER_NAME}"
        return 40
    }
}

fbthrift_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    fbthrift_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${FBTHRIFT_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${FBTHRIFT_CONTAINER_NAME}" "$@"
}

fbthrift_container_exec() { fbthrift_docker_exec '' '' "$@"; }

fbthrift_container_exec_at() {
    local workdir="$1"
    shift
    fbthrift_docker_exec "${workdir}" '' "$@"
}

fbthrift_container_exec_root() { fbthrift_docker_exec '' root "$@"; }

fbthrift_container_exec_root_at() {
    local workdir="$1"
    shift
    fbthrift_docker_exec "${workdir}" root "$@"
}

remove_fbthrift_container() {
    fbthrift_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${FBTHRIFT_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.fbthrift.run-id"}}' "${FBTHRIFT_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${FBTHRIFT_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${FBTHRIFT_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${FBTHRIFT_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${FBTHRIFT_CONTAINER_NAME}"
}
# >>> container-runtime:end
