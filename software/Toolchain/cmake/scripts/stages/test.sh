#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# One measured scenario repetition: a single child process, complete stdout and
# stderr kept in runs/<scenario>/<label>.log, wall time and peak RSS recorded in
# runs/<scenario>/<label>.json.
run_timed() {
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

# An untimed helper step (tree preparation or clean) whose output is kept next
# to the measured repetitions so the exact starting state can be audited.
run_logged() {
    local scenario="$1" label="$2" workdir="$3"
    shift 3
    local directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    (
        cd "${workdir}" || exit 1
        "$@"
    ) >"${directory}/${label}.log" 2>&1
}

mutate_generated_source() {
    local project="$1" marker="$2"
    printf 'int unit_00001(void) {\n    return (1 * 31 + 7 + %s) & 0xffff;\n}\n' \
        "${marker}" > "${project}/src/unit_00001.c"
}

mutate_upstream_source() {
    local source_file="$1" marker="$2"
    {
        cat -- "${CMAKE_INCREMENTAL_SOURCE_ORIG}"
        printf '\n// deterministic incremental-build marker %s\n' "${marker}"
    } > "${source_file}"
}

measure_generated_scale() {
    local scale="$1"
    local project="${PROJECTS_DIR}/project-${scale}"
    local build="${BENCH_DIR}/project-${scale}"
    local configure_scenario="configure_${scale}"
    local clean_scenario="clean_build_${scale}"
    local incremental_scenario="incremental_build_${scale}"
    local noop_scenario="noop_build_${scale}"
    local configure_dir index

    [[ -f "${project}/CMakeLists.txt" ]] || {
        log_message "ERROR: generated project is missing: ${project}"
        return 40
    }

    # configure: the first configuration of an empty build directory
    configure_dir="${BENCH_DIR}/configure-${scale}-warmup"
    rm -rf -- "${configure_dir}"
    log_message "scenario ${configure_scenario}: warmup"
    run_timed "${configure_scenario}" warmup "${PERF_WORK_DIR}" \
        "${CMAKE_BIN}" -S "${project}" -B "${configure_dir}" \
        "${PROJECT_CONFIGURE_ARGV[@]}" || return $?
    rm -rf -- "${configure_dir}"
    for index in $(seq 1 "${CMAKE_REPS}"); do
        configure_dir="${BENCH_DIR}/configure-${scale}-rep${index}"
        rm -rf -- "${configure_dir}"
        log_message "scenario ${configure_scenario}: rep ${index}/${CMAKE_REPS}"
        run_timed "${configure_scenario}" "rep${index}" "${PERF_WORK_DIR}" \
            "${CMAKE_BIN}" -S "${project}" -B "${configure_dir}" \
            "${PROJECT_CONFIGURE_ARGV[@]}" || return $?
        rm -rf -- "${configure_dir}"
    done

    # prepare a complete build tree used by the build scenarios (untimed)
    log_message "scenario ${clean_scenario}: preparing a fully built tree"
    rm -rf -- "${build}"
    run_logged "${clean_scenario}" prepare-configure "${PERF_WORK_DIR}" \
        "${CMAKE_BIN}" -S "${project}" -B "${build}" "${PROJECT_CONFIGURE_ARGV[@]}" || return $?
    run_logged "${clean_scenario}" prepare-build "${PERF_WORK_DIR}" \
        "${CMAKE_BIN}" --build "${build}" -j "${CMAKE_JOBS}" || return $?

    # clean build: every repetition compiles every source file again
    log_message "scenario ${clean_scenario}: warmup"
    run_logged "${clean_scenario}" clean-warmup "${PERF_WORK_DIR}" \
        "${CMAKE_BIN}" --build "${build}" --target clean || return $?
    run_timed "${clean_scenario}" warmup "${PERF_WORK_DIR}" \
        "${CMAKE_BIN}" --build "${build}" -j "${CMAKE_JOBS}" || return $?
    for index in $(seq 1 "${CMAKE_REPS}"); do
        log_message "scenario ${clean_scenario}: rep ${index}/${CMAKE_REPS}"
        run_logged "${clean_scenario}" "clean-rep${index}" "${PERF_WORK_DIR}" \
            "${CMAKE_BIN}" --build "${build}" --target clean || return $?
        run_timed "${clean_scenario}" "rep${index}" "${PERF_WORK_DIR}" \
            "${CMAKE_BIN}" --build "${build}" -j "${CMAKE_JOBS}" || return $?
    done

    # incremental build: exactly one source file changes before each run
    mutate_generated_source "${project}" 1001
    log_message "scenario ${incremental_scenario}: warmup"
    run_timed "${incremental_scenario}" warmup "${PERF_WORK_DIR}" \
        "${CMAKE_BIN}" --build "${build}" -j "${CMAKE_JOBS}" || return $?
    for index in $(seq 1 "${CMAKE_REPS}"); do
        mutate_generated_source "${project}" "$((2000 + index))"
        log_message "scenario ${incremental_scenario}: rep ${index}/${CMAKE_REPS}"
        run_timed "${incremental_scenario}" "rep${index}" "${PERF_WORK_DIR}" \
            "${CMAKE_BIN}" --build "${build}" -j "${CMAKE_JOBS}" || return $?
    done

    # no-op build: a complete tree with no changes at all
    log_message "scenario ${noop_scenario}: warmup"
    run_timed "${noop_scenario}" warmup "${PERF_WORK_DIR}" \
        "${CMAKE_BIN}" --build "${build}" -j "${CMAKE_JOBS}" || return $?
    for index in $(seq 1 "${CMAKE_REPS}"); do
        log_message "scenario ${noop_scenario}: rep ${index}/${CMAKE_REPS}"
        run_timed "${noop_scenario}" "rep${index}" "${PERF_WORK_DIR}" \
            "${CMAKE_BIN}" --build "${build}" -j "${CMAKE_JOBS}" || return $?
    done
    log_message "generated matrix scale ${scale} completed"
}

measure_upstream() {
    local source="${CMAKE_SOURCE_DIR}"
    local build="${BENCH_DIR}/upstream"
    local target="${CMAKE_UPSTREAM_BUILD_TARGET}"
    local incremental_source="${source}/${CMAKE_UPSTREAM_INCREMENTAL_SOURCE}"
    local configure_dir index

    # configure: a fresh configuration of the upstream source tree
    configure_dir="${BENCH_DIR}/upstream-configure-warmup"
    rm -rf -- "${configure_dir}"
    log_message "scenario upstream_configure: warmup"
    run_timed upstream_configure warmup "${PERF_WORK_DIR}" \
        "${CMAKE_BIN}" -S "${source}" -B "${configure_dir}" \
        "${UPSTREAM_CONFIGURE_ARGV[@]}" || return $?
    rm -rf -- "${configure_dir}"
    for index in $(seq 1 "${CMAKE_REPS}"); do
        configure_dir="${BENCH_DIR}/upstream-configure-rep${index}"
        rm -rf -- "${configure_dir}"
        log_message "scenario upstream_configure: rep ${index}/${CMAKE_REPS}"
        run_timed upstream_configure "rep${index}" "${PERF_WORK_DIR}" \
            "${CMAKE_BIN}" -S "${source}" -B "${configure_dir}" \
            "${UPSTREAM_CONFIGURE_ARGV[@]}" || return $?
        rm -rf -- "${configure_dir}"
    done

    [[ -f "${incremental_source}" ]] || {
        log_message "ERROR: upstream incremental source is missing: ${incremental_source}"
        return 40
    }

    # prepare one complete upstream build (untimed); the incremental and no-op
    # scenarios are measured against this warm tree
    log_message "scenario upstream_build: preparing a fully built upstream tree"
    rm -rf -- "${build}"
    run_logged upstream_build prepare-configure "${PERF_WORK_DIR}" \
        "${CMAKE_BIN}" -S "${source}" -B "${build}" "${UPSTREAM_CONFIGURE_ARGV[@]}" || return $?
    run_logged upstream_build prepare-build "${PERF_WORK_DIR}" \
        "${CMAKE_BIN}" --build "${build}" -j "${CMAKE_JOBS}" --target "${target}" || return $?

    # upstream clean build: compile the pinned upstream target from scratch
    log_message "scenario upstream_build: warmup"
    run_logged upstream_build clean-warmup "${PERF_WORK_DIR}" \
        "${CMAKE_BIN}" --build "${build}" --target clean || return $?
    run_timed upstream_build warmup "${PERF_WORK_DIR}" \
        "${CMAKE_BIN}" --build "${build}" -j "${CMAKE_JOBS}" --target "${target}" || return $?
    for index in $(seq 1 "${CMAKE_REPS}"); do
        log_message "scenario upstream_build: rep ${index}/${CMAKE_REPS}"
        run_logged upstream_build "clean-rep${index}" "${PERF_WORK_DIR}" \
            "${CMAKE_BIN}" --build "${build}" --target clean || return $?
        run_timed upstream_build "rep${index}" "${PERF_WORK_DIR}" \
            "${CMAKE_BIN}" --build "${build}" -j "${CMAKE_JOBS}" --target "${target}" || return $?
    done

    # upstream incremental build: one leaf translation unit is modified
    mutate_upstream_source "${incremental_source}" 1001
    log_message "scenario upstream_incremental_build: warmup"
    run_timed upstream_incremental_build warmup "${PERF_WORK_DIR}" \
        "${CMAKE_BIN}" --build "${build}" -j "${CMAKE_JOBS}" --target "${target}" || return $?
    for index in $(seq 1 "${CMAKE_REPS}"); do
        mutate_upstream_source "${incremental_source}" "$((2000 + index))"
        log_message "scenario upstream_incremental_build: rep ${index}/${CMAKE_REPS}"
        run_timed upstream_incremental_build "rep${index}" "${PERF_WORK_DIR}" \
            "${CMAKE_BIN}" --build "${build}" -j "${CMAKE_JOBS}" --target "${target}" || return $?
    done

    # upstream no-op build: the tree is complete and unchanged
    log_message "scenario upstream_noop_build: warmup"
    run_timed upstream_noop_build warmup "${PERF_WORK_DIR}" \
        "${CMAKE_BIN}" --build "${build}" -j "${CMAKE_JOBS}" --target "${target}" || return $?
    for index in $(seq 1 "${CMAKE_REPS}"); do
        log_message "scenario upstream_noop_build: rep ${index}/${CMAKE_REPS}"
        run_timed upstream_noop_build "rep${index}" "${PERF_WORK_DIR}" \
            "${CMAKE_BIN}" --build "${build}" -j "${CMAKE_JOBS}" --target "${target}" || return $?
    done
    log_message "upstream scenarios completed"
}

run_cmake_benchmarks() {
    initialize_runtime || return $?
    validate_reps || return $?
    validate_jobs || return $?
    [[ -x "${CMAKE_BIN}" ]] || {
        log_message "ERROR: CMake launcher is unavailable: ${CMAKE_BIN}"
        return 40
    }
    [[ -d "${CMAKE_SOURCE_DIR}" ]] || {
        log_message "ERROR: upstream CMake source tree is unavailable: ${CMAKE_SOURCE_DIR}"
        return 40
    }
    command -v cc >/dev/null 2>&1 || {
        log_message "ERROR: C compiler driver cc is unavailable"
        return 40
    }
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}" "${BENCH_DIR}"
    local scale
    for scale in "${CMAKE_SCALES[@]}"; do
        measure_generated_scale "${scale}" || return $?
    done
    measure_upstream || return $?

    CMAKE_COMPILER="$(compiler_identity)"
    CMAKE_VERSION_STRING="$(cmake_version_string 2>/dev/null)" || CMAKE_VERSION_STRING=""
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    export CMAKE_REPS CMAKE_JOBS CMAKE_COMPILER CMAKE_VERSION_STRING
    export CMAKE_ARCHIVE_SHA256 CMAKE_SOURCE_SHA256
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" || return $?
    log_message "complete CMake matrix finished (reps=${CMAKE_REPS}, jobs=${CMAKE_JOBS})"
}
