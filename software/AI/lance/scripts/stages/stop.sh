#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_lance_runtime() {
    configure_runtime_paths || return $?
    command -v docker >/dev/null 2>&1 || return 0
    remove_lance_container || return $?
    log 'managed Lance container stopped'
}
