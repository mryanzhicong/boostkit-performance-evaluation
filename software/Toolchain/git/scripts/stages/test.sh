#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_git_benchmarks() {
    local raw_output results_copy
    initialize_runtime || return $?
    [[ -x "${GIT_BIN}" ]] || {
        log_message 'ERROR: git is not built; build stage did not complete'
        return 40
    }
    "${GIT_BIN}" --version || return 40
    raw_output="${RESULTS_DIR}/git_benchmark_raw.log"
    results_copy="${RESULTS_DIR}/git_perf_results"
    log_message "running the upstream t/perf suite with best-of-${GIT_PERF_REPEAT_COUNT} repeats"
    rm -rf "${GIT_PERF_DIR}/test-results"
    if ! (cd "${GIT_PERF_DIR}" && \
        GIT_PERF_REPEAT_COUNT="${GIT_PERF_REPEAT_COUNT}" \
        ./run . -- "${GIT_PERF_SCRIPTS[@]}") 2>&1 | tee "${raw_output}"; then
        log_message 'ERROR: the git perf suite failed'
        return 50
    fi
    [[ -s "${GIT_PERF_DIR}/test-results/p0002-read-cache.1.result" ]] || {
        log_message 'ERROR: the perf suite produced no results'
        return 50
    }
    rm -rf "${results_copy}"
    cp -a "${GIT_PERF_DIR}/test-results" "${results_copy}" || return 50
    python3 "${CASE_DIR}/scripts/results/collect_git_benchmark.py" \
        "${results_copy}" "${RESULTS_DIR}/benchmark_git.json" \
        "${SOFTWARE_VERSION}" "${EXPECTED_ARCH}" "${GIT_PERF_REPEAT_COUNT}" || {
        log_message 'ERROR: git result collection failed'
        return 50
    }
    log_message 'git perf suite completed'
}
