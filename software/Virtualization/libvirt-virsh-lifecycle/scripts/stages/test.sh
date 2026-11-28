#!/usr/bin/env bash
# Test stage: run the measured `virsh start` / `virsh list` / `virsh console`
# lifecycle repetitions and aggregate them.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../common.sh"

write_lifecycle_rep() {
    local rep="$1" start_ms="$2" console_ms="$3" boot_seconds="$4" status="$5"
    local start_ok=false list_ok=false console_ok=false
    [[ "${status}" == passed ]] && start_ok=true list_ok=true console_ok=true
    python3 - "${REP_DIR}/rep${rep}.json" "${rep}" "${start_ms}" "${console_ms}" \
        "${boot_seconds}" "${status}" "${start_ok}" "${list_ok}" "${console_ok}" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
payload = {
    "repetition": int(sys.argv[2]),
    "virsh_start_ms": int(sys.argv[3]),
    "virsh_console_probe_ms": int(sys.argv[4]),
    "guest_boot_observed_seconds": float(sys.argv[5]),
    "status": sys.argv[6],
    "virsh_start_ok": sys.argv[7] == "true",
    "virsh_list_running_ok": sys.argv[8] == "true",
    "virsh_console_ok": sys.argv[9] == "true",
}
path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
PY
}

run_lifecycle_rep() {
    local rep="$1" index=0 start_ms console_ms begin_ns end_ns boot_seconds
    log "repetition ${rep}/${LIBVIRT_REPS}: virsh start, virsh list and virsh console"
    check_libvirt_vms_defined || return $?
    begin_ns="$(date +%s%N)"
    start_ms="$(start_libvirt_vm_timed "${index}")" || return $?
    # The guest address proves that the guest actually booted, so the observed
    # boot time is measured up to that lease, not up to the virsh call.
    wait_libvirt_vm_address "${index}" || { log 'ERROR: the VM never obtained a network address'; return 40; }
    wait_libvirt_vm_ssh "${index}" || { log 'ERROR: the guest never answered over SSH'; return 40; }
    end_ns="$(date +%s%N)"
    boot_seconds="$(awk -v begin="${begin_ns}" -v end="${end_ns}" \
        'BEGIN { printf "%.3f", (end - begin) / 1000000000 }')"
    console_ms="$(console_libvirt_vm_probe "${index}" "${REP_DIR}/rep${rep}-console.log")" || return $?
    if ! vm_exec "${index}" true >/dev/null 2>&1; then
        log 'WARNING: the guest does not answer over SSH after the console probe'
    fi
    write_lifecycle_rep "${rep}" "${start_ms}" "${console_ms}" "${boot_seconds}" passed
    log "repetition ${rep}: virsh start ${start_ms} ms, boot ${boot_seconds} s, console ready in ${console_ms} ms"
    graceful_shutdown_lifecycle_vm "${index}" || return $?
    sudo -n virsh undefine "${LIBVIRT_VM_NAMES[${index}]}" --nvram >/dev/null 2>&1 || \
        sudo -n virsh undefine "${LIBVIRT_VM_NAMES[${index}]}" >/dev/null 2>&1 || true
    create_libvirt_vms || return $?
    return 0
}

run_libvirt_virsh_lifecycle_benchmarks() {
    local rep status=0
    # Every stage runs in its own process, so the runtime and the VM plan have to
    # be loaded again before the repetitions touch LIBVIRT_VM_NAMES.
    initialize_runtime || return $?
    resolve_libvirt_accel || return $?
    require_libvirt_host || return $?
    load_libvirt_vms || return $?
    check_libvirt_vms_defined || return $?
    REP_DIR="${RESULTS_DIR}/reps"
    rm -rf "${REP_DIR}"
    mkdir -p "${REP_DIR}"
    export REP_DIR
    for ((rep = 1; rep <= LIBVIRT_REPS; rep++)); do
        if ! run_lifecycle_rep "${rep}"; then
            status=$?
            write_lifecycle_rep "${rep}" 0 0 0 failed || true
            log "ERROR: repetition ${rep} failed with status ${status}"
            break
        fi
    done
    ((status == 0)) || return "${status}"
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RESULTS_DIR}" "${RESULTS_DIR}/benchmark_virsh_lifecycle.json" \
        || return $?
    log "test stage completed: ${LIBVIRT_REPS} repetitions measured"
}
