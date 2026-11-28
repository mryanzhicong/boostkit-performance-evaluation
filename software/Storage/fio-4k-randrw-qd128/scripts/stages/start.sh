#!/usr/bin/env bash
# Start-stage entry point: the reference VM must already be serving this run.
set -o pipefail

FIO_CASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck disable=SC1091
source "${FIO_CASE_DIR}/scripts/common.sh"

start_fio_runtime() {
    configure_runtime_paths
    check_fio_vm || return $?
    verify_fio_version || return $?
    verify_guest_block_devices || return $?
    vm_exec_shell "test -s '${FIO_GUEST_DIR}/${FIO_GUEST_JOB}'" || {
        log 'ERROR: the fio job file is missing inside the reference VM'
        return 40
    }
    vm_exec_shell "command -v fio >/dev/null && command -v taskset >/dev/null" || {
        log 'ERROR: fio or taskset is unavailable inside the reference VM'
        return 40
    }
    cat > "${RESULTS_DIR}/service-state.json" <<JSON
{
  "service": "fio-reference-vm",
  "vm_name": "${FIO_VM_NAME}",
  "vm_ip": "${FIO_VM_IP}",
  "accelerator": "${FIO_VM_ACCEL_USED}",
  "fio_version": "${FIO_ACTUAL_VERSION}",
  "logical_volumes": ${FIO_LV_COUNT},
  "status": "ready"
}
JSON
    log "fio runtime is ready inside the reference VM (${FIO_NUMJOBS} job(s), iodepth ${FIO_IODEPTH}, ${FIO_LV_COUNT} LUN(s))"
}
