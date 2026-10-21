#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_hnswlib_runtime() {
    log "hnswlib benchmark has no background service to stop"
}
