#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_libvirt_unixbench_runtime() {
    initialize_runtime || return $?
    load_libvirt_vms || return $?
    check_libvirt_vms || return $?
    local index=0
    vm_exec "${index}" test -x "${UNIXBENCH_GUEST_DIR}/pgms/dhry2reg" || {
        log 'ERROR: the built UnixBench runtime is unavailable inside the reference VM'
        return 40
    }
    vm_exec "${index}" perl -MTime::HiRes -e 1 || {
        log 'ERROR: perl-Time-HiRes is not available inside the reference VM'
        return 40
    }
    log "UnixBench runtime is ready inside ${LIBVIRT_VM_COUNT} reference VMs"
}
