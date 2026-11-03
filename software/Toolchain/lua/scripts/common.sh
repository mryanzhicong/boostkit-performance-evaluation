#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="lua"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-5.5.1}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

LUA_VERSION="${SOFTWARE_VERSION}"
LUA_SOURCE_NAME="lua-${LUA_VERSION}.tar.gz"
LUA_TESTSUITE_NAME="lua-${LUA_VERSION}-tests.tar.gz"

# Official release archive: https://www.lua.org/ftp/lua-5.5.1.tar.gz
# Official checksum: https://www.lua.org/ftp/ (sha256 column), download.html.
LUA_SOURCE_SHA256="1c4b4068d67061f2a2231ad2b5422e77acea1487ea9890f6320af614f4373dce"
LUA_SOURCE_SIZE="398643"
# Official test suite: https://www.lua.org/tests/lua-5.5.1-tests.tar.gz
LUA_TESTSUITE_SHA256="da07b543872dc0bb2ff12aabd0c248578d78df3eb6b67efdc537a46d455c7f31"
LUA_TESTSUITE_SIZE="150553"

LUA_OFFICIAL_SOURCE_BASE="https://www.lua.org/ftp"
LUA_OFFICIAL_TESTSUITE_BASE="https://www.lua.org/tests"
LUA_OFFLINE_DIR="${LUA_OFFLINE_DIR:-/home/runner/software/lua}"
LUA_BUILD_TARGET="linux"
LUA_GENERATED_MODULES="${LUA_GENERATED_MODULES:-12000}"
LUA_RUN_TIMEOUT_SECONDS="${LUA_RUN_TIMEOUT_SECONDS:-1800}"

LUA_SOURCE_URLS=()
LUA_TESTSUITE_URLS=()
if [[ -n "${PERF_LUA_SOURCE_MIRROR:-}" ]]; then
    LUA_SOURCE_URLS+=("${PERF_LUA_SOURCE_MIRROR%/}/${LUA_SOURCE_NAME}")
fi
LUA_SOURCE_URLS+=("${LUA_OFFICIAL_SOURCE_BASE}/${LUA_SOURCE_NAME}")
if [[ -n "${PERF_LUA_TESTSUITE_MIRROR:-}" ]]; then
    LUA_TESTSUITE_URLS+=("${PERF_LUA_TESTSUITE_MIRROR%/}/${LUA_TESTSUITE_NAME}")
fi
LUA_TESTSUITE_URLS+=("${LUA_OFFICIAL_TESTSUITE_BASE}/${LUA_TESTSUITE_NAME}")

LUA_REPS="${PERF_REPS:-5}"
LUA_SCENARIOS_FILE="${SCRIPT_DIR}/benchmarks/scenarios.psv"

LUA_SRC_DIR=""
LUA_TESTS_DIR=""
LUA_DOWNLOADS_DIR=""
LUA_GENERATED_DIR=""
LUA_BIN=""
LUAC_BIN=""
RUNS_DIR=""
LUA_VERSION_STRING=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[lua] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    [[ "${LUA_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${LUA_REPS}"
        return 10
    }
    if (( LUA_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${LUA_REPS} is a local link-validation value; formal evidence requires 5"
    fi
}

configure_runtime_paths() {
    validate_variant || return $?
    validate_reps || return $?
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/lua/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    LUA_SRC_DIR="${PERF_WORK_DIR}/lua-src"
    LUA_TESTS_DIR="${PERF_WORK_DIR}/lua-tests"
    LUA_DOWNLOADS_DIR="${PERF_WORK_DIR}/downloads"
    LUA_GENERATED_DIR="${PERF_WORK_DIR}/generated/luac"
    LUA_BIN="${LUA_SRC_DIR}/src/lua"
    LUAC_BIN="${LUA_SRC_DIR}/src/luac"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR LUA_REPS LUA_OFFLINE_DIR LUA_GENERATED_MODULES
    export LUA_SRC_DIR LUA_TESTS_DIR LUA_DOWNLOADS_DIR LUA_GENERATED_DIR LUA_BIN LUAC_BIN RUNS_DIR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

scenario_expected_checksum() {
    local wanted_runner="$1" scenario dimension runner target scale check expected tolerance workload
    while IFS='|' read -r scenario dimension runner target scale check expected tolerance workload; do
        [[ -z "${scenario}" || "${scenario}" == \#* ]] && continue
        if [[ "${runner}" == "${wanted_runner}" ]]; then
            printf '%s\n' "${expected}"
            return 0
        fi
    done < "${LUA_SCENARIOS_FILE}"
    return 1
}

scenario_count() {
    local count=0 scenario dimension runner target scale check expected tolerance workload
    while IFS='|' read -r scenario dimension runner target scale check expected tolerance workload; do
        [[ -z "${scenario}" || "${scenario}" == \#* ]] && continue
        count=$((count + 1))
    done < "${LUA_SCENARIOS_FILE}"
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
LUA_IMAGE_ARCHIVE_DIR="${LUA_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
LUA_CA_ANCHORS_DIR="${LUA_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
LUA_CONTAINER_IMAGE="${LUA_CONTAINER_IMAGE:-}"
LUA_CONTAINER_NAME="${LUA_CONTAINER_NAME:-}"
LUA_CONTAINER_HOME="${LUA_CONTAINER_HOME:-}"
declare -p LUA_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || LUA_CONTAINER_EXTRA_ARGS=()

lua_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

lua_configure_container() {
    local arch
    arch="$(lua_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${LUA_CONTAINER_NAME}" ] || LUA_CONTAINER_NAME="boostkit-lua-${arch}-${PERF_RUN_ID}"
    [ -n "${LUA_CONTAINER_HOME}" ] || LUA_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export LUA_CONTAINER_NAME LUA_CONTAINER_HOME
}

lua_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_lua_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_lua_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${LUA_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_lua_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(lua_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${LUA_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${LUA_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        lua_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        lua_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    LUA_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${LUA_CONTAINER_IMAGE}" ] || ! docker image inspect "${LUA_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${LUA_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_lua_container_image_release || return $?
    export LUA_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${LUA_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_lua_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-lua-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${LUA_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.lua.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_lua_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    lua_configure_container
    require_lua_docker || return $?
    if docker container inspect "${LUA_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${LUA_CONTAINER_NAME}"
        return 40
    fi
    sweep_lua_stale_containers || true
    prepare_lua_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${LUA_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${LUA_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${LUA_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${LUA_CONTAINER_HOME}" || return 40
    log_message "starting private container ${LUA_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${LUA_CONTAINER_NAME}" \
        --label "boostkit.lua.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${LUA_CONTAINER_EXTRA_ARGS[@]}" \
        "${LUA_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${LUA_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${LUA_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${LUA_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${LUA_CONTAINER_NAME}"
}

check_lua_container() {
    lua_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${LUA_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${LUA_CONTAINER_NAME}"
        return 40
    }
}

lua_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    lua_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${LUA_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${LUA_CONTAINER_NAME}" "$@"
}

lua_container_exec() { lua_docker_exec '' '' "$@"; }

lua_container_exec_at() {
    local workdir="$1"
    shift
    lua_docker_exec "${workdir}" '' "$@"
}

lua_container_exec_root() { lua_docker_exec '' root "$@"; }

lua_container_exec_root_at() {
    local workdir="$1"
    shift
    lua_docker_exec "${workdir}" root "$@"
}

remove_lua_container() {
    lua_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${LUA_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.lua.run-id"}}' "${LUA_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${LUA_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${LUA_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${LUA_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${LUA_CONTAINER_NAME}"
}
# >>> container-runtime:end
