#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="tensorflow"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-2.20.0}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# The private benchmark assets are placed by the operator under one directory:
#   benchmark-infer.tar, tf_benchmark.tar.gz, optional tensorflow/ source and
#   optional download/ Bazel distdir.
TF_ASSET_DIR="${TF_ASSET_DIR:-/home/runner/software/tensorflow}"
TF_IMAGE_TAR="${TF_IMAGE_TAR:-${TF_ASSET_DIR}/benchmark-infer.tar}"
TF_BENCH_ARCHIVE="${TF_BENCH_ARCHIVE:-${TF_ASSET_DIR}/tf_benchmark.tar.gz}"
TF_IMAGE="${TF_IMAGE:-benchmark-infer:v1.0.0}"
TF_SOURCE_REPOSITORY="${TF_SOURCE_REPOSITORY:-https://gitcode.com/boostkit/tensorflow.git}"
TF_SOURCE_BRANCH="${TF_SOURCE_BRANCH:-dev_2.20.0}"

# Formal workload. The PDF uses 12 server containers; this framework case runs
# one private container and one server, which is the reproducible subset. The
# model, baseline mode, QPS, warmup, duration and batching are configurable but
# the defaults follow the PDF example.
TF_MODEL="${TF_MODEL:-din_mmoe}"
TF_RUN_MODES="${TF_RUN_MODES:-baseline}"
TF_QPS_LIST="${TF_QPS_LIST:-565}"
TF_WARMUP="${TF_WARMUP:-5}"
TF_DURATION="${TF_DURATION:-30}"
TF_THREAD_NUM="${TF_THREAD_NUM:-16}"
TF_CLIENT_THREAD_NUM="${TF_CLIENT_THREAD_NUM:-1}"
TF_MAX_INFLIGHT="${TF_MAX_INFLIGHT:-100}"
TF_REQUEST_MIN_BATCH_SIZE="${TF_REQUEST_MIN_BATCH_SIZE:-1}"
TF_REQUEST_MAX_BATCH_SIZE="${TF_REQUEST_MAX_BATCH_SIZE:-100}"
TF_SERVER_STARTUP_TIMEOUT="${TF_SERVER_STARTUP_TIMEOUT:-600}"

TF_WORK_DIR=""
TF_SOURCE_DIR=""
TF_ASSET_ROOT=""
TF_MODEL_DIR=""
TF_DATA_FILE=""
TF_OUT_DIR=""
TF_CSV_PATH=""
TF_EVIDENCE_DIR=""
TF_RAW_LOG=""
TF_IMAGE_SHA256_FILE=""
TF_SOURCE_COMMIT_FILE=""
TF_ASSET_SHA256_FILE=""
TF_CONTAINER_NAME=""
TF_SOURCE_COMMIT=""
TF_ASSET_SHA256=""
TF_IMAGE_SHA256=""

STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log() { printf '[tensorflow] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

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
        *) log "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    }
    EXPECTED_ARCH="$(normalize_arch "${EXPECTED_ARCH}")"
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/tensorflow/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    elif [[ "${PERF_WORK_DIR}" != /* ]]; then
        log 'ERROR: PERF_WORK_DIR must be an absolute path'
        return 10
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    case "${PERF_WORK_DIR}" in
        /|/home|/home/runner|/home/runner/boostkit-perf)
            log "ERROR: PERF_WORK_DIR is too broad for a private run: ${PERF_WORK_DIR}"
            return 10 ;;
    esac
    [[ "${TF_ASSET_DIR}" == /* ]] || TF_ASSET_DIR="$(pwd -P)/${TF_ASSET_DIR}"
    TF_WORK_DIR="${PERF_WORK_DIR}"
    TF_SOURCE_DIR="${PERF_WORK_DIR}/tensorflow"
    if [[ -d "${TF_ASSET_DIR}/tf_benchmark" ]]; then
        TF_ASSET_ROOT="${TF_ASSET_DIR}/tf_benchmark"
    else
        TF_ASSET_ROOT="${PERF_WORK_DIR}/assets/tf_benchmark"
    fi
    TF_MODEL_DIR="${TF_ASSET_ROOT}/${TF_MODEL}/1"
    TF_DATA_FILE="${TF_ASSET_ROOT}/benchmark_dataset/${TF_MODEL}.tsv"
    TF_OUT_DIR="${RESULTS_DIR}/tensorflow-benchmark"
    TF_CSV_PATH="${TF_OUT_DIR}/results.csv"
    TF_EVIDENCE_DIR="${TF_OUT_DIR}"
    TF_RAW_LOG="${RESULTS_DIR}/benchmark_raw.log"
    TF_IMAGE_SHA256_FILE="${PERF_WORK_DIR}/image.sha256"
    TF_SOURCE_COMMIT_FILE="${PERF_WORK_DIR}/source-commit.txt"
    TF_ASSET_SHA256_FILE="${PERF_WORK_DIR}/assets.sha256"
    TF_CONTAINER_NAME="boostkit-tensorflow-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID
    export PERF_WORK_DIR RESULTS_DIR PERF_ACTUAL_VERSION_FILE
    export TF_ASSET_DIR TF_IMAGE_TAR TF_BENCH_ARCHIVE TF_IMAGE
    export TF_MODEL TF_RUN_MODES TF_QPS_LIST TF_WARMUP TF_DURATION
    export TF_THREAD_NUM TF_CLIENT_THREAD_NUM TF_MAX_INFLIGHT
    export TF_REQUEST_MIN_BATCH_SIZE TF_REQUEST_MAX_BATCH_SIZE
    export TF_OUT_DIR TF_CSV_PATH TF_EVIDENCE_DIR TF_RAW_LOG
    export TF_SOURCE_DIR TF_ASSET_ROOT TF_MODEL_DIR TF_DATA_FILE
    export TF_CONTAINER_NAME
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TF_OUT_DIR}" "${TF_EVIDENCE_DIR}" \
        "${PERF_WORK_DIR}/tmp" "${PERF_WORK_DIR}/home" "${PERF_WORK_DIR}/assets"
}

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else
        "$@"
    fi
}

require_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log 'ERROR: an accessible Docker daemon is required for the TensorFlow benchmark'
        return 30
    fi
}

require_host_commands() {
    local command_name
    for command_name in docker curl tar sha256sum python3 git; do
        command -v "${command_name}" >/dev/null 2>&1 || {
            log "ERROR: required host command is missing: ${command_name}"
            return 30
        }
    done
}

load_tensorflow_image() {
    if docker image inspect "${TF_IMAGE}" >/dev/null 2>&1; then
        log "using already loaded image ${TF_IMAGE}"
    else
        [[ -s "${TF_IMAGE_TAR}" ]] || {
            log "ERROR: benchmark image archive is missing: ${TF_IMAGE_TAR}"
            return 30
        }
        log "loading benchmark image ${TF_IMAGE_TAR}"
        docker load --input "${TF_IMAGE_TAR}" >/dev/null || return 30
        docker image inspect "${TF_IMAGE}" >/dev/null 2>&1 || {
            log "ERROR: loaded image is not inspectable as ${TF_IMAGE}"
            return 30
        }
    fi
    sha256sum "${TF_IMAGE_TAR}" | tee "${TF_IMAGE_SHA256_FILE}" >/dev/null
    TF_IMAGE_SHA256="$(awk '{print $1}' "${TF_IMAGE_SHA256_FILE}")"
}

require_tensorflow_container() {
    require_docker || return $?
    if docker container inspect "${TF_CONTAINER_NAME}" >/dev/null 2>&1; then
        log "ERROR: refusing to reuse existing container: ${TF_CONTAINER_NAME}"
        return 40
    fi
    load_tensorflow_image || return $?
    [[ -d "${TF_ASSET_DIR}" ]] || {
        log "ERROR: asset directory is missing: ${TF_ASSET_DIR}"
        return 30
    }
    log "starting single privileged TensorFlow container ${TF_CONTAINER_NAME} (cpuset 0-15, 128g)"
    docker run --detach --name "${TF_CONTAINER_NAME}" \
        --label "boostkit.tensorflow.run-id=${PERF_RUN_ID}" \
        --network=host --privileged --user "$(id -u):$(id -g)" \
        --cpuset-cpus=0-15 --memory=128g \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${TF_ASSET_DIR},target=${TF_ASSET_DIR},readonly" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${TF_IMAGE}" sleep infinity >/dev/null || return 40
}

check_tensorflow_container() {
    [[ "$(docker inspect --format '{{.State.Running}}' "${TF_CONTAINER_NAME}" 2>/dev/null)" == true ]] || {
        log "ERROR: managed TensorFlow container is not running: ${TF_CONTAINER_NAME}"
        return 40
    }
    [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.tensorflow.run-id"}}' "${TF_CONTAINER_NAME}")" == "${PERF_RUN_ID}" ]] || {
        log 'ERROR: TensorFlow container label does not belong to this task'
        return 40
    }
}

container_exec() {
    local -a proxy=()
    if [[ -n "${PERF_PROXY:-}" ]]; then
        proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}")
    fi
    docker exec "${proxy[@]}" -e "TMPDIR=${PERF_WORK_DIR}/tmp" \
        -e "HOME=${PERF_WORK_DIR}/home" "${TF_CONTAINER_NAME}" "$@"
}

remove_tensorflow_container() {
    if ! docker container inspect "${TF_CONTAINER_NAME}" >/dev/null 2>&1; then
        return 0
    fi
    local label
    label="$(docker inspect --format '{{index .Config.Labels "boostkit.tensorflow.run-id"}}' "${TF_CONTAINER_NAME}" 2>/dev/null || true)"
    [[ "${label}" == "${PERF_RUN_ID}" ]] || {
        log 'ERROR: refusing to remove a container without this task label'
        return 70
    }
    docker stop --time 30 "${TF_CONTAINER_NAME}" >/dev/null || return 70
    docker rm "${TF_CONTAINER_NAME}" >/dev/null || return 70
    log "removed managed TensorFlow container ${TF_CONTAINER_NAME}"
}
