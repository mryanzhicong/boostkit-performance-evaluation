#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_envoy_benchmarks() {
    initialize_runtime || return $?
    [[ -x "${K6_BIN}" ]] || {
        log_message "ERROR: Envoy benchmark runtime is unavailable"
        return 50
    }
    check_envoy_container || return 50
    [[ -r "${RUNTIME_DIR}/ports.env" ]] || {
        log_message "ERROR: Envoy runtime port file is missing: ${RUNTIME_DIR}/ports.env"
        return 50
    }
    # shellcheck disable=SC1091
    . "${RUNTIME_DIR}/ports.env"
    log_message "running k6 on the host while Envoy stays in the 4U8G container"
    SOFTWARE_VERSION="${SOFTWARE_VERSION}" \
    EXPECTED_ARCH="${EXPECTED_ARCH}" \
    PERF_VARIANT="${PERF_VARIANT}" \
    TMPDIR="${TMPDIR}" \
    python3 "${SCRIPT_DIR}/scripts/results/run_k6_benchmark.py" \
        --k6 "${K6_BIN}" \
        --direct-url "https://127.0.0.1:${ENVOY_DIRECT_PORT}/" \
        --reverse-url "https://127.0.0.1:${ENVOY_PROXY_PORT}/" \
        --output "${RESULTS_DIR}/benchmark_envoy.json" \
        --raw-output "${RESULTS_DIR}/benchmark_envoy_raw.log" || {
        log_message "ERROR: Envoy host-client benchmark failed"
        return 50
    }
}
