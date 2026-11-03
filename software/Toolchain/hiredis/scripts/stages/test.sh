#!/usr/bin/env bash
# Test stage: one warm-up plus PERF_REPS independent repetitions of every
# hiredis scenario, offline, with per-repetition wall time, peak RSS and a
# compact correctness report.  The normalized result file is produced by the
# strict parser in scripts/results/parse_benchmark.py.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

read_network_mode() {
    if [[ -s "${HIREDIS_OFFLINE_DIR_MODE_FILE}" ]]; then
        cat "${HIREDIS_OFFLINE_DIR_MODE_FILE}"
    else
        printf 'unknown\n'
    fi
}

run_scenario_once() {
    local scenario="$1"
    local label="$2"
    local run_dir="${HIREDIS_RUNS_DIR}/${scenario}"
    local json_path="${run_dir}/${label}.json"
    local log_path="${run_dir}/${label}.log"
    local check_path="${run_dir}/${label}.check"
    local network_mode
    network_mode="$(read_network_mode)"

    scenario_argv "${scenario}" || return 50
    mkdir -p "${run_dir}"
    rm -f -- "${check_path}"

    local -a timing_args=(--json "${json_path}" --log "${log_path}")
    if [[ "${network_mode}" == "unshare" ]]; then
        timing_args+=(--offline --offline-prep "${HIREDIS_NETNS_PREP}")
    fi

    log_message "scenario ${scenario} ${label} starting (network mode ${network_mode})"
    # The timing wrapper runs inside the private container, so every sample is a
    # container-native child process and docker's management overhead never lands
    # inside a measurement window.
    hiredis_container_exec_at "${PERF_WORK_DIR}" \
        python3 "${SCRIPTS_DIR}/run_timed.py" "${timing_args[@]}" -- "${SCENARIO_CMD[@]}" || {
        local rc=$?
        fail_message "scenario ${scenario} ${label} failed with exit code ${rc}"
        if [[ -f "${log_path}" ]]; then
            tail -40 "${log_path}" || true
        fi
        return 50
    }
    if [[ -f "${json_path}" ]] && grep -q '"exit_code": 0' "${json_path}"; then
        :
    else
        fail_message "scenario ${scenario} ${label} did not report a zero exit code"
        [[ -f "${log_path}" ]] && tail -40 "${log_path}"
        return 50
    fi

    python3 "${SCRIPTS_DIR}/verify_outputs.py" \
        "${scenario}" "${log_path}" "${check_path}" "${label}" || {
        fail_message "scenario ${scenario} ${label} failed its output verification"
        cat "${check_path}" 2>/dev/null || true
        return 50
    }
    return 0
}

aggregate_raw_output() {
    local network_mode="$1"
    {
        printf '# hiredis %s parser/formatting measurement output\n' "${SOFTWARE_VERSION}"
        printf '# architecture: %s\n' "${EXPECTED_ARCH}"
        printf '# repetitions: %s (plus %s warm-up per scenario)\n' "${HIREDIS_REPS}" "${HIREDIS_WARMUPS}"
        printf '# network mode during measurement: %s\n' "${network_mode}"
        for scenario in "${HIREDIS_SCENARIOS[@]}"; do
            for log_file in "${HIREDIS_RUNS_DIR}/${scenario}"/*.log; do
                [[ -f "${log_file}" ]] || continue
                printf '\n===== %s =====\n' "${log_file#"${HIREDIS_RUNS_DIR}"/}"
                cat -- "${log_file}"
            done
            for check_file in "${HIREDIS_RUNS_DIR}/${scenario}"/*.check; do
                [[ -f "${check_file}" ]] || continue
                printf '\n===== %s =====\n' "${check_file#"${HIREDIS_RUNS_DIR}"/}"
                cat -- "${check_file}"
            done
        done
    } > "${RESULTS_DIR}/raw-output.log" || {
        fail_message "failed to write ${RESULTS_DIR}/raw-output.log"
        return 50
    }
    [[ -s "${RESULTS_DIR}/raw-output.log" ]] || {
        fail_message "raw output log is empty"
        return 50
    }
    return 0
}

run_hiredis_benchmarks() {
    validate_variant || return $?
    validate_reps || return $?
    configure_runtime_paths || return $?
    initialize_runtime || return $?

    check_hiredis_container || return $?

    if ! hiredis_container_exec test -x "${HIREDIS_BENCH_BIN}" || \
        ! hiredis_container_exec test -x "${HIREDIS_UPSTREAM_BIN}"; then
        fail_message "the benchmark harnesses are missing; run the build and start stages first"
        return 50
    fi
    if [[ ! -s "${HIREDIS_FIXTURE_MANIFEST}" ]]; then
        fail_message "the fixture manifest is missing; run the start stage first"
        return 50
    fi
    local network_mode
    network_mode="$(read_network_mode)"
    if [[ "${network_mode}" == "unknown" ]]; then
        fail_message "the measurement network mode is unknown; run the start stage first"
        return 50
    fi
    if [[ "${network_mode}" != "unshare" ]]; then
        log_message "WARNING: measuring with network mode '${network_mode}' (namespace isolation unavailable on this runner)"
    fi

    local scenario
    for scenario in "${HIREDIS_SCENARIOS[@]}"; do
        run_scenario_once "${scenario}" warmup || return 50
        log_message "scenario ${scenario} warmup ok"
    done

    local repetition
    for ((repetition = 1; repetition <= HIREDIS_REPS; repetition++)); do
        log_message "measurement repetition ${repetition}/${HIREDIS_REPS}"
        for scenario in "${HIREDIS_SCENARIOS[@]}"; do
            run_scenario_once "${scenario}" "rep${repetition}" || return 50
            log_message "scenario ${scenario} rep${repetition} ok"
        done
    done

    aggregate_raw_output "${network_mode}" || return 50

    export HIREDIS_NETWORK_MODE="${network_mode}"
    export HIREDIS_C_COMPILER="$(compiler_identity)"
    export HIREDIS_ACTUAL_VERSION_STRING="$(cat "${PERF_ACTUAL_VERSION_FILE}" 2>/dev/null || true)"
    export HIREDIS_SOURCE_SHA256 HIREDIS_SOURCE_NAME HIREDIS_BUILD_JOBS \
        HIREDIS_OPTIMIZATION HIREDIS_HARNESS_CFLAGS

    python3 "${SCRIPTS_DIR}/results/parse_benchmark.py" \
        "${HIREDIS_RUNS_DIR}" "${RESULTS_DIR}/results.json" || {
        fail_message "result parsing failed"
        return 50
    }

    log_message "all ${#HIREDIS_SCENARIOS[@]} scenarios finished with ${HIREDIS_REPS} repetitions"
    return 0
}
