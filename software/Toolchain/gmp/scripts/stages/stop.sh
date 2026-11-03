#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_gmp_runtime() {
    remove_gmp_container || return $?
    log_message "GMP benchmark has no background service to stop"
}
