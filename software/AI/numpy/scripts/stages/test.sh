#!/usr/bin/env bash
# ==============================================================================
# numpy test stage -- the only stage that measures anything.
# ==============================================================================
# Runs the vendored aggregate ASV suite against the containerised NumPy 2.4.3
# baseline, publishes the ASV report and then hands the raw ASV result file to
# the strict host-side parser.  The parser is deliberately kept off the
# measured process tree: it re-reads the recorded samples and refuses anything
# that is missing, duplicated, non-finite or shorter than the declared sampling
# window.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Raw ASV records land in runs/ so the report can be reproduced without the
# container; the published tree keeps ASV's native results/ + html/ layout.
numpy_copy_tree() {
    local source="$1" target="$2"
    mkdir -p "${target}" || return 30
    cp -a "${source}/." "${target}/" || return 30
}

numpy_run_asv_benchmarks() {
    local log="${RESULTS_DIR}/asv-run.log"
    local total_samples rc=0 started finished
    local -a exact=()
    local -a bench_args=()
    total_samples=$(( NUMPY_WARMUPS + NUMPY_REPS ))

    mapfile -t exact < <(numpy_container_exec "${VENV_PY}" \
        "${SCRIPT_DIR}/scripts/benchmarks/select_benchmarks.py" \
        --list "${ASV_LIST}" --emit-bench-args) || {
        log_message "ERROR: cannot expand the benchmark id list"
        return 50
    }
    if [ "${#exact[@]}" -lt 1200 ]; then
        log_message "ERROR: the benchmark id list expanded to only ${#exact[@]} entries"
        return 50
    fi
    for regex in "${exact[@]}"; do
        bench_args+=(-b "${regex}")
    done

    log_message "measuring ${#exact[@]} benchmark ids: ${NUMPY_WARMUPS} warm-up sample(s) + ${NUMPY_REPS} retained samples per benchmark"
    started="$(date +%s)"
    numpy_container_exec_at "${ASV_DIR}" env "${NUMPY_MEASUREMENT_ENV[@]}" \
        "HOME=${PERF_WORK_DIR}/home" "${ASV_BIN}" run \
        --config asv.conf.json \
        --python=same \
        --set-commit-hash "${NUMPY_BASELINE_COMMIT}" \
        --no-pull \
        --record-samples \
        -a rounds=1 \
        -a "repeat=${total_samples}" \
        "${bench_args[@]}" 2>&1 | tee "${log}" || rc=$?
    finished="$(date +%s)"
    if [ "${rc}" -ne 0 ]; then
        log_message "ERROR: the ASV measurement failed (exit ${rc}), see asv-run.log"
        tail -40 "${log}" || true
        return 50
    fi
    ASV_RUN_SECONDS=$((finished - started))
    log_message "ASV measurement finished in ${ASV_RUN_SECONDS}s"
    numpy_collect_raw_evidence || return $?
}

numpy_collect_raw_evidence() {
    local results_file machine_file commit_short
    commit_short="${NUMPY_BASELINE_COMMIT:0:8}"
    results_file="$(find "${ASV_RESULTS_DIR}" -name "${commit_short}-*.json" -type f 2>/dev/null | head -n 1)"
    if [ -z "${results_file}" ]; then
        log_message "ERROR: ASV recorded no result file for commit ${commit_short}"
        return 50
    fi
    if [ ! -s "${ASV_RESULTS_DIR}/benchmarks.json" ]; then
        log_message "ERROR: ASV discovery file is missing"
        return 50
    fi
    numpy_copy_tree "$(dirname "${results_file}")" "${RUNS_DIR}" || return 30
    cp -f "${results_file}" "${RUNS_DIR}/asv-results.json" || return 30
    cp -f "${ASV_RESULTS_DIR}/benchmarks.json" "${RUNS_DIR}/asv-benchmarks.json" || return 30
    machine_file="$(dirname "${results_file}")/machine.json"
    if [ -s "${machine_file}" ]; then
        cp -f "${machine_file}" "${RUNS_DIR}/asv-machine.json" || return 30
    fi
    cp -f "${RESULTS_DIR}/asv-run.log" "${RUNS_DIR}/asv-run.log" 2>/dev/null || true
    numpy_container_exec_at "${ASV_DIR}" env "${NUMPY_MEASUREMENT_ENV[@]}" \
        "HOME=${PERF_WORK_DIR}/home" "${ASV_BIN}" show "${NUMPY_BASELINE_COMMIT}" \
        > "${RUNS_DIR}/asv-show.txt" 2>&1 || log_message "WARNING: asv show failed (non-fatal)"
    log_message "raw ASV evidence copied into runs/"
}

numpy_publish_asv_report() {
    local log="${RESULTS_DIR}/asv-publish.log"
    log_message "publishing the ASV html report"
    numpy_container_exec_at "${ASV_DIR}" env "${NUMPY_MEASUREMENT_ENV[@]}" \
        "HOME=${PERF_WORK_DIR}/home" "${ASV_BIN}" publish --config asv.conf.json \
        > "${log}" 2>&1 || {
        log_message "ERROR: asv publish failed, see asv-publish.log"
        tail -40 "${log}" || true
        return 50
    }
    if [ ! -s "${ASV_HTML_DIR}/index.html" ]; then
        log_message "ERROR: asv publish produced no html/index.html"
        return 50
    fi
    mkdir -p "${RESULTS_DIR}/asv" || return 30
    numpy_copy_tree "${ASV_RESULTS_DIR}" "${RESULTS_DIR}/asv/results" || return 30
    numpy_copy_tree "${ASV_HTML_DIR}" "${RESULTS_DIR}/asv/html" || return 30
    log_message "published report copied to asv/results and asv/html"
}

# Host-side strict parsing: every declared benchmark must be present with the
# full sampling window, otherwise the stage fails instead of publishing a gap.
numpy_parse_measurement() {
    local parser="${SCRIPT_DIR}/scripts/results/parse_benchmark.py"
    local host_python="${PERF_HOST_PYTHON:-python3}"
    if ! command -v "${host_python}" >/dev/null 2>&1; then
        log_message "ERROR: ${host_python} is required for the strict result parser"
        return 50
    fi
    log_message "validating the ASV result file with the strict parser"
    "${host_python}" "${parser}" \
        --results "${RUNS_DIR}/asv-results.json" \
        --benchmarks "${RUNS_DIR}/asv-benchmarks.json" \
        --list "${ASV_LIST}" \
        --out "${RESULTS_DIR}/results.json" \
        --samples "${RUNS_DIR}/samples.json" \
        --log-summary || {
        log_message "ERROR: the measurement did not satisfy the result contract"
        return 50
    }
    log_message "results.json written: $(numpy_count_json_results "${RESULTS_DIR}/results.json") metrics"
}

numpy_count_json_results() {
    local file="$1"
    [ -s "${file}" ] || { printf '0\n'; return 0; }
    "${PERF_HOST_PYTHON:-python3}" -c 'import json,sys; print(len(json.load(open(sys.argv[1]))["results"]))' "${file}" 2>/dev/null || printf '0\n'
}

run_numpy_benchmarks() {
    initialize_runtime || return $?
    check_architecture || return $?
    validate_reps || return $?
    numpy_configure_container || return $?
    numpy_require_host_tools || return $?
    require_numpy_docker || return $?
    check_numpy_container || return 40

    numpy_verify_runtime_payload || return $?
    numpy_run_asv_benchmarks || return $?
    numpy_publish_asv_report || return $?
    numpy_parse_measurement || return $?
    log_message "test stage complete"
}
