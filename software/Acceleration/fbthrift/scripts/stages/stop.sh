#!/usr/bin/env bash
# Stateless benchmark: no service was started, so cleanup removes only this
# task's private container and is safe to call repeatedly on both the success and
# the failure path.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_fbthrift_runtime() {
    configure_runtime_paths || return 60
    remove_fbthrift_container || return $?
    log_message "ProtocolBench runs in the foreground; no service to stop, private container removed"
    return 0
}
