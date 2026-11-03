#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="libmpc"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.4.1}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

MPC_VERSION="${SOFTWARE_VERSION}"
MPC_ARCHIVE_NAME="mpc-${MPC_VERSION}.tar.xz"
MPC_ARCHIVE_SHA256="91204cd32f164bd3b7c992d4a6a8ce6519511aadab30f78b6982d0bf8d73e931"

# libmpc 1.4.1 is built against one pinned GMP and one pinned MPFR release;
# both dependencies are built into private prefixes inside PERF_WORK_DIR and are
# independent of the GMP and MPFR cases.
GMP_VERSION="6.3.0"
GMP_ARCHIVE_NAME="gmp-${GMP_VERSION}.tar.xz"
GMP_ARCHIVE_SHA256="a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898"
MPFR_DEP_VERSION="4.2.2"
MPFR_DEP_ARCHIVE_NAME="mpfr-${MPFR_DEP_VERSION}.tar.xz"
MPFR_DEP_ARCHIVE_SHA256="b67ba0383ef7e8a8563734e2e889ef5ec3c3b898a01d00fa0a6869ad81c6ce01"

MPC_OFFLINE_DIR="${PERF_LIBMPC_OFFLINE_DIR:-/home/runner/software/libmpc}"
MPFR_OFFLINE_DIR="${PERF_MPFR_OFFLINE_DIR:-/home/runner/software/mpfr}"
GMP_OFFLINE_DIR="${PERF_GMP_OFFLINE_DIR:-/home/runner/software/gmp}"
MPC_MIRROR_URLS=(
    "https://mirrors.tuna.tsinghua.edu.cn/gnu/mpc/${MPC_ARCHIVE_NAME}"
    "https://mirrors.huaweicloud.com/gnu/mpc/${MPC_ARCHIVE_NAME}"
)
MPC_OFFICIAL_URLS=(
    "https://ftp.gnu.org/gnu/mpc/${MPC_ARCHIVE_NAME}"
    "https://ftpmirror.gnu.org/mpc/${MPC_ARCHIVE_NAME}"
)
MPFR_MIRROR_URLS=(
    "https://mirrors.tuna.tsinghua.edu.cn/gnu/mpfr/${MPFR_DEP_ARCHIVE_NAME}"
    "https://mirrors.huaweicloud.com/gnu/mpfr/${MPFR_DEP_ARCHIVE_NAME}"
)
MPFR_OFFICIAL_URLS=(
    "https://ftp.gnu.org/gnu/mpfr/${MPFR_DEP_ARCHIVE_NAME}"
    "https://ftpmirror.gnu.org/mpfr/${MPFR_DEP_ARCHIVE_NAME}"
)
GMP_MIRROR_URLS=(
    "https://mirrors.tuna.tsinghua.edu.cn/gnu/gmp/${GMP_ARCHIVE_NAME}"
    "https://mirrors.huaweicloud.com/gnu/gmp/${GMP_ARCHIVE_NAME}"
)
GMP_OFFICIAL_URLS=(
    "https://ftp.gnu.org/gnu/gmp/${GMP_ARCHIVE_NAME}"
    "https://ftpmirror.gnu.org/gmp/${GMP_ARCHIVE_NAME}"
)

MPC_BUILD_JOBS="${PERF_LIBMPC_JOBS:-4}"
MPC_REPS="${PERF_REPS:-5}"
MPC_WARMUP_REPS="${PERF_WARMUP_REPS:-1}"

# One fixed libmpc routine at one fixed precision per scenario, executed by
# scripts/bench/mpc_bench.c.  Upstream tools/bench (mpcbench) always runs the
# full fixed operation set without any selection switch, so a per-scenario
# measurement with one warm-up and five repetitions needs this harness; it uses
# the same random-operand and CPU-time methodology and only calls public API.
MPC_SCENARIOS=(
    mpc_mul_256
    mpc_mul_1024
    mpc_mul_4096
    mpc_sqr_1024
    mpc_div_1024
    mpc_pow_256
    mpc_pow_1024
    mpc_exp_256
)

GMP_SOURCE_DIR=""
GMP_PREFIX=""
MPFR_SOURCE_DIR=""
MPFR_PREFIX=""
MPC_SOURCE_DIR=""
MPC_PREFIX=""
MPC_BENCH_BIN=""
GMP_ARCHIVE=""
MPFR_ARCHIVE=""
MPC_ARCHIVE=""
MPC_VERSION_STRING=""
GMP_VERSION_STRING=""
MPFR_VERSION_STRING=""
RUNS_DIR=""
LOG_DIR=""
ATTEMPTED_SOURCES=()
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[libmpc] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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

configure_runtime_paths() {
    validate_variant || return $?
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
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/libmpc/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    GMP_ARCHIVE="${PERF_WORK_DIR}/src/${GMP_ARCHIVE_NAME}"
    GMP_SOURCE_DIR="${PERF_WORK_DIR}/src/gmp-${GMP_VERSION}"
    GMP_PREFIX="${PERF_WORK_DIR}/gmp-prefix"
    MPFR_ARCHIVE="${PERF_WORK_DIR}/src/${MPFR_DEP_ARCHIVE_NAME}"
    MPFR_SOURCE_DIR="${PERF_WORK_DIR}/src/mpfr-${MPFR_DEP_VERSION}"
    MPFR_PREFIX="${PERF_WORK_DIR}/mpfr-prefix"
    MPC_ARCHIVE="${PERF_WORK_DIR}/src/${MPC_ARCHIVE_NAME}"
    MPC_SOURCE_DIR="${PERF_WORK_DIR}/src/mpc-${MPC_VERSION}"
    MPC_PREFIX="${PERF_WORK_DIR}/mpc-prefix"
    MPC_BENCH_BIN="${PERF_WORK_DIR}/bin/mpc_bench"
    RUNS_DIR="${RESULTS_DIR}/runs"
    LOG_DIR="${RESULTS_DIR}/logs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR MPC_REPS
}

initialize_runtime() {
    configure_runtime_paths
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${RUNS_DIR}" "${LOG_DIR}" \
        "${PERF_WORK_DIR}/src" "${GMP_PREFIX}" "${MPFR_PREFIX}" "${MPC_PREFIX}" \
        "${PERF_WORK_DIR}/bin" "${TMPDIR}"
}

scenario_routine() {
    case "${1}" in
        mpc_mul_*) printf 'mpc_mul\n' ;;
        mpc_sqr_*) printf 'mpc_sqr\n' ;;
        mpc_div_*) printf 'mpc_div\n' ;;
        mpc_pow_*) printf 'mpc_pow\n' ;;
        mpc_exp_*) printf 'mpc_exp\n' ;;
        *) return 1 ;;
    esac
}

scenario_precision() {
    case "${1}" in
        *_256) printf '256\n' ;;
        *_1024) printf '1024\n' ;;
        *_4096) printf '4096\n' ;;
        *) return 1 ;;
    esac
}

verify_sha256() {
    local file="$1" expected="$2" actual
    [[ -f "${file}" ]] || return 1
    actual="$(sha256sum -- "${file}" | awk '{print $1}')" || return 1
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: SHA-256 mismatch for ${file}"
        log_message "  expected: ${expected}"
        log_message "  actual:   ${actual}"
        return 1
    fi
    return 0
}

try_offline_archive() {
    local name="$1" expected="$2" destination="$3" directory entry
    shift 3
    for directory in "$@"; do
        entry="${directory}/${name}"
        [[ -d "${directory}" ]] || continue
        if [[ ! -f "${entry}" ]]; then
            ATTEMPTED_SOURCES+=("${entry} (missing)")
            continue
        fi
        log_message "using pre-placed offline archive: ${entry}"
        if cp -f -- "${entry}" "${destination}.part" && verify_sha256 "${destination}.part" "${expected}"; then
            mv -f -- "${destination}.part" "${destination}"
            return 0
        fi
        ATTEMPTED_SOURCES+=("${entry} (digest mismatch)")
    done
    return 1
}

try_download_urls() {
    local destination="$1" expected="$2" url
    shift 2
    for url in "$@"; do
        log_message "downloading ${url}"
        rm -f -- "${destination}.part"
        if curl -fsSL --retry 2 --retry-delay 2 --connect-timeout 20 \
            --max-time 900 -o "${destination}.part" "${url}"; then
            if verify_sha256 "${destination}.part" "${expected}"; then
                mv -f -- "${destination}.part" "${destination}"
                return 0
            fi
            ATTEMPTED_SOURCES+=("${url} (digest mismatch)")
        else
            ATTEMPTED_SOURCES+=("${url} (download failed)")
        fi
    done
    return 1
}

download_gmp_archive() {
    try_offline_archive "${GMP_ARCHIVE_NAME}" "${GMP_ARCHIVE_SHA256}" "${GMP_ARCHIVE}" \
        "${MPC_OFFLINE_DIR}" "${MPFR_OFFLINE_DIR}" "${GMP_OFFLINE_DIR}" && return 0
    try_download_urls "${GMP_ARCHIVE}" "${GMP_ARCHIVE_SHA256}" \
        "${GMP_MIRROR_URLS[@]}" "${GMP_OFFICIAL_URLS[@]}" && return 0
    log_message "ERROR: cannot obtain ${GMP_ARCHIVE_NAME} with the pinned SHA-256"
    return 30
}

download_mpfr_archive() {
    try_offline_archive "${MPFR_DEP_ARCHIVE_NAME}" "${MPFR_DEP_ARCHIVE_SHA256}" "${MPFR_ARCHIVE}" \
        "${MPC_OFFLINE_DIR}" "${MPFR_OFFLINE_DIR}" && return 0
    try_download_urls "${MPFR_ARCHIVE}" "${MPFR_DEP_ARCHIVE_SHA256}" \
        "${MPFR_MIRROR_URLS[@]}" "${MPFR_OFFICIAL_URLS[@]}" && return 0
    log_message "ERROR: cannot obtain ${MPFR_DEP_ARCHIVE_NAME} with the pinned SHA-256"
    return 30
}

download_mpc_archive() {
    try_offline_archive "${MPC_ARCHIVE_NAME}" "${MPC_ARCHIVE_SHA256}" "${MPC_ARCHIVE}" \
        "${MPC_OFFLINE_DIR}" && return 0
    try_download_urls "${MPC_ARCHIVE}" "${MPC_ARCHIVE_SHA256}" \
        "${MPC_MIRROR_URLS[@]}" "${MPC_OFFICIAL_URLS[@]}" && return 0
    log_message "ERROR: cannot obtain ${MPC_ARCHIVE_NAME} with the pinned SHA-256"
    return 30
}

report_attempted_sources() {
    local entry
    if [[ "${#ATTEMPTED_SOURCES[@]}" -eq 0 ]]; then
        return 0
    fi
    log_message "all attempted sources:"
    for entry in "${ATTEMPTED_SOURCES[@]}"; do
        log_message "  attempted: ${entry}"
    done
}

require_build_commands() {
    local command_name package
    local missing=()
    for command_name in gcc make tar xz curl sha256sum awk sed; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            gcc) package="gcc" ;;
            make) package="make" ;;
            tar) package="tar" ;;
            xz) package="xz" ;;
            curl) package="curl" ;;
            sha256sum|awk|sed) package="coreutils" ;;
        esac
        log_message "missing required build command: ${command_name} (package ${package})"
        missing+=("${package}")
    done
    if [[ "${#missing[@]}" -eq 0 ]]; then
        return 0
    fi
    if command -v dnf >/dev/null 2>&1; then
        log_message "installing build prerequisites with dnf: ${missing[*]}"
        if [[ "$(id -u)" -eq 0 ]]; then
            dnf install -y "${missing[@]}" || log_message "WARNING: dnf install failed"
        elif command -v sudo >/dev/null 2>&1; then
            sudo -n dnf install -y "${missing[@]}" || log_message "WARNING: dnf install failed"
        fi
    elif command -v apt-get >/dev/null 2>&1; then
        log_message "installing build prerequisites with apt: ${missing[*]}"
        if [[ "$(id -u)" -eq 0 ]]; then
            apt-get install -y "${missing[@]}" || log_message "WARNING: apt-get install failed"
        elif command -v sudo >/dev/null 2>&1; then
            sudo -n apt-get install -y "${missing[@]}" || log_message "WARNING: apt-get install failed"
        fi
    fi
    for command_name in gcc make tar xz curl sha256sum awk sed; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log_message "ERROR: required build command is unavailable: ${command_name}"
            return 30
        fi
    done
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
LIBMPC_IMAGE_ARCHIVE_DIR="${LIBMPC_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
LIBMPC_CA_ANCHORS_DIR="${LIBMPC_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
LIBMPC_CONTAINER_IMAGE="${LIBMPC_CONTAINER_IMAGE:-}"
LIBMPC_CONTAINER_NAME="${LIBMPC_CONTAINER_NAME:-}"
LIBMPC_CONTAINER_HOME="${LIBMPC_CONTAINER_HOME:-}"
declare -p LIBMPC_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || LIBMPC_CONTAINER_EXTRA_ARGS=()

libmpc_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

libmpc_configure_container() {
    local arch
    arch="$(libmpc_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${LIBMPC_CONTAINER_NAME}" ] || LIBMPC_CONTAINER_NAME="boostkit-libmpc-${arch}-${PERF_RUN_ID}"
    [ -n "${LIBMPC_CONTAINER_HOME}" ] || LIBMPC_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export LIBMPC_CONTAINER_NAME LIBMPC_CONTAINER_HOME
}

libmpc_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_libmpc_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_libmpc_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${LIBMPC_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_libmpc_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(libmpc_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${LIBMPC_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${LIBMPC_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        libmpc_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        libmpc_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    LIBMPC_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${LIBMPC_CONTAINER_IMAGE}" ] || ! docker image inspect "${LIBMPC_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${LIBMPC_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_libmpc_container_image_release || return $?
    export LIBMPC_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${LIBMPC_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_libmpc_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-libmpc-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${LIBMPC_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.libmpc.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_libmpc_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    libmpc_configure_container
    require_libmpc_docker || return $?
    if docker container inspect "${LIBMPC_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${LIBMPC_CONTAINER_NAME}"
        return 40
    fi
    sweep_libmpc_stale_containers || true
    prepare_libmpc_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${LIBMPC_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${LIBMPC_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${LIBMPC_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${LIBMPC_CONTAINER_HOME}" || return 40
    log_message "starting private container ${LIBMPC_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${LIBMPC_CONTAINER_NAME}" \
        --label "boostkit.libmpc.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${LIBMPC_CONTAINER_EXTRA_ARGS[@]}" \
        "${LIBMPC_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${LIBMPC_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${LIBMPC_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${LIBMPC_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${LIBMPC_CONTAINER_NAME}"
}

check_libmpc_container() {
    libmpc_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${LIBMPC_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${LIBMPC_CONTAINER_NAME}"
        return 40
    }
}

libmpc_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    libmpc_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${LIBMPC_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${LIBMPC_CONTAINER_NAME}" "$@"
}

libmpc_container_exec() { libmpc_docker_exec '' '' "$@"; }

libmpc_container_exec_at() {
    local workdir="$1"
    shift
    libmpc_docker_exec "${workdir}" '' "$@"
}

libmpc_container_exec_root() { libmpc_docker_exec '' root "$@"; }

libmpc_container_exec_root_at() {
    local workdir="$1"
    shift
    libmpc_docker_exec "${workdir}" root "$@"
}

remove_libmpc_container() {
    libmpc_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${LIBMPC_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.libmpc.run-id"}}' "${LIBMPC_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${LIBMPC_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${LIBMPC_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${LIBMPC_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${LIBMPC_CONTAINER_NAME}"
}
# >>> container-runtime:end
