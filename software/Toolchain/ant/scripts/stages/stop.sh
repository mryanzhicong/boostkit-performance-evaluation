#!/usr/bin/env bash
# Stop stage: Ant has no service.  The Framework calls this stage on both the
# success and the failure path, so it removes this task's private container
# first (which also terminates every process the container owns), then cleans the
# transient files and verifies no marker of this run is left behind.  It is
# idempotent and safe to call twice.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_ant_runtime() {
    initialize_runtime || return $?

    remove_ant_container || return $?

    local marker="${PERF_WORK_DIR}/running"
    if [[ -f "${marker}" ]]; then
        log_message "WARNING: a measured Ant run left a marker behind: ${marker}"
        rm -f -- "${marker}"
    fi
    rm -rf -- "${TMPDIR}" 2>/dev/null || true
    mkdir -p "${TMPDIR}"
    log_message "Ant runtime stop completed: private container removed, transient files cleaned"
    return 0
}
