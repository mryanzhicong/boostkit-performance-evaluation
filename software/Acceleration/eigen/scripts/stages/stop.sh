#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Eigen starts no background service; the measured bench_gemm processes are
# children of the measurement wrapper, which always waits for them.  stop removes
# this task's private container first (which also terminates anything it still
# owns), then the private scratch state, so a repeated invocation (including the
# failure path) always succeeds and no stale result file can influence the next
# run.  The extracted source tree, the compiled driver and the probe are kept in
# PERF_WORK_DIR so a follow-up run can reuse them.
stop_eigen_runtime() {
    configure_runtime_paths || return $?
    remove_eigen_container || return $?
    if [[ -d "${SCRATCH_DIR}" ]]; then
        rm -rf -- "${SCRATCH_DIR}" || {
            log_message "ERROR: failed to remove the measurement scratch directory: ${SCRATCH_DIR}"
            return 60
        }
        log_message "removed measurement scratch directory: ${SCRATCH_DIR}"
    fi
    log_message "Eigen GEMM runtime stop completed"
    return 0
}
