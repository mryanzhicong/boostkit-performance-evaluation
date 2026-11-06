#!/usr/bin/env bash
# Test stage: every measured process is started inside this task's private
# container.  The timing wrapper (scripts/run_timed.py) runs in the container as
# well, so docker's management overhead never lands inside a measurement window;
# only the strict result parser stays on the host.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

print_log_tail() {
    local log_file="$1"
    if [[ -s "${log_file}" ]]; then
        log_message "last 40 lines of ${log_file}:"
        tail -40 "${log_file}" || true
    fi
}

verify_pinned_runtime() {
    local script="${PERF_WORK_DIR}/tmp/verify-pinned-runtime.py"
    mkdir -p "${PERF_WORK_DIR}/tmp"
    cat > "${script}" <<'PY'
import json
import sys
from importlib import metadata

expected = json.loads(open(sys.argv[1], encoding="utf-8").read())["runtime"]
packages = ["numpy", "pandas", "python-dateutil", "six"]
actual = {name: metadata.version(name) for name in packages}
if actual != expected:
    raise SystemExit(f"runtime mismatch: installed {actual}, built with {expected}")
print(f"[pandas] pinned runtime verified: {actual}")
PY
    pandas_container_exec "${VENV_PY}" "${script}" "${RUNTIME_VERSIONS_JSON}"
}
run_scenario_repetitions() {
    local scenario="$1" index log_file json_file timeout_seconds
    timeout_seconds="$(scenario_timeout "${scenario}")"
    mkdir -p "${RUNS_DIR}/${scenario}"
    rm -f "${RUNS_DIR}/${scenario}"/*.log "${RUNS_DIR}/${scenario}"/*.json

    if [[ "${PANDAS_WARMUPS}" -gt 0 ]]; then
        log_file="${RUNS_DIR}/${scenario}/warmup.log"
        json_file="${RUNS_DIR}/${scenario}/warmup.json"
        log_message "warmup: ${scenario}"
        if ! pandas_container_exec_at "${PERF_WORK_DIR}" \
            python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
            --label "${scenario}#warmup" \
            --log "${log_file}" \
            --json "${json_file}" \
            --timeout "${timeout_seconds}" \
            --working-directory "${PERF_WORK_DIR}" \
            -- env "${PANDAS_MEASUREMENT_ENV[@]}" \
                "${VENV_PY}" "${SCRIPT_DIR}/scripts/fixtures/pandas_runner.py" \
                --mode measure \
                --scenario "${scenario}" \
                --scenarios-file "${SCENARIOS_FILE}" \
                --benchmarks-dir "${ASV_DIR}" >> "${RESULTS_DIR}/measurement.log" 2>&1; then
            log_message "ERROR: warmup failed for scenario ${scenario}"
            print_log_tail "${log_file}"
            return 50
        fi
    fi

    for ((index = 1; index <= PANDAS_REPS; index++)); do
        log_file="${RUNS_DIR}/${scenario}/rep${index}.log"
        json_file="${RUNS_DIR}/${scenario}/rep${index}.json"
        log_message "sample ${index}/${PANDAS_REPS}: ${scenario}"
        if ! pandas_container_exec_at "${PERF_WORK_DIR}" \
            python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
            --label "${scenario}#${index}" \
            --log "${log_file}" \
            --json "${json_file}" \
            --timeout "${timeout_seconds}" \
            --working-directory "${PERF_WORK_DIR}" \
            -- env "${PANDAS_MEASUREMENT_ENV[@]}" \
                "${VENV_PY}" "${SCRIPT_DIR}/scripts/fixtures/pandas_runner.py" \
                --mode measure \
                --scenario "${scenario}" \
                --scenarios-file "${SCENARIOS_FILE}" \
                --benchmarks-dir "${ASV_DIR}" >> "${RESULTS_DIR}/measurement.log" 2>&1; then
            log_message "ERROR: sample ${index} failed for scenario ${scenario}"
            print_log_tail "${log_file}"
            return 50
        fi
        if ! grep -q '^\[pandas-bench\] ' "${log_file}"; then
            log_message "ERROR: sample ${index} of ${scenario} produced no benchmark evidence line"
            print_log_tail "${log_file}"
            return 50
        fi
    done
    return 0
}

run_pandas_benchmarks() {
    initialize_runtime || return $?
    check_architecture || return $?
    validate_reps || return $?
    check_pandas_container || return $?
    pandas_container_exec test -x "${VENV_PY}" || {
        log_message "ERROR: the private virtual environment is unavailable inside the container: ${VENV_PY}"
        return 50
    }
    if ! verify_pinned_runtime >> "${RESULTS_DIR}/measurement.log" 2>&1; then
        log_message "ERROR: pinned runtime verification failed"
        tail -20 "${RESULTS_DIR}/measurement.log" || true
        return 50
    fi
    pandas_container_exec_at "${ASV_DIR}" sha256sum --quiet -c manifest.sha256 || {
        log_message "ERROR: the staged asv benchmark suite was modified"
        return 50
    }

    : > "${RESULTS_DIR}/measurement.log"
    local scenario
    local started
    started="$(date +%s)"
    for scenario in "${PANDAS_SCENARIOS[@]}"; do
        run_scenario_repetitions "${scenario}" || return 50
    done
    log_message "measurement finished in $(( $(date +%s) - started ))s (${#PANDAS_SCENARIOS[@]} scenarios x ${PANDAS_REPS} samples)"

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_REPS="${PANDAS_REPS}"
    export PANDAS_SCENARIOS_FILE="${SCENARIOS_FILE}"
    export PANDAS_ASV_DIR="${ASV_DIR}"
    export PANDAS_RUNTIME_VERSIONS="${RUNTIME_VERSIONS_JSON}"
    export PANDAS_ASV_COMMIT="${ASV_TAG_COMMIT}"
    export PANDAS_ASV_TAG="${ASV_TAG}"
    export PANDAS_ASV_REPOSITORY="${ASV_REPOSITORY}"
    export PANDAS_ASV_SUITE="${ASV_SUITE}"
    export PANDAS_ASV_PROFILE="${ASV_PROFILE}"
    export PANDAS_WARMUPS
    export PANDAS_STATISTIC
    export PANDAS_OFFLINE_MEASUREMENT
    export PANDAS_SDIST_SHA256 PYTHON_VERSION PYTHON_SHA256
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
