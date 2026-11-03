#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="libxml2"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-2.15.4}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

LIBXML2_VERSION="${SOFTWARE_VERSION}"
LIBXML2_SERIES="${LIBXML2_VERSION%.*}"
LIBXML2_SOURCE_NAME="libxml2-${LIBXML2_VERSION}.tar.xz"

# Official GNOME release archive of libxml2 2.15.4.  The digest is the one the
# upstream project publishes next to the archive
# (download.gnome.org/sources/libxml2/2.15/libxml2-2.15.4.sha256sum) and was
# re-computed from the downloaded archive before this file was written.
LIBXML2_SOURCE_SHA256="98087fd181d9070724f3fbc65c7377db03038eb92bd882374daff44940138821"
LIBXML2_SOURCE_URL="https://download.gnome.org/sources/libxml2/${LIBXML2_SERIES}/${LIBXML2_SOURCE_NAME}"

# Byte-identical mirrors, in fallback order.  download.gnome.org is the only
# canonical host but it intermittently resets TLS connections from some
# networks, so the case also tries an official GNOME mirror (Nanjing
# University) and ftp.gnome.org.  Every candidate must produce exactly the
# pinned SHA-256; a mirror that serves different bytes is rejected.
LIBXML2_SOURCE_URLS=(
    "${LIBXML2_SOURCE_URL}"
    "https://mirrors.nju.edu.cn/gnome/sources/libxml2/${LIBXML2_SERIES}/${LIBXML2_SOURCE_NAME}"
    "https://ftp.gnome.org/sources/libxml2/${LIBXML2_SERIES}/${LIBXML2_SOURCE_NAME}"
)

# Pre-placed offline assets are preferred (the dedicated aarch64 Runner cannot
# reach the public internet reliably).  The directory is read-only for the case.
LIBXML2_OFFLINE_DIR="${PERF_LIBXML2_OFFLINE_DIR:-/home/runner/software/libxml2}"

# Fixed build/runtime parameters.  -j4 keeps the local and Runner builds within
# the shared-machine budget; the value is recorded so both architectures submit
# the same amount of work.
LIBXML2_JOBS="${PERF_LIBXML2_JOBS:-4}"
LIBXML2_REPS="${PERF_REPS:-5}"

# Deterministic corpora generated in the build stage.  Sizes are measured after
# generation and stored in manifest.json; the parser reads the manifest so the
# throughput metrics are derived from the exact bytes that were parsed.
LIBXML2_CORPORA=(wide huge repeat deep namespaced dtd)
LIBXML2_REPEAT_ITERATIONS=100

# Scenario table.  Every scenario is one measured child process; the raw
# stdout/stderr and the timing JSON stay under runs/<scenario>/.
LIBXML2_SCENARIOS=(
    xmllint_parse_wide
    xmllint_parse_huge
    xmllint_parse_deep
    xmllint_parse_namespaced
    xmllint_dtd_validate
    xmllint_sax_namespaced
    xmllint_repeat_wide
    xmllint_xpath_wide
    upstream_runtest
    upstream_runsuite
)

LIBXML2_XMLLINT_SCENARIOS=(
    xmllint_parse_wide
    xmllint_parse_huge
    xmllint_parse_deep
    xmllint_parse_namespaced
    xmllint_dtd_validate
    xmllint_sax_namespaced
    xmllint_repeat_wide
    xmllint_xpath_wide
)

# Pinned totals of the upstream drivers.  The upstream source release is
# pinned, so these counts are part of the measurement contract: the parser
# rejects a repetition whose summary line does not match.
LIBXML2_RUNTEST_TOTAL=3886
LIBXML2_RUNSUITE_TOTAL=1471
LIBXML2_XPATH_ITEM_TOTAL=100000

LIBXML2_SOURCE_ARCHIVE=""
LIBXML2_SRC_DIR=""
LIBXML2_PREFIX=""
LIBXML2_XMLLINT=""
LIBXML2_RUNTEST=""
LIBXML2_RUNSUITE=""
LIBXML2_CORPUS_DIR=""
LIBXML2_CORPUS_MANIFEST=""
PROJECTS_DIR=""
RUNS_DIR=""
LIBXML2_VERSION_STRING=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[libxml2] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
}

# Print the tail of a failed measurement's log to stdout so the CI log carries
# the real parser/build error instead of only "exit code N".
report_failure_tail() {
    local log_file="$1" scenario="$2" label="$3" exit_code="$4"
    log_message "ERROR: ${scenario} (${label}) failed with exit code ${exit_code}"
    if [[ -s "${log_file}" ]]; then
        log_message "----- begin tail of ${log_file} (last 60 lines) -----"
        tail -n 60 -- "${log_file}" | while IFS= read -r line; do
            printf '[libxml2]   %s\n' "${line}"
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
    [[ "${LIBXML2_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${LIBXML2_REPS}"
        return 10
    }
    if (( LIBXML2_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${LIBXML2_REPS} is a local link-validation value; formal evidence requires >= 5"
    fi
}

validate_jobs() {
    [[ "${LIBXML2_JOBS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_LIBXML2_JOBS must be a positive integer, got ${LIBXML2_JOBS}"
        return 10
    }
    if (( LIBXML2_JOBS > 64 )); then
        log_message "ERROR: PERF_LIBXML2_JOBS is unreasonably large: ${LIBXML2_JOBS}"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/libxml2/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    LIBXML2_SOURCE_ARCHIVE="${PERF_WORK_DIR}/downloads/${LIBXML2_SOURCE_NAME}"
    LIBXML2_SRC_DIR="${PERF_WORK_DIR}/libxml2-source"
    LIBXML2_PREFIX="${PERF_WORK_DIR}/libxml2-install"
    LIBXML2_XMLLINT="${LIBXML2_SRC_DIR}/xmllint"
    LIBXML2_RUNTEST="${LIBXML2_SRC_DIR}/runtest"
    LIBXML2_RUNSUITE="${LIBXML2_SRC_DIR}/runsuite"
    LIBXML2_CORPUS_DIR="${PERF_WORK_DIR}/corpora"
    LIBXML2_CORPUS_MANIFEST="${LIBXML2_CORPUS_DIR}/manifest.json"
    PROJECTS_DIR="${PERF_WORK_DIR}/projects"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export SOFTWARE_NAME SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID
    export RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export LIBXML2_VERSION LIBXML2_SRC_DIR LIBXML2_PREFIX LIBXML2_XMLLINT
    export LIBXML2_RUNTEST LIBXML2_RUNSUITE LIBXML2_CORPUS_DIR LIBXML2_CORPUS_MANIFEST
    export LIBXML2_SOURCE_ARCHIVE PROJECTS_DIR RUNS_DIR LIBXML2_REPS LIBXML2_JOBS
    export LIBXML2_SOURCE_NAME LIBXML2_SOURCE_SHA256 LIBXML2_SOURCE_URL
    export LIBXML2_OFFLINE_DIR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

compiler_identity() {
    local compiler
    if ! compiler="$(libxml2_container_exec sh -c 'cc --version 2>&1 | head -n 1')"; then
        compiler="unknown"
    fi
    printf '%s\n' "${compiler:-unknown}"
}

# xmllint --version prints "using libxml version 21504": the numeric encoding is
# major*10000 + minor*100 + patch.  Decode it back into the dotted form.
decode_libxml2_version() {
    local encoded="$1"
    if [[ ! "${encoded}" =~ ^[0-9]+$ ]]; then
        return 1
    fi
    printf '%d.%d.%d\n' $(( encoded / 10000 )) $(( (encoded / 100) % 100 )) $(( encoded % 100 ))
}

libxml2_version_string() {
    libxml2_container_exec "${LIBXML2_XMLLINT}" --version 2>&1 | head -n 1
}

scenario_task() {
    case "$1" in
        xmllint_parse_wide|xmllint_parse_huge|xmllint_parse_deep|xmllint_parse_namespaced) printf 'parse\n' ;;
        xmllint_dtd_validate) printf 'dtd_validate\n' ;;
        xmllint_sax_namespaced) printf 'sax\n' ;;
        xmllint_repeat_wide) printf 'repeat\n' ;;
        xmllint_xpath_wide) printf 'xpath\n' ;;
        upstream_runtest|upstream_runsuite) printf 'upstream_suite\n' ;;
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
LIBXML2_IMAGE_ARCHIVE_DIR="${LIBXML2_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
LIBXML2_CA_ANCHORS_DIR="${LIBXML2_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
LIBXML2_CONTAINER_IMAGE="${LIBXML2_CONTAINER_IMAGE:-}"
LIBXML2_CONTAINER_NAME="${LIBXML2_CONTAINER_NAME:-}"
LIBXML2_CONTAINER_HOME="${LIBXML2_CONTAINER_HOME:-}"
declare -p LIBXML2_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || LIBXML2_CONTAINER_EXTRA_ARGS=()

libxml2_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

libxml2_configure_container() {
    local arch
    arch="$(libxml2_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${LIBXML2_CONTAINER_NAME}" ] || LIBXML2_CONTAINER_NAME="boostkit-libxml2-${arch}-${PERF_RUN_ID}"
    [ -n "${LIBXML2_CONTAINER_HOME}" ] || LIBXML2_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export LIBXML2_CONTAINER_NAME LIBXML2_CONTAINER_HOME
}

libxml2_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_libxml2_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_libxml2_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${LIBXML2_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_libxml2_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(libxml2_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${LIBXML2_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${LIBXML2_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        libxml2_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        libxml2_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    LIBXML2_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${LIBXML2_CONTAINER_IMAGE}" ] || ! docker image inspect "${LIBXML2_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${LIBXML2_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_libxml2_container_image_release || return $?
    export LIBXML2_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${LIBXML2_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_libxml2_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-libxml2-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${LIBXML2_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.libxml2.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_libxml2_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    libxml2_configure_container
    require_libxml2_docker || return $?
    if docker container inspect "${LIBXML2_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${LIBXML2_CONTAINER_NAME}"
        return 40
    fi
    sweep_libxml2_stale_containers || true
    prepare_libxml2_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${LIBXML2_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${LIBXML2_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${LIBXML2_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${LIBXML2_CONTAINER_HOME}" || return 40
    log_message "starting private container ${LIBXML2_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${LIBXML2_CONTAINER_NAME}" \
        --label "boostkit.libxml2.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${LIBXML2_CONTAINER_EXTRA_ARGS[@]}" \
        "${LIBXML2_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${LIBXML2_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${LIBXML2_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${LIBXML2_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${LIBXML2_CONTAINER_NAME}"
}

check_libxml2_container() {
    libxml2_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${LIBXML2_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${LIBXML2_CONTAINER_NAME}"
        return 40
    }
}

libxml2_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    libxml2_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${LIBXML2_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${LIBXML2_CONTAINER_NAME}" "$@"
}

libxml2_container_exec() { libxml2_docker_exec '' '' "$@"; }

libxml2_container_exec_at() {
    local workdir="$1"
    shift
    libxml2_docker_exec "${workdir}" '' "$@"
}

libxml2_container_exec_root() { libxml2_docker_exec '' root "$@"; }

libxml2_container_exec_root_at() {
    local workdir="$1"
    shift
    libxml2_docker_exec "${workdir}" root "$@"
}

remove_libxml2_container() {
    libxml2_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${LIBXML2_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.libxml2.run-id"}}' "${LIBXML2_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${LIBXML2_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${LIBXML2_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${LIBXML2_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${LIBXML2_CONTAINER_NAME}"
}
# >>> container-runtime:end
