#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_stream_benchmarks() {
    local reps="${PERF_REPS:-6}" rep status raw_log
    initialize_runtime || return $?
    check_stream_vm || return $?
    vm_exec test -x "${GUEST_BINARY}" || return 40
    case "${reps}" in
        ''|*[!0-9]*) log "ERROR: PERF_REPS must be a positive integer, got ${reps}"; return 10 ;;
    esac
    ((reps >= 6)) || { log "ERROR: PERF_REPS must be at least 6 (1 warm-up + 5 measured), got ${reps}"; return 10; }
    rm -rf "${RESULTS_DIR}/runs"
    mkdir -p "${RESULTS_DIR}/runs"
    raw_log="${RESULTS_DIR}/benchmark_stream_raw.log"
    : > "${raw_log}"
    {
        printf '### STREAM %s reference-VM run\n' "${SOFTWARE_VERSION}"
        printf '### stream_revision=%s\n' "${STREAM_REVISION}"
        printf '### array_size=%s ntimes=%s\n' "${STREAM_ARRAY_SIZE}" "${STREAM_NTIMES}"
        printf '### vm=%s vcpus=%s cores=%s threads_per_core=%s memory_mib=%s hugepages=%s numa_node=%s cpuset=%s accelerator=%s\n' \
            "${STREAM_VM_NAME}" "${STREAM_VM_VCPUS}" "${STREAM_VM_CORES_USED}" "${STREAM_VM_THREADS_PER_CORE}" \
            "${STREAM_VM_MEM_MIB}" "${STREAM_VM_HUGEPAGES_ENABLED}" "${STREAM_VM_NUMA_NODE}" \
            "${STREAM_VM_CPUSET}" "${STREAM_VM_ACCEL_USED}"
        printf '### reps=%s (rep1 is the warm-up and is excluded from the statistics)\n' "${reps}"
    } >> "${raw_log}"
    for ((rep = 1; rep <= reps; rep++)); do
        log "running STREAM rep ${rep}/${reps} inside the reference VM: ./stream_200M"
        {
            printf '\n===== rep %s =====\n' "${rep}"
        } >> "${raw_log}"
        status=0
        vm_exec_shell "cd '${GUEST_SOURCE_DIR}' && ./stream_200M" > "${RESULTS_DIR}/runs/rep${rep}.log" 2>&1 || status=$?
        cat "${RESULTS_DIR}/runs/rep${rep}.log" >> "${raw_log}"
        if ((status != 0)); then
            log "ERROR: STREAM rep ${rep} exited ${status}; see runs/rep${rep}.log"
            return 50
        fi
        if grep -q 'Failed Validation' "${RESULTS_DIR}/runs/rep${rep}.log"; then
            log "ERROR: STREAM rep ${rep} failed the upstream array validation"
            return 50
        fi
    done
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        --runs-dir "${RESULTS_DIR}/runs" \
        --reps "${reps}" \
        --output "${RESULTS_DIR}/benchmark_stream.json" \
        --raw-log "${raw_log}" || return 50
}
