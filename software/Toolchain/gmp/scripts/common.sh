#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="gmp"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-6.3.0}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

GMP_VERSION="${SOFTWARE_VERSION}"
GMP_ARCHIVE_NAME="gmp-${GMP_VERSION}.tar.xz"
# Official GNU GMP 6.3.0 release archive digest.  The same digest is checked for
# every source (offline directory, mirrors and the official GNU servers).
GMP_ARCHIVE_SHA256="a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898"

# Download order: pre-placed offline directory (the dedicated runner may not
# reach the internet), then mirrors reachable from the restricted network, then
# the official GNU servers.
GMP_OFFLINE_DIR="${PERF_GMP_OFFLINE_DIR:-/home/runner/software/gmp}"
GMP_MIRROR_URLS=(
    "https://mirrors.tuna.tsinghua.edu.cn/gnu/gmp/${GMP_ARCHIVE_NAME}"
    "https://mirrors.huaweicloud.com/gnu/gmp/${GMP_ARCHIVE_NAME}"
)
GMP_OFFICIAL_URLS=(
    "https://ftp.gnu.org/gnu/gmp/${GMP_ARCHIVE_NAME}"
    "https://ftpmirror.gnu.org/gmp/${GMP_ARCHIVE_NAME}"
)

GMP_BUILD_JOBS="${PERF_GMP_JOBS:-4}"
GMP_REPS="${PERF_REPS:-5}"
GMP_WARMUP_REPS="${PERF_WARMUP_REPS:-1}"
GMP_CONFIGURE_OPTIONS=(--disable-shared --enable-static)

# One upstream tune/speed routine at one operand size per scenario.  Sizes are
# limbs for the mpn_* routines and bits for the mpz_* routines, which is exactly
# how tune/speed defines its -s option.
GMP_SCENARIOS=(
    mpn_mul_n_512
    mpn_mul_n_2048
    mpn_mul_n_8192
    mpn_sqr_4096
    mpn_add_n_8192
    mpn_div_qr_2n_2048
    mpn_div_qr_2n_8192
    mpz_add_2048
    mpz_add_8192
)
# tune/speed aborts a measurement when it cannot get four timings within 1%
# (it then prints "n/a" instead of a value).  Under a busy CI host this can
# happen for an otherwise healthy build, so one repetition is retried up to this
# many times; the retry only happens when upstream itself produced no value.
GMP_MAX_ATTEMPTS="${PERF_GMP_ATTEMPTS:-6}"

GMP_ARCHIVE=""
GMP_SOURCE_DIR=""
GMP_PREFIX=""
GMP_SPEED_BIN=""
GMP_VERSION_STRING=""
RUNS_DIR=""
LOG_DIR=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[gmp] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/gmp/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    GMP_ARCHIVE="${PERF_WORK_DIR}/src/${GMP_ARCHIVE_NAME}"
    GMP_SOURCE_DIR="${PERF_WORK_DIR}/src/gmp-${GMP_VERSION}"
    GMP_PREFIX="${PERF_WORK_DIR}/prefix"
    GMP_SPEED_BIN="${GMP_SOURCE_DIR}/tune/speed"
    RUNS_DIR="${RESULTS_DIR}/runs"
    LOG_DIR="${RESULTS_DIR}/logs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR GMP_REPS
}

initialize_runtime() {
    configure_runtime_paths
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${RUNS_DIR}" "${LOG_DIR}" \
        "${PERF_WORK_DIR}/src" "${GMP_PREFIX}" "${TMPDIR}"
}

scenario_routine() {
    case "${1}" in
        mpn_mul_n_512|mpn_mul_n_2048|mpn_mul_n_8192) printf 'mpn_mul_n\n' ;;
        mpn_sqr_4096) printf 'mpn_sqr\n' ;;
        mpn_add_n_8192) printf 'mpn_add_n\n' ;;
        mpn_div_qr_2n_2048|mpn_div_qr_2n_8192) printf 'mpn_div_qr_2n\n' ;;
        mpz_add_2048|mpz_add_8192) printf 'mpz_add\n' ;;
        *) return 1 ;;
    esac
}

scenario_size() {
    case "${1}" in
        mpn_mul_n_512) printf '512\n' ;;
        mpn_mul_n_2048) printf '2048\n' ;;
        mpn_mul_n_8192) printf '8192\n' ;;
        mpn_sqr_4096) printf '4096\n' ;;
        mpn_add_n_8192) printf '8192\n' ;;
        mpn_div_qr_2n_2048) printf '2048\n' ;;
        mpn_div_qr_2n_8192) printf '8192\n' ;;
        mpz_add_2048) printf '2048\n' ;;
        mpz_add_8192) printf '8192\n' ;;
        *) return 1 ;;
    esac
}

scenario_unit() {
    case "${1}" in
        mpn_*) printf 'limbs\n' ;;
        mpz_*) printf 'bits\n' ;;
        *) return 1 ;;
    esac
}

verify_sha256() {
    local file="$1" expected="$2" actual
    [[ -f "${file}" ]] || {
        log_message "ERROR: archive is missing: ${file}"
        return 1
    }
    actual="$(sha256sum -- "${file}" | awk '{print $1}')" || {
        log_message "ERROR: cannot hash ${file}"
        return 1
    }
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: SHA-256 mismatch for ${file}"
        log_message "  expected: ${expected}"
        log_message "  actual:   ${actual}"
        return 1
    fi
    return 0
}

download_gmp_archive() {
    local destination="$1"
    local temporary="${destination}.part"
    local attempts=() entry url
    local ok=0

    if [[ -d "${GMP_OFFLINE_DIR}" ]]; then
        entry="${GMP_OFFLINE_DIR}/${GMP_ARCHIVE_NAME}"
        if [[ -f "${entry}" ]]; then
            log_message "using pre-placed offline archive: ${entry}"
            if cp -f -- "${entry}" "${temporary}" && verify_sha256 "${temporary}" "${GMP_ARCHIVE_SHA256}"; then
                ok=1
            else
                attempts+=("${entry} (digest mismatch)")
            fi
        else
            attempts+=("${entry} (missing)")
        fi
    else
        attempts+=("${GMP_OFFLINE_DIR} (missing directory)")
    fi

    if [[ "${ok}" -ne 1 ]]; then
        for url in "${GMP_MIRROR_URLS[@]}" "${GMP_OFFICIAL_URLS[@]}"; do
            log_message "downloading ${url}"
            rm -f -- "${temporary}"
            if curl -fsSL --retry 2 --retry-delay 2 --connect-timeout 20 \
                --max-time 900 -o "${temporary}" "${url}"; then
                if verify_sha256 "${temporary}" "${GMP_ARCHIVE_SHA256}"; then
                    ok=1
                    break
                fi
                attempts+=("${url} (digest mismatch)")
            else
                attempts+=("${url} (download failed)")
            fi
        done
    fi

    if [[ "${ok}" -ne 1 ]]; then
        log_message "ERROR: cannot obtain ${GMP_ARCHIVE_NAME} with the pinned SHA-256"
        log_message "  expected SHA-256: ${GMP_ARCHIVE_SHA256}"
        for entry in "${attempts[@]}"; do
            log_message "  attempted: ${entry}"
        done
        rm -f -- "${temporary}"
        return 30
    fi
    mv -f -- "${temporary}" "${destination}"
    log_message "verified ${GMP_ARCHIVE_NAME} (SHA-256 ${GMP_ARCHIVE_SHA256})"
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
GMP_IMAGE_ARCHIVE_DIR="${GMP_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
GMP_CA_ANCHORS_DIR="${GMP_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
GMP_CONTAINER_IMAGE="${GMP_CONTAINER_IMAGE:-}"
GMP_CONTAINER_NAME="${GMP_CONTAINER_NAME:-}"
GMP_CONTAINER_HOME="${GMP_CONTAINER_HOME:-}"
declare -p GMP_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || GMP_CONTAINER_EXTRA_ARGS=()

gmp_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

gmp_configure_container() {
    local arch
    arch="$(gmp_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${GMP_CONTAINER_NAME}" ] || GMP_CONTAINER_NAME="boostkit-gmp-${arch}-${PERF_RUN_ID}"
    [ -n "${GMP_CONTAINER_HOME}" ] || GMP_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export GMP_CONTAINER_NAME GMP_CONTAINER_HOME
}

gmp_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_gmp_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_gmp_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${GMP_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_gmp_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(gmp_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${GMP_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${GMP_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        gmp_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        gmp_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    GMP_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${GMP_CONTAINER_IMAGE}" ] || ! docker image inspect "${GMP_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${GMP_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_gmp_container_image_release || return $?
    export GMP_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${GMP_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_gmp_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-gmp-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${GMP_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.gmp.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_gmp_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    gmp_configure_container
    require_gmp_docker || return $?
    if docker container inspect "${GMP_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${GMP_CONTAINER_NAME}"
        return 40
    fi
    sweep_gmp_stale_containers || true
    prepare_gmp_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${GMP_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${GMP_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${GMP_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${GMP_CONTAINER_HOME}" || return 40
    log_message "starting private container ${GMP_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${GMP_CONTAINER_NAME}" \
        --label "boostkit.gmp.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${GMP_CONTAINER_EXTRA_ARGS[@]}" \
        "${GMP_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${GMP_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${GMP_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${GMP_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${GMP_CONTAINER_NAME}"
}

check_gmp_container() {
    gmp_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${GMP_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${GMP_CONTAINER_NAME}"
        return 40
    }
}

gmp_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    gmp_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${GMP_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${GMP_CONTAINER_NAME}" "$@"
}

gmp_container_exec() { gmp_docker_exec '' '' "$@"; }

gmp_container_exec_at() {
    local workdir="$1"
    shift
    gmp_docker_exec "${workdir}" '' "$@"
}

gmp_container_exec_root() { gmp_docker_exec '' root "$@"; }

gmp_container_exec_root_at() {
    local workdir="$1"
    shift
    gmp_docker_exec "${workdir}" root "$@"
}

remove_gmp_container() {
    gmp_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${GMP_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.gmp.run-id"}}' "${GMP_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${GMP_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${GMP_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${GMP_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${GMP_CONTAINER_NAME}"
}
# >>> container-runtime:end
