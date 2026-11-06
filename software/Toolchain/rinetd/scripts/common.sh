#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="rinetd"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-0.73}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

RINETD_VERSION="${SOFTWARE_VERSION}"
RINETD_ARCHIVE_NAME="rinetd-${RINETD_VERSION}.tar.gz"
# Official release asset attached to the upstream v0.73 tag; the same bytes are
# served by the two URLs below (both verified against this one digest).
RINETD_ARCHIVE_SHA256="da1fa70e75c2e5906ba55bb05a71da07d1e2a1cc4de2aa9bd30b1f753d8c345a"

RINETD_OFFLINE_DIR="${PERF_RINETD_OFFLINE_DIR:-/home/runner/software/rinetd}"
RINETD_URLS=(
    "https://github.com/samhocevar/rinetd/releases/download/v${RINETD_VERSION}/${RINETD_ARCHIVE_NAME}"
    "https://gh-proxy.com/https://github.com/samhocevar/rinetd/releases/download/v${RINETD_VERSION}/${RINETD_ARCHIVE_NAME}"
)

RINETD_BUILD_JOBS="${PERF_RINETD_JOBS:-4}"
RINETD_REPS="${PERF_REPS:-5}"
RINETD_WARMUP_REPS="${PERF_WARMUP_REPS:-1}"

# Fixed loopback matrix: every scenario measures one client process against one
# server process, either directly or through the rinetd instance started by the
# start stage.  Payload sizes are fixed here and mirrored by the parser.
RINETD_THROUGHPUT_SCENARIOS=(
    throughput_4m_direct
    throughput_4m_forwarded
    throughput_16m_direct
    throughput_16m_forwarded
    throughput_4m_8conn_direct
    throughput_4m_8conn_forwarded
)
RINETD_LATENCY_SCENARIOS=(
    latency_64b_direct
    latency_64b_forwarded
)
RINETD_SCENARIOS=("${RINETD_THROUGHPUT_SCENARIOS[@]}" "${RINETD_LATENCY_SCENARIOS[@]}")

RINETD_LATENCY_ROUND_TRIPS=2000
RINETD_LATENCY_DISCARD=100
RINETD_LATENCY_REQUEST_BYTES=64

RINETD_SOURCE_DIR=""
RINETD_PREFIX=""
RINETD_BIN=""
RINETD_BENCH_BIN=""
RINETD_ARCHIVE=""
RINETD_VERSION_STRING=""
RUNS_DIR=""
LOG_DIR=""
ATTEMPTED_SOURCES=()
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[rinetd] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/rinetd/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    RINETD_ARCHIVE="${PERF_WORK_DIR}/src/${RINETD_ARCHIVE_NAME}"
    RINETD_SOURCE_DIR="${PERF_WORK_DIR}/src/rinetd-${RINETD_VERSION}"
    RINETD_PREFIX="${PERF_WORK_DIR}/rinetd-prefix"
    RINETD_BIN="${RINETD_PREFIX}/sbin/rinetd"
    RINETD_BENCH_BIN="${PERF_WORK_DIR}/bin/rinetd_bench"
    RUNS_DIR="${RESULTS_DIR}/runs"
    LOG_DIR="${RESULTS_DIR}/logs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR RINETD_REPS
}

initialize_runtime() {
    configure_runtime_paths
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${RUNS_DIR}" "${LOG_DIR}" \
        "${PERF_WORK_DIR}/src" "${RINETD_PREFIX}" "${PERF_WORK_DIR}/bin" "${TMPDIR}"
}

scenario_mode() {
    case "${1}" in
        throughput_*) printf 'throughput\n' ;;
        latency_*) printf 'latency\n' ;;
        *) return 1 ;;
    esac
}

scenario_payload() {
    case "${1}" in
        throughput_4m_*) printf '%s\n' "$((4 * 1024 * 1024))" ;;
        throughput_16m_*) printf '%s\n' "$((16 * 1024 * 1024))" ;;
        *) return 1 ;;
    esac
}

scenario_connections() {
    case "${1}" in
        throughput_4m_8conn_*) printf '8\n' ;;
        throughput_*) printf '1\n' ;;
        *) return 1 ;;
    esac
}

scenario_path() {
    case "${1}" in
        *_direct) printf 'direct\n' ;;
        *_forwarded) printf 'forwarded\n' ;;
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

download_rinetd_archive() {
    try_offline_archive "${RINETD_ARCHIVE_NAME}" "${RINETD_ARCHIVE_SHA256}" "${RINETD_ARCHIVE}" \
        "${RINETD_OFFLINE_DIR}" && return 0
    try_download_urls "${RINETD_ARCHIVE}" "${RINETD_ARCHIVE_SHA256}" \
        "${RINETD_URLS[@]}" && return 0
    log_message "ERROR: cannot obtain ${RINETD_ARCHIVE_NAME} with the pinned SHA-256"
    log_message "  expected SHA-256: ${RINETD_ARCHIVE_SHA256}"
    log_message "  offline directory: ${RINETD_OFFLINE_DIR}"
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
    for command_name in gcc make tar gzip curl sha256sum awk sed python3; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            gcc) package="gcc" ;;
            make) package="make" ;;
            tar) package="tar" ;;
            gzip) package="gzip" ;;
            curl) package="curl" ;;
            python3) package="python3" ;;
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
    for command_name in gcc make tar gzip curl sha256sum awk sed python3; do
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
RINETD_IMAGE_ARCHIVE_DIR="${RINETD_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
RINETD_CA_ANCHORS_DIR="${RINETD_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
RINETD_CONTAINER_IMAGE="${RINETD_CONTAINER_IMAGE:-}"
RINETD_CONTAINER_NAME="${RINETD_CONTAINER_NAME:-}"
RINETD_CONTAINER_HOME="${RINETD_CONTAINER_HOME:-}"
declare -p RINETD_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || RINETD_CONTAINER_EXTRA_ARGS=()

rinetd_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

rinetd_configure_container() {
    local arch
    arch="$(rinetd_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${RINETD_CONTAINER_NAME}" ] || RINETD_CONTAINER_NAME="boostkit-rinetd-${arch}-${PERF_RUN_ID}"
    [ -n "${RINETD_CONTAINER_HOME}" ] || RINETD_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export RINETD_CONTAINER_NAME RINETD_CONTAINER_HOME
}

rinetd_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_rinetd_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_rinetd_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${RINETD_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_rinetd_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(rinetd_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${RINETD_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${RINETD_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        rinetd_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        rinetd_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    RINETD_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${RINETD_CONTAINER_IMAGE}" ] || ! docker image inspect "${RINETD_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${RINETD_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_rinetd_container_image_release || return $?
    export RINETD_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${RINETD_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_rinetd_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-rinetd-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${RINETD_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.rinetd.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_rinetd_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    rinetd_configure_container
    require_rinetd_docker || return $?
    if docker container inspect "${RINETD_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${RINETD_CONTAINER_NAME}"
        return 40
    fi
    sweep_rinetd_stale_containers || true
    prepare_rinetd_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${RINETD_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${RINETD_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${RINETD_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${RINETD_CONTAINER_HOME}" || return 40
    log_message "starting private container ${RINETD_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${RINETD_CONTAINER_NAME}" \
        --label "boostkit.rinetd.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${RINETD_CONTAINER_EXTRA_ARGS[@]}" \
        "${RINETD_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${RINETD_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${RINETD_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${RINETD_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${RINETD_CONTAINER_NAME}"
}

check_rinetd_container() {
    rinetd_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${RINETD_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${RINETD_CONTAINER_NAME}"
        return 40
    }
}

rinetd_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    rinetd_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${RINETD_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${RINETD_CONTAINER_NAME}" "$@"
}

rinetd_container_exec() { rinetd_docker_exec '' '' "$@"; }

rinetd_container_exec_at() {
    local workdir="$1"
    shift
    rinetd_docker_exec "${workdir}" '' "$@"
}

rinetd_container_exec_root() { rinetd_docker_exec '' root "$@"; }

rinetd_container_exec_root_at() {
    local workdir="$1"
    shift
    rinetd_docker_exec "${workdir}" root "$@"
}

remove_rinetd_container() {
    rinetd_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${RINETD_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.rinetd.run-id"}}' "${RINETD_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${RINETD_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${RINETD_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${RINETD_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${RINETD_CONTAINER_NAME}"
}
# >>> container-runtime:end
