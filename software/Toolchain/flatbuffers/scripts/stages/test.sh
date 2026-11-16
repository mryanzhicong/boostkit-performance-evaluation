#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

TIMED_RUNNER="${SCRIPT_DIR}/scripts/run_timed.py"
PARSE_SCRIPT="${SCRIPT_DIR}/scripts/results/parse_benchmark.py"

python_bin() {
    if command -v python3 >/dev/null 2>&1; then
        command -v python3
        return 0
    fi
    log_message "ERROR: python3 is required to run the timing wrapper"
    return 50
}

assert_artifact() {
    local path="$1" label="$2"
    if [[ ! -e "${path}" ]]; then
        log_message "ERROR: ${label} is missing: ${path}"
        return 50
    fi
}

# Validate the fixed correctness markers of one driver log.
verify_driver_output() {
    local log_file="$1" scenario="$2" mode elements iterations expected
    IFS='|' read -r mode elements iterations < <(driver_parameters "${scenario}") || return 1
    expected="$(driver_expected_checksum "${scenario}")" || return 1
    local pattern
    pattern="mode=${mode} elements=${elements} iterations=${iterations}"
    if ! grep -q "${pattern}" "${log_file}"; then
        report_failure_tail "${log_file}" "${scenario}" "missing-parameters" 50
        return 50
    fi
    if ! grep -q "checksum=${expected} expected=${expected}" "${log_file}"; then
        report_failure_tail "${log_file}" "${scenario}" "checksum-mismatch" 50
        return 50
    fi
    if ! grep -q "encoded_bytes=[1-9][0-9]*" "${log_file}"; then
        report_failure_tail "${log_file}" "${scenario}" "missing-encoded-bytes" 50
        return 50
    fi
    return 0
}

verify_upstream_output() {
    local log_file="$1"
    if ! grep -q "mode=upstream batches=${FLATBUFFERS_UPSTREAM_BATCHES} iterations=${FLATBUFFERS_UPSTREAM_ITERATIONS}" "${log_file}"; then
        report_failure_tail "${log_file}" upstream_bench_encode_use "missing-parameters" 50
        return 50
    fi
    if ! grep -q "checksum_ok=1" "${log_file}"; then
        report_failure_tail "${log_file}" upstream_bench_encode_use "checksum-mismatch" 50
        return 50
    fi
    if ! grep -q "encoded_bytes=[1-9][0-9]*" "${log_file}"; then
        report_failure_tail "${log_file}" upstream_bench_encode_use "missing-encoded-bytes" 50
        return 50
    fi
    return 0
}

run_one_rep() {
    local scenario="$1" label="$2" json_path="$3" log_path="$4"
    shift 4
    local -a command=("$@")
    # The timing wrapper runs inside the private container so every sample is
    # produced by a container-native child and `docker exec` overhead stays
    # outside the measurement window.
    flatbuffers_container_exec_at "${PERF_WORK_DIR}" \
        python3 "${TIMED_RUNNER}" --json "${json_path}" --log "${log_path}" -- "${command[@]}" || {
        local rc=$?
        report_failure_tail "${log_path}" "${scenario}" "${label}" "${rc}"
        return 50
    }
    return 0
}

# Run one scenario: one warm-up followed by PERF_REPS measured repetitions, and
# validate the correctness markers of every captured log.
run_scenario() {
    local scenario="$1"
    local scenario_dir="${RUNS_DIR}/${scenario}"
    mkdir -p "${scenario_dir}"
    log_message "scenario ${scenario}: warmup"
    if [[ "${scenario}" == "upstream_bench_encode_use" ]]; then
        run_one_rep "${scenario}" warmup "${scenario_dir}/warmup.json" "${scenario_dir}/warmup.log" \
            "${FLATBUFFERS_UPSTREAM_BIN}" "${FLATBUFFERS_UPSTREAM_BATCHES}" || return 50
        verify_upstream_output "${scenario_dir}/warmup.log" || return 50
        local rep
        for (( rep = 1; rep <= FLATBUFFERS_REPS; rep++ )); do
            log_message "scenario ${scenario}: ${rep}/${FLATBUFFERS_REPS}"
            run_one_rep "${scenario}" "rep${rep}" "${scenario_dir}/rep${rep}.json" "${scenario_dir}/rep${rep}.log" \
                "${FLATBUFFERS_UPSTREAM_BIN}" "${FLATBUFFERS_UPSTREAM_BATCHES}" || return 50
            verify_upstream_output "${scenario_dir}/rep${rep}.log" || return 50
        done
        return 0
    fi
    local mode elements iterations
    IFS='|' read -r mode elements iterations < <(driver_parameters "${scenario}") || return 50
    run_one_rep "${scenario}" warmup "${scenario_dir}/warmup.json" "${scenario_dir}/warmup.log" \
        "${FLATBUFFERS_DRIVER_BIN}" --mode "${mode}" --elements "${elements}" --iterations "${iterations}" || return 50
    verify_driver_output "${scenario_dir}/warmup.log" "${scenario}" || return 50
    local rep
    for (( rep = 1; rep <= FLATBUFFERS_REPS; rep++ )); do
        log_message "scenario ${scenario}: ${rep}/${FLATBUFFERS_REPS}"
        run_one_rep "${scenario}" "rep${rep}" "${scenario_dir}/rep${rep}.json" "${scenario_dir}/rep${rep}.log" \
            "${FLATBUFFERS_DRIVER_BIN}" --mode "${mode}" --elements "${elements}" --iterations "${iterations}" || return 50
        verify_driver_output "${scenario_dir}/rep${rep}.log" "${scenario}" || return 50
    done
    return 0
}

run_flatbuffers_benchmarks() {
    initialize_runtime || return $?
    check_flatbuffers_container || return $?
    validate_reps || return 50
    local python
    python="$(python_bin)" || return 50
    assert_artifact "${FLATBUFFERS_DRIVER_BIN}" "multi-scale benchmark driver" || return 50
    assert_artifact "${FLATBUFFERS_UPSTREAM_BIN}" "upstream benchmark runner" || return 50
    assert_artifact "${TIMED_RUNNER}" "timing wrapper" || return 50
    assert_artifact "${PARSE_SCRIPT}" "result normalizer" || return 50
    rm -rf "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"
    log_message "running FlatBuffers matrix: ${#FLATBUFFERS_SCENARIOS[@]} scenarios, reps=${FLATBUFFERS_REPS}, jobs=${FLATBUFFERS_JOBS}"
    local scenario
    for scenario in "${FLATBUFFERS_SCENARIOS[@]}"; do
        run_scenario "${scenario}" || return 50
    done
    log_message "normalizing evidence into results.json"
    "${python}" "${PARSE_SCRIPT}" \
        --runs-dir "${RUNS_DIR}" \
        --output "${RESULTS_DIR}/results.json" \
        --raw-output "${RESULTS_DIR}/raw-output.log" \
        --actual-version-file "${PERF_ACTUAL_VERSION_FILE}" \
        --repetitions "${FLATBUFFERS_REPS}" \
        --upstream-batches "${FLATBUFFERS_UPSTREAM_BATCHES}" \
        > "${PERF_WORK_DIR}/parse.log" 2>&1 || {
        local rc=$?
        report_failure_tail "${RESULTS_DIR}/parse.log" test normalize "${rc}"
        return 50
    }
    log_message "complete flatbuffers matrix finished (reps=${FLATBUFFERS_REPS}, scenarios=${#FLATBUFFERS_SCENARIOS[@]})"
    return 0
}
