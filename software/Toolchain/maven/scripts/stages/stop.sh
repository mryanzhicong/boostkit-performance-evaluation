#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_maven_runtime() {
    # Maven is a short-lived command-line build tool: every measured invocation is a
    # child process inside this run's private container, and the container is
    # removed together with every process it still owns.  The removal is idempotent
    # and refuses to touch a container that belongs to another run.
    initialize_runtime || return $?
    remove_maven_container || return $?
    local marker="${PERF_WORK_DIR}/running"
    if [[ -f "${marker}" ]]; then
        log_message "WARNING: a measured Maven run left a marker behind: ${marker}"
        rm -f -- "${marker}"
    fi
    log_message "Maven runtime stop completed (private container removed)"
    return 0
}
