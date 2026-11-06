#!/usr/bin/env bash
# ==============================================================================
# libwebp 1.2.1 open-box decode performance case -- shared configuration.
# ==============================================================================
# The case reproduces the untouched open-box task material for libwebp: one
# lossy WebP decode scenario generated from the first frame of Film2012.  The
# reference harness pinned two logical CPUs and a NUMA memory node; this case
# deliberately does NOT pin anything -- the whole measurement runs natively
# inside a private openEuler 24.03 LTS SP4 container, so the numbers describe an
# out-of-the-box deployment instead of a hand-tuned one.
#
# Layout inside the per-run work directory (${PERF_WORK_DIR}):
#   downloads/libwebp-1.2.1.tar.gz   verified source archive
#   libwebp-1.2.1/build              CMake build tree
#   libwebp-1.2.1/webp_install       installed libwebp (bin/cwebp, bin/dwebp)
#   bench                            generated PNG/PPM/WebP inputs and outputs
#   home                             container HOME
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SOFTWARE_NAME="libwebp"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.2.1}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# ------------------------------------------------------------------------------
# Sampling contract: >=1 warm-up and >=5 measured samples, all samples kept.
# The reference material timed 20 iterations; that stays the default.
# ------------------------------------------------------------------------------
LIBWEBP_WARMUPS="${LIBWEBP_WARMUPS:-1}"
LIBWEBP_SAMPLES="${LIBWEBP_SAMPLES:-20}"
LIBWEBP_STATISTIC="median"

# ------------------------------------------------------------------------------
# Pinned source archive (same file the reference build_install.sh verifies).
# ------------------------------------------------------------------------------
LIBWEBP_ARCHIVE_NAME="libwebp-${SOFTWARE_VERSION}.tar.gz"
LIBWEBP_ARCHIVE_SHA256="808b98d2f5b84e9b27fdef6c5372dac769c3bda4502febbfa5031bd3c4d7d018"
LIBWEBP_ARCHIVE_BYTES="4100806"
LIBWEBP_SOURCE_ARCHIVE_DIR="${LIBWEBP_SOURCE_ARCHIVE_DIR:-/home/runner/software/libwebp/downloads}"
LIBWEBP_SOURCE_URLS=(
    "https://storage.googleapis.com/downloads.webmproject.org/releases/webp/${LIBWEBP_ARCHIVE_NAME}"
    "https://webmproject.storage.googleapis.com/downloads.webmproject.org/releases/webp/${LIBWEBP_ARCHIVE_NAME}"
    "https://gh-proxy.com/https://storage.googleapis.com/downloads.webmproject.org/releases/webp/${LIBWEBP_ARCHIVE_NAME}"
)

# ------------------------------------------------------------------------------
# Open-box media (archived on the runners, never committed to git).
# ------------------------------------------------------------------------------
LIBWEBP_MEDIA_JSON="${SCRIPT_DIR}/fixtures/media.json"
LIBWEBP_MEDIA_CONTAINER_DIR="/media-input"
LIBWEBP_DEFAULT_MEDIA_DIRS=(
    "/home/runner/software/media/video"
    "/home/test/Test/video"
)
LIBWEBP_BUILD_JOBS="${LIBWEBP_BUILD_JOBS:-$(nproc)}"
LIBWEBP_CONTAINER_DEPS=(
    gcc gcc-c++ make cmake tar curl python3
)
if [[ "$(uname -m)" == x86_64 ]]; then
    LIBWEBP_CONTAINER_DEPS+=(nasm)
fi

STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

LIBWEBP_SRC_DIR=""
LIBWEBP_BUILD_DIR=""
LIBWEBP_INSTALL_DIR=""
LIBWEBP_BENCH_DIR=""
LIBWEBP_RUNS_DIR=""
LIBWEBP_MEDIA_DIR="${LIBWEBP_MEDIA_DIR:-}"
LIBWEBP_LOG=""

log_message() {
    printf '[libwebp] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    if [[ ! "${LIBWEBP_WARMUPS}" =~ ^[0-9]+$ ]] || [[ "${LIBWEBP_WARMUPS}" -lt 1 ]]; then
        log_message "ERROR: LIBWEBP_WARMUPS must be a positive integer, got ${LIBWEBP_WARMUPS}"
        return 20
    fi
    if [[ ! "${LIBWEBP_SAMPLES}" =~ ^[0-9]+$ ]] || [[ "${LIBWEBP_SAMPLES}" -lt 5 ]]; then
        log_message "ERROR: LIBWEBP_SAMPLES must be an integer >= 5, got ${LIBWEBP_SAMPLES}"
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

    LIBWEBP_SRC_DIR="${PERF_WORK_DIR}/libwebp-${SOFTWARE_VERSION}"
    LIBWEBP_BUILD_DIR="${LIBWEBP_SRC_DIR}/build"
    LIBWEBP_INSTALL_DIR="${LIBWEBP_SRC_DIR}/webp_install"
    LIBWEBP_BENCH_DIR="${PERF_WORK_DIR}/bench"
    LIBWEBP_RUNS_DIR="${RESULTS_DIR}/runs"
    LIBWEBP_LOG="${RESULTS_DIR}/benchmark_decode.txt"

    export SOFTWARE_NAME SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    export PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export LIBWEBP_WARMUPS LIBWEBP_SAMPLES LIBWEBP_STATISTIC
    export LIBWEBP_SRC_DIR LIBWEBP_BUILD_DIR LIBWEBP_INSTALL_DIR LIBWEBP_BENCH_DIR
    export LIBWEBP_RUNS_DIR LIBWEBP_MEDIA_DIR LIBWEBP_LOG
    export LIBWEBP_ARCHIVE_NAME LIBWEBP_ARCHIVE_SHA256 LIBWEBP_SOURCE_ARCHIVE_DIR
    export LIBWEBP_BUILD_JOBS LIBWEBP_MEDIA_JSON LIBWEBP_MEDIA_CONTAINER_DIR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${LIBWEBP_RUNS_DIR}" \
        "${LIBWEBP_BENCH_DIR}" "${PERF_WORK_DIR}/downloads"
}

# ------------------------------------------------------------------------------
# Media discovery: env override, then the runner archive, then the material
# machine location.  Shared by the build (early fail-fast) and test stages.
# ------------------------------------------------------------------------------
libwebp_resolve_media() {
    local candidate
    if [[ -n "${LIBWEBP_MEDIA_DIR}" ]] && [[ -d "${LIBWEBP_MEDIA_DIR}" ]]; then
        export LIBWEBP_MEDIA_DIR
        log_message "open-box media directory: ${LIBWEBP_MEDIA_DIR}"
        return 0
    fi
    for candidate in "${LIBWEBP_DEFAULT_MEDIA_DIRS[@]}"; do
        if [[ -d "${candidate}" ]]; then
            LIBWEBP_MEDIA_DIR="${candidate}"
            break
        fi
    done
    if [[ -z "${LIBWEBP_MEDIA_DIR}" ]] || [[ ! -d "${LIBWEBP_MEDIA_DIR}" ]]; then
        log_message "ERROR: open-box media directory is missing; set LIBWEBP_MEDIA_DIR"
        log_message "       checked: ${LIBWEBP_DEFAULT_MEDIA_DIRS[*]}"
        log_message "       expected inputs (see fixtures/media.json): Film2012_1920x1080_25_8bit_8Mbps.yuv"
        return 40
    fi
    export LIBWEBP_MEDIA_DIR
    log_message "open-box media directory: ${LIBWEBP_MEDIA_DIR}"
}

libwebp_require_host_tools() {
    local missing=() tool
    for tool in docker curl sha256sum tar; do
        command -v "${tool}" >/dev/null 2>&1 || missing+=("${tool}")
    done
    if [[ "${#missing[@]}" -ne 0 ]]; then
        log_message "ERROR: missing host tools: ${missing[*]}"
        return 30
    fi
}

# Mount the media directory read-only at a fixed container path so the harness
# never needs to know where the runners keep the archive.
libwebp_media_mount_args() {
    local existing
    for existing in "${LIBWEBP_CONTAINER_EXTRA_ARGS[@]:-}"; do
        if [[ "${existing}" == *"target=${LIBWEBP_MEDIA_CONTAINER_DIR}"* ]]; then
            return 0
        fi
    done
    LIBWEBP_CONTAINER_EXTRA_ARGS+=(
        --mount "type=bind,source=${LIBWEBP_MEDIA_DIR},target=${LIBWEBP_MEDIA_CONTAINER_DIR},readonly"
    )
}

# ------------------------------------------------------------------------------
# Source archive: local runner archive first, download only as a fallback.
# ------------------------------------------------------------------------------
libwebp_fetch_archive() {
    local archive="${LIBWEBP_SOURCE_ARCHIVE_DIR}/${LIBWEBP_ARCHIVE_NAME}"
    local target="${PERF_WORK_DIR}/downloads/${LIBWEBP_ARCHIVE_NAME}"
    local url
    mkdir -p "${PERF_WORK_DIR}/downloads"
    if [[ -e "${archive}" ]]; then
        if [[ ! -s "${archive}" ]]; then
            log_message "ERROR: local source archive is empty: ${archive}"
            return 30
        fi
        log_message "using local source archive: ${archive}"
        cp -f "${archive}" "${target}.part" || return 30
        mv -f "${target}.part" "${target}" || return 30
    else
        log_message "local source archive is absent; downloading ${LIBWEBP_ARCHIVE_NAME}"
        local downloaded=0
        for url in "${LIBWEBP_SOURCE_URLS[@]}"; do
            if libwebp_with_proxy curl -fSL --retry 2 --connect-timeout 30 \
                -o "${target}.part" "${url}"; then
                mv -f "${target}.part" "${target}" || return 30
                downloaded=1
                log_message "downloaded ${LIBWEBP_ARCHIVE_NAME} from ${url}"
                break
            fi
            log_message "WARNING: source download failed: ${url}"
        done
        if [[ "${downloaded}" -ne 1 ]]; then
            log_message "ERROR: every source archive location failed"
            return 30
        fi
    fi
    libwebp_verify_archive "${target}" || return $?
    LIBWEBP_ARCHIVE_PATH="${target}"
    export LIBWEBP_ARCHIVE_PATH
    log_message "verified source archive: ${target} (sha256 ${LIBWEBP_ARCHIVE_SHA256})"
}

libwebp_verify_archive() {
    local path="$1" actual bytes
    bytes="$(stat -c %s "${path}")"
    if [[ "${bytes}" != "${LIBWEBP_ARCHIVE_BYTES}" ]]; then
        log_message "ERROR: source archive size mismatch: ${path} (${bytes} bytes, expected ${LIBWEBP_ARCHIVE_BYTES})"
        return 30
    fi
    actual="$(sha256sum "${path}" | awk '{print $1}')"
    if [[ "${actual}" != "${LIBWEBP_ARCHIVE_SHA256}" ]]; then
        log_message "ERROR: source archive checksum mismatch: ${path} (${actual})"
        return 30
    fi
}

# ------------------------------------------------------------------------------
# Container-side probes
# ------------------------------------------------------------------------------
libwebp_container_version() {
    local binary="$1"
    libwebp_container_exec env LD_LIBRARY_PATH="${LIBWEBP_INSTALL_DIR}/lib" \
        "${binary}" -version 2>&1 | head -n 1
}

libwebp_verify_runtime_payload() {
    local cwebp_version dwebp_version
    libwebp_container_exec test -x "${LIBWEBP_INSTALL_DIR}/bin/cwebp" || {
        log_message "ERROR: cwebp is missing in the container: ${LIBWEBP_INSTALL_DIR}/bin/cwebp"
        return 30
    }
    libwebp_container_exec test -x "${LIBWEBP_INSTALL_DIR}/bin/dwebp" || {
        log_message "ERROR: dwebp is missing in the container: ${LIBWEBP_INSTALL_DIR}/bin/dwebp"
        return 30
    }
    cwebp_version="$(libwebp_container_version "${LIBWEBP_INSTALL_DIR}/bin/cwebp")" || return 30
    case "${cwebp_version}" in
        *"${SOFTWARE_VERSION}"*) ;;
        *) log_message "ERROR: cwebp reports '${cwebp_version}', expected ${SOFTWARE_VERSION}"; return 30 ;;
    esac
    dwebp_version="$(libwebp_container_version "${LIBWEBP_INSTALL_DIR}/bin/dwebp")" || return 30
    case "${dwebp_version}" in
        *"${SOFTWARE_VERSION}"*) ;;
        *) log_message "ERROR: dwebp reports '${dwebp_version}', expected ${SOFTWARE_VERSION}"; return 30 ;;
    esac
    log_message "container payload verified: ${cwebp_version} / ${dwebp_version}"
}

libwebp_media_probe() {
    libwebp_container_exec test -r "${LIBWEBP_MEDIA_CONTAINER_DIR}/Film2012_1920x1080_25_8bit_8Mbps.yuv" || {
        log_message "ERROR: media is not readable in the container: ${LIBWEBP_MEDIA_CONTAINER_DIR}"
        return 40
    }
}

write_actual_version() {
    local version="${1:-${SOFTWARE_VERSION}}"
    printf '%s\n' "${version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 30
    log_message "recorded actual software version: $(cat "${PERF_ACTUAL_VERSION_FILE}")"
}

write_build_variant() {
    local payload
    payload="$(printf '{"variant":"%s","software":"%s","version":"%s","architecture":"%s","source_archive":"%s","source_sha256":"%s","container_image":"%s"}\n' \
        "${PERF_VARIANT}" "${SOFTWARE_NAME}" "${SOFTWARE_VERSION}" \
        "$(normalize_architecture "${EXPECTED_ARCH}")" \
        "${LIBWEBP_ARCHIVE_NAME}" "${LIBWEBP_ARCHIVE_SHA256}" "${LIBWEBP_CONTAINER_IMAGE:-unknown}")"
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
LIBWEBP_IMAGE_ARCHIVE_DIR="${LIBWEBP_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
LIBWEBP_CA_ANCHORS_DIR="${LIBWEBP_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
LIBWEBP_CONTAINER_IMAGE="${LIBWEBP_CONTAINER_IMAGE:-}"
LIBWEBP_CONTAINER_NAME="${LIBWEBP_CONTAINER_NAME:-}"
LIBWEBP_CONTAINER_HOME="${LIBWEBP_CONTAINER_HOME:-}"
declare -p LIBWEBP_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || LIBWEBP_CONTAINER_EXTRA_ARGS=()

libwebp_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

libwebp_configure_container() {
    local arch
    arch="$(libwebp_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${LIBWEBP_CONTAINER_NAME}" ] || LIBWEBP_CONTAINER_NAME="boostkit-libwebp-${arch}-${PERF_RUN_ID}"
    [ -n "${LIBWEBP_CONTAINER_HOME}" ] || LIBWEBP_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export LIBWEBP_CONTAINER_NAME LIBWEBP_CONTAINER_HOME
}

libwebp_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_libwebp_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_libwebp_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${LIBWEBP_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_libwebp_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(libwebp_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${LIBWEBP_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${LIBWEBP_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        libwebp_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        libwebp_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    LIBWEBP_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${LIBWEBP_CONTAINER_IMAGE}" ] || ! docker image inspect "${LIBWEBP_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${LIBWEBP_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_libwebp_container_image_release || return $?
    export LIBWEBP_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${LIBWEBP_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_libwebp_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-libwebp-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${LIBWEBP_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.libwebp.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_libwebp_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    libwebp_configure_container
    require_libwebp_docker || return $?
    if docker container inspect "${LIBWEBP_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${LIBWEBP_CONTAINER_NAME}"
        return 40
    fi
    sweep_libwebp_stale_containers || true
    prepare_libwebp_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${LIBWEBP_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${LIBWEBP_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${LIBWEBP_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${LIBWEBP_CONTAINER_HOME}" || return 40
    log_message "starting private container ${LIBWEBP_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${LIBWEBP_CONTAINER_NAME}" \
        --label "boostkit.libwebp.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${LIBWEBP_CONTAINER_EXTRA_ARGS[@]}" \
        "${LIBWEBP_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${LIBWEBP_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${LIBWEBP_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${LIBWEBP_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${LIBWEBP_CONTAINER_NAME}"
}

check_libwebp_container() {
    libwebp_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${LIBWEBP_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${LIBWEBP_CONTAINER_NAME}"
        return 40
    }
}

libwebp_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    libwebp_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${LIBWEBP_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${LIBWEBP_CONTAINER_NAME}" "$@"
}

libwebp_container_exec() { libwebp_docker_exec '' '' "$@"; }

libwebp_container_exec_at() {
    local workdir="$1"
    shift
    libwebp_docker_exec "${workdir}" '' "$@"
}

libwebp_container_exec_root() { libwebp_docker_exec '' root "$@"; }

libwebp_container_exec_root_at() {
    local workdir="$1"
    shift
    libwebp_docker_exec "${workdir}" root "$@"
}

remove_libwebp_container() {
    libwebp_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${LIBWEBP_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.libwebp.run-id"}}' "${LIBWEBP_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${LIBWEBP_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${LIBWEBP_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${LIBWEBP_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${LIBWEBP_CONTAINER_NAME}"
}
# >>> container-runtime:end
