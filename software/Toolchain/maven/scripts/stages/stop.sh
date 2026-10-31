#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_maven_runtime() {
    # Maven is a short-lived command-line build tool: every measured invocation
    # is a child process that the timing wrapper waits for. There is no service
    # to shut down, so stop only verifies that no measured run is still alive.
    local marker="${PERF_WORK_DIR}/running"
    if [[ -f "${marker}" ]]; then
        log_message "WARNING: a measured Maven run left a marker behind: ${marker}"
        rm -f -- "${marker}"
    fi
    log_message "Maven runtime stop completed"
    return 0
}
