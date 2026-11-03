#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_timed() {
    local scenario="$1" label="$2" attempt="$3"
    local directory="${RUNS_DIR}/${scenario}" size routine
    mkdir -p "${directory}"
    size="$(scenario_size "${scenario}")" || return 1
    routine="$(scenario_routine "${scenario}")" || return 1
    gmp_container_exec_at "${GMP_SOURCE_DIR}/tune" \
        python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
        --json "${directory}/${label}.attempt${attempt}.json" \
        --log "${directory}/${label}.attempt${attempt}.log" \
        --timeout 900 \
        -- ./speed -s "${size}" "${routine}" >/dev/null 2>&1
}

# Run one sample, retrying only when upstream tune/speed itself failed to produce
# a value (it prints "speed_measure() could not get 4 results within 1.0%" and
# "n/a").  The retried attempt is kept next to the sample for audit and the
# recorded wall time/RSS always belong to the attempt whose value is reported.
run_sample() {
    local scenario="$1" label="$2"
    local directory="${RUNS_DIR}/${scenario}"
    local attempt rc
    mkdir -p "${directory}"
    for attempt in $(seq 1 "${GMP_MAX_ATTEMPTS}"); do
        rc=0
        run_timed "${scenario}" "${label}" "${attempt}" || rc=$?
        if (( rc != 0 )); then
            log_message "ERROR: scenario ${scenario} ${label} attempt ${attempt} failed with exit code ${rc}"
            tail -n 40 -- "${directory}/${label}.attempt${attempt}.log" 2>/dev/null | \
                while IFS= read -r line; do log_message "  ${line}"; done
            continue
        fi
        if grep -q 'could not get' "${directory}/${label}.attempt${attempt}.log" 2>/dev/null; then
            log_message "scenario ${scenario} ${label}: tune/speed did not converge (attempt ${attempt}/${GMP_MAX_ATTEMPTS}), retrying"
            continue
        fi
        printf '# accepted attempt: %s/%s\n' "${attempt}" "${GMP_MAX_ATTEMPTS}" \
            >> "${directory}/${label}.attempt${attempt}.log"
        mv -f -- "${directory}/${label}.attempt${attempt}.json" "${directory}/${label}.json"
        mv -f -- "${directory}/${label}.attempt${attempt}.log" "${directory}/${label}.log"
        return 0
    done
    log_message "ERROR: scenario ${scenario} ${label} produced no usable measurement after ${GMP_MAX_ATTEMPTS} attempts"
    return 50
}

write_raw_output() {
    local scenario label scenario_dir value
    {
        printf '# GMP tune/speed raw output\n'
        printf '# generated: %s\n' "$(TZ=UTC-8 date '+%F %T')"
        printf '# reps: %s, warmup: %s\n' "${GMP_REPS}" "${GMP_WARMUP_REPS}"
        for scenario in "${GMP_SCENARIOS[@]}"; do
            scenario_dir="${RUNS_DIR}/${scenario}"
            for label in warmup $(for value in $(seq 1 "${GMP_REPS}"); do printf 'rep%s ' "${value}"; done); do
                [[ -f "${scenario_dir}/${label}.log" ]] || continue
                printf '===== %s / %s =====\n' "${scenario}" "${label}"
                cat -- "${scenario_dir}/${label}.log"
            done
        done
    } > "${RESULTS_DIR}/raw-output.log"
}

verify_samples() {
    local scenario label directory
    for scenario in "${GMP_SCENARIOS[@]}"; do
        directory="${RUNS_DIR}/${scenario}"
        for label in $(for value in $(seq 1 "${GMP_WARMUP_REPS}"); do printf 'warmup%s ' "${value}"; done); do
            [[ -f "${directory}/${label}.json" ]] || {
                log_message "ERROR: missing warmup sample ${scenario}/${label}.json"
                return 50
            }
        done
        for label in $(for value in $(seq 1 "${GMP_REPS}"); do printf 'rep%s ' "${value}"; done); do
            [[ -f "${directory}/${label}.json" ]] || {
                log_message "ERROR: missing measured sample ${scenario}/${label}.json"
                return 50
            }
        done
    done
    return 0
}

run_gmp_benchmarks() {
    local scenario rep directory label
    initialize_runtime || return $?
    check_gmp_container || return 50
    gmp_container_exec test -x "${GMP_SPEED_BIN}" || {
        log_message "ERROR: upstream tune/speed is unavailable in the container: ${GMP_SPEED_BIN}"
        return 50
    }
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"

    for scenario in "${GMP_SCENARIOS[@]}"; do
        log_message "scenario ${scenario}: warmup (${GMP_WARMUP_REPS} run(s))"
        for rep in $(seq 1 "${GMP_WARMUP_REPS}"); do
            run_sample "${scenario}" "warmup${rep}" || return 50
        done
        log_message "scenario ${scenario}: ${GMP_REPS} measured repetition(s)"
        for rep in $(seq 1 "${GMP_REPS}"); do
            run_sample "${scenario}" "rep${rep}" || return 50
        done
    done

    write_raw_output
    verify_samples || return 50

    log_message "aggregating ${GMP_REPS} repetition(s) per scenario"
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        --runs "${RUNS_DIR}" \
        --output "${RESULTS_DIR}/benchmark_gmp.json" \
        --reps "${GMP_REPS}" \
        --warmup-reps "${GMP_WARMUP_REPS}" || {
        log_message "ERROR: GMP result parser failed; the measurement set is incomplete or invalid"
        return 50
    }
    log_message "GMP benchmark results written to ${RESULTS_DIR}/benchmark_gmp.json"
}
