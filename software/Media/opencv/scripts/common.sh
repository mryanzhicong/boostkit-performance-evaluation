#!/usr/bin/env bash
# ==============================================================================
# opencv 4.10.0 open-box image-processing performance case -- shared config.
# ==============================================================================
# The case reproduces the untouched open-box task material for OpenCV: the L1
# norm of a 1920x1080 gray8 frame (cv2.norm(gray, cv2.NORM_L1)) measured over 500
# calls per sample.  The reference harness pinned the process to CPU 88 and a
# NUMA memory node; this case pins nothing and runs natively inside a private
# openEuler 24.03 LTS SP4 container.  Single-threaded measurement is kept via
# cv2.setNumThreads(1) (a library setting, not CPU affinity), matching the
# reference material's "Parallel framework: none" build.
#
# Layout inside the per-run work directory (${PERF_WORK_DIR}):
#   downloads/opencv-4.10.0.tar.gz   verified source archive
#   opencv-4.10.0/build-bench-python OpenCV build tree
#   opencv-4.10.0/opencv_install     installed libraries + python3 bindings
#   bench                            per-run scratch files
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SOFTWARE_NAME="opencv"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-4.10.0}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# ------------------------------------------------------------------------------
# Sampling contract: five warm-up calls per scenario, then >=5 measured samples of
# 500 calls each (the reference material used exactly 5 + 20 x 500).
# ------------------------------------------------------------------------------
OPENCV_WARMUPS="${OPENCV_WARMUPS:-5}"
OPENCV_SAMPLES="${OPENCV_SAMPLES:-20}"
OPENCV_CALLS_PER_SAMPLE="${OPENCV_CALLS_PER_SAMPLE:-500}"
OPENCV_STATISTIC="median"

# ------------------------------------------------------------------------------
# Pinned source archive: same file the reference build_install.sh verifies.
# ------------------------------------------------------------------------------
OPENCV_ARCHIVE_NAME="opencv-${SOFTWARE_VERSION}.tar.gz"
OPENCV_ARCHIVE_SHA256="b2171af5be6b26f7a06b1229948bbb2bdaa74fcf5cd097e0af6378fce50a6eb9"
OPENCV_ARCHIVE_BYTES="94993429"
OPENCV_SOURCE_ARCHIVE_DIR="${OPENCV_SOURCE_ARCHIVE_DIR:-/home/runner/software/opencv/downloads}"
OPENCV_SOURCE_URL="https://codeload.github.com/opencv/opencv/tar.gz/refs/tags/${SOFTWARE_VERSION}"

# ------------------------------------------------------------------------------
# Open-box media (archived on the runners, never committed to git).
# ------------------------------------------------------------------------------
OPENCV_MEDIA_JSON="${SCRIPT_DIR}/fixtures/media.json"
OPENCV_MEDIA_CONTAINER_DIR="/media-input"
OPENCV_DEFAULT_MEDIA_DIRS=(
    "/home/runner/software/media/video"
    "/home/test/Test/video"
)
OPENCV_BUILD_JOBS="${OPENCV_BUILD_JOBS:-$(nproc)}"
OPENCV_CONTAINER_DEPS=(
    gcc gcc-c++ make cmake tar curl git pkg-config python3-devel python3-numpy
)

STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

OPENCV_SRC_DIR=""
OPENCV_BUILD_DIR=""
OPENCV_INSTALL_DIR=""
OPENCV_PYTHON_DIR=""
OPENCV_BENCH_DIR=""
OPENCV_RUNS_DIR=""
OPENCV_MEDIA_DIR="${OPENCV_MEDIA_DIR:-}"
OPENCV_LOG=""

log_message() {
    printf '[opencv] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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

validate_sampling() {
    if [[ ! "${OPENCV_WARMUPS}" =~ ^[0-9]+$ ]] || [[ "${OPENCV_WARMUPS}" -lt 1 ]]; then
        log_message "ERROR: OPENCV_WARMUPS must be a positive integer, got ${OPENCV_WARMUPS}"
        return 20
    fi
    if [[ ! "${OPENCV_SAMPLES}" =~ ^[0-9]+$ ]] || [[ "${OPENCV_SAMPLES}" -lt 5 ]]; then
        log_message "ERROR: OPENCV_SAMPLES must be an integer >= 5, got ${OPENCV_SAMPLES}"
        return 20
    fi
    if [[ ! "${OPENCV_CALLS_PER_SAMPLE}" =~ ^[0-9]+$ ]] || [[ "${OPENCV_CALLS_PER_SAMPLE}" -lt 1 ]]; then
        log_message "ERROR: OPENCV_CALLS_PER_SAMPLE must be a positive integer, got ${OPENCV_CALLS_PER_SAMPLE}"
        return 20
    fi
}

check_architecture() {
    local actual expected
    actual="$(normalize_architecture "$(uname -m)")"
    expected="$(normalize_architecture "${EXPECTED_ARCH}")"
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: expected architecture ${expected}, runner is ${actual}"
        return 20
    fi
}

configure_runtime_paths() {
    validate_variant || return $?
    validate_sampling || return $?
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
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
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/${SOFTWARE_NAME}/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi

    OPENCV_SRC_DIR="${PERF_WORK_DIR}/opencv-${SOFTWARE_VERSION}"
    OPENCV_BUILD_DIR="${OPENCV_SRC_DIR}/build-bench-python"
    OPENCV_INSTALL_DIR="${OPENCV_SRC_DIR}/opencv_install"
    OPENCV_PYTHON_DIR="${OPENCV_INSTALL_DIR}/python"
    OPENCV_BENCH_DIR="${PERF_WORK_DIR}/bench"
    OPENCV_RUNS_DIR="${RESULTS_DIR}/runs"
    OPENCV_LOG="${RESULTS_DIR}/benchmark_norm.txt"

    export SOFTWARE_NAME SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    export PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export OPENCV_WARMUPS OPENCV_SAMPLES OPENCV_CALLS_PER_SAMPLE OPENCV_STATISTIC
    export OPENCV_SRC_DIR OPENCV_BUILD_DIR OPENCV_INSTALL_DIR OPENCV_PYTHON_DIR
    export OPENCV_BENCH_DIR OPENCV_RUNS_DIR OPENCV_MEDIA_DIR OPENCV_LOG
    export OPENCV_ARCHIVE_NAME OPENCV_ARCHIVE_SHA256 OPENCV_SOURCE_ARCHIVE_DIR
    export OPENCV_BUILD_JOBS OPENCV_MEDIA_JSON OPENCV_MEDIA_CONTAINER_DIR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${OPENCV_RUNS_DIR}" \
        "${OPENCV_BENCH_DIR}" "${PERF_WORK_DIR}/downloads"
}

# ------------------------------------------------------------------------------
# Media discovery: env override, then the runner archive, then the material
# machine location.
# ------------------------------------------------------------------------------
opencv_resolve_media() {
    local candidate
    if [[ -n "${OPENCV_MEDIA_DIR}" ]] && [[ -d "${OPENCV_MEDIA_DIR}" ]]; then
        export OPENCV_MEDIA_DIR
        log_message "open-box media directory: ${OPENCV_MEDIA_DIR}"
        return 0
    fi
    for candidate in "${OPENCV_DEFAULT_MEDIA_DIRS[@]}"; do
        if [[ -d "${candidate}" ]]; then
            OPENCV_MEDIA_DIR="${candidate}"
            break
        fi
    done
    if [[ -z "${OPENCV_MEDIA_DIR}" ]] || [[ ! -d "${OPENCV_MEDIA_DIR}" ]]; then
        log_message "ERROR: open-box media directory is missing; set OPENCV_MEDIA_DIR"
        log_message "       checked: ${OPENCV_DEFAULT_MEDIA_DIRS[*]}"
        log_message "       expected inputs (see fixtures/media.json): BQTerrace / Film2012 / messi 1920x1080 YUV"
        return 40
    fi
    export OPENCV_MEDIA_DIR
    log_message "open-box media directory: ${OPENCV_MEDIA_DIR}"
}

opencv_require_host_tools() {
    local missing=() tool
    for tool in docker curl sha256sum tar; do
        command -v "${tool}" >/dev/null 2>&1 || missing+=("${tool}")
    done
    if [[ "${#missing[@]}" -ne 0 ]]; then
        log_message "ERROR: missing host tools: ${missing[*]}"
        return 30
    fi
}

opencv_media_mount_args() {
    local existing
    for existing in "${OPENCV_CONTAINER_EXTRA_ARGS[@]:-}"; do
        if [[ "${existing}" == *"target=${OPENCV_MEDIA_CONTAINER_DIR}"* ]]; then
            return 0
        fi
    done
    OPENCV_CONTAINER_EXTRA_ARGS+=(
        --mount "type=bind,source=${OPENCV_MEDIA_DIR},target=${OPENCV_MEDIA_CONTAINER_DIR},readonly"
    )
}

# ------------------------------------------------------------------------------
# Source archive: runner archive first, codeload only as a fallback.
# ------------------------------------------------------------------------------
opencv_verify_archive() {
    local path="$1" expected_sha="$2" expected_bytes="$3" actual bytes
    bytes="$(stat -c %s "${path}")"
    if [[ "${bytes}" != "${expected_bytes}" ]]; then
        log_message "ERROR: archive size mismatch: ${path} (${bytes} bytes, expected ${expected_bytes})"
        return 30
    fi
    actual="$(sha256sum "${path}" | awk '{print $1}')"
    if [[ "${actual}" != "${expected_sha}" ]]; then
        log_message "ERROR: archive checksum mismatch: ${path} (${actual})"
        return 30
    fi
}

opencv_fetch_archive() {
    local target="${PERF_WORK_DIR}/downloads/${OPENCV_ARCHIVE_NAME}"
    mkdir -p "${PERF_WORK_DIR}/downloads"
    if [[ -s "${target}" ]]; then
        log_message "reusing downloaded archive: ${target}"
    elif [[ -s "${OPENCV_SOURCE_ARCHIVE_DIR}/${OPENCV_ARCHIVE_NAME}" ]]; then
        log_message "using local source archive: ${OPENCV_SOURCE_ARCHIVE_DIR}/${OPENCV_ARCHIVE_NAME}"
        cp -f "${OPENCV_SOURCE_ARCHIVE_DIR}/${OPENCV_ARCHIVE_NAME}" "${target}.part" || return 30
        mv -f "${target}.part" "${target}" || return 30
    else
        log_message "local archive is absent; downloading ${OPENCV_SOURCE_URL}"
        opencv_with_proxy curl --fail --location --retry 2 --connect-timeout 20 \
            -o "${target}.part" "${OPENCV_SOURCE_URL}" || return 30
        mv -f "${target}.part" "${target}" || return 30
    fi
    opencv_verify_archive "${target}" "${OPENCV_ARCHIVE_SHA256}" "${OPENCV_ARCHIVE_BYTES}" || return $?
    log_message "verified source archive: OpenCV ${SOFTWARE_VERSION} (${OPENCV_ARCHIVE_SHA256:0:12})"
}

# ------------------------------------------------------------------------------
# Container-side probes
# ------------------------------------------------------------------------------
opencv_container_version() {
    opencv_container_exec env PYTHONPATH="${OPENCV_PYTHON_DIR}" \
        LD_LIBRARY_PATH="${OPENCV_INSTALL_DIR}/lib" \
        python3 -c 'import cv2; print(cv2.__version__)' 2>&1 | tail -n 1
}

opencv_verify_runtime_payload() {
    local version
    opencv_container_exec test -f "${OPENCV_INSTALL_DIR}/lib/libopencv_core.so" || {
        log_message "ERROR: libopencv_core.so is missing in the container: ${OPENCV_INSTALL_DIR}/lib"
        return 30
    }
    # OPENCV_SKIP_PYTHON_LOADER installs the raw extension module (cv2.<abi>.so)
    # instead of a cv2/ loader package, so look for the extension itself.
    opencv_container_exec bash -c "ls '${OPENCV_PYTHON_DIR}'/cv2*.so >/dev/null 2>&1" || {
        log_message "ERROR: the python3 bindings are missing in the container: ${OPENCV_PYTHON_DIR}/cv2*.so"
        return 30
    }
    version="$(opencv_container_version)" || return 30
    case "${version}" in
        *"${SOFTWARE_VERSION}"*) ;;
        *) log_message "ERROR: cv2 reports '${version}', expected ${SOFTWARE_VERSION}"; return 30 ;;
    esac
    log_message "container payload verified: cv2 ${version}"
}

opencv_media_probe() {
    local name
    for name in BQTerrace_1920x1080_60.yuv Film2012_1920x1080_25_8bit_8Mbps.yuv messi_1920x1080_25_1000.yuv; do
        opencv_container_exec test -r "${OPENCV_MEDIA_CONTAINER_DIR}/${name}" || {
            log_message "ERROR: media is not readable in the container: ${OPENCV_MEDIA_CONTAINER_DIR}/${name}"
            return 40
        }
    done
}

write_actual_version() {
    local version="${1:-${SOFTWARE_VERSION}}"
    printf '%s\n' "${version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 30
    log_message "recorded actual software version: $(cat "${PERF_ACTUAL_VERSION_FILE}")"
}

write_build_variant() {
    local payload
    payload="$(printf '{"variant":"%s","software":"%s","version":"%s","architecture":"%s","archive_sha256":"%s","container_image":"%s"}\n' \
        "${PERF_VARIANT}" "${SOFTWARE_NAME}" "${SOFTWARE_VERSION}" \
        "$(normalize_architecture "${EXPECTED_ARCH}")" \
        "${OPENCV_ARCHIVE_SHA256}" "${OPENCV_CONTAINER_IMAGE:-unknown}")"
    printf '%s' "${payload}" > "${RESULTS_DIR}/build_variant.json" || return 30
    log_message "recorded build variant: ${PERF_VARIANT}"
}

# The generated container block is appended below by
# adaptation/scripts/add-container-block.py; everything above stays hand-written.

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
OPENCV_IMAGE_ARCHIVE_DIR="${OPENCV_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
OPENCV_CA_ANCHORS_DIR="${OPENCV_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
OPENCV_CONTAINER_IMAGE="${OPENCV_CONTAINER_IMAGE:-}"
OPENCV_CONTAINER_NAME="${OPENCV_CONTAINER_NAME:-}"
OPENCV_CONTAINER_HOME="${OPENCV_CONTAINER_HOME:-}"
declare -p OPENCV_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || OPENCV_CONTAINER_EXTRA_ARGS=()

opencv_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

opencv_configure_container() {
    local arch
    arch="$(opencv_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${OPENCV_CONTAINER_NAME}" ] || OPENCV_CONTAINER_NAME="boostkit-opencv-${arch}-${PERF_RUN_ID}"
    [ -n "${OPENCV_CONTAINER_HOME}" ] || OPENCV_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export OPENCV_CONTAINER_NAME OPENCV_CONTAINER_HOME
}

opencv_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_opencv_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_opencv_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${OPENCV_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_opencv_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(opencv_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${OPENCV_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${OPENCV_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        opencv_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        opencv_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    OPENCV_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${OPENCV_CONTAINER_IMAGE}" ] || ! docker image inspect "${OPENCV_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${OPENCV_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_opencv_container_image_release || return $?
    export OPENCV_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${OPENCV_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_opencv_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-opencv-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${OPENCV_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.opencv.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_opencv_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    opencv_configure_container
    require_opencv_docker || return $?
    if docker container inspect "${OPENCV_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${OPENCV_CONTAINER_NAME}"
        return 40
    fi
    sweep_opencv_stale_containers || true
    prepare_opencv_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${OPENCV_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${OPENCV_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${OPENCV_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${OPENCV_CONTAINER_HOME}" || return 40
    log_message "starting private container ${OPENCV_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${OPENCV_CONTAINER_NAME}" \
        --label "boostkit.opencv.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${OPENCV_CONTAINER_EXTRA_ARGS[@]}" \
        "${OPENCV_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${OPENCV_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${OPENCV_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${OPENCV_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${OPENCV_CONTAINER_NAME}"
}

check_opencv_container() {
    opencv_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${OPENCV_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${OPENCV_CONTAINER_NAME}"
        return 40
    }
}

opencv_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    opencv_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${OPENCV_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${OPENCV_CONTAINER_NAME}" "$@"
}

opencv_container_exec() { opencv_docker_exec '' '' "$@"; }

opencv_container_exec_at() {
    local workdir="$1"
    shift
    opencv_docker_exec "${workdir}" '' "$@"
}

opencv_container_exec_root() { opencv_docker_exec '' root "$@"; }

opencv_container_exec_root_at() {
    local workdir="$1"
    shift
    opencv_docker_exec "${workdir}" root "$@"
}

remove_opencv_container() {
    opencv_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${OPENCV_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.opencv.run-id"}}' "${OPENCV_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${OPENCV_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${OPENCV_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${OPENCV_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${OPENCV_CONTAINER_NAME}"
}
# >>> container-runtime:end
