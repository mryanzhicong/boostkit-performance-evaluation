#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_git_runtime() {
    local smoke_dir
    initialize_runtime || return $?
    check_git_container || return $?
    container_exec test -x "${GIT_BIN}" || {
        log_message 'ERROR: git is not built; build stage did not complete'
        return 40
    }
    container_exec test -d "${GIT_PERF_DIR}" || {
        log_message 'ERROR: the checkout does not contain t/perf'
        return 40
    }
    # perf-lib requires GNU time through /usr/bin/time inside the container.
    container_exec test -x /usr/bin/time || {
        log_message 'ERROR: GNU time (/usr/bin/time) is required by the perf suite'
        return 40
    }
    container_exec "${GIT_BIN}" --version || return 40

    # Smoke-run the smallest official perf script once so the test stage only
    # ever measures a fully verified build and harness.
    smoke_dir="$(mktemp -d "${TMPDIR}/git-perf-smoke.XXXXXX")" || return 40
    if ! container_exec sh -c \
        "cd '${GIT_PERF_DIR}' && GIT_PERF_REPEAT_COUNT=1 ./run . -- p0002-read-cache.sh" \
        > "${smoke_dir}/smoke.log" 2>&1; then
        log_message "ERROR: perf harness smoke run failed (see ${smoke_dir}/smoke.log)"
        return 40
    fi
    container_exec test -s "${GIT_PERF_DIR}/test-results/p0002-read-cache.1.result" || {
        log_message 'ERROR: the perf harness smoke run produced no timing result'
        return 40
    }
    rm -rf "${smoke_dir}"
    container_exec rm -rf "${GIT_PERF_DIR}/test-results"
    log_message 'git perf runtime is ready inside the container'
}
