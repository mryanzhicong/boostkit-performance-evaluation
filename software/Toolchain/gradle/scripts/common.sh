#!/usr/bin/env bash
set -euo pipefail

# Re-sourcing this file must not reset values that configure_runtime_paths already
# computed (dispatch.sh, base.sh and the stage scripts each source it).
if [[ -n "${GRADLE_COMMON_SOURCED:-}" ]]; then
    return 0
fi
GRADLE_COMMON_SOURCED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SOFTWARE_NAME="gradle"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-9.8.2}"
CATEGORY="Toolchain"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

GRADLE_VERSION="${SOFTWARE_VERSION}"
GRADLE_ZIP_NAME="gradle-${GRADLE_VERSION}-bin.zip"
# Official Gradle distribution digest (the checksum published next to the
# distribution on services.gradle.org and mirrored by the download mirrors).
GRADLE_ZIP_SHA256="21bd5da2de49b642904077f38c0efdc7778e92b3ed0889392dca61b97e389607"
GRADLE_ZIP_URL_PRIMARY="https://repo.huaweicloud.com/gradle/${GRADLE_ZIP_NAME}"
GRADLE_ZIP_URL_SECONDARY="https://mirrors.cloud.tencent.com/gradle/${GRADLE_ZIP_NAME}"
GRADLE_ZIP_URL_OFFICIAL="https://services.gradle.org/distributions/${GRADLE_ZIP_NAME}"

# Pinned Gradle source release, used as the upstream multi-module engineering load.
GRADLE_SRC_NAME="gradle-${GRADLE_VERSION}-source.tar.gz"
GRADLE_SRC_SHA256="54b41c997ff95f61e74ed257e02012ebbc855b3c4c2637837e744a82595f6d8a"
GRADLE_SRC_URL="https://codeload.github.com/gradle/gradle/tar.gz/refs/tags/v${GRADLE_VERSION}"
GRADLE_SRC_URL_FALLBACK="https://gh-proxy.com/${GRADLE_SRC_URL}"

# Upstream sample projects from the pinned source release.  They are part of
# Gradle's own documentation/integration sample suite, contain real Java sources
# and multi-module layouts (library + annotation processor + consumer), require
# no external Maven dependency, and build without network access once the shared
# Gradle user home has been warmed.
GRADLE_UPSTREAM_SCENARIO="upstream_multiproject_build"
GRADLE_UPSTREAM_SAMPLES=(
    "platforms/documentation/docs/src/snippets/integration-tests/java/incrementalAnnotationProcessing/groovy"
    "platforms/documentation/docs/src/snippets/reference/platforms/jvm/incrementalAnnotationProcessing/groovy"
)
# Child processes (the upstream batch runner, the result parser) cannot read a bash
# array, so the same fixed list is also exposed as a newline separated scalar.
GRADLE_UPSTREAM_SAMPLE_LIST="$(printf '%s\n' "${GRADLE_UPSTREAM_SAMPLES[@]}")"

# The Java toolchain comes from the pinned openEuler 24.03 LTS SP4 container
# image: the case installs java-21-openjdk-headless/-devel with dnf inside this
# run's private container, so no JDK archive is downloaded or verified on the
# host.  The JDK major version stays a fixed workload parameter; the exact
# package build is reported as runtime context only.
JDK_MAJOR="21"
JDK_PACKAGES=("java-21-openjdk-headless" "java-21-openjdk-devel")
JDK_HOME_DEFAULT="/usr/lib/jvm/java-21-openjdk"

GRADLE_SCALES=(100 1000 10000)
GRADLE_MATRIX_TASKS=(clean_build incremental_build noop_build)
GRADLE_REPS="${PERF_REPS:-5}"
GRADLE_OFFLINE_DIR="${PERF_GRADLE_OFFLINE_DIR:-/home/runner/software/gradle}"

GRADLE_HOME=""
GRADLE_BIN=""
GRADLE_SRC_DIR=""
GRADLE_USER_HOME_DIR=""
PROJECTS_DIR=""
RUNS_DIR=""
JDK_HOME="${JDK_HOME_DEFAULT}"
JDK_HOME_FILE=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"

log_message() {
    printf '[gradle] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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

validate_architecture() {
    local normalized
    normalized="$(normalize_architecture "${EXPECTED_ARCH}")" || return 20
    case "${normalized}" in
        x86_64|aarch64) ;;
        *)
            log_message "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
}

validate_reps() {
    [[ "${GRADLE_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${GRADLE_REPS}"
        return 10
    }
    if (( GRADLE_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${GRADLE_REPS} is a local link-validation value; formal evidence requires >= 5"
    fi
}

configure_runtime_paths() {
    validate_variant || return $?
    validate_reps || return $?
    EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
    EXPECTED_ARCH="$(normalize_architecture "${EXPECTED_ARCH}")" || {
        log_message "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
        return 20
    }
    local runner_architecture
    runner_architecture="$(normalize_architecture "$(uname -m)")" || {
        log_message "ERROR: unsupported runner architecture: $(uname -m)"
        return 20
    }
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log_message "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    if [[ -z "${PERF_RUN_ID:-}" ]]; then
        PERF_RUN_ID="$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    if [[ -z "${RESULTS_DIR:-}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${PERF_WORK_DIR:-}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/gradle/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    TMPDIR="${TMPDIR:-${PERF_WORK_DIR}/tmp}"
    JDK_HOME_FILE="${PERF_WORK_DIR}/container-jdk-home.txt"
    if [[ -s "${JDK_HOME_FILE}" ]]; then
        JDK_HOME="$(head -n 1 "${JDK_HOME_FILE}")"
    fi
    GRADLE_HOME="${PERF_WORK_DIR}/gradle-install"
    GRADLE_BIN="${GRADLE_HOME}/bin/gradle"
    GRADLE_SRC_DIR="${PERF_WORK_DIR}/gradle-source"
    GRADLE_USER_HOME_DIR="${PERF_WORK_DIR}/gradle-home"
    PROJECTS_DIR="${PERF_WORK_DIR}/projects"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export GRADLE_USER_HOME="${GRADLE_USER_HOME_DIR}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR GRADLE_REPS GRADLE_OFFLINE_DIR
    export JDK_HOME JDK_HOME_FILE GRADLE_HOME GRADLE_BIN GRADLE_SRC_DIR GRADLE_USER_HOME_DIR
    export PROJECTS_DIR RUNS_DIR
    export GRADLE_SCALES GRADLE_MATRIX_TASKS GRADLE_UPSTREAM_SCENARIO GRADLE_UPSTREAM_SAMPLE_LIST
    export GRADLE_SRC_NAME GRADLE_SRC_SHA256 GRADLE_ZIP_NAME GRADLE_ZIP_SHA256
}

initialize_runtime() {
    if [[ -z "${GRADLE_BIN:-}" || -z "${RUNS_DIR:-}" ]]; then
        configure_runtime_paths || return $?
    fi
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${GRADLE_USER_HOME_DIR}"
}

gradle_flags() {
    # --no-daemon: every measured invocation pays the full JVM start-up of a
    # single-use daemon, exactly like the delivery manual prescribes, so daemon
    # reuse can never mask build differences between architectures.
    printf '%s\n' --no-daemon --max-workers=1 --console=plain --no-build-cache --warning-mode=none
}

# Container-side JAVA_HOME / GRADLE_HOME / GRADLE_USER_HOME.  Every Java and
# Gradle command runs through one of these wrappers, so the measured process tree
# always uses the container JDK and the shared Gradle user home that lives under
# PERF_WORK_DIR (never the operator's ~/.gradle).
GRADLE_CONTAINER_PATH_PREFIX="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
declare -ga GRADLE_ENV_ARGS=()

gradle_refresh_env_args() {
    GRADLE_ENV_ARGS=(
        "JAVA_HOME=${JDK_HOME}"
        "GRADLE_HOME=${GRADLE_HOME}"
        "GRADLE_BIN=${GRADLE_BIN}"
        "GRADLE_USER_HOME=${GRADLE_USER_HOME_DIR}"
        "PATH=${JDK_HOME}/bin:${GRADLE_HOME}/bin:${GRADLE_CONTAINER_PATH_PREFIX}"
    )
}

gradle_container_env_exec() {
    gradle_refresh_env_args
    gradle_container_exec env "${GRADLE_ENV_ARGS[@]}" "$@"
}

gradle_container_env_exec_at() {
    local workdir="$1"
    shift
    gradle_refresh_env_args
    gradle_container_exec_at "${workdir}" env "${GRADLE_ENV_ARGS[@]}" "$@"
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

gradle_version_string() {
    # Read the complete banner first: letting awk/head close the pipe early makes
    # the container JVM die from SIGPIPE, which pipefail then reports as failure.
    local banner
    banner="$(gradle_container_env_exec "${GRADLE_BIN}" --version 2>/dev/null)" || return 1
    printf '%s\n' "${banner}" | awk '/^Gradle /{print $2; exit}'
}

java_version_string() {
    local banner
    banner="$(gradle_container_env_exec java -version 2>&1)" || return 1
    printf '%s\n' "${banner}" | sed -n '1{s/^openjdk version "//;s/".*$//;p}'
}

# Run the pinned upstream sample batch inside the container.  The batch runner
# needs the Gradle user home, the pinned flags and the sample list, so they are
# injected explicitly; offline_flag=0 warms the dependency cache, 1 measures.
gradle_container_batch_exec() {
    local workdir="$1" offline_flag="$2"
    shift 2
    gradle_refresh_env_args
    gradle_container_exec_at "${workdir}" env "${GRADLE_ENV_ARGS[@]}" \
        "UPSTREAM_WORK_DIR=${workdir}" \
        "GRADLE_BATCH_OFFLINE=${offline_flag}" \
        "GRADLE_FLAGS=${GRADLE_FLAGS:-}" \
        "GRADLE_UPSTREAM_SAMPLE_LIST=${GRADLE_UPSTREAM_SAMPLE_LIST}" \
        bash "${SCRIPT_DIR}/scripts/run_upstream_batch.sh" "$@"
}

gradle_source_revision_string() {
    # The source archive is a GitHub tag archive: the tag itself is the revision.
    printf '%s\n' "v${GRADLE_VERSION}"
}

scenario_list() {
    local scale task
    for scale in "${GRADLE_SCALES[@]}"; do
        for task in "${GRADLE_MATRIX_TASKS[@]}"; do
            printf '%s_%s\n' "${task}" "${scale}"
        done
    done
    printf '%s\n' "${GRADLE_UPSTREAM_SCENARIO}"
}

scenario_scale() {
    local scenario="$1"
    if [[ "${scenario}" == "${GRADLE_UPSTREAM_SCENARIO}" ]]; then
        printf 'upstream\n'
        return 0
    fi
    printf '%s\n' "${scenario##*_}"
}

record_actual_version() {
    local version java_version
    version="$(gradle_version_string)" || version=""
    if [[ "${version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: requested Gradle ${SOFTWARE_VERSION} but installed: ${version:-<unknown>}"
        return 30
    fi
    java_version="$(java_version_string)" || java_version=""
    if [[ "${java_version}" != "${JDK_MAJOR}."* ]]; then
        log_message "ERROR: expected container JDK ${JDK_MAJOR}.x, got: ${java_version:-<unknown>}"
        return 30
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "recorded actual Gradle version: ${version} (container JDK ${java_version})"
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
GRADLE_IMAGE_ARCHIVE_DIR="${GRADLE_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
GRADLE_CA_ANCHORS_DIR="${GRADLE_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
GRADLE_CONTAINER_IMAGE="${GRADLE_CONTAINER_IMAGE:-}"
GRADLE_CONTAINER_NAME="${GRADLE_CONTAINER_NAME:-}"
GRADLE_CONTAINER_HOME="${GRADLE_CONTAINER_HOME:-}"
declare -p GRADLE_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || GRADLE_CONTAINER_EXTRA_ARGS=()

gradle_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

gradle_configure_container() {
    local arch
    arch="$(gradle_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${GRADLE_CONTAINER_NAME}" ] || GRADLE_CONTAINER_NAME="boostkit-gradle-${arch}-${PERF_RUN_ID}"
    [ -n "${GRADLE_CONTAINER_HOME}" ] || GRADLE_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export GRADLE_CONTAINER_NAME GRADLE_CONTAINER_HOME
}

gradle_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_gradle_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_gradle_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${GRADLE_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_gradle_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(gradle_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${GRADLE_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${GRADLE_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        gradle_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        gradle_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    GRADLE_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${GRADLE_CONTAINER_IMAGE}" ] || ! docker image inspect "${GRADLE_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${GRADLE_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_gradle_container_image_release || return $?
    export GRADLE_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${GRADLE_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_gradle_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-gradle-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${GRADLE_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.gradle.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_gradle_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    gradle_configure_container
    require_gradle_docker || return $?
    if docker container inspect "${GRADLE_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${GRADLE_CONTAINER_NAME}"
        return 40
    fi
    sweep_gradle_stale_containers || true
    prepare_gradle_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${GRADLE_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${GRADLE_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${GRADLE_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${GRADLE_CONTAINER_HOME}" || return 40
    log_message "starting private container ${GRADLE_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${GRADLE_CONTAINER_NAME}" \
        --label "boostkit.gradle.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${GRADLE_CONTAINER_EXTRA_ARGS[@]}" \
        "${GRADLE_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${GRADLE_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${GRADLE_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${GRADLE_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${GRADLE_CONTAINER_NAME}"
}

check_gradle_container() {
    gradle_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${GRADLE_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${GRADLE_CONTAINER_NAME}"
        return 40
    }
}

gradle_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    gradle_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${GRADLE_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${GRADLE_CONTAINER_NAME}" "$@"
}

gradle_container_exec() { gradle_docker_exec '' '' "$@"; }

gradle_container_exec_at() {
    local workdir="$1"
    shift
    gradle_docker_exec "${workdir}" '' "$@"
}

gradle_container_exec_root() { gradle_docker_exec '' root "$@"; }

gradle_container_exec_root_at() {
    local workdir="$1"
    shift
    gradle_docker_exec "${workdir}" root "$@"
}

remove_gradle_container() {
    gradle_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${GRADLE_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.gradle.run-id"}}' "${GRADLE_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${GRADLE_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${GRADLE_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${GRADLE_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${GRADLE_CONTAINER_NAME}"
}
# >>> container-runtime:end
