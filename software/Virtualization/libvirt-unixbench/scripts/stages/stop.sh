#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_libvirt_unixbench_runtime() {
    initialize_runtime || return $?
    load_libvirt_vms || true
    stop_libvirt_vms
    return 0
}
