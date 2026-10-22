#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_folly_runtime() {
    configure_runtime_paths || return $?
    local pid_file="${SERVICE_DIR}/server.pid" server_pid command_line
    [[ -s "${pid_file}" ]] || return 0
    server_pid="$(< "${pid_file}")"
    [[ "${server_pid}" =~ ^[0-9]+$ ]] || return 70
    if [[ -r "/proc/${server_pid}/cmdline" ]]; then
        command_line="$(tr '\0' ' ' < "/proc/${server_pid}/cmdline")"
        [[ "${command_line}" == *"${SERVER_BINARY}"* ]] || {
            log_message 'ERROR: PID file no longer identifies this press_server'
            return 70
        }
        kill "${server_pid}" || return 70
    fi
    rm -f -- "${pid_file}"
    log_message 'AccLibBenchmark press_server stopped'
}
