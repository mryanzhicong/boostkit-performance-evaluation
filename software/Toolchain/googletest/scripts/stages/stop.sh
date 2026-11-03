#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

# Stop stage: remove this task's private container first, which also terminates
# every process it owns, then verify that no measurement process of this run is
# still alive.  The stage is idempotent (a missing container is success) and safe
# to call twice, because the Framework calls it on both the success and the
# failure path.
stop_googletest_runtime() {
    initialize_runtime || return $?

    remove_googletest_container || return $?

    local leftover=0 pid
    for pid in $(pgrep -f "${GOOGLETEST_MATRIX_BIN_DIR}/" 2>/dev/null || true); do
        if [[ -r "/proc/${pid}/cmdline" ]] && \
            tr '\0' ' ' < "/proc/${pid}/cmdline" | grep -q -F "${PERF_WORK_DIR}"; then
            log_message "ERROR: measurement process ${pid} of this run is still alive"
            leftover=$((leftover + 1))
        fi
    done
    if (( leftover > 0 )); then
        for pid in $(pgrep -f "${GOOGLETEST_MATRIX_BIN_DIR}/" 2>/dev/null || true); do
            if [[ -r "/proc/${pid}/cmdline" ]] && \
                tr '\0' ' ' < "/proc/${pid}/cmdline" | grep -q -F "${PERF_WORK_DIR}"; then
                kill -TERM "${pid}" 2>/dev/null || true
            fi
        done
        return 60
    fi

    rm -rf -- "${TMPDIR}/"* 2>/dev/null || true
    log_message "googletest runtime stop completed: private container removed, no leftover measurement process"
    return 0
}
