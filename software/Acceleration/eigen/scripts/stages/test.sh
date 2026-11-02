#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

join_by_comma() {
    local first=1 item
    for item in "$@"; do
        if ((first)); then
            first=0
        else
            printf ','
        fi
        printf '%s' "${item}"
    done
    printf '\n'
}

# One measured process: the complete stdout/stderr is kept in
# <evidence_dir>/<label>.log and its wall time / exit code / peak RSS in
# <evidence_dir>/<label>.json.
run_timed() {
    local evidence_dir="$1" label="$2" workdir="$3"
    shift 3
    mkdir -p "${evidence_dir}"
    local rc=0
    (
        cd "${workdir}" || exit 1
        python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
            --json "${evidence_dir}/${label}.json" \
            --log "${evidence_dir}/${label}.log" \
            --timeout "${EIGEN_RUN_TIMEOUT}" \
            -- "$@"
    ) || rc=$?
    if ((rc != 0)); then
        # Surface the reason in the job log: a CI failure must be diagnosable
        # without downloading the result artifact.
        log_message "ERROR: ${evidence_dir} ${label} failed with exit code ${rc}"
        if [[ -f "${evidence_dir}/${label}.log" ]]; then
            log_message "---- tail of ${label}.log ----"
            while IFS= read -r line; do log_message "  ${line}"; done \
                < <(tail -n 40 -- "${evidence_dir}/${label}.log")
            log_message "---- end of ${label}.log ----"
        fi
    fi
    return "${rc}"
}

scenario_labels() {
    printf 'warmup\n'
    local index
    for index in $(seq 1 "${EIGEN_REPS}"); do
        printf 'rep%s\n' "${index}"
    done
}

# Upstream BTL sweep: the unmodified btl_eigen3_* executable is limited to one
# BTL action through the upstream BTL_CONFIG variable.  It produces the wall
# clock and peak RSS metrics of the scenario.
measure_sweep() {
    local group="$1" action="$2"
    local scenario="${group}_${action}"
    local binary filter label scratch
    binary="$(btl_binary_path "${group}" "${action}")"
    filter="$(action_filter "${action}")"
    if [[ ! -x "${binary}" ]]; then
        log_message "ERROR: measured BTL executable is missing: ${binary}"
        return 40
    fi
    local btl_config="-a ${filter} ${EIGEN_BTL_CONFIG}"
    log_message "scenario ${scenario}: upstream sweep ${binary} (BTL_CONFIG='${btl_config}')"
    while IFS= read -r label; do
        scratch="${SCRATCH_DIR}/${scenario}/${label}"
        rm -rf -- "${scratch}"
        mkdir -p "${scratch}"
        log_message "scenario ${scenario}: ${label} (upstream sweep)"
        run_timed "${RUNS_DIR}/${scenario}" "${label}" "${scratch}" \
            env BTL_CONFIG="${btl_config}" "${binary}" || return 50
    done < <(scenario_labels)
    return 0
}

# Fixed-dimension GFLOPS measurement through the upstream BTL action code.
measure_fixed_dimension() {
    local group="$1" action="$2" target="$3"
    local scenario="${group}_${action}"
    local binary filter label scratch
    binary="$(single_point_binary_path "${group}")"
    filter="$(action_filter "${action}")"
    if [[ ! -x "${binary}" ]]; then
        log_message "ERROR: fixed-dimension BTL driver is missing: ${binary}"
        return 40
    fi
    while IFS= read -r label; do
        scratch="${SCRATCH_DIR}/${scenario}/size${target}/${label}"
        rm -rf -- "${scratch}"
        mkdir -p "${scratch}"
        log_message "scenario ${scenario}: ${label} (${filter} at dimension ${target})"
        run_timed "${RUNS_DIR}/${scenario}/size${target}" "${label}" "${scratch}" \
            env BTL_CONFIG="-t 1" "${binary}" "${filter}" "${target}" || return 50
    done < <(scenario_labels)
    return 0
}

measure_scenario() {
    local group="$1" action="$2" target
    measure_sweep "${group}" "${action}" || return $?
    for target in "${EIGEN_SCALES[@]}"; do
        measure_fixed_dimension "${group}" "${action}" "${target}" || return $?
    done
    return 0
}

read_identity_file() {
    local path="$1" fallback="$2"
    if [[ -s "${path}" ]]; then
        head -n 1 "${path}"
    else
        printf '%s\n' "${fallback}"
    fi
}

run_eigen_benchmarks() {
    initialize_runtime || return $?
    validate_reps || return $?
    [[ -d "${SOURCE_DIR}" ]] || {
        log_message "ERROR: the pinned Eigen source tree is missing: ${SOURCE_DIR}"
        return 40
    }
    command -v python3 >/dev/null 2>&1 || {
        log_message "ERROR: python3 is required by the measurement wrapper"
        return 40
    }
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}" "${SCRATCH_DIR}" "${PERF_WORK_DIR}/logs"
    local group action
    for group in "${EIGEN_GROUPS[@]}"; do
        for action in "${EIGEN_ACTIONS[@]}"; do
            measure_scenario "${group}" "${action}" || return $?
        done
    done

    COMPILER_IDENTITY="$(read_identity_file "${PERF_WORK_DIR}/compiler.txt" "$(c++ --version 2>&1 | head -n 1)")"
    CMAKE_IDENTITY="$(read_identity_file "${PERF_WORK_DIR}/cmake.txt" "$(cmake --version 2>&1 | head -n 1)")"
    export EIGEN_COMPILER="${COMPILER_IDENTITY}"
    export EIGEN_CMAKE="${CMAKE_IDENTITY}"
    EIGEN_GROUPS_CSV="$(join_by_comma "${EIGEN_GROUPS[@]}")"
    EIGEN_ACTIONS_CSV="$(join_by_comma "${EIGEN_ACTIONS[@]}")"
    EIGEN_SCALES_CSV="$(join_by_comma "${EIGEN_SCALES[@]}")"
    export EIGEN_GROUPS_CSV EIGEN_ACTIONS_CSV EIGEN_SCALES_CSV
    export EIGEN_PROBE_DIR="${PROBE_DIR}"
    export EIGEN_ARCHIVE_SHA256 EIGEN_ARCHIVE_NAME EIGEN_ARCHIVE_URL
    export EIGEN_BTL_NB_POINT EIGEN_BTL_MIN_TIME
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT EIGEN_REPS EIGEN_JOBS
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" || {
        log_message "ERROR: the BTL result parser rejected the measured samples"
        return 50
    }
    log_message "complete BTL matrix finished: $((${#EIGEN_GROUPS[@]})) groups x $((${#EIGEN_ACTIONS[@]})) actions x (1 upstream sweep + ${#EIGEN_SCALES[@]} fixed dimensions) x ${EIGEN_REPS} repetitions"
}
