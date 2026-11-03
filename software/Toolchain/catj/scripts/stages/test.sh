#!/usr/bin/env bash
#
# Test stage for the catj case: run every scenario once as a warm-up and
# CATJ_REPS times as isolated samples inside the task's private container, then
# hand the raw evidence to the strict parser on the host.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Environment the measured Node.js process sees; it is passed explicitly to the
# container because only the case-level variables are exported to `docker exec`.
catj_measurement_env_names() {
    printf '%s\n' \
        NODE_ENV=production \
        FORCE_COLOR=0 \
        NO_COLOR=1 \
        TZ=UTC \
        LANG=C \
        LC_ALL=C \
        OMP_NUM_THREADS=1 \
        UV_THREADPOOL_SIZE=1 \
        DEBUGINFOD_URLS= \
        http_proxy=http://127.0.0.1:9 \
        https_proxy=http://127.0.0.1:9 \
        HTTP_PROXY=http://127.0.0.1:9 \
        HTTPS_PROXY=http://127.0.0.1:9 \
        no_proxy= \
        NO_PROXY=
}

run_one_sample() {
    local scenario="$1" label="$2" input_file="$3" mode="$4" json_path="$5" output_path="$6" error_path="$7"
    local -a command=("${NODE_BIN}" "${APP_DIR}/node_modules/catj/catj.js")
    local -a stdin_args=()
    if [[ "${mode}" == stdin ]]; then
        stdin_args=(--stdin-file "${INPUT_DIR}/${input_file}")
    else
        command+=("${INPUT_DIR}/${input_file}")
    fi
    catj_measurement_env
    # The sample evidence is captured on the native filesystem of the work
    # directory and only published into the result tree after the timed window:
    # the container writes the captured stdout itself, and a bind-mounted
    # result directory can be dramatically slower than a native write, which
    # would otherwise turn the harness capture into the measurement bottleneck.
    local stage_dir="${PERF_WORK_DIR}/staging/${label//#/_}"
    rm -rf -- "${stage_dir}"
    mkdir -p "${stage_dir}"
    local stage_json="${stage_dir}/measure.json"
    local stage_stdout="${stage_dir}/stdout.txt"
    local stage_stderr="${stage_dir}/stderr.txt"
    local -a measure=(
        catj_container_exec_at "${PERF_WORK_DIR}" env
        "HOME=${PERF_WORK_DIR}/home" "TMPDIR=${TMPDIR}"
        $(catj_measurement_env_names)
        python3 "${SCRIPT_DIR}/scripts/results/run_measure.py"
        --label "${label}"
        --timeout "$(scenario_timeout "${scenario}")"
        --json-out "${stage_json}"
        --stdout-out "${stage_stdout}"
        --stderr-out "${stage_stderr}"
        "${stdin_args[@]}"
        -- "${command[@]}"
    )
    if ! "${measure[@]}"; then
        return 50
    fi
    if ! python3 "${SCRIPT_DIR}/scripts/results/verify_output.py" \
        --scenarios "${SCENARIOS_FILE}" --scenario "${scenario}" --output "${stage_stdout}"; then
        return 50
    fi
    mkdir -p -- "$(dirname "${json_path}")" "$(dirname "${output_path}")" "$(dirname "${error_path}")"
    cp -f -- "${stage_json}" "${json_path}" &&
        cp -f -- "${stage_stdout}" "${output_path}" &&
        cp -f -- "${stage_stderr}" "${error_path}" || return 50
    rm -rf -- "${stage_dir}"
    return 0
}

run_catj_benchmarks() {
    initialize_runtime || return $?
    validate_reps || return $?
    check_architecture || return $?

    check_catj_container || return $?

    catj_measurement_env
    if ! catj_container_exec test -f "${APP_DIR}/node_modules/catj/catj.js"; then
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
