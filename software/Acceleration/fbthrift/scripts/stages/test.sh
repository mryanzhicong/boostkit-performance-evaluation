#!/usr/bin/env bash
# Run the pinned upstream ProtocolBench matrix: warmup, independent repetitions,
# raw logs, then strict parsing into benchmark_fbthrift.json.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_single_benchmark() {
    # $1 scenario id, $2 run label, $3 benchmark filter, $4 minimum time
    local scenario="$1" label="$2" filter="$3" min_time="$4"
    local run_dir="${RESULTS_DIR}/runs/${scenario}"
    local log="${run_dir}/${label}.log"
    local json="${run_dir}/${label}.json"
    local timing="${run_dir}/${label}.time"
    mkdir -p "${run_dir}"
    log_message "scenario ${scenario} ${label}: filter=${filter} min_time=${min_time} (in container)"
    # The measured process is spawned inside the private container from the shared
    # run directory; GNU time and ProtocolBench both live in the container, so the
    # RSS record and the JSON report are container-native artifacts.
    if ! fbthrift_container_exec_at "${run_dir}" \
            env LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}" \
            /usr/bin/time -v -o "${timing}" \
            "${PROTOCOL_BENCH_BIN}" \
            --benchmark_filter="${filter}" \
            --benchmark_min_time="${min_time}" \
            --benchmark_out_format=json \
            --benchmark_out="${json}" \
            > "${log}" 2>&1; then
        log_message "ERROR: ProtocolBench failed for ${scenario} ${label}"
        tail -n 20 "${log}" >&2 || true
        return 50
    fi
    if [[ ! -s "${json}" ]]; then
        log_message "ERROR: ProtocolBench produced no JSON for ${scenario} ${label}"
        return 50
    fi
    if [[ ! -s "${timing}" ]]; then
        log_message "ERROR: GNU time produced no RSS record for ${scenario} ${label}"
        return 50
    fi
    return 0
}

concatenate_raw_logs() {
    local raw="${RESULTS_DIR}/benchmark_raw.txt"
    local scenario group benchmark filter rep
    : > "${raw}" || return 50
    while IFS=$'\t' read -r scenario group benchmark filter; do
        [[ -n "${scenario:-}" ]] || continue
        for ((rep = 1; rep <= PERF_REPS; rep++)); do
            printf '===== scenario=%s group=%s benchmark=%s run=rep%d min_time=%s =====\n' \
                "${scenario}" "${group}" "${benchmark}" "${rep}" \
                "${PERF_BENCHMARK_MIN_TIME}" >> "${raw}"
            cat "${RESULTS_DIR}/runs/${scenario}/rep${rep}.log" >> "${raw}" || return 50
        done
    done < "${SCENARIOS_FILE}"
    [[ -s "${raw}" ]] || return 50
}

run_fbthrift_benchmarks() {
    initialize_runtime || return $?
    check_fbthrift_container || return $?
    fbthrift_container_exec test -x "${PROTOCOL_BENCH_BIN}" || {
        log_message "ERROR: private ProtocolBench is missing in the container: ${PROTOCOL_BENCH_BIN}"
        return 50
    }
    fbthrift_container_exec test -x /usr/bin/time || {
        log_message "ERROR: /usr/bin/time (GNU time) is required for peak RSS inside the container"
        return 50
    }
    local actual_version
    actual_version="$(head -n 1 "${PERF_ACTUAL_VERSION_FILE}" 2>/dev/null || true)"
    if [[ -z "${actual_version}" ]]; then
        log_message "ERROR: actual version file is empty: ${PERF_ACTUAL_VERSION_FILE}"
        return 50
    fi
    local runs_dir="${RESULTS_DIR}/runs"
    rm -rf -- "${runs_dir}"
    mkdir -p "${runs_dir}"
    log_message "warmup runs per scenario: ${PERF_WARMUP_RUNS}; measured repetitions: ${PERF_REPS}"

    local scenario group benchmark filter w rep
    for ((w = 1; w <= PERF_WARMUP_RUNS; w++)); do
        while IFS=$'\t' read -r scenario group benchmark filter; do
            [[ -n "${scenario:-}" ]] || continue
            run_single_benchmark "${scenario}" "warmup${w}" "${filter}" \
                "${PERF_WARMUP_MIN_TIME}" || return 50
        done < "${SCENARIOS_FILE}"
    done
    for ((rep = 1; rep <= PERF_REPS; rep++)); do
        while IFS=$'\t' read -r scenario group benchmark filter; do
            [[ -n "${scenario:-}" ]] || continue
            run_single_benchmark "${scenario}" "rep${rep}" "${filter}" \
                "${PERF_BENCHMARK_MIN_TIME}" || return 50
        done < "${SCENARIOS_FILE}"
    done

    concatenate_raw_logs || return 50
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        --runs-dir "${runs_dir}" \
        --cases-file "${SCENARIOS_FILE}" \
        --dependencies "${RESULTS_DIR}/dependencies.json" \
        --reps "${PERF_REPS}" \
        --warmups "${PERF_WARMUP_RUNS}" \
        --benchmark-min-time "${PERF_BENCHMARK_MIN_TIME}" \
        --warmup-min-time "${PERF_WARMUP_MIN_TIME}" \
        --actual-version "${actual_version}" \
        --architecture "$(normalize_architecture "${EXPECTED_ARCH}")" \
        --output "${RESULTS_DIR}/benchmark_fbthrift.json" || return 50
    log_message "benchmark results are ready: ${RESULTS_DIR}/benchmark_fbthrift.json"
}
