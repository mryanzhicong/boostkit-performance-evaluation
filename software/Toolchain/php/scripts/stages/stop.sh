#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_php_runtime() {
    # PHP CLI scenarios are short-lived child processes that the timing wrapper
    # waits for; there is no service to stop.  The marker check only makes an
    # interrupted stage visible in the log, and the work directory is kept so
    # the raw samples remain inspectable after the run.
    local marker="${PERF_WORK_DIR}/running"
    if [[ -f "${marker}" ]]; then
        log_message "WARNING: a measured PHP run left a marker behind: ${marker}"
        rm -f -- "${marker}"
    fi
    log_message "PHP runtime stop completed"
    return 0
}
