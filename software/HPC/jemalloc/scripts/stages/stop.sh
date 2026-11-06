#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_jemalloc_runtime() {
    local arch="$(jemalloc_arch "${EXPECTED_ARCH:-$(uname -m)}")" run_id="${PERF_RUN_ID:-}"
    [[ "${run_id}" =~ ^[A-Za-z0-9._-]+$ ]] || { jemalloc_log 'ERROR: unsafe or missing run ID'; return 10; }
    JEMALLOC_CONTAINER="boostkit-jemalloc-${arch}-${run_id}"
    command -v docker >/dev/null 2>&1 || { jemalloc_log 'Docker is unavailable; no managed container to stop'; return 0; }
    jemalloc_stop_container "${run_id}" || return $?
    jemalloc_log "managed container stopped: ${JEMALLOC_CONTAINER}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    stop_jemalloc_runtime
fi
