#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_rapidjson_runtime() {
    rapidjson_configure_paths || return $?
    if ! command -v docker >/dev/null 2>&1; then
        log_message 'Docker is unavailable; no managed container to stop'
        return 0
    fi
    remove_rapidjson_container || return $?
    sweep_rapidjson_stale_containers || true
    if [[ -n "${RAPIDJSON_CONTAINER_NAME}" ]] && docker container inspect "${RAPIDJSON_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: managed container still exists after cleanup: ${RAPIDJSON_CONTAINER_NAME}"
        return 60
    fi
    log_message "managed container stopped: ${RAPIDJSON_CONTAINER_NAME:-<none>}"
}
