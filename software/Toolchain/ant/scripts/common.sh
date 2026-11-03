#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.10.18}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

ANT_VERSION="${SOFTWARE_VERSION}"
ANT_ARCHIVE_NAME="apache-ant-${ANT_VERSION}-bin.tar.gz"
ANT_ARCHIVE_SHA256="b45db2fdd76d639301550930d33dd7bc672c9d4fdea0fe8cfd2e6a3518388d59"
ANT_OFFICIAL_URL="https://archive.apache.org/dist/ant/binaries/${ANT_ARCHIVE_NAME}"
ANT_MIRROR_URLS=(
    "https://mirrors.tuna.tsinghua.edu.cn/apache/ant/binaries/${ANT_ARCHIVE_NAME}"
    "https://mirrors.huaweicloud.com/apache/ant/binaries/${ANT_ARCHIVE_NAME}"
    "https://dlcdn.apache.org/ant/binaries/${ANT_ARCHIVE_NAME}"
)
ANT_OFFLINE_DIR="${PERF_ANT_OFFLINE_DIR:-/home/runner/software/ant}"

# The Java toolchain comes from the pinned openEuler 24.03 LTS SP4 container
# image: the case installs java-21-openjdk-headless/-devel with dnf inside this
# run's private container, so no JDK archive is downloaded or verified on the
# host.  The JDK major version stays a fixed workload parameter; the exact
# package build is reported as runtime context only.
JDK_MAJOR="21"
JDK_PACKAGES=("java-21-openjdk-headless" "java-21-openjdk-devel")
JDK_HOME_DEFAULT="/usr/lib/jvm/java-21-openjdk"

# 构建矩阵：clean 全量构建 + 增量（空闲/单文件变更）对比。
ANT_JAR_SCALES=(50 100 200)
ANT_REPS="${PERF_REPS:-5}"

JDK_HOME="${JDK_HOME_DEFAULT}"
JDK_HOME_FILE=""
ANT_HOME=""
ANT_BIN=""
PROJECTS_DIR=""
RUNS_DIR=""
ANT_VERSION_STRING=""
declare -ga ANT_ARCHIVE_URLS=()
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[ant] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    [[ "${ANT_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${ANT_REPS}"
        return 10
    }
    if (( ANT_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${ANT_REPS} is a local link-validation value; formal evidence requires >= 5"
    fi
}

select_ant_artifact() {
    ANT_ARCHIVE_URLS=("${ANT_MIRROR_URLS[@]}" "${ANT_OFFICIAL_URL}")
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/ant/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    select_ant_artifact
    JDK_HOME_FILE="${PERF_WORK_DIR}/container-jdk-home.txt"
    if [[ -s "${JDK_HOME_FILE}" ]]; then
        JDK_HOME="$(head -n 1 "${JDK_HOME_FILE}")"
    fi
    ANT_HOME="${PERF_WORK_DIR}/ant-install"
    ANT_BIN="${ANT_HOME}/bin/ant"
    PROJECTS_DIR="${PERF_WORK_DIR}/projects"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR
    export PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR ANT_REPS
    export JDK_HOME JDK_HOME_FILE ANT_HOME ANT_BIN PROJECTS_DIR RUNS_DIR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

# Container-side JAVA_HOME/PATH.  Every Java command runs through one of these
# wrappers, so the measured process tree always uses the container JDK.
ANT_CONTAINER_PATH_PREFIX="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

ant_container_java_exec() {
    ant_container_exec env "JAVA_HOME=${JDK_HOME}"         "PATH=${JDK_HOME}/bin:${ANT_HOME}/bin:${ANT_CONTAINER_PATH_PREFIX}" "$@"
}

ant_container_java_exec_at() {
    local workdir="$1"
    shift
    ant_container_exec_at "${workdir}" env "JAVA_HOME=${JDK_HOME}"         "PATH=${JDK_HOME}/bin:${ANT_HOME}/bin:${ANT_CONTAINER_PATH_PREFIX}" "$@"
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

scenario_metadata_payload() {
    python3 - "$1" "${ANT_REPS}" <<'PY'
import json
import sys

output = sys.argv[1]
reps = int(sys.argv[2])
scenarios = []
for scale in (50, 100, 200):
    scenarios.append({
        "scenario": f"clean_jar_{scale}",
        "description": f"ant clean build (javac + jar) of the generated {scale}-class project",
        "workload": f"{scale} generated Java sources",
        "throughput": {"name": "classes_per_second", "items": scale, "unit": "classes/s"},
    })
scenarios.extend([
    {
        "scenario": "clean_compile_100",
        "description": "ant clean compile (javac only) of the generated 100-class project",
        "workload": "100 generated Java sources",
        "throughput": {"name": "classes_per_second", "items": 100, "unit": "classes/s"},
    },
    {
        "scenario": "incremental_noop_100",
        "description": "ant incremental jar build with no source change (idle incremental)",
        "workload": "100 unchanged Java sources",
    },
    {
        "scenario": "incremental_touch_100",
        "description": "ant incremental jar build after modifying a single source file",
        "workload": "100 Java sources, 1 modified",
    },
])
payload = {
    "reps": reps,
    "parameters": {
        "clean_jar_scales": [50, 100, 200],
        "incremental_work_scale": 100,
        "jdk_release": "openEuler 24.03 LTS SP4 java-21-openjdk",
    },
    "scenarios": scenarios,
}
with open(output, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, ensure_ascii=False, indent=2)
    handle.write("\n")
PY
}

case_tool_release_string() {
    printf 'openEuler 24.03 LTS SP4 %s\n' "${JDK_PACKAGES[*]}"
}

case_artifact_url() {
    printf '%s\n' "${ANT_OFFICIAL_URL}"
}

case_artifact_sha256() {
    printf '%s\n' "${ANT_ARCHIVE_SHA256}"
}

case_artifact_version_string() {
    printf '%s\n' "${ANT_VERSION_STRING:-Apache Ant ${SOFTWARE_VERSION}}"
}

case_build_notes() {
    printf 'apache-ant binary distribution (%s) unpacked inside the private openEuler 24.03 LTS SP4 container; JDK installed there with dnf (%s); Ant is not built from source\n' \
        "${ANT_ARCHIVE_NAME}" "${JDK_PACKAGES[*]}"
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
ANT_IMAGE_ARCHIVE_DIR="${ANT_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
ANT_CA_ANCHORS_DIR="${ANT_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
ANT_CONTAINER_IMAGE="${ANT_CONTAINER_IMAGE:-}"
ANT_CONTAINER_NAME="${ANT_CONTAINER_NAME:-}"
ANT_CONTAINER_HOME="${ANT_CONTAINER_HOME:-}"
declare -p ANT_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || ANT_CONTAINER_EXTRA_ARGS=()

ant_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

ant_configure_container() {
    local arch
    arch="$(ant_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${ANT_CONTAINER_NAME}" ] || ANT_CONTAINER_NAME="boostkit-ant-${arch}-${PERF_RUN_ID}"
    [ -n "${ANT_CONTAINER_HOME}" ] || ANT_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export ANT_CONTAINER_NAME ANT_CONTAINER_HOME
}

ant_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_ant_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_ant_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${ANT_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_ant_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(ant_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${ANT_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${ANT_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        ant_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        ant_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    ANT_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${ANT_CONTAINER_IMAGE}" ] || ! docker image inspect "${ANT_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${ANT_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_ant_container_image_release || return $?
    export ANT_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${ANT_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_ant_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-ant-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${ANT_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.ant.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_ant_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    ant_configure_container
    require_ant_docker || return $?
    if docker container inspect "${ANT_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${ANT_CONTAINER_NAME}"
        return 40
    fi
    sweep_ant_stale_containers || true
    prepare_ant_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${ANT_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${ANT_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${ANT_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${ANT_CONTAINER_HOME}" || return 40
    log_message "starting private container ${ANT_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${ANT_CONTAINER_NAME}" \
        --label "boostkit.ant.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${ANT_CONTAINER_EXTRA_ARGS[@]}" \
        "${ANT_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${ANT_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${ANT_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${ANT_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${ANT_CONTAINER_NAME}"
}

check_ant_container() {
    ant_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${ANT_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${ANT_CONTAINER_NAME}"
        return 40
    }
}

ant_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    ant_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${ANT_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${ANT_CONTAINER_NAME}" "$@"
}

ant_container_exec() { ant_docker_exec '' '' "$@"; }

ant_container_exec_at() {
    local workdir="$1"
    shift
    ant_docker_exec "${workdir}" '' "$@"
}

ant_container_exec_root() { ant_docker_exec '' root "$@"; }

ant_container_exec_root_at() {
    local workdir="$1"
    shift
    ant_docker_exec "${workdir}" root "$@"
}

remove_ant_container() {
    ant_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${ANT_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.ant.run-id"}}' "${ANT_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${ANT_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${ANT_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${ANT_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${ANT_CONTAINER_NAME}"
}
# >>> container-runtime:end
