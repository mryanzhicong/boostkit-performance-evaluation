#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_hnswlib_runtime() {
    initialize_runtime || return $?
    if [[ ! -x "${SRA_DIR}/hnswlib_test" ]]; then
        log "ERROR: sra_test hnswlib_test is unavailable"
        return 40
    fi
    log "sra_test hnswlib_test is ready"
}
