#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_git_benchmarks() {
    local raw_output results_copy script_args
    initialize_runtime || return $?
    check_git_container || return $?
    container_exec test -x "${GIT_BIN}" || {
        log_message 'ERROR: git is not built; build stage did not complete'
        return 40
    }
    container_exec "${GIT_BIN}" --version || return 40
    raw_output="${RESULTS_DIR}/git_benchmark_raw.log"
    results_copy="${RESULTS_DIR}/git_perf_results"
    script_args="${GIT_PERF_SCRIPTS[*]}"
    log_message "running the upstream t/perf suite inside the container with best-of-${GIT_PERF_REPEAT_COUNT} repeats"
    container_exec rm -rf "${GIT_PERF_DIR}/test-results"
    if ! container_exec sh -c \
        "cd '${GIT_PERF_DIR}' && GIT_PERF_REPEAT_COUNT='${GIT_PERF_REPEAT_COUNT}' ./run . -- ${script_args}" \
        2>&1 | tee "${raw_output}"; then
        log_message 'ERROR: the git perf suite failed'
        return 50
    fi
    container_exec test -s "${GIT_PERF_DIR}/test-results/p0002-read-cache.1.result" || {
        log_message 'ERROR: the perf suite produced no results'
        return 50
    }
    # The work directory is bind-mounted, so the raw test-results written
    # inside the container are already visible on the host; copy them into
    # the result directory, which is also mounted into the container.
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
