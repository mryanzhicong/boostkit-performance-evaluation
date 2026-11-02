#!/usr/bin/env bash
#
# Test stage for the catj case: run every scenario once as a warm-up and
# CATJ_REPS times as isolated samples, then hand the raw evidence to the strict
# parser.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_one_sample() {
    local scenario="$1" label="$2" input_file="$3" mode="$4" json_path="$5" output_path="$6" error_path="$7"
    local -a command=("${NODE_BIN}" "${APP_DIR}/node_modules/catj/catj.js")
    local -a stdin_args=()
    if [[ "${mode}" == stdin ]]; then
        stdin_args=(--stdin-file "${INPUT_DIR}/${input_file}")
    else
        command+=("${INPUT_DIR}/${input_file}")
    fi
    local -a measure=(
        python3 "${SCRIPT_DIR}/scripts/results/run_measure.py"
        --label "${label}"
        --timeout "$(scenario_timeout "${scenario}")"
        --json-out "${json_path}"
        --stdout-out "${output_path}"
        --stderr-out "${error_path}"
        "${stdin_args[@]}"
        -- "${command[@]}"
    )
    if ! "${measure[@]}"; then
        return 50
    fi
    if ! python3 "${SCRIPT_DIR}/scripts/results/verify_output.py" \
        --scenarios "${SCENARIOS_FILE}" --scenario "${scenario}" --output "${output_path}"; then
        return 50
    fi
    return 0
}

run_catj_benchmarks() {
    initialize_runtime || return $?
    validate_reps || return $?
    check_architecture || return $?
    catj_measurement_env
    if [[ ! -x "${NODE_BIN}" ]] || [[ ! -f "${APP_DIR}/node_modules/catj/catj.js" ]]; then
        log_message "ERROR: the staged runtime is incomplete, rerun the build stage"
        return 40
    fi

    local scenario input_file mode iterations warmup_dir run_dir sample log_path
    local status=0
    rm -rf "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"
    log_path="${RESULTS_DIR}/measurement.log"
    : >"${log_path}"

    for scenario in "${CATJ_SCENARIOS[@]}"; do
        read -r input_file mode iterations < <(python3 "${SCRIPT_DIR}/scripts/results/scenario_info.py" \
            --scenarios "${SCENARIOS_FILE}" --scenario "${scenario}" --fields)
        run_dir="${RUNS_DIR}/${scenario}"
        mkdir -p "${run_dir}"
        warmup_dir="${PERF_WORK_DIR}/warmup/${scenario}"
        mkdir -p "${warmup_dir}"
        if [[ "${CATJ_WARMUPS}" -gt 0 ]]; then
            log_message "warmup: ${scenario}"
            if ! run_one_sample "${scenario}" "${scenario}#warmup" "${input_file}" "${mode}" \
                "${warmup_dir}/warmup.json" "${warmup_dir}/warmup.out" "${warmup_dir}/warmup.err"; then
                status=50
                break
            fi
            cp -f "${warmup_dir}/warmup.json" "${run_dir}/warmup.json"
            cp -f "${warmup_dir}/warmup.out" "${run_dir}/warmup.out"
            cp -f "${warmup_dir}/warmup.err" "${run_dir}/warmup.err"
        fi
        local rep
        for rep in $(seq 1 "${CATJ_REPS}"); do
            log_message "sample ${rep}/${CATJ_REPS}: ${scenario}"
            if ! run_one_sample "${scenario}" "${scenario}#${rep}" "${input_file}" "${mode}" \
                "${run_dir}/rep${rep}.json" "${run_dir}/rep${rep}.out" "${run_dir}/rep${rep}.err" \
                >>"${log_path}" 2>&1; then
                log_message "ERROR: sample ${rep} of ${scenario} failed"
                status=50
                break
            fi
        done
        [[ "${status}" -eq 0 ]] || break
    done

    if [[ "${status}" -ne 0 ]]; then
        log_message "ERROR: measurement failed, last ${scenario} log lines:"
        tail -n 40 "${log_path}" || true
        return 50
    fi
    log_message "measurement finished (${#CATJ_SCENARIOS[@]} scenarios x ${CATJ_REPS} samples)"
    export PERF_REPS="${CATJ_REPS}"
    if ! python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" >>"${log_path}" 2>&1; then
        log_message "ERROR: strict result parsing failed"
        tail -n 40 "${log_path}" || true
        return 50
    fi
    log_message "results written to ${RESULTS_DIR}/results.json"
}
