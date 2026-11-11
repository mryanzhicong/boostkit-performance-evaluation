#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_x265_benchmarks() {
    local private_scripts
    initialize_runtime || return $?
    [[ -x "${FFMPEG_BIN}" && -x "${FFPROBE_BIN}" ]] || {
        log_message "ERROR: private FFmpeg binaries are unavailable"
        return 40
    }
    private_scripts="${PERF_WORK_DIR}/reference/scripts"
    [[ -f "${private_scripts}/run.py" && -f "${private_scripts}/bench_scene.py" ]] || {
        log_message "ERROR: reference benchmark scripts are unavailable"
        return 40
    }
    log_message "running the reference run.py: BQTerrace 600 frames, CRF 24/28"
    X265_VIDEO_DIR="${VIDEO_DIR}" python3 -B "${private_scripts}/run.py" \
        2>&1 | tee "${RESULTS_DIR}/benchmark_encode.txt" || return 50
    cp -- "${private_scripts}/result_bench-x265.csv" \
        "${RESULTS_DIR}/result_bench-x265.csv" || return 50
    python3 "${SCRIPT_DIR}/scripts/results/parse_reference.py" \
        --reference-dir "${PERF_WORK_DIR}/reference" \
        --video "${VIDEO_FILE}" --results-dir "${RESULTS_DIR}" \
        --version "${SOFTWARE_VERSION}" \
        --architecture "$(normalize_architecture "${EXPECTED_ARCH}")" || return 50
}
