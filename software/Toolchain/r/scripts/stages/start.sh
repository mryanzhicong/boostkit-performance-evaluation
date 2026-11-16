#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Start stage: verify the built R runtime and the workload matrix inside the
# private container, because that is where the measured processes will run.
start_r_runtime() {
    initialize_runtime || return $?
    check_r_container || return $?
    if ! r_container_exec test -x "${BENCH_BIN}"; then
        log_message "ERROR: built runtime is missing inside the private container: ${BENCH_BIN}"
        return 40
    fi
    if [[ ! -f "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        log_message "ERROR: actual version file is missing: ${PERF_ACTUAL_VERSION_FILE}"
        return 40
    fi
    local actual
    actual="$(cat "${PERF_ACTUAL_VERSION_FILE}")"
    if [[ "${actual}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: actual version file reports ${actual}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    if [[ ! -f "${BENCH_SCENARIOS_FILE}" ]]; then
        log_message "ERROR: workload matrix manifest is missing: ${BENCH_SCENARIOS_FILE}"
        return 40
    fi
    if ! r_container_exec test -x /usr/bin/time; then
        log_message "ERROR: the private container has no GNU time at /usr/bin/time"
        return 40
    fi
    local missing=0
    local scenario dimension runner target scale check expected tolerance workload
    while IFS='|' read -r scenario dimension runner target scale check expected tolerance workload; do
        [[ -z "${scenario}" || "${scenario}" == \#* ]] && continue
        [[ "${scenario}" == "scenario" ]] && continue
        if [[ -f "${SCRIPT_DIR}/benchmarks/${target}" ]]; then
            :
        else
            log_message "ERROR: benchmark workload is missing: benchmarks/${target}"
            missing=1
        fi
    done < "${BENCH_SCENARIOS_FILE}"
    if [[ "${missing}" -ne 0 ]]; then
        return 40
    fi
    local r_version
    r_version="$(r_container_exec "${BENCH_R_BIN}" --version 2>&1 | head -1 || true)"
    log_message "runtime check passed inside the private container: ${actual} (${r_version})"
    return 0
}
