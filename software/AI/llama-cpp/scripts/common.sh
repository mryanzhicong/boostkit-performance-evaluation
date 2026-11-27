#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="llama-cpp"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-3ac67535c86}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
LLAMA_CPP_IMAGE_ARCHIVE_DIR="${LLAMA_CPP_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
LLAMA_CPP_CA_ANCHORS_DIR="${LLAMA_CPP_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
LLAMA_CPP_OFFLINE_DIR="${LLAMA_CPP_OFFLINE_DIR:-/home/runner/software/llama-cpp}"
LLAMA_CPP_REPO_URL="${LLAMA_CPP_REPO_URL:-https://github.com/ggml-org/llama.cpp.git}"
LLAMA_CPP_MODEL_NAME="bge-m3-q8_0.gguf"
LLAMA_CPP_MODEL_URL="${LLAMA_CPP_MODEL_URL:-https://huggingface.co/ggml-org/bge-m3-Q8_0-GGUF/resolve/main/bge-m3-q8_0.gguf}"
LLAMA_CPP_MODEL_SHA256="${LLAMA_CPP_MODEL_SHA256:-aa473d51f451a22f0fcf39ba3330c14bed38a385712b1113440f69df4047a173}"
LLAMA_CPP_CONTAINER_IMAGE=""
LLAMA_CPP_CONTAINER_NAME=""
LLAMA_CPP_CONTAINER_LABEL="boostkit.llama-cpp.run-id"
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"

log() { printf '[llama-cpp] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log "ERROR: unsupported variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

configure_runtime_paths() {
    [[ "${SOFTWARE_VERSION}" == "3ac67535c86" ]] || {
        log "ERROR: only llama.cpp commit 3ac67535c86 is supported (got ${SOFTWARE_VERSION})"
        return 10
    }
    validate_variant || return $?
    PERF_RUN_ID="${PERF_RUN_ID:-local-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || { log 'ERROR: unsafe run ID'; return 10; }
    EXPECTED_ARCH="$(normalize_arch "${EXPECTED_ARCH}")"
    case "${EXPECTED_ARCH}" in
        x86_64|aarch64) ;;
        *) log "ERROR: unsupported architecture: ${EXPECTED_ARCH}"; return 10 ;;
    esac
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/llama-cpp/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    elif [[ "${PERF_WORK_DIR}" != /* ]]; then
        log 'ERROR: PERF_WORK_DIR must be absolute'
        return 10
    fi
    case "${PERF_WORK_DIR}" in
        /|/tmp|/home|/home/runner|/home/runner/boostkit-perf)
            log "ERROR: PERF_WORK_DIR is too broad: ${PERF_WORK_DIR}"
            return 10
            ;;
    esac
    LLAMA_CPP_HOME_DIR="${PERF_WORK_DIR}/home"
    LLAMA_CPP_SOURCE_DIR="${PERF_WORK_DIR}/llama.cpp-${SOFTWARE_VERSION}"
    LLAMA_CPP_BUILD_DIR="${PERF_WORK_DIR}/build"
    LLAMA_CPP_MODEL_DIR="${PERF_WORK_DIR}/models"
    LLAMA_CPP_MODEL_PATH="${LLAMA_CPP_MODEL_DIR}/${LLAMA_CPP_MODEL_NAME}"
    LLAMA_CPP_BENCH_BIN="${LLAMA_CPP_BUILD_DIR}/bin/llama-bench"
    LLAMA_CPP_SERVER_BIN="${LLAMA_CPP_BUILD_DIR}/bin/llama-server"
    LLAMA_CPP_EMBEDDING_BIN="${LLAMA_CPP_BUILD_DIR}/bin/llama-embedding"
    LLAMA_CPP_CONTAINER_NAME="boostkit-llama-cpp-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    LLAMA_CPP_IMAGE_STATE_FILE="${PERF_WORK_DIR}/container-image.txt"
    TMPDIR="${PERF_WORK_DIR}/tmp"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    export SOFTWARE_NAME SOFTWARE_VERSION PERF_VARIANT EXPECTED_ARCH PERF_RUN_ID
    export PERF_WORK_DIR RESULTS_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export LLAMA_CPP_HOME_DIR LLAMA_CPP_SOURCE_DIR LLAMA_CPP_BUILD_DIR LLAMA_CPP_MODEL_DIR
    export LLAMA_CPP_MODEL_PATH LLAMA_CPP_BENCH_BIN LLAMA_CPP_SERVER_BIN LLAMA_CPP_EMBEDDING_BIN
    export LLAMA_CPP_CONTAINER_NAME LLAMA_CPP_IMAGE_STATE_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}" "${TMPDIR}" "${LLAMA_CPP_HOME_DIR}" "${LLAMA_CPP_MODEL_DIR}"
}

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else
        "$@"
    fi
}

require_docker() {
    command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1 || {
        log 'ERROR: accessible Docker daemon required'
        return 30
    }
}

prepare_llama_cpp_image() {
    local name="openEuler-docker.${EXPECTED_ARCH}.tar.xz"
    local url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${name}"
    local archive checksum expected actual loaded image_arch release
    if [[ -s "${LLAMA_CPP_IMAGE_ARCHIVE_DIR}/${name}" ]]; then
        archive="${LLAMA_CPP_IMAGE_ARCHIVE_DIR}/${name}"
    else
        archive="${PERF_WORK_DIR}/${name}"
        rm -f -- "${archive}.part"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
            -o "${archive}.part" "${url}" || { rm -f -- "${archive}.part"; return 30; }
        mv -- "${archive}.part" "${archive}" || return 30
    fi
    if [[ -s "${LLAMA_CPP_IMAGE_ARCHIVE_DIR}/${name}.sha256sum" ]]; then
        checksum="${LLAMA_CPP_IMAGE_ARCHIVE_DIR}/${name}.sha256sum"
    else
        checksum="${PERF_WORK_DIR}/${name}.sha256sum"
        rm -f -- "${checksum}.part"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
            -o "${checksum}.part" "${url}.sha256sum" || { rm -f -- "${checksum}.part"; return 30; }
        mv -- "${checksum}.part" "${checksum}" || return 30
    fi
    expected="$(awk 'NR==1 {print $1}' "${checksum}")"
    [[ "${expected}" =~ ^[[:xdigit:]]{64}$ ]] || { log 'ERROR: invalid image SHA-256'; return 30; }
    actual="$(sha256sum "${archive}")"
    [[ "${actual%% *}" == "${expected,,}" ]] || { log 'ERROR: image SHA-256 mismatch'; return 30; }
    loaded="$(docker load --input "${archive}")" || return 30
    LLAMA_CPP_CONTAINER_IMAGE="$(printf '%s\n' "${loaded}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    [[ -n "${LLAMA_CPP_CONTAINER_IMAGE}" ]] || return 30
    image_arch="$(docker image inspect --format '{{.Architecture}}' "${LLAMA_CPP_CONTAINER_IMAGE}")" || return 30
    case "${EXPECTED_ARCH}:${image_arch}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log "ERROR: image architecture mismatch (${EXPECTED_ARCH} vs ${image_arch})"; return 30 ;;
    esac
    release="$(docker run --rm --network=none "${LLAMA_CPP_CONTAINER_IMAGE}" cat /etc/os-release)" || return 30
    grep -Eq '^ID="?openEuler"?$' <<< "${release}" && grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}" || {
        log 'ERROR: image is not openEuler 24.03 LTS SP4'
        return 30
    }
    printf '%s\n' "${LLAMA_CPP_CONTAINER_IMAGE}" > "${LLAMA_CPP_IMAGE_STATE_FILE}"
    log "openEuler image ready: ${LLAMA_CPP_CONTAINER_IMAGE}"
}

require_llama_cpp_container() {
    local -a cert_mount=() git_mount=() offline_mount=()
    require_docker || return $?
    docker container inspect "${LLAMA_CPP_CONTAINER_NAME}" >/dev/null 2>&1 && {
        log "ERROR: refusing to reuse or overwrite an existing container: ${LLAMA_CPP_CONTAINER_NAME}"
        return 40
    }
    prepare_llama_cpp_image || return $?
    if [[ -n "${PERF_PROXY:-}" ]]; then
        [[ -d "${LLAMA_CPP_CA_ANCHORS_DIR}" ]] || { log 'ERROR: proxy CA anchors missing'; return 30; }
        cert_mount+=(--mount "type=bind,source=${LLAMA_CPP_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    if [[ -f /home/runner/.gitconfig ]]; then
        git_mount+=(--mount type=bind,source=/home/runner/.gitconfig,target=/home/runner/.gitconfig,readonly)
    fi
    if [[ -d "${LLAMA_CPP_OFFLINE_DIR}" ]]; then
        offline_mount+=(--mount "type=bind,source=${LLAMA_CPP_OFFLINE_DIR},target=${LLAMA_CPP_OFFLINE_DIR},readonly")
    fi
    docker run --detach --name "${LLAMA_CPP_CONTAINER_NAME}" \
        --label "${LLAMA_CPP_CONTAINER_LABEL}=${PERF_RUN_ID}" \
        --network=host \
        --ulimit nofile=65535:65535 \
        --user "$(id -u):$(id -g)" \
        -e "HOME=${LLAMA_CPP_HOME_DIR}" \
        -e "XDG_CACHE_HOME=${LLAMA_CPP_HOME_DIR}/.cache" \
        -e "TMPDIR=${TMPDIR}" \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${git_mount[@]}" "${offline_mount[@]}" \
        "${LLAMA_CPP_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec --user 0 "${LLAMA_CPP_CONTAINER_NAME}" update-ca-trust extract || return 30
    fi
    if docker exec --user 0 "${LLAMA_CPP_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        docker exec --user 0 "${LLAMA_CPP_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || return 30
    fi
}

check_llama_cpp_container() {
    local running label
    running="$(docker inspect --format '{{.State.Running}}' "${LLAMA_CPP_CONTAINER_NAME}" 2>/dev/null || true)"
    [[ "${running}" == true ]] || {
        log "ERROR: managed llama-cpp container is not running: ${LLAMA_CPP_CONTAINER_NAME}"
        return 40
    }
    label="$(docker inspect --format "{{index .Config.Labels \"${LLAMA_CPP_CONTAINER_LABEL}\"}}" "${LLAMA_CPP_CONTAINER_NAME}" 2>/dev/null || true)"
    [[ "${label}" == "${PERF_RUN_ID}" ]] || {
        log "ERROR: container label mismatch on ${LLAMA_CPP_CONTAINER_NAME}"
        return 40
    }
}

container_exec() {
    local -a proxy=() git_config=()
    if [[ -n "${PERF_PROXY:-}" ]]; then
        proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}")
    fi
    if [[ -f /home/runner/.gitconfig ]]; then
        git_config=(-e GIT_CONFIG_GLOBAL=/home/runner/.gitconfig)
    fi
    docker exec "${proxy[@]}" \
        -e "HOME=${LLAMA_CPP_HOME_DIR}" \
        -e "XDG_CACHE_HOME=${LLAMA_CPP_HOME_DIR}/.cache" \
        -e "TMPDIR=${TMPDIR}" \
        "${git_config[@]}" \
        "${LLAMA_CPP_CONTAINER_NAME}" "$@"
}

container_exec_root() {
    local -a proxy=()
    [[ -z "${PERF_PROXY:-}" ]] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}")
    docker exec --user 0 "${proxy[@]}" "${LLAMA_CPP_CONTAINER_NAME}" "$@"
}

remove_llama_cpp_container() {
    local label
    docker container inspect "${LLAMA_CPP_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    label="$(docker inspect --format "{{index .Config.Labels \"${LLAMA_CPP_CONTAINER_LABEL}\"}}" "${LLAMA_CPP_CONTAINER_NAME}" 2>/dev/null || true)"
    [[ "${label}" == "${PERF_RUN_ID}" ]] || {
        log "ERROR: refusing to remove container without matching run label: ${LLAMA_CPP_CONTAINER_NAME}"
        return 70
    }
    if [[ -n "${RESULTS_DIR:-}" && -d "${RESULTS_DIR}" ]]; then
        docker logs "${LLAMA_CPP_CONTAINER_NAME}" > "${RESULTS_DIR}/container.log" 2>&1 || true
    fi
    docker stop --time 30 "${LLAMA_CPP_CONTAINER_NAME}" >/dev/null || return 70
    docker rm "${LLAMA_CPP_CONTAINER_NAME}" >/dev/null || return 70
}

verify_model_file() {
    local path="$1" expected actual magic
    expected="${LLAMA_CPP_MODEL_SHA256,,}"
    [[ "${expected}" =~ ^[[:xdigit:]]{64}$ ]] || {
        log "ERROR: invalid expected model SHA-256: ${LLAMA_CPP_MODEL_SHA256}"
        return 50
    }
    [[ -s "${path}" ]] || return 1
    actual="$(sha256sum "${path}")"
    [[ "${actual%% *}" == "${expected}" ]] || return 1
    magic="$(dd if="${path}" bs=4 count=1 2>/dev/null || true)"
    [[ "${magic}" == "GGUF" ]] || return 1
    return 0
}

prepare_bge_m3_model() {
    local local_model="${LLAMA_CPP_OFFLINE_DIR}/${LLAMA_CPP_MODEL_NAME}"
    local temp_model="${LLAMA_CPP_MODEL_PATH}.part"
    if [[ -e "${LLAMA_CPP_MODEL_PATH}" ]]; then
        if verify_model_file "${LLAMA_CPP_MODEL_PATH}"; then
            log "using verified private model copy: ${LLAMA_CPP_MODEL_PATH}"
            return 0
        fi
        log "WARNING: removing invalid private model copy before re-acquiring: ${LLAMA_CPP_MODEL_PATH}"
        rm -f -- "${LLAMA_CPP_MODEL_PATH}"
    fi
    rm -f -- "${temp_model}"
    if [[ -s "${local_model}" ]]; then
        log "checking offline pre-provisioned model: ${local_model}"
        if verify_model_file "${local_model}"; then
            cp -- "${local_model}" "${temp_model}" || { rm -f -- "${temp_model}"; return 50; }
            verify_model_file "${temp_model}" || { rm -f -- "${temp_model}"; log 'ERROR: copied model checksum verification failed'; return 50; }
            mv -- "${temp_model}" "${LLAMA_CPP_MODEL_PATH}" || { rm -f -- "${temp_model}"; return 50; }
            log "prepared verified model from offline cache: ${LLAMA_CPP_MODEL_PATH}"
            return 0
        fi
        log "WARNING: offline model failed SHA-256/GGUF check, falling back to upstream download: ${local_model}"
    fi
    log "downloading ${LLAMA_CPP_MODEL_NAME} from ${LLAMA_CPP_MODEL_URL}"
    with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
        -o "${temp_model}" "${LLAMA_CPP_MODEL_URL}" || {
        rm -f -- "${temp_model}"
        log 'ERROR: model download failed'
        return 50
    }
    if ! verify_model_file "${temp_model}"; then
        rm -f -- "${temp_model}"
        log "ERROR: downloaded model failed SHA-256 (${LLAMA_CPP_MODEL_SHA256}) or GGUF header verification"
        return 50
    fi
    mv -- "${temp_model}" "${LLAMA_CPP_MODEL_PATH}" || { rm -f -- "${temp_model}"; return 50; }
    log "downloaded and verified model: ${LLAMA_CPP_MODEL_PATH}"
}
