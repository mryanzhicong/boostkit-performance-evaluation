#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_envoy_benchmarks() {
    initialize_runtime || return $?
    [[ -x "${K6_BIN}" ]] || {
        log_message "ERROR: Envoy benchmark runtime is unavailable"
        return 50
    }
    check_envoy_container || return 50
    docker exec -i --user "$(id -u):$(id -g)" \
        --env "SOFTWARE_VERSION=${SOFTWARE_VERSION}" \
        --env "EXPECTED_ARCH=${EXPECTED_ARCH}" \
        --env "PERF_VARIANT=${PERF_VARIANT}" \
        --env "TMPDIR=${TMPDIR}" \
        "${ENVOY_CONTAINER_NAME}" python3 - \
        --k6 "${K6_BIN}" \
        --direct-url 'https://127.0.0.1:19000/' \
        --reverse-url 'https://127.0.0.1:19001/' \
        --output "${RESULTS_DIR}/benchmark_envoy.json" \
        --raw-output "${RESULTS_DIR}/benchmark_envoy_raw.log" \
        < "${SCRIPT_DIR}/scripts/results/run_k6_benchmark.py" || {
        log_message "ERROR: Envoy single-machine benchmark failed"
        return 50
    }
}
