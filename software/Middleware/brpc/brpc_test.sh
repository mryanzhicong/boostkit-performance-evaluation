#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.17.0}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
BRPC_SOURCE_URL="${BRPC_SOURCE_URL:-https://github.com/apache/brpc.git}"
# Load parameters of the official benchmark_http client
# (docs/cn/benchmark_http.md; defaults of example/http_c++/benchmark_http.cpp).
BENCHMARK_HTTP_THREAD_NUM="${BENCHMARK_HTTP_THREAD_NUM:-50}"
BENCHMARK_HTTP_DURATION_S="${BENCHMARK_HTTP_DURATION_S:-60}"
BENCHMARK_HTTP_WARMUP_S="${BENCHMARK_HTTP_WARMUP_S:-5}"
HTTP_SERVER_PORT="${HTTP_SERVER_PORT:-18010}"
BENCHMARK_DUMMY_PORT="${BENCHMARK_DUMMY_PORT:-18888}"

SOURCE_DIR=""
BUILD_DIR=""
EXAMPLE_DIR=""
SERVICE_DIR=""
HTTP_SERVER_BIN=""
BENCHMARK_HTTP_BIN=""
SERVER_LOG_FILE=""
CLIENT_LOG_FILE=""
SERVER_PID_FILE=""
CLIENT_PID_FILE=""
COMPILER_BINARY=""
COMPILER_VERSION_STRING=""
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

log_message() { printf '[brpc] %s\n' "$*"; }

normalize_architecture() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

configure_runtime_paths() {
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    }
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/tmp/brpc-perf/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
        TMPDIR="${PERF_WORK_DIR}/tmp"
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/brpc-source"
    # The official example cmake discovers the brpc library by searching for
    # */output/include inside the source tree, so the library build directory
    # must stay inside the cloned source tree (the official getting_started.md
    # layout). Everything still lives under PERF_WORK_DIR.
    BUILD_DIR="${SOURCE_DIR}/build"
    EXAMPLE_DIR="${SOURCE_DIR}/example/http_c++"
    SERVICE_DIR="${PERF_WORK_DIR}/service"
    HTTP_SERVER_BIN="${EXAMPLE_DIR}/build/http_server"
    BENCHMARK_HTTP_BIN="${EXAMPLE_DIR}/build/benchmark_http"
    SERVER_LOG_FILE="${SERVICE_DIR}/http_server.log"
    CLIENT_LOG_FILE="${SERVICE_DIR}/benchmark_http.log"
    SERVER_PID_FILE="${SERVICE_DIR}/http_server.pid"
    CLIENT_PID_FILE="${SERVICE_DIR}/benchmark_http.pid"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
}

initialize_runtime() {
    configure_runtime_paths
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR:-${PERF_WORK_DIR}/tmp}"
}

require_commands() {
    local required missing=0
    for required in git cmake make gcc g++ protoc python3 curl tar sed grep tee nproc; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            log_message "ERROR: required command is missing: ${required}"
            missing=1
        fi
    done
    [[ "${missing}" -eq 0 ]]
}

check_system_dependencies() {
    # brpc links against system-installed openssl, gflags, leveldb and
    # protobuf; their development packages are required before building.
    local check missing=0
    local checks=(
        "openssl/openssl/ssl.h"
        "gflags/gflags/gflags.h"
        "leveldb/leveldb/db.h"
        "protobuf/google/protobuf/message.h"
    )
    for check in "${checks[@]}"; do
        local library="${check%%/*}" header="${check#*/}"
        if ! printf '#include <%s>\nint main(){return 0;}\n' "${header}" \
            | g++ -x c++ -fsyntax-only - 2>/dev/null; then
            log_message "ERROR: development headers for ${library} are missing"
            missing=1
        fi
    done
    [[ "${missing}" -eq 0 ]] || {
        log_message "ERROR: install the missing development packages before retrying"
        return 30
    }
}

check_architecture() {
    local actual expected
    actual="$(normalize_architecture "$(uname -m)")"
    expected="$(normalize_architecture "${EXPECTED_ARCH}")"
    [[ "${actual}" == "${expected}" ]] || {
        log_message "ERROR: expected architecture ${expected}, runner is ${actual}"
        return 20
    }
}

prepare_compiler() {
    # The official getting_started.md builds brpc with the default g++
    # toolchain; record the compiler actually used by the build.
    COMPILER_BINARY="g++"
    COMPILER_VERSION_STRING="$("${COMPILER_BINARY}" --version | head -n 1)"
    log_message "using compiler: ${COMPILER_BINARY} (${COMPILER_VERSION_STRING})"
}

prepare_brpc_source() {
    [[ ! -e "${SOURCE_DIR}" ]] || {
        log_message "ERROR: source directory already exists: ${SOURCE_DIR}"
        return 30
    }
    export GIT_TERMINAL_PROMPT=0
    log_message "cloning brpc ${SOFTWARE_VERSION} from ${BRPC_SOURCE_URL}"
    git clone --branch "${SOFTWARE_VERSION}" --depth 1 \
        "${BRPC_SOURCE_URL}" "${SOURCE_DIR}" || {
        log_message "ERROR: failed to clone brpc ${SOFTWARE_VERSION}"
        return 30
    }
}

report_actual_version() {
    # The brpc server binary does not carry a --version flag; the
    # RELEASE_VERSION file shipped with the release tag is the authoritative
    # version evidence.
    local actual_version
    actual_version="$(<"${SOURCE_DIR}/RELEASE_VERSION")"
    actual_version="${actual_version//[[:space:]]/}"
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: source RELEASE_VERSION '${actual_version}' does not match ${SOFTWARE_VERSION}"
        return 40
    }
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40
}

enable_modern_cxx_for_http_example() {
    # BRPC 1.17 enables C++17 for Protobuf newer than 4.21 in its main CMake
    # project.  The independently configured http_c++ example still pins
    # C++11, which cannot compile against current Protobuf/Abseil headers.
    local example_cmake_file="${EXAMPLE_DIR}/CMakeLists.txt"
    [[ -f "${example_cmake_file}" ]] || {
        log_message "ERROR: official HTTP example CMake file is missing: ${example_cmake_file}"
        return 40
    }
    sed -i 's/set(CMAKE_CXX_STANDARD 11)/set(CMAKE_CXX_STANDARD 17)/' \
        "${example_cmake_file}" || {
        log_message "ERROR: could not enable C++17 for the official HTTP example"
        return 40
    }
    grep -Fq 'set(CMAKE_CXX_STANDARD 17)' "${example_cmake_file}" || {
        log_message "ERROR: the official HTTP example C++11 setting was not found"
        return 40
    }
    log_message "enabled C++17 for the official HTTP example to match the installed Protobuf"
}

build_brpc() {
    initialize_runtime || return $?
    check_architecture || return $?
    require_commands || return $?
    [[ ! -e "${SOURCE_DIR}" && ! -e "${BUILD_DIR}" && ! -e "${SERVICE_DIR}" ]] || {
        log_message "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    }
    check_system_dependencies || return $?
    prepare_compiler || return $?
    prepare_brpc_source || return $?
    report_actual_version || return $?
    enable_modern_cxx_for_http_example || return $?

    log_message "building the official brpc library with cmake (Release)"
    mkdir -p "${BUILD_DIR}"
    cmake -S "${SOURCE_DIR}" -B "${BUILD_DIR}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DWITH_DEBUG_SYMBOLS=OFF \
        -DBUILD_BRPC_TOOLS=OFF || {
        log_message "ERROR: cmake configure of the brpc library failed"
        return 40
    }
    cmake --build "${BUILD_DIR}" -j "$(nproc)" || {
        log_message "ERROR: cmake build of the brpc library failed"
        return 40
    }
    [[ -f "${BUILD_DIR}/output/lib/libbrpc.a" ]] || {
        log_message "ERROR: official libbrpc.a was not produced under ${BUILD_DIR}/output/lib"
        return 40
    }

    # The example cmake auto-discovers the sibling build/output directory, so
    # configure example/http_c++ as its own project from the source root.
    log_message "building official example binaries: benchmark_http and http_server"
    mkdir -p "${EXAMPLE_DIR}/build"
    cmake -S "${EXAMPLE_DIR}" -B "${EXAMPLE_DIR}/build" \
        -DCMAKE_BUILD_TYPE=Release || {
        log_message "ERROR: cmake configure of example/http_c++ failed"
        return 40
    }
    cmake --build "${EXAMPLE_DIR}/build" -j "$(nproc)" \
        --target benchmark_http --target http_server || {
        log_message "ERROR: cmake build of benchmark_http/http_server failed"
        return 40
    }
    [[ -x "${HTTP_SERVER_BIN}" ]] || {
        log_message "ERROR: official http_server binary was not produced: ${HTTP_SERVER_BIN}"
        return 40
    }
    [[ -x "${BENCHMARK_HTTP_BIN}" ]] || {
        log_message "ERROR: official benchmark_http binary was not produced: ${BENCHMARK_HTTP_BIN}"
        return 40
    }
    log_message "brpc ${SOFTWARE_VERSION} official benchmark artifacts are ready"
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

wait_for_http_endpoint() {
    local url="$1" attempts=60
    while ((attempts > 0)); do
        if curl -fsS -o /dev/null "${url}" 2>/dev/null; then
            return 0
        fi
        sleep 1
        attempts=$((attempts - 1))
    done
    return 1
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

start_brpc_service() {
    initialize_runtime || return $?
    [[ -x "${HTTP_SERVER_BIN}" ]] || {
        log_message "ERROR: official http_server binary is unavailable: ${HTTP_SERVER_BIN}"
        return 40
    }
    [[ -e "${SERVICE_DIR}" ]] || mkdir -p "${SERVICE_DIR}"
    if process_is_alive "$(read_pid_file "${SERVER_PID_FILE}")"; then
        log_message "official http_server is already running"
        return 0
    fi
    port_is_free "${HTTP_SERVER_PORT}" || {
        log_message "ERROR: port ${HTTP_SERVER_PORT} is already in use"
        return 20
    }
    # The official example enables SSL with the repository's cert.pem/key.pem
    # (http_server.cpp always sets ssl options); plain HTTP requests are still
    # served, so benchmark_http keeps using plain HTTP against /HttpService/Echo.
    log_message "starting official example http_server on 127.0.0.1:${HTTP_SERVER_PORT}"
    nohup "${HTTP_SERVER_BIN}" \
        -port "${HTTP_SERVER_PORT}" \
        -certificate "${EXAMPLE_DIR}/cert.pem" \
        -private_key "${EXAMPLE_DIR}/key.pem" \
        >"${SERVER_LOG_FILE}" 2>&1 &
    local server_pid=$!
    printf '%s\n' "${server_pid}" > "${SERVER_PID_FILE}"
    if ! wait_for_http_endpoint "http://127.0.0.1:${HTTP_SERVER_PORT}/status"; then
        terminate_process_gracefully "${server_pid}" "official http_server" || true
        log_message "ERROR: official http_server did not become ready on port ${HTTP_SERVER_PORT}"
        return 40
    fi
    log_message "official http_server is ready (pid ${server_pid})"
}

verify_brpc_service_ready() {
    local server_pid
    server_pid="$(read_pid_file "${SERVER_PID_FILE}")"
    process_is_alive "${server_pid}" || {
        log_message "ERROR: official http_server (pid ${server_pid:-unknown}) is not running"
        return 40
    }
    curl -fsS -o /dev/null "http://127.0.0.1:${HTTP_SERVER_PORT}/status" || {
        log_message "ERROR: official http_server is not responding on port ${HTTP_SERVER_PORT}"
        return 40
    }
}

run_brpc_benchmark_http() {
    initialize_runtime || return $?
    [[ -x "${BENCHMARK_HTTP_BIN}" ]] || {
        log_message "ERROR: official benchmark_http binary is unavailable: ${BENCHMARK_HTTP_BIN}"
        return 40
    }
    verify_brpc_service_ready || return $?
    port_is_free "${BENCHMARK_DUMMY_PORT}" || {
        log_message "ERROR: dummy port ${BENCHMARK_DUMMY_PORT} is already in use"
        return 20
    }
    log_message "running official benchmark_http: ${BENCHMARK_HTTP_THREAD_NUM} threads for ${BENCHMARK_HTTP_DURATION_S}s"
    nohup "${BENCHMARK_HTTP_BIN}" \
        -thread_num "${BENCHMARK_HTTP_THREAD_NUM}" \
        -url "127.0.0.1:${HTTP_SERVER_PORT}/HttpService/Echo" \
        -dummy_port "${BENCHMARK_DUMMY_PORT}" \
        >"${CLIENT_LOG_FILE}" 2>&1 &
    local client_pid=$!
    printf '%s\n' "${client_pid}" > "${CLIENT_PID_FILE}"

    sleep "${BENCHMARK_HTTP_WARMUP_S}"
    process_is_alive "${client_pid}" || {
        log_message "ERROR: official benchmark_http exited during warmup"
        return 50
    }
    sleep "${BENCHMARK_HTTP_DURATION_S}"
    process_is_alive "${client_pid}" || {
        log_message "ERROR: official benchmark_http exited before the duration elapsed"
        return 50
    }

    # The client exposes its bvar counters (client_qps, client_latency_*)
    # through the dummy server; dump them verbatim as the raw result source.
    curl -fsS "http://127.0.0.1:${BENCHMARK_DUMMY_PORT}/vars/client_*" \
        -o "${RESULTS_DIR}/bvar_vars.txt" || {
        terminate_process_gracefully "${client_pid}" "official benchmark_http" || true
        log_message "ERROR: failed to dump client bvar values from the dummy server"
        return 50
    }
    terminate_process_gracefully "${client_pid}" "official benchmark_http" || return $?
    rm -f "${CLIENT_PID_FILE}"

    grep -Eq 'client_qps +[0-9]+' "${RESULTS_DIR}/bvar_vars.txt" || {
        log_message "ERROR: bvar dump is missing client_qps"
        return 50
    }
    export SOFTWARE_VERSION EXPECTED_ARCH BENCHMARK_HTTP_THREAD_NUM
    export BENCHMARK_HTTP_DURATION_S BENCHMARK_HTTP_WARMUP_S HTTP_SERVER_PORT
    python3 "${SCRIPT_DIR}/scripts/parse_benchmark.py" \
        "${RESULTS_DIR}/bvar_vars.txt" \
        "${RESULTS_DIR}/benchmark_brpc.json" || {
        log_message "ERROR: failed to normalize official bvar benchmark results"
        return 50
    }
    log_message "brpc benchmark results written to bvar_vars.txt and benchmark_brpc.json"
}

stop_brpc_service() {
    configure_runtime_paths || return $?
    local stop_status=0 client_pid server_pid
    client_pid="$(read_pid_file "${CLIENT_PID_FILE}")"
    if process_is_alive "${client_pid}"; then
        terminate_process_gracefully "${client_pid}" "official benchmark_http" || stop_status=1
    fi
    rm -f "${CLIENT_PID_FILE}"
    server_pid="$(read_pid_file "${SERVER_PID_FILE}")"
    if process_is_alive "${server_pid}"; then
        terminate_process_gracefully "${server_pid}" "official http_server" || stop_status=1
    fi
    rm -f "${SERVER_PID_FILE}"
    if [[ -n "${server_pid}" ]] && port_is_free "${HTTP_SERVER_PORT}"; then
        log_message "official http_server has stopped"
    elif [[ -n "${server_pid}" ]]; then
        log_message "ERROR: port ${HTTP_SERVER_PORT} is still occupied after stop"
        stop_status=1
    else
        log_message "brpc benchmark has no running service to stop"
    fi
    return "${stop_status}"
}

standalone_runtime() {
    python3 "${SCRIPT_DIR}/scripts/standalone_runtime.py" "$@"
}

cleanup_standalone_workdir() {
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 1 ]]; then
        log_message "keeping standalone work directory: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${STANDALONE_OWNS_WORK_DIR}" -ne 1 ]]; then
        log_message "external work directory was not removed: ${PERF_WORK_DIR}"
        return 0
    fi
    [[ "${PERF_WORK_DIR}" == /tmp/brpc-perf/local-* && \
       "${PERF_WORK_DIR}" != "/tmp/brpc-perf" ]] || {
        log_message "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    }
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        rm -rf -- "${PERF_WORK_DIR}" || return 70
    fi
    log_message "cleaned standalone work directory: ${PERF_WORK_DIR}"
}

emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then
        stop_brpc_service
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_brpc_standalone() {
    local stage_status=0 failed_stage="" cleanup_status="passed" finalize_status=0
    local command_status="passed"

    configure_runtime_paths || return $?
    STANDALONE_STOP_DONE=0
    STANDALONE_CLEANUP_DONE=0
    trap emergency_standalone_cleanup EXIT
    initialize_runtime || return $?

    if standalone_runtime system "${RESULTS_DIR}/system_info.json" && \
        standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json"; then
        :
    else
        stage_status=$?
        failed_stage="prepare"
    fi

    if [[ "${stage_status}" -eq 0 ]]; then
        if build_brpc; then
            if standalone_runtime build-info \
                "${RESULTS_DIR}/build_info.json" \
                "${SOFTWARE_VERSION}" \
                "${PERF_ACTUAL_VERSION_FILE}" \
                "$(normalize_architecture "${EXPECTED_ARCH}")" \
                "${PERF_RUN_ID}" \
                "${COMPILER_BINARY}" \
                "${COMPILER_VERSION_STRING}"; then
                :
            else
                stage_status=$?
                failed_stage="build"
            fi
        else
            stage_status=$?
            failed_stage="build"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if start_brpc_service; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_brpc_benchmark_http; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_brpc_service; then
        cleanup_status="failed"
    fi
    STANDALONE_STOP_DONE=1
    if ! standalone_runtime runtime "${RESULTS_DIR}/runtime_after.json"; then
        cleanup_status="failed"
    fi
    if ! cleanup_standalone_workdir; then
        cleanup_status="failed"
    fi
    STANDALONE_CLEANUP_DONE=1

    if [[ "${stage_status}" -ne 0 ]]; then
        command_status="failed"
    fi
    if standalone_runtime finalize \
        "${RESULTS_DIR}" \
        "${SOFTWARE_VERSION}" \
        "$(normalize_architecture "${EXPECTED_ARCH}")" \
        "${PERF_RUN_ID}" \
        "${command_status}" \
        "${cleanup_status}" \
        "${failed_stage}"; then
        finalize_status=0
    else
        finalize_status=$?
    fi
    trap - EXIT
    [[ "${stage_status}" -eq 0 ]] || return "${stage_status}"
    [[ "${cleanup_status}" == "passed" ]] || return 70
    return "${finalize_status}"
}

usage() {
    cat <<USAGE
Usage: $(basename "$0") [OPTIONS]

Build and run brpc's official benchmark_http (example/http_c++) against the
official example http_server as a standalone performance evaluation. Results
default to results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       brpc version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR, BRPC_SOURCE_URL,
  BENCHMARK_HTTP_THREAD_NUM, BENCHMARK_HTTP_DURATION_S, BENCHMARK_HTTP_WARMUP_S,
  HTTP_SERVER_PORT, BENCHMARK_DUMMY_PORT
USAGE
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --version requires a value"; return 10; }
                SOFTWARE_VERSION="$2"
                shift 2
                ;;
            --results-dir)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --results-dir requires a value"; return 10; }
                RESULTS_DIR="$2"
                shift 2
                ;;
            --keep-workdir)
                STANDALONE_KEEP_WORK_DIR=1
                shift
                ;;
            -h|--help)
                usage
                return 0
                ;;
            *)
                log_message "ERROR: unsupported option: $1"
                usage
                return 10
                ;;
        esac
    done

    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" || return $?
    : > "${RESULTS_DIR}/results.log"
    local pipeline_status=0
    set +e
    run_brpc_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log_message "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
