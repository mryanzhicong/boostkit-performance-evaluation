#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_envoy_benchmarks() {
    initialize_runtime || return $?
    [[ -x "${K6_BIN}" && -f "${DIRECT_PID_FILE}" && -f "${PROXY_PID_FILE}" ]] || {
        log_message "ERROR: Envoy benchmark runtime is unavailable"
        return 50
    }
    python3 "${SCRIPT_DIR}/scripts/results/run_k6_benchmark.py" \
        --k6 "${K6_BIN}" \
        --direct-url 'https://127.0.0.1:19000/' \
        --reverse-url 'https://127.0.0.1:19001/' \
        --output "${RESULTS_DIR}/benchmark_envoy.json" \
        --raw-output "${RESULTS_DIR}/benchmark_envoy_raw.log" || {
        log_message "ERROR: Envoy single-machine benchmark failed"
        return 50
    }
}
