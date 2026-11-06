#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# One measured scenario repetition: a single child process, complete stdout and
# stderr kept in runs/<scenario>/<label>.log, wall time and peak RSS recorded in
# runs/<scenario>/<label>.json.  On failure the tail of that log is printed to
# stdout so the CI log shows the parser error instead of only an exit code.
run_timed() {
    local scenario="$1" label="$2" workdir="$3"
    shift 3
    local directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    local exit_code=0
    # The timing wrapper runs inside the private container so every sample is
    # produced by a container-native child and `docker exec` overhead stays
    # outside the measurement window.
    expat_container_exec_at "${workdir}" \
        python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
            --json "${directory}/${label}.json" \
            --log "${directory}/${label}.log" \
            --timeout 3600 \
            -- "$@" || exit_code=$?
    if (( exit_code != 0 )); then
        report_failure_tail "${directory}/${label}.log" "${scenario}" "${label}" "${exit_code}"
    fi
    return "${exit_code}"
}

# Verify that a repetition's captured output really proves the work was done.
# A run that silently parsed zero documents (or a different corpus) must never
# become a measurement.
verify_log_pattern() {
    local scenario="$1" label="$2" log_file="$3" pattern="$4" description="$5"
    if [[ ! -f "${log_file}" ]]; then
        log_message "ERROR: ${scenario} (${label}) produced no log: ${log_file}"
        return 50
    fi
    if ! grep -qE -- "${pattern}" "${log_file}"; then
        log_message "ERROR: ${scenario} (${label}) does not show the expected ${description}"
        report_failure_tail "${log_file}" "${scenario}" "${label}" 50
        return 50
    fi
}

verify_no_parser_errors() {
    local scenario="$1" label="$2" log_file="$3"
    if grep -qiE -- 'error' "${log_file}"; then
        log_message "ERROR: ${scenario} (${label}) reported an error"
        report_failure_tail "${log_file}" "${scenario}" "${label}" 50
        return 50
    fi
}

run_labels() {
    printf 'warmup\n'
    local index
    for index in $(seq 1 "${EXPAT_REPS}"); do
        printf 'rep%s\n' "${index}"
    done
}

# One xmlwf scenario over one generated corpus.  Additional arguments are xmlwf
# flags (for example -n, -p, -t).
run_xmlwf_scenario() {
    local scenario="$1" corpus="$2"
    shift 2
    local file="${EXPAT_CORPUS_DIR}/${corpus}"
    local directory="${RUNS_DIR}/${scenario}"
    local label
    for label in $(run_labels); do
        if [[ "${label}" == warmup ]]; then
            log_message "scenario ${scenario}: warmup"
        else
            log_message "scenario ${scenario}: ${label#rep}/${EXPAT_REPS}"
        fi
        run_timed "${scenario}" "${label}" "${EXPAT_CORPUS_DIR}" \
            "${EXPAT_XMLWF}" "$@" -t "${file}" || return $?
        verify_no_parser_errors "${scenario}" "${label}" "${directory}/${label}.log" || return $?
    done
}

# The upstream test suite.  Its summary line is part of the measurement contract
# because the source release is pinned.
run_upstream_runtests() {
    local scenario="upstream_runtests"
    local directory="${RUNS_DIR}/${scenario}"
    local label
    for label in $(run_labels); do
        if [[ "${label}" == warmup ]]; then
            log_message "scenario ${scenario}: warmup"
        else
            log_message "scenario ${scenario}: ${label#rep}/${EXPAT_REPS}"
        fi
        run_timed "${scenario}" "${label}" "${EXPAT_SRC_DIR}" \
            "${EXPAT_RUNTESTS}" || return $?
        verify_log_pattern "${scenario}" "${label}" "${directory}/${label}.log" \
            "Checks: ${EXPAT_RUNTESTS_CHECKS}, Failed: 0" \
            "pinned upstream summary (${EXPAT_RUNTESTS_CHECKS} checks, 0 failed)" || return $?
    done
}

# The upstream benchmark driver: parses one corpus `iterations` times through a
# fixed buffer size and prints the average time per loop.
run_upstream_benchmark() {
    local scenario="$1" corpus="$2" namespace_flag="$3"
    local directory="${RUNS_DIR}/${scenario}"
    local file="${EXPAT_CORPUS_DIR}/${corpus}"
    local label
    for label in $(run_labels); do
        if [[ "${label}" == warmup ]]; then
            log_message "scenario ${scenario}: warmup"
        else
            log_message "scenario ${scenario}: ${label#rep}/${EXPAT_REPS}"
        fi
        if [[ -n "${namespace_flag}" ]]; then
            run_timed "${scenario}" "${label}" "${EXPAT_CORPUS_DIR}" \
                "${EXPAT_BENCHMARK}" -n "${file}" "${EXPAT_BENCH_BUFFER}" "${EXPAT_BENCH_ITERATIONS}" || return $?
        else
            run_timed "${scenario}" "${label}" "${EXPAT_CORPUS_DIR}" \
                "${EXPAT_BENCHMARK}" "${file}" "${EXPAT_BENCH_BUFFER}" "${EXPAT_BENCH_ITERATIONS}" || return $?
        fi
        verify_log_pattern "${scenario}" "${label}" "${directory}/${label}.log" \
            "${EXPAT_BENCH_ITERATIONS} loops, with buffer size ${EXPAT_BENCH_BUFFER}" \
            "pinned benchmark summary" || return $?
        verify_log_pattern "${scenario}" "${label}" "${directory}/${label}.log" \
            "Average time per loop: [0-9]" "benchmark average time" || return $?
    done
}

run_expat_benchmarks() {
    initialize_runtime || return $?
    check_expat_container || return $?
    if [[ -z "${RESULTS_DIR}" || -z "${RUNS_DIR}" ]]; then
        log_message "ERROR: results directory is not configured"
        return 50
    fi
    if ! expat_container_exec test -x "${EXPAT_XMLWF}"; then
        log_message "ERROR: measured binary is unavailable: ${EXPAT_XMLWF}"
        return 50
    fi
    if [[ ! -s "${EXPAT_CORPUS_MANIFEST}" ]]; then
        log_message "ERROR: corpus manifest is missing: ${EXPAT_CORPUS_MANIFEST}"
        return 50
    fi
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"

    run_xmlwf_scenario xmlwf_parse_wide wide.xml || return $?
    run_xmlwf_scenario xmlwf_parse_huge huge.xml || return $?
    run_xmlwf_scenario xmlwf_parse_namespaced namespaced.xml -n || return $?
    run_xmlwf_scenario xmlwf_parse_entities entities.xml || return $?
    run_xmlwf_scenario xmlwf_parse_external_dtd dtd_ext.xml -p || return $?
    run_upstream_runtests || return $?
    run_upstream_benchmark upstream_benchmark_wide wide.xml "" || return $?
    run_upstream_benchmark upstream_benchmark_namespaced namespaced.xml "-n" || return $?

    EXPAT_VERSION_STRING="$(expat_version_string 2>/dev/null)" || EXPAT_VERSION_STRING=""
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    export EXPAT_REPS EXPAT_JOBS EXPAT_RUNTESTS_CHECKS
    export EXPAT_BENCH_ITERATIONS EXPAT_BENCH_BUFFER
    export EXPAT_SOURCE_NAME EXPAT_SOURCE_SHA256 EXPAT_SOURCE_URL
    export EXPAT_VERSION_STRING EXPAT_CORPUS_MANIFEST
    export EXPAT_SCENARIOS
    if ! python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json"; then
        log_message "ERROR: result parsing failed; the test stage does not accept incomplete or inconsistent measurements"
        return 50
    fi
    log_message "complete expat matrix finished (reps=${EXPAT_REPS}, corpora=$((${#EXPAT_CORPORA[@]})), scenarios=$((${#EXPAT_SCENARIOS[@]})))"
}
