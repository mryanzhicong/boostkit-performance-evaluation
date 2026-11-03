#!/usr/bin/env bash
# Stop stage: Ruby CLI scenarios are short-lived child processes, so there is no
# service to stop; the stage still runs on success and failure paths and removes
# this task's private container first (which also terminates anything the
# container still owns), then reports the retained evidence directory.  It is
# idempotent and safe to call twice.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_ruby_runtime() {
    initialize_runtime || return $?
    remove_ruby_container || return $?
    log_message "no long-running service is created by the Ruby case"
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        log_message "work directory retained for evidence: ${PERF_WORK_DIR}"
    fi
    log_message "Ruby runtime stop completed: private container removed"
    return 0
}
