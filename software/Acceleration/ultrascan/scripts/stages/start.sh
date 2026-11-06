#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_ultrascan_runtime() {
    initialize_runtime || return $?
    check_ultrascan_container || return $?
    verify_measurement_inputs || return $?
    local hsbench_sha dump_sha
    hsbench_sha="$(sha256_of "${HSBENCH_BIN:-}" 2>/dev/null | cut -c1-16 || true)"
    dump_sha="$(ultrascan_container_exec sha256sum "${DUMP_DB}" | awk '{print $1}' | cut -c1-16)" || return 40
    log "ultrascan runtime is ready: hsbench=${hsbench_sha} universal_bytecode=${dump_sha}"
    log "hsbench needs no background service; the two documented scenarios run in the test stage inside the private container"
}
