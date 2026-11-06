#!/usr/bin/env bash
# Stop any bdevperf process started by this run and remove this task's private
# container.  The stage is safe to call repeatedly and on failure paths.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Only processes whose command line contains this run's private bdevperf path can
# belong to this run (the path contains the run ID), so nothing unrelated is
# touched.  It runs inside the private container, which is removed afterwards.
stop_container_bdevperf() {
    local pids
    pids="$(spdk_container_exec pgrep -f "${BDEVPERF_BIN}" 2>/dev/null || true)"
    [[ -n "${pids}" ]] || return 1
    local pid
    for pid in ${pids}; do
        log_message "stopping leftover bdevperf PID ${pid} in the container"
        spdk_container_exec kill "${pid}" 2>/dev/null || true
    done
    local attempt
    for attempt in {1..25}; do
        [[ -n "$(spdk_container_exec pgrep -f "${BDEVPERF_BIN}" 2>/dev/null || true)" ]] || return 0
        sleep 0.2
    done
    log_message "WARNING: bdevperf ignored SIGTERM in the container, sending SIGKILL"
    for pid in $(spdk_container_exec pgrep -f "${BDEVPERF_BIN}" 2>/dev/null || true); do
        spdk_container_exec kill -9 "${pid}" 2>/dev/null || true
    done
    sleep 0.5
    [[ -z "$(spdk_container_exec pgrep -f "${BDEVPERF_BIN}" 2>/dev/null || true)" ]]
}

stop_spdk_runtime() {
    configure_runtime_paths || return $?
    local pid_file="${PERF_WORK_DIR}/bdevperf.pid"
    local stopped=0 pid command_line

    if [[ -s "${pid_file}" ]]; then
        pid="$(< "${pid_file}")"
        if [[ "${pid}" =~ ^[0-9]+$ ]] && [[ -r "/proc/${pid}/cmdline" ]]; then
            command_line="$(tr '\0' ' ' < "/proc/${pid}/cmdline")"
            if [[ "${command_line}" != *"${BDEVPERF_BIN}"* ]]; then
                log_message "ERROR: PID ${pid} no longer identifies this run's bdevperf"
                return 60
            fi
            log_message "stopping host-side bdevperf PID ${pid}"
            kill "${pid}" 2>/dev/null || true
            for _ in {1..50}; do
                kill -0 "${pid}" 2>/dev/null || break
                sleep 0.2
            done
            if kill -0 "${pid}" 2>/dev/null; then
                log_message "WARNING: bdevperf PID ${pid} ignored SIGTERM, sending SIGKILL"
                kill -9 "${pid}" 2>/dev/null || true
                sleep 0.5
            fi
            if kill -0 "${pid}" 2>/dev/null; then
                log_message "ERROR: bdevperf PID ${pid} is still running"
                return 60
            fi
            stopped=1
        fi
        rm -f -- "${pid_file}"
    fi

    if check_spdk_container >/dev/null 2>&1; then
        if stop_container_bdevperf; then
            stopped=1
        fi
    fi

    if [[ "${stopped}" -eq 1 ]]; then
        log_message 'bdevperf processes for this run were stopped'
    else
        log_message 'no bdevperf process was running for this run'
    fi
    remove_spdk_container || return $?
    log_message 'private container removed; no bdevperf process is left behind'
    return 0
}
