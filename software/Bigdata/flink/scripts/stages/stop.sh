#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_flink_runtime() {
    local pid cmdline
    initialize_runtime || return $?
    if [[ -s "${PERF_WORK_DIR}/java-home.txt" ]]; then
        load_java || log_message 'WARN: private JDK unavailable during cleanup'
    fi
    if [[ -d "${FLINK_HOME}/log" ]]; then
        mkdir -p "${RESULTS_DIR}/flink-logs"
        cp -a "${FLINK_HOME}/log/." "${RESULTS_DIR}/flink-logs/" || true
    fi
    if [[ -d "${NEXMARK_HOME}/log" ]]; then
        mkdir -p "${RESULTS_DIR}/nexmark-logs"
        cp -a "${NEXMARK_HOME}/log/." "${RESULTS_DIR}/nexmark-logs/" || true
    fi
    if [[ -s "${PERF_WORK_DIR}/metric-client.pid" ]]; then
        pid="$(< "${PERF_WORK_DIR}/metric-client.pid")"
        if [[ "${pid}" =~ ^[0-9]+$ ]] && [[ -r "/proc/${pid}/cmdline" ]]; then
            cmdline="$(tr '\0' ' ' < "/proc/${pid}/cmdline")"
            if [[ "${cmdline}" == *"com.github.nexmark.flink.metric.cpu.CpuMetricSender"* &&
                  "${cmdline}" == *"${NEXMARK_HOME}"* ]]; then
                kill "${pid}" 2>/dev/null || true
            fi
        fi
    fi
    if [[ -x "${FLINK_HOME}/bin/taskmanager.sh" ]]; then
        log_message 'stopping only the private Flink daemons for this task'
        FLINK_PID_DIR="${PERF_WORK_DIR}/pids/tm2" "${FLINK_HOME}/bin/taskmanager.sh" stop || true
        "${FLINK_HOME}/bin/stop-cluster.sh" || true
    fi
}
