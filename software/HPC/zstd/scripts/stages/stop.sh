#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_zstd_runtime() {
    log "Zstd lzbench has no background service to stop"
}
