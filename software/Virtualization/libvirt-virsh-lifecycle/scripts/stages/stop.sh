#!/usr/bin/env bash
# Stop stage: destroy and undefine every lifecycle VM and drop the private work tree.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../common.sh"

stop_libvirt_virsh_lifecycle_runtime() {
    initialize_runtime || return $?
    load_libvirt_vms || return $?
    sweep_libvirt_stale_vms || true
    stop_all_libvirt_vms || return $?
    if [[ -n "${PERF_WORK_DIR:-}" && "${PERF_WORK_DIR}" == /home/runner/boostkit-perf/libvirt-virsh-lifecycle/* ]]; then
        rm -rf -- "${PERF_WORK_DIR}" || return 70
    fi
    log 'stop stage completed: no lifecycle VM is left behind'
    return 0
}
