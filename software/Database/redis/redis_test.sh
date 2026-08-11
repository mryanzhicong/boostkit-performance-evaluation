#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-8.0.6}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
RESULTS_DIR="${RESULTS_DIR:-${SCRIPT_DIR}/results/${SOFTWARE_VERSION}}"
PERF_WORK_DIR="${PERF_WORK_DIR:-/tmp/boostkit-perf/local/Database/redis/${SOFTWARE_VERSION}}"
REDIS_SOURCE_URL="${REDIS_SOURCE_URL:-https://github.com/redis/redis.git}"
BUILD_JOBS="${BUILD_JOBS:-$(nproc)}"
SOURCE_DIR="${PERF_WORK_DIR}/redis-source"
INSTALL_DIR="${PERF_WORK_DIR}/install"
REDIS_SERVER_BIN="${INSTALL_DIR}/bin/redis-server"
REDIS_BENCHMARK_BIN="${INSTALL_DIR}/bin/redis-benchmark"
REDIS_CLI_BIN="${INSTALL_DIR}/bin/redis-cli"
REDIS_SERVICE_PORT="${REDIS_SERVICE_PORT:-16379}"
SERVICE_DIR="${PERF_WORK_DIR}/service"
LOG_FILE="${RESULTS_DIR}/results.log"

mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR:-${PERF_WORK_DIR}/tmp}"
touch "${LOG_FILE}"
exec > >(tee -a "${LOG_FILE}") 2>&1

log() { printf '[redis] %s\n' "$*"; }

normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

require_commands() {
    local command missing=0
    for command in bash git python3 gcc make; do
        if ! command -v "${command}" >/dev/null 2>&1; then
            log "ERROR: required command is missing: ${command}"
            missing=1
        fi
    done
    [[ "${missing}" -eq 0 ]]
}

check_architecture() {
    local actual expected
    actual="$(normalize_arch "$(uname -m)")"
    expected="$(normalize_arch "${EXPECTED_ARCH}")"
    [[ "${actual}" == "${expected}" ]] || {
        log "ERROR: expected architecture ${expected}, runner is ${actual}"
        return 20
    }
}

phase_build() {
    check_architecture
    require_commands
    [[ ! -e "${SOURCE_DIR}" && ! -e "${INSTALL_DIR}" ]] || {
        log "ERROR: source or install directory is not clean under ${PERF_WORK_DIR}"
        return 20
    }
    log "cloning Redis ${SOFTWARE_VERSION} from ${REDIS_SOURCE_URL}"
    git clone --branch "${SOFTWARE_VERSION}" --depth 1 "${REDIS_SOURCE_URL}" "${SOURCE_DIR}"
    log "building Redis with ${BUILD_JOBS} jobs"
    make -C "${SOURCE_DIR}" -j"${BUILD_JOBS}" BUILD_TLS=no
    log "installing Redis into ${INSTALL_DIR}"
    make -C "${SOURCE_DIR}" install PREFIX="${INSTALL_DIR}"
}

phase_validate() {
    local binary actual_version actual_arch
    check_architecture
    require_commands
    for binary in "${REDIS_SERVER_BIN}" "${REDIS_BENCHMARK_BIN}" "${REDIS_CLI_BIN}"; do
        [[ -x "${binary}" ]] || { log "ERROR: expected executable not found: ${binary}"; return 40; }
    done
    actual_version="$("${REDIS_SERVER_BIN}" --version | sed -n 's/.*v=\([^ ]*\).*/\1/p' | head -n 1)"
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log "ERROR: requested Redis ${SOFTWARE_VERSION}, installed ${actual_version:-unknown}"
        return 40
    }
    actual_arch="$(normalize_arch "$(uname -m)")"
    python3 "${SCRIPT_DIR}/scripts/write_version_info.py" \
        "${RESULTS_DIR}/version_info.json" "${SOFTWARE_VERSION}" "${actual_version}" "${actual_arch}"
}

phase_start_service() {
    [[ -x "${REDIS_SERVER_BIN}" && -x "${REDIS_CLI_BIN}" ]] || {
        log "ERROR: Redis is not installed"
        return 40
    }
    mkdir -p "${SERVICE_DIR}"
    if "${REDIS_CLI_BIN}" -h 127.0.0.1 -p "${REDIS_SERVICE_PORT}" PING 2>/dev/null | grep -qx PONG; then
        log "ERROR: port ${REDIS_SERVICE_PORT} already has a Redis service"
        return 20
    fi
    "${REDIS_SERVER_BIN}" \
        --bind 127.0.0.1 \
        --protected-mode yes \
        --port "${REDIS_SERVICE_PORT}" \
        --dir "${SERVICE_DIR}" \
        --save "" \
        --appendonly no \
        --daemonize yes \
        --pidfile "${SERVICE_DIR}/redis.pid" \
        --logfile "${SERVICE_DIR}/redis.log"
    local attempt
    for attempt in {1..30}; do
        if "${REDIS_CLI_BIN}" -h 127.0.0.1 -p "${REDIS_SERVICE_PORT}" PING 2>/dev/null | grep -qx PONG; then
            log "Redis service is ready on port ${REDIS_SERVICE_PORT}"
            return 0
        fi
        sleep 0.2
    done
    log "ERROR: Redis service did not become ready"
    return 20
}

phase_test() {
    "${REDIS_CLI_BIN}" -h 127.0.0.1 -p "${REDIS_SERVICE_PORT}" PING | grep -qx PONG || {
        log "ERROR: Redis service is not running on port ${REDIS_SERVICE_PORT}"
        return 50
    }
    export REDIS_CLI_BIN SOFTWARE_VERSION EXPECTED_ARCH REDIS_SERVICE_PORT
    python3 "${SCRIPT_DIR}/scripts/benchmark_redis.py" \
        "${REDIS_SERVER_BIN}" "${REDIS_BENCHMARK_BIN}" "${RESULTS_DIR}/benchmark_redis.json"
    python3 "${SCRIPT_DIR}/scripts/micro_benchmark.py" \
        "${REDIS_SERVER_BIN}" "${REDIS_BENCHMARK_BIN}" "${RESULTS_DIR}/micro_benchmark.json"
}

phase_stop_service() {
    local pid=""
    if [[ -f "${SERVICE_DIR}/redis.pid" ]]; then
        pid="$(<"${SERVICE_DIR}/redis.pid")"
    fi
    if [[ -x "${REDIS_CLI_BIN}" ]]; then
        "${REDIS_CLI_BIN}" -h 127.0.0.1 -p "${REDIS_SERVICE_PORT}" SHUTDOWN NOSAVE >/dev/null 2>&1 || true
    fi
    if [[ "${pid}" =~ ^[0-9]+$ ]]; then
        local attempt
        for attempt in {1..20}; do
            kill -0 "${pid}" 2>/dev/null || break
            sleep 0.1
        done
        if kill -0 "${pid}" 2>/dev/null; then
            kill -TERM "${pid}" 2>/dev/null || true
            sleep 0.5
        fi
        if kill -0 "${pid}" 2>/dev/null; then
            kill -KILL "${pid}" 2>/dev/null || true
        fi
    fi
    if "${REDIS_CLI_BIN}" -h 127.0.0.1 -p "${REDIS_SERVICE_PORT}" PING >/dev/null 2>&1; then
        log "ERROR: Redis service is still reachable on port ${REDIS_SERVICE_PORT}"
        return 50
    fi
    log "Redis service stopped"
}

phase_collect_report() {
    python3 "${SCRIPT_DIR}/scripts/aggregate_results.py" \
        "${RESULTS_DIR}" "${RESULTS_DIR}/results.json"
    python3 "${SCRIPT_DIR}/scripts/generate_summary.py" \
        "${RESULTS_DIR}/results.json" "${RESULTS_DIR}/results.txt"
    local output
    for output in version_info.json benchmark_redis.json micro_benchmark.json results.json results.txt results.log; do
        [[ -s "${RESULTS_DIR}/${output}" ]] || { log "ERROR: missing or empty output: ${output}"; return 60; }
    done
}

run_all() {
    phase_build
    phase_validate
    phase_start_service
    trap phase_stop_service EXIT
    phase_test
    phase_stop_service
    trap - EXIT
    phase_collect_report
}

case "${1:-all}" in
    build) phase_build ;;
    validate) phase_validate ;;
    start-service) phase_start_service ;;
    test) phase_test ;;
    stop-service) phase_stop_service ;;
    collect-report) phase_collect_report ;;
    all) run_all ;;
    *) log "ERROR: unknown stage: $1"; exit 10 ;;
esac
