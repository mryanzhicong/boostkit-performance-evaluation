#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_python_runtime() {
    log_message "python benchmark has no background service to stop"
}
