#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_rocksdb_benchmarks() {
    initialize_runtime || return $?
    if [[ ! -s "${YCSB_DIST_DIR}/bin/ycsb" || ! -d "${BENCH_DATA_DIR}" ]]; then
        log_message "ERROR: build or benchmark data preparation is incomplete"
        return 50
    fi
    python3 "${SCRIPT_DIR}/scripts/results/run_ycsb.py" \
        "${YCSB_DIST_DIR}" "${RESULTS_DIR}/results.json" \
        "${RESULTS_DIR}/ycsb_raw.log" || return 50
}
