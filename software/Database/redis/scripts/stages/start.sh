#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_redis_service() {
    local attempt

    initialize_runtime || return $?
    if [[ ! -x "${REDIS_SERVER_BIN}" || ! -x "${REDIS_CLI_BIN}" ]]; then
        log_message "ERROR: Redis is not built; run the build stage first"
        return 40
    fi
    if [[ -e "${SERVICE_DIR}" ]]; then
        log_message "ERROR: Redis data directory already exists: ${SERVICE_DIR}"
        return 20
    fi
    if "${REDIS_CLI_BIN}" -h 127.0.0.1 -p "${REDIS_SERVICE_PORT}" PING 2>/dev/null | grep -qx PONG; then
        log_message "ERROR: port ${REDIS_SERVICE_PORT} already has a Redis service"
        return 20
    fi

    mkdir -p "${SERVICE_DIR}"
    log_message "starting isolated Redis on port ${REDIS_SERVICE_PORT} with data directory ${SERVICE_DIR}"
    if ! "${REDIS_SERVER_BIN}" \
        --bind 127.0.0.1 \
        --protected-mode yes \
        --port "${REDIS_SERVICE_PORT}" \
        --dir "${SERVICE_DIR}" \
        --daemonize yes \
        --pidfile "${PID_FILE}" \
        --logfile "${LOG_FILE}"; then
        log_message "ERROR: Redis service failed to start; see ${LOG_FILE}"
        return 40
    fi

    for attempt in {1..60}; do
        if "${REDIS_CLI_BIN}" -h 127.0.0.1 -p "${REDIS_SERVICE_PORT}" PING 2>/dev/null | grep -qx PONG; then
            log_message "Redis service is ready on port ${REDIS_SERVICE_PORT}"
            return 0
        fi
        sleep 1
    done
    log_message "ERROR: Redis service did not become ready; see ${LOG_FILE}"
    return 40
}
