#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_unixbench_benchmarks() {
    local run_command run_status=0
    initialize_runtime || return $?
    check_unixbench_vm || return $?
    vm_exec test -x "${GUEST_RUN_DIR}/pgms/dhry2reg" || return 40
    [[ -z "$(find "${UB_RESULTDIR}" -mindepth 1 -print -quit)" ]] || {
        log 'ERROR: official output directory is not empty'; return 50;
    }
    vm_exec mkdir -p "${GUEST_RESULTDIR}" "${GUEST_TMPDIR}" || return 50
    run_command="cd ${GUEST_RUN_DIR} && env UB_RESULTDIR=${GUEST_RESULTDIR} UB_TMPDIR=${GUEST_TMPDIR} UB_OUTPUT_FILE_NAME=${UB_OUTPUT_FILE_NAME} ./Run"
    log 'running the complete official UnixBench system index inside the reference VM: ./Run'
    vm_exec_shell "${run_command}" 2>&1 | tee "${RESULTS_DIR}/benchmark_unixbench_raw.log" || \
        run_status="${PIPESTATUS[0]}"
    [[ "${run_status}" -eq 0 ]] || { log "ERROR: ./Run exited ${run_status}"; return 50; }
    vm_copy_out "${GUEST_RESULTDIR}/${UB_OUTPUT_FILE_NAME}" "${UB_RESULTDIR}/${UB_OUTPUT_FILE_NAME}" || {
        log 'ERROR: official UnixBench index report was not produced'; return 50;
    }
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${UB_RESULTDIR}/${UB_OUTPUT_FILE_NAME}" \
        "${RESULTS_DIR}/benchmark_unixbench.json" || return 50
}
