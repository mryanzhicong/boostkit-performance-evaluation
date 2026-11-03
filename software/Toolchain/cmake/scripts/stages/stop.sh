#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_cmake_runtime() {
    configure_runtime_paths || return $?
    # CMake is a short-lived command-line build tool: every measured invocation
    # is a child process that the timing wrapper waits for.  Removing the private
    # container terminates anything it still owns; stop then verifies that no
    # measured run left state behind.  The function is idempotent.
    remove_cmake_container || return $?
    local marker="${PERF_WORK_DIR}/running"
    if [[ -f "${marker}" ]]; then
        log_message "WARNING: a measured CMake run left a marker behind: ${marker}"
        rm -f -- "${marker}"
    fi
    log_message "CMake runtime stop completed (private container removed)"
    return 0
}
