#!/usr/bin/env bash
# Stateless benchmark: verify the private ProtocolBench binary and its case matrix.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_fbthrift_runtime() {
    initialize_runtime || return 20
    if [[ ! -x "${PROTOCOL_BENCH_BIN}" ]]; then
        log_message "ERROR: private ProtocolBench is missing: ${PROTOCOL_BENCH_BIN}"
        return 20
    fi
    if [[ ! -s "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        log_message "ERROR: actual version file is missing: ${PERF_ACTUAL_VERSION_FILE}"
        return 20
    fi
    if pgrep -f -- "${PROTOCOL_BENCH_BIN}" >/dev/null 2>&1; then
        log_message "ERROR: a ProtocolBench process from another run is already active"
        return 20
    fi
    local listing="${RESULTS_DIR}/benchmark_listing.txt"
    if ! "${PROTOCOL_BENCH_BIN}" --benchmark_list_tests=true > "${listing}" 2>&1; then
        log_message "ERROR: ProtocolBench failed to list its benchmark cases"
        return 20
    fi
    local scenario group benchmark filter occurrences count=0
    while IFS=$'\t' read -r scenario group benchmark filter; do
        [[ -n "${scenario:-}" ]] || continue
        occurrences="$(grep -Fxc -- "${benchmark}" "${listing}" 2>/dev/null || true)"
        if [[ "${occurrences}" != "1" ]]; then
            log_message "ERROR: benchmark case ${benchmark} is listed ${occurrences:-0} times (expected 1)"
            return 20
        fi
        count=$((count + 1))
    done < "${SCENARIOS_FILE}"
    if (( count < 6 || count > 10 )); then
        log_message "ERROR: scenario matrix must declare 6..10 scenarios, found ${count}"
        return 20
    fi
    log_message "ProtocolBench is ready: $(head -n 1 "${PERF_ACTUAL_VERSION_FILE}"), ${count} scenarios"
}
