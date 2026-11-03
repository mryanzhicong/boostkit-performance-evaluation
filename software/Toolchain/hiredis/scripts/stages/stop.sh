#!/usr/bin/env bash
# Stop stage: the case runs no daemon, so this removes this task's private
# container (which also terminates every process it owns) and then verifies that
# no measured child process of this run is left behind.  The stage is idempotent
# and called by the Framework on both the success and the failure path.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

stop_hiredis_runtime() {
    validate_variant || return $?
    configure_runtime_paths || return $?

    remove_hiredis_container || return $?

    local leftover=0
    local pid
    local -a pids=()
    if command -v pgrep >/dev/null 2>&1; then
        mapfile -t pids < <(pgrep -f -- "${PERF_WORK_DIR}" 2>/dev/null || true)
    fi
    for pid in "${pids[@]}"; do
        # The stop stage's own shell and its parent may carry the work directory
        # on their command line; they are not measured processes.
        [[ "${pid}" == "$$" || "${pid}" == "${PPID}" ]] && continue
        if [[ -r "/proc/${pid}/cmdline" ]] && \
            tr '\0' ' ' < "/proc/${pid}/cmdline" | grep -q -- "${PERF_WORK_DIR}"; then
            fail_message "measured process ${pid} is still running under ${PERF_WORK_DIR}"
            leftover=1
        fi
    done

    rm -rf -- "${TMPDIR}" 2>/dev/null || true

    if [[ "${leftover}" -ne 0 ]]; then
        fail_message "leftover measured processes were found"
        return 60
    fi
    log_message "stop stage: private container removed, transient files removed"
    return 0
}
