#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

cleanup_rocksdb_benchmark_data() {
    initialize_runtime || return $?
    if [[ ! -e "${BENCH_DATA_DIR}" ]]; then
        log_message "benchmark data directory is already absent"
        return 0
    fi
    if [[ "${BENCH_DATA_DIR}" != "${ROCKSDB_DATA_ROOT}" ]]; then
        log_message "ERROR: refusing to remove unexpected data directory: ${BENCH_DATA_DIR}"
        return 70
    fi
    rm -rf -- "${BENCH_DATA_DIR}"
    log_message "removed task-private benchmark data directory: ${BENCH_DATA_DIR}"
}
