#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_redis_service() {
    local pid="" attempt

    initialize_runtime || return $?
    if [[ -f "${PID_FILE}" ]]; then
        pid="$(<"${PID_FILE}")"
    fi
    if [[ -x "${REDIS_CLI_BIN}" ]]; then
        "${REDIS_CLI_BIN}" -h 127.0.0.1 -p "${REDIS_SERVICE_PORT}" \
            SHUTDOWN NOSAVE >/dev/null 2>&1 || true
    fi
    if [[ "${pid}" =~ ^[0-9]+$ ]]; then
        for attempt in {1..20}; do
            kill -0 "${pid}" 2>/dev/null || break
            sleep 1
        done
        if kill -0 "${pid}" 2>/dev/null; then
            kill -TERM "${pid}" 2>/dev/null || true
            sleep 1
        fi
        if kill -0 "${pid}" 2>/dev/null; then
            kill -KILL "${pid}" 2>/dev/null || true
        fi
    fi
    if [[ -x "${REDIS_CLI_BIN}" ]] && \
       "${REDIS_CLI_BIN}" -h 127.0.0.1 -p "${REDIS_SERVICE_PORT}" PING >/dev/null 2>&1; then
        log_message "ERROR: Redis service is still reachable on port ${REDIS_SERVICE_PORT}"
        return 50
    fi
    if [[ -d "${SERVICE_DIR}" ]]; then
        if [[ "${SERVICE_DIR}" != "${REDIS_DATA_ROOT}" ]]; then
            log_message "ERROR: refusing to remove unexpected Redis data directory: ${SERVICE_DIR}"
            return 70
        fi
        rm -rf -- "${SERVICE_DIR}"
    fi
    log_message "Redis service stopped and task data directory removed"
}
