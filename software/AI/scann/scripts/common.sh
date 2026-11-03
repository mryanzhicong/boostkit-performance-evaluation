#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.4.2}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
SCANN_DATA_ROOT="${SCANN_DATA_ROOT:-/home/runner/software/scann/data}"
SCANN_WHEEL_ROOT="${SCANN_WHEEL_ROOT:-/home/runner/software/scann/wheels}"
SCANN_CA_ANCHORS_DIR="${SCANN_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
readonly ANNB_REVISION="2e081ad32c1eccab72dcb739ad886c310b90f715"
readonly SCANN_DATASETS=(
    fashion-mnist-784-euclidean sift-128-euclidean glove-100-angular
    gist-960-euclidean deep-image-96-angular
)
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"

log() { printf '[scann] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

configure_runtime_paths() {
    [[ "${SOFTWARE_VERSION}" == 1.4.2 ]] || { log 'ERROR: only ScaNN 1.4.2 is supported'; return 10; }
    case "${PERF_VARIANT}" in base|optimized) ;; *) log 'ERROR: invalid build variant'; return 10 ;; esac
    PERF_RUN_ID="${PERF_RUN_ID:-local-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || { log 'ERROR: invalid run ID'; return 10; }
    EXPECTED_ARCH="$(normalize_arch "${EXPECTED_ARCH}")"
    case "${EXPECTED_ARCH}" in x86_64|aarch64) ;; *) log 'ERROR: unsupported architecture'; return 10 ;; esac
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/scann/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    elif [[ "${PERF_WORK_DIR}" != /* ]]; then
        log 'ERROR: PERF_WORK_DIR must be absolute'; return 10
    fi
    [[ "${PERF_WORK_DIR}" != / && "${PERF_WORK_DIR}" != /home/runner && \
       "${PERF_WORK_DIR}" != /home/runner/boostkit-perf ]] || {
        log 'ERROR: PERF_WORK_DIR is too broad'; return 10;
    }
    ANN_ROOT="${PERF_WORK_DIR}/ann-benchmarks"
    ANN_VENV="${PERF_WORK_DIR}/annb-venv"
    SCANN_IMAGE_TAG="ann-benchmarks-scann-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    export SOFTWARE_VERSION PERF_VARIANT EXPECTED_ARCH PERF_RUN_ID PERF_WORK_DIR RESULTS_DIR
    export ANN_ROOT ANN_VENV SCANN_IMAGE_TAG PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}" "${SCANN_DATA_ROOT}"
}

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        local bundle="${PERF_WORK_DIR}/proxy-ca.pem" system_ca=""
        local path
        [[ -d "${SCANN_CA_ANCHORS_DIR}" ]] || {
            log "ERROR: proxy CA anchors are missing: ${SCANN_CA_ANCHORS_DIR}"; return 30;
        }
        if [[ ! -s "${bundle}" ]]; then
            for path in /etc/pki/tls/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt; do
                if [[ -s "${path}" ]]; then system_ca="${path}"; break; fi
            done
            [[ -n "${system_ca}" ]] || { log 'ERROR: system CA bundle is missing'; return 30; }
            cp -- "${system_ca}" "${bundle}" || return 30
            local found=0
            shopt -s nullglob
            for path in "${SCANN_CA_ANCHORS_DIR}"/*.crt "${SCANN_CA_ANCHORS_DIR}"/*.pem; do
                printf '\n' >> "${bundle}"
                cat -- "${path}" >> "${bundle}" || return 30
                found=1
            done
            shopt -u nullglob
            [[ "${found}" -eq 1 ]] || { log 'ERROR: proxy CA anchors are empty'; return 30; }
        fi
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" \
            GIT_SSL_CAINFO="${bundle}" CURL_CA_BUNDLE="${bundle}" \
            PIP_CERT="${bundle}" REQUESTS_CA_BUNDLE="${bundle}" "$@"
    else
        "$@"
    fi
}

verify_scann_image() {
    docker image inspect "${SCANN_IMAGE_TAG}" >/dev/null 2>&1 || {
        log 'ERROR: private ScaNN image is unavailable'; return 40;
    }
    local actual
    actual="$(docker run --rm --entrypoint python "${SCANN_IMAGE_TAG}" -c \
        'from importlib.metadata import version; import scann; print(version("scann"))')" || return 40
    [[ "${actual}" == 1.4.2 ]] || { log "ERROR: image contains ScaNN ${actual}"; return 40; }
}
