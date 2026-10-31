#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# One measured repetition: a single child process, complete stdout and stderr in
# runs/<scenario>/<label>.log, wall time and peak RSS in runs/<scenario>/<label>.json.
run_timed() {
    local scenario="$1" label="$2" workdir="$3"
    shift 3
    local directory="${REACT_RUNS_DIR}/${scenario}"
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

# An untimed helper step (build tree cleanup) whose output stays with the samples.
run_logged() {
    local scenario="$1" label="$2" workdir="$3"
    shift 3
    local directory="${REACT_RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    (
        cd "${workdir}" || exit 1
        "$@"
    ) >"${directory}/${label}.log" 2>&1
}

# The release build writes its artefacts into build/; remove them so every
# repetition starts from the same empty output directory.
clear_upstream_build_output() {
    local output="${REACT_SOURCE_DIR}/${REACT_UPSTREAM_BUILD_OUTPUT}"
    rm -rf -- "${output}"
}

verify_upstream_build_output() {
    local output="${REACT_SOURCE_DIR}/${REACT_UPSTREAM_BUILD_OUTPUT}"
    if [[ ! -d "${output}" ]]; then
        log_message "ERROR: upstream build produced no output directory: ${output}"
        return 50
    fi
    local artifacts
    artifacts="$(find "${output}" -type f | wc -l)"
    if (( artifacts == 0 )); then
        log_message "ERROR: upstream build produced no artefacts in ${output}"
        return 50
    fi
    return 0
}

measure_matrix_scenario() {
    local task="$1" scale="$2"
    local scenario="${task}_${scale}"
    local renders index
    renders="$(react_renders_for_scale "${scale}")" || {
        log_message "ERROR: unsupported tree size: ${scale}"
        return 50
    }
    log_message "scenario ${scenario}: warmup"
    run_timed "${scenario}" warmup "${REACT_APP_DIR}" \
        env NODE_ENV=production "${REACT_NODE_BIN}" "${REACT_APP_BENCH_SCRIPT}" \
        --task "${task}" --items "${scale}" --renders "${renders}" \
        --warmup "${REACT_WARMUP_RENDERS}" \
        --output "${REACT_RUNS_DIR}/${scenario}/warmup.bench.json" || return $?
    for index in $(seq 1 "${REACT_REPS}"); do
        log_message "scenario ${scenario}: rep ${index}/${REACT_REPS}"
        run_timed "${scenario}" "rep${index}" "${REACT_APP_DIR}" \
            env NODE_ENV=production "${REACT_NODE_BIN}" "${REACT_APP_BENCH_SCRIPT}" \
            --task "${task}" --items "${scale}" --renders "${renders}" \
            --warmup "${REACT_WARMUP_RENDERS}" \
            --output "${REACT_RUNS_DIR}/${scenario}/rep${index}.bench.json" || return $?
    done
}

measure_upstream_build() {
    local scenario="upstream_build" index
    local build_command=(
        env -u NODE_ENV "${REACT_NODE_BIN}" "${REACT_UPSTREAM_BUILD_SCRIPT}"
        "${REACT_UPSTREAM_BUILD_ENTRIES}"
        "--type=${REACT_UPSTREAM_BUILD_TYPES}"
        "--release-channel=${REACT_UPSTREAM_RELEASE_CHANNEL}"
    )
    log_message "scenario ${scenario}: warmup"
    clear_upstream_build_output
    run_logged "${scenario}" clean-warmup "${REACT_SOURCE_DIR}" true || return $?
    run_timed "${scenario}" warmup "${REACT_SOURCE_DIR}" "${build_command[@]}" || return $?
    verify_upstream_build_output || return $?
    for index in $(seq 1 "${REACT_REPS}"); do
        log_message "scenario ${scenario}: rep ${index}/${REACT_REPS}"
        clear_upstream_build_output
        run_logged "${scenario}" "clean-rep${index}" "${REACT_SOURCE_DIR}" true || return $?
        run_timed "${scenario}" "rep${index}" "${REACT_SOURCE_DIR}" "${build_command[@]}" || return $?
        verify_upstream_build_output || return $?
    done
    log_message "upstream React production bundle build measured"
}

run_react_benchmarks() {
    initialize_runtime || return $?
    validate_reps || return $?
    if [[ ! -x "${REACT_NODE_BIN}" ]]; then
        log_message "ERROR: pinned Node.js runtime is unavailable: ${REACT_NODE_BIN}"
        return 50
    fi
    if [[ ! -x "${REACT_APP_BENCH_SCRIPT}" && ! -f "${REACT_APP_BENCH_SCRIPT}" ]]; then
        log_message "ERROR: SSR harness is unavailable: ${REACT_APP_BENCH_SCRIPT}"
        return 50
    fi
    if [[ ! -f "${REACT_SOURCE_DIR}/${REACT_UPSTREAM_BUILD_SCRIPT}" ]]; then
        log_message "ERROR: upstream React build script is unavailable"
        return 50
    fi
    rm -rf -- "${REACT_RUNS_DIR}"
    mkdir -p "${REACT_RUNS_DIR}"
    local scale task
    for scale in "${REACT_SCALES[@]}"; do
        for task in "${REACT_TASKS[@]}"; do
            measure_matrix_scenario "${task}" "${scale}" || return $?
        done
    done
    measure_upstream_build || return $?

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    export REACT_REPS REACT_WARMUP_RENDERS
    export REACT_NODE_VERSION="$(node_version_string 2>/dev/null || true)"
    export REACT_NPM_VERSION="$("${REACT_NPM_CLI}" --version 2>/dev/null || true)"
    export REACT_YARN_VERSION="$(yarn_version_string 2>/dev/null || true)"
    export REACT_JAVA_VERSION="$(java_version_string 2>/dev/null || true)"
    export REACT_APP_VERSION="$(react_version_string 2>/dev/null || true)"
    export REACT_APP_REACT_DOM_VERSION="$(react_dom_version_string 2>/dev/null || true)"
    export REACT_APP_SCHEDULER_VERSION="$(react_scheduler_version_string 2>/dev/null || true)"
    export REACT_SOURCE_VERSION="$(react_source_version_string 2>/dev/null || true)"
    export REACT_NODE_ARCHIVE_SHA256 REACT_ARCHIVE_SHA256 REACT_DOM_ARCHIVE_SHA256
    export SCHEDULER_ARCHIVE_SHA256 REACT_SOURCE_SHA256
    export REACT_REGISTRY REACT_UPSTREAM_BUILD_SCRIPT REACT_UPSTREAM_BUILD_OUTPUT
    export REACT_UPSTREAM_BUILD_ENTRIES REACT_UPSTREAM_BUILD_TYPES REACT_UPSTREAM_RELEASE_CHANNEL
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${REACT_RUNS_DIR}" "${RESULTS_DIR}/results.json" || return $?
    log_message "complete React matrix finished (reps=${REACT_REPS}, warmup renders=${REACT_WARMUP_RENDERS})"
}
