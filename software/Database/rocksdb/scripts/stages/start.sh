#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

prepare_rocksdb_benchmark_data() {
    initialize_runtime || return $?
    if [[ ! -s "${YCSB_DIST_DIR}/bin/ycsb" ]]; then
        log_message "ERROR: YCSB RocksDB binding is not built"
        return 40
    fi
    if [[ -e "${BENCH_DATA_DIR}" ]]; then
        log_message "ERROR: benchmark data directory already exists: ${BENCH_DATA_DIR}"
        return 20
    fi
    mkdir -p "${BENCH_DATA_DIR}"
    log_message "prepared task-private benchmark data directory: ${BENCH_DATA_DIR}"
}
