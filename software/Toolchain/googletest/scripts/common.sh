#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="googletest"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.18.0}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

GOOGLETEST_VERSION="${SOFTWARE_VERSION}"
GOOGLETEST_SOURCE_NAME="googletest-${GOOGLETEST_VERSION}.tar.gz"

# The release asset is the official source distribution published on the
# GoogleTest GitHub release page.  Its SHA-256 equals the digest GitHub reports
# for the asset through the releases API (upstream-published value), and it is
# reproduced byte-for-byte through two independent mirror paths.
GOOGLETEST_SOURCE_SHA256="6e3191c1455468b3fc35a417fb565c1c5071aee1b7e7f85e30cf48a98d37d8b5"
GOOGLETEST_SOURCE_SIZE=894741
GOOGLETEST_SOURCE_URL="https://github.com/google/googletest/releases/download/v${GOOGLETEST_VERSION}/${GOOGLETEST_SOURCE_NAME}"

# Fallback order: the Runner cannot reliably reach github.com, so the public
# GitHub mirrors are tried before the canonical URL gets its last chance.  Every
# candidate must produce the same SHA-256.
GOOGLETEST_SOURCE_URLS=(
    "https://gh-proxy.com/https://github.com/google/googletest/releases/download/v${GOOGLETEST_VERSION}/${GOOGLETEST_SOURCE_NAME}"
    "https://ghfast.top/https://github.com/google/googletest/releases/download/v${GOOGLETEST_VERSION}/${GOOGLETEST_SOURCE_NAME}"
    "${GOOGLETEST_SOURCE_URL}"
)

GOOGLETEST_OFFLINE_DIR="${PERF_GOOGLETEST_OFFLINE_DIR:-/home/runner/software/googletest}"

GOOGLETEST_JOBS="${PERF_GOOGLETEST_JOBS:-4}"
GOOGLETEST_REPS="${PERF_REPS:-5}"

# Pinned assertion-matrix sizes.  The first one is the representative load of
# the delivery manual (1000 successful assertion tests), the second one scales
# the registration/dispatch overhead, and the third measures the assertion
# macro itself inside one test body.
GOOGLETEST_MATRIX_1K=1000
GOOGLETEST_MATRIX_10K=10000
GOOGLETEST_ASSERTION_LOOP=5000000

# Upstream test suite: `gtest_unittest`, built from the same release archive.
# The pinned summary is the deterministic test count of 1.18.0.
GOOGLETEST_UPSTREAM_TESTS=434
GOOGLETEST_UPSTREAM_SUITES=104

GOOGLETEST_SCENARIOS=(
    upstream_gtest_unittest
    matrix_1k
    matrix_10k
    assertion_loop_5m
)
GOOGLETEST_MATRIX_SCENARIOS=(
    matrix_1k
    matrix_10k
    assertion_loop_5m
)

GOOGLETEST_SOURCE_ARCHIVE=""
GOOGLETEST_SRC_DIR=""
GOOGLETEST_BUILD_DIR=""
GOOGLETEST_MATRIX_BIN_DIR=""
GOOGLETEST_UPSTREAM_BIN=""
RUNS_DIR=""
GOOGLETEST_VERSION_STRING=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[googletest] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
}

report_failure_tail() {
    local log_file="$1" scenario="$2" label="$3" exit_code="$4"
    log_message "ERROR: ${scenario} (${label}) failed with exit code ${exit_code}"
    if [[ -s "${log_file}" ]]; then
        log_message "----- begin tail of ${log_file} (last 60 lines) -----"
        tail -n 60 -- "${log_file}" | while IFS= read -r line; do
            printf '[googletest]   %s\n' "${line}"
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
    [[ "${GOOGLETEST_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${GOOGLETEST_REPS}"
        return 10
    }
    if (( GOOGLETEST_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${GOOGLETEST_REPS} is a local link-validation value; formal evidence requires >= 5"
    fi
}

validate_jobs() {
    [[ "${GOOGLETEST_JOBS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_GOOGLETEST_JOBS must be a positive integer, got ${GOOGLETEST_JOBS}"
        return 10
    }
    if (( GOOGLETEST_JOBS > 64 )); then
        log_message "ERROR: PERF_GOOGLETEST_JOBS is unreasonably large: ${GOOGLETEST_JOBS}"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/googletest/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    GOOGLETEST_SOURCE_ARCHIVE="${PERF_WORK_DIR}/downloads/${GOOGLETEST_SOURCE_NAME}"
    GOOGLETEST_SRC_DIR="${PERF_WORK_DIR}/googletest-source"
    GOOGLETEST_BUILD_DIR="${PERF_WORK_DIR}/build"
    GOOGLETEST_MATRIX_BIN_DIR="${PERF_WORK_DIR}/bin"
    GOOGLETEST_UPSTREAM_BIN="${GOOGLETEST_BUILD_DIR}/googletest/gtest_unittest"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export SOFTWARE_NAME SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID
    export RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export GOOGLETEST_VERSION GOOGLETEST_SRC_DIR GOOGLETEST_BUILD_DIR
    export GOOGLETEST_MATRIX_BIN_DIR GOOGLETEST_UPSTREAM_BIN
    export GOOGLETEST_SOURCE_ARCHIVE RUNS_DIR GOOGLETEST_REPS GOOGLETEST_JOBS
    export GOOGLETEST_SOURCE_NAME GOOGLETEST_SOURCE_SHA256 GOOGLETEST_SOURCE_SIZE
    export GOOGLETEST_SOURCE_URL GOOGLETEST_OFFLINE_DIR
    export GOOGLETEST_MATRIX_1K GOOGLETEST_MATRIX_10K GOOGLETEST_ASSERTION_LOOP
    export GOOGLETEST_UPSTREAM_TESTS GOOGLETEST_UPSTREAM_SUITES
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

compiler_identity() {
    local compiler
    # The compiler that actually built GoogleTest lives inside the private
    # container, so provenance records the container toolchain.
    if ! compiler="$(googletest_container_exec c++ --version 2>&1 | head -n 1)"; then
        compiler="unknown"
    fi
    printf '%s\n' "${compiler:-unknown}"
}

# GoogleTest's public headers do not export a runtime version string, so the
# declared version of the extracted source distribution is the version record.
decode_googletest_version() {
    local source_dir="$1"
    local line=""
    if [[ -f "${source_dir}/CMakeLists.txt" ]]; then
        line="$(sed -n 's/^set(GOOGLETEST_VERSION[[:space:]]*\([0-9][0-9.]*\))$/\1/p' \
            "${source_dir}/CMakeLists.txt" | head -n 1)"
    fi
    if [[ "${line}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        printf '%s\n' "${line}"
        return 0
    fi
    return 1
}

googletest_version_string() {
    local version
    if ! version="$(decode_googletest_version "${GOOGLETEST_SRC_DIR}")"; then
        printf 'unknown\n'
        return 0
    fi
    printf 'GoogleTest %s (source distribution)\n' "${version}"
}

scenario_task() {
    case "$1" in
        upstream_gtest_unittest) printf 'upstream_suite\n' ;;
        *) printf 'assertion_matrix\n' ;;
    esac
}

# (mode|tests|assertions) for one matrix scenario.
matrix_parameters() {
    case "$1" in
        matrix_1k) printf 'registered|%s|0\n' "${GOOGLETEST_MATRIX_1K}" ;;
        matrix_10k) printf 'registered|%s|0\n' "${GOOGLETEST_MATRIX_10K}" ;;
        assertion_loop_5m) printf 'loop|0|%s\n' "${GOOGLETEST_ASSERTION_LOOP}" ;;
        *) log_message "ERROR: unknown matrix scenario: $1"; return 1 ;;
    esac
}

# Binary name of one matrix scenario.
matrix_binary() {
    case "$1" in
        matrix_1k) printf 'gtest_matrix_1k\n' ;;
        matrix_10k) printf 'gtest_matrix_10k\n' ;;
        assertion_loop_5m) printf 'gtest_assertion_loop\n' ;;
        *) return 1 ;;
    esac
}

# Number of tests that must be reported as PASSED for one scenario.
matrix_expected_passed() {
    case "$1" in
        matrix_1k) printf '%s\n' "${GOOGLETEST_MATRIX_1K}" ;;
        matrix_10k) printf '%s\n' "${GOOGLETEST_MATRIX_10K}" ;;
        assertion_loop_5m) printf '1\n' ;;
        *) return 1 ;;
    esac
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
GOOGLETEST_IMAGE_ARCHIVE_DIR="${GOOGLETEST_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
GOOGLETEST_CA_ANCHORS_DIR="${GOOGLETEST_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
GOOGLETEST_CONTAINER_IMAGE="${GOOGLETEST_CONTAINER_IMAGE:-}"
GOOGLETEST_CONTAINER_NAME="${GOOGLETEST_CONTAINER_NAME:-}"
GOOGLETEST_CONTAINER_HOME="${GOOGLETEST_CONTAINER_HOME:-}"
declare -p GOOGLETEST_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || GOOGLETEST_CONTAINER_EXTRA_ARGS=()

googletest_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

googletest_configure_container() {
    local arch
    arch="$(googletest_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${GOOGLETEST_CONTAINER_NAME}" ] || GOOGLETEST_CONTAINER_NAME="boostkit-googletest-${arch}-${PERF_RUN_ID}"
    [ -n "${GOOGLETEST_CONTAINER_HOME}" ] || GOOGLETEST_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export GOOGLETEST_CONTAINER_NAME GOOGLETEST_CONTAINER_HOME
}

googletest_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_googletest_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_googletest_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${GOOGLETEST_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_googletest_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(googletest_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${GOOGLETEST_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${GOOGLETEST_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        googletest_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        googletest_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    GOOGLETEST_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${GOOGLETEST_CONTAINER_IMAGE}" ] || ! docker image inspect "${GOOGLETEST_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${GOOGLETEST_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_googletest_container_image_release || return $?
    export GOOGLETEST_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${GOOGLETEST_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_googletest_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-googletest-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${GOOGLETEST_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.googletest.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_googletest_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    googletest_configure_container
    require_googletest_docker || return $?
    if docker container inspect "${GOOGLETEST_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${GOOGLETEST_CONTAINER_NAME}"
        return 40
    fi
    sweep_googletest_stale_containers || true
    prepare_googletest_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${GOOGLETEST_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${GOOGLETEST_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${GOOGLETEST_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${GOOGLETEST_CONTAINER_HOME}" || return 40
    log_message "starting private container ${GOOGLETEST_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${GOOGLETEST_CONTAINER_NAME}" \
        --label "boostkit.googletest.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${GOOGLETEST_CONTAINER_EXTRA_ARGS[@]}" \
        "${GOOGLETEST_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${GOOGLETEST_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${GOOGLETEST_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${GOOGLETEST_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${GOOGLETEST_CONTAINER_NAME}"
}

check_googletest_container() {
    googletest_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${GOOGLETEST_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${GOOGLETEST_CONTAINER_NAME}"
        return 40
    }
}

googletest_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    googletest_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${GOOGLETEST_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${GOOGLETEST_CONTAINER_NAME}" "$@"
}

googletest_container_exec() { googletest_docker_exec '' '' "$@"; }

googletest_container_exec_at() {
    local workdir="$1"
    shift
    googletest_docker_exec "${workdir}" '' "$@"
}

googletest_container_exec_root() { googletest_docker_exec '' root "$@"; }

googletest_container_exec_root_at() {
    local workdir="$1"
    shift
    googletest_docker_exec "${workdir}" root "$@"
}

remove_googletest_container() {
    googletest_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${GOOGLETEST_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.googletest.run-id"}}' "${GOOGLETEST_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${GOOGLETEST_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${GOOGLETEST_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${GOOGLETEST_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${GOOGLETEST_CONTAINER_NAME}"
}
# >>> container-runtime:end
