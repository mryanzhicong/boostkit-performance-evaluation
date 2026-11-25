#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SOFTWARE_VERSION="${SOFTWARE_VERSION:-4.6.11}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

PERF_REPS="${PERF_REPS:-5}"
SIMDJSON_WARMUPS="${SIMDJSON_WARMUPS:-1}"
SIMDJSON_BENCH_MIN_TIME="${SIMDJSON_BENCH_MIN_TIME:-1s}"
SIMDJSON_PARSE_ITERATIONS="${SIMDJSON_PARSE_ITERATIONS:-1000}"
SIMDJSON_OFFLINE_DIR="${SIMDJSON_OFFLINE_DIR:-/home/runner/software/simdjson}"

SIMDJSON_CONTAINER_IMAGE="${SIMDJSON_CONTAINER_IMAGE:-}"
SIMDJSON_CONTAINER_NAME="${SIMDJSON_CONTAINER_NAME:-}"
SIMDJSON_CONTAINER_HOME="${SIMDJSON_CONTAINER_HOME:-}"
declare -a SIMDJSON_CONTAINER_EXTRA_ARGS=()
# Escape hatch for restricted networks: extra docker run arguments, for example
# --add-host entries when a local package mirror has to be reached by IP.
if [[ -n "${SIMDJSON_DOCKER_EXTRA_ARGS:-}" ]]; then
    read -r -a SIMDJSON_CONTAINER_EXTRA_ARGS <<< "${SIMDJSON_DOCKER_EXTRA_ARGS}"
fi

STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"
STANDALONE_STATUS="${STANDALONE_STATUS:-}"

# Pinned upstream inputs.  Every archive is verified before it is unpacked; a
# mismatch aborts the build instead of producing numbers from other sources.
SIMDJSON_SOURCE_ARCHIVE="simdjson-v4.6.11.tar.gz"
SIMDJSON_SOURCE_URL="https://codeload.github.com/simdjson/simdjson/tar.gz/refs/tags/v4.6.11"
SIMDJSON_SOURCE_SHA256="61d948fc24f0d793829ad658058e7597d064988a89b4607ea02e401a82df98ff"
SIMDJSON_SOURCE_BYTES=6709400
SIMDJSON_SOURCE_ROOT="simdjson-4.6.11"

SIMDJSON_BENCHMARK_ARCHIVE="benchmark-v1.9.5.zip"
SIMDJSON_BENCHMARK_URL="https://codeload.github.com/google/benchmark/zip/refs/tags/v1.9.5"
SIMDJSON_BENCHMARK_SHA256="68c9c65cee4864db42c3af9ff5b5cfa32ce1b01d9653136c5f4ff96e18a9b8f2"
SIMDJSON_BENCHMARK_BYTES=347679
SIMDJSON_BENCHMARK_ROOT="benchmark-1.9.5"

SIMDJSON_DATA_ARCHIVE="simdjson-data-3519499.zip"
SIMDJSON_DATA_URL="https://codeload.github.com/simdjson/simdjson-data/zip/351949906abde446f0314bf79606fb5d884f5be7"
SIMDJSON_DATA_SHA256="a2623f4cbe5ee988c00ff26549dd0e7738b25938fd4d6e5f1f7d10faf748a884"
SIMDJSON_DATA_BYTES=7188926
SIMDJSON_DATA_ROOT="simdjson-data-3519499"

SIMDJSON_TARGETS=(parse parse_stream bench_parse_call bench_dom_api bench_ondemand)
SIMDJSON_SCENARIOS=(dom_parse dom_parse_stream bench_parse_call bench_dom_api bench_ondemand)

log_message() { printf '[simdjson] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

simdjson_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) log_message "ERROR: unsupported architecture: $1" >&2; return 20 ;;
    esac
}

simdjson_repo_root() {
    local root
    root="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel 2>/dev/null || true)"
    if [[ -n "${root}" ]]; then
        printf '%s\n' "${root}"
    else
        printf '%s\n' "$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
    fi
}

simdjson_configure_paths() {
    local arch root
    arch="$(simdjson_arch "${EXPECTED_ARCH}")"
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || { log_message "ERROR: unsafe run ID: ${PERF_RUN_ID}"; return 10; }
    root="$(simdjson_repo_root)"
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        if [[ "${STANDALONE_OWNS_WORK_DIR}" -eq 1 ]]; then
            PERF_WORK_DIR="${root}/.perf-work/simdjson/${SOFTWARE_VERSION}/${arch}/${PERF_RUN_ID}"
        else
            PERF_WORK_DIR="/home/runner/boostkit-perf/simdjson/${SOFTWARE_VERSION}/${arch}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${root}/.perf-output/HPC/simdjson/${SOFTWARE_VERSION}/${arch}/${PERF_RUN_ID}"
    fi
    [[ "${PERF_WORK_DIR}" == /* && "${PERF_WORK_DIR}" != *'/../'* ]] || { log_message 'ERROR: work directory must be an absolute safe path'; return 10; }
    [[ "${RESULTS_DIR}" == /* ]] || { log_message 'ERROR: results directory must be absolute'; return 10; }
    [[ "${PERF_WORK_DIR}" != *'/../'* && "${RESULTS_DIR}" != *'/../'* ]] || { log_message 'ERROR: directories must not contain ..'; return 10; }
    [[ "${PERF_WORK_DIR}" != "${RESULTS_DIR}" ]] || { log_message 'ERROR: work and result directories must differ'; return 10; }
    export PERF_RUN_ID PERF_WORK_DIR RESULTS_DIR SOFTWARE_VERSION PERF_VARIANT EXPECTED_ARCH
}

simdjson_initialize_runtime() {
    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}"
    log_message "runtime: arch=$(simdjson_arch "${EXPECTED_ARCH}") variant=${PERF_VARIANT} run_id=${PERF_RUN_ID}"
    log_message "work directory: ${PERF_WORK_DIR}"
    log_message "results directory: ${RESULTS_DIR}"
}

simdjson_verify_archive() {
    local file="$1" expected="$2" actual
    [[ -s "${file}" ]] || { log_message "ERROR: missing archive: ${file}"; return 30; }
    actual="$(sha256sum "${file}")"
    actual="${actual%% *}"
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: sha256 mismatch for ${file}: expected ${expected}, got ${actual}"
        return 30
    fi
}

# fetch_archive <name> <url> <sha256> <target-dir>
simdjson_fetch_archive() {
    local name="$1" url="$2" expected="$3" target_dir="$4" source="${SIMDJSON_OFFLINE_DIR}/${1}" dest
    mkdir -p "${target_dir}"
    dest="${target_dir}/${name}"
    if [[ -s "${source}" ]]; then
        log_message "using offline archive ${source}"
        cp -- "${source}" "${dest}.part" || return 30
    else
        log_message "downloading ${url}"
        if [[ -n "${PERF_PROXY:-}" ]]; then
            http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" curl -fSL --retry 3 --connect-timeout 30 -o "${dest}.part" "${url}" || return 30
        else
            curl -fSL --retry 3 --connect-timeout 30 -o "${dest}.part" "${url}" || return 30
        fi
    fi
    simdjson_verify_archive "${dest}.part" "${expected}" || { rm -f -- "${dest}.part"; return 30; }
    mv -f -- "${dest}.part" "${dest}"
    printf '%s  %s\n' "${expected}" "${name}" >> "${target_dir}/sha256sums.txt"
    log_message "verified ${name} ($(stat -c '%s' "${dest}") bytes, sha256 ${expected})"
}

simdjson_source_dir() { printf '%s/%s\n' "${PERF_WORK_DIR}" "${SIMDJSON_SOURCE_ROOT}"; }
simdjson_benchmark_source_dir() { printf '%s/deps/%s\n' "${PERF_WORK_DIR}" "${SIMDJSON_BENCHMARK_ROOT}"; }
simdjson_data_dir() { printf '%s/deps/%s/jsonexamples\n' "${PERF_WORK_DIR}" "${SIMDJSON_DATA_ROOT}"; }
simdjson_build_dir() { printf '%s/build\n' "${PERF_WORK_DIR}"; }
simdjson_downloads_dir() { printf '%s/downloads\n' "${PERF_WORK_DIR}"; }

simdjson_write_build_variant() {
    local variant="$1" output="${RESULTS_DIR}/build_variant.json" arch gcc_version image binaries_json entry sha name
    arch="$(simdjson_arch "${EXPECTED_ARCH}")"
    gcc_version="$(simdjson_container_exec bash -c 'gcc --version | head -n 1')" || gcc_version=unknown
    image="${SIMDJSON_CONTAINER_IMAGE:-unknown}"
    binaries_json=""
    for name in "${SIMDJSON_TARGETS[@]}"; do
        sha="$(simdjson_container_exec sha256sum "$(simdjson_build_dir)/${name}")" || return 40
        sha="${sha%% *}"
        [[ -z "${binaries_json}" ]] || binaries_json+=", "
        binaries_json+="\"${name}\": \"${sha}\""
    done
    entry="{\"variant\": \"${variant}\", \"architecture\": \"${arch}\", \"version\": \"${SOFTWARE_VERSION}\", \"run_id\": \"${PERF_RUN_ID}\", \"container_image\": \"${image}\", \"compiler\": \"${gcc_version//\"/\\\"}\", \"benchmark_min_time\": \"${SIMDJSON_BENCH_MIN_TIME}\", \"parse_iterations\": ${SIMDJSON_PARSE_ITERATIONS}, \"archives\": {\"simdjson\": \"${SIMDJSON_SOURCE_SHA256}\", \"google_benchmark\": \"${SIMDJSON_BENCHMARK_SHA256}\", \"simdjson_data\": \"${SIMDJSON_DATA_SHA256}\"}, \"binaries\": {${binaries_json}}, \"parameters\": {\"variant\": \"${variant}\", \"benchmark_min_time\": \"${SIMDJSON_BENCH_MIN_TIME}\", \"parse_iterations\": ${SIMDJSON_PARSE_ITERATIONS}, \"warmups\": ${SIMDJSON_WARMUPS}, \"reps\": ${PERF_REPS}}}"
    mkdir -p "${RESULTS_DIR}"
    printf '%s\n' "${entry}" > "${output}"
    log_message "wrote ${output}"
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
SIMDJSON_IMAGE_ARCHIVE_DIR="${SIMDJSON_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
SIMDJSON_CA_ANCHORS_DIR="${SIMDJSON_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
SIMDJSON_CONTAINER_IMAGE="${SIMDJSON_CONTAINER_IMAGE:-}"
SIMDJSON_CONTAINER_NAME="${SIMDJSON_CONTAINER_NAME:-}"
SIMDJSON_CONTAINER_HOME="${SIMDJSON_CONTAINER_HOME:-}"
declare -p SIMDJSON_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || SIMDJSON_CONTAINER_EXTRA_ARGS=()

simdjson_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

simdjson_configure_container() {
    local arch
    arch="$(simdjson_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${SIMDJSON_CONTAINER_NAME}" ] || SIMDJSON_CONTAINER_NAME="boostkit-simdjson-${arch}-${PERF_RUN_ID}"
    [ -n "${SIMDJSON_CONTAINER_HOME}" ] || SIMDJSON_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export SIMDJSON_CONTAINER_NAME SIMDJSON_CONTAINER_HOME
}

simdjson_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_simdjson_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_simdjson_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${SIMDJSON_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_simdjson_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(simdjson_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${SIMDJSON_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${SIMDJSON_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        simdjson_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        simdjson_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    SIMDJSON_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${SIMDJSON_CONTAINER_IMAGE}" ] || ! docker image inspect "${SIMDJSON_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${SIMDJSON_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_simdjson_container_image_release || return $?
    export SIMDJSON_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${SIMDJSON_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_simdjson_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-simdjson-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${SIMDJSON_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.simdjson.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_simdjson_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    simdjson_configure_container
    require_simdjson_docker || return $?
    if docker container inspect "${SIMDJSON_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${SIMDJSON_CONTAINER_NAME}"
        return 40
    fi
    sweep_simdjson_stale_containers || true
    prepare_simdjson_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${SIMDJSON_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${SIMDJSON_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${SIMDJSON_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${SIMDJSON_CONTAINER_HOME}" || return 40
    log_message "starting private container ${SIMDJSON_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${SIMDJSON_CONTAINER_NAME}" \
        --label "boostkit.simdjson.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${SIMDJSON_CONTAINER_EXTRA_ARGS[@]}" \
        "${SIMDJSON_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${SIMDJSON_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${SIMDJSON_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${SIMDJSON_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${SIMDJSON_CONTAINER_NAME}"
}

check_simdjson_container() {
    simdjson_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${SIMDJSON_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${SIMDJSON_CONTAINER_NAME}"
        return 40
    }
}

simdjson_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    simdjson_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${SIMDJSON_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${SIMDJSON_CONTAINER_NAME}" "$@"
}

simdjson_container_exec() { simdjson_docker_exec '' '' "$@"; }

simdjson_container_exec_at() {
    local workdir="$1"
    shift
    simdjson_docker_exec "${workdir}" '' "$@"
}

simdjson_container_exec_root() { simdjson_docker_exec '' root "$@"; }

simdjson_container_exec_root_at() {
    local workdir="$1"
    shift
    simdjson_docker_exec "${workdir}" root "$@"
}

remove_simdjson_container() {
    simdjson_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${SIMDJSON_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.simdjson.run-id"}}' "${SIMDJSON_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${SIMDJSON_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${SIMDJSON_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${SIMDJSON_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${SIMDJSON_CONTAINER_NAME}"
}
# >>> container-runtime:end
