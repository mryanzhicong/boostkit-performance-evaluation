#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

# Start stage: the build products live inside this task's private container, so
# every readiness check runs through the container runtime.  No service is
# started; "start" means the measured workspace is complete and reproducible.
start_googletest_runtime() {
    initialize_runtime || return $?
    log_message "starting googletest runtime checks for ${GOOGLETEST_VERSION} on ${EXPECTED_ARCH}"

    check_googletest_container || return $?

    local scenario binary
    if ! googletest_container_exec test -x "${GOOGLETEST_UPSTREAM_BIN}"; then
        log_message "ERROR: upstream gtest_unittest binary is missing: ${GOOGLETEST_UPSTREAM_BIN}"
        log_message "run the build stage first"
        return 40
    fi
    if ! googletest_container_exec test -f "${SCRIPT_DIR}/scripts/run_timed.py"; then
        log_message "ERROR: timing wrapper is not visible inside the container: ${SCRIPT_DIR}/scripts/run_timed.py"
        return 40
    fi
    for scenario in "${GOOGLETEST_MATRIX_SCENARIOS[@]}"; do
        binary="${GOOGLETEST_MATRIX_BIN_DIR}/$(matrix_binary "${scenario}")" || return 40
        if ! googletest_container_exec test -x "${binary}"; then
            log_message "ERROR: assertion matrix binary is missing: ${binary}"
            return 40
        fi
        log_message "matrix ready: ${scenario} -> $(basename "${binary}")"
    done
    if ! googletest_container_exec python3 --version >/dev/null 2>&1; then
        log_message "ERROR: python3 is not available inside the private container"
        return 40
    fi
    if [[ ! -s "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        log_message "ERROR: actual version file is missing: ${PERF_ACTUAL_VERSION_FILE}"
        return 40
    fi
    mkdir -p "${RUNS_DIR}"
    log_message "googletest runtime ready: $(googletest_version_string)"
    log_message "container: ${GOOGLETEST_CONTAINER_NAME} (${GOOGLETEST_CONTAINER_IMAGE})"
    log_message "scenarios: ${GOOGLETEST_SCENARIOS[*]}"
    log_message "googletest runtime start completed"
    return 0
}
