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

SCALA_VERSION="${SOFTWARE_VERSION}"
SCALA_ARCHIVE_NAME="scala3-${SCALA_VERSION}.zip"
SCALA_ARCHIVE_SHA256="e3d60a2fdc52c45ee1efe7a0e595b98beadba7cfa37a17806625ce2c07708586"
SCALA_OFFICIAL_URL="https://github.com/scala/scala3/releases/download/${SCALA_VERSION}/${SCALA_ARCHIVE_NAME}"
# The dedicated aarch64 runner cannot reliably reach github.com release assets;
# the same pinned archive is fetched through public GitHub mirrors and verified
# against the identical SHA-256, so the download path never changes the payload.
SCALA_MIRROR_URLS=(
    "https://ghfast.top/https://github.com/scala/scala3/releases/download/${SCALA_VERSION}/${SCALA_ARCHIVE_NAME}"
    "https://gh-proxy.com/https://github.com/scala/scala3/releases/download/${SCALA_VERSION}/${SCALA_ARCHIVE_NAME}"
)
SCALA_OFFLINE_DIR="${PERF_SCALA_OFFLINE_DIR:-/home/runner/software/scala}"

# The Java toolchain comes from the pinned openEuler 24.03 LTS SP4 container
# image: the case installs java-21-openjdk-headless/-devel with dnf inside this
# run's private container, so no JDK archive is downloaded or verified on the
# host.  The JDK major version stays a fixed workload parameter; the exact
# package build is reported as runtime context only.
JDK_MAJOR="21"
JDK_PACKAGES=("java-21-openjdk-headless" "java-21-openjdk-devel")
JDK_HOME_DEFAULT="/usr/lib/jvm/java-21-openjdk"

# 编译矩阵：固定站点源码集，全部由 scripts/generate_sources.py 确定性生成。
SCALA_COMPILE_SCALES=(20 100 300)
SCALA_RUN_WORKLOADS=(arith collections strings)
SCALA_EXTRA_SCENARIOS=(pipeline_compile_and_run)
SCALA_REPS="${PERF_REPS:-5}"

JDK_HOME="${JDK_HOME_DEFAULT}"
JDK_HOME_FILE=""
SCALA_HOME=""
SCALA_LIB_DIR=""
SCALAC_BIN=""
SCALA_PROGRAMS_OUT=""
PROJECTS_DIR=""
RUNS_DIR=""
SCALA_VERSION_STRING=""
declare -ga SCALA_ARCHIVE_URLS=()
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[scala] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    [[ "${SCALA_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${SCALA_REPS}"
        return 10
    }
    if (( SCALA_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${SCALA_REPS} is a local link-validation value; formal evidence requires >= 5"
    fi
}

select_scala_artifact() {
    SCALA_ARCHIVE_URLS=("${SCALA_MIRROR_URLS[@]}" "${SCALA_OFFICIAL_URL}")
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/scala/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    select_scala_artifact
    JDK_HOME_FILE="${PERF_WORK_DIR}/container-jdk-home.txt"
    if [[ -s "${JDK_HOME_FILE}" ]]; then
        JDK_HOME="$(head -n 1 "${JDK_HOME_FILE}")"
    fi
    SCALA_HOME="${PERF_WORK_DIR}/scala-install"
    SCALA_LIB_DIR="${SCALA_HOME}/maven2"
    SCALAC_BIN="${SCALA_HOME}/bin/scalac"
SCALA_CLASSPATH=""
    SCALA_PROGRAMS_OUT="${PERF_WORK_DIR}/programs-out"
    PROJECTS_DIR="${PERF_WORK_DIR}/projects"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR
    export PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR SCALA_REPS
    export JDK_HOME JDK_HOME_FILE SCALA_HOME SCALA_LIB_DIR SCALAC_BIN SCALA_PROGRAMS_OUT SCALA_CLASSPATH
    export PROJECTS_DIR RUNS_DIR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

# Container-side JAVA_HOME / Scala home.  Every scalac/java command runs through
# one of the wrappers below, so the measured process tree always uses the
# container JDK and the Scala distribution that lives under PERF_WORK_DIR.
SCALA_CONTAINER_PATH_PREFIX="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
declare -ga SCALA_ENV_ARGS=()

scala_refresh_env_args() {
    SCALA_ENV_ARGS=(
        "JAVA_HOME=${JDK_HOME}"
        "SCALA_HOME=${SCALA_HOME}"
        "PATH=${JDK_HOME}/bin:${SCALA_HOME}/bin:${SCALA_CONTAINER_PATH_PREFIX}"
    )
}

scala_container_env_exec() {
    scala_refresh_env_args
    scala_container_exec env "${SCALA_ENV_ARGS[@]}" "$@"
}

scala_container_env_exec_at() {
    local workdir="$1"
    shift
    scala_refresh_env_args
    scala_container_exec_at "${workdir}" env "${SCALA_ENV_ARGS[@]}" "$@"
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

java_version_string() {
    # Read the complete banner first: letting awk/head close the pipe early makes
    # the container JVM die from SIGPIPE, which pipefail then reports as failure.
    local banner
    banner="$(scala_container_env_exec java -version 2>&1)" || return 1
    printf '%s\n' "${banner}" | sed -n '1{s/^openjdk version "//;s/".*$//;p}'
}

export_java_env() {
    # Kept for the stage scripts: the JDK and Scala homes are injected per command
    # by scala_container_env_exec, there is no host-side JAVA_HOME/PATH to set.
    export JAVA_HOME="${JDK_HOME}"
}

# Scala 3.10 ships its jars under <home>/maven2 (the launchers in <home>/lib are
# tiny manifests), so the user classpath is built from the standard library jars
# only; the scalac launcher adds the compiler jars itself.
resolve_scala_classpath() {
    if [[ -n "${SCALA_CLASSPATH}" ]]; then
        return 0
    fi
    local name jar joined=""
    for name in scala3-library_3 scala-library tasty-core_3; do
        jar="$(find "${SCALA_LIB_DIR}" -type f -name "${name}-*.jar" | sort | head -n 1)"
        if [[ -z "${jar}" ]]; then
            log_message "ERROR: Scala distribution is missing ${name}-*.jar under ${SCALA_LIB_DIR}"
            return 40
        fi
        joined="${joined:+${joined}:}${jar}"
    done
    SCALA_CLASSPATH="${joined}"
    export SCALA_CLASSPATH
}

scala_compile_command() {
    printf '%s\n' "${SCALAC_BIN}" -classpath "${SCALA_CLASSPATH}" -d "$1" "${@:2}"
}

scala_run_command() {
    printf '%s\n' "${JDK_HOME}/bin/java" -cp "${SCALA_CLASSPATH}:$1" bench.Main "${@:2}"
}

scenario_metadata_payload() {
    # Emits the scenario contract consumed by scripts/results/parse_benchmark.py.
    python3 - "$1" "${SCALA_REPS}" <<'PY'
import json
import sys

output = sys.argv[1]
reps = int(sys.argv[2])
scenarios = []
for scale in (20, 100, 300):
    scenarios.append({
        "scenario": f"compile_{scale}",
        "description": f"scalac clean compile of the generated {scale}-class project",
        "workload": f"{scale} generated Scala 3 sources",
        "throughput": {"name": "classes_per_second", "items": scale, "unit": "classes/s"},
    })
for workload in ("arith", "collections", "strings"):
    scenarios.append({
        "scenario": f"run_{workload}",
        "description": f"JVM execution of the precompiled {workload} workload",
        "workload": f"scala3-library workload: {workload}",
    })
scenarios.append({
    "scenario": "pipeline_compile_and_run",
    "description": "compile the 100-class project and run it in one measured pipeline",
    "workload": "100 generated sources + JVM execution",
})
payload = {
    "reps": reps,
    "parameters": {
        "compile_scales": [20, 100, 300],
        "run_workloads": ["arith", "collections", "strings"],
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
    printf 'openEuler 24.03 LTS SP4 java-21-openjdk (JDK %s)\n' "${JDK_MAJOR}"
}

case_artifact_url() {
    printf '%s\n' "${SCALA_OFFICIAL_URL}"
}

case_artifact_sha256() {
    printf '%s\n' "${SCALA_ARCHIVE_SHA256}"
}

case_artifact_version_string() {
    if [[ -n "${SCALA_VERSION_STRING}" ]]; then
        printf '%s\n' "${SCALA_VERSION_STRING}"
        return 0
    fi
    local banner
    banner="$(scalac_version_output)" || return 1
    printf '%s\n' "${banner}" | sed -n '1p'
}

scalac_version_output() {
    scala_container_env_exec "${SCALAC_BIN}" -version 2>&1
}

case_build_notes() {
    printf 'scala3 compiler distribution (%s) + container OpenJDK %s; no compiler source build\n' \
        "${SCALA_ARCHIVE_NAME}" "${JDK_MAJOR}"
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
SCALA_IMAGE_ARCHIVE_DIR="${SCALA_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
SCALA_CA_ANCHORS_DIR="${SCALA_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
SCALA_CONTAINER_IMAGE="${SCALA_CONTAINER_IMAGE:-}"
SCALA_CONTAINER_NAME="${SCALA_CONTAINER_NAME:-}"
SCALA_CONTAINER_HOME="${SCALA_CONTAINER_HOME:-}"
declare -p SCALA_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || SCALA_CONTAINER_EXTRA_ARGS=()

scala_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

scala_configure_container() {
    local arch
    arch="$(scala_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${SCALA_CONTAINER_NAME}" ] || SCALA_CONTAINER_NAME="boostkit-scala-${arch}-${PERF_RUN_ID}"
    [ -n "${SCALA_CONTAINER_HOME}" ] || SCALA_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export SCALA_CONTAINER_NAME SCALA_CONTAINER_HOME
}

scala_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_scala_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_scala_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${SCALA_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_scala_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(scala_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${SCALA_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${SCALA_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        scala_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        scala_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    SCALA_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${SCALA_CONTAINER_IMAGE}" ] || ! docker image inspect "${SCALA_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${SCALA_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_scala_container_image_release || return $?
    export SCALA_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${SCALA_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_scala_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-scala-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${SCALA_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.scala.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_scala_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    scala_configure_container
    require_scala_docker || return $?
    if docker container inspect "${SCALA_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${SCALA_CONTAINER_NAME}"
        return 40
    fi
    sweep_scala_stale_containers || true
    prepare_scala_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${SCALA_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${SCALA_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${SCALA_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${SCALA_CONTAINER_HOME}" || return 40
    log_message "starting private container ${SCALA_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${SCALA_CONTAINER_NAME}" \
        --label "boostkit.scala.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${SCALA_CONTAINER_EXTRA_ARGS[@]}" \
        "${SCALA_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${SCALA_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${SCALA_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${SCALA_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${SCALA_CONTAINER_NAME}"
}

check_scala_container() {
    scala_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${SCALA_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${SCALA_CONTAINER_NAME}"
        return 40
    }
}

scala_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    scala_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${SCALA_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${SCALA_CONTAINER_NAME}" "$@"
}

scala_container_exec() { scala_docker_exec '' '' "$@"; }

scala_container_exec_at() {
    local workdir="$1"
    shift
    scala_docker_exec "${workdir}" '' "$@"
}

scala_container_exec_root() { scala_docker_exec '' root "$@"; }

scala_container_exec_root_at() {
    local workdir="$1"
    shift
    scala_docker_exec "${workdir}" root "$@"
}

remove_scala_container() {
    scala_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${SCALA_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.scala.run-id"}}' "${SCALA_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${SCALA_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${SCALA_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${SCALA_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${SCALA_CONTAINER_NAME}"
}
# >>> container-runtime:end
