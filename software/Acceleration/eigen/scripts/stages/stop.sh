#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Eigen starts no background service; the measured BTL processes are children of
# the measurement wrapper, which always waits for them.  stop only removes the
# private scratch state so a repeated invocation (including the failure path)
# always succeeds and no stale BTL result file can influence the next run.
stop_eigen_runtime() {
    configure_runtime_paths || return $?
    if [[ -d "${SCRATCH_DIR}" ]]; then
        rm -rf -- "${SCRATCH_DIR}" || {
            log_message "ERROR: failed to remove the measurement scratch directory: ${SCRATCH_DIR}"
            return 60
        }
        log_message "removed measurement scratch directory: ${SCRATCH_DIR}"
    fi
    log_message "Eigen BTL runtime stop completed"
    return 0
}
