#!/usr/bin/env bash
# Stop stage: remove this task's private container (idempotent) and report the
# retained evidence directory.  No long-running service is created.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_perl_runtime() {
    initialize_runtime || return $?
    remove_perl_container || return $?
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        log_message "work directory retained for evidence: ${PERF_WORK_DIR}"
    fi
    return 0
}
