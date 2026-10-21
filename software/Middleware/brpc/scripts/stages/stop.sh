#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_brpc_service() {
    configure_runtime_paths || return $?
    local stop_status=0 server_pid
    server_pid="$(read_pid_file "${SERVER_PID_FILE}")"
    if process_is_alive "${server_pid}"; then
        terminate_process_gracefully "${server_pid}" "official performance server" || stop_status=1
    fi
    rm -f "${SERVER_PID_FILE}"
    if [[ -n "${server_pid}" ]] && port_is_free "${RDMA_SERVER_PORT}"; then
        log_message "official performance server has stopped"
    elif [[ -n "${server_pid}" ]]; then
        log_message "ERROR: port ${RDMA_SERVER_PORT} is still occupied after stop"
        stop_status=1
    else
        log_message "brpc benchmark has no running service to stop"
    fi
    return "${stop_status}"
}
