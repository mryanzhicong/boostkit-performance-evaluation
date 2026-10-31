#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_cmake_runtime() {
    # CMake is a short-lived command-line build tool: every measured invocation
    # is a child process that the timing wrapper waits for.  There is no service
    # to shut down, so stop only verifies that no measured run left state that
    # would change the next measurement.
    local marker="${PERF_WORK_DIR}/running"
    if [[ -f "${marker}" ]]; then
        log_message "WARNING: a measured CMake run left a marker behind: ${marker}"
        rm -f -- "${marker}"
    fi
    log_message "CMake runtime stop completed"
    return 0
}
