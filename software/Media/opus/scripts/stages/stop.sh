#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_opus_runtime() {
    initialize_runtime || return $?
    if ! command -v docker >/dev/null 2>&1; then
        log 'no Docker client; no managed Opus container to stop'
        return 0
    fi
    if docker container inspect "${OPUS_CONTAINER_NAME}" >/dev/null 2>&1; then
        docker logs "${OPUS_CONTAINER_NAME}" > "${RESULTS_DIR}/container_runtime.log" 2>&1 || true
    fi
    remove_opus_container || return $?
    log 'managed Opus container stopped'
}
