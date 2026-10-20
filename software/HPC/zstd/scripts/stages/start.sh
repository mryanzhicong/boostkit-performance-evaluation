#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_zstd_runtime() {
    initialize_runtime || return $?
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log "ERROR: lzbench executable is unavailable"
        return 40
    }
    log "Zstd lzbench runtime is ready"
}
