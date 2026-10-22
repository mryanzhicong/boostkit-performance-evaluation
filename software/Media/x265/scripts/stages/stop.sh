#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_x265_runtime() {
    log_message "x265 benchmark has no background service to stop"
}
