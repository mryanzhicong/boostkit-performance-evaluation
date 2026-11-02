#!/usr/bin/env bash
# Stateless benchmark: no service was started, so cleanup is a safe no-op that
# can be called repeatedly on both the success and the failure path.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_fbthrift_runtime() {
    configure_runtime_paths || return 60
    log_message "ProtocolBench runs in the foreground; no service to stop"
    return 0
}
