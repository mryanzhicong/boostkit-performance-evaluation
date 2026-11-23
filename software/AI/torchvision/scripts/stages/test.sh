#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_torchvision_benchmarks() {
    local run_status=0 source_video
    initialize_runtime || return $?
    check_torchvision_container || return $?
    for source_video in \
        "${TORCHVISION_VIDEO_DIR}/${TORCHVISION_VIDEO_BQ}" \
        "${TORCHVISION_VIDEO_DIR}/${TORCHVISION_VIDEO_FILM}" \
        "${TORCHVISION_VIDEO_DIR}/${TORCHVISION_VIDEO_MESSI}"; do
        container_exec test -f "${source_video}" || {
            log "ERROR: input video is unavailable inside the container: ${source_video}"
            return 40
        }
    done
    if [[ -d "${TORCHVISION_EVIDENCE_DIR}" ]] && \
       [[ -n "$(find "${TORCHVISION_EVIDENCE_DIR}" -mindepth 1 -print -quit)" ]]; then
        log "ERROR: benchmark evidence directory is not empty: ${TORCHVISION_EVIDENCE_DIR}"
        return 50
    fi
    log 'running 2 official INT8 models x 3 videos, 3 warm-ups + 20 timed forwards'
    container_exec python3 "${SCRIPT_DIR}/scripts/results/run_benchmark.py" \
        --video-dir "${TORCHVISION_VIDEO_DIR}" \
        --weight-dir "${TORCHVISION_WEIGHT_DIR}" \
        --evidence-dir "${TORCHVISION_EVIDENCE_DIR}" \
        --csv "${TORCHVISION_CSV_PATH}" \
        --work-dir "${PERF_WORK_DIR}/media" \
        --iterations "${TORCHVISION_ITERATIONS}" \
        --warmup-iterations "${TORCHVISION_WARMUP_ITERATIONS}" \
        --threads "${TORCHVISION_THREADS}" \
        --batch-size "${TORCHVISION_BATCH_SIZE}" 2>&1 | \
        tee "${RESULTS_DIR}/benchmark_raw.log" || run_status="${PIPESTATUS[0]}"
    if [[ "${run_status}" -ne 0 ]]; then
        log "ERROR: TorchVision benchmark exited ${run_status}"
        return 50
    fi
    SOFTWARE_VERSION="${SOFTWARE_VERSION}" EXPECTED_ARCH="${EXPECTED_ARCH}" \
        python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${TORCHVISION_CSV_PATH}" \
        "${TORCHVISION_EVIDENCE_DIR}/evidence.json" \
        "${RESULTS_DIR}/benchmark_torchvision.json" || return 50
}
