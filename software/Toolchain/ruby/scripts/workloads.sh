#!/usr/bin/env bash
# Command construction for the Ruby workload runners.

workload_invoke() {
    local scenario="$1" runner="$2" target="$3" scale="$4" label="$5"
    MEASURED_CMD=()
    case "${runner}" in
        ruby_script)
            MEASURED_CMD=("${BENCH_BIN}" "${SCRIPT_DIR}/benchmarks/${target}" "${scenario}" "${scale}" "${label}")
            ;;
        *)
            log_message "ERROR: unsupported runner in ${BENCH_SCENARIOS_FILE}: ${runner}"
            return 50
            ;;
    esac
    return 0
}
