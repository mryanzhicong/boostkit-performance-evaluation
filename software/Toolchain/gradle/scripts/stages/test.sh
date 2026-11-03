#!/usr/bin/env bash
# Test stage: every measured Gradle invocation, including the timing wrapper and
# the upstream sample batch, runs inside this task's private container, so each
# sample is produced by a container-native child process and docker's management
# overhead never lands in a measurement window.  The strict parser stays on the
# host.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_timed_command() {
    local scenario="$1" label="$2" workdir="$3"
    shift 3
    local directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    gradle_container_env_exec_at "${workdir}" \
        python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
        --json "${directory}/${label}.json" \
        --log "${directory}/${label}.log" \
        --timeout 3600 \
        -- "$@"
}

run_untimed_command() {
    local log_file="$1" workdir="$2"
    shift 2
    mkdir -p "$(dirname "${log_file}")"
    gradle_container_env_exec_at "${workdir}" "$@" >"${log_file}" 2>&1
}

# The upstream batch runner needs the online-warmed dependency cache and the
# pinned sample list, so those are injected into the container explicitly before
# the timing wrapper starts the batch.
run_timed_upstream_batch() {
    local scenario="$1" label="$2" workdir="$3"
    local directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    gradle_refresh_env_args
    gradle_container_exec_at "${workdir}" env "${GRADLE_ENV_ARGS[@]}" \
        "UPSTREAM_WORK_DIR=${workdir}" \
        "GRADLE_BATCH_OFFLINE=1" \
        "GRADLE_FLAGS=${GRADLE_FLAGS:-}" \
        "GRADLE_UPSTREAM_SAMPLE_LIST=${GRADLE_UPSTREAM_SAMPLE_LIST}" \
        python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
        --json "${directory}/${label}.json" \
        --log "${directory}/${label}.log" \
        --timeout 3600 \
        -- bash "${SCRIPT_DIR}/scripts/run_upstream_batch.sh"
}

verify_build_artifacts() {
    local project="$1" scenario="$2" label="$3"
    local jar
    jar="$( find "${project}/build/libs" -maxdepth 1 -type f -name '*.jar' -print -quit 2>/dev/null )"
    if [[ -z "${jar}" ]]; then
        log_message "ERROR: ${scenario} ${label}: the build produced no jar in ${project}/build/libs"
        return 50
    fi
    if [[ ! -s "${jar}" ]]; then
        log_message "ERROR: ${scenario} ${label}: the produced jar is empty: ${jar}"
        return 50
    fi
}

gradle_invoke() {
    local workdir="$1"
    shift
    gradle_container_env_exec_at "${workdir}" "${GRADLE_BIN}" "${GRADLE_FLAG_ARRAY[@]}" "$@"
}

touch_incremental_source() {
    local project="$1" revision="$2"
    gradle_container_env_exec python3 "${SCRIPT_DIR}/scripts/generate_project.py" \
        --output "${project}" \
        --classes "$(cat "${project}/.generated-classes")" \
        --incremental-revision "${revision}"
}

prepare_built_tree() {
    local project="$1" log_file="$2"
    run_untimed_command "${log_file}" "${project}" \
        "${GRADLE_BIN}" "${GRADLE_FLAG_ARRAY[@]}" --offline clean build || return 50
}

measure_clean_scale() {
    local scale="$1"
    local project="${PROJECTS_DIR}/project-${scale}"
    local scenario="clean_build_${scale}"
    local index
    log_message "scenario ${scenario}: warmup"
    if ! run_timed_command "${scenario}" warmup "${project}" \
        "${GRADLE_BIN}" "${GRADLE_FLAG_ARRAY[@]}" --offline clean build; then return 50; fi
    if ! verify_build_artifacts "${project}" "${scenario}" warmup; then return 50; fi
    for index in $(seq 1 "${GRADLE_REPS}"); do
        log_message "scenario ${scenario}: rep ${index}/${GRADLE_REPS}"
        if ! run_timed_command "${scenario}" "rep${index}" "${project}" \
            "${GRADLE_BIN}" "${GRADLE_FLAG_ARRAY[@]}" --offline clean build; then return 50; fi
        if ! verify_build_artifacts "${project}" "${scenario}" "rep${index}"; then return 50; fi
    done
}

measure_incremental_scale() {
    local scale="$1"
    local project="${PROJECTS_DIR}/project-${scale}"
    local scenario="incremental_build_${scale}"
    local revision=0 index
    log_message "scenario ${scenario}: preparing a fully built tree"
    if ! prepare_built_tree "${project}" "${RUNS_DIR}/${scenario}/prepare.log"; then return 50; fi
    revision=1
    if ! touch_incremental_source "${project}" "${revision}"; then
        log_message "ERROR: failed to rewrite the incremental source for ${scenario}"
        return 50
    fi
    log_message "scenario ${scenario}: warmup"
    if ! run_timed_command "${scenario}" warmup "${project}" \
        "${GRADLE_BIN}" "${GRADLE_FLAG_ARRAY[@]}" --offline build; then return 50; fi
    for index in $(seq 1 "${GRADLE_REPS}"); do
        revision=$((revision + 1))
        log_message "scenario ${scenario}: rep ${index}/${GRADLE_REPS}"
        if ! touch_incremental_source "${project}" "${revision}"; then
            log_message "ERROR: failed to rewrite the incremental source for ${scenario}"
            return 50
        fi
        if ! run_timed_command "${scenario}" "rep${index}" "${project}" \
            "${GRADLE_BIN}" "${GRADLE_FLAG_ARRAY[@]}" --offline build; then return 50; fi
        if ! verify_build_artifacts "${project}" "${scenario}" "rep${index}"; then return 50; fi
    done
}

measure_noop_scale() {
    local scale="$1"
    local project="${PROJECTS_DIR}/project-${scale}"
    local scenario="noop_build_${scale}"
    local index
    log_message "scenario ${scenario}: preparing a fully built tree"
    if ! prepare_built_tree "${project}" "${RUNS_DIR}/${scenario}/prepare.log"; then return 50; fi
    if ! gradle_invoke "${project}" --offline build \
        >"${RUNS_DIR}/${scenario}/prepare-noop.log" 2>&1; then
        log_message "ERROR: failed to prepare the up-to-date tree for ${scenario}"
        return 50
    fi
    log_message "scenario ${scenario}: warmup"
    if ! run_timed_command "${scenario}" warmup "${project}" \
        "${GRADLE_BIN}" "${GRADLE_FLAG_ARRAY[@]}" --offline build; then return 50; fi
    for index in $(seq 1 "${GRADLE_REPS}"); do
        log_message "scenario ${scenario}: rep ${index}/${GRADLE_REPS}"
        if ! run_timed_command "${scenario}" "rep${index}" "${project}" \
            "${GRADLE_BIN}" "${GRADLE_FLAG_ARRAY[@]}" --offline build; then return 50; fi
        if ! verify_build_artifacts "${project}" "${scenario}" "rep${index}"; then return 50; fi
    done
}

measure_upstream() {
    local scenario="${GRADLE_UPSTREAM_SCENARIO}"
    local upstream_dir="${PERF_WORK_DIR}/upstream-samples"
    local index
    log_message "scenario ${scenario}: warmup"
    if ! run_timed_upstream_batch "${scenario}" warmup "${upstream_dir}"; then return 50; fi
    for index in $(seq 1 "${GRADLE_REPS}"); do
        log_message "scenario ${scenario}: rep ${index}/${GRADLE_REPS}"
        if ! run_timed_upstream_batch "${scenario}" "rep${index}" "${upstream_dir}"; then return 50; fi
    done
}

run_gradle_benchmarks() {
    initialize_runtime || return 50
    check_gradle_container || return $?
    load_container_jdk
    validate_reps || return 50
    gradle_container_exec test -x "${GRADLE_BIN}" || {
        log_message "ERROR: Gradle launcher is unavailable: ${GRADLE_BIN}"
        return 50
    }
    # shellcheck disable=SC2206
    GRADLE_FLAG_ARRAY=($(gradle_flags))
    export GRADLE_FLAGS="${GRADLE_FLAG_ARRAY[*]}"
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"

    local scale
    for scale in "${GRADLE_SCALES[@]}"; do
        log_message "matrix scale ${scale}: ${GRADLE_MATRIX_TASKS[*]}"
        measure_clean_scale "${scale}" || return 50
        measure_incremental_scale "${scale}" || return 50
        measure_noop_scale "${scale}" || return 50
        log_message "matrix scale ${scale} completed"
    done
    measure_upstream || return 50

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    export GRADLE_REPS GRADLE_ZIP_SHA256 GRADLE_SRC_SHA256
    export GRADLE_JDK_RELEASE="openEuler 24.03 LTS SP4 java-21-openjdk"
    export GRADLE_JAVA_VERSION="$(java_version_string || true)"
    export GRADLE_SOURCE_REVISION="$(gradle_source_revision_string || true)"
    if ! python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json"; then
        log_message "ERROR: result parsing failed; the test stage does not accept incomplete or inconsistent measurements"
        return 50
    fi
    log_message "complete Gradle matrix finished (reps=${GRADLE_REPS})"
}
