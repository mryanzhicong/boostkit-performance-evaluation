#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_mpc_runtime() {
    remove_libmpc_container || return $?
    log_message "MPC benchmark has no background service to stop"
}
