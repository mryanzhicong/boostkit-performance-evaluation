#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_protobuf_benchmarks() {
    initialize_runtime || return $?
    if [[ ! -x "${PROTOC_BIN}" ]]; then
        log_message "ERROR: private protoc is unavailable: ${PROTOC_BIN}"
        return 40
    fi
    if [[ ! -x "${BENCHMARK_BIN}" ]]; then
        log_message "ERROR: original protobuf-benchmark binary is unavailable"
        return 40
    fi
    if [[ ! -x "${FIXTURE_DUMP_BIN}" ]]; then
        log_message "ERROR: protobuf fixture generator is unavailable"
        return 40
    fi
    local fixture_dir="${PERF_WORK_DIR}/fixtures"
    local repeat_dir="${PERF_WORK_DIR}/fixtures-repeat"
    mkdir -p "${fixture_dir}" "${repeat_dir}"
    "${FIXTURE_DUMP_BIN}" "${fixture_dir}" || return 50
    "${FIXTURE_DUMP_BIN}" "${repeat_dir}" || return 50
    (cd "${fixture_dir}" && LC_ALL=C sha256sum -- *.pb) \
        > "${RESULTS_DIR}/fixture_sha256.txt"
    (cd "${repeat_dir}" && LC_ALL=C sha256sum -- *.pb) \
        > "${RESULTS_DIR}/fixture_sha256_repeat.txt"
    if [[ "$(wc -l < "${RESULTS_DIR}/fixture_sha256.txt")" -ne 84 ]] ||
       ! cmp -s "${RESULTS_DIR}/fixture_sha256.txt" "${RESULTS_DIR}/fixture_sha256_repeat.txt"; then
        log_message "ERROR: expected 84 reproducible Protobuf fixtures"
        return 50
    fi
    rm -f -- "${RESULTS_DIR}/fixture_sha256_repeat.txt"
    log_message "verified 84 reproducible fixture hashes; compare fixture_sha256.txt across architectures"
    local cases_file="${RESULTS_DIR}/benchmark_cases.txt"
    if ! "${BENCHMARK_BIN}" --benchmark_list_tests=true > "${cases_file}"; then
        log_message "ERROR: could not list original protobuf-benchmark cases"
        return 50
    fi
    if [[ "$(wc -l < "${cases_file}")" -ne 168 ]]; then
        log_message "ERROR: expected 168 original protobuf-benchmark cases"
        return 50
    fi
    log_message "running all 168 original C++ cases (1s minimum, 5 repetitions)"
    if ! "${BENCHMARK_BIN}" --benchmark_min_time=1s \
        --benchmark_repetitions=5 --benchmark_display_aggregates_only=true \
        --benchmark_out="${RESULTS_DIR}/benchmark_google.json" \
        --benchmark_out_format=json \
        2>&1 | tee "${RESULTS_DIR}/benchmark_google.log"; then
        log_message "ERROR: original protobuf-benchmark execution failed"
        return 50
    fi
    if ! python3 "${SCRIPT_DIR}/scripts/results/parse_google_benchmark.py" \
        "${RESULTS_DIR}/benchmark_google.json" "${cases_file}" \
        "${RESULTS_DIR}/benchmark_protobuf.json"; then
        log_message "ERROR: failed to normalize Google Benchmark results"
        return 50
    fi
    log_message "original protobuf-benchmark results are ready"
}
