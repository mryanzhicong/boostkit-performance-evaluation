#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

verify_prepared_input() {
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
        --verify-only
}

start_dav1d_runtime() {
    local minimum_bytes source_video source_bytes source_sha256
    initialize_runtime || return $?
    check_dav1d_container || return $?
    container_exec test -x "${DAV1D_DECODER_BIN}" || {
        log 'ERROR: built dav1d is unavailable inside the container'
        return 40
    }
    container_exec test -x "${DAV1D_ENCODER_BIN}" || {
        log 'ERROR: built aomenc is unavailable inside the container'
        return 40
    }
    minimum_bytes=$((DAV1D_WIDTH * DAV1D_HEIGHT * 3 / 2 * DAV1D_FRAMES))
    for source_video in "${DAV1D_VIDEO_DIR}/${DAV1D_VIDEO_BQ}" "${DAV1D_VIDEO_DIR}/${DAV1D_VIDEO_MESSI}"; do
        [[ -f "${source_video}" ]] || {
            log "ERROR: reference video is missing: ${source_video}"
            return 40
        }
        source_bytes="$(stat -c '%s' "${source_video}")"
        if (( source_bytes < minimum_bytes )); then
            log "ERROR: reference video needs at least ${DAV1D_FRAMES} frames: ${source_video}"
            return 40
        fi
        source_sha256="$(sha256sum "${source_video}" | awk '{print $1}')"
        log "source video: ${source_video} (${source_bytes} bytes, sha256 ${source_sha256})"
    done
    if [[ -s "${DAV1D_MANIFEST_PATH}" && -s "${DAV1D_MEDIA_DIR}/${DAV1D_STREAM_BQ}" && -s "${DAV1D_MEDIA_DIR}/${DAV1D_STREAM_MESSI}" ]]; then
        if verify_prepared_input; then
            log 'reusing prepared IVF streams'
            log 'dav1d runtime and IVF inputs are ready inside the private container'
            return 0
        fi
        log 'existing IVF inputs do not match this source; regenerating them'
        rm -f -- "${DAV1D_MANIFEST_PATH}" \
            "${DAV1D_MEDIA_DIR}/${DAV1D_STREAM_BQ}" \
            "${DAV1D_MEDIA_DIR}/${DAV1D_STREAM_MESSI}"
    fi
    log "encoding the first ${DAV1D_FRAMES} frames with AOM (not timed)"
    if ! container_exec python3 "${SCRIPT_DIR}/scripts/results/prepare_inputs.py" \
        --encoder "${DAV1D_ENCODER_BIN}" \
        --source-dir "${DAV1D_VIDEO_DIR}" \
        --output-dir "${DAV1D_MEDIA_DIR}" \
        --manifest "${DAV1D_MANIFEST_PATH}" \
        --log-dir "${DAV1D_MEDIA_DIR}/logs" \
        --width "${DAV1D_WIDTH}" \
        --height "${DAV1D_HEIGHT}" \
        --frames "${DAV1D_FRAMES}" \
        --cq-level "${DAV1D_CQ_LEVEL}" \
        --bit-depth "${DAV1D_BIT_DEPTH}"; then
        rm -rf -- "${RESULTS_DIR}/input_prepare"
        mkdir -p "${RESULTS_DIR}/input_prepare"
        if [[ -d "${DAV1D_MEDIA_DIR}/logs" ]]; then
            cp -a -- "${DAV1D_MEDIA_DIR}/logs/." "${RESULTS_DIR}/input_prepare/" || true
            for prepare_log in "${DAV1D_MEDIA_DIR}/logs"/*.prepare.log; do
                [[ -f "${prepare_log}" ]] || continue
                log "encoder log tail: ${prepare_log}"
                tail -n 40 "${prepare_log}" >&2 || true
            done
        fi
        return 50
    fi
    mkdir -p "${RESULTS_DIR}/input_prepare"
    cp -a -- "${DAV1D_MEDIA_DIR}/logs/." "${RESULTS_DIR}/input_prepare/" || return 50
    verify_prepared_input || return 50
    log 'dav1d runtime and IVF inputs are ready inside the private container'
}
