#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_openvino_runtime() {
    local minimum_bytes=3110400 source_video source_bytes source_sha256
    initialize_runtime || return $?
    check_openvino_container || return $?
    container_exec python3 "${SCRIPT_DIR}/scripts/results/verify_runtime.py" || {
        log 'ERROR: pinned OpenVINO runtime is not usable inside the container'
        return 40
    }
    for source_video in \
        "${OPENVINO_VIDEO_DIR}/${OPENVINO_VIDEO_BQ}" \
        "${OPENVINO_VIDEO_DIR}/${OPENVINO_VIDEO_FILM}" \
        "${OPENVINO_VIDEO_DIR}/${OPENVINO_VIDEO_MESSI}"; do
        [[ -f "${source_video}" ]] || {
            log "ERROR: reference video is missing: ${source_video}"
            return 40
        }
        source_bytes="$(stat -c '%s' "${source_video}")"
        if (( source_bytes < minimum_bytes )); then
            log "ERROR: reference video needs at least one complete frame: ${source_video}"
            return 40
        fi
        source_sha256="$(sha256sum "${source_video}" | awk '{print $1}')"
        log "source video: ${source_video} (${source_bytes} bytes, sha256 ${source_sha256})"
    done
    log 'exporting the official ResNet18 ONNX model and preparing three inputs'
    container_exec python3 "${SCRIPT_DIR}/scripts/results/prepare_inputs.py" \
        --video-dir "${OPENVINO_VIDEO_DIR}" \
        --output-dir "${OPENVINO_MEDIA_DIR}" \
        --manifest "${OPENVINO_MANIFEST}" || {
        log 'ERROR: preparing the ONNX model/inputs failed'
        return 40
    }
    log 'OpenVINO runtime, model and inputs are ready inside the private container'
}
