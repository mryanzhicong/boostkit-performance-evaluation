#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_redis_service() {
    local cleanup_status=0 instance_id

    initialize_runtime || return $?
    load_started_instance_count || return 50
    for ((instance_id = REDIS_INSTANCE_COUNT; instance_id >= 1; instance_id--)); do
        configure_redis_instance "${instance_id}" || return 50
        if docker container inspect "${REDIS_CONTAINER_NAME}" >/dev/null 2>&1; then
            if [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.redis.run-id"}}' "${REDIS_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]]; then
                log_message "ERROR: refusing to stop container without this task's ownership label: ${REDIS_CONTAINER_NAME}"
                cleanup_status=50
                continue
            fi
            if [[ -x "${REDIS_CLI_BIN}" ]]; then
                docker exec "${REDIS_CONTAINER_NAME}" "${REDIS_CLI_BIN}" \
                    -h 127.0.0.1 -p "${REDIS_SERVICE_PORT}" SHUTDOWN NOSAVE \
                    >/dev/null 2>&1 || true
            fi
        fi
        if ! remove_redis_container; then
            cleanup_status=50
            continue
        fi
        if [[ "${SERVICE_DIR}" != "${REDIS_INSTANCES_DIR}/${instance_id}" ]]; then
            log_message "ERROR: refusing to remove unexpected Redis instance directory: ${SERVICE_DIR}"
            cleanup_status=50
            continue
        fi
        if [[ -d "${SERVICE_DIR}" ]]; then
            rm -rf -- "${SERVICE_DIR}" || cleanup_status=50
        fi
        log_message "Redis instance ${instance_id} stopped and task data directory removed"
    done
    if (( cleanup_status == 0 )); then
        rm -f -- "${REDIS_INSTANCE_COUNT_FILE}" || cleanup_status=50
    fi
    return "${cleanup_status}"
}
