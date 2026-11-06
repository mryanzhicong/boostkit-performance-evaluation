#!/usr/bin/env bash
# Start stage: verify the built Perl runtime and the committed workload matrix
# inside this task's private container.  No long-running service is created;
# "start" means "the measured workload is ready and reproducible".
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_perl_runtime() {
    initialize_runtime || return $?
    check_perl_container || return $?
    perl_container_exec test -x "${BENCH_BIN}" || {
        log_message "ERROR: built runtime is missing inside the container: ${BENCH_BIN}"
        return 30
    }
    [[ -f "${PERF_ACTUAL_VERSION_FILE}" ]] || {
        log_message "ERROR: actual version file is missing: ${PERF_ACTUAL_VERSION_FILE}"
        return 30
    }
    local actual
    actual="$(cat "${PERF_ACTUAL_VERSION_FILE}")"
    [[ "${actual}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: actual version file reports ${actual}, expected ${SOFTWARE_VERSION}"
        return 30
    }
    local reported
    reported="$(perl_container_exec "${BENCH_BIN}" -e 'print $^V' 2>/dev/null | sed 's/^v//')" || reported=""
    [[ "${reported}" == "${actual}" ]] || {
        log_message "ERROR: the container runtime reports perl ${reported}, staged version file says ${actual}"
        return 30
    }
    [[ -f "${BENCH_SCENARIOS_FILE}" ]] || {
        log_message "ERROR: workload matrix manifest is missing: ${BENCH_SCENARIOS_FILE}"
        return 30
    }
    local missing=0
    local scenario dimension runner target scale check expected tolerance workload
    while IFS='|' read -r scenario dimension runner target scale check expected tolerance workload; do
        [[ -z "${scenario}" || "${scenario}" == \#* ]] && continue
        [[ "${scenario}" == "scenario" ]] && continue
        if ! perl_container_exec test -f "${SCRIPT_DIR}/benchmarks/${target}"; then
            log_message "ERROR: benchmark workload is missing inside the container: benchmarks/${target}"
            missing=1
        fi
    done < "${BENCH_SCENARIOS_FILE}"
    [[ "${missing}" -eq 0 ]] || return 30
    log_message "runtime check passed inside ${PERL_CONTAINER_NAME}: perl ${reported}"
}
