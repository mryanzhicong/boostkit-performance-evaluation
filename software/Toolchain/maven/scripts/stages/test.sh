#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

maven_argv() {
    MAVEN_ARGV=(
        "${MAVEN_BIN}" -B -o -ntp
        "${MAVEN_SETTINGS_ARGV[@]}"
        "-Dmaven.repo.local=${M2_REPO}"
        -Dstyle.color=never
    )
}

run_timed_command() {
    local scenario="$1" label="$2" workdir="$3"
    shift 3
    local directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    (
        cd "${workdir}" || exit 1
        python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
            --json "${directory}/${label}.json" \
            --log "${directory}/${label}.log" \
            --timeout 3600 \
            -- "$@"
    )
}

run_untimed_command() {
    local log_file="$1" workdir="$2"
    shift 2
    mkdir -p "$(dirname "${log_file}")"
    (
        cd "${workdir}" || exit 1
        "$@"
    ) >"${log_file}" 2>&1
}

touch_incremental_source() {
    local project="$1"
    touch "${project}/src/main/java/bench/Class00001.java"
}

measure_project_scale() {
    local scale="$1"
    local project="${PROJECTS_DIR}/project-${scale}"
    local clean_scenario="clean_package_${scale}"
    local incremental_scenario="incremental_package_${scale}"
    local noop_scenario="noop_package_${scale}"
    local i

    maven_argv
    [[ -d "${project}" ]] || {
        log_message "ERROR: generated project is missing: ${project}"
        return 40
    }

    log_message "scenario ${clean_scenario}: warmup"
    run_timed_command "${clean_scenario}" warmup "${project}" \
        "${MAVEN_ARGV[@]}" clean package || return $?
    for ((i = 1; i <= MAVEN_REPS; i++)); do
        log_message "scenario ${clean_scenario}: rep ${i}/${MAVEN_REPS}"
        run_timed_command "${clean_scenario}" "rep${i}" "${project}" \
            "${MAVEN_ARGV[@]}" clean package || return $?
    done

    log_message "scenario ${incremental_scenario}: preparing a fully built tree"
    run_untimed_command "${RUNS_DIR}/${incremental_scenario}/prepare.log" "${project}" \
        "${MAVEN_ARGV[@]}" clean package || return $?
    log_message "scenario ${incremental_scenario}: warmup"
    touch_incremental_source "${project}"
    run_timed_command "${incremental_scenario}" warmup "${project}" \
        "${MAVEN_ARGV[@]}" package || return $?
    for ((i = 1; i <= MAVEN_REPS; i++)); do
        log_message "scenario ${incremental_scenario}: rep ${i}/${MAVEN_REPS}"
        touch_incremental_source "${project}"
        run_timed_command "${incremental_scenario}" "rep${i}" "${project}" \
            "${MAVEN_ARGV[@]}" package || return $?
    done

    log_message "scenario ${noop_scenario}: preparing a fully built tree"
    run_untimed_command "${RUNS_DIR}/${noop_scenario}/prepare.log" "${project}" \
        "${MAVEN_ARGV[@]}" clean package || return $?
    log_message "scenario ${noop_scenario}: warmup"
    run_timed_command "${noop_scenario}" warmup "${project}" \
        "${MAVEN_ARGV[@]}" package || return $?
    for ((i = 1; i <= MAVEN_REPS; i++)); do
        log_message "scenario ${noop_scenario}: rep ${i}/${MAVEN_REPS}"
        run_timed_command "${noop_scenario}" "rep${i}" "${project}" \
            "${MAVEN_ARGV[@]}" package || return $?
    done
    log_message "matrix scale ${scale} completed"
}

measure_self_build() {
    local scenario="maven_self_build"
    local i
    maven_argv
    [[ -f "${MAVEN_SRC_DIR}/pom.xml" ]] || {
        log_message "ERROR: upstream Maven sources are missing"
        return 40
    }
    log_message "scenario ${scenario}: warmup"
    run_timed_command "${scenario}" warmup "${MAVEN_SRC_DIR}" \
        "${MAVEN_ARGV[@]}" -DskipTests -Drat.skip=true -Dmaven.javadoc.skip=true \
        -Dmaven.source.skip=true -Dcheckstyle.skip=true clean package || return $?
    for ((i = 1; i <= MAVEN_REPS; i++)); do
        log_message "scenario ${scenario}: rep ${i}/${MAVEN_REPS}"
        run_timed_command "${scenario}" "rep${i}" "${MAVEN_SRC_DIR}" \
            "${MAVEN_ARGV[@]}" -DskipTests -Drat.skip=true -Dmaven.javadoc.skip=true \
            -Dmaven.source.skip=true -Dcheckstyle.skip=true clean package || return $?
    done
    log_message "scenario ${scenario} completed"
}

run_maven_benchmarks() {
    initialize_runtime || return $?
    export_java_env
    validate_reps || return $?
    [[ -x "${MAVEN_BIN}" ]] || {
        log_message "ERROR: Maven launcher is unavailable: ${MAVEN_BIN}"
        return 40
    }
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"
    local scale
    for scale in "${MAVEN_SCALES[@]}"; do
        measure_project_scale "${scale}" || return $?
    done
    measure_self_build || return $?

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" || return $?
    log_message "complete Maven matrix finished (reps=${MAVEN_REPS})"
}
