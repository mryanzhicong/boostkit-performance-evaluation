#!/usr/bin/env bash
#
# Stop stage: terminate only processes that belong to this case's staged app.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_bcrypt_runtime() {
    initialize_runtime || return $?
    # Removing the container first terminates every measured process it owns.
    remove_bcrypt_container || return $?
    local pid killed=0
    for pid in /proc/[0-9]*; do
        pid="${pid##*/}"
        [[ "${pid}" == "$$" ]] && continue
        if [[ -r "/proc/${pid}/cmdline" ]] && cat "/proc/${pid}/cmdline" 2>/dev/null | tr '\0' ' ' | grep -qF "${APP_DIR}"; then
            kill -TERM "${pid}" 2>/dev/null && killed=$((killed + 1))
        fi
    done
    if [[ "${killed}" -gt 0 ]]; then
        sleep 1
        for pid in /proc/[0-9]*; do
            pid="${pid##*/}"
            [[ "${pid}" == "$$" ]] && continue
            if [[ -r "/proc/${pid}/cmdline" ]] && cat "/proc/${pid}/cmdline" 2>/dev/null | tr '\0' ' ' | grep -qF "${APP_DIR}"; then
                kill -KILL "${pid}" 2>/dev/null || true
            fi
        done
        log_message "terminated ${killed} leftover bcrypt measurement process(es)"
    else
        log_message "no bcrypt measurement process is running"
    fi
}
