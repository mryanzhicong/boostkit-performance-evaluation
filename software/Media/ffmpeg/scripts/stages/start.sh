#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_ffmpeg_runtime() {
    local video source_bytes
    initialize_runtime || return $?
    check_ffmpeg_container || return $?
    container_exec env LD_LIBRARY_PATH="${FFMPEG_INSTALL_DIR}/lib" \
        "${FFMPEG_INSTALL_DIR}/bin/ffmpeg" -version >/dev/null || {
        log 'ERROR: FFmpeg binary is not runnable inside the container'
        return 40
    }
    for video in "${FFMPEG_VIDEO_BQ}" "${FFMPEG_VIDEO_FILM}" "${FFMPEG_VIDEO_MESSI}"; do
        container_exec test -f "${FFMPEG_VIDEO_DIR}/${video}" || {
            log "ERROR: input video is missing inside the container: ${FFMPEG_VIDEO_DIR}/${video}"
            return 40
        }
    done
    log 'FFmpeg runtime and three reference videos are ready'
}
