#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_fbthrift_benchmarks() {
    initialize_runtime || return $?
    check_fbthrift_container || return $?
    local port node
    [[ -s "${SERVICE_DIR}/port" ]] || { log_message 'ERROR: press_server port is unknown; run start first'; return 40; }
    port="$(cat "${SERVICE_DIR}/port")"
    node="$(cat "${SERVICE_DIR}/numa-node" 2>/dev/null || printf '0')"
    mkdir -p "${RESULTS_DIR}/raw"
    log_message "running the ${FBTHRIFT_MATRIX} RPC matrix (test_seconds=${FBTHRIFT_TEST_SECONDS}, numa_node=${node}, port=${port})"
    fbthrift_container_exec_at "${SERVICE_DIR}" python3 "${SCRIPT_DIR}/scripts/results/run_matrix.py" \
        --client "${CLIENT_BINARY}" \
        --port "${port}" \
        --numa-node "${node}" \
        --matrix "${FBTHRIFT_MATRIX}" \
        --test-seconds "${FBTHRIFT_TEST_SECONDS}" \
        --rpc-timeout-ms "${FBTHRIFT_RPC_TIMEOUT_MS}" \
        --version "${SOFTWARE_VERSION}" \
        --arch "${EXPECTED_ARCH}" \
        --results-json "${RESULTS_DIR}/benchmark_fbthrift.json" \
        --raw-dir "${RESULTS_DIR}/raw" || {
        log_message 'ERROR: the RPC matrix driver failed'
        return 40
    }
    [[ -s "${RESULTS_DIR}/benchmark_fbthrift.json" ]] || {
        log_message 'ERROR: benchmark_fbthrift.json was not written'
        return 40
    }
    log_message "benchmark results written to ${RESULTS_DIR}/benchmark_fbthrift.json"
}
