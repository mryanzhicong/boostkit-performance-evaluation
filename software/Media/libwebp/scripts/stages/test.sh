#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_libwebp_benchmarks() {
    initialize_runtime || return $?
    check_architecture || return $?
    libwebp_resolve_media || return $?
    check_libwebp_container || return $?
    libwebp_verify_runtime_payload || return $?
    libwebp_media_probe || return $?

    log_message "decode scenario: 1 case, warmups=${LIBWEBP_WARMUPS}, samples=${LIBWEBP_SAMPLES}, no CPU/memory pinning"
    libwebp_container_exec python3 "${SCRIPT_DIR}/scripts/harness/bench_decode.py" \
        --media-dir "${LIBWEBP_MEDIA_CONTAINER_DIR}" \
        --install-dir "${LIBWEBP_INSTALL_DIR}" \
        --work-dir "${LIBWEBP_BENCH_DIR}" \
        --results-dir "${RESULTS_DIR}" \
        --runs-dir "${LIBWEBP_RUNS_DIR}" \
        --manifest "${LIBWEBP_MEDIA_JSON}" \
        --warmups "${LIBWEBP_WARMUPS}" \
        --samples "${LIBWEBP_SAMPLES}" 2>&1 | tee "${LIBWEBP_LOG}"
    local harness_status=${PIPESTATUS[0]}
    if [[ "${harness_status}" -ne 0 ]]; then
        log_message "ERROR: the decode harness exited with ${harness_status}"
        tail -n 20 "${LIBWEBP_LOG}" >&2 || true
        return 50
    fi
    if ! grep -q 'LIBWEBP_BENCH_COMPLETE' "${LIBWEBP_LOG}"; then
        log_message "ERROR: the decode harness did not complete"
        return 50
    fi

    log_message "validating the reference CSV and building benchmark_libwebp.json"
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        --csv "${RESULTS_DIR}/result_bench-libwebp.csv" \
        --evidence "${RESULTS_DIR}/evidence.json" \
        --manifest "${LIBWEBP_MEDIA_JSON}" \
        --warmups "${LIBWEBP_WARMUPS}" \
        --samples "${LIBWEBP_SAMPLES}" \
        --version "${SOFTWARE_VERSION}" \
        --architecture "$(normalize_architecture "${EXPECTED_ARCH}")" \
        --variant "${PERF_VARIANT}" \
        --output "${RESULTS_DIR}/benchmark_libwebp.json" || return 50
    log_message "benchmark result written: ${RESULTS_DIR}/benchmark_libwebp.json"
}
