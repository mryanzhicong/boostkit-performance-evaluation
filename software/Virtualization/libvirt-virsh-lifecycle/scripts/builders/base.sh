#!/usr/bin/env bash
# Build the reference lifecycle VM from the pinned openEuler 22.03 LTS SP3 image.
#
# The VM is defined once and left shut off: every measured repetition performs the
# `virsh start` / `virsh list` / `virsh console` sequence itself.

write_lifecycle_build_evidence() {
    local release="$1"
    python3 - "${RESULTS_DIR}/build_variant.json" "${release}" <<'PY'
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

path = Path(sys.argv[1])
release = sys.argv[2]
payload = {
    "software": "libvirt-virsh-lifecycle",
    "variant": os.environ["PERF_VARIANT"],
    "version": os.environ["SOFTWARE_VERSION"],
    "architecture": os.environ["EXPECTED_ARCH"],
    "benchmark": "virsh_lifecycle",
    "execution_environment": "kvm-vm",
    "guest_os": f"openEuler {release}",
    "vm_count": int(os.environ.get("LIBVIRT_VM_COUNT", "1")),
    "vm_vcpus": int(os.environ["LIBVIRT_VM_CORES"]),
    "vm_memory_mib": int(os.environ["LIBVIRT_VM_MEM_MIB"]),
    "vcpu_pinning": "one vCPU per consecutive host core of a single NUMA node",
    "memory_binding": "numatune strict to the NUMA node of the pinned cores",
    "accelerator": os.environ.get("LIBVIRT_VM_ACCEL_USED", ""),
    "repetitions": int(os.environ["LIBVIRT_REPS"]),
    "warmup_repetitions": int(os.environ["LIBVIRT_WARMUP_REPS"]),
    "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
}
path.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(json.dumps(payload, indent=2, ensure_ascii=False))
PY
}

build_libvirt_virsh_lifecycle_base() {
    local release
    require_libvirt_host || return $?
    resolve_libvirt_accel || return $?
    sweep_libvirt_stale_vms || return $?
    plan_libvirt_vms || return $?
    load_libvirt_vms || return $?
    create_libvirt_vms || return $?

    log 'booting the reference VM once to verify the guest operating system'
    start_libvirt_vm_timed 0 >/dev/null || return $?
    wait_libvirt_vm_address 0 || { log 'ERROR: the reference VM never obtained an address'; return 40; }
    wait_libvirt_vm_ssh 0 || { log 'ERROR: the reference VM never answered over SSH'; return 40; }
    release="$(verify_libvirt_guest_os)" || return $?
    # The Framework compares this file with the requested version, so the canonical
    # case version is recorded while the raw guest release stays in the evidence.
    printf '%s\n' "${SOFTWARE_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}"
    graceful_shutdown_lifecycle_vm 0 || return $?
    virsh_wait_state "${LIBVIRT_VM_NAMES[0]}" "shut off" || {
        log 'ERROR: the reference VM did not return to the shut off state'; return 40
    }
    sudo -n virsh dominfo "${LIBVIRT_VM_NAMES[0]}" >/dev/null 2>&1 || {
        log 'ERROR: the reference VM must stay defined for the measured repetitions'; return 40
    }

    write_lifecycle_build_evidence "${release#openEuler }" >/dev/null || return $?
    log "build stage completed: openEuler ${release} VM defined, shut off and ready for the virsh lifecycle repetitions"
}
