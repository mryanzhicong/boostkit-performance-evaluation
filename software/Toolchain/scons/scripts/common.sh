#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-4.11.1}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

SCONS_VERSION="${SOFTWARE_VERSION}"
SCONS_ARCHIVE_NAME="scons-${SCONS_VERSION}.tar.gz"
SCONS_ARCHIVE_SHA256="9087b5068572e9e4d9347c987e3fa5ab0edf3fa84935f7ac5c0508792bb7a776"
SCONS_OFFICIAL_URL="https://codeload.github.com/SCons/scons/tar.gz/refs/tags/${SCONS_VERSION}"
SCONS_MIRROR_URLS=(
    "https://ghfast.top/https://github.com/SCons/scons/archive/refs/tags/${SCONS_VERSION}.tar.gz"
    "https://github.com/SCons/scons/archive/refs/tags/${SCONS_VERSION}.tar.gz"
)
SCONS_OFFLINE_DIR="${PERF_SCONS_OFFLINE_DIR:-/home/runner/software/scons}"

# 构建矩阵：100 个 C 文件的 clean 全量 vs 单文件增量 vs 空闲增量。
SCONS_C_FILE_COUNT=100
SCONS_REPS="${PERF_REPS:-5}"
# 上游自带 bench/ 中在 CPython 3 上可完整运行（退出码 0）的计时脚本；
# 其余三个（env.__setitem__.py / benchmark_subst.py / time_member.py）在本
# 解释器上分别超时或报错，已在 README 中记录并排除，不做零填充。
SCONS_BENCH_SCRIPTS=(is_types.py lvars-gvars.py dependency-func.py)

SCONS_HOME=""
SCONS_ENTRY=""
PROJECT_DIR=""
RUNS_DIR=""
SCONS_VERSION_STRING=""
declare -ga SCONS_ARCHIVE_URLS=()
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[scons] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    [[ "${SCONS_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${SCONS_REPS}"
        return 10
    }
    if (( SCONS_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${SCONS_REPS} is a local link-validation value; formal evidence requires >= 5"
    fi
}

select_scons_artifact() {
    SCONS_ARCHIVE_URLS=("${SCONS_MIRROR_URLS[@]}" "${SCONS_OFFICIAL_URL}")
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/scons/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    select_scons_artifact
    SCONS_HOME="${PERF_WORK_DIR}/scons-src"
    SCONS_ENTRY="${SCONS_HOME}/scripts/scons.py"
    PROJECT_DIR="${PERF_WORK_DIR}/project-${SCONS_C_FILE_COUNT}"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR
    export PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR SCONS_REPS
    export SCONS_HOME SCONS_ENTRY PROJECT_DIR RUNS_DIR SCONS_C_FILE_COUNT
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

scenario_metadata_payload() {
    python3 - "$1" "${SCONS_REPS}" <<'PY'
import json
import sys

output = sys.argv[1]
reps = int(sys.argv[2])
scenarios = [
    {
        "scenario": "upstream_bench_is_types",
        "description": "upstream bench/ harness: SCons is_types snippet timing",
        "workload": "bench/is_types.py",
    },
    {
        "scenario": "upstream_bench_lvars_gvars",
        "description": "upstream bench/ harness: LocalVariables/GlobalVariables snippet timing",
        "workload": "bench/lvars-gvars.py",
    },
    {
        "scenario": "upstream_bench_dependency_func",
        "description": "upstream bench/ harness: dependency function snippet timing",
        "workload": "bench/dependency-func.py",
    },
    {
        "scenario": "scons_clean_100",
        "description": "SCons clean build of the generated 100-file C project",
        "workload": "100 generated C sources",
        "throughput": {"name": "files_per_second", "items": 100, "unit": "files/s"},
    },
    {
        "scenario": "scons_noop_100",
        "description": "SCons no-op build of an up-to-date 100-file C project (idle incremental)",
        "workload": "100 unchanged C sources",
    },
    {
        "scenario": "scons_incremental_one_100",
        "description": "SCons incremental build after modifying a single C source",
        "workload": "100 C sources, 1 modified",
    },
]
payload = {
    "reps": reps,
    "parameters": {
        "c_file_count": 100,
        "bench_scripts": ["is_types.py", "lvars-gvars.py", "dependency-func.py"],
        "scons_launcher": "python3 scripts/scons.py (run from the pinned source tree)",
    },
    "scenarios": scenarios,
}
with open(output, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, ensure_ascii=False, indent=2)
    handle.write("\n")
PY
}

case_tool_release_string() {
    printf 'CPython %s\n' "$(python3 -c 'import platform; print(platform.python_version())' 2>/dev/null)"
}

case_artifact_url() {
    printf '%s\n' "${SCONS_OFFICIAL_URL}"
}

case_artifact_sha256() {
    printf '%s\n' "${SCONS_ARCHIVE_SHA256}"
}

case_artifact_version_string() {
    printf '%s\n' "${SCONS_VERSION_STRING:-SCons ${SOFTWARE_VERSION}}"
}

case_build_notes() {
    printf 'SCons source distribution (%s) executed from the extracted tree; C compiler: %s\n' \
        "${SCONS_ARCHIVE_NAME}" "$(cc --version 2>/dev/null | head -n 1)"
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
SCONS_IMAGE_ARCHIVE_DIR="${SCONS_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
SCONS_CA_ANCHORS_DIR="${SCONS_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
SCONS_CONTAINER_IMAGE="${SCONS_CONTAINER_IMAGE:-}"
SCONS_CONTAINER_NAME="${SCONS_CONTAINER_NAME:-}"
SCONS_CONTAINER_HOME="${SCONS_CONTAINER_HOME:-}"
declare -p SCONS_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || SCONS_CONTAINER_EXTRA_ARGS=()

scons_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

scons_configure_container() {
    local arch
    arch="$(scons_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${SCONS_CONTAINER_NAME}" ] || SCONS_CONTAINER_NAME="boostkit-scons-${arch}-${PERF_RUN_ID}"
    [ -n "${SCONS_CONTAINER_HOME}" ] || SCONS_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export SCONS_CONTAINER_NAME SCONS_CONTAINER_HOME
}

scons_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_scons_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_scons_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${SCONS_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_scons_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(scons_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${SCONS_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${SCONS_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        scons_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        scons_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    SCONS_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${SCONS_CONTAINER_IMAGE}" ] || ! docker image inspect "${SCONS_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${SCONS_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_scons_container_image_release || return $?
    export SCONS_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${SCONS_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_scons_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-scons-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${SCONS_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.scons.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_scons_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    scons_configure_container
    require_scons_docker || return $?
    if docker container inspect "${SCONS_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${SCONS_CONTAINER_NAME}"
        return 40
    fi
    sweep_scons_stale_containers || true
    prepare_scons_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${SCONS_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${SCONS_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${SCONS_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${SCONS_CONTAINER_HOME}" || return 40
    log_message "starting private container ${SCONS_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${SCONS_CONTAINER_NAME}" \
        --label "boostkit.scons.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${SCONS_CONTAINER_EXTRA_ARGS[@]}" \
        "${SCONS_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${SCONS_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${SCONS_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${SCONS_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${SCONS_CONTAINER_NAME}"
}

check_scons_container() {
    scons_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${SCONS_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${SCONS_CONTAINER_NAME}"
        return 40
    }
}

scons_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    scons_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${SCONS_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${SCONS_CONTAINER_NAME}" "$@"
}

scons_container_exec() { scons_docker_exec '' '' "$@"; }

scons_container_exec_at() {
    local workdir="$1"
    shift
    scons_docker_exec "${workdir}" '' "$@"
}

scons_container_exec_root() { scons_docker_exec '' root "$@"; }

scons_container_exec_root_at() {
    local workdir="$1"
    shift
    scons_docker_exec "${workdir}" root "$@"
}

remove_scons_container() {
    scons_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${SCONS_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.scons.run-id"}}' "${SCONS_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${SCONS_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${SCONS_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${SCONS_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${SCONS_CONTAINER_NAME}"
}
# >>> container-runtime:end
