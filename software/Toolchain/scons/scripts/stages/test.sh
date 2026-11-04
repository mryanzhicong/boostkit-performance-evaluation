#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_timed_command() {
    local scenario="$1" label="$2" workdir="$3"
    shift 3
    local directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    scons_container_exec_at "${workdir}" \
        python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
        --scenario "${scenario}" \
        --json "${directory}/${label}.json" \
        --log "${directory}/${label}.log" \
        --timeout 1800 \
        -- "$@"
}

scons_invoke() {
    scons_container_exec_at "${PROJECT_DIR}" python3 "${SCONS_ENTRY}" "$@"
}

reset_project_state() {
    rm -rf -- "${PROJECT_DIR}/build"
    rm -f -- "${PROJECT_DIR}/.sconsign.dblite"
}

verify_library() {
    local scenario="$1"
    [[ -f "${PROJECT_DIR}/build/libbench.a" ]] || {
        log_message "ERROR: scenario ${scenario} did not produce build/libbench.a"
        return 50
    }
}

measure_upstream_bench() {
    local script="$1" scenario="$2"
    local i
    log_message "scenario ${scenario}: warmup"
    run_timed_command "${scenario}" warmup "${SCONS_HOME}" \
        python3 bench/bench.py "bench/${script}" || return $?
    for ((i = 1; i <= SCONS_REPS; i++)); do
        log_message "scenario ${scenario}: rep ${i}/${SCONS_REPS}"
        run_timed_command "${scenario}" "rep${i}" "${SCONS_HOME}" \
            python3 bench/bench.py "bench/${script}" || return $?
    done
    log_message "scenario ${scenario} completed (${SCONS_REPS} repetitions)"
}

measure_clean_build() {
    local scenario="scons_clean_100"
    local i
    log_message "scenario ${scenario}: warmup"
    reset_project_state
    run_timed_command "${scenario}" warmup "${PROJECT_DIR}" \
        python3 "${SCONS_ENTRY}" || return $?
    verify_library "${scenario}" || return $?
    for ((i = 1; i <= SCONS_REPS; i++)); do
        log_message "scenario ${scenario}: rep ${i}/${SCONS_REPS}"
        reset_project_state
        run_timed_command "${scenario}" "rep${i}" "${PROJECT_DIR}" \
            python3 "${SCONS_ENTRY}" || return $?
    done
    log_message "scenario ${scenario} completed (${SCONS_REPS} repetitions)"
}

prepare_built_project() {
    reset_project_state
    log_message "preparing the project once (untimed full SCons build)"
    if ! scons_container_exec_at "${PROJECT_DIR}" python3 "${SCONS_ENTRY}" \
        >"${PERF_WORK_DIR}/scons-prepare.log" 2>&1; then
        log_message "ERROR: failed to prepare the SCons project"
        tail -n 30 "${PERF_WORK_DIR}/scons-prepare.log" | sed 's/^/  /'
        return 40
    fi
    verify_library "prepare" || return $?
}

measure_noop_build() {
    local scenario="scons_noop_100"
    prepare_built_project || return $?
    local i
    log_message "scenario ${scenario}: warmup"
    run_timed_command "${scenario}" warmup "${PROJECT_DIR}" \
        python3 "${SCONS_ENTRY}" || return $?
    for ((i = 1; i <= SCONS_REPS; i++)); do
        log_message "scenario ${scenario}: rep ${i}/${SCONS_REPS}"
        run_timed_command "${scenario}" "rep${i}" "${PROJECT_DIR}" \
            python3 "${SCONS_ENTRY}" || return $?
    done
    verify_library "${scenario}" || return $?
    log_message "scenario ${scenario} completed (${SCONS_REPS} repetitions)"
}

touch_one_source() {
    local target="${PROJECT_DIR}/src/bench_0042.c"
    [[ -f "${target}" ]] || return 40
    touch "${target}"
}

measure_incremental_build() {
    local scenario="scons_incremental_one_100"
    prepare_built_project || return $?
    local i
    log_message "scenario ${scenario}: warmup"
    touch_one_source || return $?
    run_timed_command "${scenario}" warmup "${PROJECT_DIR}" \
        python3 "${SCONS_ENTRY}" || return $?
    for ((i = 1; i <= SCONS_REPS; i++)); do
        log_message "scenario ${scenario}: rep ${i}/${SCONS_REPS}"
        touch_one_source || return $?
        run_timed_command "${scenario}" "rep${i}" "${PROJECT_DIR}" \
            python3 "${SCONS_ENTRY}" || return $?
    done
    verify_library "${scenario}" || return $?
    log_message "scenario ${scenario} completed (${SCONS_REPS} repetitions)"
}

run_scons_benchmarks() {
    initialize_runtime || return $?
    validate_reps || return $?
    check_scons_container || return 50
    [[ -f "${SCONS_ENTRY}" ]] || {
        log_message "ERROR: SCons launcher is unavailable: ${SCONS_ENTRY}"
        return 40
    }
    scons_container_exec sh -c 'command -v cc >/dev/null 2>&1' || {
        log_message "ERROR: no C compiler (cc) is available in the container"
        return 40
    }
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"
    scenario_metadata_payload "${RUNS_DIR}/scenario_meta.json" || return $?

    measure_upstream_bench is_types.py upstream_bench_is_types || return $?
    measure_upstream_bench lvars-gvars.py upstream_bench_lvars_gvars || return $?
    measure_upstream_bench dependency-func.py upstream_bench_dependency_func || return $?
    measure_clean_build || return $?
    measure_noop_build || return $?
    measure_incremental_build || return $?

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_REPS
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" || return $?
    log_message "complete SCons bench + build matrix finished (reps=${SCONS_REPS})"
}
