#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_envoy_runtime() {
    local name
    initialize_runtime || return $?
    stop_envoy_process "${DIRECT_PID_FILE}"
    stop_envoy_process "${PROXY_PID_FILE}"
    stop_envoy_process "${BACKEND_PID_FILE}"
    for name in direct proxy backend; do
        if [[ -f "${RUNTIME_DIR}/${name}.log" ]]; then
            cp -- "${RUNTIME_DIR}/${name}.log" "${RESULTS_DIR}/envoy-${name}.log" || return 50
        fi
    done
    rm -rf -- "${RUNTIME_DIR}"
    log_message "stopped isolated Envoy benchmark services"
}
