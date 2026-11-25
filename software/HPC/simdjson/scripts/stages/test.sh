#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

simdjson_validate_sampling() {
    if [[ ! "${PERF_REPS}" =~ ^[0-9]+$ ]] || (( PERF_REPS < 1 || PERF_REPS > 20 )); then
        log_message "ERROR: PERF_REPS must be an integer between 1 and 20, got ${PERF_REPS}"
        return 10
    fi
    if [[ ! "${SIMDJSON_WARMUPS}" =~ ^[0-9]+$ ]] || (( SIMDJSON_WARMUPS > 3 )); then
        log_message "ERROR: SIMDJSON_WARMUPS must be an integer between 0 and 3, got ${SIMDJSON_WARMUPS}"
        return 10
    fi
    if [[ ! "${SIMDJSON_BENCH_MIN_TIME}" =~ ^[0-9]+(\.[0-9]+)?(ms|s)$ ]]; then
        log_message "ERROR: SIMDJSON_BENCH_MIN_TIME must look like 500ms or 1s, got ${SIMDJSON_BENCH_MIN_TIME}"
        return 10
    fi
    if [[ ! "${SIMDJSON_PARSE_ITERATIONS}" =~ ^[1-9][0-9]*$ ]]; then
        log_message "ERROR: SIMDJSON_PARSE_ITERATIONS must be a positive integer, got ${SIMDJSON_PARSE_ITERATIONS}"
        return 10
    fi
    if (( PERF_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${PERF_REPS} is below the 5-sample contract; this run only validates the pipeline"
    fi
}

# run_step <label> <stdout log> <command inside the container...>
simdjson_run_step() {
    local label="$1" log="$2"
    shift 2
    local status err="${log%.log}.err"
    simdjson_container_exec timeout 2400 "$@" > "${log}" 2> "${err}"
    status=$?
    if (( status == 0 )); then
        return 0
    fi
    if (( status == 124 )); then
        log_message "ERROR: ${label} timed out after 2400 s"
    else
        log_message "ERROR: ${label} failed with exit code ${status}"
    fi
    tail -n 20 "${err}" 2>/dev/null || true
    tail -n 20 "${log}" 2>/dev/null || true
    return 50
}

run_simdjson_benchmarks() {
    simdjson_configure_paths || return $?
    simdjson_validate_sampling || return $?
    check_simdjson_container || return $?

    local build src run_root scenario suite rep total i
    build="$(simdjson_build_dir)"
    src="$(simdjson_source_dir)"
    run_root="${RESULTS_DIR}/runs"
    total=$(( SIMDJSON_WARMUPS + PERF_REPS ))

    for scenario in "${SIMDJSON_SCENARIOS[@]}"; do
        mkdir -p "${run_root}/${scenario}"
    done

    log_message "sampling: ${SIMDJSON_WARMUPS} warmup + ${PERF_REPS} measured round(s), container ${SIMDJSON_CONTAINER_NAME}"
    for ((i = 0; i < total; i++)); do
        if (( i < SIMDJSON_WARMUPS )); then
            log_message "round ${i}: warmup"
        else
            log_message "round ${i}: measured sample $((i - SIMDJSON_WARMUPS + 1))/${PERF_REPS}"
        fi
        simdjson_run_step "dom_parse round ${i}" "${run_root}/dom_parse/rep${i}.log" \
            "${build}/parse" \
            -n "${SIMDJSON_PARSE_ITERATIONS}" -t \
            "${src}/jsonexamples/twitter.json" \
            "${src}/jsonexamples/citm_catalog.json" || return 50
        simdjson_run_step "dom_parse_stream round ${i}" "${run_root}/dom_parse_stream/rep${i}.log" \
            "${build}/parse_stream" \
            "${src}/jsonexamples/amazon_cellphones.ndjson" || return 50
        for suite in bench_parse_call bench_dom_api bench_ondemand; do
            simdjson_run_step "${suite} round ${i}" "${run_root}/${suite}/rep${i}.log" \
                "${build}/${suite}" \
                --benchmark_min_time="${SIMDJSON_BENCH_MIN_TIME}" \
                --benchmark_out="${run_root}/${suite}/rep${i}.benchmark.json" \
                --benchmark_out_format=json || return 50
        done
    done

    {
        for scenario in "${SIMDJSON_SCENARIOS[@]}"; do
            for ((i = 0; i < total; i++)); do
                printf '\n===== %s rep%d =====\n' "${scenario}" "${i}"
                cat "${run_root}/${scenario}/rep${i}.log" 2>/dev/null || true
            done
        done
    } > "${RESULTS_DIR}/raw-output.log"
    log_message "raw outputs collected: ${RESULTS_DIR}/raw-output.log"

    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        --runs-dir "${run_root}" \
        --results-dir "${RESULTS_DIR}" \
        --fixtures "${SCRIPT_DIR}/fixtures/benchmarks.json" \
        --warmups "${SIMDJSON_WARMUPS}" \
        --reps "${PERF_REPS}" \
        --version "${SOFTWARE_VERSION}" \
        --architecture "$(simdjson_arch "${EXPECTED_ARCH}")" \
        --bench-min-time "${SIMDJSON_BENCH_MIN_TIME}" \
        --variant "${PERF_VARIANT}" \
        --run-id "${PERF_RUN_ID}" || return 50

    [[ -s "${RESULTS_DIR}/benchmark_simdjson.json" ]] || {
        log_message 'ERROR: the strict parser did not produce benchmark_simdjson.json'
        return 60
    }
    log_message "test stage finished: ${RESULTS_DIR}/benchmark_simdjson.json"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run_simdjson_benchmarks "$@"
fi
