#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_folly_benchmarks() {
    initialize_runtime || return $?
    [[ -s "${SERVICE_DIR}/port" && -x "${CLIENT_BINARY}" ]] || return 50
    python3 "${SCRIPT_DIR}/scripts/results/run_acclib.py" \
        "${ACCLIB_SOURCE_ROOT}/fb_folly_autobuild/run.py" \
        "${CLIENT_BINARY}" "$(< "${SERVICE_DIR}/port")" \
        "${RESULTS_DIR}/benchmark_folly.json" "${RESULTS_DIR}/press_client_raw" \
        "${SOFTWARE_VERSION}" "$(normalize_architecture "${EXPECTED_ARCH}")" || {
        log_message 'ERROR: AccLibBenchmark matrix failed'
        return 50
    }
}
