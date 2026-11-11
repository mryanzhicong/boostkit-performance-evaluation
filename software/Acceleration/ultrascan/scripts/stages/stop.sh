#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_ultrascan_runtime() {
    # hsbench is a foreground benchmark: the test stage owns every process it
    # starts inside the private container, so removing this task's container also
    # terminates anything it still owns.  The function stays idempotent, which
    # makes it safe on the failure path where the container was never created.
    configure_runtime_paths || return $?
    remove_ultrascan_container || return $?
    log "ultrascan benchmark has no background service left; private container removed"
    return 0
}
