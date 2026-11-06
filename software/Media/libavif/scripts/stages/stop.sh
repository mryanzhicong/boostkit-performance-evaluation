#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_libavif_runtime() {
    initialize_runtime || return $?
    remove_libavif_container || return $?
    log_message "stop stage completed; no background service remains"
}
