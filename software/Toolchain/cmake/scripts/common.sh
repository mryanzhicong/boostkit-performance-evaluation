#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="cmake"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-4.4.5}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

CMAKE_VERSION="${SOFTWARE_VERSION}"
CMAKE_RELEASE_BASE="https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}"
# The official cmake.org file server publishes the identical release assets.
# Dedicated performance runners frequently cannot reach github.com (or reach it
# only at a few kB/s), so the official server is tried first; every candidate is
# verified against the same pinned SHA-256.
CMAKE_OFFICIAL_BASE="https://cmake.org/files/v${CMAKE_VERSION%.*}"

# Official distribution archives.  The digests are the ones published in the
# release's cmake-<version>-SHA-256.txt (the aarch64 and x86_64 entries were
# cross-checked against the release asset metadata).
CMAKE_X86_NAME="cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz"
CMAKE_ARM_NAME="cmake-${CMAKE_VERSION}-linux-aarch64.tar.gz"
CMAKE_X86_SHA256="ed85135c5a5135b45e50423cb406dea04ca3338da0b8ef3c9ede963559680be0"
CMAKE_ARM_SHA256="301d5063ab259577c1b57ce5490b1aab9ea5c56dc4c822f73499553dab94925f"

# Official source release archive, used as the upstream project workload and to
# prove the version from the registered release.  GitHub publishes this asset
# digest only through the release metadata; it was verified against the
# downloaded archive before this file was written.
CMAKE_SOURCE_NAME="cmake-${CMAKE_VERSION}.tar.gz"
CMAKE_SOURCE_SHA256="a0c54c88abb8078dd8eccadb717fc6bb194bf18e7d44c86309910288886e04e2"

CMAKE_OFFICIAL_SHA256_FILE="cmake-${CMAKE_VERSION}-SHA-256.txt"
CMAKE_OFFICIAL_SHA256_FILE_SHA256="f502d7058129606f8e468d2373178a5b48eb2c5f9785641b706f45952956dd25"

# Pre-placed offline assets are the preferred input; the directory is read-only
# for the case.  PERF_CMAKE_MIRROR may prefix GitHub download URLs for restricted
# networks (for example a GitHub release proxy used by a local workstation).
CMAKE_OFFLINE_DIR="${PERF_CMAKE_OFFLINE_DIR:-/home/runner/software/cmake}"
PERF_CMAKE_MIRROR="${PERF_CMAKE_MIRROR:-}"

CMAKE_SCALES=(100 1000 10000)
CMAKE_TASKS=(configure clean_build incremental_build noop_build)
CMAKE_UPSTREAM_SCENARIOS=(
    upstream_configure
    upstream_build
    upstream_incremental_build
    upstream_noop_build
)
CMAKE_UPSTREAM_BUILD_TARGET="cmake"
CMAKE_UPSTREAM_INCREMENTAL_SOURCE="Source/cmWorkingDirectory.cxx"

# One warm-up plus five independent measurements per scenario; the build
# parallelism is pinned so the measured build tasks never mix in the machine's
# core count and both architectures submit the same amount of work.
CMAKE_REPS="${PERF_REPS:-5}"
CMAKE_JOBS="${PERF_CMAKE_JOBS:-8}"

CMAKE_ARCHIVE_NAME=""
CMAKE_ARCHIVE_SHA256=""
CMAKE_ARCHIVE_URL=""
CMAKE_HOME=""
CMAKE_BIN=""
CMAKE_SOURCE_ARCHIVE=""
CMAKE_SOURCE_DIR=""
CMAKE_SOURCE_URL=""
CMAKE_INCREMENTAL_SOURCE_ORIG=""
PROJECTS_DIR=""
BENCH_DIR=""
RUNS_DIR=""
CMAKE_VERSION_STRING=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[cmake] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    [[ "${CMAKE_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${CMAKE_REPS}"
        return 10
    }
    if (( CMAKE_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${CMAKE_REPS} is a local link-validation value; formal evidence requires >= 5"
    fi
}

validate_jobs() {
    [[ "${CMAKE_JOBS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_CMAKE_JOBS must be a positive integer, got ${CMAKE_JOBS}"
        return 10
    }
    if (( CMAKE_JOBS > 256 )); then
        log_message "ERROR: PERF_CMAKE_JOBS is unreasonably large: ${CMAKE_JOBS}"
        return 10
    fi
}

select_cmake_archive() {
    case "${EXPECTED_ARCH}" in
        x86_64)
            CMAKE_ARCHIVE_NAME="${CMAKE_X86_NAME}"
            CMAKE_ARCHIVE_SHA256="${CMAKE_X86_SHA256}"
            ;;
        aarch64)
            CMAKE_ARCHIVE_NAME="${CMAKE_ARM_NAME}"
            CMAKE_ARCHIVE_SHA256="${CMAKE_ARM_SHA256}"
            ;;
        *)
            log_message "ERROR: no CMake distribution for architecture ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    CMAKE_ARCHIVE_URL="${CMAKE_RELEASE_BASE}/${CMAKE_ARCHIVE_NAME}"
    CMAKE_SOURCE_URL="${CMAKE_RELEASE_BASE}/${CMAKE_SOURCE_NAME}"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/cmake/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    select_cmake_archive || return $?
    CMAKE_HOME="${PERF_WORK_DIR}/cmake-install"
    CMAKE_BIN="${CMAKE_HOME}/bin/cmake"
    CMAKE_SOURCE_ARCHIVE="${PERF_WORK_DIR}/downloads/${CMAKE_SOURCE_NAME}"
    CMAKE_SOURCE_DIR="${PERF_WORK_DIR}/cmake-source"
    CMAKE_INCREMENTAL_SOURCE_ORIG="${PERF_WORK_DIR}/incremental-source.orig"
    PROJECTS_DIR="${PERF_WORK_DIR}/projects"
    BENCH_DIR="${PERF_WORK_DIR}/bench"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export SOFTWARE_NAME SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID
    export RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export CMAKE_VERSION CMAKE_HOME CMAKE_BIN CMAKE_SOURCE_DIR CMAKE_SOURCE_ARCHIVE
    export CMAKE_INCREMENTAL_SOURCE_ORIG
    export PROJECTS_DIR BENCH_DIR RUNS_DIR CMAKE_REPS CMAKE_JOBS
    export CMAKE_ARCHIVE_NAME CMAKE_ARCHIVE_SHA256 CMAKE_SOURCE_NAME CMAKE_SOURCE_SHA256
    export CMAKE_UPSTREAM_BUILD_TARGET CMAKE_UPSTREAM_INCREMENTAL_SOURCE
    export CMAKE_OFFLINE_DIR PERF_CMAKE_MIRROR CMAKE_OFFICIAL_BASE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

compiler_identity() {
    local compiler
    if ! compiler="$(cmake_container_exec cc --version 2>&1 | head -n 1)"; then
        compiler="unknown"
    fi
    printf '%s\n' "${compiler:-unknown}"
}

cmake_version_string() {
    cmake_container_exec "${CMAKE_BIN}" --version 2>&1 | head -n 1
}

# Configure arguments.  Both architectures use the same release build type, the
# same fixed optimisation flags and the same compiler driver (the Runner's cc).
# The upstream CMake build additionally disables its own tests and the system
# OpenSSL dependency so the workload depends only on the pinned source archive.
declare -ga PROJECT_CONFIGURE_ARGV=(
    -DCMAKE_BUILD_TYPE=Release
    '-DCMAKE_C_FLAGS_RELEASE=-O2 -DNDEBUG'
)
declare -ga UPSTREAM_CONFIGURE_ARGV=(
    -DCMAKE_BUILD_TYPE=Release
    '-DCMAKE_C_FLAGS_RELEASE=-O2 -DNDEBUG'
    '-DCMAKE_CXX_FLAGS_RELEASE=-O2 -DNDEBUG'
    -DBUILD_TESTING=OFF
    -DCMAKE_USE_OPENSSL=OFF
)

scenario_scale() {
    local scenario="$1"
    case "${scenario}" in
        upstream_*)
            printf 'upstream\n'
            return 0
            ;;
    esac
    printf '%s\n' "${scenario##*_}"
}

scenario_task() {
    local scenario="$1"
    case "${scenario}" in
        upstream_configure) printf 'configure\n' ;;
        upstream_incremental_build) printf 'incremental_build\n' ;;
        upstream_noop_build) printf 'noop_build\n' ;;
        *) printf '%s\n' "${scenario%_*}" ;;
    esac
}

scenario_list() {
    local scale task
    for scale in "${CMAKE_SCALES[@]}"; do
        for task in "${CMAKE_TASKS[@]}"; do
            printf '%s_%s\n' "${task}" "${scale}"
        done
    done
    printf '%s\n' "${CMAKE_UPSTREAM_SCENARIOS[@]}"
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
CMAKE_IMAGE_ARCHIVE_DIR="${CMAKE_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
CMAKE_CA_ANCHORS_DIR="${CMAKE_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
CMAKE_CONTAINER_IMAGE="${CMAKE_CONTAINER_IMAGE:-}"
CMAKE_CONTAINER_NAME="${CMAKE_CONTAINER_NAME:-}"
CMAKE_CONTAINER_HOME="${CMAKE_CONTAINER_HOME:-}"
declare -p CMAKE_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || CMAKE_CONTAINER_EXTRA_ARGS=()

cmake_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

cmake_configure_container() {
    local arch
    arch="$(cmake_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${CMAKE_CONTAINER_NAME}" ] || CMAKE_CONTAINER_NAME="boostkit-cmake-${arch}-${PERF_RUN_ID}"
    [ -n "${CMAKE_CONTAINER_HOME}" ] || CMAKE_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export CMAKE_CONTAINER_NAME CMAKE_CONTAINER_HOME
}

cmake_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_cmake_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_cmake_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${CMAKE_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_cmake_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(cmake_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${CMAKE_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${CMAKE_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        cmake_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        cmake_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    CMAKE_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${CMAKE_CONTAINER_IMAGE}" ] || ! docker image inspect "${CMAKE_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${CMAKE_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_cmake_container_image_release || return $?
    export CMAKE_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${CMAKE_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_cmake_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-cmake-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${CMAKE_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.cmake.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_cmake_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    cmake_configure_container
    require_cmake_docker || return $?
    if docker container inspect "${CMAKE_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${CMAKE_CONTAINER_NAME}"
        return 40
    fi
    sweep_cmake_stale_containers || true
    prepare_cmake_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${CMAKE_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${CMAKE_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${CMAKE_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${CMAKE_CONTAINER_HOME}" || return 40
    log_message "starting private container ${CMAKE_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${CMAKE_CONTAINER_NAME}" \
        --label "boostkit.cmake.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${CMAKE_CONTAINER_EXTRA_ARGS[@]}" \
        "${CMAKE_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${CMAKE_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${CMAKE_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${CMAKE_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${CMAKE_CONTAINER_NAME}"
}

check_cmake_container() {
    cmake_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${CMAKE_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${CMAKE_CONTAINER_NAME}"
        return 40
    }
}

cmake_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    cmake_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${CMAKE_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${CMAKE_CONTAINER_NAME}" "$@"
}

cmake_container_exec() { cmake_docker_exec '' '' "$@"; }

cmake_container_exec_at() {
    local workdir="$1"
    shift
    cmake_docker_exec "${workdir}" '' "$@"
}

cmake_container_exec_root() { cmake_docker_exec '' root "$@"; }

cmake_container_exec_root_at() {
    local workdir="$1"
    shift
    cmake_docker_exec "${workdir}" root "$@"
}

remove_cmake_container() {
    cmake_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${CMAKE_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.cmake.run-id"}}' "${CMAKE_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${CMAKE_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${CMAKE_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${CMAKE_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${CMAKE_CONTAINER_NAME}"
}
# >>> container-runtime:end
