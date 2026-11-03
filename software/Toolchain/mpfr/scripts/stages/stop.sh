#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_mpfr_runtime() {
    remove_mpfr_container || return $?
    log_message "MPFR benchmark has no background service to stop"
}
