#!/usr/bin/env bash
# ==============================================================================
# libavif 0.9.3 open-box AV1 encode performance case -- shared configuration.
# ==============================================================================
# The case reproduces the current open-box task material for libavif + AOM
# (Test/libavif @ 6c69c13d): three 1920x1080 frame-0 images encoded at QP 20 and
# QP 32 with avifenc (AOM, speed 8, 8 jobs, 1x4 tiles), one warm-up plus N timed
# samples per scenario and the mean reported.  The reference material no longer
# pins CPUs or NUMA nodes, so this case pins nothing either -- everything runs
# natively inside a private openEuler 24.03 LTS SP4 container, so the numbers
# describe an out-of-the-box deployment.
#
# Layout inside the per-run work directory (${PERF_WORK_DIR}):
#   downloads/{libavif-0.9.3,aom-3.2.0}.tar.gz   verified source archives
#   aom-3.2.0/build                              AOM build tree
#   libavif-0.9.3/build                          libavif build tree
#   libavif-0.9.3/avif_install                   installed avifenc/avifdec + libs
#   bench                                        generated PNG/AVIF/Y4M files
#   home                                         container HOME
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SOFTWARE_NAME="libavif"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-0.9.3}"
AOM_VERSION="3.2.0"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# ------------------------------------------------------------------------------
# Sampling contract: >=1 warm-up and >=5 measured samples per scenario, all
# samples kept, and the reported statistic is the MEAN of the timed samples.
# The reference material timed 20 iterations and reports their mean; that stays
# the default (6 scenarios x 20 samples = 120 encodes).  The warm-up encode and
# decode are untimed and only their sha256 digests are recorded as evidence --
# they are not compared against later iterations, and the encoder thread count
# is not observed (the declared native_threads value is documentation only).
# ------------------------------------------------------------------------------
LIBAVIF_WARMUPS="${LIBAVIF_WARMUPS:-1}"
LIBAVIF_SAMPLES="${LIBAVIF_SAMPLES:-20}"
LIBAVIF_STATISTIC="mean"

# ------------------------------------------------------------------------------
# Pinned source archives: the same files the reference build_install.sh verifies.
# ------------------------------------------------------------------------------
LIBAVIF_ARCHIVE_NAME="libavif-${SOFTWARE_VERSION}.tar.gz"
LIBAVIF_ARCHIVE_SHA256="bcd9a1f57f982a9615eb7e2faf87236dc88eb1d0c886f3471c7440ead605060d"
LIBAVIF_ARCHIVE_BYTES="2000521"
AOM_ARCHIVE_NAME="aom-${AOM_VERSION}.tar.gz"
AOM_ARCHIVE_SHA256="34132ae827c469a223fe5fbb0e42ac342539649cf2b97764c9912d7333d79169"
AOM_ARCHIVE_BYTES="4778299"
LIBAVIF_SOURCE_ARCHIVE_DIR="${LIBAVIF_SOURCE_ARCHIVE_DIR:-/home/runner/software/libavif/downloads}"
LIBAVIF_SOURCE_REPOSITORY="https://gitcode.com/boostkit/libavif.git"

# ------------------------------------------------------------------------------
# Open-box media (archived on the runners, never committed to git).
# ------------------------------------------------------------------------------
LIBAVIF_MEDIA_JSON="${SCRIPT_DIR}/fixtures/media.json"
LIBAVIF_MEDIA_CONTAINER_DIR="/media-input"
LIBAVIF_DEFAULT_MEDIA_DIRS=(
    "/home/runner/software/media/video"
    "/home/test/Test/video"
)
LIBAVIF_BUILD_JOBS="${LIBAVIF_BUILD_JOBS:-$(nproc)}"
LIBAVIF_CONTAINER_DEPS=(
    gcc gcc-c++ make cmake tar curl python3 pkg-config git zlib-devel libpng-devel libjpeg-turbo-devel
)
if [[ "$(uname -m)" == x86_64 ]]; then
    LIBAVIF_CONTAINER_DEPS+=(nasm)
fi

STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

LIBAVIF_SRC_DIR=""
LIBAVIF_BUILD_DIR=""
LIBAVIF_INSTALL_DIR=""
AOM_SRC_DIR=""
AOM_BUILD_DIR=""
LIBAVIF_BENCH_DIR=""
LIBAVIF_RUNS_DIR=""
LIBAVIF_MEDIA_DIR="${LIBAVIF_MEDIA_DIR:-}"
LIBAVIF_LOG=""

log_message() {
    printf '[libavif] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    if [[ ! "${LIBAVIF_WARMUPS}" =~ ^[0-9]+$ ]] || [[ "${LIBAVIF_WARMUPS}" -lt 1 ]]; then
        log_message "ERROR: LIBAVIF_WARMUPS must be a positive integer, got ${LIBAVIF_WARMUPS}"
        return 20
    fi
    if [[ ! "${LIBAVIF_SAMPLES}" =~ ^[0-9]+$ ]] || [[ "${LIBAVIF_SAMPLES}" -lt 5 ]]; then
        log_message "ERROR: LIBAVIF_SAMPLES must be an integer >= 5, got ${LIBAVIF_SAMPLES}"
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

    LIBAVIF_SRC_DIR="${PERF_WORK_DIR}/libavif-${SOFTWARE_VERSION}"
    LIBAVIF_BUILD_DIR="${LIBAVIF_SRC_DIR}/build"
    LIBAVIF_INSTALL_DIR="${LIBAVIF_SRC_DIR}/avif_install"
    AOM_SRC_DIR="${PERF_WORK_DIR}/aom-${AOM_VERSION}"
    AOM_BUILD_DIR="${AOM_SRC_DIR}/build"
    LIBAVIF_BENCH_DIR="${PERF_WORK_DIR}/bench"
    LIBAVIF_RUNS_DIR="${RESULTS_DIR}/runs"
    LIBAVIF_LOG="${RESULTS_DIR}/benchmark_encode.txt"

    export SOFTWARE_NAME SOFTWARE_VERSION AOM_VERSION EXPECTED_ARCH PERF_VARIANT
    export PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export LIBAVIF_WARMUPS LIBAVIF_SAMPLES LIBAVIF_STATISTIC
    export LIBAVIF_SRC_DIR LIBAVIF_BUILD_DIR LIBAVIF_INSTALL_DIR AOM_SRC_DIR AOM_BUILD_DIR
    export LIBAVIF_BENCH_DIR LIBAVIF_RUNS_DIR LIBAVIF_MEDIA_DIR LIBAVIF_LOG
    export LIBAVIF_ARCHIVE_NAME LIBAVIF_ARCHIVE_SHA256 LIBAVIF_SOURCE_ARCHIVE_DIR
    export AOM_ARCHIVE_NAME AOM_ARCHIVE_SHA256
    export LIBAVIF_BUILD_JOBS LIBAVIF_MEDIA_JSON LIBAVIF_MEDIA_CONTAINER_DIR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${LIBAVIF_RUNS_DIR}" \
        "${LIBAVIF_BENCH_DIR}" "${PERF_WORK_DIR}/downloads"
}

# ------------------------------------------------------------------------------
# Media discovery: env override, then the runner archive, then the material
# machine location.  Shared by the build (early fail-fast) and test stages.
# ------------------------------------------------------------------------------
libavif_resolve_media() {
    local candidate
    if [[ -n "${LIBAVIF_MEDIA_DIR}" ]] && [[ -d "${LIBAVIF_MEDIA_DIR}" ]]; then
        export LIBAVIF_MEDIA_DIR
        log_message "open-box media directory: ${LIBAVIF_MEDIA_DIR}"
        return 0
    fi
    for candidate in "${LIBAVIF_DEFAULT_MEDIA_DIRS[@]}"; do
        if [[ -d "${candidate}" ]]; then
            LIBAVIF_MEDIA_DIR="${candidate}"
            break
        fi
    done
    if [[ -z "${LIBAVIF_MEDIA_DIR}" ]] || [[ ! -d "${LIBAVIF_MEDIA_DIR}" ]]; then
        log_message "ERROR: open-box media directory is missing; set LIBAVIF_MEDIA_DIR"
        log_message "       checked: ${LIBAVIF_DEFAULT_MEDIA_DIRS[*]}"
        log_message "       expected inputs (see fixtures/media.json): BQTerrace / Film2012 / messi 1920x1080 YUV"
        return 40
    fi
    export LIBAVIF_MEDIA_DIR
    log_message "open-box media directory: ${LIBAVIF_MEDIA_DIR}"
}

libavif_require_host_tools() {
    local missing=() tool
    for tool in docker curl sha256sum tar; do
        command -v "${tool}" >/dev/null 2>&1 || missing+=("${tool}")
    done
    if [[ "${#missing[@]}" -ne 0 ]]; then
        log_message "ERROR: missing host tools: ${missing[*]}"
        return 30
    fi
}

# Mount the media directory read-only at a fixed container path.
libavif_media_mount_args() {
    local existing
    for existing in "${LIBAVIF_CONTAINER_EXTRA_ARGS[@]:-}"; do
        if [[ "${existing}" == *"target=${LIBAVIF_MEDIA_CONTAINER_DIR}"* ]]; then
            return 0
        fi
    done
    LIBAVIF_CONTAINER_EXTRA_ARGS+=(
        --mount "type=bind,source=${LIBAVIF_MEDIA_DIR},target=${LIBAVIF_MEDIA_CONTAINER_DIR},readonly"
    )
}

# ------------------------------------------------------------------------------
# Source archives: local runner archives first, gitcode clone only as a fallback.
# ------------------------------------------------------------------------------
libavif_verify_archive() {
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

libavif_fetch_archives() {
    local name target url_archive
    mkdir -p "${PERF_WORK_DIR}/downloads"
    for name in "${LIBAVIF_ARCHIVE_NAME}" "${AOM_ARCHIVE_NAME}"; do
        target="${PERF_WORK_DIR}/downloads/${name}"
        if [[ -s "${target}" ]]; then
            log_message "reusing downloaded archive: ${target}"
            continue
        fi
        url_archive="${LIBAVIF_SOURCE_ARCHIVE_DIR}/${name}"
        if [[ -s "${url_archive}" ]]; then
            log_message "using local source archive: ${url_archive}"
            cp -f "${url_archive}" "${target}.part" || return 30
            mv -f "${target}.part" "${target}" || return 30
            continue
        fi
        if [[ ! -d "${PERF_WORK_DIR}/downloads/boostkit-libavif/.git" ]]; then
            log_message "local archive is absent; cloning ${LIBAVIF_SOURCE_REPOSITORY} once for both archives"
            rm -rf "${PERF_WORK_DIR}/downloads/boostkit-libavif"
            libavif_with_proxy git clone --depth 1 \
                "${LIBAVIF_SOURCE_REPOSITORY}" \
                "${PERF_WORK_DIR}/downloads/boostkit-libavif" || return 30
        fi
        if [[ ! -s "${PERF_WORK_DIR}/downloads/boostkit-libavif/${name}" ]]; then
            log_message "ERROR: ${name} is neither archived on this runner nor in the boostkit repository"
            return 30
        fi
        cp -f "${PERF_WORK_DIR}/downloads/boostkit-libavif/${name}" "${target}.part" || return 30
        mv -f "${target}.part" "${target}" || return 30
    done
    libavif_verify_archive "${PERF_WORK_DIR}/downloads/${LIBAVIF_ARCHIVE_NAME}" \
        "${LIBAVIF_ARCHIVE_SHA256}" "${LIBAVIF_ARCHIVE_BYTES}" || return $?
    libavif_verify_archive "${PERF_WORK_DIR}/downloads/${AOM_ARCHIVE_NAME}" \
        "${AOM_ARCHIVE_SHA256}" "${AOM_ARCHIVE_BYTES}" || return $?
    log_message "verified source archives: libavif ${SOFTWARE_VERSION} (${LIBAVIF_ARCHIVE_SHA256:0:12}) and AOM ${AOM_VERSION} (${AOM_ARCHIVE_SHA256:0:12})"
}

# ------------------------------------------------------------------------------
# Container-side probes
# ------------------------------------------------------------------------------
libavif_container_version() {
    libavif_container_exec env LD_LIBRARY_PATH="${LIBAVIF_INSTALL_DIR}/lib" \
        "${LIBAVIF_INSTALL_DIR}/bin/avifenc" --version 2>&1 | head -n 1
}

libavif_verify_runtime_payload() {
    local version
    libavif_container_exec test -x "${LIBAVIF_INSTALL_DIR}/bin/avifenc" || {
        log_message "ERROR: avifenc is missing in the container: ${LIBAVIF_INSTALL_DIR}/bin/avifenc"
        return 30
    }
    libavif_container_exec test -x "${LIBAVIF_INSTALL_DIR}/bin/avifdec" || {
        log_message "ERROR: avifdec is missing in the container: ${LIBAVIF_INSTALL_DIR}/bin/avifdec"
        return 30
    }
    version="$(libavif_container_version)" || return 30
    case "${version}" in
        *"${SOFTWARE_VERSION}"*) ;;
        *) log_message "ERROR: avifenc reports '${version}', expected ${SOFTWARE_VERSION}"; return 30 ;;
    esac
    # The current reference material only checks that the tools exist and report
    # the expected version; the superseded dynamic-linkage assertions are
    # intentionally not carried over.
    log_message "container payload verified: ${version}"
}

libavif_media_probe() {
    local candidates name found
    for candidates in \
        "BQTerrace_1920x1080_60-dianbo.yuv BQTerrace_1920x1080_60.yuv" \
        "Film2012_1920x1080_25_8bit_8Mbps.yuv" \
        "messi_1920x1080_25_1000.yuv"; do
        found=""
        for name in ${candidates}; do
            if libavif_container_exec test -r "${LIBAVIF_MEDIA_CONTAINER_DIR}/${name}"; then
                found="${name}"
                break
            fi
        done
        if [[ -z "${found}" ]]; then
            log_message "ERROR: media is not readable in the container: ${LIBAVIF_MEDIA_CONTAINER_DIR}/<${candidates// /|}>"
            return 40
        fi
    done
}

write_actual_version() {
    local version="${1:-${SOFTWARE_VERSION}}"
    printf '%s\n' "${version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 30
    log_message "recorded actual software version: $(cat "${PERF_ACTUAL_VERSION_FILE}")"
}

write_build_variant() {
    local payload
    payload="$(printf '{"variant":"%s","software":"%s","version":"%s","codec":"aom","codec_version":"%s","architecture":"%s","libavif_sha256":"%s","aom_sha256":"%s","container_image":"%s"}\n' \
        "${PERF_VARIANT}" "${SOFTWARE_NAME}" "${SOFTWARE_VERSION}" "${AOM_VERSION}" \
        "$(normalize_architecture "${EXPECTED_ARCH}")" \
        "${LIBAVIF_ARCHIVE_SHA256}" "${AOM_ARCHIVE_SHA256}" "${LIBAVIF_CONTAINER_IMAGE:-unknown}")"
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
LIBAVIF_IMAGE_ARCHIVE_DIR="${LIBAVIF_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
LIBAVIF_CA_ANCHORS_DIR="${LIBAVIF_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
LIBAVIF_CONTAINER_IMAGE="${LIBAVIF_CONTAINER_IMAGE:-}"
LIBAVIF_CONTAINER_NAME="${LIBAVIF_CONTAINER_NAME:-}"
LIBAVIF_CONTAINER_HOME="${LIBAVIF_CONTAINER_HOME:-}"
declare -p LIBAVIF_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || LIBAVIF_CONTAINER_EXTRA_ARGS=()

libavif_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

libavif_configure_container() {
    local arch
    arch="$(libavif_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${LIBAVIF_CONTAINER_NAME}" ] || LIBAVIF_CONTAINER_NAME="boostkit-libavif-${arch}-${PERF_RUN_ID}"
    [ -n "${LIBAVIF_CONTAINER_HOME}" ] || LIBAVIF_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export LIBAVIF_CONTAINER_NAME LIBAVIF_CONTAINER_HOME
}

libavif_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_libavif_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_libavif_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${LIBAVIF_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_libavif_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(libavif_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${LIBAVIF_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${LIBAVIF_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        libavif_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        libavif_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    LIBAVIF_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${LIBAVIF_CONTAINER_IMAGE}" ] || ! docker image inspect "${LIBAVIF_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${LIBAVIF_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_libavif_container_image_release || return $?
    export LIBAVIF_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${LIBAVIF_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_libavif_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-libavif-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${LIBAVIF_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.libavif.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_libavif_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    libavif_configure_container
    require_libavif_docker || return $?
    if docker container inspect "${LIBAVIF_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${LIBAVIF_CONTAINER_NAME}"
        return 40
    fi
    sweep_libavif_stale_containers || true
    prepare_libavif_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${LIBAVIF_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${LIBAVIF_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${LIBAVIF_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${LIBAVIF_CONTAINER_HOME}" || return 40
    log_message "starting private container ${LIBAVIF_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${LIBAVIF_CONTAINER_NAME}" \
        --label "boostkit.libavif.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${LIBAVIF_CONTAINER_EXTRA_ARGS[@]}" \
        "${LIBAVIF_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${LIBAVIF_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${LIBAVIF_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${LIBAVIF_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${LIBAVIF_CONTAINER_NAME}"
}

check_libavif_container() {
    libavif_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${LIBAVIF_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${LIBAVIF_CONTAINER_NAME}"
        return 40
    }
}

libavif_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    libavif_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${LIBAVIF_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${LIBAVIF_CONTAINER_NAME}" "$@"
}

libavif_container_exec() { libavif_docker_exec '' '' "$@"; }

libavif_container_exec_at() {
    local workdir="$1"
    shift
    libavif_docker_exec "${workdir}" '' "$@"
}

libavif_container_exec_root() { libavif_docker_exec '' root "$@"; }

libavif_container_exec_root_at() {
    local workdir="$1"
    shift
    libavif_docker_exec "${workdir}" root "$@"
}

remove_libavif_container() {
    libavif_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${LIBAVIF_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.libavif.run-id"}}' "${LIBAVIF_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${LIBAVIF_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${LIBAVIF_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${LIBAVIF_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${LIBAVIF_CONTAINER_NAME}"
}
# >>> container-runtime:end
