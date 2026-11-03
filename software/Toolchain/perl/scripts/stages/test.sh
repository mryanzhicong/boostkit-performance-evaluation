#!/usr/bin/env bash
# Test stage: every measured Perl workload runs inside this task's private
# container through the in-container timing wrapper; only the strict result
# parser stays on the host.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_measured_command() {
    local scenario="$1" label="$2"
    shift 2
    local directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    perl_container_exec_at "${PERF_WORK_DIR}" \
        python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
        --json "${directory}/${label}.json" \
        --log "${directory}/${label}.log" \
        --timeout "${BENCH_RUN_TIMEOUT_SECONDS}" \
        -- "$@"
}

run_scenario_repetition() {
    local scenario="$1" runner="$2" target="$3" scale="$4" label="$5"
    workload_invoke "${scenario}" "${runner}" "${target}" "${scale}" "${label}" || return $?
    if [[ "${#MEASURED_CMD[@]}" -eq 0 ]]; then
        log_message "ERROR: no command produced for scenario ${scenario} (runner ${runner})"
        return 50
    fi
    run_measured_command "${scenario}" "${label}" "${MEASURED_CMD[@]}" || return $?
}

run_benchmarks() {
    initialize_runtime || return $?
    validate_reps || return $?
    check_perl_container || return $?
    perl_container_exec test -x "${BENCH_BIN}" || {
        log_message "ERROR: built runtime is unavailable inside the container: ${BENCH_BIN}"
        return 40
    }
    [[ -f "${BENCH_SCENARIOS_FILE}" ]] || {
        log_message "ERROR: workload matrix manifest is missing: ${BENCH_SCENARIOS_FILE}"
        return 50
    }
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"

    local scenario dimension runner target scale check expected tolerance workload
    local scenario_total=0 rep
    while IFS='|' read -r scenario dimension runner target scale check expected tolerance workload; do
        [[ -z "${scenario}" || "${scenario}" == \#* ]] && continue
        [[ "${scenario}" == "scenario" ]] && continue
        log_message "scenario ${scenario} (${dimension}/${runner}): warmup"
        run_scenario_repetition "${scenario}" "${runner}" "${target}" "${scale}" warmup || return $?
        for ((rep = 1; rep <= BENCH_REPS; rep++)); do
            log_message "scenario ${scenario}: rep ${rep}/${BENCH_REPS}"
            run_scenario_repetition "${scenario}" "${runner}" "${target}" "${scale}" "rep${rep}" || return $?
        done
        scenario_total=$((scenario_total + 1))
    done < "${BENCH_SCENARIOS_FILE}"

    if [[ "${scenario_total}" -lt 1 ]]; then
        log_message "ERROR: workload matrix manifest contains no scenarios"
        return 50
    fi

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT BENCH_REPS
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" \
        "${BENCH_SCENARIOS_FILE}" || return $?
    log_message "complete Perl workload matrix finished inside ${PERL_CONTAINER_NAME}: ${scenario_total} scenarios, reps=${BENCH_REPS} (warmup 1, offline measurement)"
}
