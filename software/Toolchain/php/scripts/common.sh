#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="php"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-8.5.12}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

PHP_SOURCE_NAME="php-${SOFTWARE_VERSION}.tar.gz"
# Official release archive: https://www.php.net/distributions/php-8.5.12.tar.gz
# Official SHA-256 comes from https://www.php.net/releases/index.php?json&version=8.5
PHP_SOURCE_SHA256="81a0f450349e84b08eb43faa85f8a4c835684f3cc1c50471775d1317a046c525"
PHP_SOURCE_SIZE="24469403"
PHP_OFFICIAL_SOURCE_BASE="https://www.php.net/distributions"
PHP_OFFLINE_DIR="${PHP_OFFLINE_DIR:-/home/runner/software/php}"
PHP_BUILD_JOBS="${PHP_BUILD_JOBS:-$(nproc)}"
# Minimal CLI build, fixed here and in the README: no FPM, no HTTP SAPI, no
# third-party extensions.  PHP 8.5 always compiles Zend OPcache into the CLI
# binary (there is no shared opcache.so any more), so the opcache scenarios
# only toggle opcache.enable_cli / the file cache at run time; the JIT is
# disabled at build time to keep the baseline free of JIT-compiled code.
PHP_CONFIGURE_FLAGS=(
    --disable-all
    --enable-cli
    --disable-opcache-jit
)
PHP_RUN_TIMEOUT_SECONDS="${PHP_RUN_TIMEOUT_SECONDS:-1800}"
PHP_REPS="${PERF_REPS:-5}"
PHP_GENERATED_MODULES="${PHP_GENERATED_MODULES:-1000}"

PHP_SOURCE_URLS=()
if [[ -n "${PERF_PHP_SOURCE_MIRROR:-}" ]]; then
    PHP_SOURCE_URLS+=("${PERF_PHP_SOURCE_MIRROR%/}/${PHP_SOURCE_NAME}")
fi
PHP_SOURCE_URLS+=("${PHP_OFFICIAL_SOURCE_BASE}/${PHP_SOURCE_NAME}")

PHP_SCENARIOS_FILE="${SCRIPT_DIR}/benchmarks/scenarios.psv"

PHP_SRC_DIR=""
PHP_INSTALL_DIR=""
PHP_BIN=""
PHP_OPCACHE_SO=""
PHP_OPCACHE_INI=""
PHP_OPCACHE_CACHE_DIR=""
PHP_GENERATED_DIR=""
PHP_BUILD_DIR=""
PHP_DOWNLOADS_DIR=""
PHP_VERSION_STRING=""
PHP_CONFIGURE_SUMMARY=""
RUNS_DIR=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[php] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
        *)
            log_message "ERROR: invalid build variant: ${PERF_VARIANT}"
            return 10
            ;;
    esac
}

validate_reps() {
    [[ "${PHP_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${PHP_REPS}"
        return 10
    }
    if (( PHP_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${PHP_REPS} is a local link-validation value; formal evidence requires 5"
    fi
}

configure_runtime_paths() {
    validate_variant || return $?
    validate_reps || return $?
    [[ "${SOFTWARE_VERSION}" == "8.5.12" ]] || {
        log_message "ERROR: unsupported PHP version: ${SOFTWARE_VERSION}"
        return 10
    }
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    local runner_architecture
    runner_architecture="$(normalize_architecture "$(uname -m)")"
    EXPECTED_ARCH="$(normalize_architecture "${EXPECTED_ARCH}")"
    case "${EXPECTED_ARCH}" in
        x86_64|aarch64) ;;
        *)
            log_message "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
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
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/php/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    TMPDIR="${PERF_WORK_DIR}/tmp"
    PHP_SRC_DIR="${PERF_WORK_DIR}/php-src/php-${SOFTWARE_VERSION}"
    PHP_INSTALL_DIR="${PERF_WORK_DIR}/php-install"
    PHP_BIN="${PHP_INSTALL_DIR}/bin/php"
    PHP_OPCACHE_INI="${PERF_WORK_DIR}/opcache.ini"
    PHP_OPCACHE_CACHE_DIR="${PERF_WORK_DIR}/opcache-file-cache"
    PHP_GENERATED_DIR="${PERF_WORK_DIR}/generated/modules"
    PHP_BUILD_DIR="${PERF_WORK_DIR}/build"
    PHP_DOWNLOADS_DIR="${PERF_WORK_DIR}/downloads"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID PERF_WORK_DIR
    export RESULTS_DIR PERF_ACTUAL_VERSION_FILE TMPDIR PHP_REPS PHP_OFFLINE_DIR
    export PHP_GENERATED_MODULES PHP_GENERATED_DIR PHP_SRC_DIR PHP_INSTALL_DIR
    export PHP_BIN PHP_OPCACHE_INI PHP_OPCACHE_CACHE_DIR PHP_BUILD_DIR RUNS_DIR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

scenario_count() {
    local count=0 scenario dimension runner target scale check expected tolerance workload
    while IFS='|' read -r scenario dimension runner target scale check expected tolerance workload; do
        [[ -z "${scenario}" || "${scenario}" == \#* ]] && continue
        count=$((count + 1))
    done < "${PHP_SCENARIOS_FILE}"
    printf '%s\n' "${count}"
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
PHP_IMAGE_ARCHIVE_DIR="${PHP_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
PHP_CA_ANCHORS_DIR="${PHP_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
PHP_CONTAINER_IMAGE="${PHP_CONTAINER_IMAGE:-}"
PHP_CONTAINER_NAME="${PHP_CONTAINER_NAME:-}"
PHP_CONTAINER_HOME="${PHP_CONTAINER_HOME:-}"
declare -p PHP_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || PHP_CONTAINER_EXTRA_ARGS=()

php_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

php_configure_container() {
    local arch
    arch="$(php_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${PHP_CONTAINER_NAME}" ] || PHP_CONTAINER_NAME="boostkit-php-${arch}-${PERF_RUN_ID}"
    [ -n "${PHP_CONTAINER_HOME}" ] || PHP_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export PHP_CONTAINER_NAME PHP_CONTAINER_HOME
}

php_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_php_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_php_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${PHP_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_php_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(php_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${PHP_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${PHP_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        php_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        php_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    PHP_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${PHP_CONTAINER_IMAGE}" ] || ! docker image inspect "${PHP_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${PHP_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_php_container_image_release || return $?
    export PHP_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${PHP_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_php_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-php-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${PHP_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.php.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_php_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    php_configure_container
    require_php_docker || return $?
    if docker container inspect "${PHP_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${PHP_CONTAINER_NAME}"
        return 40
    fi
    sweep_php_stale_containers || true
    prepare_php_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${PHP_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${PHP_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${PHP_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${PHP_CONTAINER_HOME}" || return 40
    log_message "starting private container ${PHP_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${PHP_CONTAINER_NAME}" \
        --label "boostkit.php.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${PHP_CONTAINER_EXTRA_ARGS[@]}" \
        "${PHP_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${PHP_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${PHP_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${PHP_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${PHP_CONTAINER_NAME}"
}

check_php_container() {
    php_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${PHP_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${PHP_CONTAINER_NAME}"
        return 40
    }
}

php_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    php_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${PHP_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${PHP_CONTAINER_NAME}" "$@"
}

php_container_exec() { php_docker_exec '' '' "$@"; }

php_container_exec_at() {
    local workdir="$1"
    shift
    php_docker_exec "${workdir}" '' "$@"
}

php_container_exec_root() { php_docker_exec '' root "$@"; }

php_container_exec_root_at() {
    local workdir="$1"
    shift
    php_docker_exec "${workdir}" root "$@"
}

remove_php_container() {
    php_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${PHP_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.php.run-id"}}' "${PHP_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${PHP_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${PHP_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${PHP_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${PHP_CONTAINER_NAME}"
}
# >>> container-runtime:end
