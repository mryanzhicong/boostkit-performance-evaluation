#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_fbthrift_runtime() {
    local status=0
    if command -v docker >/dev/null 2>&1 && fbthrift_container_exec bash -c 'pkill -f press_server' >/dev/null 2>&1; then
        log_message 'stopped press_server inside the private container'
        sleep 2
    fi
    remove_fbthrift_container || status=$?
    rm -f "${SERVICE_DIR}/port" "${SERVICE_DIR}/numa-node" "${SERVICE_DIR}/numa-nodes"
    return "${status}"
}
