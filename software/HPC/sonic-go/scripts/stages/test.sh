#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_sonic_go_benchmarks() {
    local raw_result

    initialize_runtime || return $?
    verify_go_toolchain || return $?
    if [[ ! -d "${SOURCE_DIR}" ]]; then
        log_message "ERROR: Sonic source directory is unavailable: ${SOURCE_DIR}"
        return 40
    fi

    raw_result="${RESULTS_DIR}/result-sonic-${TOOLCHAIN_TARGET}-base.json"
    log_message "running the sonic benchmark matrix with toolchain ${TOOLCHAIN_TARGET}"
    # sonic_bench.sh 自身退出码恒为 0；每个模式的真实成败记录在结果 JSON 的
    # runs[].exit_code / 顶层 exit_code 里，由 parse_sonic_bench.py 严格校验，
    # 任一模式失败都让本阶段返回非零。
    if ! (
        export WORKDIR="${PERF_WORK_DIR}"
        export OBJECTS="${OBJECTS_DIR}"
        export RESULTS="${RESULTS_DIR}"
        export SONIC_DIR="${SOURCE_DIR}"
        unset GOCACHE
        bash "${SCRIPT_DIR}/scripts/go/sonic_bench.sh" \
            --toolchain "${TOOLCHAIN_TARGET}" \
            --result "${raw_result}"
    ) 2>&1 | tee "${RESULTS_DIR}/benchmark_sonic_go.txt"; then
        log_message "ERROR: sonic benchmark run failed"
        return 50
    fi
    if [[ ! -s "${raw_result}" ]]; then
        log_message "ERROR: sonic benchmark produced no result JSON: ${raw_result}"
        return 50
    fi

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    if ! python3 "${SCRIPT_DIR}/scripts/results/parse_sonic_bench.py" \
        "${raw_result}" \
        "${RESULTS_DIR}/benchmark_sonic_go.json"; then
        log_message "ERROR: failed to normalize sonic benchmark results"
        return 50
    fi
    log_message "Sonic benchmark results written to benchmark_sonic_go.txt and benchmark_sonic_go.json"
}
