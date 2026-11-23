#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_dav1d_benchmarks() {
    local run_status=0
    initialize_runtime || return $?
    check_dav1d_container || return $?
    container_exec test -x "${DAV1D_DECODER_BIN}" || {
        log 'ERROR: built dav1d is unavailable inside the container'
        return 40
    }
    container_exec python3 "${SCRIPT_DIR}/scripts/results/prepare_inputs.py" \
        --source-dir "${DAV1D_VIDEO_DIR}" \
        --output-dir "${DAV1D_MEDIA_DIR}" \
        --manifest "${DAV1D_MANIFEST_PATH}" \
        --log-dir "${DAV1D_MEDIA_DIR}/logs" \
        --width "${DAV1D_WIDTH}" \
        --height "${DAV1D_HEIGHT}" \
        --frames "${DAV1D_FRAMES}" \
        --cq-level "${DAV1D_CQ_LEVEL}" \
        --bit-depth "${DAV1D_BIT_DEPTH}" \
        --verify-only || {
        log 'ERROR: prepared IVF inputs failed verification before the benchmark'
        return 50
    }
    if [[ -d "${DAV1D_EVIDENCE_DIR}" ]] && \
       [[ -n "$(find "${DAV1D_EVIDENCE_DIR}" -mindepth 1 -print -quit)" ]]; then
        log "ERROR: decode evidence directory is not empty: ${DAV1D_EVIDENCE_DIR}"
        return 50
    fi
    log 'running 2 scenarios x (1 warm-up + 20 timed) decodes inside the container'
    container_exec python3 "${SCRIPT_DIR}/scripts/results/run_decode_benchmark.py" \
        --decoder "${DAV1D_DECODER_BIN}" \
        --manifest "${DAV1D_MANIFEST_PATH}" \
        --library-dir "${DAV1D_LIBRARY_DIR}" \
        --evidence-dir "${DAV1D_EVIDENCE_DIR}" \
        --csv "${DAV1D_CSV_PATH}" \
        --work-dir "${DAV1D_MEDIA_DIR}" \
        --iterations "${DAV1D_ITERATIONS}" \
        --warmup-iterations "${DAV1D_WARMUP_ITERATIONS}" \
        --frames "${DAV1D_FRAMES}" \
        --width "${DAV1D_WIDTH}" \
        --height "${DAV1D_HEIGHT}" \
        --threads "${DAV1D_THREADS}" \
        --timeout 300 2>&1 | tee "${RESULTS_DIR}/benchmark_raw.log" || \
        run_status="${PIPESTATUS[0]}"
    if [[ "${run_status}" -ne 0 ]]; then
        log "ERROR: formal decode benchmark exited ${run_status}"
        return 50
    fi
    SOFTWARE_VERSION="${SOFTWARE_VERSION}" EXPECTED_ARCH="${EXPECTED_ARCH}" \
        python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${DAV1D_CSV_PATH}" \
        "${DAV1D_EVIDENCE_DIR}/evidence.json" \
        "${RESULTS_DIR}/benchmark_dav1d.json" || return 50
}
