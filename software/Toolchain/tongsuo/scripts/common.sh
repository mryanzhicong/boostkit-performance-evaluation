#!/usr/bin/env bash
# ==============================================================================
# Tongsuo 8.5.0 algorithm performance case -- shared configuration.
# ==============================================================================
# The case builds the untouched upstream tag 8.5.0 (commit 80cfbe3eb194a4d30da90742273c305ad4d096be)
# from the pinned source archive inside a private openEuler 24.03 LTS SP4
# container and measures the shipped `apps/openssl speed` workloads:
# SM2/SM3/SM4, ZUC-128-EEA3, AES-256-GCM, SHA-256, ECDSA P-256, RSA-2048 and
# ECDH P-256.
#
# Neither the reference material nor this case pins CPU or memory: the whole
# measurement runs natively inside the container, so the numbers describe an
# out-of-the-box deployment instead of a hand-tuned one.
#
# Layout inside the per-run work directory (${PERF_WORK_DIR}):
#   downloads/Tongsuo-8.5.0.tar.gz   verified source archive
#   Tongsuo-8.5.0/                   in-tree build (apps/openssl, libcrypto.a)
#   home                             container HOME
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SOFTWARE_NAME="tongsuo"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-8.5.0}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# ------------------------------------------------------------------------------
# Sampling contract: >=1 warm-up and >=5 measured samples, all samples kept.
# The published configuration runs 1 warm-up + 6 measured samples per scenario;
# PERF_REPS lets the Framework (and local smoke runs) drive the count.
# ------------------------------------------------------------------------------
TONGSUO_WARMUPS="${TONGSUO_WARMUPS:-1}"
TONGSUO_SAMPLES="${TONGSUO_SAMPLES:-${PERF_REPS:-6}}"
TONGSUO_STATISTIC="median"
# `openssl speed -seconds` default is 3 s for ciphers/digests and 10 s for public
# key operations; the case pins both to the same 3 s so every scenario shares one
# time budget (upstream CI uses the tool defaults, this is documented in README).
TONGSUO_SECONDS="${TONGSUO_SECONDS:-3}"

# ------------------------------------------------------------------------------
# Pinned source archive (upstream tag 8.5.0).
# ------------------------------------------------------------------------------
TONGSUO_ARCHIVE_NAME="Tongsuo-${SOFTWARE_VERSION}.tar.gz"
TONGSUO_ARCHIVE_SHA256="505085d457214e5662ea7109c3919fb75f695edf74c91ec6f690da0e58c07dea"
TONGSUO_ARCHIVE_BYTES="53695695"
TONGSUO_TAG_COMMIT="80cfbe3eb194a4d30da90742273c305ad4d096be"
TONGSUO_SOURCE_ARCHIVE_DIR="${TONGSUO_SOURCE_ARCHIVE_DIR:-/home/runner/software/tongsuo/downloads}"
TONGSUO_SOURCE_URLS=(
    "https://github.com/Tongsuo-Project/Tongsuo/archive/refs/tags/${SOFTWARE_VERSION}.tar.gz"
    "https://gh-proxy.com/https://github.com/Tongsuo-Project/Tongsuo/archive/refs/tags/${SOFTWARE_VERSION}.tar.gz"
    "https://ghfast.top/https://github.com/Tongsuo-Project/Tongsuo/archive/refs/tags/${SOFTWARE_VERSION}.tar.gz"
)

TONGSUO_BUILD_JOBS="${TONGSUO_BUILD_JOBS:-$(nproc)}"
if [[ "${TONGSUO_BUILD_JOBS}" =~ ^[0-9]+$ ]] && [[ "${TONGSUO_BUILD_JOBS}" -gt 16 ]]; then
    TONGSUO_BUILD_JOBS=16
fi
# The same feature set the upstream CI benchmark job pins (minus enable-fips,
# which only builds the FIPS provider and is not exercised by `speed`).
TONGSUO_CONFIG_FLAGS=(
    no-shared
    enable-ntls
    enable-zuc
    enable-ec_elgamal
    enable-paillier
    enable-sm2
    enable-sm3
    enable-sm4
)
TONGSUO_CONTAINER_DEPS=(
    gcc make perl perl-Text-Template tar gzip curl which coreutils findutils
    diffutils binutils glibc-devel
)

# Scenario table: <name>|<kind>|<speed arguments>.  `kind` selects the strict
# extractor in scripts/results/parse_benchmark.py.
TONGSUO_SCENARIOS=(
    "sm4_gcm|table|-evp sm4-gcm"
    "sm4_cbc|table|-evp sm4-cbc"
    "aes_256_gcm|table|-evp aes-256-gcm"
    "zuc_128_eea3|table|-evp zuc-128-eea3"
    "sm3|table|sm3"
    "sha256|table|sha256"
    "sm2_sign_verify|pubkey|sm2"
    "ecdsa_p256|pubkey|ecdsap256"
    "rsa2048|pubkey|rsa2048"
    "ecdh_p256|ecdh|ecdhp256"
)

STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

TONGSUO_SRC_DIR=""
TONGSUO_RUNS_DIR=""
TONGSUO_LOG=""

log_message() {
    printf '[tongsuo] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    if [[ ! "${TONGSUO_WARMUPS}" =~ ^[0-9]+$ ]] || [[ "${TONGSUO_WARMUPS}" -lt 1 ]]; then
        log_message "ERROR: TONGSUO_WARMUPS must be a positive integer, got ${TONGSUO_WARMUPS}"
        return 20
    fi
    if [[ ! "${TONGSUO_SAMPLES}" =~ ^[0-9]+$ ]] || [[ "${TONGSUO_SAMPLES}" -lt 1 ]]; then
        log_message "ERROR: TONGSUO_SAMPLES must be a positive integer, got ${TONGSUO_SAMPLES}"
        return 20
    fi
    if [[ "${TONGSUO_SAMPLES}" -lt 5 ]]; then
        log_message "WARNING: TONGSUO_SAMPLES=${TONGSUO_SAMPLES} is below the 5-sample minimum used for published numbers (local smoke runs only)"
    fi
    if [[ ! "${TONGSUO_SECONDS}" =~ ^[0-9]+$ ]] || [[ "${TONGSUO_SECONDS}" -lt 1 ]]; then
        log_message "ERROR: TONGSUO_SECONDS must be a positive integer, got ${TONGSUO_SECONDS}"
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

    TONGSUO_SRC_DIR="${PERF_WORK_DIR}/Tongsuo-${SOFTWARE_VERSION}"
    TONGSUO_RUNS_DIR="${RESULTS_DIR}/runs"
    TONGSUO_LOG="${RESULTS_DIR}/benchmark_tongsuo.txt"

    export SOFTWARE_NAME SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    export PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export TONGSUO_WARMUPS TONGSUO_SAMPLES TONGSUO_STATISTIC TONGSUO_SECONDS
    export TONGSUO_SRC_DIR TONGSUO_RUNS_DIR TONGSUO_LOG
    export TONGSUO_ARCHIVE_NAME TONGSUO_ARCHIVE_SHA256 TONGSUO_ARCHIVE_BYTES
    export TONGSUO_TAG_COMMIT TONGSUO_SOURCE_ARCHIVE_DIR TONGSUO_BUILD_JOBS
    export TONGSUO_CONFIG_FLAGS
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${TONGSUO_RUNS_DIR}" \
        "${PERF_WORK_DIR}/downloads"
}

# ------------------------------------------------------------------------------
# Host tooling required before the private container can be created.
# ------------------------------------------------------------------------------
tongsuo_require_host_tools() {
    local missing=() tool
    for tool in docker curl sha256sum tar; do
        command -v "${tool}" >/dev/null 2>&1 || missing+=("${tool}")
    done
    if [[ "${#missing[@]}" -ne 0 ]]; then
        log_message "ERROR: missing host tools: ${missing[*]}"
        return 30
    fi
}

# ------------------------------------------------------------------------------
# Source archive: local runner archive first, download only as a fallback.
# ------------------------------------------------------------------------------
tongsuo_fetch_archive() {
    local archive="${TONGSUO_SOURCE_ARCHIVE_DIR}/${TONGSUO_ARCHIVE_NAME}"
    local target="${PERF_WORK_DIR}/downloads/${TONGSUO_ARCHIVE_NAME}"
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
        log_message "local source archive is absent; downloading ${TONGSUO_ARCHIVE_NAME}"
        local downloaded=0
        for url in "${TONGSUO_SOURCE_URLS[@]}"; do
            if tongsuo_with_proxy curl -fSL --retry 2 --connect-timeout 30 \
                -o "${target}.part" "${url}"; then
                mv -f "${target}.part" "${target}" || return 30
                downloaded=1
                log_message "downloaded ${TONGSUO_ARCHIVE_NAME} from ${url}"
                break
            fi
            log_message "WARNING: source download failed: ${url}"
        done
        if [[ "${downloaded}" -ne 1 ]]; then
            log_message "ERROR: every source archive location failed"
            return 30
        fi
    fi
    tongsuo_verify_archive "${target}" || return $?
    TONGSUO_ARCHIVE_PATH="${target}"
    export TONGSUO_ARCHIVE_PATH
    log_message "verified source archive: ${target} (sha256 ${TONGSUO_ARCHIVE_SHA256})"
}

tongsuo_verify_archive() {
    local path="$1" actual bytes
    bytes="$(stat -c %s "${path}")"
    if [[ "${bytes}" != "${TONGSUO_ARCHIVE_BYTES}" ]]; then
        log_message "ERROR: source archive size mismatch: ${path} (${bytes} bytes, expected ${TONGSUO_ARCHIVE_BYTES})"
        return 30
    fi
    actual="$(sha256sum "${path}" | awk '{print $1}')"
    if [[ "${actual}" != "${TONGSUO_ARCHIVE_SHA256}" ]]; then
        log_message "ERROR: source archive checksum mismatch: ${path} (${actual})"
        return 30
    fi
}

# ------------------------------------------------------------------------------
# Container-side probes
# ------------------------------------------------------------------------------
tongsuo_cli_version() {
    tongsuo_container_exec_at "${TONGSUO_SRC_DIR}" ./apps/openssl version 2>&1 | head -n 1
}

tongsuo_verify_runtime_payload() {
    local version_line
    tongsuo_container_exec test -x "${TONGSUO_SRC_DIR}/apps/openssl" || {
        log_message "ERROR: apps/openssl is missing in the container: ${TONGSUO_SRC_DIR}/apps/openssl"
        return 30
    }
    version_line="$(tongsuo_cli_version)" || return 30
    case "${version_line}" in
        *"${SOFTWARE_VERSION}"*) ;;
        *) log_message "ERROR: apps/openssl reports '${version_line}', expected ${SOFTWARE_VERSION}"; return 30 ;;
    esac
    if ! tongsuo_container_exec_at "${TONGSUO_SRC_DIR}" ./apps/openssl speed -testmode sha256 >/dev/null 2>&1; then
        log_message "ERROR: apps/openssl speed smoke run failed inside the container"
        return 30
    fi
    log_message "container payload verified: ${version_line}"
}

write_actual_version() {
    local version="${1:-${SOFTWARE_VERSION}}"
    printf '%s\n' "${version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 30
    log_message "recorded actual software version: $(cat "${PERF_ACTUAL_VERSION_FILE}")"
}

write_build_variant() {
    local payload
    payload="$(printf '{"variant":"%s","software":"%s","version":"%s","architecture":"%s","source_archive":"%s","source_sha256":"%s","source_tag_commit":"%s","configure_flags":"%s","container_image":"%s"}\n' \
        "${PERF_VARIANT}" "${SOFTWARE_NAME}" "${SOFTWARE_VERSION}" \
        "$(normalize_architecture "${EXPECTED_ARCH}")" \
        "${TONGSUO_ARCHIVE_NAME}" "${TONGSUO_ARCHIVE_SHA256}" "${TONGSUO_TAG_COMMIT}" \
        "${TONGSUO_CONFIG_FLAGS[*]}" "${TONGSUO_CONTAINER_IMAGE:-unknown}")"
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
TONGSUO_IMAGE_ARCHIVE_DIR="${TONGSUO_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
TONGSUO_CA_ANCHORS_DIR="${TONGSUO_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
TONGSUO_CONTAINER_IMAGE="${TONGSUO_CONTAINER_IMAGE:-}"
TONGSUO_CONTAINER_NAME="${TONGSUO_CONTAINER_NAME:-}"
TONGSUO_CONTAINER_HOME="${TONGSUO_CONTAINER_HOME:-}"
declare -p TONGSUO_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || TONGSUO_CONTAINER_EXTRA_ARGS=()

tongsuo_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

tongsuo_configure_container() {
    local arch
    arch="$(tongsuo_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${TONGSUO_CONTAINER_NAME}" ] || TONGSUO_CONTAINER_NAME="boostkit-tongsuo-${arch}-${PERF_RUN_ID}"
    [ -n "${TONGSUO_CONTAINER_HOME}" ] || TONGSUO_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export TONGSUO_CONTAINER_NAME TONGSUO_CONTAINER_HOME
}

tongsuo_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_tongsuo_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_tongsuo_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${TONGSUO_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_tongsuo_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(tongsuo_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${TONGSUO_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${TONGSUO_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        tongsuo_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        tongsuo_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    TONGSUO_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${TONGSUO_CONTAINER_IMAGE}" ] || ! docker image inspect "${TONGSUO_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${TONGSUO_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_tongsuo_container_image_release || return $?
    export TONGSUO_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${TONGSUO_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_tongsuo_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-tongsuo-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${TONGSUO_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.tongsuo.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_tongsuo_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    tongsuo_configure_container
    require_tongsuo_docker || return $?
    if docker container inspect "${TONGSUO_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${TONGSUO_CONTAINER_NAME}"
        return 40
    fi
    sweep_tongsuo_stale_containers || true
    prepare_tongsuo_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${TONGSUO_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${TONGSUO_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${TONGSUO_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${TONGSUO_CONTAINER_HOME}" || return 40
    log_message "starting private container ${TONGSUO_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${TONGSUO_CONTAINER_NAME}" \
        --label "boostkit.tongsuo.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${TONGSUO_CONTAINER_EXTRA_ARGS[@]}" \
        "${TONGSUO_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${TONGSUO_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${TONGSUO_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${TONGSUO_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${TONGSUO_CONTAINER_NAME}"
}

check_tongsuo_container() {
    tongsuo_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${TONGSUO_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${TONGSUO_CONTAINER_NAME}"
        return 40
    }
}

tongsuo_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    tongsuo_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${TONGSUO_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${TONGSUO_CONTAINER_NAME}" "$@"
}

tongsuo_container_exec() { tongsuo_docker_exec '' '' "$@"; }

tongsuo_container_exec_at() {
    local workdir="$1"
    shift
    tongsuo_docker_exec "${workdir}" '' "$@"
}

tongsuo_container_exec_root() { tongsuo_docker_exec '' root "$@"; }

tongsuo_container_exec_root_at() {
    local workdir="$1"
    shift
    tongsuo_docker_exec "${workdir}" root "$@"
}

remove_tongsuo_container() {
    tongsuo_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${TONGSUO_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.tongsuo.run-id"}}' "${TONGSUO_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${TONGSUO_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${TONGSUO_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${TONGSUO_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${TONGSUO_CONTAINER_NAME}"
}
# >>> container-runtime:end
