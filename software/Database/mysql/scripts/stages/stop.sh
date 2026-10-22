#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_mysql_service() {
    initialize_runtime || return $?
    shutdown_mysql_server || return 50
    if [[ "${SERVICE_DIR}" != "${PERF_WORK_DIR}/data" || "${SERVICE_DIR}" == / || -z "${SERVICE_DIR}" ]]; then
        log_message "ERROR: refusing to remove unexpected MySQL data directory: ${SERVICE_DIR}"
        return 50
    fi
    rm -rf -- "${SERVICE_DIR}"
    log_message "MySQL runtime data removed from ${SERVICE_DIR}"
}
