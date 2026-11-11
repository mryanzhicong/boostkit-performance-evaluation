#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_opencv_benchmarks() {
    initialize_runtime || return $?
    check_architecture || return $?
    opencv_resolve_media || return $?
    check_opencv_container || return $?
    opencv_verify_runtime_payload || return $?
    opencv_media_probe || return $?

    log_message "norm scenarios: 3, warmups=${OPENCV_WARMUPS}, samples=${OPENCV_SAMPLES}," \
        "calls/sample=${OPENCV_CALLS_PER_SAMPLE}, no CPU/memory pinning"
    opencv_container_exec env PYTHONPATH="${OPENCV_PYTHON_DIR}" \
        LD_LIBRARY_PATH="${OPENCV_INSTALL_DIR}/lib" \
        python3 "${SCRIPT_DIR}/scripts/harness/bench_norm.py" \
        --media-dir "${OPENCV_MEDIA_CONTAINER_DIR}" \
        --install-dir "${OPENCV_INSTALL_DIR}" \
        --work-dir "${OPENCV_BENCH_DIR}" \
        --results-dir "${RESULTS_DIR}" \
        --runs-dir "${OPENCV_RUNS_DIR}" \
        --manifest "${OPENCV_MEDIA_JSON}" \
        --warmups "${OPENCV_WARMUPS}" \
        --samples "${OPENCV_SAMPLES}" \
        --calls "${OPENCV_CALLS_PER_SAMPLE}" 2>&1 | tee "${OPENCV_LOG}"
    local harness_status=${PIPESTATUS[0]}
    if [[ "${harness_status}" -ne 0 ]]; then
        log_message "ERROR: the norm harness exited with ${harness_status}"
        tail -n 20 "${OPENCV_LOG}" >&2 || true
        return 50
    fi
    if ! grep -q 'OPENCV_BENCH_COMPLETE' "${OPENCV_LOG}"; then
        log_message "ERROR: the norm harness did not complete"
        return 50
    fi

    log_message "validating the reference CSV and building benchmark_opencv.json"
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        --csv "${RESULTS_DIR}/result_bench-opencv.csv" \
        --evidence "${RESULTS_DIR}/evidence.json" \
        --manifest "${OPENCV_MEDIA_JSON}" \
        --warmups "${OPENCV_WARMUPS}" \
        --samples "${OPENCV_SAMPLES}" \
        --calls "${OPENCV_CALLS_PER_SAMPLE}" \
        --version "${SOFTWARE_VERSION}" \
        --architecture "$(normalize_architecture "${EXPECTED_ARCH}")" \
        --variant "${PERF_VARIANT}" \
        --output "${RESULTS_DIR}/benchmark_opencv.json" || return 50
    log_message "benchmark result written: ${RESULTS_DIR}/benchmark_opencv.json"
}
