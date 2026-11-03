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
    libxml2_container_exec_at "${workdir}" \
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
# The upstream test drivers print a pinned summary; a run that silently parsed
# zero documents (or a different corpus) must never become a measurement.
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
    if grep -qE -- '(^|[^a-z])parser error|validity error|I/O error' "${log_file}"; then
        log_message "ERROR: ${scenario} (${label}) reported a parser/validation error"
        report_failure_tail "${log_file}" "${scenario}" "${label}" 50
        return 50
    fi
}

run_labels() {
    printf 'warmup\n'
    local index
    for index in $(seq 1 "${LIBXML2_REPS}"); do
        printf 'rep%s\n' "${index}"
    done
}

# One xmllint scenario over one generated corpus.  Extra arguments are the
# xmllint mode flags (--noout, --valid, --sax, --repeat, --xpath ...).
run_xmllint_scenario() {
    local scenario="$1" corpus="$2"
    shift 2
    local file="${LIBXML2_CORPUS_DIR}/${corpus}"
    local directory="${RUNS_DIR}/${scenario}"
    local label
    for label in $(run_labels); do
        if [[ "${label}" == warmup ]]; then
            log_message "scenario ${scenario}: warmup"
        else
            log_message "scenario ${scenario}: ${label#rep}/${LIBXML2_REPS}"
        fi
        run_timed "${scenario}" "${label}" "${PERF_WORK_DIR}" \
            "${LIBXML2_XMLLINT}" --nonet "$@" "${file}" || return $?
        if [[ "${scenario}" == xmllint_xpath_wide ]]; then
            verify_log_pattern "${scenario}" "${label}" "${directory}/${label}.log" \
                "^${LIBXML2_XPATH_ITEM_TOTAL}$" "pinned XPath item count (${LIBXML2_XPATH_ITEM_TOTAL})" || return $?
        fi
        if [[ "${scenario}" != xmllint_sax_namespaced ]]; then
            verify_no_parser_errors "${scenario}" "${label}" "${directory}/${label}.log" || return $?
        fi
    done
}

# One upstream driver scenario: the prebuilt upstream test binary runs from the
# source tree (it needs test/ and result/) and must print its pinned summary.
run_upstream_scenario() {
    local scenario="$1" binary="$2" summary="$3"
    local directory="${RUNS_DIR}/${scenario}"
    local label
    for label in $(run_labels); do
        if [[ "${label}" == warmup ]]; then
            log_message "scenario ${scenario}: warmup"
        else
            log_message "scenario ${scenario}: ${label#rep}/${LIBXML2_REPS}"
        fi
        run_timed "${scenario}" "${label}" "${LIBXML2_SRC_DIR}" "${binary}" || return $?
        verify_log_pattern "${scenario}" "${label}" "${directory}/${label}.log" \
            "${summary}" "pinned upstream summary '${summary}'" || return $?
    done
}

run_libxml2_benchmarks() {
    initialize_runtime || return $?
    if [[ -z "${RESULTS_DIR}" || -z "${RUNS_DIR}" ]]; then
        log_message "ERROR: results directory is not configured"
        return 50
    fi
    if [[ ! -x "${LIBXML2_XMLLINT}" ]]; then
        log_message "ERROR: measured binary is unavailable: ${LIBXML2_XMLLINT}"
        return 50
    fi
    if [[ ! -s "${LIBXML2_CORPUS_MANIFEST}" ]]; then
        log_message "ERROR: corpus manifest is missing: ${LIBXML2_CORPUS_MANIFEST}"
        return 50
    fi
    if ! libxml2_container_exec sh -c 'command -v cc >/dev/null 2>&1'; then
        log_message "ERROR: C compiler driver cc is unavailable in the container"
        return 50
    fi
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"

    run_xmllint_scenario xmllint_parse_wide wide.xml --noout || return $?
    run_xmllint_scenario xmllint_parse_huge huge.xml --noout || return $?
    run_xmllint_scenario xmllint_parse_deep deep.xml --huge --noout || return $?
    run_xmllint_scenario xmllint_parse_namespaced namespaced.xml --noout || return $?
    run_xmllint_scenario xmllint_dtd_validate dtd.xml --valid --noout || return $?
    run_xmllint_scenario xmllint_sax_namespaced namespaced.xml --sax --noout || return $?
    run_xmllint_scenario xmllint_repeat_wide repeat.xml --repeat --noout || return $?
    run_xmllint_scenario xmllint_xpath_wide wide.xml --xpath 'count(//item)' || return $?
    run_upstream_scenario upstream_runtest "${LIBXML2_RUNTEST}" \
        "Total ${LIBXML2_RUNTEST_TOTAL} tests, no errors" || return $?
    run_upstream_scenario upstream_runsuite "${LIBXML2_RUNSUITE}" \
        "Total ${LIBXML2_RUNSUITE_TOTAL} tests, no errors" || return $?

    LIBXML2_VERSION_STRING="$(libxml2_version_string 2>/dev/null)" || LIBXML2_VERSION_STRING=""
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    export LIBXML2_REPS LIBXML2_JOBS LIBXML2_REPEAT_ITERATIONS
    export LIBXML2_SOURCE_NAME LIBXML2_SOURCE_SHA256 LIBXML2_SOURCE_URL
    export LIBXML2_RUNTEST_TOTAL LIBXML2_RUNSUITE_TOTAL LIBXML2_XPATH_ITEM_TOTAL
    export LIBXML2_VERSION_STRING LIBXML2_CORPUS_MANIFEST
    export LIBXML2_SCENARIOS
    if ! python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json"; then
        log_message "ERROR: result parsing failed; the test stage does not accept incomplete or inconsistent measurements"
        return 50
    fi
    log_message "complete libxml2 matrix finished (reps=${LIBXML2_REPS}, corpora=$((${#LIBXML2_CORPORA[@]})), scenarios=$((${#LIBXML2_SCENARIOS[@]})))"
}
