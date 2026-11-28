#!/usr/bin/env bash
# Test-stage entry point: six timed fio runs inside the reference VM.
set -o pipefail

FIO_CASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck disable=SC1091
source "${FIO_CASE_DIR}/scripts/common.sh"

run_fio_rep() {
    local rep="$1" log_file="$2"
    vm_exec_shell "cd '${FIO_GUEST_DIR}' && taskset -c 0 fio '${FIO_GUEST_JOB}'" > "${log_file}"
}

run_fio_benchmarks() {
    local reps rep runs_dir raw_log log_file rc
    configure_runtime_paths
    check_fio_vm || return $?
    reps="${PERF_REPS:-6}"
    [[ "${reps}" =~ ^[0-9]+$ ]] || {
        log "ERROR: PERF_REPS='${reps}' is not a number"
        return 30
    }
    ((reps >= 6)) || {
        log "ERROR: the sampling contract needs 1 warm-up + 5 measured runs, got PERF_REPS=${reps}"
        return 30
    }
    export FIO_NUMJOBS FIO_IODEPTH FIO_BLOCK_SIZE FIO_RUNTIME FIO_RAMP_TIME FIO_RW
    capture_fio_format_info || return $?
    vm_exec_shell "rm -rf '${FIO_GUEST_DIR}/logs' && mkdir -p '${FIO_GUEST_DIR}/logs'" || {
        log 'ERROR: cannot prepare the guest log directory'
        return 40
    }
    runs_dir="${RESULTS_DIR}/runs"
    mkdir -p "${runs_dir}"
    raw_log="${RESULTS_DIR}/benchmark_fio_raw.log"
    : > "${raw_log}"
    for rep in $(seq 1 "${reps}"); do
        log_file="${runs_dir}/rep${rep}.log"
        log "running fio rep ${rep}/${reps} inside the reference VM: taskset -c 0 fio ${FIO_GUEST_JOB}"
        rc=0
        run_fio_rep "${rep}" "${log_file}" || rc=$?
        {
            printf '===== rep %s/%s rc=%s =====\n' "${rep}" "${reps}" "${rc}"
            cat "${log_file}"
            printf '\n'
        } >> "${raw_log}"
        if ((rc != 0)); then
            log "ERROR: fio rep ${rep} failed with exit code ${rc}"
            return 50
        fi
        if grep -q 'err= [1-9]' "${log_file}"; then
            log "ERROR: fio rep ${rep} reported a non-zero error count"
            return 50
        fi
    done
    python3 "${FIO_CASE_DIR}/scripts/results/parse_benchmark.py" \
        --runs-dir "${runs_dir}" \
        --reps "${reps}" \
        --output "${RESULTS_DIR}/benchmark_fio.json" \
        --raw-log "${raw_log}" || return $?
    log "normalized ${reps} fio repetitions"
}
