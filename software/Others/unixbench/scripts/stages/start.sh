#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_unixbench_runtime() {
    initialize_runtime || return $?
    check_unixbench_vm || return $?
    vm_exec test -x "${GUEST_RUN_DIR}/pgms/dhry2reg" || {
        log 'ERROR: built UnixBench runtime is unavailable in the reference VM'; return 40;
    }
    vm_exec perl -MTime::HiRes -e 1 || {
        log 'ERROR: Time::HiRes is not available inside the reference VM'; return 40;
    }
    log 'UnixBench runtime is ready inside the reference VM'
}
