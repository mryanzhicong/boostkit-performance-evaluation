#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_expat_runtime() {
    configure_runtime_paths || return $?
    # expat is exercised as short-lived command-line tools (xmlwf, runtests,
    # benchmark); every measured invocation is a child process that the timing
    # wrapper waits for.  Removing the private container terminates anything it
    # still owns; stop then verifies that a timed run did not leave stale state
    # behind.  The function is idempotent.
    remove_expat_container || return $?
    local marker="${PERF_WORK_DIR}/running"
    if [[ -f "${marker}" ]]; then
        log_message "WARNING: a measured expat run left a marker behind: ${marker}"
        rm -f -- "${marker}"
    fi
    log_message "expat runtime stop completed (private container removed)"
    return 0
}
