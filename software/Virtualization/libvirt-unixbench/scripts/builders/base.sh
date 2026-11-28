#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_libvirt_unixbench_base() {
    local variant_file="${RESULTS_DIR}/build_variant.json"
    initialize_runtime || return $?
    [[ "${SOFTWARE_VERSION}" == 6.0.1 ]] || {
        log 'ERROR: the UnixBench master snapshot reports 6.0.1; only that version is supported'
        return 10
    }
    resolve_libvirt_accel || return $?
    require_libvirt_host || return $?
    sweep_libvirt_stale_vms
    plan_libvirt_vms || return $?
    load_libvirt_vms
    create_libvirt_vms || return $?
    start_libvirt_vms || return $?
    verify_libvirt_guest_os || return $?
    prepare_all_libvirt_guests || return $?
    capture_libvirt_vm_environment || return $?
    printf '6.0.1\n' > "${PERF_ACTUAL_VERSION_FILE}"
    export LIBVIRT_VM_COUNT LIBVIRT_VM_CORES LIBVIRT_VM_MEM_MIB LIBVIRT_COPIES
    python3 - "${variant_file}" <<'PY'
import json
import os
import sys
from datetime import datetime, timezone

payload = {
    "software": "libvirt-unixbench",
    "variant": os.environ.get("PERF_VARIANT", "base"),
    "version": os.environ.get("SOFTWARE_VERSION", "6.0.1"),
    "architecture": os.environ.get("EXPECTED_ARCH", ""),
    "benchmark": "unixbench_system_index",
    "unixbench_archive": "byte-unixbench-master.tar.gz",
    "unixbench_archive_sha256": "f57ab9d1d61e920bce58ee05c82c70dca8490d30662d21d7bef1579a1a797125",
    "execution_environment": "kvm-vm-fleet",
    "vm_count": int(os.environ.get("LIBVIRT_VM_COUNT", "0")),
    "vm_vcpus": int(os.environ.get("LIBVIRT_VM_CORES", "4")),
    "vm_memory_mib": int(os.environ.get("LIBVIRT_VM_MEM_MIB", "8192")),
    "copies_per_vm": int(os.environ.get("LIBVIRT_COPIES", "4")),
    "guest_os": "openEuler 24.03 LTS SP4",
    "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
}
with open(sys.argv[1], "w", encoding="utf-8") as handle:
    json.dump(payload, handle, indent=2, ensure_ascii=False)
    handle.write("\n")
PY
    log "build stage completed: ${LIBVIRT_VM_COUNT} VMs with UnixBench 6.0.1 (master snapshot) ready"
}

build_libvirt_unixbench() {
    build_libvirt_unixbench_base "$@"
}
