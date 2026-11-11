#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

verify_prepared_input() {
    local source_video="$1"
    container_exec python3 "${SCRIPT_DIR}/scripts/results/prepare_inputs.py" \
        --source "${source_video}" \
        --output "${UAVS3D_STREAM_PATH}" \
        --manifest "${UAVS3D_MANIFEST_PATH}" \
        --width "${UAVS3D_WIDTH}" \
        --height "${UAVS3D_HEIGHT}" \
        --frames "${UAVS3D_FRAMES}" \
        --fps "${UAVS3D_FPS}" \
        --qp "${UAVS3D_QP}" \
        --verify-only
}

start_uavs3d_runtime() {
    local source_video minimum_bytes
    initialize_runtime || return $?
    check_uavs3d_container || return $?
    container_exec test -x "${UAVS3D_DECODER_BIN}" || {
        log 'ERROR: built uavs3dec is unavailable inside the container'
        return 40
    }
    container_exec test -x "${UAVS3D_ENCODER_BIN}" || {
        log 'ERROR: built uavs3enc is unavailable inside the container'
        return 40
    }
    source_video="${UAVS3D_VIDEO_DIR}/${UAVS3D_VIDEO_NAME}"
    [[ -f "${source_video}" ]] || {
        log "ERROR: reference video is missing: ${source_video}"
        return 40
    }
    minimum_bytes=$((UAVS3D_WIDTH * UAVS3D_HEIGHT * 3 / 2 * UAVS3D_FRAMES))
    local source_bytes source_sha256
    source_bytes="$(stat -c '%s' "${source_video}")"
    if (( source_bytes < minimum_bytes )); then
        log "ERROR: reference video needs at least ${UAVS3D_FRAMES} frames: ${source_video}"
        return 40
    fi
    source_sha256="$(sha256sum "${source_video}" | awk '{print $1}')"
    log "source video: ${source_video} (${source_bytes} bytes, sha256 ${source_sha256})"
    if [[ -s "${UAVS3D_STREAM_PATH}" && -s "${UAVS3D_MANIFEST_PATH}" ]]; then
        if verify_prepared_input "${source_video}"; then
            log "reusing prepared AVS3 stream: ${UAVS3D_STREAM_PATH}"
            log 'uavs3d runtime and AVS3 input are ready inside the private container'
            return 0
        fi
        log 'existing AVS3 input does not match this source; regenerating it'
        rm -f -- "${UAVS3D_STREAM_PATH}" "${UAVS3D_MANIFEST_PATH}" "${UAVS3D_PREPARE_LOG}"
    fi
    log "encoding the first ${UAVS3D_FRAMES} frames with uavs3e (not timed)"
    if ! container_exec python3 "${SCRIPT_DIR}/scripts/results/prepare_inputs.py" \
        --encoder "${UAVS3D_ENCODER_BIN}" \
        --source "${source_video}" \
        --output "${UAVS3D_STREAM_PATH}" \
        --manifest "${UAVS3D_MANIFEST_PATH}" \
        --log "${UAVS3D_PREPARE_LOG}" \
        --width "${UAVS3D_WIDTH}" \
        --height "${UAVS3D_HEIGHT}" \
        --frames "${UAVS3D_FRAMES}" \
        --fps "${UAVS3D_FPS}" \
        --qp "${UAVS3D_QP}" \
        --wpp-threads "${UAVS3D_WPP_THREADS}" \
        --frm-threads "${UAVS3D_FRM_THREADS}" \
        --speed-level "${UAVS3D_SPEED_LEVEL}" \
        --gop "${UAVS3D_GOP}" \
        --preset "${UAVS3D_PRESET}"; then
        if [[ -f "${UAVS3D_PREPARE_LOG}" ]]; then
            cp -- "${UAVS3D_PREPARE_LOG}" "${RESULTS_DIR}/input_prepare.log" || true
            log 'encoder log tail:'
            tail -n 40 "${UAVS3D_PREPARE_LOG}" >&2 || true
        fi
        return 50
    fi
    if [[ -f "${UAVS3D_PREPARE_LOG}" ]]; then
        cp -- "${UAVS3D_PREPARE_LOG}" "${RESULTS_DIR}/input_prepare.log" || return 50
    fi
    verify_prepared_input "${source_video}" || return 50
    log 'uavs3d runtime and AVS3 input are ready inside the private container'
}
