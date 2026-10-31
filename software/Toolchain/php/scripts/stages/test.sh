#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_measured_command() {
    local scenario="$1" label="$2" workdir="$3"
    shift 3
    local directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    (
        cd "${workdir}" || exit 1
        python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
            --json "${directory}/${label}.json" \
            --log "${directory}/${label}.log" \
            --timeout "${PHP_RUN_TIMEOUT_SECONDS}" \
            -- "$@"
    )
}

run_scenario_repetition() {
    local scenario="$1" runner="$2" target="$3" scale="$4" label="$5"
    case "${runner}" in
        php_script)
            run_measured_command "${scenario}" "${label}" "${PERF_WORK_DIR}" \
                "${PHP_BIN}" -n -d memory_limit=512M \
                "${SCRIPT_DIR}/benchmarks/${target}" "${scenario}" "${scale}" || return $?
            ;;
        php_upstream_bench)
            run_measured_command "${scenario}" "${label}" "${PERF_WORK_DIR}" \
                "${PHP_BIN}" -n "${PHP_SRC_DIR}/${target}" || return $?
            ;;
        *)
            log_message "ERROR: unsupported runner in ${PHP_SCENARIOS_FILE}: ${runner}"
            return 50
            ;;
    esac
}

run_php_benchmarks() {
    initialize_runtime || return $?
    validate_reps || return $?
    [[ -x "${PHP_BIN}" ]] || {
        log_message "ERROR: built PHP CLI is unavailable under ${PHP_INSTALL_DIR}"
        return 40
    }
    [[ -f "${PHP_SCENARIOS_FILE}" ]] || {
        log_message "ERROR: workload matrix manifest is missing: ${PHP_SCENARIOS_FILE}"
        return 50
    }
    export PHP_MODULES_DIR="${PHP_GENERATED_DIR}"
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"

    local scenario dimension runner target scale check expected tolerance workload
    local scenario_total=0 rep
    while IFS='|' read -r scenario dimension runner target scale check expected tolerance workload; do
        [[ -z "${scenario}" || "${scenario}" == \#* ]] && continue
        log_message "scenario ${scenario} (${dimension}/${runner}): warmup"
        run_scenario_repetition "${scenario}" "${runner}" "${target}" "${scale}" warmup || return $?
        for ((rep = 1; rep <= PHP_REPS; rep++)); do
            log_message "scenario ${scenario}: rep ${rep}/${PHP_REPS}"
            run_scenario_repetition "${scenario}" "${runner}" "${target}" "${scale}" "rep${rep}" || return $?
        done
        scenario_total=$((scenario_total + 1))
    done < "${PHP_SCENARIOS_FILE}"

    if [[ "${scenario_total}" -lt 1 ]]; then
        log_message "ERROR: workload matrix manifest contains no scenarios"
        return 50
    fi

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PHP_REPS
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" \
        "${PHP_SCENARIOS_FILE}" || return $?
    log_message "complete PHP workload matrix finished: ${scenario_total} scenarios, reps=${PHP_REPS} (warmup 1, offline measurement)"
}
