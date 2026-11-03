#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_unixbench_benchmarks() {
    initialize_runtime || return $?
    check_unixbench_container || return $?
    container_exec test -x "${UNIXBENCH_RUN_DIR}/pgms/dhry2reg" || return 40
    [[ -z "$(find "${UB_RESULTDIR}" -mindepth 1 -print -quit)" ]] || {
        log 'ERROR: official output directory is not empty'; return 50;
    }
    log 'running the complete official UnixBench system index inside the container: ./Run'
    local run_status=0
    container_exec sh -c 'cd "$1" && ./Run' sh "${UNIXBENCH_RUN_DIR}" 2>&1 | \
        tee "${RESULTS_DIR}/benchmark_unixbench_raw.log" || run_status="${PIPESTATUS[0]}"
    [[ "${run_status}" -eq 0 ]] || { log "ERROR: ./Run exited ${run_status}"; return 50; }
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${UB_RESULTDIR}/unixbench-index" \
        "${RESULTS_DIR}/benchmark_unixbench.json" || return 50
}
