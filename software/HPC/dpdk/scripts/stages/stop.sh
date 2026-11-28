#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_dpdk_runtime() {
    configure_runtime_paths || return $?
    command -v docker >/dev/null 2>&1 || return 0
    remove_dpdk_container || return $?
    log "managed DPDK container stopped: ${DPDK_CONTAINER_NAME}"
}
