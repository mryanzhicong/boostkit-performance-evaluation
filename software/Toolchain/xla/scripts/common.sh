#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASE_DIR="${SCRIPT_DIR}"
SOFTWARE_NAME="xla"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1930995a8aab}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"

# openxla/xla is developed on a rolling main branch, so the software version
# is the commit itself (short 12 characters in the manifest, full SHA in the
# script).
XLA_REPOSITORY="${XLA_REPOSITORY:-https://github.com/openxla/xla.git}"
XLA_COMMIT="${XLA_COMMIT:-1930995a8aabe45a13854f701b5b39ab732aef94}"
XLA_ARCHIVE_DIR="${XLA_ARCHIVE_DIR:-/home/runner/software/xla}"

# openEuler container runtime (same base image and loading method as MySQL).
XLA_IMAGE_ARCHIVE_DIR="${XLA_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
XLA_CA_ANCHORS_DIR="${XLA_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
XLA_CONTAINER_IMAGE=""
XLA_CONTAINER_NAME=""

# Bazel is provisioned through the official bazelisk release; the actual
# Bazel version is pinned by the repository's .bazelversion file.
BAZELISK_VERSION="${BAZELISK_VERSION:-v1.29.0}"
BAZELISK_RELEASE_BASE="${BAZELISK_RELEASE_BASE:-https://github.com/bazelbuild/bazelisk/releases/download}"
BAZELISK_X86_64_SHA256="${BAZELISK_X86_64_SHA256:-5a408715e932c0250d28bd84555f12edbf70117de42f9181691c736eacc4a992}"
BAZELISK_AARCH64_SHA256="${BAZELISK_AARCH64_SHA256:-e20e8b0f4f240091b7a55bf17b9398bd4f40ee70ae0208dff95dd4c445fb4010}"

# Official CPU benchmark registry entries (xla/tools/benchmarks). The two
# Keras/Flax workloads are served from the official GCS bucket referenced by
# the registry; the bf16 workload ships inside the pinned commit.
XLA_NUM_REPEATS="${XLA_NUM_REPEATS:-5}"
XLA_GEMMA3_BENCHMARK="gemma3_1b_flax_call"
XLA_GEMMA3_HLO_NAME="gemma3_1b_flax_call.hlo"
XLA_GEMMA3_HLO_URL="${XLA_GEMMA3_HLO_URL:-https://storage.googleapis.com/xla-benchmarking-temp/gemma3_1b_flax_call.hlo}"
XLA_GEMMA3_HLO_SHA256="${XLA_GEMMA3_HLO_SHA256:-b3bee2a908477a49d41dd6d0adb8ccf2a25fe0bfecb5aa7d6bdb7cee4633b7de}"
XLA_GEMMA2_BENCHMARK="gemma2_2b_keras_jax"
XLA_GEMMA2_HLO_NAME="gemma2_2b_keras_jax.hlo"
XLA_GEMMA2_HLO_URL="${XLA_GEMMA2_HLO_URL:-https://storage.googleapis.com/xla-benchmarking-temp/gemma2_2b_keras_jax.hlo}"
XLA_GEMMA2_HLO_SHA256="${XLA_GEMMA2_HLO_SHA256:-78aaab6a47a87edbaba4d6acc10f3d5175a09c4a38b9a4cf02900c96558eb49c}"
XLA_GEMMA4_BENCHMARK="gemma4_2b_bf16"
XLA_GEMMA4_HLO_NAME="hlo_gemma4_2b_bf16.hlo"
XLA_GEMMA4_HLO_SHA256="${XLA_GEMMA4_HLO_SHA256:-b3a724c8d9990f10b8b788a8879129bf47024b847da665fccc2271ce9331f5f0}"

# Lifecycle paths (assigned in configure_runtime_paths).
XLA_SRC_DIR=""
BAZELISK_BIN=""
HLO_RUNNER_BIN=""
XSPACE_STATS_BIN=""
OFFICIAL_RUN_BENCHMARK=""
BENCHMARK_DIR=""
HARDWARE_CATEGORY=""
CONFIG_ID=""

log_message() { printf '[xla] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    [[ "${SOFTWARE_VERSION}" == "1930995a8aab" ]] || {
        log_message "ERROR: unsupported XLA version: ${SOFTWARE_VERSION}"
        return 10
    }
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64)
            EXPECTED_ARCH="x86_64"
            HARDWARE_CATEGORY="CPU_X86"
            CONFIG_ID="cpu_x86"
            ;;
        aarch64|arm64)
            EXPECTED_ARCH="aarch64"
            HARDWARE_CATEGORY="CPU_ARM64"
            CONFIG_ID="cpu_arm64"
            ;;
        *)
            log_message "ERROR: unsupported architecture: ${EXPECTED_ARCH}"
            return 10
            ;;
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/xla/local-${PERF_RUN_ID}"
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
    XLA_SRC_DIR="${PERF_WORK_DIR}/xla-src"
    BAZELISK_BIN="${PERF_WORK_DIR}/bazelisk/bazelisk"
    HLO_RUNNER_BIN="${XLA_SRC_DIR}/bazel-bin/xla/tools/multihost_hlo_runner/hlo_runner_main"
    XSPACE_STATS_BIN="${XLA_SRC_DIR}/bazel-bin/xla/tools/compute_xspace_stats_main"
    OFFICIAL_RUN_BENCHMARK="${XLA_SRC_DIR}/.github/workflows/benchmarks/run_benchmark.sh"
    BENCHMARK_DIR="${PERF_WORK_DIR}/benchmark"
    XLA_CONTAINER_NAME="boostkit-xla-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    export SOFTWARE_VERSION PERF_VARIANT EXPECTED_ARCH PERF_RUN_ID PERF_WORK_DIR RESULTS_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR HARDWARE_CATEGORY CONFIG_ID XLA_CONTAINER_NAME
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

verify_sha256() {
    local file_path="$1" expected="$2" actual
    actual="$(sha256sum "${file_path}" | cut -d' ' -f1)"
    [[ "${actual}" == "${expected}" ]] || {
        log_message "ERROR: checksum mismatch for ${file_path}: expected ${expected}, got ${actual}"
        return 30
    }
}

require_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the XLA container'
        return 30
    fi
}

verify_xla_image_release() {
    local release
    release="$(docker run --rm --network=none "${XLA_CONTAINER_IMAGE}" cat /etc/os-release)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    if ! grep -Eq '^ID="?openEuler"?$' <<< "${release}" || \
       ! grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}"; then
        log_message 'ERROR: loaded XLA container image is not openEuler 24.03 LTS SP4'
        return 30
    fi
}

prepare_xla_container_image() {
    local archive_name="openEuler-docker.${EXPECTED_ARCH}.tar.xz"
    local archive checksum expected actual load_output image_architecture
    local image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${archive_name}"

    if [[ -s "${XLA_IMAGE_ARCHIVE_DIR}/${archive_name}" ]]; then
        archive="${XLA_IMAGE_ARCHIVE_DIR}/${archive_name}"
        log_message "using local openEuler container image archive: ${archive}"
    else
        archive="${PERF_WORK_DIR}/${archive_name}"
        log_message "downloading openEuler container image archive: ${image_url}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}" "${image_url}" || return 30
    fi

    if [[ -s "${XLA_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum" ]]; then
        checksum="${XLA_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum"
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
    XLA_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [[ -z "${XLA_CONTAINER_IMAGE}" ]] || ! docker image inspect "${XLA_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${XLA_CONTAINER_IMAGE}")"
    case "${EXPECTED_ARCH}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${EXPECTED_ARCH}"; return 30 ;;
    esac
    verify_xla_image_release || return $?
    export XLA_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${XLA_CONTAINER_IMAGE} (${image_architecture})"
}

# One private container per run: host network, no CPU/NUMA pinning, work and
# result directories bind-mounted at their host paths.
require_xla_container() {
    local -a cert_mount=()
    require_docker || return $?
    if docker container inspect "${XLA_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${XLA_CONTAINER_NAME}"
        return 40
    fi
    if [[ -z "${XLA_CONTAINER_IMAGE}" ]]; then
        prepare_xla_container_image || return $?
    fi
    if [[ -n "${PERF_PROXY:-}" ]]; then
        if [[ ! -d "${XLA_CA_ANCHORS_DIR}" ]]; then
            log_message "ERROR: proxy CA certificate directory is missing: ${XLA_CA_ANCHORS_DIR}"
            return 30
        fi
        cert_mount+=(--mount "type=bind,source=${XLA_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    log_message "starting XLA container ${XLA_CONTAINER_NAME} (host network, no CPU/NUMA pinning)"
    docker run --detach --name "${XLA_CONTAINER_NAME}" \
        --label "boostkit.xla.run-id=${PERF_RUN_ID}" \
        --network=host --user "$(id -u):$(id -g)" \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" \
        "${XLA_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [[ -n "${PERF_PROXY:-}" ]]; then
        log_message 'updating CA trust in the private XLA container'
        docker exec --user 0 "${XLA_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the XLA container'
            return 30
        }
    fi
    log_message 'switching private XLA container repositories to the Huawei openEuler mirror'
    if docker exec --user 0 "${XLA_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        docker exec --user 0 "${XLA_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to update repositories in the XLA container'
            return 30
        }
    fi
}

check_xla_container() {
    [[ "$(docker inspect --format '{{.State.Running}}' "${XLA_CONTAINER_NAME}" 2>/dev/null)" == true ]] || {
        log_message "ERROR: managed XLA container is not running: ${XLA_CONTAINER_NAME}"
        return 40
    }
}

container_exec() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec -e http_proxy="${PERF_PROXY}" -e https_proxy="${PERF_PROXY}" \
            -e TMPDIR="${TMPDIR}" "${XLA_CONTAINER_NAME}" "$@"
    else
        docker exec -e TMPDIR="${TMPDIR}" "${XLA_CONTAINER_NAME}" "$@"
    fi
}

container_exec_root() {
    docker exec --user 0 -e TMPDIR="${TMPDIR}" "${XLA_CONTAINER_NAME}" "$@"
}

remove_xla_container() {
    if ! docker container inspect "${XLA_CONTAINER_NAME}" >/dev/null 2>&1; then
        return 0
    fi
    if [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.xla.run-id"}}' "${XLA_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]]; then
        log_message "ERROR: refusing to remove container without this task's ownership label: ${XLA_CONTAINER_NAME}"
        return 50
    fi
    docker stop --time 30 "${XLA_CONTAINER_NAME}" >/dev/null || return 50
    docker rm "${XLA_CONTAINER_NAME}" >/dev/null || return 50
    log_message "removed managed XLA container ${XLA_CONTAINER_NAME}"
}
