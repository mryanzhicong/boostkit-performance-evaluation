#!/usr/bin/env bash
# Start stage: the lifecycle VM must exist, stay shut off and be startable.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../common.sh"

start_libvirt_virsh_lifecycle_runtime() {
    initialize_runtime || return $?
    require_libvirt_host || return $?
    load_libvirt_vms || return $?
    check_libvirt_vms_defined || return $?
    local version
    version="$(sudo -n virsh version 2>/dev/null | awk '/Using library/ {print $NF}' | head -n 1)"
    log "libvirt ${version:-unknown} is ready; ${LIBVIRT_VM_COUNT} VM(s) defined and shut off"
    sudo -n virsh dominfo "${LIBVIRT_VM_NAMES[0]}" 2>/dev/null | sed -n '1,12p' >&2 || true
    return 0
}
