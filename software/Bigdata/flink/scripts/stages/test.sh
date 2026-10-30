#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_flink_benchmark() {
    initialize_runtime || return $?
    load_java || return $?
    [[ -s "${NEXMARK_HOME}/conf/nexmark.yaml" ]] || { log_message 'ERROR: Nexmark is not deployed'; return 40; }
    log_message 'running Nexmark V1 OA: 500K warmup, then 10M events x 23 queries'
    python3 "${CASE_DIR}/scripts/run_nexmark.py" \
        --nexmark-home "${NEXMARK_HOME}" \
        --flink-home "${FLINK_HOME}" \
        --rest-port "${FLINK_REST_PORT}" \
        --results-dir "${RESULTS_DIR}" || {
        log_message 'ERROR: Nexmark benchmark failed'
        return 50
    }
    python3 "${CASE_DIR}/scripts/results/parse_benchmark.py" \
        --results-dir "${RESULTS_DIR}" || {
        log_message 'ERROR: Nexmark result parsing failed'
        return 50
    }
}
