#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.15.2}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
SONIC_GO_SOURCE_URL="${SONIC_GO_SOURCE_URL:-https://github.com/bytedance/sonic.git}"
SONIC_GO_PROXY="${SONIC_GO_PROXY:-https://repo.huaweicloud.com/repository/goproxy/|https://goproxy.cn}"
GO_SRC_VERSION="${GO_SRC_VERSION:-1.24.6}"
GO_SOURCE_URL="${GO_SOURCE_URL:-https://gitcode.com/openeuler/golang.git}"
GO_SRC_BRANCH="go${GO_SRC_VERSION}"
TOOLCHAIN_TARGET="${TOOLCHAIN_TARGET:-go${GO_SRC_VERSION}-default}"
GO_BOOTSTRAP_VERSION="${GO_BOOTSTRAP_VERSION:-1.27.0}"
GO_RELEASE_URL="${GO_RELEASE_URL:-https://go.dev/dl}"
GO_OFFLINE_DIR="${GO_OFFLINE_DIR:-/home/runner/software/golang}"

SOURCE_DIR=""
OBJECTS_DIR=""
TOOLCHAIN_DIR=""
GO_BIN=""
GO_ARCH=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[sonic-go] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    local expected_arch
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64)
            expected_arch="x86_64"
            GO_ARCH="amd64"
            ;;
        aarch64|arm64)
            expected_arch="aarch64"
            GO_ARCH="arm64"
            ;;
        *)
            log_message "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    EXPECTED_ARCH="${expected_arch}"

    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    }
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/sonic-go/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi

    OBJECTS_DIR="${PERF_WORK_DIR}/objects"
    SOURCE_DIR="${OBJECTS_DIR}/go/src/sonic"
    TOOLCHAIN_DIR="${OBJECTS_DIR}/go/bin/${TOOLCHAIN_TARGET}"
    GO_BIN="${TOOLCHAIN_DIR}/bin/go"
    TMPDIR="${PERF_WORK_DIR}/tmp"

    # Go 环境隔离：模块/GOPATH/临时目录全部落在 PERF_WORK_DIR；GOTOOLCHAIN=local
    # 禁止 go.mod 触发工具链自动下载；GOENV=off 屏蔽宿主机 go env 文件残留。
    # 显式清掉 GOROOT/GOWORK/GOFLAGS 的全局残留：
    #   GOROOT  残留会让自编译工具链错用宿主机 pkg/tool（版本错配）；
    #   GOWORK  残留 off 会与 sonic 自带 go.work 的 replace 冲突；
    #   GOFLAGS 残留（如 -mod=vendor）会破坏 sonic 的模块解析。
    unset GOROOT GOWORK GOFLAGS GOCACHE
    export GOMODCACHE="${PERF_WORK_DIR}/runtime/module-cache"
    export GOPATH="${PERF_WORK_DIR}/runtime/path"
    export GOPROXY="${SONIC_GO_PROXY}"
    export GOTOOLCHAIN=local
    export GOENV=off
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
    export SONIC_GO_BIN="${GO_BIN}" SONIC_GO_VERSION="${GO_SRC_VERSION}"
    export SONIC_GO_TOOLCHAIN="${TOOLCHAIN_TARGET}"
}

initialize_runtime() {
    configure_runtime_paths
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${GOMODCACHE}" "${GOPATH}"
}

verify_go_toolchain() {
    local actual_version

    if [[ ! -x "${GO_BIN}" ]]; then
        log_message "ERROR: built Go toolchain is unavailable: ${GO_BIN}"
        return 40
    fi
    actual_version="$("${GO_BIN}" version | awk '{print $3}' | sed 's/^go//')" || return 40
    if [[ "${actual_version}" != "${GO_SRC_VERSION}" ]]; then
        log_message "ERROR: built Go is ${actual_version}, expected ${GO_SRC_VERSION}"
        return 40
    fi
}
