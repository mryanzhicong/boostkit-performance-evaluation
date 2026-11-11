#!/usr/bin/env bash
# Shared configuration for the OpenViking 0.5.0 benchmark-kit performance case.
#
# Every environment (x86_64 and aarch64) runs the upstream OpenViking v0.5.0
# container benchmark kit inside one private openEuler 24.03 LTS SP4 container:
#
#   1. the v0.5.0 source tree is cloned on the host, its tag commit is verified
#      and the architecture-specific ``benchmark-kit`` archive is copied out and
#      SHA-256 verified before it enters the container;
#   2. inside the container the kit's pinned dependency set, the v0.5.0 wheel
#      and the instrumented overlay are installed, and the import contract is
#      verified;
#   3. the kit's seven-step protocol (write LoCoMo sample 0 with telemetry,
#      replay 152 search questions, run 152 QA questions, instrumentation
#      coverage, report suite) is executed against a deterministic local mock of
#      the LLM/embedding providers, so the run needs no external model service
#      and stays reproducible;
#   4. the run is executed exactly as the kit ships it: no NUMA node binding, no
#      cpuset pinning and no other non-out-of-the-box tuning is applied.
#
# The host keeps only Docker, the source clone, asset verification, the stage
# orchestration and the strict result parser.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SOFTWARE_VERSION="${SOFTWARE_VERSION:-0.5.0}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# Upstream source of truth: the OpenViking v0.5.0 benchmark kit.
OPENVIKING_REPO_URL="${OPENVIKING_REPO_URL:-https://gitcode.com/JankinLee/OpenViking.git}"
OPENVIKING_TAG="${OPENVIKING_TAG:-V0.5.0}"
OPENVIKING_COMMIT="${OPENVIKING_COMMIT:-b2b3df1fb5d845552a87f1efde8d5ddf5018c66b}"
OPENVIKING_KIT_VERSION="${OPENVIKING_KIT_VERSION:-48T96G}"
declare -A OPENVIKING_KIT_SHA256=(
    [aarch64]="45d6f22bf825c837cd46b462639a0c561960c008941407aa7ec9c470b02a8707"
    [x86_64]="3e947cc9c50b50e63a1a1af48692f3c1f9c9daf0d4b0cc5ed67977ef53450dc0"
)
OPENVIKING_PIP_INDEX_URL="${OPENVIKING_PIP_INDEX_URL:-https://repo.huaweicloud.com/repository/pypi/simple}"
OPENVIKING_PIP_TRUSTED_HOST="${OPENVIKING_PIP_TRUSTED_HOST:-repo.huaweicloud.com}"

# Provider mock: deterministic local replacement for the external LLM and
# embedding APIs the kit normally talks to.
OPENVIKING_MOCK_PORT="${OPENVIKING_MOCK_PORT:-19660}"
OPENVIKING_MOCK_MODEL="${OPENVIKING_MOCK_MODEL:-mock-chat}"
OPENVIKING_MOCK_EMBEDDING_MODEL="${OPENVIKING_MOCK_EMBEDDING_MODEL:-mock-embedding}"
OPENVIKING_MOCK_EMBEDDING_DIMENSION="${OPENVIKING_MOCK_EMBEDDING_DIMENSION:-1024}"
OPENVIKING_SERVICE_PORT="${OPENVIKING_SERVICE_PORT:-19666}"
OPENVIKING_QA_CONCURRENCY="${OPENVIKING_QA_CONCURRENCY:-8}"
OPENVIKING_SEARCH_CONCURRENCY="${OPENVIKING_SEARCH_CONCURRENCY:-4}"
OPENVIKING_TOKEN_CONCURRENCY="${OPENVIKING_TOKEN_CONCURRENCY:-4}"
OPENVIKING_REQUEST_TIMEOUT="${OPENVIKING_REQUEST_TIMEOUT:-600}"

# Fixed in-container locations (all inside the mounted work directory, so the
# container user needs no write access outside it).
OPENVIKING_INSTALL_DIR=""
OPENVIKING_CONTEXT_DIR=""
OPENVIKING_SITE_DIR=""
OPENVIKING_KIT_DIR=""
OPENVIKING_SRC_HOST_DIR=""
OPENVIKING_KIT_ARCHIVE=""
OPENVIKING_RUN_ROOT=""
OPENVIKING_WARMUP_RUN_ROOT=""
OPENVIKING_PYTHON="python3"
OPENVIKING_ARCH=""
OPENVIKING_KIT_ARCHIVE_NAME=""
OPENVIKING_KIT_SHA256=""
OPENVIKING_SOURCE_COMMIT=""
OPENVIKING_CONTAINER_ENV_FILE=""

log_message() {
    printf '[openviking] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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

configure_runtime_paths() {
    validate_variant || return $?
    EXPECTED_ARCH="$(normalize_architecture "${EXPECTED_ARCH}")"
    case "${EXPECTED_ARCH}" in
        x86_64) OPENVIKING_ARCH="x86_64" ;;
        aarch64) OPENVIKING_ARCH="aarch64" ;;
        *)
            log_message "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    local runner_architecture
    runner_architecture="$(normalize_architecture "$(uname -m)")"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log_message "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi

    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="/home/runner/boostkit-perf/openviking/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/openviking/local-${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi

    OPENVIKING_INSTALL_DIR="${PERF_WORK_DIR}/install"
    OPENVIKING_CONTEXT_DIR="${OPENVIKING_INSTALL_DIR}/kit-context"
    OPENVIKING_SITE_DIR="${OPENVIKING_INSTALL_DIR}/site-packages"
    OPENVIKING_KIT_DIR="${OPENVIKING_INSTALL_DIR}/kit"
    OPENVIKING_SRC_HOST_DIR="${PERF_WORK_DIR}/OpenViking-${OPENVIKING_TAG}"
    OPENVIKING_KIT_ARCHIVE_NAME="openviking-${SOFTWARE_VERSION}-${OPENVIKING_KIT_VERSION}-${OPENVIKING_ARCH}-container-benchmark-kit.tar"
    OPENVIKING_KIT_SHA256="${OPENVIKING_KIT_SHA256[${OPENVIKING_ARCH}]}"
    OPENVIKING_KIT_ARCHIVE="${PERF_WORK_DIR}/${OPENVIKING_KIT_ARCHIVE_NAME}"
    OPENVIKING_RUN_ROOT="${RESULTS_DIR}/run"
    OPENVIKING_WARMUP_RUN_ROOT="${RESULTS_DIR}/warmup"
    OPENVIKING_CONTAINER_ENV_FILE="${PERF_WORK_DIR}/container-env.sh"

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE OPENVIKING_ARCH OPENVIKING_INSTALL_DIR OPENVIKING_CONTEXT_DIR
    export OPENVIKING_SITE_DIR OPENVIKING_KIT_DIR OPENVIKING_SRC_HOST_DIR OPENVIKING_KIT_ARCHIVE
    export OPENVIKING_KIT_ARCHIVE_NAME OPENVIKING_KIT_SHA256 OPENVIKING_RUN_ROOT
    export OPENVIKING_WARMUP_RUN_ROOT OPENVIKING_CONTAINER_ENV_FILE
    export OPENVIKING_MOCK_PORT OPENVIKING_SERVICE_PORT OPENVIKING_MOCK_MODEL
    export OPENVIKING_MOCK_EMBEDDING_MODEL OPENVIKING_MOCK_EMBEDDING_DIMENSION
    export OPENVIKING_QA_CONCURRENCY OPENVIKING_SEARCH_CONCURRENCY OPENVIKING_TOKEN_CONCURRENCY
    export OPENVIKING_REQUEST_TIMEOUT OPENVIKING_PIP_INDEX_URL OPENVIKING_PIP_TRUSTED_HOST
}

# Route the case directory into the container: the benchmark harness scripts and
# the provider mock live in ``<case>/benchmark`` and are executed in place.
configure_openviking_container_mounts() {
    local existing
    for existing in "${OPENVIKING_CONTAINER_EXTRA_ARGS[@]:-}"; do
        if [[ "${existing}" == *"target=${SCRIPT_DIR}"* ]]; then
            return 0
        fi
    done
    :
}

# Write the environment that every in-container command sources.  Keeping it in
# one file avoids re-deriving dozens of paths on each docker exec call.
write_openviking_container_env() {
    mkdir -p "${PERF_WORK_DIR}" || return 30
    cat > "${OPENVIKING_CONTAINER_ENV_FILE}" <<EOF
export SOFTWARE_VERSION='${SOFTWARE_VERSION}'
export EXPECTED_ARCH='${EXPECTED_ARCH}'
export PERF_RUN_ID='${PERF_RUN_ID}'
export RESULTS_DIR='${RESULTS_DIR}'
export PERF_WORK_DIR='${PERF_WORK_DIR}'
export PYTHONPATH='${OPENVIKING_SITE_DIR}:${OPENVIKING_KIT_DIR}'
export PYTHONUNBUFFERED=1
export KIT_ROOT='${OPENVIKING_KIT_DIR}'
export CASE_DIR='${SCRIPT_DIR}'
export INSTALL_DIR='${OPENVIKING_INSTALL_DIR}'
export RUN_ROOT='${OPENVIKING_RUN_ROOT}'
export WARMUP_RUN_ROOT='${OPENVIKING_WARMUP_RUN_ROOT}'
export SERVICE_PORT='${OPENVIKING_SERVICE_PORT}'
export MOCK_PORT='${OPENVIKING_MOCK_PORT}'
export OPENVIKING_URL='http://127.0.0.1:${OPENVIKING_SERVICE_PORT}'
export OPENVIKING_CONFIG_FILE='${OPENVIKING_RUN_ROOT}/ov.conf'
export OV_AGFS_TIMING=1
export OPENVIKING_VERSION_LABEL='OpenViking v0.5.0 (official benchmark kit ${OPENVIKING_KIT_VERSION}, ${OPENVIKING_ARCH}, container, out-of-the-box)'
export OPENVIKING_SOURCE_COMMIT='${OPENVIKING_COMMIT}'
export LLM_BASE_URL='http://127.0.0.1:${OPENVIKING_MOCK_PORT}/v1'
export LLM_API_KEY='local-mock'
export LLM_MODEL='${OPENVIKING_MOCK_MODEL}'
export EMBEDDING_BASE_URL='http://127.0.0.1:${OPENVIKING_MOCK_PORT}/v1'
export EMBEDDING_API_KEY='local-mock'
export EMBEDDING_MODEL='${OPENVIKING_MOCK_EMBEDDING_MODEL}'
export EMBEDDING_DIMENSION='${OPENVIKING_MOCK_EMBEDDING_DIMENSION}'
export EMBEDDING_INPUT=text
export QA_CONCURRENCY='${OPENVIKING_QA_CONCURRENCY}'
export SEARCH_CONCURRENCY='${OPENVIKING_SEARCH_CONCURRENCY}'
export TOKEN_CONCURRENCY='${OPENVIKING_TOKEN_CONCURRENCY}'
export JUDGE_CONCURRENCY='${OPENVIKING_QA_CONCURRENCY}'
export REQUEST_TIMEOUT='${OPENVIKING_REQUEST_TIMEOUT}'
export RUN_MODE=full
export USE_SYSTEM_PROXY=0
export BUILD_REPORTS_FULL=1
unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY
EOF
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${OPENVIKING_INSTALL_DIR}" || return 30
    openviking_configure_container
    configure_openviking_container_mounts
    # The build stage discovers the architecture-specific kit layout; later
    # stages re-discover it from the persisted kit tree so that KIT_ROOT and the
    # harness PYTHONPATH stay valid across stage boundaries.
    if [[ -d "${OPENVIKING_CONTEXT_DIR}" ]] \
        && find "${OPENVIKING_CONTEXT_DIR}" -maxdepth 6 -type f -path '*/harness/import_to_ov.py' | grep -q .; then
        discover_openviking_kit_layout || return $?
    fi
    write_openviking_container_env || return $?
    export OPENVIKING_CONTAINER_NAME
}

# Run one command inside the private container with the case environment.
openviking_run() {
    openviking_container_exec bash -c ". '${OPENVIKING_CONTAINER_ENV_FILE}'; $*"
}

openviking_run_at() {
    local workdir="$1"
    shift
    openviking_container_exec_at "${workdir}" bash -c ". '${OPENVIKING_CONTAINER_ENV_FILE}'; $*"
}

openviking_http_ready() {
    local url="$1"
    openviking_run "python3 -c \"import urllib.request; urllib.request.urlopen('${url}', timeout=5)\"" >/dev/null 2>&1
}

wait_for_openviking_http() {
    local url="$1" attempts="${2:-120}" index=0
    while (( index < attempts )); do
        if openviking_http_ready "${url}"; then
            return 0
        fi
        index=$((index + 1))
        sleep 1
    done
    return 1
}

# Locate the kit, wheel, overlay and dependency lock inside the extracted
# benchmark-kit archive, whose layout differs between architectures.
discover_openviking_kit_layout() {
    local root="${OPENVIKING_CONTEXT_DIR}"
    local harness_dir
    harness_dir="$(find "${root}" -type f -path '*/harness/import_to_ov.py' | head -n 1)" || return 30
    [[ -n "${harness_dir}" ]] || {
        log_message "ERROR: cannot locate the benchmark-kit harness in ${root}"
        return 30
    }
    OPENVIKING_KIT_DIR="$(dirname "$(dirname "${harness_dir}")")"
    [[ -n "${OPENVIKING_KIT_DIR}" && -d "${OPENVIKING_KIT_DIR}" ]] || {
        log_message "ERROR: cannot locate the benchmark-kit harness in ${root}"
        return 30
    }
    OPENVIKING_WHEEL_FILE="$(find "${root}" -type f -name "openviking-${SOFTWARE_VERSION}-*.whl" | head -n 1)" || return 30
    [[ -n "${OPENVIKING_WHEEL_FILE}" ]] || {
        log_message "ERROR: cannot locate the OpenViking ${SOFTWARE_VERSION} wheel in ${root}"
        return 30
    }
    local lock candidate
    lock=""
    for candidate in "${OPENVIKING_KIT_DIR}/requirements-${SOFTWARE_VERSION}.lock" \
                     "$(find "${root}" -maxdepth 3 -type f -name 'requirements.lock' | head -n 1)" \
                     "$(find "${root}" -maxdepth 3 -type f -name "requirements-${SOFTWARE_VERSION}.lock" | head -n 1)"; do
        if [[ -n "${candidate}" && -f "${candidate}" ]]; then
            lock="${candidate}"
            break
        fi
    done
    [[ -n "${lock}" ]] || {
        log_message "ERROR: cannot locate the pinned dependency lock in ${root}"
        return 30
    }
    OPENVIKING_REQUIREMENTS_LOCK="${lock}"
    # The overlay only replaces instrumented modules, so it has no __init__.py;
    # identify it by the instrumented extraction module it ships.
    local overlay candidate_overlay
    overlay=""
    for candidate_overlay in "${root}"/*/overlay/openviking "${root}"/*/*/overlay/openviking "${root}"/*/*/*/overlay/openviking \
                              "${root}"/*/*/_port/*/openviking "${root}"/*/_port/*/openviking \
                              "$(find "${root}" -type d -name openviking -path '*/overlay/*' | head -n 1)" \
                              "$(find "${root}" -type d -name openviking -path '*/_port/*' | head -n 1)"; do
        if [[ -n "${candidate_overlay}" && -f "${candidate_overlay}/session/memory/extract_loop.py" ]]; then
            overlay="${candidate_overlay}"
            break
        fi
    done
    [[ -n "${overlay}" ]] || {
        log_message "ERROR: cannot locate the instrumented overlay in ${root}"
        return 30
    }
    OPENVIKING_OVERLAY_DIR="${overlay}"
    export OPENVIKING_WHEEL_FILE OPENVIKING_REQUIREMENTS_LOCK OPENVIKING_OVERLAY_DIR OPENVIKING_KIT_DIR
    log_message "benchmark-kit layout: kit=${OPENVIKING_KIT_DIR} wheel=$(basename "${OPENVIKING_WHEEL_FILE}") overlay=${OPENVIKING_OVERLAY_DIR#"${root}/"}"
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
OPENVIKING_IMAGE_ARCHIVE_DIR="${OPENVIKING_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
OPENVIKING_CA_ANCHORS_DIR="${OPENVIKING_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
OPENVIKING_CONTAINER_IMAGE="${OPENVIKING_CONTAINER_IMAGE:-}"
OPENVIKING_CONTAINER_NAME="${OPENVIKING_CONTAINER_NAME:-}"
OPENVIKING_CONTAINER_HOME="${OPENVIKING_CONTAINER_HOME:-}"
declare -p OPENVIKING_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || OPENVIKING_CONTAINER_EXTRA_ARGS=()

openviking_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

openviking_configure_container() {
    local arch
    arch="$(openviking_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${OPENVIKING_CONTAINER_NAME}" ] || OPENVIKING_CONTAINER_NAME="boostkit-openviking-${arch}-${PERF_RUN_ID}"
    [ -n "${OPENVIKING_CONTAINER_HOME}" ] || OPENVIKING_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export OPENVIKING_CONTAINER_NAME OPENVIKING_CONTAINER_HOME
}

openviking_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_openviking_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_openviking_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${OPENVIKING_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_openviking_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(openviking_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${OPENVIKING_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${OPENVIKING_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        openviking_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        openviking_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    OPENVIKING_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${OPENVIKING_CONTAINER_IMAGE}" ] || ! docker image inspect "${OPENVIKING_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${OPENVIKING_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_openviking_container_image_release || return $?
    export OPENVIKING_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${OPENVIKING_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_openviking_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-openviking-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${OPENVIKING_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.openviking.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_openviking_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    openviking_configure_container
    require_openviking_docker || return $?
    if docker container inspect "${OPENVIKING_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${OPENVIKING_CONTAINER_NAME}"
        return 40
    fi
    sweep_openviking_stale_containers || true
    prepare_openviking_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${OPENVIKING_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${OPENVIKING_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${OPENVIKING_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${OPENVIKING_CONTAINER_HOME}" || return 40
    log_message "starting private container ${OPENVIKING_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${OPENVIKING_CONTAINER_NAME}" \
        --label "boostkit.openviking.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${OPENVIKING_CONTAINER_EXTRA_ARGS[@]}" \
        "${OPENVIKING_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${OPENVIKING_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${OPENVIKING_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${OPENVIKING_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${OPENVIKING_CONTAINER_NAME}"
}

check_openviking_container() {
    openviking_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${OPENVIKING_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${OPENVIKING_CONTAINER_NAME}"
        return 40
    }
}

openviking_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    openviking_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${OPENVIKING_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${OPENVIKING_CONTAINER_NAME}" "$@"
}

openviking_container_exec() { openviking_docker_exec '' '' "$@"; }

openviking_container_exec_at() {
    local workdir="$1"
    shift
    openviking_docker_exec "${workdir}" '' "$@"
}

openviking_container_exec_root() { openviking_docker_exec '' root "$@"; }

openviking_container_exec_root_at() {
    local workdir="$1"
    shift
    openviking_docker_exec "${workdir}" root "$@"
}

remove_openviking_container() {
    openviking_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${OPENVIKING_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.openviking.run-id"}}' "${OPENVIKING_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${OPENVIKING_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${OPENVIKING_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${OPENVIKING_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${OPENVIKING_CONTAINER_NAME}"
}
# >>> container-runtime:end
