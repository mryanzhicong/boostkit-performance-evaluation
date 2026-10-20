#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_lz4_runtime() {
    log "LZ4 lzbench has no background service to stop"
}
