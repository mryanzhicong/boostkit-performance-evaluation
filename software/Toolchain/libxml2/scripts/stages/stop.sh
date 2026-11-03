#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_libxml2_runtime() {
    # libxml2 is exercised as short-lived command-line tools (xmllint, runtest,
    # runsuite); every measured invocation is a child process that the timing
    # wrapper waits for.  There is no service to shut down, so stop removes the
    # private container and checks that a timed run left no stale state.
    remove_libxml2_container || return $?
    local marker="${PERF_WORK_DIR}/running"
    if [[ -f "${marker}" ]]; then
        log_message "WARNING: a measured libxml2 run left a marker behind: ${marker}"
        rm -f -- "${marker}"
    fi
    log_message "libxml2 runtime stop completed"
    return 0
}
