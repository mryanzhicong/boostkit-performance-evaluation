#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_rust_benchmarks() {
    initialize_runtime || return $?
    load_rust_toolchain || return $?
    [[ -x "${COLLECTOR_BIN}" ]] || {
        log_message 'ERROR: collector binary is missing; build stage did not complete'
        return 40
    }
    rm -f "${RUST_DB}"
    log_message "running upstream rustc-perf compile benchmarks: ${RUST_COMPILE_CATEGORY} x ${RUST_COMPILE_PROFILES} x ${RUST_COMPILE_SCENARIOS}"
    (cd "${RUSTC_PERF_DIR}" && \
        env CARGO_HOME="${CARGO_HOME}" TMPDIR="${TMPDIR}" \
            "${COLLECTOR_BIN}" bench_local "${RUSTC_BIN}" \
                --id "${RUST_BENCH_ID}" \
                --cargo "${CARGO_BIN}" \
                --profiles "${RUST_COMPILE_PROFILES}" \
                --scenarios "${RUST_COMPILE_SCENARIOS}" \
                --category "${RUST_COMPILE_CATEGORY}" \
                --iterations "${RUST_COMPILE_ITERATIONS}" \
                --db "${RUST_DB}") 2>&1 | tee "${RESULTS_DIR}/benchmark_rust_compile.log" || {
        log_message 'ERROR: upstream compile benchmark run failed'
        return 50
    }
    log_message "running upstream rustc-perf runtime benchmarks: ${RUST_RUNTIME_ITERATIONS} iterations"
    (cd "${RUSTC_PERF_DIR}" && \
        env CARGO_HOME="${CARGO_HOME}" TMPDIR="${TMPDIR}" \
            "${COLLECTOR_BIN}" bench_runtime_local "${RUSTC_BIN}" \
                --id "${RUST_BENCH_ID}" \
                --cargo "${CARGO_BIN}" \
                --iterations "${RUST_RUNTIME_ITERATIONS}" \
                --db "${RUST_DB}") 2>&1 | tee "${RESULTS_DIR}/benchmark_rust_runtime.log" || {
        log_message 'ERROR: upstream runtime benchmark run failed'
        return 50
    }
    cp -f "${RUST_DB}" "${RESULTS_DIR}/rustc_perf.db" || return 50
    python3 "${CASE_DIR}/scripts/results/parse_benchmark.py" \
        --results-dir "${RESULTS_DIR}" \
        --database "${RESULTS_DIR}/rustc_perf.db" \
        --compile-benchmarks "${RUSTC_PERF_DIR}/collector/compile-benchmarks" \
        --runtime-log "${RESULTS_DIR}/benchmark_rust_runtime.log" \
        --rustc-version-file "${PERF_WORK_DIR}/rustc-version.txt" \
        --target-triple "${RUST_TARGET_TRIPLE}" \
        --artifact-id "${RUST_BENCH_ID}" || {
        log_message 'ERROR: rustc-perf result parsing failed'
        return 50
    }
}
