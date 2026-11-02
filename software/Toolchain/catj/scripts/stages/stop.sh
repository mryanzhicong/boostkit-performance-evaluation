#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

find_case_processes() {
    local pattern="$1" proc_dir pid cmdline
    for proc_dir in /proc/[0-9]*; do
        pid="${proc_dir#/proc/}"
        [[ "${pid}" =~ ^[0-9]+$ ]] || continue
        cmdline="$(cat "${proc_dir}/cmdline" 2>/dev/null | tr '\0' ' ' || true)"
        [[ -n "${cmdline}" ]] || continue
        if [[ "${cmdline}" == *"${pattern}"* ]]; then
            printf '%s\n' "${pid}"
        fi
    done
}

stop_catj_runtime() {
    initialize_runtime || return $?
    local -a pids=()
    local pid attempt survivors
    mapfile -t pids < <(find_case_processes "${PERF_WORK_DIR}")
    if [[ "${#pids[@]}" -eq 0 ]]; then
        log_message "no catj measurement process is running"
        return 0
    fi
    log_message "stopping ${#pids[@]} leftover measurement process(es) from ${PERF_WORK_DIR}"
    for pid in "${pids[@]}"; do
        kill -TERM "${pid}" 2>/dev/null || true
    done
    for attempt in 1 2 3 4 5 6 7 8 9 10; do
        survivors=0
        for pid in "${pids[@]}"; do
            if kill -0 "${pid}" 2>/dev/null; then
                survivors=$((survivors + 1))
            fi
        done
        [[ "${survivors}" -eq 0 ]] && break
        sleep 1
    done
    if [[ "${survivors}" -ne 0 ]]; then
        log_message "processes ignored SIGTERM, sending SIGKILL"
        for pid in "${pids[@]}"; do
            kill -KILL "${pid}" 2>/dev/null || true
        done
        sleep 1
    fi
    mapfile -t pids < <(find_case_processes "${PERF_WORK_DIR}")
    if [[ "${#pids[@]}" -ne 0 ]]; then
        log_message "ERROR: measurement processes remain after cleanup: ${pids[*]}"
        return 50
    fi
    log_message "catj measurement processes are stopped"
}
