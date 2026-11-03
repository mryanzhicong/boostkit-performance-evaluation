#!/usr/bin/env bash
# Start stage: verify inside the private openEuler container that the built Ruby
# interpreter, the actual-version record and every workload script of the matrix
# are ready.  Ruby is measured as a CLI interpreter, so there is no service to
# start.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_ruby_runtime() {
    initialize_runtime || return $?
    check_ruby_container || return $?
    ruby_container_exec test -x "${BENCH_BIN}" || {
        log_message "ERROR: built runtime is missing in the container: ${BENCH_BIN}"
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
    [[ -f "${BENCH_SCENARIOS_FILE}" ]] || {
        log_message "ERROR: workload matrix manifest is missing: ${BENCH_SCENARIOS_FILE}"
        return 30
    }
    ruby_container_exec "${BENCH_BIN}" -rbenchmark -e 'print "Benchmark module loadable\n"' >/dev/null 2>&1 || {
        log_message "ERROR: the built ruby cannot load the stdlib Benchmark module inside the container"
        return 30
    }
    local missing=0
    local scenario dimension runner target scale check expected tolerance workload
    while IFS='|' read -r scenario dimension runner target scale check expected tolerance workload; do
        [[ -z "${scenario}" || "${scenario}" == \#* ]] && continue
        [[ "${scenario}" == "scenario" ]] && continue
        if ruby_container_exec test -f "${SCRIPT_DIR}/benchmarks/${target}"; then
            :
        else
            log_message "ERROR: benchmark workload is missing in the container: benchmarks/${target}"
            missing=1
        fi
    done < "${BENCH_SCENARIOS_FILE}"
    [[ "${missing}" -eq 0 ]] || return 30
    log_message "runtime check passed inside the private container: ${actual}"
}
