#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-23.1.4}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

LLVM_VERSION="${SOFTWARE_VERSION}"
LLVM_ARCHIVE_NAME="llvm-project-${LLVM_VERSION}.tar.gz"
LLVM_ARCHIVE_SHA256="3e1c70b30f623976c2046d94b8eeab6cac536f107914cb4ed7bac572a03131db"
LLVM_OFFICIAL_URL="https://codeload.github.com/llvm/llvm-project/tar.gz/refs/tags/llvmorg-${LLVM_VERSION}"
# The aarch64 runner cannot reliably fetch from github.com; the same pinned tag
# archive is fetched through a public mirror and verified against the identical
# SHA-256, so the download path never changes the compiled payload.
LLVM_MIRROR_URLS=(
    "https://ghfast.top/https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-${LLVM_VERSION}.tar.gz"
    "https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-${LLVM_VERSION}.tar.gz"
)
LLVM_OFFLINE_DIR="${PERF_LLVM_OFFLINE_DIR:-/home/runner/software/llvm}"
# Local link-validation shortcut only: an existing LLVM build tree whose
# bin/opt and bin/llc were produced with the same configuration.  CI leaves this
# empty and performs the full source build.
LLVM_REUSE_BUILD_DIR="${PERF_LLVM_REUSE_BUILD_DIR:-}"

LLVM_IR_FUNCTIONS=200
LLVM_BUILD_JOBS="${PERF_BUILD_JOBS:-6}"
LLVM_REPS="${PERF_REPS:-5}"

CMAKE_BIN="${PERF_CMAKE_BIN:-cmake}"
LLVM_SRC=""
LLVM_BUILD_DIR=""
LLVM_BIN_DIR=""
OPT_BIN=""
LLC_BIN=""
CORPUS_DIR=""
RUNS_DIR=""
LLVM_VERSION_STRING=""
LLVM_TARGET_NAME=""
declare -ga LLVM_ARCHIVE_URLS=()
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[llvm] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    [[ "${LLVM_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${LLVM_REPS}"
        return 10
    }
    if (( LLVM_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${LLVM_REPS} is a local link-validation value; formal evidence requires >= 5"
    fi
}

select_llvm_artifact() {
    LLVM_ARCHIVE_URLS=("${LLVM_MIRROR_URLS[@]}" "${LLVM_OFFICIAL_URL}")
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
        x86_64|amd64)
            EXPECTED_ARCH="x86_64"
            LLVM_TARGET_NAME="X86"
            ;;
        aarch64|arm64)
            EXPECTED_ARCH="aarch64"
            LLVM_TARGET_NAME="AArch64"
            ;;
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/llvm/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    select_llvm_artifact
    LLVM_SRC="${PERF_WORK_DIR}/llvm-project"
    LLVM_BUILD_DIR="${PERF_WORK_DIR}/llvm-build"
    if [[ -n "${LLVM_REUSE_BUILD_DIR}" ]]; then
        LLVM_BIN_DIR="${LLVM_REUSE_BUILD_DIR}/bin"
    else
        LLVM_BIN_DIR="${LLVM_BUILD_DIR}/bin"
    fi
    OPT_BIN="${LLVM_BIN_DIR}/opt"
    LLC_BIN="${LLVM_BIN_DIR}/llc"
    CORPUS_DIR="${PERF_WORK_DIR}/corpus"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR
    export PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR LLVM_REPS LLVM_REUSE_BUILD_DIR
    export LLVM_SRC LLVM_BUILD_DIR LLVM_BIN_DIR OPT_BIN LLC_BIN CORPUS_DIR RUNS_DIR
    export LLVM_IR_FUNCTIONS LLVM_BUILD_JOBS LLVM_TARGET_NAME CMAKE_BIN
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

scenario_metadata_payload() {
    python3 - "$1" "${LLVM_REPS}" "${LLVM_IR_FUNCTIONS}" "${LLVM_TARGET_NAME}" <<'PY'
import json
import sys

output = sys.argv[1]
reps = int(sys.argv[2])
functions = int(sys.argv[3])
target = sys.argv[4]
throughput = {"name": "functions_per_second", "items": functions, "unit": "functions/s"}
scenarios = [
    ("opt_o0_arith", "opt -O0 over the 200-function integer IR module", "arith.ll"),
    ("opt_o2_arith", "opt -O2 over the 200-function integer IR module", "arith.ll"),
    ("opt_o3_arith", "opt -O3 over the 200-function integer IR module", "arith.ll"),
    ("opt_multi_pass_arith",
     "opt with default<O2>,loop-vectorize,instcombine,gvn,simplifycfg over arith.ll",
     "arith.ll"),
    ("opt_o2_mem", "opt -O2 over the 200-function memory IR module", "mem.ll"),
    ("opt_o2_branch", "opt -O2 over the 200-function branchy IR module", "branch.ll"),
    ("llc_o0_arith", "llc -O0 (code generation) over the 200-function integer IR module", "arith.ll"),
    ("llc_o2_arith", "llc -O2 (code generation) over the 200-function integer IR module", "arith.ll"),
    ("pipeline_o2_arith", "opt -O2 then llc -O2 in one measured pipeline", "arith.ll"),
]
payload = {
    "reps": reps,
    "parameters": {
        "ir_functions": functions,
        "modules": ["arith.ll", "mem.ll", "branch.ll"],
        "native_target": target,
        "jdk": None,
    },
    "scenarios": [
        {
            "scenario": name,
            "description": description,
            "workload": module,
            "throughput": throughput,
        }
        for name, description, module in scenarios
    ],
}
with open(output, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, ensure_ascii=False, indent=2)
    handle.write("\n")
PY
}

case_tool_release_string() {
    local cc_version
    cc_version="$(g++ --version 2>/dev/null | head -n 1)"
    printf 'GCC %s\n' "${cc_version}"
}

case_artifact_url() {
    printf '%s\n' "${LLVM_OFFICIAL_URL}"
}

case_artifact_sha256() {
    printf '%s\n' "${LLVM_ARCHIVE_SHA256}"
}

case_artifact_version_string() {
    printf '%s\n' "${LLVM_VERSION_STRING:-LLVM ${SOFTWARE_VERSION}}"
}

case_build_notes() {
    printf 'built from the pinned llvm-project %s source archive with LLVM_TARGETS_TO_BUILD=%s and targets opt,llc; compiler: %s\n' \
        "${LLVM_VERSION}" "${LLVM_TARGET_NAME}" "$(g++ --version 2>/dev/null | head -n 1)"
}

# ------------------------------------------------- container process env ------
# ``docker exec`` does not inherit the caller's environment, so the values the
# build and the measurement need are forwarded explicitly.  Absolute paths are
# identical inside and outside the container because the work directory, the
# result directory and the case directory are mounted at the same paths.
LLVM_CONTAINER_ENV=()

llvm_build_env() {
    LLVM_CONTAINER_ENV=(
        "HOME=${LLVM_CONTAINER_HOME:-${PERF_WORK_DIR}/home}"
        "TMPDIR=${TMPDIR}"
        "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        "SOFTWARE_VERSION=${SOFTWARE_VERSION}"
        "LLVM_BUILD_JOBS=${LLVM_BUILD_JOBS}"
        "LLVM_TARGET_NAME=${LLVM_TARGET_NAME}"
        "LLVM_IR_FUNCTIONS=${LLVM_IR_FUNCTIONS}"
        "LLVM_SRC=${LLVM_SRC}"
        "LLVM_BUILD_DIR=${LLVM_BUILD_DIR}"
        "CORPUS_DIR=${CORPUS_DIR}"
    )
}

# Measurement environment: C locale, UTC and closed proxies so a measured opt/llc
# run cannot silently depend on the network.
llvm_measure_env() {
    llvm_build_env
    LLVM_CONTAINER_ENV+=(
        "TZ=UTC"
        "LC_ALL=C"
        "LANG=C"
        "HTTP_PROXY=http://127.0.0.1:9"
        "HTTPS_PROXY=http://127.0.0.1:9"
        "http_proxy=http://127.0.0.1:9"
        "https_proxy=http://127.0.0.1:9"
        "NO_PROXY=127.0.0.1,localhost"
        "no_proxy=127.0.0.1,localhost"
    )
}

llvm_container_exec_env() {
    llvm_build_env
    llvm_container_exec env "${LLVM_CONTAINER_ENV[@]}" "$@"
}

llvm_container_exec_env_at() {
    local workdir="$1"
    shift
    llvm_build_env
    llvm_container_exec_at "${workdir}" env "${LLVM_CONTAINER_ENV[@]}" "$@"
}

llvm_container_measure_at() {
    local workdir="$1"
    shift
    llvm_measure_env
    llvm_container_exec_at "${workdir}" env "${LLVM_CONTAINER_ENV[@]}" "$@"
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
LLVM_IMAGE_ARCHIVE_DIR="${LLVM_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
LLVM_CA_ANCHORS_DIR="${LLVM_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
LLVM_CONTAINER_IMAGE="${LLVM_CONTAINER_IMAGE:-}"
LLVM_CONTAINER_NAME="${LLVM_CONTAINER_NAME:-}"
LLVM_CONTAINER_HOME="${LLVM_CONTAINER_HOME:-}"
declare -p LLVM_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || LLVM_CONTAINER_EXTRA_ARGS=()

llvm_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

llvm_configure_container() {
    local arch
    arch="$(llvm_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${LLVM_CONTAINER_NAME}" ] || LLVM_CONTAINER_NAME="boostkit-llvm-${arch}-${PERF_RUN_ID}"
    [ -n "${LLVM_CONTAINER_HOME}" ] || LLVM_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export LLVM_CONTAINER_NAME LLVM_CONTAINER_HOME
}

llvm_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_llvm_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_llvm_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${LLVM_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_llvm_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(llvm_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${LLVM_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${LLVM_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        llvm_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        llvm_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    LLVM_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${LLVM_CONTAINER_IMAGE}" ] || ! docker image inspect "${LLVM_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${LLVM_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_llvm_container_image_release || return $?
    export LLVM_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${LLVM_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_llvm_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-llvm-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${LLVM_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.llvm.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_llvm_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    llvm_configure_container
    require_llvm_docker || return $?
    if docker container inspect "${LLVM_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${LLVM_CONTAINER_NAME}"
        return 40
    fi
    sweep_llvm_stale_containers || true
    prepare_llvm_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${LLVM_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${LLVM_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${LLVM_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${LLVM_CONTAINER_HOME}" || return 40
    log_message "starting private container ${LLVM_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${LLVM_CONTAINER_NAME}" \
        --label "boostkit.llvm.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${LLVM_CONTAINER_EXTRA_ARGS[@]}" \
        "${LLVM_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${LLVM_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${LLVM_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${LLVM_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${LLVM_CONTAINER_NAME}"
}

check_llvm_container() {
    llvm_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${LLVM_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${LLVM_CONTAINER_NAME}"
        return 40
    }
}

llvm_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    llvm_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${LLVM_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${LLVM_CONTAINER_NAME}" "$@"
}

llvm_container_exec() { llvm_docker_exec '' '' "$@"; }

llvm_container_exec_at() {
    local workdir="$1"
    shift
    llvm_docker_exec "${workdir}" '' "$@"
}

llvm_container_exec_root() { llvm_docker_exec '' root "$@"; }

llvm_container_exec_root_at() {
    local workdir="$1"
    shift
    llvm_docker_exec "${workdir}" root "$@"
}

remove_llvm_container() {
    llvm_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${LLVM_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.llvm.run-id"}}' "${LLVM_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${LLVM_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${LLVM_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${LLVM_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${LLVM_CONTAINER_NAME}"
}
# >>> container-runtime:end
