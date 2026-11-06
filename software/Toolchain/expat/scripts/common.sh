#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="expat"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-2.9.0}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

EXPAT_VERSION="${SOFTWARE_VERSION}"
EXPAT_VERSION_TAG="R_${EXPAT_VERSION//./_}"
EXPAT_SOURCE_NAME="expat-${EXPAT_VERSION}.tar.xz"

# Official libexpat release asset (the project publishes its release archives on
# GitHub; there is no separate download server).  The digest was computed from
# the official asset and reproduced byte-for-byte through two independent
# mirror paths before this file was written.
EXPAT_SOURCE_SHA256="1e6371862cc31999b368c3b89b49994f0677e1bab5f1b2b85ae3741f5d803051"
EXPAT_SOURCE_URL="https://github.com/libexpat/libexpat/releases/download/${EXPAT_VERSION_TAG}/${EXPAT_SOURCE_NAME}"

# Fallback order.  The dedicated aarch64 Runner cannot reliably reach
# github.com, so the public GitHub mirrors are tried before the canonical URL
# gets its last chance.  Every candidate must produce the same SHA-256.
EXPAT_SOURCE_URLS=(
    "https://gh-proxy.com/https://github.com/libexpat/libexpat/releases/download/${EXPAT_VERSION_TAG}/${EXPAT_SOURCE_NAME}"
    "https://ghfast.top/https://github.com/libexpat/libexpat/releases/download/${EXPAT_VERSION_TAG}/${EXPAT_SOURCE_NAME}"
    "${EXPAT_SOURCE_URL}"
)

# Pre-placed offline assets are preferred (the Runner cannot rely on the public
# internet).  The directory is read-only for the case.
EXPAT_OFFLINE_DIR="${PERF_EXPAT_OFFLINE_DIR:-/home/runner/software/expat}"

EXPAT_JOBS="${PERF_EXPAT_JOBS:-4}"
EXPAT_REPS="${PERF_REPS:-5}"

# Pinned upstream driver parameters.
EXPAT_RUNTESTS_CHECKS=5196
EXPAT_BENCH_ITERATIONS=20
EXPAT_BENCH_BUFFER=8192

# Deterministic corpora generated in the build stage (sizes recorded in
# manifest.json; the parser derives MiB/s from the exact bytes parsed).
EXPAT_CORPORA=(wide huge namespaced entities dtd_ext)

# Scenario table: every scenario is one measured child process whose stdout and
# stderr are kept under runs/<scenario>/.
EXPAT_SCENARIOS=(
    xmlwf_parse_wide
    xmlwf_parse_huge
    xmlwf_parse_namespaced
    xmlwf_parse_entities
    xmlwf_parse_external_dtd
    upstream_runtests
    upstream_benchmark_wide
    upstream_benchmark_namespaced
)

EXPAT_SOURCE_ARCHIVE=""
EXPAT_SRC_DIR=""
EXPAT_PREFIX=""
EXPAT_XMLWF=""
EXPAT_RUNTESTS=""
EXPAT_BENCHMARK=""
EXPAT_CORPUS_DIR=""
EXPAT_CORPUS_MANIFEST=""
PROJECTS_DIR=""
RUNS_DIR=""
EXPAT_VERSION_STRING=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[expat] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
}

# Print the tail of a failed measurement's log to stdout so the CI log carries
# the real parser/build error instead of only an exit code.
report_failure_tail() {
    local log_file="$1" scenario="$2" label="$3" exit_code="$4"
    log_message "ERROR: ${scenario} (${label}) failed with exit code ${exit_code}"
    if [[ -s "${log_file}" ]]; then
        log_message "----- begin tail of ${log_file} (last 60 lines) -----"
        tail -n 60 -- "${log_file}" | while IFS= read -r line; do
            printf '[expat]   %s\n' "${line}"
        done
        log_message "----- end tail of ${log_file} -----"
    else
        log_message "ERROR: no captured output at ${log_file}"
    fi
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
    [[ "${EXPAT_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${EXPAT_REPS}"
        return 10
    }
    if (( EXPAT_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${EXPAT_REPS} is a local link-validation value; formal evidence requires >= 5"
    fi
}

validate_jobs() {
    [[ "${EXPAT_JOBS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_EXPAT_JOBS must be a positive integer, got ${EXPAT_JOBS}"
        return 10
    }
    if (( EXPAT_JOBS > 64 )); then
        log_message "ERROR: PERF_EXPAT_JOBS is unreasonably large: ${EXPAT_JOBS}"
        return 10
    fi
}

configure_runtime_paths() {
    validate_variant || return $?
    validate_reps || return $?
    validate_jobs || return $?
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/expat/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    EXPAT_SOURCE_ARCHIVE="${PERF_WORK_DIR}/downloads/${EXPAT_SOURCE_NAME}"
    EXPAT_SRC_DIR="${PERF_WORK_DIR}/expat-source"
    EXPAT_PREFIX="${PERF_WORK_DIR}/expat-install"
    EXPAT_XMLWF="${EXPAT_SRC_DIR}/xmlwf/xmlwf"
    EXPAT_RUNTESTS="${EXPAT_SRC_DIR}/tests/runtests"
    EXPAT_BENCHMARK="${EXPAT_SRC_DIR}/tests/benchmark/benchmark"
    EXPAT_CORPUS_DIR="${PERF_WORK_DIR}/corpora"
    EXPAT_CORPUS_MANIFEST="${EXPAT_CORPUS_DIR}/manifest.json"
    PROJECTS_DIR="${PERF_WORK_DIR}/projects"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export SOFTWARE_NAME SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID
    export RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export EXPAT_VERSION EXPAT_SRC_DIR EXPAT_PREFIX EXPAT_XMLWF EXPAT_RUNTESTS
    export EXPAT_BENCHMARK EXPAT_CORPUS_DIR EXPAT_CORPUS_MANIFEST
    export EXPAT_SOURCE_ARCHIVE PROJECTS_DIR RUNS_DIR EXPAT_REPS EXPAT_JOBS
    export EXPAT_SOURCE_NAME EXPAT_SOURCE_SHA256 EXPAT_SOURCE_URL
    export EXPAT_OFFLINE_DIR EXPAT_RUNTESTS_CHECKS EXPAT_BENCH_ITERATIONS
    export EXPAT_BENCH_BUFFER
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

compiler_identity() {
    local compiler
    if ! compiler="$(expat_container_exec cc --version 2>&1 | head -n 1)"; then
        compiler="unknown"
    fi
    printf '%s\n' "${compiler:-unknown}"
}

# xmlwf --version prints "xmlwf using expat_2.9.0"; strip the prefix.
decode_expat_version() {
    local line="$1"
    local version="${line##*expat_}"
    if [[ "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        printf '%s\n' "${version}"
        return 0
    fi
    return 1
}

expat_version_string() {
    expat_container_exec "${EXPAT_XMLWF}" --version 2>&1 | head -n 1
}

scenario_task() {
    case "$1" in
        xmlwf_parse_*) printf 'parse\n' ;;
        upstream_runtests) printf 'upstream_suite\n' ;;
        upstream_benchmark_*) printf 'upstream_benchmark\n' ;;
        *) printf '%s\n' "$1" ;;
    esac
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
EXPAT_IMAGE_ARCHIVE_DIR="${EXPAT_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
EXPAT_CA_ANCHORS_DIR="${EXPAT_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
EXPAT_CONTAINER_IMAGE="${EXPAT_CONTAINER_IMAGE:-}"
EXPAT_CONTAINER_NAME="${EXPAT_CONTAINER_NAME:-}"
EXPAT_CONTAINER_HOME="${EXPAT_CONTAINER_HOME:-}"
declare -p EXPAT_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || EXPAT_CONTAINER_EXTRA_ARGS=()

expat_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

expat_configure_container() {
    local arch
    arch="$(expat_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${EXPAT_CONTAINER_NAME}" ] || EXPAT_CONTAINER_NAME="boostkit-expat-${arch}-${PERF_RUN_ID}"
    [ -n "${EXPAT_CONTAINER_HOME}" ] || EXPAT_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export EXPAT_CONTAINER_NAME EXPAT_CONTAINER_HOME
}

expat_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_expat_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_expat_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${EXPAT_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_expat_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(expat_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${EXPAT_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${EXPAT_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        expat_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        expat_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    EXPAT_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${EXPAT_CONTAINER_IMAGE}" ] || ! docker image inspect "${EXPAT_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${EXPAT_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_expat_container_image_release || return $?
    export EXPAT_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${EXPAT_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_expat_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-expat-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${EXPAT_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.expat.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_expat_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    expat_configure_container
    require_expat_docker || return $?
    if docker container inspect "${EXPAT_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${EXPAT_CONTAINER_NAME}"
        return 40
    fi
    sweep_expat_stale_containers || true
    prepare_expat_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${EXPAT_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${EXPAT_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${EXPAT_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${EXPAT_CONTAINER_HOME}" || return 40
    log_message "starting private container ${EXPAT_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${EXPAT_CONTAINER_NAME}" \
        --label "boostkit.expat.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${EXPAT_CONTAINER_EXTRA_ARGS[@]}" \
        "${EXPAT_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${EXPAT_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${EXPAT_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${EXPAT_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${EXPAT_CONTAINER_NAME}"
}

check_expat_container() {
    expat_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${EXPAT_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${EXPAT_CONTAINER_NAME}"
        return 40
    }
}

expat_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    expat_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${EXPAT_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${EXPAT_CONTAINER_NAME}" "$@"
}

expat_container_exec() { expat_docker_exec '' '' "$@"; }

expat_container_exec_at() {
    local workdir="$1"
    shift
    expat_docker_exec "${workdir}" '' "$@"
}

expat_container_exec_root() { expat_docker_exec '' root "$@"; }

expat_container_exec_root_at() {
    local workdir="$1"
    shift
    expat_docker_exec "${workdir}" root "$@"
}

remove_expat_container() {
    expat_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${EXPAT_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.expat.run-id"}}' "${EXPAT_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${EXPAT_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${EXPAT_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${EXPAT_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${EXPAT_CONTAINER_NAME}"
}
# >>> container-runtime:end
