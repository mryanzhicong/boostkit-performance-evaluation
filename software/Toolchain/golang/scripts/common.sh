#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.26.9}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

GO_RELEASE_URL="${GO_RELEASE_URL:-https://go.dev/dl}"
GO_OFFLINE_DIR="${GO_OFFLINE_DIR:-/home/runner/software/golang}"
BENT_MODULE_CACHE_DIR="${BENT_MODULE_CACHE_DIR:-${GO_OFFLINE_DIR}/bent-modules}"
GO_RUNTIME_ROOT="${GO_RUNTIME_ROOT:-}"
BENT_MODULE_VERSION="v0.0.0-20261009192853-4a545adeb0d5"

GO_INSTALL_DIR=""
GO_BIN=""
GO_ARCH=""
GO_RUNTIME_DIR=""
GCC_VERSION_STRING=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"

log_message() {
    printf '[golang] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64)
            EXPECTED_ARCH="x86_64"
            GO_ARCH="amd64"
            ;;
        aarch64|arm64)
            EXPECTED_ARCH="aarch64"
            GO_ARCH="arm64"
            ;;
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
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/golang/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    if [[ -z "${GO_RUNTIME_ROOT}" ]]; then
        GO_RUNTIME_ROOT="${PERF_WORK_DIR}/runtime"
    fi
    GO_RUNTIME_DIR="${GO_RUNTIME_ROOT}"
    GO_INSTALL_DIR="${PERF_WORK_DIR}/go-install"
    GO_BIN="${GO_INSTALL_DIR}/bin/go"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    if ! mkdir -p "${GO_RUNTIME_DIR}/tmp"; then
        log_message "ERROR: cannot create the Go runtime directory: ${GO_RUNTIME_DIR}"
        return 30
    fi
    export TMPDIR="${GO_RUNTIME_DIR}/tmp"
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

configure_go_environment() {
    export GOROOT="${GO_INSTALL_DIR}"
    # Bent invokes the Go command by its basename while it prepares each
    # official benchmark module.  Make this task's Go installation available
    # to those child processes instead of relying on a runner-wide Go command.
    export PATH="${GO_INSTALL_DIR}/bin:${PATH}"
    export GOCACHE="${GO_RUNTIME_DIR}/go-cache"
    export GOMODCACHE="${GO_RUNTIME_DIR}/go-mod-cache"
    export GOPATH="${GO_RUNTIME_DIR}/gopath"
    export GOTOOLCHAIN=local
    export GOENV=off
    export GOWORK=off
    if [[ "${PERF_DIRECT_NETWORK:-}" == "true" ]]; then
        export GOPROXY=direct
    else
        export GOPROXY="https://repo.huaweicloud.com/repository/goproxy/|https://goproxy.cn"
    fi
    export GOSUMDB="${GOSUMDB:-sum.golang.org}"
    unset GOFLAGS GO111MODULE GOOS GOARCH GOARM GOARM64 GOAMD64 GOEXPERIMENT
}
