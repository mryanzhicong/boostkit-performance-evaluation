#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../builders/base.sh"

run_measured_scenario() {
    local scenario="$1" action="$2" scale="$3" label="$4"
    local directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    local home="${JENKINS_HOMES_DIR}/${scenario}-${label}"
    python3 "${JENKINS_DRIVER}" \
        --scenario "${scenario}" \
        --action "${action}" \
        --scale "${scale}" \
        --json "${directory}/${label}.json" \
        --log "${directory}/${label}.log" \
        --timeout "${JENKINS_DRIVER_TIMEOUT_SECONDS}" \
        --ready-timeout 180 \
        --build-timeout 300 \
        --java "${JENKINS_JAVA}" \
        --war "${JENKINS_WAR}" \
        --port "${JENKINS_PORT}" \
        --home "${home}" \
        --template-home "${JENKINS_TEMPLATE_HOME}" \
        --expected-version "${SOFTWARE_VERSION}"
}

run_jenkins_benchmarks() {
    initialize_runtime || return $?
    export_java_env
    validate_reps || return $?
    [[ -f "${JENKINS_TEMPLATE_HOME}/config.xml" ]] || {
        log_message "ERROR: the initialized JENKINS_HOME template is missing; run the build stage first"
        return 40
    }
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"
    local scenario dimension action scale check expected workload rep
    local total handled=0
    total="$(scenario_count)"
    while IFS='|' read -r scenario dimension action scale check expected workload; do
        [[ -z "${scenario}" || "${scenario}" == \#* ]] && continue
        handled=$((handled + 1))
        log_message "scenario ${scenario} (${dimension}): warmup"
        run_measured_scenario "${scenario}" "${action}" "${scale}" warmup || return $?
        for ((rep = 1; rep <= JENKINS_REPS; rep++)); do
            log_message "scenario ${scenario} (${dimension}): rep ${rep}/${JENKINS_REPS}"
            run_measured_scenario "${scenario}" "${action}" "${scale}" "rep${rep}" || return $?
        done
    done < "${JENKINS_SCENARIOS_FILE}"
    if [[ "${handled}" != "${total}" ]]; then
        log_message "ERROR: scenario manifest read ${handled} of ${total} scenarios"
        return 40
    fi

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" || return $?
    log_message "complete Jenkins matrix finished (reps=${JENKINS_REPS})"
}
