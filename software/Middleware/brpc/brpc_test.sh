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

log_message() {
    printf '[brpc] %s\n' "$*"
}

configure_runtime_paths() {
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    }
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64) EXPECTED_ARCH="x86_64" ;;
        aarch64|arm64) EXPECTED_ARCH="aarch64" ;;
        *) EXPECTED_ARCH="${EXPECTED_ARCH,,}" ;;
    esac
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
    local runner_architecture

    configure_runtime_paths
    runner_architecture="$(uname -m)"
    [[ "${runner_architecture}" == "${EXPECTED_ARCH}" ]] || {
        log_message "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    }
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR:-${PERF_WORK_DIR}/tmp}"
}

require_brpc_dependencies() {
    local required package library header
    local packages=()

    for required in git cmake make gcc g++ protoc python3 curl tar sed grep install tee nproc; do
        if command -v "${required}" >/dev/null 2>&1; then
            continue
        fi
        case "${required}" in
            git) package="git" ;;
            cmake) package="cmake" ;;
            make) package="make" ;;
            gcc) package="gcc" ;;
            g++) package="gcc-c++" ;;
            protoc) package="protobuf-compiler" ;;
            python3) package="python3" ;;
            curl) package="curl" ;;
            tar) package="tar" ;;
            sed) package="sed" ;;
            grep) package="grep" ;;
            install|tee|nproc) package="coreutils" ;;
        esac
        log_message "missing required BRPC build command: ${required}"
        packages+=("${package}")
    done

    # BRPC links against these system libraries.  Test the headers instead of
    # assuming that a package name proves the compiler can use the library.
    for library in openssl gflags leveldb protobuf; do
        case "${library}" in
            openssl) header="openssl/ssl.h"; package="openssl-devel" ;;
            gflags) header="gflags/gflags.h"; package="gflags-devel" ;;
            leveldb) header="leveldb/db.h"; package="leveldb-devel" ;;
            protobuf) header="google/protobuf/message.h"; package="protobuf-devel" ;;
        esac
        if ! printf '#include <%s>\nint main(){return 0;}\n' "${header}" \
            | g++ -x c++ -fsyntax-only - 2>/dev/null; then
            log_message "missing required BRPC development headers: ${library}"
            packages+=("${package}")
        fi
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log_message "ERROR: dnf is required to install BRPC build prerequisites"
        return 30
    fi
    log_message "installing missing BRPC build packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log_message "ERROR: sudo is required to install BRPC build prerequisites"
        return 30
    elif ! sudo -n dnf install -y "${packages[@]}"; then
        log_message "ERROR: failed to install BRPC build prerequisites"
        return 30
    fi

    for required in git cmake make gcc g++ protoc python3 curl tar sed grep install tee nproc; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            log_message "ERROR: required BRPC build command remains unavailable: ${required}"
            return 30
        fi
    done
    for library in openssl gflags leveldb protobuf; do
        case "${library}" in
            openssl) header="openssl/ssl.h" ;;
            gflags) header="gflags/gflags.h" ;;
            leveldb) header="leveldb/db.h" ;;
            protobuf) header="google/protobuf/message.h" ;;
        esac
        if ! printf '#include <%s>\nint main(){return 0;}\n' "${header}" \
            | g++ -x c++ -fsyntax-only - 2>/dev/null; then
            log_message "ERROR: required BRPC development headers remain unavailable: ${library}"
            return 30
        fi
    done
}

configure_http_example_for_modern_protobuf() {
    # BRPC 1.17 enables C++17 for Protobuf newer than 4.21 in its main CMake
    # project.  The independently configured http_c++ example still pins
    # C++11, which cannot compile against current Protobuf/Abseil headers.
    local example_cmake_file="${EXAMPLE_DIR}/CMakeLists.txt"
    local absl_cmake_file="${EXAMPLE_DIR}/brpc_http_example_absl.cmake"
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

    install -m 0644 "${SCRIPT_DIR}/http_example_absl.cmake" "${absl_cmake_file}" || {
        log_message "ERROR: could not provide the Abseil dependencies for the official HTTP example"
        return 40
    }
    sed -i \
        -e '/^[[:space:]]*include_directories(${OPENSSL_INCLUDE_DIR})[[:space:]]*$/a\include(${CMAKE_CURRENT_LIST_DIR}/brpc_http_example_absl.cmake)' \
        -e '/^[[:space:]]*${PROTOBUF_LIBRARIES}[[:space:]]*$/a\    ${BRPC_HTTP_EXAMPLE_ABSL_TARGETS}' \
        "${example_cmake_file}" || {
        log_message "ERROR: could not link Abseil for the official HTTP example"
        return 40
    }
    grep -Fq 'include(${CMAKE_CURRENT_LIST_DIR}/brpc_http_example_absl.cmake)' "${example_cmake_file}" \
        && grep -Fq '${BRPC_HTTP_EXAMPLE_ABSL_TARGETS}' "${example_cmake_file}" || {
        log_message "ERROR: the official HTTP example did not include the Abseil dependencies"
        return 40
    }
    log_message "configured the official HTTP example for current Protobuf and Abseil"
}

build_brpc() {
    local actual_version

    initialize_runtime || return $?
    require_brpc_dependencies || return $?
    [[ ! -e "${SOURCE_DIR}" && ! -e "${BUILD_DIR}" && ! -e "${SERVICE_DIR}" ]] || {
        log_message "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    }

    # The official getting_started.md builds BRPC with the default g++
    # toolchain.  Record the compiler actually used by this build.
    COMPILER_BINARY="g++"
    COMPILER_VERSION_STRING="$("${COMPILER_BINARY}" --version | head -n 1)"
    log_message "using compiler: ${COMPILER_BINARY} (${COMPILER_VERSION_STRING})"

    export GIT_TERMINAL_PROMPT=0
    log_message "cloning brpc ${SOFTWARE_VERSION} from ${BRPC_SOURCE_URL}"
    git clone --branch "${SOFTWARE_VERSION}" --depth 1 \
        "${BRPC_SOURCE_URL}" "${SOURCE_DIR}" || {
        log_message "ERROR: failed to clone brpc ${SOFTWARE_VERSION}"
        return 30
    }

    # The server binary has no --version switch.  RELEASE_VERSION from the
    # checked-out release is the authoritative version evidence.
    actual_version="$(<"${SOURCE_DIR}/RELEASE_VERSION")"
    actual_version="${actual_version//[[:space:]]/}"
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: source RELEASE_VERSION '${actual_version}' does not match ${SOFTWARE_VERSION}"
        return 40
    }
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40

    configure_http_example_for_modern_protobuf || return $?

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
    local server_pid attempt

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
    server_pid=$!
    printf '%s\n' "${server_pid}" > "${SERVER_PID_FILE}"
    for ((attempt = 0; attempt < 60; attempt += 1)); do
        if curl -fsS -o /dev/null "http://127.0.0.1:${HTTP_SERVER_PORT}/status" 2>/dev/null; then
            break
        fi
        sleep 1
    done
    if ! curl -fsS -o /dev/null "http://127.0.0.1:${HTTP_SERVER_PORT}/status"; then
        terminate_process_gracefully "${server_pid}" "official http_server" || true
        log_message "ERROR: official http_server did not become ready on port ${HTTP_SERVER_PORT}"
        return 40
    fi
    log_message "official http_server is ready (pid ${server_pid})"
}

run_brpc_benchmark_http() {
    local warmup_pid client_pid server_pid

    initialize_runtime || return $?
    [[ -x "${BENCHMARK_HTTP_BIN}" ]] || {
        log_message "ERROR: official benchmark_http binary is unavailable: ${BENCHMARK_HTTP_BIN}"
        return 40
    }
    server_pid="$(read_pid_file "${SERVER_PID_FILE}")"
    process_is_alive "${server_pid}" || {
        log_message "ERROR: official http_server (pid ${server_pid:-unknown}) is not running"
        return 40
    }
    curl -fsS -o /dev/null "http://127.0.0.1:${HTTP_SERVER_PORT}/status" || {
        log_message "ERROR: official http_server is not responding on port ${HTTP_SERVER_PORT}"
        return 40
    }
    port_is_free "${BENCHMARK_DUMMY_PORT}" || {
        log_message "ERROR: dummy port ${BENCHMARK_DUMMY_PORT} is already in use"
        return 20
    }
    log_message "warming up official benchmark_http for ${BENCHMARK_HTTP_WARMUP_S}s; warmup metrics will be discarded"
    nohup "${BENCHMARK_HTTP_BIN}" \
        -thread_num "${BENCHMARK_HTTP_THREAD_NUM}" \
        -url "127.0.0.1:${HTTP_SERVER_PORT}/HttpService/Echo" \
        -dummy_port "${BENCHMARK_DUMMY_PORT}" \
        >"${CLIENT_LOG_FILE}" 2>&1 &
    warmup_pid=$!
    printf '%s\n' "${warmup_pid}" > "${CLIENT_PID_FILE}"

    sleep "${BENCHMARK_HTTP_WARMUP_S}"
    process_is_alive "${warmup_pid}" || {
        log_message "ERROR: official benchmark_http exited during warmup"
        return 50
    }

    terminate_process_gracefully "${warmup_pid}" "warmup benchmark_http" || return $?
    rm -f "${CLIENT_PID_FILE}"
    port_is_free "${BENCHMARK_DUMMY_PORT}" || {
        log_message "ERROR: warmup benchmark_http did not release dummy port ${BENCHMARK_DUMMY_PORT}"
        return 50
    }

    log_message "running measured official benchmark_http: ${BENCHMARK_HTTP_THREAD_NUM} threads for ${BENCHMARK_HTTP_DURATION_S}s"
    nohup "${BENCHMARK_HTTP_BIN}" \
        -thread_num "${BENCHMARK_HTTP_THREAD_NUM}" \
        -url "127.0.0.1:${HTTP_SERVER_PORT}/HttpService/Echo" \
        -dummy_port "${BENCHMARK_DUMMY_PORT}" \
        >"${CLIENT_LOG_FILE}" 2>&1 &
    client_pid=$!
    printf '%s\n' "${client_pid}" > "${CLIENT_PID_FILE}"

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

    grep -Eq '^client_qps[[:space:]]+:[[:space:]]+[0-9]+' "${RESULTS_DIR}/bvar_vars.txt" || {
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
                "${EXPECTED_ARCH}" \
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
        "${EXPECTED_ARCH}" \
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
