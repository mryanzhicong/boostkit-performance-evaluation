#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_timed_command() {
    local scenario="$1" label="$2" workdir="$3"
    shift 3
    local directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    (
        cd "${workdir}" || exit 1
        python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
            --scenario "${scenario}" \
            --json "${directory}/${label}.json" \
            --log "${directory}/${label}.log" \
            --timeout 1800 \
            -- "$@"
    )
}

ant_build() {
    local project="$1"
    shift
    "${ANT_BIN}" -f "${project}/build.xml" "$@"
}

reset_project() {
    local project="$1"
    rm -rf -- "${project}/build"
}

touch_one_source() {
    local project="$1"
    local target="${project}/src/bench/Class0001.java"
    [[ -f "${target}" ]] || return 40
    touch "${target}"
}

verify_artifacts() {
    local scenario="$1" project="$2"
    shift 2
    local -a expected=("$@")
    local relative
    for relative in "${expected[@]}"; do
        [[ -e "${project}/${relative}" ]] || {
            log_message "ERROR: scenario ${scenario} did not produce ${relative}"
            return 50
        }
    done
}

measure_clean_build() {
    local scale="$1" target="$2" scenario="$3"
    local project="${PROJECTS_DIR}/project-${scale}"
    local -a artifacts=()
    case "${target}" in
        jar) artifacts=("build/bench.jar" "build/classes/bench/Class0001.class") ;;
        compile) artifacts=("build/classes/bench/Class0001.class") ;;
        *) log_message "ERROR: unsupported target ${target}"; return 40 ;;
    esac
    local i
    log_message "scenario ${scenario}: warmup"
    reset_project "${project}"
    run_timed_command "${scenario}" warmup "${project}" \
        "${ANT_BIN}" -f "${project}/build.xml" "${target}" || return $?
    verify_artifacts "${scenario}" "${project}" "${artifacts[@]}" || return $?
    for ((i = 1; i <= ANT_REPS; i++)); do
        log_message "scenario ${scenario}: rep ${i}/${ANT_REPS}"
        reset_project "${project}"
        run_timed_command "${scenario}" "rep${i}" "${project}" \
            "${ANT_BIN}" -f "${project}/build.xml" "${target}" || return $?
    done
    log_message "scenario ${scenario} completed (${ANT_REPS} repetitions)"
}

prepare_incremental_project() {
    local project="${PROJECTS_DIR}/project-100"
    reset_project "${project}"
    log_message "preparing the incremental project once (untimed full build)"
    if ! ant_build "${project}" jar >"${PERF_WORK_DIR}/incremental-prepare.log" 2>&1; then
        log_message "ERROR: failed to prepare the incremental project"
        tail -n 30 "${PERF_WORK_DIR}/incremental-prepare.log" | sed 's/^/  /'
        return 40
    fi
    [[ -f "${project}/build/bench.jar" ]] || {
        log_message "ERROR: incremental project preparation did not produce a jar"
        return 40
    }
}

measure_incremental() {
    local mode="$1" scenario="$2"
    local project="${PROJECTS_DIR}/project-100"
    prepare_incremental_project || return $?
    local i
    log_message "scenario ${scenario}: warmup"
    if [[ "${mode}" == "touch" ]]; then
        touch_one_source "${project}" || return $?
    fi
    run_timed_command "${scenario}" warmup "${project}" \
        "${ANT_BIN}" -f "${project}/build.xml" jar || return $?
    for ((i = 1; i <= ANT_REPS; i++)); do
        log_message "scenario ${scenario}: rep ${i}/${ANT_REPS}"
        if [[ "${mode}" == "touch" ]]; then
            touch_one_source "${project}" || return $?
        fi
        run_timed_command "${scenario}" "rep${i}" "${project}" \
            "${ANT_BIN}" -f "${project}/build.xml" jar || return $?
    done
    verify_artifacts "${scenario}" "${project}" "build/bench.jar" || return $?
    log_message "scenario ${scenario} completed (${ANT_REPS} repetitions)"
}

run_ant_benchmarks() {
    initialize_runtime || return $?
    export_java_env
    validate_reps || return $?
    [[ -x "${ANT_BIN}" ]] || {
        log_message "ERROR: Ant launcher is unavailable: ${ANT_BIN}"
        return 40
    }
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"
    scenario_metadata_payload "${RUNS_DIR}/scenario_meta.json" || return $?

    local scale
    for scale in "${ANT_JAR_SCALES[@]}"; do
        measure_clean_build "${scale}" jar "clean_jar_${scale}" || return $?
    done
    measure_clean_build 100 compile "clean_compile_100" || return $?
    measure_incremental noop "incremental_noop_100" || return $?
    measure_incremental touch "incremental_touch_100" || return $?

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_REPS
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" || return $?
    log_message "complete Ant build matrix finished (reps=${ANT_REPS})"
}
