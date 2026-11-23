#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_opus_benchmarks() {
    local run_status=0
    initialize_runtime || return $?
    check_opus_container || return $?
    rm -rf "${OPUS_EVIDENCE_DIR}"
    mkdir -p "${OPUS_EVIDENCE_DIR}"
    rm -f "${OPUS_CONTAINER_CSV}" "${OPUS_CONTAINER_EVIDENCE}"
    log 'calling original run_bench.sh (fixed-point Opus, 3 cases, 20 iterations)'
    container_exec env BENCH_ENV_READY="${OPUS_WORK_SCRIPTS}" \
        bash "${OPUS_WORK_SCRIPTS}/run_bench.sh" 2>&1 | tee "${OPUS_RAW_LOG}" || run_status="${PIPESTATUS[0]}"
    if [[ "${run_status}" -ne 0 ]]; then
        log "ERROR: original run_bench.sh exited ${run_status}"
        return 50
    fi
    [[ -s "${OPUS_CONTAINER_CSV}" ]] || {
        log "ERROR: original bench.py did not write ${OPUS_CONTAINER_CSV}"
        return 50
    }
    [[ -s "${OPUS_CONTAINER_EVIDENCE}" ]] || {
        log "ERROR: original bench.py did not write ${OPUS_CONTAINER_EVIDENCE}"
        return 50
    }
    cp -- "${OPUS_CONTAINER_CSV}" "${OPUS_CSV_PATH}" || return 50
    cp -- "${OPUS_CONTAINER_EVIDENCE}" "${OPUS_EVIDENCE_DIR}/evidence.json" || return 50
    SOFTWARE_VERSION="${SOFTWARE_VERSION}" EXPECTED_ARCH="${EXPECTED_ARCH}" \
        python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${OPUS_CSV_PATH}" "${OPUS_EVIDENCE_DIR}/evidence.json" \
        "${RESULTS_DIR}/benchmark_opus.json" || return 50
}
