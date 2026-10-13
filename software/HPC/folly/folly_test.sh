#!/usr/bin/env bash
# Compare upstream Folly using AccLibBenchmark's fbthrift RPC client/server.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-2022.11.14.00}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
FOLLY_SOURCE_URL="${FOLLY_SOURCE_URL:-https://github.com/facebook/folly.git}"
FAST_FLOAT_SOURCE_URL="${FAST_FLOAT_SOURCE_URL:-https://github.com/fastfloat/fast_float.git}"
FAST_FLOAT_VERSION="v8.2.10"
ACCLIB_SOURCE_ROOT="/home/runner/software/folly/AccLibBenchmark"
COMPILER_BINARY="g++"
COMPILER_VERSION_STRING=""
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0

log_message() { printf '[folly] %s\n' "$*"; }

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
        log_message "ERROR: PERF_RUN_ID contains unsafe characters"
        return 10
    }
    [[ -n "${RESULTS_DIR}" ]] || RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/folly/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    [[ -n "${PERF_ACTUAL_VERSION_FILE}" ]] || PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    SOURCE_DIR="${PERF_WORK_DIR}/folly-source"
    FAST_FLOAT_DIR="${PERF_WORK_DIR}/fast_float"
    BENCH_DIR="${PERF_WORK_DIR}/fbthrift_folly_benchmark"
    SERVER_BINARY="${BENCH_DIR}/build/press_server"
    CLIENT_BINARY="${BENCH_DIR}/build/press_client"
    SERVICE_DIR="${PERF_WORK_DIR}/service"
    export TMPDIR="${PERF_WORK_DIR}/tmp"
    local prefix="${PERF_WORK_DIR}/install"
    export LD_LIBRARY_PATH="${prefix}/fbthrift/lib:${prefix}/fbthrift/lib64:${prefix}/wangle/lib:${prefix}/wangle/lib64:${prefix}/fizz/lib:${prefix}/fizz/lib64:${prefix}/folly/lib:${prefix}/folly/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    [[ "$(normalize_architecture "$(uname -m)")" == "$(normalize_architecture "${EXPECTED_ARCH}")" ]] || {
        log_message "ERROR: runner architecture differs from ${EXPECTED_ARCH}"
        return 20
    }
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${SERVICE_DIR}"
}

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else
        "$@"
    fi
}

require_build_commands() {
    local required package
    local packages=()
    for required in git cmake make g++ python3 nproc rpm; do
        command -v "${required}" >/dev/null 2>&1 && continue
        case "${required}" in
            g++) package="gcc-c++" ;;
            nproc) package="coreutils" ;;
            *) package="${required}" ;;
        esac
        packages+=("${package}")
    done
    if ((${#packages[@]})); then
        local dnf_options=()
        [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
        command -v dnf >/dev/null 2>&1 || return 30
        if [[ "$(id -u)" -eq 0 ]]; then
            dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        else
            sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        fi
    fi
    for required in git cmake make g++ python3 nproc rpm; do
        command -v "${required}" >/dev/null 2>&1 || return 30
    done
}

prepare_folly_source() {
    [[ ! -e "${SOURCE_DIR}" ]] || { log_message "ERROR: existing source directory: ${SOURCE_DIR}"; return 40; }
    log_message "cloning upstream Folly v${SOFTWARE_VERSION}"
    with_network_proxy git clone --branch "v${SOFTWARE_VERSION}" --depth 1 \
        "${FOLLY_SOURCE_URL}" "${SOURCE_DIR}" || return 40
    [[ "$(git -C "${SOURCE_DIR}" describe --tags --exact-match)" == "v${SOFTWARE_VERSION}" ]] || return 40
    printf '%s\n' "${SOFTWARE_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}"
}

prepare_fast_float() {
    if printf '#include <fast_float/fast_float.h>\nint main(){return 0;}\n' \
        | g++ -x c++ -fsyntax-only - 2>/dev/null; then
        return 0
    fi
    log_message "fetching required upstream fast_float ${FAST_FLOAT_VERSION}"
    with_network_proxy git clone --branch "${FAST_FLOAT_VERSION}" --depth 1 \
        "${FAST_FLOAT_SOURCE_URL}" "${FAST_FLOAT_DIR}" || return 40
    [[ -f "${FAST_FLOAT_DIR}/include/fast_float/fast_float.h" ]] || return 40
}

build_folly() {
    initialize_runtime || return $?
    require_build_commands || return $?
    [[ -d "${ACCLIB_SOURCE_ROOT}/fbthrift_folly_benchmark" && \
       -f "${ACCLIB_SOURCE_ROOT}/fb_folly_autobuild/run.py" ]] || {
        log_message "ERROR: provide AccLibBenchmark at ${ACCLIB_SOURCE_ROOT} on this runner"
        return 30
    }
    COMPILER_VERSION_STRING="$(g++ --version | head -1)"
    prepare_folly_source || return $?
    prepare_fast_float || return $?
    bash "${SCRIPT_DIR}/scripts/build_acclib_stack.sh" "${PERF_WORK_DIR}" \
        "${SOURCE_DIR}" "${FAST_FLOAT_DIR}" "${SOFTWARE_VERSION}" \
        "${ACCLIB_SOURCE_ROOT}" || {
        log_message 'ERROR: upstream Folly stack or AccLibBenchmark build failed'
        return 40
    }
}

start_folly_runtime() {
    initialize_runtime || return $?
    [[ -x "${SERVER_BINARY}" && -x "${CLIENT_BINARY}" ]] || {
        log_message 'ERROR: AccLibBenchmark press_server/press_client is missing'
        return 40
    }
    [[ ! -e "${SERVICE_DIR}/server.pid" ]] || {
        log_message 'ERROR: a server PID file already exists for this run'
        return 40
    }
    local port
    port="$(python3 - <<'PYEOF'
import socket
with socket.socket() as listener:
    listener.bind(("127.0.0.1", 0))
    print(listener.getsockname()[1])
PYEOF
)"
    printf '%s\n' "${port}" > "${SERVICE_DIR}/port"
    log_message "starting AccLibBenchmark press_server on 127.0.0.1:${port}"
    "${SERVER_BINARY}" --num_io_threads=40 --num_cpu_threads=40 \
        --port="${port}" --use_io_uring=false \
        > "${RESULTS_DIR}/press_server.log" 2>&1 &
    local server_pid="$!" attempt
    printf '%s\n' "${server_pid}" > "${SERVICE_DIR}/server.pid"
    for attempt in {1..60}; do
        if python3 - "${port}" <<'PYEOF'
import socket, sys
try:
    with socket.create_connection(("127.0.0.1", int(sys.argv[1])), timeout=0.2):
        pass
except OSError:
    raise SystemExit(1)
PYEOF
        then
            log_message 'AccLibBenchmark press_server is ready'
            return 0
        fi
        if ! kill -0 "${server_pid}" 2>/dev/null; then
            log_message "ERROR: press_server exited; see ${RESULTS_DIR}/press_server.log"
            return 40
        fi
        sleep 1
    done
    log_message "ERROR: press_server did not listen; see ${RESULTS_DIR}/press_server.log"
    return 40
}

run_folly_benchmarks() {
    initialize_runtime || return $?
    [[ -s "${SERVICE_DIR}/port" && -x "${CLIENT_BINARY}" ]] || return 50
    python3 "${SCRIPT_DIR}/scripts/run_acclib.py" \
        "${ACCLIB_SOURCE_ROOT}/fb_folly_autobuild/run.py" \
        "${CLIENT_BINARY}" "$(< "${SERVICE_DIR}/port")" \
        "${RESULTS_DIR}/benchmark_folly.json" "${RESULTS_DIR}/press_client_raw" \
        "${SOFTWARE_VERSION}" "$(normalize_architecture "${EXPECTED_ARCH}")" || {
        log_message 'ERROR: AccLibBenchmark matrix failed'
        return 50
    }
}

stop_folly_runtime() {
    configure_runtime_paths || return $?
    local pid_file="${SERVICE_DIR}/server.pid" server_pid command_line
    [[ -s "${pid_file}" ]] || return 0
    server_pid="$(< "${pid_file}")"
    [[ "${server_pid}" =~ ^[0-9]+$ ]] || return 70
    if [[ -r "/proc/${server_pid}/cmdline" ]]; then
        command_line="$(tr '\0' ' ' < "/proc/${server_pid}/cmdline")"
        [[ "${command_line}" == *"${SERVER_BINARY}"* ]] || {
            log_message 'ERROR: PID file no longer identifies this press_server'
            return 70
        }
        kill "${server_pid}" || return 70
    fi
    rm -f -- "${pid_file}"
    log_message 'AccLibBenchmark press_server stopped'
}

standalone_runtime() { python3 "${SCRIPT_DIR}/scripts/standalone_runtime.py" "$@"; }

cleanup_standalone_workdir() {
    [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 0 && "${STANDALONE_OWNS_WORK_DIR}" -eq 1 ]] || return 0
    [[ "${PERF_WORK_DIR}" == /home/runner/boostkit-perf/folly/local-* ]] || return 70
    rm -rf -- "${PERF_WORK_DIR}"
}

run_folly_standalone() {
    local status=0 failed_stage="" cleanup_status="passed"
    initialize_runtime || return $?
    standalone_runtime system "${RESULTS_DIR}/system_info.json" || return $?
    standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json" || return $?
    if ! build_folly; then status=40; failed_stage="build"; fi
    if [[ "${status}" -eq 0 ]]; then
        standalone_runtime build-info "${RESULTS_DIR}/build_info.json" \
            "${SOFTWARE_VERSION}" "${PERF_ACTUAL_VERSION_FILE}" \
            "$(normalize_architecture "${EXPECTED_ARCH}")" "${PERF_RUN_ID}" \
            "${COMPILER_BINARY}" "${COMPILER_VERSION_STRING}" || { status=40; failed_stage="build"; }
    fi
    if [[ "${status}" -eq 0 ]] && ! start_folly_runtime; then status=40; failed_stage="start"; fi
    if [[ "${status}" -eq 0 ]] && ! run_folly_benchmarks; then status=50; failed_stage="test"; fi
    stop_folly_runtime || cleanup_status="failed"
    standalone_runtime runtime "${RESULTS_DIR}/runtime_after.json" || cleanup_status="failed"
    cleanup_standalone_workdir || cleanup_status="failed"
    local command_status="passed"
    [[ "${status}" -eq 0 ]] || command_status="failed"
    standalone_runtime finalize "${RESULTS_DIR}" "${SOFTWARE_VERSION}" \
        "$(normalize_architecture "${EXPECTED_ARCH}")" "${PERF_RUN_ID}" \
        "${command_status}" "${cleanup_status}" "${failed_stage}" || return $?
    return "${status}"
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version) SOFTWARE_VERSION="$2"; shift 2 ;;
            --results-dir) RESULTS_DIR="$2"; shift 2 ;;
            --keep-workdir) STANDALONE_KEEP_WORK_DIR=1; shift ;;
            -h|--help)
                printf 'Usage: %s [--version VERSION] [--results-dir DIR] [--keep-workdir]\n' "$0"
                return 0 ;;
            *) log_message "ERROR: unsupported option: $1"; return 10 ;;
        esac
    done
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}"
    : > "${RESULTS_DIR}/results.log"
    local status=0
    run_folly_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log" || status="${PIPESTATUS[0]}"
    log_message "standalone results: ${RESULTS_DIR}"
    return "${status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
