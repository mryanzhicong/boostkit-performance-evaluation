#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_ffmpeg_runtime() {
    local video
    initialize_runtime || return $?
    check_ffmpeg_container || return $?
    container_exec test -f "${FFMPEG_WORK_SCRIPTS}/bench.py" || {
        log 'ERROR: original bench.py is not staged; run the build stage first'
        return 40
    }
    container_exec test -x "${FFMPEG_INSTALL_DIR}/bin/ffmpeg" || {
        log 'ERROR: FFmpeg binary is missing; run the build stage first'
        return 40
    }
    container_exec env LD_LIBRARY_PATH="${FFMPEG_INSTALL_DIR}/lib" \
        "${FFMPEG_INSTALL_DIR}/bin/ffmpeg" -version >/dev/null || {
        log 'ERROR: FFmpeg binary is not runnable inside the container'
        return 40
    }
    for video in "${FFMPEG_VIDEO_BQ}" "${FFMPEG_VIDEO_FILM}" "${FFMPEG_VIDEO_MESSI}"; do
        container_exec test -f "${FFMPEG_CONTAINER_VIDEO_DIR}/${video}" || {
            log "ERROR: input video is missing inside the container: ${FFMPEG_CONTAINER_VIDEO_DIR}/${video}"
            return 40
        }
    done
    log 'original FFmpeg scripts, binary and three reference videos are ready'
}
