#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_ffmpeg_benchmarks() {
    local run_status=0
    initialize_runtime || return $?
    check_ffmpeg_container || return $?
    rm -rf "${FFMPEG_EVIDENCE_DIR}"
    mkdir -p "${FFMPEG_EVIDENCE_DIR}" "${FFMPEG_CLIPS_DIR}"
    log "running stock FFmpeg 7.1.1 scale benchmark: 30 frames, 1080p -> ${FFMPEG_WIDTH}x${FFMPEG_HEIGHT} ${FFMPEG_PIXEL_FORMAT}"
    container_exec python3 "${SCRIPT_DIR}/scripts/results/run_benchmark.py" \
        --video-dir "${FFMPEG_VIDEO_DIR}" \
        --clips-dir "${FFMPEG_CLIPS_DIR}" \
        --ffmpeg "${FFMPEG_INSTALL_DIR}/bin/ffmpeg" \
        --lib-dir "${FFMPEG_INSTALL_DIR}/lib" \
        --csv "${FFMPEG_CSV_PATH}" \
        --evidence-dir "${FFMPEG_EVIDENCE_DIR}" \
        --iterations "${FFMPEG_ITERATIONS}" \
        --warmup-iterations "${FFMPEG_WARMUP_ITERATIONS}" \
        --frames "${FFMPEG_FRAMES}" 2>&1 | tee "${FFMPEG_RAW_LOG}" || run_status="${PIPESTATUS[0]}"
    if [[ "${run_status}" -ne 0 ]]; then
        log "ERROR: FFmpeg benchmark exited ${run_status}"
        return 50
    fi
    SOFTWARE_VERSION="${SOFTWARE_VERSION}" EXPECTED_ARCH="${EXPECTED_ARCH}" \
        python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${FFMPEG_CSV_PATH}" "${FFMPEG_EVIDENCE_DIR}/evidence.json" \
        "${RESULTS_DIR}/benchmark_ffmpeg.json" || return 50
}
