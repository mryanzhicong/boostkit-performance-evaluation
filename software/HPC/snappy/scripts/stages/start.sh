#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_snappy_runtime() {
    initialize_runtime || return $?
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log "ERROR: lzbench executable is unavailable"
        return 40
    }
    ldd "${BENCHMARK_BIN}" | grep -Fq "=> ${BUILD_DIR}/libsnappy.so.1 " || {
        log "ERROR: lzbench is not linked to this run's Snappy shared library"
        return 40
    }
    log "Snappy lzbench runtime is ready"
}
