#!/usr/bin/env bash
# Stop stage: PCRE has no service.  The stage still runs (the Framework calls it
# on both the success and the failure path), so it removes this task's private
# container, then its transient files, and verifies that no measurement process
# of this run is still alive.  It is idempotent and safe to call twice.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_pcre_runtime() {
    initialize_runtime || return $?

    # Removing the container first stops every process it owns, which keeps the
    # leftover scan below from racing the cleanup.
    remove_pcre_container || return $?

    local leftover=0 pid
    for pid in $(pgrep -f "${PCRE_BENCH_BIN}" 2>/dev/null || true); do
        if [[ -r "/proc/${pid}/cmdline" ]] && \
            tr '\0' ' ' < "/proc/${pid}/cmdline" | grep -q -F "${PERF_WORK_DIR}"; then
            fail_message "measurement process ${pid} of this run is still alive"
            leftover=$((leftover + 1))
        fi
    done
    if (( leftover > 0 )); then
        # Try to terminate only the processes proven to belong to this run.
        for pid in $(pgrep -f "${PCRE_BENCH_BIN}" 2>/dev/null || true); do
            if [[ -r "/proc/${pid}/cmdline" ]] && \
                tr '\0' ' ' < "/proc/${pid}/cmdline" | grep -q -F "${PERF_WORK_DIR}"; then
                kill -TERM "${pid}" 2>/dev/null || true
            fi
        done
        return 60
    fi

    rm -rf -- "${TMPDIR}" 2>/dev/null || true
    mkdir -p "${TMPDIR}"
    # Never expand an unset state directory: "${PCRE_STATE_DIR}/tmp" with an empty
    # variable would remove the host /tmp.
    if [[ -n "${PCRE_STATE_DIR}" ]]; then
        rm -rf -- "${PCRE_STATE_DIR}/tmp" 2>/dev/null || true
    fi
    log_message "stop stage: private container removed, transient files cleaned"
    return 0
}
