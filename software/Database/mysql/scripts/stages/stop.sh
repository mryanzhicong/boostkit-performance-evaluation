#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_mysql_service() {
    local cleanup_status=0 instance_id
    initialize_runtime || return $?
    for ((instance_id = MYSQL_INSTANCE_COUNT; instance_id >= 1; instance_id--)); do
        configure_mysql_instance "${instance_id}" || return 50
        shutdown_mysql_server || cleanup_status=50
        if ! remove_mysql_container; then
            cleanup_status=50
            continue
        fi
        if [[ "${SERVICE_DIR}" != "${MYSQL_INSTANCES_DIR}/${instance_id}" ]]; then
            log_message "ERROR: refusing to remove unexpected MySQL instance directory: ${SERVICE_DIR}"
            cleanup_status=50
            continue
        fi
        rm -rf -- "${SERVICE_DIR}" || cleanup_status=50
        log_message "MySQL instance ${instance_id} data removed from ${SERVICE_DIR}"
    done
    return "${cleanup_status}"
}
