#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

cleanup_rocksdb_benchmark_data() {
    initialize_runtime || return $?
    if docker container inspect "${ROCKSDB_CONTAINER_NAME}" >/dev/null 2>&1; then
        if [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.rocksdb.run-id"}}' "${ROCKSDB_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]]; then
            log_message "ERROR: refusing to remove container without this task's ownership label: ${ROCKSDB_CONTAINER_NAME}"
            return 70
        fi
        docker stop --time 30 "${ROCKSDB_CONTAINER_NAME}" >/dev/null || return 70
        docker rm "${ROCKSDB_CONTAINER_NAME}" >/dev/null || return 70
        log_message "removed managed RocksDB container ${ROCKSDB_CONTAINER_NAME}"
    fi
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
