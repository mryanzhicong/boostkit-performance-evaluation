#!/usr/bin/env bash
# Stop stage: PHP CLI scenarios are short-lived child processes; there is no
# service to stop.  The stage still runs on both the success and the failure
# path, so it removes this task's private container first (which terminates any
# process the container still owns), then clears the transient marker.  It is
# idempotent and safe to call twice.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_php_runtime() {
    initialize_runtime || return $?
    remove_php_container || return $?

    local marker="${PERF_WORK_DIR}/running"
    if [[ -f "${marker}" ]]; then
        log_message "WARNING: a measured PHP run left a marker behind: ${marker}"
        rm -f -- "${marker}"
    fi
    log_message "PHP runtime stop completed: private container removed"
    return 0
}
