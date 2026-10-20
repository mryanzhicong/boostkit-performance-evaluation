#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_lz4_runtime() {
    initialize_runtime || return $?
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log "ERROR: lzbench executable is unavailable"
        return 40
    }
    ldd "${BENCHMARK_BIN}" | grep -Fq "=> ${SOURCE_DIR}/lib/liblz4.so.1 " || {
        log "ERROR: lzbench is not linked to this run's LZ4 shared library"
        return 40
    }
    log "LZ4 lzbench runtime is ready"
}
