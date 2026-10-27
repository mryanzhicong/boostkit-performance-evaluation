#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_rocksdb_benchmarks() {
    initialize_runtime || return $?
    if [[ ! -s "${YCSB_DIST_DIR}/bin/ycsb" || ! -d "${BENCH_DATA_DIR}" ]]; then
        log_message "ERROR: build or benchmark data preparation is incomplete"
        return 50
    fi
    check_rocksdb_container || return 50
    docker exec -i \
        --env "PERF_WORK_DIR=${PERF_WORK_DIR}" \
        --env "ROCKSDB_BENCH_DATA_DIR=${BENCH_DATA_DIR}" \
        --env "SOFTWARE_VERSION=${SOFTWARE_VERSION}" \
        --env "EXPECTED_ARCH=${EXPECTED_ARCH}" \
        --env "PERF_VARIANT=${PERF_VARIANT}" \
        --env "ROCKSDB_NUMA_NODE=${ROCKSDB_NUMA_NODE}" \
        --env "TMPDIR=${TMPDIR}" \
        "${ROCKSDB_CONTAINER_NAME}" python3 - \
        "${YCSB_DIST_DIR}" "${RESULTS_DIR}/results.json" \
        "${RESULTS_DIR}/ycsb_raw.log" \
        < "${SCRIPT_DIR}/scripts/results/run_ycsb.py" || return 50
}
