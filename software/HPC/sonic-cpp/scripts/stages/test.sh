#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_sonic_cpp_benchmarks() {
    initialize_runtime || return $?
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log_message "ERROR: official sonic-cpp benchmark binary is unavailable: ${BENCHMARK_BIN}"
        return 40
    }
    log_message "running official CMake benchmark (benchmark/main.cpp)"
    (
        # The binary loads testdata/ relative to the working directory.
        cd "${SOURCE_DIR}"
        "${BENCHMARK_BIN}" \
            "--benchmark_out_format=json" \
            "--benchmark_out=${RESULTS_DIR}/benchmark.json" \
            "--benchmark_filter=Sonic" \
            "--benchmark_min_time=${BENCHMARK_MIN_TIME}"
    ) || {
        log_message "ERROR: official sonic-cpp benchmark failed"
        return 50
    }
    export SOFTWARE_VERSION EXPECTED_ARCH BENCHMARK_MIN_TIME PERF_VARIANT
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RESULTS_DIR}/benchmark.json" \
        "${RESULTS_DIR}/benchmark_sonic_cpp.json" || {
        log_message "ERROR: failed to normalize official sonic-cpp benchmark results"
        return 50
    }
    log_message "sonic-cpp benchmark results written to benchmark.json and benchmark_sonic_cpp.json"
}
