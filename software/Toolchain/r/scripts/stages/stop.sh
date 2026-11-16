#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# The R workload consists of short-lived child processes, so removing this task's
# private container is enough to guarantee that nothing survives the test stage.
# The stage also proves the container is really gone: a stale container would keep
# the work tree mounted and break the next run on the reused name.
stop_r_runtime() {
    initialize_runtime || return $?
    remove_r_container || return $?
    r_configure_container
    if docker container inspect "${R_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: the managed container still exists after stop: ${R_CONTAINER_NAME}"
        return 50
    fi
    log_message "no measured R process is still running (container ${R_CONTAINER_NAME} removed)"
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        log_message "work directory retained for evidence: ${PERF_WORK_DIR}"
    fi
    return 0
}
