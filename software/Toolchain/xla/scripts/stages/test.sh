#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Reuse the staging and official-harness helpers from the start stage; the
# test stage runs the same workload definitions, only with the formal repeat
# count.
source "${SCRIPT_DIR}/scripts/stages/start.sh"

verify_benchmark_result() {
    local results_json="$1" benchmark_name="$2"
    jq -e --arg name "${benchmark_name}" \
        '.benchmark_name == $name and .run_status == "SUCCESS" and
         (.metrics.CPU_TIME.value > 0) and (.metrics.WALL_TIME.value > 0) and
         (.metrics.CPU_TIME.unit == "ms") and (.metrics.WALL_TIME.unit == "ms")' \
        "${results_json}" >/dev/null || {
        log_message "ERROR: benchmark result is not a successful CPU measurement: ${results_json}"
        return 50
    }
}

run_xla_benchmarks() {
    local raw_output benchmark_name hlo_name benchmark_runs_dir work_dir
    initialize_runtime || return $?
    [[ -x "${HLO_RUNNER_BIN}" && -x "${XSPACE_STATS_BIN}" ]] || {
        log_message 'ERROR: XLA benchmark harness is missing; build stage did not complete'
        return 40
    }
    stage_benchmark_workloads || return $?

    raw_output="${RESULTS_DIR}/hlo_benchmark_raw.log"
    benchmark_runs_dir="${RESULTS_DIR}/benchmark_runs"
    rm -rf "${benchmark_runs_dir}"
    mkdir -p "${benchmark_runs_dir}"
    log_message "running the official XLA CPU registry entries with ${XLA_NUM_REPEATS} repeats"

    if ! (
        for benchmark_name in "${XLA_GEMMA3_BENCHMARK}" "${XLA_GEMMA2_BENCHMARK}" "${XLA_GEMMA4_BENCHMARK}"; do
            case "${benchmark_name}" in
                "${XLA_GEMMA3_BENCHMARK}") hlo_name="${XLA_GEMMA3_HLO_NAME}" ;;
                "${XLA_GEMMA2_BENCHMARK}") hlo_name="${XLA_GEMMA2_HLO_NAME}" ;;
                "${XLA_GEMMA4_BENCHMARK}") hlo_name="${XLA_GEMMA4_HLO_NAME}" ;;
            esac
            work_dir="${PERF_WORK_DIR}/bench-${benchmark_name}"
            rm -rf "${work_dir}"
            run_official_benchmark "${benchmark_name}" \
                "${BENCHMARK_DIR}/${hlo_name}" "${XLA_NUM_REPEATS}" "${work_dir}" || exit 50
            verify_benchmark_result "${work_dir}/results.json" "${benchmark_name}" || exit 50
            mkdir -p "${benchmark_runs_dir}/${benchmark_name}"
            cp "${work_dir}/results.json" "${benchmark_runs_dir}/${benchmark_name}/results.json" || exit 50
            cp "${work_dir}/runner_stdout.txt" "${benchmark_runs_dir}/${benchmark_name}/runner_stdout.txt" || exit 50
            rm -rf "${work_dir}"
            log_message "benchmark ${benchmark_name} completed"
        done
    ) 2>&1 | tee "${raw_output}"; then
        log_message 'ERROR: the official XLA benchmark suite failed'
        return 50
    fi

    python3 "${CASE_DIR}/scripts/results/collect_xla_benchmark.py" \
        "${benchmark_runs_dir}" "${RESULTS_DIR}/benchmark_xla.json" \
        "${SOFTWARE_VERSION}" "${EXPECTED_ARCH}" "${XLA_NUM_REPEATS}" || {
        log_message 'ERROR: XLA result collection failed'
        return 50
    }
    log_message 'official XLA benchmark suite completed'
}
