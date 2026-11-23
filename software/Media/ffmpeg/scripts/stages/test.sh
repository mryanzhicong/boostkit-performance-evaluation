#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_ffmpeg_benchmarks() {
    local run_status=0
    initialize_runtime || return $?
    check_ffmpeg_container || return $?
    rm -rf "${FFMPEG_EVIDENCE_DIR}"
    mkdir -p "${FFMPEG_EVIDENCE_DIR}"
    rm -f "${FFMPEG_CONTAINER_CSV}" "${FFMPEG_CONTAINER_EVIDENCE}"
    log 'calling original run_bench.sh (build cache check + bench.py)'
    container_exec env BENCH_ENV_READY="${FFMPEG_WORK_SCRIPTS}" \
        bash "${FFMPEG_WORK_SCRIPTS}/run_bench.sh" 2>&1 | tee "${FFMPEG_RAW_LOG}" || run_status="${PIPESTATUS[0]}"
    if [[ "${run_status}" -ne 0 ]]; then
        log "ERROR: original run_bench.sh exited ${run_status}"
        return 50
    fi
    [[ -s "${FFMPEG_CONTAINER_CSV}" ]] || {
        log "ERROR: original bench.py did not write ${FFMPEG_CONTAINER_CSV}"
        return 50
    }
    [[ -s "${FFMPEG_CONTAINER_EVIDENCE}" ]] || {
        log "ERROR: original bench.py did not write ${FFMPEG_CONTAINER_EVIDENCE}"
        return 50
    }
    cp -- "${FFMPEG_CONTAINER_CSV}" "${FFMPEG_CSV_PATH}" || return 50
    cp -- "${FFMPEG_CONTAINER_EVIDENCE}" "${FFMPEG_EVIDENCE_DIR}/evidence.json" || return 50
    SOFTWARE_VERSION="${SOFTWARE_VERSION}" EXPECTED_ARCH="${EXPECTED_ARCH}" \
        python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${FFMPEG_CSV_PATH}" "${FFMPEG_EVIDENCE_DIR}/evidence.json" \
        "${RESULTS_DIR}/benchmark_ffmpeg.json" || return 50
}
