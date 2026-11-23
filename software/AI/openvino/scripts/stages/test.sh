#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_openvino_benchmarks() {
    local run_status=0 source_video
    initialize_runtime || return $?
    check_openvino_container || return $?
    for source_video in \
        "${OPENVINO_VIDEO_DIR}/${OPENVINO_VIDEO_BQ}" \
        "${OPENVINO_VIDEO_DIR}/${OPENVINO_VIDEO_FILM}" \
        "${OPENVINO_VIDEO_DIR}/${OPENVINO_VIDEO_MESSI}"; do
        container_exec test -f "${source_video}" || {
            log "ERROR: input video is unavailable inside the container: ${source_video}"
            return 40
        }
    done
    container_exec python3 "${SCRIPT_DIR}/scripts/results/prepare_inputs.py" \
        --video-dir "${OPENVINO_VIDEO_DIR}" \
        --output-dir "${OPENVINO_MEDIA_DIR}" \
        --manifest "${OPENVINO_MANIFEST}" --verify-only || {
        log 'ERROR: ONNX model or prepared inputs are not valid'
        return 50
    }
    if [[ -d "${OPENVINO_EVIDENCE_DIR}" ]] && \
       [[ -n "$(find "${OPENVINO_EVIDENCE_DIR}" -mindepth 1 -print -quit)" ]]; then
        log "ERROR: benchmark evidence directory is not empty: ${OPENVINO_EVIDENCE_DIR}"
        return 50
    fi
    log 'running ResNet18 FP32 x 3 videos, 3 warm-ups + 20 synchronous inferences'
    container_exec python3 "${SCRIPT_DIR}/scripts/results/run_benchmark.py" \
        --manifest "${OPENVINO_MANIFEST}" \
        --evidence-dir "${OPENVINO_EVIDENCE_DIR}" \
        --csv "${OPENVINO_CSV_PATH}" \
        --iterations "${OPENVINO_ITERATIONS}" \
        --warmup-iterations "${OPENVINO_WARMUP_ITERATIONS}" 2>&1 | \
        tee "${RESULTS_DIR}/benchmark_raw.log" || run_status="${PIPESTATUS[0]}"
    if [[ "${run_status}" -ne 0 ]]; then
        log "ERROR: OpenVINO benchmark exited ${run_status}"
        return 50
    fi
    SOFTWARE_VERSION="${SOFTWARE_VERSION}" EXPECTED_ARCH="${EXPECTED_ARCH}" \
        python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${OPENVINO_CSV_PATH}" \
        "${OPENVINO_EVIDENCE_DIR}/evidence.json" \
        "${RESULTS_DIR}/benchmark_openvino.json" || return 50
}
