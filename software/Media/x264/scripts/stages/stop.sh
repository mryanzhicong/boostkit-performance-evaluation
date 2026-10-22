#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_x264_runtime() {
    log_message "x264 benchmark has no background service to stop"
}
