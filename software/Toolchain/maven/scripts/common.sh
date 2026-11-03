#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-3.10.0}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

MAVEN_VERSION="${SOFTWARE_VERSION}"
MAVEN_DIST_BASE="https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}"
MAVEN_BIN_NAME="apache-maven-${MAVEN_VERSION}-bin.tar.gz"
MAVEN_SRC_NAME="apache-maven-${MAVEN_VERSION}-src.tar.gz"
MAVEN_BIN_URL="${MAVEN_DIST_BASE}/binaries/${MAVEN_BIN_NAME}"
MAVEN_SRC_URL="${MAVEN_DIST_BASE}/source/${MAVEN_SRC_NAME}"
MAVEN_BIN_SHA512="908b1501bfb420bf7c8affb855534a9c407fd6099367bfb9f2f2dcb8e9799102bffb84518cde74c679bd76870247c6528683abdd620581bffa90f95d92d175aa"
MAVEN_SRC_SHA512="5b95db2740e5e11c29ce372541c4e00829ad58ca490749c9810aacb9ea1855166d85734cbf6ed4c178001eddba3719ed912807dfe1aa8f9036f09d862aa1d05c"
MAVEN_OFFLINE_DIR="${MAVEN_OFFLINE_DIR:-/home/runner/software/maven}"

# The Java toolchain comes from the pinned openEuler 24.03 LTS SP4 container
# image: the case installs java-21-openjdk-headless/-devel with dnf inside this
# run's private container, so no JDK archive is downloaded or verified on the
# host.  The JDK major version stays a fixed workload parameter; the exact
# package build is reported as runtime context only.
JDK_MAJOR="21"
JDK_PACKAGES=("java-21-openjdk-headless" "java-21-openjdk-devel")
JDK_HOME_DEFAULT="/usr/lib/jvm/java-21-openjdk"

MAVEN_MIRROR_BASE_URLS=(
    "https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/${MAVEN_VERSION}"
    "https://mirrors.huaweicloud.com/apache/maven/maven-3/${MAVEN_VERSION}"
)
# Last-resort repository mirror for the timed warm-up phase only.  Some
# dedicated runners cannot reach repo.maven.apache.org; the warm-up is untimed
# and the measured scenarios run with -o (offline), so falling back to a public
# Central mirror cannot change the measured artifact set.  Set
# PERF_MAVEN_MIRROR_URL to override ("" disables the fallback).
MAVEN_FALLBACK_MIRROR_URL="${PERF_MAVEN_MIRROR_URL-https://maven.aliyun.com/repository/central}"

MAVEN_SCALES=(100 1000 10000)
MAVEN_TASKS=(clean_package incremental_package noop_package)
MAVEN_EXTRA_SCENARIOS=(maven_self_build)
MAVEN_REPS="${PERF_REPS:-5}"
# Optional settings.xml override, used by offline/intranet environments that
# cannot reach Maven Central directly.  Unset by default: CI runs against the
# repositories declared by Maven's own POM without any mirror.
PERF_MAVEN_SETTINGS="${PERF_MAVEN_SETTINGS:-}"
declare -ga MAVEN_SETTINGS_ARGV=()
MAVEN_FALLBACK_SETTINGS="${MAVEN_FALLBACK_SETTINGS:-}"

JDK_HOME="${JDK_HOME_DEFAULT}"
JDK_HOME_FILE=""
MAVEN_SRC_DIR=""
MAVEN_HOME=""
MAVEN_BIN=""
M2_REPO=""
PROJECTS_DIR=""
RUNS_DIR=""
declare -ga MAVEN_BIN_URLS=()
declare -ga MAVEN_SRC_URLS=()
MAVEN_VERSION_STRING=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[maven] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    [[ "${MAVEN_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${MAVEN_REPS}"
        return 10
    }
    if (( MAVEN_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${MAVEN_REPS} is a local link-validation value; formal evidence requires >= 5"
    fi
}

select_maven_artifacts() {
    MAVEN_BIN_URLS=("${MAVEN_BIN_URL}")
    MAVEN_SRC_URLS=("${MAVEN_SRC_URL}")
    local mirror_base
    for mirror_base in "${MAVEN_MIRROR_BASE_URLS[@]}"; do
        MAVEN_BIN_URLS+=("${mirror_base}/binaries/${MAVEN_BIN_NAME}")
        MAVEN_SRC_URLS+=("${mirror_base}/source/${MAVEN_SRC_NAME}")
    done
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/maven/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    select_maven_artifacts || return $?
    MAVEN_SETTINGS_ARGV=()
    if [[ -n "${PERF_MAVEN_SETTINGS}" ]]; then
        if [[ ! -f "${PERF_MAVEN_SETTINGS}" ]]; then
            log_message "ERROR: PERF_MAVEN_SETTINGS does not point to a file: ${PERF_MAVEN_SETTINGS}"
            return 10
        fi
        MAVEN_SETTINGS_ARGV=(-s "${PERF_MAVEN_SETTINGS}")
        log_message "using explicit Maven settings file: ${PERF_MAVEN_SETTINGS}"
    fi
    JDK_HOME_FILE="${PERF_WORK_DIR}/container-jdk-home.txt"
    if [[ -s "${JDK_HOME_FILE}" ]]; then
        JDK_HOME="$(head -n 1 "${JDK_HOME_FILE}")"
    fi
    MAVEN_SRC_DIR="${PERF_WORK_DIR}/maven-src"
    MAVEN_HOME="${PERF_WORK_DIR}/maven-install"
    MAVEN_BIN="${MAVEN_HOME}/bin/mvn"
    M2_REPO="${PERF_WORK_DIR}/m2repo"
    PROJECTS_DIR="${PERF_WORK_DIR}/projects"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR MAVEN_REPS
    export JDK_HOME JDK_HOME_FILE MAVEN_SRC_DIR MAVEN_HOME MAVEN_BIN M2_REPO PROJECTS_DIR RUNS_DIR
    export MAVEN_FALLBACK_MIRROR_URL
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

# Container-side JAVA_HOME / Maven home.  Every java/mvn command runs through
# one of the wrappers below, so the measured process tree always uses the
# container JDK and the private repository that lives under PERF_WORK_DIR (never
# the operator's ~/.m2).
MAVEN_CONTAINER_PATH_PREFIX="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
declare -ga MAVEN_ENV_ARGS=()

maven_refresh_env_args() {
    MAVEN_ENV_ARGS=(
        "JAVA_HOME=${JDK_HOME}"
        "MAVEN_HOME=${MAVEN_HOME}"
        "PATH=${JDK_HOME}/bin:${MAVEN_HOME}/bin:${MAVEN_CONTAINER_PATH_PREFIX}"
        "MAVEN_OPTS="
    )
}

maven_container_env_exec() {
    maven_refresh_env_args
    maven_container_exec env "${MAVEN_ENV_ARGS[@]}" "$@"
}

maven_container_env_exec_at() {
    local workdir="$1"
    shift
    maven_refresh_env_args
    maven_container_exec_at "${workdir}" env "${MAVEN_ENV_ARGS[@]}" "$@"
}

load_container_jdk() {
    if [[ -s "${JDK_HOME_FILE}" ]]; then
        JDK_HOME="$(head -n 1 "${JDK_HOME_FILE}")"
    fi
    export JDK_HOME
}

record_container_jdk_home() {
    [[ -n "${JDK_HOME}" ]] || {
        log_message "ERROR: cannot record an empty container JDK home"
        return 30
    }
    mkdir -p "$(dirname "${JDK_HOME_FILE}")"
    printf '%s\n' "${JDK_HOME}" > "${JDK_HOME_FILE}"
    log_message "container JDK home: ${JDK_HOME}"
}

export_java_env() {
    # Kept for the stage scripts: the JDK and Maven homes are injected per command
    # by maven_container_env_exec, there is no host-side JAVA_HOME/PATH to set.
    export JAVA_HOME="${JDK_HOME}"
    export MAVEN_OPTS=""
}

maven_command() {
    printf '%s\n' "${MAVEN_BIN}" -B -o -ntp \
        "-Dmaven.repo.local=${M2_REPO}" \
        -Dstyle.color=never
}

# Read the complete `mvn -v` banner before filtering: letting awk/head close the
# pipe early makes the container JVM die from SIGPIPE, which pipefail would then
# report as a failed (and silently empty) version probe.
maven_version_output() {
    maven_container_env_exec "${MAVEN_BIN}" -v 2>&1
}

maven_version_string() {
    local banner
    banner="$(maven_version_output)" || return 1
    printf '%s\n' "${banner}" | awk '/^Apache Maven/ {print $3; exit}'
}

java_version_string() {
    local banner
    banner="$(maven_container_env_exec java -version 2>&1)" || return 1
    printf '%s\n' "${banner}" | sed -n '1{s/^openjdk version "//;s/".*$//;p}'
}

scenario_list() {
    local scale task
    for scale in "${MAVEN_SCALES[@]}"; do
        for task in "${MAVEN_TASKS[@]}"; do
            printf '%s_%s\n' "${task}" "${scale}"
        done
    done
    printf '%s\n' "${MAVEN_EXTRA_SCENARIOS[@]}"
}

scenario_scale() {
    local scenario="$1"
    if [[ "${scenario}" == "maven_self_build" ]]; then
        printf 'upstream\n'
        return 0
    fi
    printf '%s\n' "${scenario##*_}"
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
MAVEN_IMAGE_ARCHIVE_DIR="${MAVEN_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
MAVEN_CA_ANCHORS_DIR="${MAVEN_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
MAVEN_CONTAINER_IMAGE="${MAVEN_CONTAINER_IMAGE:-}"
MAVEN_CONTAINER_NAME="${MAVEN_CONTAINER_NAME:-}"
MAVEN_CONTAINER_HOME="${MAVEN_CONTAINER_HOME:-}"
declare -p MAVEN_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || MAVEN_CONTAINER_EXTRA_ARGS=()

maven_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

maven_configure_container() {
    local arch
    arch="$(maven_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${MAVEN_CONTAINER_NAME}" ] || MAVEN_CONTAINER_NAME="boostkit-maven-${arch}-${PERF_RUN_ID}"
    [ -n "${MAVEN_CONTAINER_HOME}" ] || MAVEN_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export MAVEN_CONTAINER_NAME MAVEN_CONTAINER_HOME
}

maven_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_maven_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_maven_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${MAVEN_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_maven_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(maven_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${MAVEN_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${MAVEN_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        maven_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        maven_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    MAVEN_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${MAVEN_CONTAINER_IMAGE}" ] || ! docker image inspect "${MAVEN_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${MAVEN_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_maven_container_image_release || return $?
    export MAVEN_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${MAVEN_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_maven_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-maven-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${MAVEN_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.maven.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_maven_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    maven_configure_container
    require_maven_docker || return $?
    if docker container inspect "${MAVEN_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${MAVEN_CONTAINER_NAME}"
        return 40
    fi
    sweep_maven_stale_containers || true
    prepare_maven_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${MAVEN_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${MAVEN_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${MAVEN_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${MAVEN_CONTAINER_HOME}" || return 40
    log_message "starting private container ${MAVEN_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${MAVEN_CONTAINER_NAME}" \
        --label "boostkit.maven.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${MAVEN_CONTAINER_EXTRA_ARGS[@]}" \
        "${MAVEN_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${MAVEN_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${MAVEN_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${MAVEN_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${MAVEN_CONTAINER_NAME}"
}

check_maven_container() {
    maven_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${MAVEN_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${MAVEN_CONTAINER_NAME}"
        return 40
    }
}

maven_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    maven_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${MAVEN_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${MAVEN_CONTAINER_NAME}" "$@"
}

maven_container_exec() { maven_docker_exec '' '' "$@"; }

maven_container_exec_at() {
    local workdir="$1"
    shift
    maven_docker_exec "${workdir}" '' "$@"
}

maven_container_exec_root() { maven_docker_exec '' root "$@"; }

maven_container_exec_root_at() {
    local workdir="$1"
    shift
    maven_docker_exec "${workdir}" root "$@"
}

remove_maven_container() {
    maven_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${MAVEN_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.maven.run-id"}}' "${MAVEN_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${MAVEN_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${MAVEN_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${MAVEN_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${MAVEN_CONTAINER_NAME}"
}
# >>> container-runtime:end
