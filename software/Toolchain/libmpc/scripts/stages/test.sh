#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_timed() {
    local scenario="$1" label="$2"
    local directory="${RUNS_DIR}/${scenario}" routine precision
    mkdir -p "${directory}"
    routine="$(scenario_routine "${scenario}")" || return 1
    precision="$(scenario_precision "${scenario}")" || return 1
    local rc=0
    libmpc_container_exec_at "${PERF_WORK_DIR}" \
        python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
        --json "${directory}/${label}.json" \
        --log "${directory}/${label}.log" \
        --timeout 900 \
        -- "${MPC_BENCH_BIN}" "${routine}" "${precision}" || rc=$?
    if (( rc != 0 )); then
        log_message "ERROR: scenario ${scenario} ${label} failed with exit code ${rc}"
        if [[ -f "${directory}/${label}.log" ]]; then
            log_message "---- tail of ${scenario}/${label}.log ----"
            tail -n 40 -- "${directory}/${label}.log" | while IFS= read -r line; do log_message "  ${line}"; done
            log_message "---- end of ${scenario}/${label}.log ----"
        fi
    fi
    return "${rc}"
}

write_raw_output() {
    local scenario label scenario_dir value
    {
        printf '# MPC benchmark raw output\n'
        printf '# generated: %s\n' "$(TZ=UTC-8 date '+%F %T')"
        printf '# reps: %s, warmup: %s\n' "${MPC_REPS}" "${MPC_WARMUP_REPS}"
        for scenario in "${MPC_SCENARIOS[@]}"; do
            scenario_dir="${RUNS_DIR}/${scenario}"
            for label in warmup1 $(for value in $(seq 1 "${MPC_REPS}"); do printf 'rep%s ' "${value}"; done); do
                [[ -f "${scenario_dir}/${label}.log" ]] || continue
                printf '===== %s / %s =====\n' "${scenario}" "${label}"
                cat -- "${scenario_dir}/${label}.log"
            done
        done
    } > "${RESULTS_DIR}/raw-output.log"
}

verify_samples() {
    local scenario label directory value
    for scenario in "${MPC_SCENARIOS[@]}"; do
        directory="${RUNS_DIR}/${scenario}"
        for value in $(seq 1 "${MPC_WARMUP_REPS}"); do
            [[ -f "${directory}/warmup${value}.json" ]] || {
                log_message "ERROR: missing warmup sample ${scenario}/warmup${value}.json"
                return 50
            }
        done
        for value in $(seq 1 "${MPC_REPS}"); do
            [[ -f "${directory}/rep${value}.json" ]] || {
                log_message "ERROR: missing measured sample ${scenario}/rep${value}.json"
                return 50
            }
        done
    done
    return 0
}

run_mpc_benchmarks() {
    local scenario rep
    initialize_runtime || return $?
    check_libmpc_container || return 50
    libmpc_container_exec test -x "${MPC_BENCH_BIN}" || {
        log_message "ERROR: MPC benchmark harness is unavailable in the container: ${MPC_BENCH_BIN}"
        return 50
    }
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"

    for scenario in "${MPC_SCENARIOS[@]}"; do
        log_message "scenario ${scenario}: warmup (${MPC_WARMUP_REPS} run(s))"
        for rep in $(seq 1 "${MPC_WARMUP_REPS}"); do
            run_timed "${scenario}" "warmup${rep}" || return 50
        done
        log_message "scenario ${scenario}: ${MPC_REPS} measured repetition(s)"
        for rep in $(seq 1 "${MPC_REPS}"); do
            run_timed "${scenario}" "rep${rep}" || return 50
        done
    done

    write_raw_output
    verify_samples || return 50

    log_message "aggregating ${MPC_REPS} repetition(s) per scenario"
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        --runs "${RUNS_DIR}" \
        --output "${RESULTS_DIR}/benchmark_mpc.json" \
        --reps "${MPC_REPS}" \
        --warmup-reps "${MPC_WARMUP_REPS}" || {
        log_message "ERROR: MPC result parser failed; the measurement set is incomplete or invalid"
        return 50
    }
    log_message "MPC benchmark results written to ${RESULTS_DIR}/benchmark_mpc.json"
}
