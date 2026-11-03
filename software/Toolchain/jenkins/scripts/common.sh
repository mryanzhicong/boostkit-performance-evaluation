#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="jenkins"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-2.588}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

JENKINS_WAR_NAME="jenkins.war"
JENKINS_WAR_SHA256="e84790335e973f1c051f32cb1e64808049a31a17dbeaa98014937842710bf37a"
JENKINS_WAR_SIZE="52583800"
JENKINS_OFFICIAL_WAR_BASE="https://get.jenkins.io/war/${SOFTWARE_VERSION}"
JENKINS_OFFICIAL_WAR_URL="${JENKINS_OFFICIAL_WAR_BASE}/${JENKINS_WAR_NAME}"
# Download order: the self-hosted aarch64 Runner cannot reach github.com and
# get.jenkins.io reliably (see QA 14), so verified domestic mirrors go first and
# the official upstream is the last resort.  Every source must yield exactly the
# same pinned SHA-256, which is re-checked after each download.
JENKINS_WAR_URLS=(
    "https://mirrors.huaweicloud.com/jenkins/war/${SOFTWARE_VERSION}/${JENKINS_WAR_NAME}"
    "https://mirrors.tuna.tsinghua.edu.cn/jenkins/war/${SOFTWARE_VERSION}/${JENKINS_WAR_NAME}"
    "https://mirrors.aliyun.com/jenkins/war/${SOFTWARE_VERSION}/${JENKINS_WAR_NAME}"
    "https://gh-proxy.com/https://github.com/jenkinsci/jenkins/releases/download/jenkins-${SOFTWARE_VERSION}/${JENKINS_WAR_NAME}"
    "https://ghfast.top/https://github.com/jenkinsci/jenkins/releases/download/jenkins-${SOFTWARE_VERSION}/${JENKINS_WAR_NAME}"
    "${JENKINS_OFFICIAL_WAR_URL}"
)

# The Java toolchain comes from the pinned openEuler 24.03 LTS SP4 container
# image: the case installs java-21-openjdk-headless/-devel with dnf inside this
# run's private container, so no JDK archive is downloaded or verified on the
# host.  The JDK major version stays a fixed workload parameter; the exact
# package build is reported as runtime context only.
JDK_MAJOR="21"
JDK_PACKAGES=("java-21-openjdk-headless" "java-21-openjdk-devel")
JDK_HOME_DEFAULT="/usr/lib/jvm/java-21-openjdk"

# Network robustness knobs (seconds / bytes-per-second).  The aarch64 Runner
# blackholes github.com connections instead of resetting them, so a plain curl
# without a total timeout can hang for the whole job budget (observed in Actions
# run 41389053397: the build stage sat on an upstream download for 46 minutes).
# Every download therefore has a per-source attempt timeout, a stall detector and
# a shared budget; the build stage has its own hard budget below.
JENKINS_DOWNLOAD_ATTEMPT_SECONDS="${JENKINS_DOWNLOAD_ATTEMPT_SECONDS:-240}"
JENKINS_DOWNLOAD_BUDGET_SECONDS="${JENKINS_DOWNLOAD_BUDGET_SECONDS:-480}"
JENKINS_STALL_BYTES_PER_SECOND="${JENKINS_STALL_BYTES_PER_SECOND:-20000}"
JENKINS_STALL_SECONDS="${JENKINS_STALL_SECONDS:-30}"
JENKINS_BUILD_BUDGET_SECONDS="${JENKINS_BUILD_BUDGET_SECONDS:-600}"
JENKINS_TEMPLATE_TIMEOUT_SECONDS="${JENKINS_TEMPLATE_TIMEOUT_SECONDS:-240}"
JENKINS_VERSION_PROBE_TIMEOUT_SECONDS="${JENKINS_VERSION_PROBE_TIMEOUT_SECONDS:-120}"
JENKINS_TEST_BUDGET_SECONDS="${JENKINS_TEST_BUDGET_SECONDS:-2400}"
JENKINS_DOWNLOAD_DEADLINE=0
JENKINS_BUILD_DEADLINE=0

JENKINS_OFFLINE_DIR="${JENKINS_OFFLINE_DIR:-/home/runner/software/jenkins}"
JENKINS_HEAP_FLAGS=(-Xms512m -Xmx512m -Djava.awt.headless=true)
JENKINS_JVM_FLAGS=(
    -Djenkins.install.runSetupWizard=false
    -Dhudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION=true
    -Dhudson.model.UpdateCenter.updateCenterUrl=http://127.0.0.1:1/update-center.json
    -Djenkins.model.DownloadService.noSignatureCheck=true
    -Dhudson.model.UsageStatistics.disabled=true
)
JENKINS_DRIVER_TIMEOUT_SECONDS="${JENKINS_DRIVER_TIMEOUT_SECONDS:-300}"
JENKINS_REPS="${PERF_REPS:-5}"

JENKINS_SCENARIOS_FILE="${SCRIPT_DIR}/benchmarks/scenarios.psv"
JENKINS_DRIVER="${SCRIPT_DIR}/scripts/run_jenkins_case.py"

JENKINS_WAR=""
JENKINS_HOMES_DIR=""
JENKINS_TEMPLATE_HOME=""
JDK_HOME="${JDK_HOME_DEFAULT}"
JDK_HOME_FILE=""
JENKINS_JAVA=""
JENKINS_VERSION_STRING=""
JDK_SOURCE=""
JENKINS_PORT=""
RUNS_DIR=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[jenkins] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
}

# Print the last N lines of a log file to stdout (streamed into the Actions job
# log) so a failed build/test sample can be diagnosed without artifacts.
print_log_tail() {
    local path="$1" lines="${2:-40}"
    printf '%s\n' "---- tail of ${path} (last ${lines} lines) ----"
    if [[ -f "${path}" ]]; then
        tail -n "${lines}" -- "${path}" 2>/dev/null || true
    else
        printf '%s\n' "(log file does not exist)"
    fi
    printf '%s\n' "---- end of ${path} ----"
}

remaining_seconds() {
    local deadline="$1"
    if [[ "${deadline}" -le 0 ]]; then
        printf '0\n'
        return 0
    fi
    local remaining=$(( deadline - $(date +%s) ))
    (( remaining < 0 )) && remaining=0
    printf '%s\n' "${remaining}"
}

# Kill only the controller JVMs that belong to this run's derived port.  The port
# is a pure function of PERF_RUN_ID, so this pattern cannot match another agent's
# Jenkins process (unlike a broad `pkill -f jenkins`).
stop_stray_controllers() {
    local port="${1:-}"
    command -v pgrep >/dev/null 2>&1 || return 0
    [[ -n "${port}" ]] || return 0
    local -a pids=()
    local pid
    mapfile -t pids < <(pgrep -f "jenkins.war.*--httpPort=${port}" 2>/dev/null || true)
    (( ${#pids[@]} == 0 )) && return 0
    log_message "stopping stray controller process(es) on port ${port}: ${pids[*]}"
    for pid in "${pids[@]}"; do
        kill -TERM "${pid}" 2>/dev/null || true
    done
    sleep 2
    for pid in "${pids[@]}"; do
        kill -KILL "${pid}" 2>/dev/null || true
    done
    return 0
}

ensure_build_budget() {
    local step="$1" remaining
    remaining="$(remaining_seconds "${JENKINS_BUILD_DEADLINE}")"
    if [[ "${JENKINS_BUILD_DEADLINE}" -gt 0 && "${remaining}" -le 0 ]]; then
        log_message "ERROR: the ${JENKINS_BUILD_BUDGET_SECONDS}s build budget is exhausted before ${step}"
        return 30
    fi
    log_message "${step}: ${remaining}s of the build budget remain"
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
    [[ "${JENKINS_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${JENKINS_REPS}"
        return 10
    }
}

configure_runtime_paths() {
    validate_variant || return $?
    validate_reps || return $?
    [[ "${SOFTWARE_VERSION}" == "2.588" ]] || {
        log_message "ERROR: unsupported Jenkins version: ${SOFTWARE_VERSION}"
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
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/jenkins/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
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
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    TMPDIR="${PERF_WORK_DIR}/tmp"
    JENKINS_WAR="${PERF_WORK_DIR}/${JENKINS_WAR_NAME}"
    JENKINS_HOMES_DIR="${PERF_WORK_DIR}/homes"
    JENKINS_TEMPLATE_HOME="${PERF_WORK_DIR}/jenkins-home-template"
    JDK_HOME_FILE="${PERF_WORK_DIR}/container-jdk-home.txt"
    if [[ -s "${JDK_HOME_FILE}" ]]; then
        JDK_HOME="$(head -n 1 "${JDK_HOME_FILE}")"
    fi
    JENKINS_JAVA="${JDK_HOME}/bin/java"
    RUNS_DIR="${RESULTS_DIR}/runs"
    # The controller port is derived from the run ID so that concurrent runs on
    # one machine do not collide, while repeated repetitions reuse one port.
    JENKINS_PORT="$((18200 + $(printf '%s' "${PERF_RUN_ID}" | cksum | cut -d ' ' -f 1) % 2000))"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID PERF_WORK_DIR
    export RESULTS_DIR PERF_ACTUAL_VERSION_FILE TMPDIR JENKINS_REPS
    export JENKINS_WAR JENKINS_HOMES_DIR JENKINS_TEMPLATE_HOME JDK_HOME JDK_HOME_FILE
    export JENKINS_JAVA RUNS_DIR JENKINS_PORT
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${JENKINS_HOMES_DIR}"
}

# Container-side JAVA_HOME.  Every java invocation (the war version probe, the
# JENKINS_HOME template boot and the per-sample driver) runs through one of the
# wrappers below, so the controller JVM always uses the container JDK.
JENKINS_CONTAINER_PATH_PREFIX="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
declare -ga JENKINS_ENV_ARGS=()

jenkins_refresh_env_args() {
    JENKINS_ENV_ARGS=(
        "JAVA_HOME=${JDK_HOME}"
        "PATH=${JDK_HOME}/bin:${JENKINS_CONTAINER_PATH_PREFIX}"
    )
}

jenkins_container_env_exec() {
    jenkins_refresh_env_args
    jenkins_container_exec env "${JENKINS_ENV_ARGS[@]}" "$@"
}

jenkins_container_env_exec_at() {
    local workdir="$1"
    shift
    jenkins_refresh_env_args
    jenkins_container_exec_at "${workdir}" env "${JENKINS_ENV_ARGS[@]}" "$@"
}

load_container_jdk() {
    if [[ -s "${JDK_HOME_FILE}" ]]; then
        JDK_HOME="$(head -n 1 "${JDK_HOME_FILE}")"
    fi
    JENKINS_JAVA="${JDK_HOME}/bin/java"
    export JDK_HOME JENKINS_JAVA
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

# Read the complete banner before filtering: letting awk/head close the pipe early
# makes the container JVM die from SIGPIPE, which pipefail would then report as a
# failed (and silently empty) version probe.
java_version_string() {
    local banner
    banner="$(jenkins_container_env_exec java -version 2>&1)" || return 1
    printf '%s\n' "${banner}" | sed -n '1{s/^openjdk version "//;s/".*$//;p}'
}

export_java_env() {
    # Kept for the stage scripts: the JDK home is injected per command by
    # jenkins_container_env_exec, there is no host-side JAVA_HOME/PATH to set.
    export JAVA_HOME="${JDK_HOME}"
}

scenario_count() {
    local count=0 scenario dimension action scale check expected workload
    while IFS='|' read -r scenario dimension action scale check expected workload; do
        [[ -z "${scenario}" || "${scenario}" == \#* ]] && continue
        count=$((count + 1))
    done < "${JENKINS_SCENARIOS_FILE}"
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
JENKINS_IMAGE_ARCHIVE_DIR="${JENKINS_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
JENKINS_CA_ANCHORS_DIR="${JENKINS_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
JENKINS_CONTAINER_IMAGE="${JENKINS_CONTAINER_IMAGE:-}"
JENKINS_CONTAINER_NAME="${JENKINS_CONTAINER_NAME:-}"
JENKINS_CONTAINER_HOME="${JENKINS_CONTAINER_HOME:-}"
declare -p JENKINS_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || JENKINS_CONTAINER_EXTRA_ARGS=()

jenkins_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

jenkins_configure_container() {
    local arch
    arch="$(jenkins_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${JENKINS_CONTAINER_NAME}" ] || JENKINS_CONTAINER_NAME="boostkit-jenkins-${arch}-${PERF_RUN_ID}"
    [ -n "${JENKINS_CONTAINER_HOME}" ] || JENKINS_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export JENKINS_CONTAINER_NAME JENKINS_CONTAINER_HOME
}

jenkins_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_jenkins_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_jenkins_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${JENKINS_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_jenkins_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(jenkins_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${JENKINS_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${JENKINS_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        jenkins_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        jenkins_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    JENKINS_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${JENKINS_CONTAINER_IMAGE}" ] || ! docker image inspect "${JENKINS_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${JENKINS_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_jenkins_container_image_release || return $?
    export JENKINS_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${JENKINS_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_jenkins_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-jenkins-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${JENKINS_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.jenkins.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_jenkins_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    jenkins_configure_container
    require_jenkins_docker || return $?
    if docker container inspect "${JENKINS_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${JENKINS_CONTAINER_NAME}"
        return 40
    fi
    sweep_jenkins_stale_containers || true
    prepare_jenkins_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${JENKINS_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${JENKINS_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${JENKINS_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${JENKINS_CONTAINER_HOME}" || return 40
    log_message "starting private container ${JENKINS_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${JENKINS_CONTAINER_NAME}" \
        --label "boostkit.jenkins.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${JENKINS_CONTAINER_EXTRA_ARGS[@]}" \
        "${JENKINS_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${JENKINS_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${JENKINS_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${JENKINS_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${JENKINS_CONTAINER_NAME}"
}

check_jenkins_container() {
    jenkins_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${JENKINS_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${JENKINS_CONTAINER_NAME}"
        return 40
    }
}

jenkins_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    jenkins_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${JENKINS_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${JENKINS_CONTAINER_NAME}" "$@"
}

jenkins_container_exec() { jenkins_docker_exec '' '' "$@"; }

jenkins_container_exec_at() {
    local workdir="$1"
    shift
    jenkins_docker_exec "${workdir}" '' "$@"
}

jenkins_container_exec_root() { jenkins_docker_exec '' root "$@"; }

jenkins_container_exec_root_at() {
    local workdir="$1"
    shift
    jenkins_docker_exec "${workdir}" root "$@"
}

remove_jenkins_container() {
    jenkins_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${JENKINS_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.jenkins.run-id"}}' "${JENKINS_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${JENKINS_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${JENKINS_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${JENKINS_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${JENKINS_CONTAINER_NAME}"
}
# >>> container-runtime:end
