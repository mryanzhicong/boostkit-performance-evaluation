#!/usr/bin/env bash
# Start stage: verify that the pinned pandas runtime, the staged asv benchmark
# snapshot and the scenario definition are available *inside this task's private
# container*.  The container is the execution environment for every timed
# sample, so "start" means "the measured workload is ready and reproducible".
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_pandas_runtime() {
    initialize_runtime || return $?
    check_architecture || return $?
    check_pandas_container || return $?
    pandas_container_exec test -x "${VENV_PY}" || {
        log_message "ERROR: the private virtual environment is unavailable inside the container: ${VENV_PY}"
        return 40
    }
    pandas_container_exec "${VENV_PY}" -c 'import pandas, numpy, dateutil, six' || {
        log_message "ERROR: the pinned runtime cannot be imported inside the container"
        return 40
    }
    local reported
    reported="$(pandas_container_exec "${VENV_PY}" -c \
        'import sys, pandas; actual = pandas.__version__; expected = sys.argv[1]; sys.exit(0 if actual == expected else f"pandas reports {actual}, expected {expected}"); print(f"[pandas] pandas {actual} runtime is ready")' \
        "${SOFTWARE_VERSION}")" || {
        log_message "ERROR: the private virtual environment does not report the requested pandas version"
        return 40
    }
    log_message "${reported}"
    pandas_container_exec test -d "${ASV_DIR}/benchmarks" || {
        log_message "ERROR: the staged asv benchmark suite is missing inside the container: ${ASV_DIR}/benchmarks"
        return 40
    }
    pandas_container_exec_at "${ASV_DIR}" sha256sum --quiet -c manifest.sha256 || {
        log_message "ERROR: the staged asv benchmark suite does not match its manifest"
        return 40
    }
    [[ -s "${SCENARIOS_FILE}" ]] || {
        log_message "ERROR: scenario definition file is missing: ${SCENARIOS_FILE}"
        return 40
    }
    local expected_scenarios staged_scenarios
    expected_scenarios="$(count_scenario_entries)" || return 40
    staged_scenarios="${#PANDAS_SCENARIOS[@]}"
    if [[ "${expected_scenarios}" != "${staged_scenarios}" ]]; then
        log_message "ERROR: ${staged_scenarios} scenarios configured but ${expected_scenarios} defined in scenarios.json"
        return 40
    fi
    mkdir -p "${RUNS_DIR}"
    log_message "pandas ${SOFTWARE_VERSION} measurement runtime is ready inside ${PANDAS_CONTAINER_NAME} (${staged_scenarios} scenarios)"
}
