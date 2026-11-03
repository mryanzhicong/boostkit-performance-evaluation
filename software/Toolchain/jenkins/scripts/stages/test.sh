#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../builders/base.sh"

# Every sample runs the Python driver *inside* this task's private container: the
# driver starts the controller JVM itself, waits for readiness, drives the REST
# API and reads VmHWM from the container's /proc, so the whole service lifecycle
# and every measured child process live in the container.  A single sample has two
# independent bounds: the driver enforces --timeout with a SIGALRM watchdog (it can
# then stop its controller JVM cleanly), and the in-container `timeout` is the
# outer backstop; this shell layer prints the sample log tail on failure.
run_measured_scenario() {
    local scenario="$1" action="$2" scale="$3" label="$4"
    local directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    local home="${JENKINS_HOMES_DIR}/${scenario}-${label}"
    local remaining sample_timeout hard_timeout rc
    remaining="$(remaining_seconds "${JENKINS_TEST_DEADLINE}")"
    if [[ "${JENKINS_TEST_DEADLINE}" -gt 0 && "${remaining}" -le 30 ]]; then
        log_message "ERROR: the ${JENKINS_TEST_BUDGET_SECONDS}s test budget is exhausted before ${scenario} ${label}"
        return 50
    fi
    sample_timeout="${JENKINS_DRIVER_TIMEOUT_SECONDS}"
    if [[ "${JENKINS_TEST_DEADLINE}" -gt 0 && "${remaining}" -lt "${sample_timeout}" ]]; then
        sample_timeout="${remaining}"
    fi
    hard_timeout=$(( sample_timeout + 20 ))
    jenkins_container_env_exec_at "${PERF_WORK_DIR}" timeout --kill-after=15 \
        "${hard_timeout}" python3 "${JENKINS_DRIVER}" \
        --scenario "${scenario}" \
        --action "${action}" \
        --scale "${scale}" \
        --json "${directory}/${label}.json" \
        --log "${directory}/${label}.log" \
        --timeout "${sample_timeout}" \
        --ready-timeout 180 \
        --build-timeout 300 \
        --java "${JENKINS_JAVA}" \
        --war "${JENKINS_WAR}" \
        --port "${JENKINS_PORT}" \
        --home "${home}" \
        --template-home "${JENKINS_TEMPLATE_HOME}" \
        --expected-version "${SOFTWARE_VERSION}"
    rc=$?
    if [[ "${rc}" -ne 0 ]]; then
        if [[ "${rc}" -eq 124 ]]; then
            log_message "ERROR: ${scenario} ${label} was killed by the in-container timeout after ${hard_timeout}s"
            jenkins_stop_stray_controllers || true
        else
            log_message "ERROR: ${scenario} ${label} failed with exit code ${rc}"
            jenkins_stop_stray_controllers || true
        fi
        print_log_tail "${directory}/${label}.log" 40
        return 50
    fi
    rm -rf -- "${home}"
}

# Reap a controller left behind inside the container: the host pgrep path also
# works (container processes are visible to the host kernel), but stopping it
# through the container keeps the "service first, container second" order explicit.
jenkins_stop_stray_controllers() {
    jenkins_container_exec pgrep -f "jenkins.war.*--httpPort=${JENKINS_PORT}" >/dev/null 2>&1 || return 0
    jenkins_container_exec pkill -TERM -f "jenkins.war.*--httpPort=${JENKINS_PORT}" || true
    sleep 2
    jenkins_container_exec pkill -KILL -f "jenkins.war.*--httpPort=${JENKINS_PORT}" || true
    return 0
}

run_jenkins_benchmarks() {
    initialize_runtime || return $?
    check_jenkins_container || return $?
    load_container_jdk
    export_java_env
    validate_reps || return $?
    jenkins_container_exec test -f "${JENKINS_TEMPLATE_HOME}/config.xml" || {
        log_message "ERROR: the initialized JENKINS_HOME template is missing; run the build stage first"
        return 40
    }
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"
    JENKINS_TEST_DEADLINE=$(( $(date +%s) + JENKINS_TEST_BUDGET_SECONDS ))
    log_message "test budget: ${JENKINS_TEST_BUDGET_SECONDS}s, per-sample limit: ${JENKINS_DRIVER_TIMEOUT_SECONDS}s (driver runs inside ${JENKINS_CONTAINER_NAME})"
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
