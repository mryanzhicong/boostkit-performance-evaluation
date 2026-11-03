#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_rust_benchmarks() {
    initialize_runtime || return $?
    check_rust_container || return $?
    container_exec test -x "${COLLECTOR_BIN}" || {
        log_message 'ERROR: collector binary is missing; build stage did not complete'
        return 40
    }
    container_exec rm -f "${RUST_DB}"
    log_message "running upstream rustc-perf compile benchmarks inside the container: ${RUST_COMPILE_CATEGORY} x ${RUST_COMPILE_PROFILES} x ${RUST_COMPILE_SCENARIOS}"
    if ! container_exec sh -c \
        "export PATH=\"${RUST_HOME}/bin:\$PATH\" && cd '${RUSTC_PERF_DIR}' && '${COLLECTOR_BIN}' bench_local '${RUSTC_BIN}' \
            --id '${RUST_BENCH_ID}' --cargo '${CARGO_BIN}' \
            --profiles '${RUST_COMPILE_PROFILES}' --scenarios '${RUST_COMPILE_SCENARIOS}' \
            --category '${RUST_COMPILE_CATEGORY}' --iterations '${RUST_COMPILE_ITERATIONS}' \
            --db '${RUST_DB}'" \
        2>&1 | tee "${RESULTS_DIR}/benchmark_rust_compile.log"; then
        log_message 'ERROR: upstream compile benchmark run failed'
        return 50
    fi
    log_message "running upstream rustc-perf runtime benchmarks inside the container: ${RUST_RUNTIME_ITERATIONS} iterations"
    if ! container_exec sh -c \
        "cd '${RUSTC_PERF_DIR}' && '${COLLECTOR_BIN}' bench_runtime_local '${RUSTC_BIN}' \
            --id '${RUST_BENCH_ID}' --cargo '${CARGO_BIN}' \
            --iterations '${RUST_RUNTIME_ITERATIONS}' --db '${RUST_DB}'" \
        2>&1 | tee "${RESULTS_DIR}/benchmark_rust_runtime.log"; then
        log_message 'ERROR: upstream runtime benchmark run failed'
        return 50
    fi
    container_exec cp -f "${RUST_DB}" "${RESULTS_DIR}/rustc_perf.db" || {
        log_message 'ERROR: cannot copy the rustc-perf database into the result directory'
        return 50
    }
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
