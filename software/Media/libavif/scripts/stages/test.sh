#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_libavif_benchmarks() {
    initialize_runtime || return $?
    check_architecture || return $?
    libavif_resolve_media || return $?
    check_libavif_container || return $?
    libavif_verify_runtime_payload || return $?
    libavif_media_probe || return $?

    log_message "encode scenarios: 6, warmups=${LIBAVIF_WARMUPS}, samples=${LIBAVIF_SAMPLES}, no CPU/memory pinning"
    libavif_container_exec python3 "${SCRIPT_DIR}/scripts/harness/bench_encode.py" \
        --media-dir "${LIBAVIF_MEDIA_CONTAINER_DIR}" \
        --install-dir "${LIBAVIF_INSTALL_DIR}" \
        --work-dir "${LIBAVIF_BENCH_DIR}" \
        --results-dir "${RESULTS_DIR}" \
        --runs-dir "${LIBAVIF_RUNS_DIR}" \
        --manifest "${LIBAVIF_MEDIA_JSON}" \
        --warmups "${LIBAVIF_WARMUPS}" \
        --samples "${LIBAVIF_SAMPLES}" 2>&1 | tee "${LIBAVIF_LOG}"
    local harness_status=${PIPESTATUS[0]}
    if [[ "${harness_status}" -ne 0 ]]; then
        log_message "ERROR: the encode harness exited with ${harness_status}"
        tail -n 20 "${LIBAVIF_LOG}" >&2 || true
        return 50
    fi
    if ! grep -q 'LIBAVIF_BENCH_COMPLETE' "${LIBAVIF_LOG}"; then
        log_message "ERROR: the encode harness did not complete"
        return 50
    fi

    log_message "validating the reference CSV and building benchmark_libavif.json"
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        --csv "${RESULTS_DIR}/result_bench-libavif.csv" \
        --evidence "${RESULTS_DIR}/evidence.json" \
        --manifest "${LIBAVIF_MEDIA_JSON}" \
        --warmups "${LIBAVIF_WARMUPS}" \
        --samples "${LIBAVIF_SAMPLES}" \
        --version "${SOFTWARE_VERSION}" \
        --architecture "$(normalize_architecture "${EXPECTED_ARCH}")" \
        --variant "${PERF_VARIANT}" \
        --output "${RESULTS_DIR}/benchmark_libavif.json" || return 50
    log_message "benchmark result written: ${RESULTS_DIR}/benchmark_libavif.json"
}
