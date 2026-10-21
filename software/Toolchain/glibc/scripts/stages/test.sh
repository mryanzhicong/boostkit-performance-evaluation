#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_glibc_benchmarks() {
    initialize_runtime || return $?
    # See start_glibc_runtime: benchtest binaries must run without a host
    # LD_LIBRARY_PATH.
    unset LD_LIBRARY_PATH
    if [[ ! -x "${LDCONFIG_BIN}" ]]; then
        log_message "ERROR: glibc is not built; run the build stage first"
        return 50
    fi
    mkdir -p "${RESULTS_DIR}"
    if ! TIMING_TYPE_OUTPUT="$("${BUILD_DIR}/benchtests/bench-timing-type")"; then
        log_message "ERROR: bench-timing-type is not runnable"
        return 50
    fi
    if [[ "${TIMING_TYPE_OUTPUT}" != "clock_gettime_ns" ]]; then
        log_message "ERROR: benchtests use unexpected timing backend: ${TIMING_TYPE_OUTPUT}"
        return 50
    fi
    mkdir -p "${RESULTS_DIR}/benchtests"
    : > "${RESULTS_DIR}/benchmark_bench.txt"
    local bench_name output_path
    for bench_name in "${GLIBC_BENCHMARKS[@]}"; do
        output_path="${RESULTS_DIR}/benchtests/${bench_name}.out"
        log_message "running ${bench_name} with ${TIMING_TYPE_OUTPUT}"
        printf '%s\n' "${BUILD_DIR}/benchtests/${bench_name} > ${output_path}" \
            >> "${RESULTS_DIR}/benchmark_bench.txt"
        if ! "${BUILD_DIR}/benchtests/${bench_name}" > "${output_path}"; then
            log_message "ERROR: ${bench_name} failed"
            return 50
        fi
        if [[ ! -s "${output_path}" ]]; then
            log_message "ERROR: ${bench_name} produced empty output"
            return 50
        fi
    done
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT GLIBC_BENCHSET TIMING_TYPE_OUTPUT
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RESULTS_DIR}/benchtests" \
        "${RESULTS_DIR}/benchmark_glibc.json" || {
        log_message "ERROR: failed to normalize official glibc benchtest results"
        return 50
    }
    log_message "benchtest results written to benchmark_bench.txt and benchmark_glibc.json"
}
