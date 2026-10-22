#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_redis_benchmarks() {
    initialize_runtime || return $?
    if [[ ! -x "${REDIS_BENCHMARK_BIN}" || ! -x "${REDIS_CLI_BIN}" ]]; then
        log_message "ERROR: Redis benchmark tools are unavailable; run the build stage first"
        return 50
    fi
    if ! "${REDIS_CLI_BIN}" -h 127.0.0.1 -p "${REDIS_SERVICE_PORT}" PING | grep -qx PONG; then
        log_message "ERROR: Redis service is not running on port ${REDIS_SERVICE_PORT}"
        return 50
    fi

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    if ! python3 "${SCRIPT_DIR}/scripts/results/benchmark_redis.py" \
        "${REDIS_BENCHMARK_BIN}" \
        "${RESULTS_DIR}/redis_benchmark_raw.log" \
        "${RESULTS_DIR}/benchmark_redis.json"; then
        log_message "ERROR: Redis SET/GET throughput benchmark failed"
        return 50
    fi
}
