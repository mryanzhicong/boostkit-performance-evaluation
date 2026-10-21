#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_hnswlib_benchmarks() {
    local actual_version
    local benchmark_status

    initialize_runtime || return $?
    if [[ ! -f "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        log "ERROR: actual version file is missing"
        return 50
    fi
    actual_version="$(sed -n '1p' "${PERF_ACTUAL_VERSION_FILE}")" || return 50
    if [[ -e "${RESULTS_DIR}/benchmark_sra.json" ]]; then
        log "ERROR: hnswlib benchmark result already exists"
        return 50
    fi

    log "running original sra_test hnswlib_test on five datasets"
    if python3 "${SCRIPT_DIR}/scripts/results/run_sra_benchmark.py" \
        --source "${SRA_DIR}" \
        --data "${HNSWLIB_DATA_ROOT}" \
        --results "${RESULTS_DIR}" \
        --version "${actual_version}" \
        --architecture "${EXPECTED_ARCH}"; then
        :
    else
        benchmark_status=$?
        log "ERROR: sra_test hnswlib benchmark failed with status ${benchmark_status}"
        return "${benchmark_status}"
    fi
    log "hnswlib benchmark results written to benchmark_sra.json"
}
