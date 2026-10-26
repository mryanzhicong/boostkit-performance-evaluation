#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_x264_benchmarks() {
    local machine_type="x86"
    initialize_runtime || return $?
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log_message "ERROR: official x264 binary is unavailable"
        return 40
    }
    [[ -d "${VIDEO_DIR}" ]] || {
        log_message "ERROR: reference videos are unavailable: ${VIDEO_DIR}"
        return 40
    }
    if [[ "$(normalize_architecture "${EXPECTED_ARCH}")" == "aarch64" ]]; then
        machine_type="920"
    fi
    export TEST_HOME="${PERF_WORK_DIR}"
    (
        cd "${TEST_HOME}"
        unset THREADS_MODE
        bash "${SCRIPT_DIR}/scripts/fps-encode-x264.sh" 8core "${machine_type}" 1
    ) 2>&1 | tee "${RESULTS_DIR}/benchmark_encode.txt" || return 50
    (
        cd "${TEST_HOME}"
        bash "${SCRIPT_DIR}/scripts/score-x264.sh"
    ) 2>&1 | tee -a "${RESULTS_DIR}/benchmark_encode.txt" || return 50
    cp "${TEST_HOME}/video_fps_summary_x264.csv" \
        "${RESULTS_DIR}/video_fps_summary_x264.csv" || return 50
    python3 "${SCRIPT_DIR}/../collect_reference.py" \
        --encoder x264 --allow-video-subset \
        --video-dir "${VIDEO_DIR}" --work-dir "${TEST_HOME}" \
        --raw-output "${RESULTS_DIR}/benchmark_encode.txt" \
        --summary "${RESULTS_DIR}/video_fps_summary_x264.csv" \
        --normalized-output "${RESULTS_DIR}/benchmark_x264.json" \
        --version "${SOFTWARE_VERSION}" \
        --architecture "$(normalize_architecture "${EXPECTED_ARCH}")" || return 50
}
