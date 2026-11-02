#!/usr/bin/env bash
# Test stage: run every scenario with one warm-up and PCRE_REPS independent
# measurements.  Each measurement is a single child process recorded by
# scripts/run_timed.py (offline, inside a fresh network namespace when the start
# stage proved it is available).  Raw logs and per-repetition timing JSON stay in
# runs/<scenario>/, the parser aggregates them strictly afterwards.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

read_network_mode() {
    if [[ -s "${PCRE_OFFLINE_DIR_MODE_FILE}" ]]; then
        head -n 1 "${PCRE_OFFLINE_DIR_MODE_FILE}"
        return 0
    fi
    printf 'unavailable\n'
}

# One measured repetition of one scenario.  The scenario directory name is the
# scenario itself; the label is warmup / rep<N>.
run_measured() {
    local scenario="$1" label="$2" offline_flag="$3"
    shift 3
    local directory="${PCRE_RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    local rc=0
    local -a wrapper=(
        python3 "${SCRIPT_DIR}/scripts/run_timed.py"
        --json "${directory}/${label}.json"
        --log "${directory}/${label}.log"
        --timeout 1800
    )
    if [[ "${offline_flag}" == "1" ]]; then
        wrapper+=(--offline)
    fi
    (
        cd "${SCENARIO_WORKDIR}" || exit 1
        "${wrapper[@]}" -- "${SCENARIO_CMD[@]}"
    ) || rc=$?
    if (( rc != 0 )); then
        fail_message "scenario ${scenario} ${label} failed with exit code ${rc}"
        if [[ -f "${directory}/${label}.log" ]]; then
            fail_message "---- tail of ${scenario}/${label}.log ----"
            while IFS= read -r line; do fail_message "  ${line}"; done \
                < <(tail -n 40 -- "${directory}/${label}.log")
            fail_message "---- end of ${scenario}/${label}.log ----"
        fi
        return 50
    fi
    log_message "scenario ${scenario} ${label} ok"
    return 0
}

run_pcre_benchmarks() {
    initialize_runtime || return $?

    [[ -x "$(pcre_tool pcretest)" ]] || {
        fail_message "pcretest is missing; build stage did not complete"
        return 50
    }
    [[ -x "${PCRE_BENCH_BIN}" ]] || {
        fail_message "benchmark harness is missing; build stage did not complete"
        return 50
    }
    [[ -s "${PCRE_FIXTURE_MANIFEST}" ]] || {
        fail_message "fixtures are missing; start stage did not complete"
        return 50
    }

    local network_mode offline_flag
    network_mode="$(read_network_mode)"
    offline_flag="0"
    if [[ "${network_mode}" == "unshare" ]]; then
        offline_flag="1"
    else
        if [[ "${PERF_PCRE_ALLOW_ONLINE_MEASUREMENT:-0}" != "1" ]]; then
            fail_message "measurement network mode is ${network_mode} and online measurement is not allowed"
            return 50
        fi
        log_message "WARNING: measuring without network namespace isolation (mode: ${network_mode})"
    fi

    rm -rf -- "${PCRE_RUNS_DIR}"
    mkdir -p "${PCRE_RUNS_DIR}"

    local scenario index
    for scenario in "${PCRE_SCENARIOS[@]}"; do
        scenario_argv "${scenario}" || {
            fail_message "unknown scenario: ${scenario}"
            return 50
        }
        log_message "scenario ${scenario}: warm-up (network mode ${network_mode})"
        run_measured "${scenario}" warmup "${offline_flag}" || return 50
    done

    for index in $(seq 1 "${PCRE_REPS}"); do
        log_message "measurement repetition ${index}/${PCRE_REPS}"
        for scenario in "${PCRE_SCENARIOS[@]}"; do
            scenario_argv "${scenario}" || return 50
            run_measured "${scenario}" "rep${index}" "${offline_flag}" || return 50
        done
    done

    # Complete raw evidence in one declared text output: every warm-up and
    # repetition log, in execution order, with a separator header.
    {
        printf '# PCRE %s raw measurement output\n' "${SOFTWARE_VERSION}"
        printf '# architecture: %s\n' "${EXPECTED_ARCH}"
        printf '# repetitions: %s (plus %s warm-up per scenario)\n' "${PCRE_REPS}" "${PCRE_WARMUPS}"
        printf '# network mode during measurement: %s\n' "${network_mode}"
        for scenario in "${PCRE_SCENARIOS[@]}"; do
            for log_file in "${PCRE_RUNS_DIR}/${scenario}"/*.log; do
                [[ -f "${log_file}" ]] || continue
                printf '\n===== %s =====\n' "${log_file#"${PCRE_RUNS_DIR}"/}"
                cat -- "${log_file}"
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

    export PCRE_NETWORK_MODE="${network_mode}"
    export PCRE_C_COMPILER="$(compiler_identity)"
    export PCRE_PCRETEST_FEATURES="$("$(pcre_tool pcretest)" -C 2>/dev/null | tr '\n' ';' || true)"
    export PCRE_ACTUAL_VERSION_STRING="$(cat "${PERF_ACTUAL_VERSION_FILE}")"
    export PCRE_SOURCE_SHA256 PCRE_SOURCE_NAME PCRE_BUILD_JOBS PCRE_CFLAGS
    export PCRE_CONFIGURE_OPTIONS_TEXT="${PCRE_CONFIGURE_OPTIONS[*]}"
    export PCRE_RUNTEST_TESTS_TEXT="${PCRE_RUNTEST_TESTS[*]}"
    export PCRE_RUNTEST_ITERATIONS=1
    export PCRE_PCRETEST_LITERAL_ITERS PCRE_PCRETEST_BACKTRACK_ITERS
    export PCRE_PCRETEST_UTF8_ITERS PCRE_PCRETEST_DFA_ITERS
    export PCRE_BENCH_LITERAL_ITERS PCRE_BENCH_BACKTRACK_ITERS PCRE_BENCH_UTF8_ITERS
    export PCRE_BENCH_DFA_ITERS PCRE_BENCH_JIT_ITERS PCRE_BENCH_COMPILE_ITERS
    export PCRE_FIXTURE_LITERAL_SHA256 PCRE_FIXTURE_BACKTRACK_SHA256
    export PCRE_FIXTURE_UTF8_SHA256 PCRE_FIXTURE_DFA_SHA256
    export PCRE_FIXTURE_SCAN_PATTERNS_SHA256 PCRE_FIXTURE_SCAN_CORPUS_SHA256

    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${PCRE_RUNS_DIR}" "${RESULTS_DIR}/results.json" || {
        fail_message "result parsing failed"
        return 50
    }

    log_message "all ${#PCRE_SCENARIOS[@]} scenarios finished with ${PCRE_REPS} repetitions"
    return 0
}
