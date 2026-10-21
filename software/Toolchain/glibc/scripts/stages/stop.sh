#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_glibc_runtime() {
    log_message "glibc benchmark has no background service to stop"
}
