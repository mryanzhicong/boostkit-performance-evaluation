#!/usr/bin/env bash
# Test stage: every measured scalac/java invocation, including the timing wrapper,
# runs inside this task's private container, so each sample is produced by a
# container-native child process and docker's management overhead never lands in a
# measurement window.  The strict parser stays on the host.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_timed_command() {
    local scenario="$1" label="$2" workdir="$3"
    shift 3
    local directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    scala_container_env_exec_at "${workdir}" \
        python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
        --scenario "${scenario}" \
        --json "${directory}/${label}.json" \
        --log "${directory}/${label}.log" \
        --timeout 1800 \
        -- "$@"
}

compile_sources() {
    local project="$1" output="$2"
    local -a sources=("${project}/src/bench/"*.scala)
    [[ -f "${sources[0]}" ]] || {
        log_message "ERROR: generated sources are missing under ${project}"
        return 40
    }
    scala_container_env_exec "${SCALAC_BIN}" -classpath "${SCALA_CLASSPATH}" \
        -d "${output}" "${sources[@]}"
}

measure_compile_scale() {
    local scale="$1"
    local scenario="compile_${scale}"
    local project="${PROJECTS_DIR}/project-${scale}"
    local output="${PERF_WORK_DIR}/compile-out/${scale}"
    local i

    scala_container_exec test -d "${project}/src/bench" || {
        log_message "ERROR: generated project is missing: ${project}"
        return 40
    }
    log_message "scenario ${scenario}: warmup"
    scala_container_exec rm -rf -- "${output}" || return 40
    scala_container_exec mkdir -p "${output}" || return 40
    run_timed_command "${scenario}" warmup "${PERF_WORK_DIR}" \
        "${SCALAC_BIN}" -classpath "${SCALA_CLASSPATH}" -d "${output}" \
        "${project}/src/bench/"*.scala || return $?
    for ((i = 1; i <= SCALA_REPS; i++)); do
        log_message "scenario ${scenario}: rep ${i}/${SCALA_REPS}"
        scala_container_exec rm -rf -- "${output}" || return 40
        scala_container_exec mkdir -p "${output}" || return 40
        run_timed_command "${scenario}" "rep${i}" "${PERF_WORK_DIR}" \
            "${SCALAC_BIN}" -classpath "${SCALA_CLASSPATH}" -d "${output}" \
            "${project}/src/bench/"*.scala || return $?
    done
    log_message "scenario ${scenario} completed"
}

measure_run_workload() {
    local workload="$1"
    local scenario="run_${workload}"
    local classes="${SCALA_PROGRAMS_OUT}/${workload}"
    local rounds
    case "${workload}" in
        arith) rounds=40000000 ;;
        collections) rounds=400000 ;;
        strings) rounds=20 ;;
        *) rounds=1000 ;;
    esac
    local i
    log_message "scenario ${scenario}: warmup"
    run_timed_command "${scenario}" warmup "${PERF_WORK_DIR}" \
        "${JDK_HOME}/bin/java" -cp "${SCALA_CLASSPATH}:${classes}" bench.Main "${rounds}" || return $?
    for ((i = 1; i <= SCALA_REPS; i++)); do
        log_message "scenario ${scenario}: rep ${i}/${SCALA_REPS}"
        run_timed_command "${scenario}" "rep${i}" "${PERF_WORK_DIR}" \
            "${JDK_HOME}/bin/java" -cp "${SCALA_CLASSPATH}:${classes}" bench.Main "${rounds}" || return $?
    done
    log_message "scenario ${scenario} completed"
}

measure_pipeline() {
    local scenario="pipeline_compile_and_run"
    local project="${PROJECTS_DIR}/project-100"
    local output="${PERF_WORK_DIR}/pipeline-out"
    local pipeline_script="${PERF_WORK_DIR}/pipeline_compile_and_run.sh"
    local i
    cat >"${pipeline_script}" <<EOF
#!/usr/bin/env bash
set -euo pipefail
rm -rf "${output}"
mkdir -p "${output}"
"${SCALAC_BIN}" -classpath "${SCALA_CLASSPATH}" -d "${output}" "${project}/src/bench/"*.scala
"${JDK_HOME}/bin/java" -cp "${SCALA_CLASSPATH}:${output}" bench.Main 50
EOF
    chmod +x "${pipeline_script}"
    log_message "scenario ${scenario}: warmup"
    run_timed_command "${scenario}" warmup "${PERF_WORK_DIR}" bash "${pipeline_script}" || return $?
    for ((i = 1; i <= SCALA_REPS; i++)); do
        log_message "scenario ${scenario}: rep ${i}/${SCALA_REPS}"
        run_timed_command "${scenario}" "rep${i}" "${PERF_WORK_DIR}" bash "${pipeline_script}" || return $?
    done
    log_message "scenario ${scenario} completed"
}

run_scala_benchmarks() {
    initialize_runtime || return $?
    check_scala_container || return $?
    load_container_jdk
    export_java_env
    resolve_scala_classpath || return $?
    validate_reps || return $?
    scala_container_exec test -x "${SCALAC_BIN}" || {
        log_message "ERROR: Scala compiler is unavailable: ${SCALAC_BIN}"
        return 40
    }
    scala_container_exec test -x "${JDK_HOME}/bin/java" || {
        log_message "ERROR: container JDK java is unavailable: ${JDK_HOME}/bin/java"
        return 40
    }
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"
    scenario_metadata_payload "${RUNS_DIR}/scenario_meta.json" || return $?
    local scale workload
    for scale in "${SCALA_COMPILE_SCALES[@]}"; do
        measure_compile_scale "${scale}" || return $?
    done
    for workload in "${SCALA_RUN_WORKLOADS[@]}"; do
        measure_run_workload "${workload}" || return $?
    done
    measure_pipeline || return $?

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_REPS
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" || return $?
    log_message "complete Scala compile_and_run matrix finished (reps=${SCALA_REPS})"
}
