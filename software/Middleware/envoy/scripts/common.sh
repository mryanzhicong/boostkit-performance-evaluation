#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.38.6}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
PERF_GITHUB_DOWNLOAD_PROXY="${PERF_GITHUB_DOWNLOAD_PROXY:-}"

K6_VERSION="2.2.0"
ENVOY_OFFLINE_DIR="${ENVOY_OFFLINE_DIR:-/home/runner/software/envoy}"
ENVOY_IMAGE_ARCHIVE_DIR="${ENVOY_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
ENVOY_CA_ANCHORS_DIR="${ENVOY_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
ENVOY_CONTAINER_CPUS="${ENVOY_CONTAINER_CPUS:-4}"
ENVOY_CONTAINER_MEMORY="${ENVOY_CONTAINER_MEMORY:-8g}"
ENVOY_CONTAINER_NUMA_NODE="${ENVOY_CONTAINER_NUMA_NODE:-}"

INSTALL_DIR=""
ENVOY_BIN=""
K6_BIN=""
RUNTIME_DIR=""
ENVOY_CONTAINER_IMAGE=""
ENVOY_CONTAINER_NAME=""
ENVOY_IMAGE_REF_FILE=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[envoy] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
}

normalize_architecture() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

validate_envoy_container_resources() {
    if [[ ! "${ENVOY_CONTAINER_CPUS}" =~ ^[1-9][0-9]*$ ]]; then
        log_message "ERROR: ENVOY_CONTAINER_CPUS must be a positive integer: ${ENVOY_CONTAINER_CPUS}"
        return 10
    fi
    if [[ ! "${ENVOY_CONTAINER_MEMORY}" =~ ^[1-9][0-9]*[gG]$ ]]; then
        log_message "ERROR: ENVOY_CONTAINER_MEMORY must be a whole-GiB value such as 8g: ${ENVOY_CONTAINER_MEMORY}"
        return 10
    fi
    if [[ -n "${ENVOY_CONTAINER_NUMA_NODE}" && ! "${ENVOY_CONTAINER_NUMA_NODE}" =~ ^[0-9]+$ ]]; then
        log_message "ERROR: ENVOY_CONTAINER_NUMA_NODE must be a non-negative integer: ${ENVOY_CONTAINER_NUMA_NODE}"
        return 10
    fi
}

# Pick four CPUs from one NUMA node, never from a hard-coded CPU range.  The
# runner's allowed affinity is the source of truth; when sysfs exposes no NUMA
# topology (for example a local WSL smoke host), fall back to four affinity CPUs
# and let Docker use the host memory policy.
select_envoy_cpu_set() {
    python3 - "${ENVOY_CONTAINER_CPUS}" "${ENVOY_CONTAINER_NUMA_NODE}" <<'PY'
import os
import sys
from pathlib import Path

want = int(sys.argv[1])
preferred = sys.argv[2].strip()
if want < 1:
    raise SystemExit("CPU count must be positive")

affinity = sorted(os.sched_getaffinity(0))
node_cpus = {}
for cpu in affinity:
    nodes = sorted(Path(f"/sys/devices/system/cpu/cpu{cpu}").glob("node[0-9]*"))
    if not nodes:
        continue
    node = nodes[0].name[4:]
    node_cpus.setdefault(node, []).append(cpu)

if node_cpus:
    candidates = sorted(node_cpus, key=int)
    if preferred:
        if preferred not in node_cpus:
            raise SystemExit(f"requested NUMA node {preferred} has no allowed CPUs")
        candidates = [preferred]
    for node in candidates:
        if len(node_cpus[node]) >= want:
            print(",".join(map(str, node_cpus[node][:want])), node)
            raise SystemExit(0)
    raise SystemExit(f"no NUMA node has at least {want} available CPUs")

if len(affinity) < want:
    raise SystemExit(f"only {len(affinity)} CPUs available, need {want}")
print(",".join(map(str, affinity[:want])), "")
PY
}

# Derive a per-run port block instead of using fixed 18080/19000/19001 ports.
# The block is ten ports wide and stays in the unprivileged 20000-49999 range;
# cksum spreads sequential run IDs without depending on a hard-coded suffix.
select_envoy_port_base() {
    local hash
    hash="$(printf '%s' "${PERF_RUN_ID}" | cksum | awk '{print $1}')"
    printf '%s\n' "$(( 20000 + (hash % 3000) * 10 ))"
}

set_envoy_runtime_ports() {
    local base
    base="$(select_envoy_port_base)" || return 40
    ENVOY_BACKEND_PORT=$(( base ))
    ENVOY_BACKEND_ADMIN_PORT=$(( base + 1 ))
    ENVOY_DIRECT_PORT=$(( base + 2 ))
    ENVOY_DIRECT_ADMIN_PORT=$(( base + 3 ))
    ENVOY_PROXY_PORT=$(( base + 4 ))
    ENVOY_PROXY_ADMIN_PORT=$(( base + 5 ))
    export ENVOY_BACKEND_PORT ENVOY_BACKEND_ADMIN_PORT
    export ENVOY_DIRECT_PORT ENVOY_DIRECT_ADMIN_PORT
    export ENVOY_PROXY_PORT ENVOY_PROXY_ADMIN_PORT
}

verify_envoy_container_resources() {
    local expected_cpu_set="$1"
    local expected_numa_node="$2"
    local expect_swap="${3:-false}"
    local actual nano_cpus cpu_set numa_node memory memory_swap
    local expected_nano expected_bytes

    expected_nano=$(( ENVOY_CONTAINER_CPUS * 1000000000 ))
    expected_bytes=$(( ${ENVOY_CONTAINER_MEMORY%[gG]} * 1024 * 1024 * 1024 ))
    actual="$(docker inspect --format '{{.HostConfig.NanoCpus}}|{{.HostConfig.CpusetCpus}}|{{.HostConfig.CpusetMems}}|{{.HostConfig.Memory}}|{{.HostConfig.MemorySwap}}' "${ENVOY_CONTAINER_NAME}" 2>/dev/null)" || {
        log_message "ERROR: cannot inspect Envoy container resource limits: ${ENVOY_CONTAINER_NAME}"
        return 40
    }
    IFS='|' read -r nano_cpus cpu_set numa_node memory memory_swap <<< "${actual}"
    if [[ "${nano_cpus}" != "${expected_nano}" ]]; then
        log_message "ERROR: Envoy container CPU quota is ${nano_cpus}, expected ${expected_nano} (${ENVOY_CONTAINER_CPUS} CPUs)"
        return 40
    fi
    if [[ "${cpu_set}" != "${expected_cpu_set}" ]]; then
        log_message "ERROR: Envoy container CPU set is ${cpu_set}, expected ${expected_cpu_set}"
        return 40
    fi
    if [[ -n "${expected_numa_node}" && "${numa_node}" != "${expected_numa_node}" ]]; then
        log_message "ERROR: Envoy container NUMA memory set is ${numa_node}, expected ${expected_numa_node}"
        return 40
    fi
    if [[ "${memory}" != "${expected_bytes}" ]]; then
        log_message "ERROR: Envoy container memory is ${memory}, expected ${expected_bytes}"
        return 40
    fi
    if [[ "${expect_swap}" == true && "${memory_swap}" != "${expected_bytes}" ]]; then
        log_message "ERROR: Envoy container memory swap is ${memory_swap}, expected ${expected_bytes}"
        return 40
    fi
    if [[ "${expect_swap}" != true ]]; then
        log_message "WARNING: this Docker daemon does not enforce swap accounting; the 8 GiB memory cgroup limit is still verified"
    fi
    log_message "verified Envoy container limits: ${ENVOY_CONTAINER_CPUS} CPUs (${cpu_set}), NUMA ${numa_node:-unbound}, ${ENVOY_CONTAINER_MEMORY} memory"
}

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    local actual_arch expected_arch

    expected_arch="$(normalize_architecture "${EXPECTED_ARCH}")"
    case "${expected_arch}" in
        x86_64) K6_ARCH="amd64" ;;
        aarch64) K6_ARCH="arm64" ;;
        *)
            log_message "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    EXPECTED_ARCH="${expected_arch}"
    actual_arch="$(normalize_architecture "$(uname -m)")"
    [[ "${actual_arch}" == "${EXPECTED_ARCH}" ]] || {
        log_message "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${actual_arch}"
        return 20
    }

    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    }
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/envoy/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"

    INSTALL_DIR="${PERF_WORK_DIR}/envoy-install"
    ENVOY_BIN="${INSTALL_DIR}/envoy"
    K6_BIN="${PERF_WORK_DIR}/tools/k6"
    RUNTIME_DIR="${PERF_WORK_DIR}/runtime"
    ENVOY_IMAGE_REF_FILE="${PERF_WORK_DIR}/envoy-container-image-24.03-LTS-SP4.txt"
    ENVOY_CONTAINER_NAME="boostkit-envoy-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
    export ENVOY_IMAGE_REF_FILE ENVOY_CONTAINER_NAME
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" || return 30
}

# >>> container-runtime:begin
# This case keeps its container runtime in common.sh rather than importing the
# generated block, because the image is prepared during the build stage and the
# three Envoy processes share one task-private container.  The markers keep the
# repository container-block verifier applicable to this hand-written runtime.
verify_envoy_image_release() {
    local release
    release="$(docker run --rm --network=none "${ENVOY_CONTAINER_IMAGE}" cat /etc/os-release)" || return 30
    if ! grep -Eq '^ID="?openEuler"?$' <<< "${release}" || \
       ! grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}"; then
        log_message "ERROR: loaded Envoy container image is not openEuler 24.03 LTS SP4"
        return 30
    fi
}

prepare_envoy_container_image() {
    local archive_name="openEuler-docker.${EXPECTED_ARCH}.tar.xz"
    local archive checksum expected actual load_output image_architecture
    local image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${archive_name}"

    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message "ERROR: an accessible Docker daemon is required for the Envoy container"
        return 30
    fi
    if [[ -s "${ENVOY_IMAGE_REF_FILE}" ]]; then
        ENVOY_CONTAINER_IMAGE="$(<"${ENVOY_IMAGE_REF_FILE}")"
        if docker image inspect "${ENVOY_CONTAINER_IMAGE}" >/dev/null 2>&1; then
            verify_envoy_image_release || return $?
            return 0
        fi
        log_message "ERROR: recorded Envoy image is no longer available"
        return 30
    fi
    if [[ -s "${ENVOY_IMAGE_ARCHIVE_DIR}/${archive_name}" ]]; then
        archive="${ENVOY_IMAGE_ARCHIVE_DIR}/${archive_name}"
        log_message "using local openEuler image archive: ${archive}"
    else
        archive="${PERF_WORK_DIR}/${archive_name}"
        log_message "downloading openEuler image archive: ${image_url}"
        curl -fSL --retry 3 --connect-timeout 30 -o "${archive}" "${image_url}" || return 30
    fi
    if [[ -s "${ENVOY_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum" ]]; then
        checksum="${ENVOY_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum"
    else
        checksum="${PERF_WORK_DIR}/${archive_name}.sha256sum"
        curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
    fi
    expected="$(awk 'NR == 1 {print $1}' "${checksum}")"
    if [[ ! "${expected}" =~ ^[[:xdigit:]]{64}$ ]]; then
        log_message "ERROR: invalid openEuler image checksum: ${checksum}"
        return 30
    fi
    actual="$(sha256sum "${archive}")"
    if [[ "${actual%% *}" != "${expected,,}" ]]; then
        log_message "ERROR: openEuler image checksum mismatch: ${archive}"
        return 30
    fi
    load_output="$(docker load --input "${archive}")" || return 30
    ENVOY_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [[ -z "${ENVOY_CONTAINER_IMAGE}" ]] || ! docker image inspect "${ENVOY_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${ENVOY_CONTAINER_IMAGE}")"
    case "${EXPECTED_ARCH}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${EXPECTED_ARCH}"; return 30 ;;
    esac
    verify_envoy_image_release || return $?
    printf '%s\n' "${ENVOY_CONTAINER_IMAGE}" > "${ENVOY_IMAGE_REF_FILE}"
    log_message "openEuler 24.03 LTS SP4 image is ready: ${ENVOY_CONTAINER_IMAGE}"
}

check_envoy_container() {
    command -v docker >/dev/null 2>&1 || {
        log_message "ERROR: Docker is required for the Envoy benchmark container"
        return 50
    }
    if [[ "$(docker inspect --format '{{.State.Running}}' "${ENVOY_CONTAINER_NAME}" 2>/dev/null)" != true ]] || \
       [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.envoy.run-id"}}' "${ENVOY_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]]; then
        log_message "ERROR: managed Envoy container is unavailable: ${ENVOY_CONTAINER_NAME}"
        return 50
    fi
}

remove_envoy_container() {
    local label
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${ENVOY_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    label="$(docker inspect --format '{{index .Config.Labels "boostkit.envoy.run-id"}}' "${ENVOY_CONTAINER_NAME}" 2>/dev/null)"
    if [[ "${label}" != "${PERF_RUN_ID}" ]]; then
        log_message "ERROR: refusing to remove a container that belongs to another run: ${ENVOY_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${ENVOY_CONTAINER_NAME}" >/dev/null || return 70
    docker rm "${ENVOY_CONTAINER_NAME}" >/dev/null || return 70
    log_message "removed task-private Envoy container: ${ENVOY_CONTAINER_NAME}"
}
# >>> container-runtime:end
