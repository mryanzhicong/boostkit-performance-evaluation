#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# ---------------------------------------------------------------------------
# 阶段 3：test - 执行基准测试并聚合结果
# ---------------------------------------------------------------------------
run_oceanbase_benchmarks() {
    initialize_runtime || return $?
    if ! check_proxy_ready; then
        log_message "ERROR: OBProxy test tenant is not reachable on ${OB_HOST}:${OB_PROXY_PORT}"
        return 50
    fi
    if [[ ! -x "${SYSBENCH_BIN}" || ! -f "${SYSBENCH_LUA_DIR}/oltp_insert.lua" ]]; then
        log_message 'ERROR: private Sysbench 1.0.20 build is missing'
        return 50
    fi
    if ! proxy_mysql -e "CREATE DATABASE IF NOT EXISTS ${OB_DB}"; then
        log_message "ERROR: could not create benchmark database ${OB_DB} in test tenant"
        return 50
    fi
    log_message 'running selected Sysbench matrix through OBProxy: 4 workloads x 3 thread levels'
    python3 "${SCRIPT_DIR}/scripts/results/benchmark_ob.py" \
        --host "${OB_HOST}" --port "${OB_PROXY_PORT}" \
        --user "${OB_USER}" --database "${OB_DB}" \
        --results-dir "${RESULTS_DIR}" || {
        log_message 'ERROR: OceanBase Sysbench benchmark failed'
        return 50
    }
    log_message "Sysbench results written to ${RESULTS_DIR}"
}
