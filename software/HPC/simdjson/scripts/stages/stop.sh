#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_simdjson_runtime() {
    simdjson_configure_paths || return $?
    if ! command -v docker >/dev/null 2>&1; then
        log_message 'Docker is unavailable; no managed container to stop'
        return 0
    fi
    remove_simdjson_container || return $?
    sweep_simdjson_stale_containers || true
    if [[ -n "${SIMDJSON_CONTAINER_NAME}" ]] && docker container inspect "${SIMDJSON_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: managed container still exists after cleanup: ${SIMDJSON_CONTAINER_NAME}"
        return 60
    fi
    log_message "managed container stopped: ${SIMDJSON_CONTAINER_NAME:-<none>}"
}
