#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_uavs3d_runtime() {
    initialize_runtime || return $?
    if ! command -v docker >/dev/null 2>&1; then
        log 'no Docker client; no managed uavs3d container to stop'
        return 0
    fi
    if docker container inspect "${UAVS3D_CONTAINER_NAME}" >/dev/null 2>&1; then
        docker logs "${UAVS3D_CONTAINER_NAME}" > "${RESULTS_DIR}/container_runtime.log" 2>&1 || true
    fi
    remove_uavs3d_container || return $?
    log 'managed uavs3d container stopped'
}
