#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_x265_runtime() {
    initialize_runtime || return $?
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log_message "ERROR: official x265 binary is unavailable"
        return 40
    }
    "${BENCHMARK_BIN}" --version >/dev/null 2>&1 || {
        log_message "ERROR: x265 binary is not runnable"
        return 40
    }
    [[ -x "${FFMPEG_BIN}" && -x "${FFPROBE_BIN}" ]] || {
        log_message "ERROR: private FFmpeg 7.0.1 binaries are unavailable"
        return 40
    }
    local ffmpeg_version
    ffmpeg_version="$("${FFMPEG_BIN}" -version 2>&1)" || return 40
    [[ "${ffmpeg_version}" == *"ffmpeg version 7.0.1"* ]] || {
        log_message "ERROR: private FFmpeg version is not 7.0.1"
        return 40
    }
    [[ -f "${VIDEO_FILE}" ]] || {
        log_message "ERROR: required BQTerrace video is unavailable: ${VIDEO_FILE}"
        return 40
    }
    local bytes
    bytes="$(stat -c %s -- "${VIDEO_FILE}")" || return 40
    (( bytes >= 1920 * 1080 * 3 / 2 * 600 )) || {
        log_message "ERROR: BQTerrace video contains fewer than 600 complete frames"
        return 40
    }
    log_message "x265 4.2 / FFmpeg 7.0.1 runtime and 600-frame video are ready"
}
