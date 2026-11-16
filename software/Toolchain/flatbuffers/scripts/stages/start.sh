#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

start_flatbuffers_runtime() {
    initialize_runtime || return $?
    check_flatbuffers_container || return $?
    log_message "starting flatbuffers runtime checks for ${FLATBUFFERS_VERSION} on ${EXPECTED_ARCH} inside the private container"
    local required=(
        "${FLATBUFFERS_FLATC}"
        "${FLATBUFFERS_DRIVER_BIN}"
        "${FLATBUFFERS_UPSTREAM_BIN}"
        "${SCRIPT_DIR}/scripts/run_timed.py"
    )
    local path
    for path in "${required[@]}"; do
        if ! flatbuffers_container_exec test -e "${path}"; then
            log_message "ERROR: required artifact is missing: ${path}"
            log_message "run the build stage first"
            return 40
        fi
    done
    local header
    for header in \
        "${FLATBUFFERS_GEN_DIR}/benchmarks/cpp/flatbuffers/bench_generated.h" \
        "${FLATBUFFERS_GEN_DIR}/driver/driver_generated.h"; do
        if ! flatbuffers_container_exec test -s "${header}"; then
            log_message "ERROR: generated header is missing: ${header}"
            return 40
        fi
    done
    mkdir -p "${RUNS_DIR}"
    local reported
    reported="$(flatbuffers_version_string)"
    log_message "flatbuffers runtime ready: ${reported}"
    log_message "scenarios: ${FLATBUFFERS_SCENARIOS[*]}"
    log_message "flatbuffers runtime start completed"
    return 0
}
