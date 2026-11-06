#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="flatbuffers"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-25.12.19}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

FLATBUFFERS_VERSION="${SOFTWARE_VERSION}"
# The release is identified by its full upstream tag; the version in the
# software name is the major.minor.patch part that `flatc --version` reports.
FLATBUFFERS_TAG="v25.12.19-2026-02-06-03fffb2"
FLATBUFFERS_SOURCE_NAME="flatbuffers-${FLATBUFFERS_VERSION}.tar.gz"

# Upstream publishes only prebuilt flatc binaries as release assets, so the
# pinned source is the GitHub tag archive.  GitHub does not publish a checksum
# for auto-generated tag archives; this digest was computed locally and
# reproduced byte-for-byte through two independent mirror paths.
FLATBUFFERS_SOURCE_SHA256="ccbce58684691de1e7d51f5e87786266b37d06ab66e9dfe2d0ec106fe50aace0"
FLATBUFFERS_SOURCE_SIZE=2375289
FLATBUFFERS_SOURCE_URL="https://github.com/google/flatbuffers/archive/refs/tags/${FLATBUFFERS_TAG}.tar.gz"

# Fallback order: the Runner cannot reliably reach github.com, so the public
# GitHub mirrors are tried before the canonical URL gets its last chance.  Every
# candidate must produce the same SHA-256.
FLATBUFFERS_SOURCE_URLS=(
    "https://gh-proxy.com/https://github.com/google/flatbuffers/archive/refs/tags/${FLATBUFFERS_TAG}.tar.gz"
    "https://ghfast.top/https://github.com/google/flatbuffers/archive/refs/tags/${FLATBUFFERS_TAG}.tar.gz"
    "${FLATBUFFERS_SOURCE_URL}"
)

FLATBUFFERS_OFFLINE_DIR="${PERF_FLATBUFFERS_OFFLINE_DIR:-/home/runner/software/flatbuffers}"

FLATBUFFERS_JOBS="${PERF_FLATBUFFERS_JOBS:-4}"
FLATBUFFERS_REPS="${PERF_REPS:-5}"

# Fixed upstream-benchmark parameters.  The upstream benchmark object encodes a
# fixed 3-element list per iteration; `flatc` and the benchmark are both built
# from the same pinned tag.
FLATBUFFERS_UPSTREAM_BATCHES=10
FLATBUFFERS_UPSTREAM_ITERATIONS=10000
# Deterministic checksum of one 10000-iteration batch of the upstream
# benchmarks/cpp/flatbuffers/fb_bench.cpp encode/use path (computed from the
# pinned source; the driver fails when a batch differs).
FLATBUFFERS_UPSTREAM_CHECKSUM=-7035620705617902304

# Case-owned multi-scale matrix: (scenario|mode|elements|iterations).
# Encoded bytes per iteration are measured by the driver itself.
FLATBUFFERS_SCENARIOS=(
    builder_1k
    accessor_1k
    builder_accessor_1k
    builder_accessor_10k
    builder_accessor_100k
    builder_accessor_1m
    upstream_bench_encode_use
)
FLATBUFFERS_DRIVER_SCENARIOS=(
    builder_1k
    accessor_1k
    builder_accessor_1k
    builder_accessor_10k
    builder_accessor_100k
    builder_accessor_1m
)

FLATBUFFERS_SOURCE_ARCHIVE=""
FLATBUFFERS_SRC_DIR=""
FLATBUFFERS_BUILD_DIR=""
FLATBUFFERS_GEN_DIR=""
FLATBUFFERS_FLATC=""
FLATBUFFERS_DRIVER_BIN=""
FLATBUFFERS_UPSTREAM_BIN=""
RUNS_DIR=""
FLATBUFFERS_VERSION_STRING=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[flatbuffers] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
}

report_failure_tail() {
    local log_file="$1" scenario="$2" label="$3" exit_code="$4"
    log_message "ERROR: ${scenario} (${label}) failed with exit code ${exit_code}"
    if [[ -s "${log_file}" ]]; then
        log_message "----- begin tail of ${log_file} (last 60 lines) -----"
        tail -n 60 -- "${log_file}" | while IFS= read -r line; do
            printf '[flatbuffers]   %s\n' "${line}"
        done
        log_message "----- end tail of ${log_file} -----"
    else
        log_message "ERROR: no captured output at ${log_file}"
    fi
}

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

validate_reps() {
    [[ "${FLATBUFFERS_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${FLATBUFFERS_REPS}"
        return 10
    }
    if (( FLATBUFFERS_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${FLATBUFFERS_REPS} is a local link-validation value; formal evidence requires >= 5"
    fi
}

validate_jobs() {
    [[ "${FLATBUFFERS_JOBS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_FLATBUFFERS_JOBS must be a positive integer, got ${FLATBUFFERS_JOBS}"
        return 10
    }
    if (( FLATBUFFERS_JOBS > 64 )); then
        log_message "ERROR: PERF_FLATBUFFERS_JOBS is unreasonably large: ${FLATBUFFERS_JOBS}"
        return 10
    fi
}

configure_runtime_paths() {
    validate_variant || return $?
    validate_reps || return $?
    validate_jobs || return $?
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64) EXPECTED_ARCH="x86_64" ;;
        aarch64|arm64) EXPECTED_ARCH="aarch64" ;;
        *)
            log_message "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    local runner_architecture
    runner_architecture="$(normalize_architecture "$(uname -m)")"
    case "${runner_architecture}" in
        x86_64|aarch64) ;;
        *)
            log_message "ERROR: unsupported runner architecture: $(uname -m)"
            return 20
            ;;
    esac
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log_message "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/flatbuffers/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    FLATBUFFERS_SOURCE_ARCHIVE="${PERF_WORK_DIR}/downloads/${FLATBUFFERS_SOURCE_NAME}"
    FLATBUFFERS_SRC_DIR="${PERF_WORK_DIR}/flatbuffers-source"
    FLATBUFFERS_BUILD_DIR="${PERF_WORK_DIR}/build"
    FLATBUFFERS_GEN_DIR="${PERF_WORK_DIR}/generated"
    FLATBUFFERS_FLATC="${FLATBUFFERS_BUILD_DIR}/flatc"
    FLATBUFFERS_DRIVER_BIN="${PERF_WORK_DIR}/bin/fb_bench_driver"
    FLATBUFFERS_UPSTREAM_BIN="${PERF_WORK_DIR}/bin/fb_upstream_bench"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export SOFTWARE_NAME SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID
    export RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export FLATBUFFERS_VERSION FLATBUFFERS_TAG FLATBUFFERS_SRC_DIR
    export FLATBUFFERS_BUILD_DIR FLATBUFFERS_GEN_DIR FLATBUFFERS_FLATC
    export FLATBUFFERS_DRIVER_BIN FLATBUFFERS_UPSTREAM_BIN
    export FLATBUFFERS_SOURCE_ARCHIVE RUNS_DIR FLATBUFFERS_REPS FLATBUFFERS_JOBS
    export FLATBUFFERS_SOURCE_NAME FLATBUFFERS_SOURCE_SHA256 FLATBUFFERS_SOURCE_SIZE
    export FLATBUFFERS_SOURCE_URL FLATBUFFERS_OFFLINE_DIR
    export FLATBUFFERS_UPSTREAM_BATCHES FLATBUFFERS_UPSTREAM_ITERATIONS
    export FLATBUFFERS_UPSTREAM_CHECKSUM
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

compiler_identity() {
    local compiler
    if ! compiler="$(flatbuffers_container_exec "${CXX:-c++}" --version 2>&1 | head -n 1)"; then
        compiler="unknown"
    fi
    printf '%s\n' "${compiler:-unknown}"
}

# `flatc --version` prints "flatc version 25.12.19".
decode_flatbuffers_version() {
    local line="$1"
    local version="${line##*version }"
    if [[ "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        printf '%s\n' "${version}"
        return 0
    fi
    return 1
}

flatbuffers_version_string() {
    flatbuffers_container_exec "${FLATBUFFERS_FLATC}" --version 2>&1 | head -n 1
}

scenario_task() {
    case "$1" in
        builder_1k|accessor_1k|builder_accessor_*) printf 'builder_accessor\n' ;;
        upstream_bench_encode_use) printf 'upstream_benchmark\n' ;;
        *) printf '%s\n' "$1" ;;
    esac
}

# (mode|elements|iterations) for one driver scenario.
driver_parameters() {
    case "$1" in
        builder_1k) printf 'build|1000|100000\n' ;;
        accessor_1k) printf 'access|1000|100000\n' ;;
        builder_accessor_1k) printf 'merged|1000|100000\n' ;;
        builder_accessor_10k) printf 'merged|10000|10000\n' ;;
        builder_accessor_100k) printf 'merged|100000|1000\n' ;;
        builder_accessor_1m) printf 'merged|1000000|100\n' ;;
        *) log_message "ERROR: unknown driver scenario: $1"; return 1 ;;
    esac
}

# Deterministic checksum the driver must report for one driver scenario.
driver_expected_checksum() {
    local scenario="$1" mode elements iterations
    IFS='|' read -r mode elements iterations < <(driver_parameters "${scenario}") || return 1
    if [[ "${mode}" == "build" ]]; then
        printf '0\n'
        return 0
    fi
    printf '%s\n' $(( elements * (elements - 1) / 2 * iterations ))
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
FLATBUFFERS_IMAGE_ARCHIVE_DIR="${FLATBUFFERS_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
FLATBUFFERS_CA_ANCHORS_DIR="${FLATBUFFERS_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
FLATBUFFERS_CONTAINER_IMAGE="${FLATBUFFERS_CONTAINER_IMAGE:-}"
FLATBUFFERS_CONTAINER_NAME="${FLATBUFFERS_CONTAINER_NAME:-}"
FLATBUFFERS_CONTAINER_HOME="${FLATBUFFERS_CONTAINER_HOME:-}"
declare -p FLATBUFFERS_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || FLATBUFFERS_CONTAINER_EXTRA_ARGS=()

flatbuffers_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

flatbuffers_configure_container() {
    local arch
    arch="$(flatbuffers_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${FLATBUFFERS_CONTAINER_NAME}" ] || FLATBUFFERS_CONTAINER_NAME="boostkit-flatbuffers-${arch}-${PERF_RUN_ID}"
    [ -n "${FLATBUFFERS_CONTAINER_HOME}" ] || FLATBUFFERS_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export FLATBUFFERS_CONTAINER_NAME FLATBUFFERS_CONTAINER_HOME
}

flatbuffers_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_flatbuffers_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_flatbuffers_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${FLATBUFFERS_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_flatbuffers_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(flatbuffers_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${FLATBUFFERS_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${FLATBUFFERS_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        flatbuffers_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        flatbuffers_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    FLATBUFFERS_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${FLATBUFFERS_CONTAINER_IMAGE}" ] || ! docker image inspect "${FLATBUFFERS_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${FLATBUFFERS_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_flatbuffers_container_image_release || return $?
    export FLATBUFFERS_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${FLATBUFFERS_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_flatbuffers_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-flatbuffers-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${FLATBUFFERS_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.flatbuffers.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_flatbuffers_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    flatbuffers_configure_container
    require_flatbuffers_docker || return $?
    if docker container inspect "${FLATBUFFERS_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${FLATBUFFERS_CONTAINER_NAME}"
        return 40
    fi
    sweep_flatbuffers_stale_containers || true
    prepare_flatbuffers_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${FLATBUFFERS_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${FLATBUFFERS_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${FLATBUFFERS_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${FLATBUFFERS_CONTAINER_HOME}" || return 40
    log_message "starting private container ${FLATBUFFERS_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${FLATBUFFERS_CONTAINER_NAME}" \
        --label "boostkit.flatbuffers.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${FLATBUFFERS_CONTAINER_EXTRA_ARGS[@]}" \
        "${FLATBUFFERS_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${FLATBUFFERS_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${FLATBUFFERS_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${FLATBUFFERS_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${FLATBUFFERS_CONTAINER_NAME}"
}

check_flatbuffers_container() {
    flatbuffers_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${FLATBUFFERS_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${FLATBUFFERS_CONTAINER_NAME}"
        return 40
    }
}

flatbuffers_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    flatbuffers_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${FLATBUFFERS_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${FLATBUFFERS_CONTAINER_NAME}" "$@"
}

flatbuffers_container_exec() { flatbuffers_docker_exec '' '' "$@"; }

flatbuffers_container_exec_at() {
    local workdir="$1"
    shift
    flatbuffers_docker_exec "${workdir}" '' "$@"
}

flatbuffers_container_exec_root() { flatbuffers_docker_exec '' root "$@"; }

flatbuffers_container_exec_root_at() {
    local workdir="$1"
    shift
    flatbuffers_docker_exec "${workdir}" root "$@"
}

remove_flatbuffers_container() {
    flatbuffers_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${FLATBUFFERS_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.flatbuffers.run-id"}}' "${FLATBUFFERS_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${FLATBUFFERS_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${FLATBUFFERS_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${FLATBUFFERS_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${FLATBUFFERS_CONTAINER_NAME}"
}
# >>> container-runtime:end
