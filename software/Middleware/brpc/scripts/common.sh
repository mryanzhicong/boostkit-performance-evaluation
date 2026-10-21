#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.17.0}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
BRPC_SOURCE_URL="${BRPC_SOURCE_URL:-https://github.com/apache/brpc.git}"
RDMA_SERVER_PORT=8003
RDMA_CLIENT_DUMMY_PORT=8001
BRPC_ATTACHMENT_SIZES=(0 1024 4096 8192 102400 204800 1048576 8388608)
BRPC_REPETITIONS=5
BRPC_MAX_INFLIGHT_ATTACHMENT_BYTES=$((32 * 1024 * 1024))
BRPC_MAX_CLIENT_THREADS=32
BRPC_MAX_QUEUE_DEPTH=32

SOURCE_DIR=""
BUILD_DIR=""
EXAMPLE_DIR=""
SERVICE_DIR=""
RDMA_SERVER_BIN=""
RDMA_CLIENT_BIN=""
SERVER_LOG_FILE=""
CLIENT_LOG_FILE=""
SERVER_PID_FILE=""
COMPILER_BINARY=""
COMPILER_VERSION_STRING=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[brpc] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    }
    EXPECTED_ARCH="$(normalize_architecture "${EXPECTED_ARCH}")"
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/brpc/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/brpc-source"
    # The upstream example discovers */output/include inside the source tree.
    BUILD_DIR="${SOURCE_DIR}/build"
    EXAMPLE_DIR="${SOURCE_DIR}/example/rdma_performance"
    SERVICE_DIR="${PERF_WORK_DIR}/service"
    RDMA_SERVER_BIN="${EXAMPLE_DIR}/build/server"
    RDMA_CLIENT_BIN="${EXAMPLE_DIR}/build/client"
    SERVER_LOG_FILE="${SERVICE_DIR}/server.log"
    CLIENT_LOG_FILE="${RESULTS_DIR}/benchmark_client.log"
    SERVER_PID_FILE="${SERVICE_DIR}/server.pid"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
}

initialize_runtime() {
    local runner_architecture

    configure_runtime_paths
    runner_architecture="$(uname -m)"
    [[ "${runner_architecture}" == "${EXPECTED_ARCH}" ]] || {
        log_message "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    }
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

port_is_free() {
    python3 - "$1" <<'PYEOF'
import socket
import sys

port = int(sys.argv[1])
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        sock.bind(("127.0.0.1", port))
    except OSError:
        sys.exit(1)
PYEOF
}

process_is_alive() {
    [[ -n "$1" && "$1" =~ ^[0-9]+$ ]] && kill -0 "$1" 2>/dev/null
}

read_pid_file() {
    local pid_file="$1"
    [[ -f "${pid_file}" ]] || return 0
    local pid
    pid="$(<"${pid_file}")"
    pid="${pid//[[:space:]]/}"
    [[ "${pid}" =~ ^[0-9]+$ ]] && printf '%s\n' "${pid}"
}

terminate_process_gracefully() {
    local pid="$1" name="$2" waited=0
    process_is_alive "${pid}" || return 0
    kill -TERM "${pid}" 2>/dev/null || true
    while process_is_alive "${pid}" && ((waited < 15)); do
        sleep 1
        waited=$((waited + 1))
    done
    if process_is_alive "${pid}"; then
        kill -KILL "${pid}" 2>/dev/null || true
        sleep 1
    fi
    if process_is_alive "${pid}"; then
        log_message "ERROR: ${name} (pid ${pid}) is still alive"
        return 1
    fi
    return 0
}
