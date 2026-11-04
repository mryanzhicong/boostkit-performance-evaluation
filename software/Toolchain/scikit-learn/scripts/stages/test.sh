#!/usr/bin/env bash
# Test stage: every measured scenario runs inside the private openEuler
# container.  The pinned BLAS/OpenMP thread pools, hash seed, locale, timezone
# and offline proxy policy are re-applied inside the container through
# sklearn_container_exec_measured(), so the measured process sees exactly the
# same environment as on a native runner.  The strict parser stays on the host.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

print_log_tail() {
    local log_file="$1"
    if [[ -s "${log_file}" ]]; then
        log_message "last 40 lines of ${log_file}:"
        tail -40 "${log_file}" || true
    fi
}

verify_pinned_runtime() {
    local script_path="${PERF_WORK_DIR}/build/verify_runtime.py"
    mkdir -p "$(dirname "${script_path}")"
    cat > "${script_path}" <<'PY'
import json
import sys
from importlib import metadata

expected = json.loads(open(sys.argv[1], encoding="utf-8").read())["runtime"]
packages = ["numpy", "scipy", "scikit-learn", "joblib", "narwhals", "threadpoolctl"]
actual = {name: metadata.version(name) for name in packages}
if actual != expected:
    raise SystemExit(f"runtime mismatch: installed {actual}, built with {expected}")
print(f"[sklearn] pinned runtime verified: {actual}")
PY
    scikit_learn_container_exec_at "${PERF_WORK_DIR}" \
        "${VENV_PY}" "${script_path}" "${RUNTIME_VERSIONS_JSON}"
}

run_timed_in_container() {
    local label="$1" log_file="$2" json_file="$3" timeout_seconds="$4" scenario="$5"
    sklearn_container_exec_measured "${PERF_WORK_DIR}" \
        python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
        --label "${label}" \
        --log "${log_file}" \
        --json "${json_file}" \
        --timeout "${timeout_seconds}" \
        --working-directory "${PERF_WORK_DIR}" \
        -- "${VENV_PY}" "${SCRIPT_DIR}/scripts/fixtures/asv_runner.py" \
            --mode measure \
            --scenario "${scenario}" \
            --scenarios "${SCENARIOS_FILE}" \
            --benchmarks-dir "${ASV_DIR}" >> "${RESULTS_DIR}/measurement.log" 2>&1
}

run_scenario_repetitions() {
    local scenario="$1" index log_file json_file timeout_seconds command_status
    timeout_seconds="$(scenario_timeout "${scenario}")"
    mkdir -p "${RUNS_DIR}/${scenario}"
    rm -f "${RUNS_DIR}/${scenario}"/*.log "${RUNS_DIR}/${scenario}"/*.json

    if [[ "${SKLEARN_WARMUPS}" -gt 0 ]]; then
        log_file="${RUNS_DIR}/${scenario}/warmup.log"
        json_file="${RUNS_DIR}/${scenario}/warmup.json"
        log_message "warmup: ${scenario}"
        if ! run_timed_in_container "${scenario}#warmup" "${log_file}" "${json_file}" \
            "${timeout_seconds}" "${scenario}"; then
            log_message "ERROR: warmup failed for scenario ${scenario}"
            print_log_tail "${log_file}"
            return 50
        fi
    fi

    for ((index = 1; index <= SKLEARN_REPS; index++)); do
        log_file="${RUNS_DIR}/${scenario}/rep${index}.log"
        json_file="${RUNS_DIR}/${scenario}/rep${index}.json"
        log_message "sample ${index}/${SKLEARN_REPS}: ${scenario}"
        if ! run_timed_in_container "${scenario}#${index}" "${log_file}" "${json_file}" \
            "${timeout_seconds}" "${scenario}"; then
            log_message "ERROR: sample ${index} failed for scenario ${scenario}"
            print_log_tail "${log_file}"
            return 50
        fi
        command_status=0
        if ! grep -q '^\[sklearn-bench\] ' "${log_file}"; then
            log_message "ERROR: sample ${index} of ${scenario} produced no benchmark evidence line"
            print_log_tail "${log_file}"
            return 50
        fi
        [[ "${command_status}" -eq 0 ]] || return 50
    done
    return 0
}

run_scikit_learn_benchmarks() {
    initialize_runtime || return $?
    check_architecture || return $?
    check_scikit_learn_container || return $?
    validate_reps || return $?
    sklearn_measurement_env
    scikit_learn_container_exec test -x "${VENV_PY}" || {
        log_message "ERROR: the private virtual environment is unavailable in the container: ${VENV_PY}"
        return 50
    }
    if ! verify_pinned_runtime >> "${RESULTS_DIR}/measurement.log" 2>&1; then
        log_message "ERROR: pinned runtime verification failed"
        tail -20 "${RESULTS_DIR}/measurement.log" || true
        return 50
    fi
    scikit_learn_container_exec_at "${ASV_DIR}" sha256sum --quiet -c manifest.sha256 || {
        log_message "ERROR: the staged asv benchmark suite was modified"
        return 50
    }

    : > "${RESULTS_DIR}/measurement.log"
    local scenario
    local started
    started="$(date +%s)"
    for scenario in "${SKLEARN_SCENARIOS[@]}"; do
        run_scenario_repetitions "${scenario}" || return 50
    done
    log_message "measurement finished in $(( $(date +%s) - started ))s (${#SKLEARN_SCENARIOS[@]} scenarios x ${SKLEARN_REPS} samples, inside the private container)"

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_REPS="${SKLEARN_REPS}"
    export SKLEARN_SCENARIOS_FILE="${SCENARIOS_FILE}"
    export SKLEARN_ASV_DIR="${ASV_DIR}"
    export SKLEARN_RUNTIME_VERSIONS="${RUNTIME_VERSIONS_JSON}"
    export SKLEARN_ASV_COMMIT="${ASV_TAG_COMMIT}"
    export SKLEARN_ASV_TAG="${ASV_TAG}"
    export SKLEARN_ASV_REPOSITORY="${ASV_REPOSITORY}"
    export SKLEARN_ASV_SUITE="${ASV_SUITE}"
    export SKLEARN_ASV_PROFILE="${ASV_PROFILE}"
    export SKLEARN_WARMUPS
    export SKLEARN_STATISTIC
    export SKLEARN_OFFLINE_MEASUREMENT
    export SKLEARN_SDIST_SHA256 PYTHON_VERSION PYTHON_SHA256
    if ! python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" >> "${RESULTS_DIR}/measurement.log" 2>&1; then
        log_message "ERROR: strict result parsing failed"
        tail -40 "${RESULTS_DIR}/measurement.log" || true
        return 50
    fi
    [[ -s "${RESULTS_DIR}/results.json" ]] || {
        log_message "ERROR: results.json is empty"
        return 50
    }
    log_message "results written to ${RESULTS_DIR}/results.json"
}
