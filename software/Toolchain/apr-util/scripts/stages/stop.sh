#!/usr/bin/env bash
# Stop stage: the case runs no daemon, so this only verifies that no measured
# child process is left behind under this task's work directory and removes the
# transient files that are not evidence.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

stop_apr_util_runtime() {
    validate_variant || return $?
    configure_runtime_paths || return $?

    # Removing the container first stops every process it owns, which keeps the
    # leftover scan below from racing the cleanup.
    remove_apr_util_container || return $?

    local leftover=0
    local pid
    local -a pids=()
    if command -v pgrep >/dev/null 2>&1; then
        mapfile -t pids < <(pgrep -f -- "${PERF_WORK_DIR}" 2>/dev/null || true)
        if (( ${#pids[@]} == 0 )); then
            mapfile -t pids < <(pgrep -f -- 'apr-util-bench/base64_bench' 2>/dev/null || true)
        fi
        if (( ${#pids[@]} == 0 )); then
            mapfile -t pids < <(pgrep -f -- 'apr-util-src/apr-util-1.6.5/test/testall' 2>/dev/null || true)
        fi
    fi
    for pid in "${pids[@]}"; do
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
    log_message "stop stage: no service to stop, transient files removed"
    return 0
}
