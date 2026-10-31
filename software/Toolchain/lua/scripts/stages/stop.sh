#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_lua_runtime() {
    # Lua is a short-lived interpreter: every measured invocation is a child
    # process that the timing wrapper waits for. There is no service to stop;
    # the marker check only makes an interrupted stage visible in the log.
    local marker="${PERF_WORK_DIR}/running"
    if [[ -f "${marker}" ]]; then
        log_message "WARNING: a measured Lua run left a marker behind: ${marker}"
        rm -f -- "${marker}"
    fi
    log_message "Lua runtime stop completed"
    return 0
}
