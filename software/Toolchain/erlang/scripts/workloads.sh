#!/usr/bin/env bash
# Command construction for the Erlang workload runners.

workload_invoke() {
    local scenario="$1" runner="$2" target="$3" scale="$4" label="$5"
    MEASURED_CMD=()
    case "${runner}" in
        erlang_workload)
            MEASURED_CMD=("${BENCH_BIN}" -noshell -pa "${BENCH_EBIN_DIR}" -run perf_bench main "${scenario}" "${scale}" "${label}")
            ;;
        *)
            log_message "ERROR: unsupported runner in ${BENCH_SCENARIOS_FILE}: ${runner}"
            return 50
            ;;
    esac
    return 0
}
