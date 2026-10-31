#!/usr/bin/env bash
# Stop stage: GDB scenarios are short-lived processes, so the stage only has to prove
# that no measured GDB, no ``make check-gdb`` and no inferior process survived the
# test stage.
set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

find_leftover_pids() {
    local pid cmdline
    for pid_dir in /proc/[0-9]*; do
        pid="${pid_dir#/proc/}"
        cmdline="$(cat "${pid_dir}/cmdline" 2>/dev/null | tr '\0' ' ' || true)"
        if [[ -z "${cmdline}" ]]; then
            continue
        fi
        case "${cmdline}" in
            *"${GDB_BIN}"*|*"${GDB_BUILD_DIR}/gdb/testsuite"*|*"check-gdb"*)
                printf '%s\n' "${pid}"
                ;;
        esac
    done
}

stop_gdb_runtime() {
    initialize_runtime || return $?
    local pids
    pids="$(find_leftover_pids)"
    if [[ -z "${pids}" ]]; then
        log_message "no leftover GDB or testsuite processes"
        return 0
    fi
    log_message "terminating leftover processes: $(printf '%s ' ${pids})"
    local pid
    for pid in ${pids}; do
        kill -TERM "${pid}" 2>/dev/null || true
    done
    sleep 1
    pids="$(find_leftover_pids)"
    if [[ -n "${pids}" ]]; then
        for pid in ${pids}; do
            kill -KILL "${pid}" 2>/dev/null || true
        done
        sleep 1
    fi
    pids="$(find_leftover_pids)"
    if [[ -n "${pids}" ]]; then
        fail_message "the following processes could not be stopped: $(printf '%s ' ${pids})"
        return 50
    fi
    log_message "leftover GDB processes stopped"
    return 0
}
