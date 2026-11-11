#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_libwebp_runtime() {
    initialize_runtime || return $?
    remove_libwebp_container || return $?
    log_message "stop stage completed; no background service remains"
}
