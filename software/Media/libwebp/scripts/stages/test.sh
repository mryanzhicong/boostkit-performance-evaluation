#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_libwebp_benchmarks() {
    local harness_status=0
    initialize_runtime || return $?
    check_architecture || return $?
    check_libwebp_container || return $?
    libwebp_verify_runtime_payload || return $?

    log_message "lossless encode scenarios: 2, warmups=${LIBWEBP_WARMUPS}, samples=${LIBWEBP_SAMPLES}, statistic=${LIBWEBP_STATISTIC}, no CPU/memory pinning"
    set +e
    libwebp_container_exec python3 "${SCRIPT_DIR}/scripts/harness/bench_encode.py" \
        --install-dir "${LIBWEBP_INSTALL_DIR}" \
        --work-dir "${LIBWEBP_BENCH_DIR}" \
        --results-dir "${RESULTS_DIR}" \
        --runs-dir "${LIBWEBP_RUNS_DIR}" \
        --manifest "${SCRIPT_DIR}/fixtures/media.json" \
        --warmups "${LIBWEBP_WARMUPS}" \
        --samples "${LIBWEBP_SAMPLES}" 2>&1 | tee "${LIBWEBP_LOG}"
    harness_status=${PIPESTATUS[0]}
    set -e
    if [[ "${harness_status}" -ne 0 ]]; then
        log_message "ERROR: the lossless encode harness exited with ${harness_status}"
        tail -n 20 "${LIBWEBP_LOG}" >&2 || true
        return 50
    fi
    if ! grep -q 'LIBWEBP_BENCH_COMPLETE' "${LIBWEBP_LOG}"; then
        log_message "ERROR: the lossless encode harness did not complete"
        return 50
    fi

    log_message "validating the reference CSV and building benchmark_libwebp.json"
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        --csv "${RESULTS_DIR}/result_bench-libwebp.csv" \
        --evidence "${RESULTS_DIR}/evidence.json" \
        --manifest "${SCRIPT_DIR}/fixtures/media.json" \
        --warmups "${LIBWEBP_WARMUPS}" \
        --samples "${LIBWEBP_SAMPLES}" \
        --version "${SOFTWARE_VERSION}" \
        --architecture "$(normalize_architecture "${EXPECTED_ARCH}")" \
        --variant "${PERF_VARIANT}" \
        --output "${RESULTS_DIR}/benchmark_libwebp.json" || return 50
    log_message "benchmark result written: ${RESULTS_DIR}/benchmark_libwebp.json"
}
