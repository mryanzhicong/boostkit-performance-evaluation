#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Read one process command line to be able to tell our own measured servers apart
# from unrelated processes of other cases running on the same machine.
process_cmdline() {
    local pid="$1"
    tr '\0' ' ' < "/proc/${pid}/cmdline" 2>/dev/null || true
}

process_is_ours() {
    local pid="$1"
    local cmdline
    cmdline="$(process_cmdline "${pid}")"
    [[ -z "${cmdline}" ]] && return 1
    [[ -z "${NEXT_BIN}" ]] && return 1
    [[ "${cmdline}" == *"${NEXT_BIN}"* ]] || return 1
    [[ "${cmdline}" == *" start "* || "${cmdline}" == *"start"* ]] || return 1
    return 0
}

# Stop stage: no measured Next.js server may survive the test stage.  A stale
# listener would silently make the next run measure the wrong process, so a
# leftover server is a stop failure (exit code 50) instead of a warning.
stop_nextjs_runtime() {
    local pid
    local owned=()
    for pid in /proc/[0-9]*; do
        pid="${pid#/proc/}"
        [[ "${pid}" == "$$" ]] && continue
        if process_is_ours "${pid}"; then
            owned+=("${pid}")
        fi
    done
    if [[ "${#owned[@]}" -eq 0 ]]; then
        log_message "no measured Next.js server process is still running"
        return 0
    fi
    log_message "terminating leftover Next.js server process(es): ${owned[*]}"
    for pid in "${owned[@]}"; do
        kill -TERM "${pid}" 2>/dev/null || true
    done
    local waited=0
    while [[ "${waited}" -lt 200 ]]; do
        local remaining=()
        for pid in "${owned[@]}"; do
            if [[ -d "/proc/${pid}" ]] && process_is_ours "${pid}"; then
                remaining+=("${pid}")
            fi
        done
        if [[ "${#remaining[@]}" -eq 0 ]]; then
            break
        fi
        sleep 0.1
        waited=$((waited + 1))
    done
    for pid in "${owned[@]}"; do
        if [[ -d "/proc/${pid}" ]] && process_is_ours "${pid}"; then
            kill -KILL "${pid}" 2>/dev/null || true
        fi
    done
    for pid in "${owned[@]}"; do
        if [[ -d "/proc/${pid}" ]] && process_is_ours "${pid}"; then
            fail_message "failed to terminate the measured server process ${pid}"
            return 50
        fi
    done
    log_message "Next.js server stop completed"
    return 0
}
