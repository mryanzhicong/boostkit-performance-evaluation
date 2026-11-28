#!/usr/bin/env bash
# Stop-stage entry point: destroy the transient domain, keep the host data pool.
set -o pipefail

FIO_CASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck disable=SC1091
source "${FIO_CASE_DIR}/scripts/common.sh"

stop_fio_runtime() {
    configure_runtime_paths
    stop_fio_vm || return $?
    cat > "${RESULTS_DIR}/stop-state.json" <<JSON
{
  "vm_name": "${FIO_VM_NAME}",
  "domain_removed": true,
  "logical_volumes_kept": ${FIO_LV_COUNT},
  "volume_group": "${FIO_VG_NAME}"
}
JSON
    return 0
}
