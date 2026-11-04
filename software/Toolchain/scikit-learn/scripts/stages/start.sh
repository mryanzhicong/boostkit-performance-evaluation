#!/usr/bin/env bash
# Start stage: verify inside the private openEuler container that the pinned
# CPython runtime, the private virtual environment, the hash-locked wheels, the
# staged asv benchmark snapshot and the scenario manifest are ready for the
# measured run.  No service is started; the case measures CLI processes.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_scikit_learn_runtime() {
    initialize_runtime || return $?
    check_architecture || return $?
    check_scikit_learn_container || return $?
    scikit_learn_container_exec test -x "${VENV_PY}" || {
        log_message "ERROR: the private virtual environment is unavailable in the container: ${VENV_PY}"
        return 40
    }
    scikit_learn_container_exec "${VENV_PY}" -c \
        'import sklearn, numpy, scipy, joblib, narwhals, threadpoolctl' || {
        log_message "ERROR: the pinned runtime cannot be imported from the private virtual environment"
        return 40
    }
    local reported
    reported="$(scikit_learn_container_exec "${VENV_PY}" -c 'import sklearn; print(sklearn.__version__)')" || {
        log_message "ERROR: the private virtual environment does not report its scikit-learn version"
        return 40
    }
    if [[ "${reported}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: scikit-learn reports ${reported}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    log_message "scikit-learn ${reported} runtime is ready inside the private container"
    scikit_learn_container_exec test -d "${ASV_DIR}/benchmarks" || {
        log_message "ERROR: the staged asv benchmark suite is missing in the container: ${ASV_DIR}/benchmarks"
        return 40
    }
    scikit_learn_container_exec_at "${ASV_DIR}" sha256sum --quiet -c manifest.sha256 || {
        log_message "ERROR: the staged asv benchmark suite does not match its manifest"
        return 40
    }
    [[ -s "${SCENARIOS_FILE}" ]] || {
        log_message "ERROR: scenario definition file is missing: ${SCENARIOS_FILE}"
        return 40
    }
    local expected_scenarios staged_scenarios
    expected_scenarios="$(count_scenario_entries)" || return 40
    staged_scenarios="${#SKLEARN_SCENARIOS[@]}"
    if [[ "${expected_scenarios}" != "${staged_scenarios}" ]]; then
        log_message "ERROR: ${staged_scenarios} scenarios configured but ${expected_scenarios} defined in scenarios.json"
        return 40
    fi
    mkdir -p "${RUNS_DIR}"
    log_message "scikit-learn ${SOFTWARE_VERSION} measurement runtime is ready inside the private container (${staged_scenarios} scenarios)"
}
