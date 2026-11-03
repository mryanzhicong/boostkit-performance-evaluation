#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_unixbench_runtime() {
    initialize_runtime || return $?
    if ! command -v docker >/dev/null 2>&1; then
        log 'no Docker daemon; no managed UnixBench container to stop'
        return 0
    fi
    remove_unixbench_container || return $?
    log 'managed UnixBench container stopped'
}
