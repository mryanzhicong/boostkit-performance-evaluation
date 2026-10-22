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
    [[ -d "${VIDEO_DIR}" ]] || {
        log_message "ERROR: reference videos are unavailable: ${VIDEO_DIR}"
        return 40
    }
    python3 "${SCRIPT_DIR}/../collect_reference.py" \
        --check-only --video-dir "${VIDEO_DIR}" || return 40
    [[ ! -e "${PERF_WORK_DIR}/video" ]] || {
        log_message "ERROR: reference video link already exists: ${PERF_WORK_DIR}/video"
        return 40
    }
    ln -s "${VIDEO_DIR}" "${PERF_WORK_DIR}/video" || return 40
    log_message "x265 official benchmark runtime is ready"
}
