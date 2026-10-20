#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_snappy_runtime() {
    log "Snappy benchmark has no background service to stop"
}
