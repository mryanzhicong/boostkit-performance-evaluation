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

# Validate the pinned correctness markers of one upstream-suite log.
verify_upstream_output() {
    local log_file="$1"
    if ! grep -q "\[==========\] ${GOOGLETEST_UPSTREAM_TESTS} tests from ${GOOGLETEST_UPSTREAM_SUITES} test suites ran\." "${log_file}"; then
        report_failure_tail "${log_file}" upstream_gtest_unittest "missing-summary" 50
        return 50
    fi
    if ! grep -q "\[  PASSED  \] ${GOOGLETEST_UPSTREAM_TESTS} tests\." "${log_file}"; then
        report_failure_tail "${log_file}" upstream_gtest_unittest "missing-passed-count" 50
        return 50
    fi
    return 0
}

# Validate the pinned correctness markers of one matrix log: the workspace line
# the driver prints itself, plus the GoogleTest summary lines.
verify_matrix_output() {
    local log_file="$1" scenario="$2" mode tests assertions expected_passed total_tests
    IFS='|' read -r mode tests assertions < <(matrix_parameters "${scenario}") || return 1
    expected_passed="$(matrix_expected_passed "${scenario}")" || return 1
    if [[ "${tests}" -gt 0 ]]; then
        total_tests="${tests}"
    else
        total_tests=1
    fi
    if ! grep -q "\[gt-matrix\] mode=${mode} registered_tests=${tests} assertions=${assertions} rc=0" "${log_file}"; then
        report_failure_tail "${log_file}" "${scenario}" "missing-workload-line" 50
        return 50
    fi
    if ! grep -qE "\[==========\] ${total_tests} tests? from 1 test suite ran\." "${log_file}"; then
        report_failure_tail "${log_file}" "${scenario}" "missing-summary" 50
        return 50
    fi
    if ! grep -qE "\[  PASSED  \] ${expected_passed} tests?\." "${log_file}"; then
        report_failure_tail "${log_file}" "${scenario}" "missing-passed-count" 50
        return 50
    fi
    if grep -q "\[  FAILED  \]" "${log_file}"; then
        report_failure_tail "${log_file}" "${scenario}" "unexpected-failure" 50
        return 50
    fi
    return 0
}

run_one_rep() {
    local scenario="$1" label="$2" json_path="$3" log_path="$4"
    shift 4
    local -a command=("$@")
    # The timing wrapper itself runs inside the private container, so every sample
    # is derived from a container-native child process and docker's management
    # overhead never lands inside a measurement window.
    googletest_container_exec_at "${PERF_WORK_DIR}" \
        python3 "${TIMED_RUNNER}" --json "${json_path}" --log "${log_path}" -- "${command[@]}" || {
        local rc=$?
        report_failure_tail "${log_path}" "${scenario}" "${label}" "${rc}"
        return 50
    }
    return 0
}

scenario_binary() {
    case "$1" in
        upstream_gtest_unittest) printf '%s\n' "${GOOGLETEST_UPSTREAM_BIN}" ;;
        *) printf '%s\n' "${GOOGLETEST_MATRIX_BIN_DIR}/$(matrix_binary "$1")" ;;
    esac
}

# Run one scenario: one warm-up followed by PERF_REPS measured repetitions, and
# validate the correctness markers of every captured log.
run_scenario() {
    local scenario="$1"
    local binary
    binary="$(scenario_binary "${scenario}")" || return 50
    local scenario_dir="${RUNS_DIR}/${scenario}"
    mkdir -p "${scenario_dir}"
    local label name
    for label in warmup $(seq 1 "${GOOGLETEST_REPS}"); do
        if [[ "${label}" == warmup ]]; then
            name="warmup"
            log_message "scenario ${scenario}: warmup"
        else
            name="rep${label}"
            log_message "scenario ${scenario}: ${label}/${GOOGLETEST_REPS}"
        fi
        run_one_rep "${scenario}" "${name}" "${scenario_dir}/${name}.json" "${scenario_dir}/${name}.log" \
            "${binary}" || return 50
        if [[ "${scenario}" == "upstream_gtest_unittest" ]]; then
            verify_upstream_output "${scenario_dir}/${name}.log" || return 50
        else
            verify_matrix_output "${scenario_dir}/${name}.log" "${scenario}" || return 50
        fi
    done
    return 0
}

run_googletest_benchmarks() {
    initialize_runtime || return $?
    validate_reps || return 50
    check_googletest_container || return $?
    local python
    python="$(python_bin)" || return 50
    if ! googletest_container_exec test -x "${GOOGLETEST_UPSTREAM_BIN}"; then
        log_message "ERROR: upstream gtest_unittest binary is missing; build stage did not complete"
        return 50
    fi
    if [[ ! -f "${TIMED_RUNNER}" ]]; then
        log_message "ERROR: timing wrapper is missing: ${TIMED_RUNNER}"
        return 50
    fi
    assert_artifact "${PARSE_SCRIPT}" "result normalizer" || return 50
    rm -rf "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"
    log_message "running GoogleTest matrix: ${#GOOGLETEST_SCENARIOS[@]} scenarios, reps=${GOOGLETEST_REPS}"
    local scenario
    for scenario in "${GOOGLETEST_SCENARIOS[@]}"; do
        run_scenario "${scenario}" || return 50
    done
    log_message "normalizing evidence into results.json"
    "${python}" "${PARSE_SCRIPT}" \
        --runs-dir "${RUNS_DIR}" \
        --output "${RESULTS_DIR}/results.json" \
        --raw-output "${RESULTS_DIR}/raw-output.log" \
        --actual-version-file "${PERF_ACTUAL_VERSION_FILE}" \
        --repetitions "${GOOGLETEST_REPS}" \
        --matrix-1k "${GOOGLETEST_MATRIX_1K}" \
        --matrix-10k "${GOOGLETEST_MATRIX_10K}" \
        --assertion-loop "${GOOGLETEST_ASSERTION_LOOP}" \
        --upstream-tests "${GOOGLETEST_UPSTREAM_TESTS}" \
        --upstream-suites "${GOOGLETEST_UPSTREAM_SUITES}" \
        > "${PERF_WORK_DIR}/parse.log" 2>&1 || {
        local rc=$?
        report_failure_tail "${PERF_WORK_DIR}/parse.log" test normalize "${rc}"
        return 50
    }
    log_message "complete googletest matrix finished (reps=${GOOGLETEST_REPS}, scenarios=${#GOOGLETEST_SCENARIOS[@]})"
    return 0
}
