#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_unixbench_runtime() {
    initialize_runtime || return $?
    stop_unixbench_vm || return $?
    log 'managed UnixBench reference VM stopped'
}
