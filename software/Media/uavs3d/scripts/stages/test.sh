#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_uavs3d_benchmarks() {
    local source_video run_status=0
    initialize_runtime || return $?
    check_uavs3d_container || return $?
    source_video="${UAVS3D_VIDEO_DIR}/${UAVS3D_VIDEO_NAME}"
    container_exec test -x "${UAVS3D_DECODER_BIN}" || {
        log 'ERROR: built uavs3dec is unavailable inside the container'
        return 40
    }
    container_exec test -x "${UAVS3D_ENCODER_BIN}" || {
        log 'ERROR: built uavs3enc is unavailable inside the container'
        return 40
    }
    container_exec python3 "${SCRIPT_DIR}/scripts/results/prepare_inputs.py" \
        --source "${source_video}" \
        --output "${UAVS3D_STREAM_PATH}" \
        --manifest "${UAVS3D_MANIFEST_PATH}" \
        --width "${UAVS3D_WIDTH}" \
        --height "${UAVS3D_HEIGHT}" \
        --frames "${UAVS3D_FRAMES}" \
        --fps "${UAVS3D_FPS}" \
        --qp "${UAVS3D_QP}" \
        --verify-only || {
        log 'ERROR: prepared AVS3 input failed verification before the benchmark'
        return 50
    }
    if [[ -d "${UAVS3D_EVIDENCE_DIR}" ]] && \
       [[ -n "$(find "${UAVS3D_EVIDENCE_DIR}" -mindepth 1 -print -quit)" ]]; then
        log "ERROR: decode evidence directory is not empty: ${UAVS3D_EVIDENCE_DIR}"
        return 50
    fi
    log 'running 2 scenarios x (1 warm-up + 20 timed) decodes inside the container'
    container_exec python3 "${SCRIPT_DIR}/scripts/results/run_decode_benchmark.py" \
        --decoder "${UAVS3D_DECODER_BIN}" \
        --stream "${UAVS3D_STREAM_PATH}" \
        --manifest "${UAVS3D_MANIFEST_PATH}" \
        --evidence-dir "${UAVS3D_EVIDENCE_DIR}" \
        --csv "${UAVS3D_CSV_PATH}" \
        --work-dir "${UAVS3D_MEDIA_DIR}" \
        --iterations "${UAVS3D_ITERATIONS}" \
        --warmup-iterations "${UAVS3D_WARMUP_ITERATIONS}" \
        --frames "${UAVS3D_FRAMES}" \
        --width "${UAVS3D_WIDTH}" \
        --height "${UAVS3D_HEIGHT}" \
        --threads "${UAVS3D_THREADS[@]}" \
        --timeout 300 2>&1 | tee "${RESULTS_DIR}/benchmark_raw.log" || \
        run_status="${PIPESTATUS[0]}"
    if [[ "${run_status}" -ne 0 ]]; then
        log "ERROR: formal decode benchmark exited ${run_status}"
        return 50
    fi
    SOFTWARE_VERSION="${SOFTWARE_VERSION}" EXPECTED_ARCH="${EXPECTED_ARCH}" \
        python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${UAVS3D_CSV_PATH}" \
        "${UAVS3D_EVIDENCE_DIR}/evidence.json" \
        "${RESULTS_DIR}/benchmark_uavs3d.json" || return 50
}
