#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Every measured R workload runs inside the private container.  ``run_timed.py``
# forwards the fixed measurement environment (C locale, UTC, closed proxies)
# through ``r_container_measure_at`` because docker exec does not inherit the
# caller's environment, and it starts the workload as its direct child so the
# docker exec overhead never enters a measurement window.
run_measured_command() {
    local scenario="$1" label="$2"
    shift 2
    local directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    r_container_measure_at "${PERF_WORK_DIR}" python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
        --json "${directory}/${label}.json" \
        --log "${directory}/${label}.log" \
        --timeout "${BENCH_RUN_TIMEOUT_SECONDS}" \
        -- "$@" || return 50
    return 0
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
    check_r_container || return $?
    if ! r_container_exec test -x "${BENCH_BIN}"; then
        log_message "ERROR: built runtime is unavailable inside the private container: ${BENCH_BIN}"
        return 50
    fi
    if [[ ! -f "${BENCH_SCENARIOS_FILE}" ]]; then
        log_message "ERROR: workload matrix manifest is missing: ${BENCH_SCENARIOS_FILE}"
        return 50
    fi
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
    log_message "complete R workload matrix finished: ${scenario_total} scenarios, reps=${BENCH_REPS} (warmup 1, offline measurement, private container)"
}
