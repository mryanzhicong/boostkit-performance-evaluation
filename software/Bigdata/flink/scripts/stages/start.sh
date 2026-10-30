#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

wait_for_cluster() {
    local expected_slots="$1" status slots
    for ((attempt = 1; attempt <= 60; attempt++)); do
        status="$(curl --noproxy '*' -fsS --max-time 3 "http://127.0.0.1:${FLINK_REST_PORT}/overview" 2>/dev/null || true)"
        if [[ -n "${status}" ]]; then
            slots="$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("slots-total",0))' <<< "${status}" 2>/dev/null || true)"
            if [[ "${slots}" =~ ^[0-9]+$ ]] && (( slots >= expected_slots )); then
                log_message "standalone cluster ready: ${slots} slots"
                return 0
            fi
        fi
        sleep 2
    done
    log_message "ERROR: Flink did not register ${expected_slots} slots on ${FLINK_REST_PORT}"
    return 40
}

start_flink_runtime() {
    initialize_runtime || return $?
    load_java || return $?
    [[ -s "${NEXMARK_HOME}/lib/nexmark-flink-0.3-SNAPSHOT.jar" ]] || return 40
    python3 - "${FLINK_REST_PORT}" "${FLINK_RPC_PORT}" "${NEXMARK_METRIC_PORT}" <<'PY' || return 40
import socket
import sys
for port in map(int, sys.argv[1:]):
    with socket.socket() as sock:
        try:
            sock.bind(("127.0.0.1", port))
        except OSError as exc:
            raise SystemExit(f"task port {port} is already occupied: {exc}")
PY
    log_message 'starting private standalone Flink session (1 JM + 2 TM)'
    "${FLINK_HOME}/bin/start-cluster.sh" || return 40
    wait_for_cluster 8 || return $?
    FLINK_PID_DIR="${PERF_WORK_DIR}/pids/tm2" "${FLINK_HOME}/bin/taskmanager.sh" start || return 40
    wait_for_cluster 16 || return $?

    log_message 'starting Nexmark CPU metric sender'
    "${JAVA_HOME}/bin/java" \
        "-Dlog.file=${NEXMARK_HOME}/log/metric-client.log" \
        "-Dlog4j.configuration=file:${NEXMARK_HOME}/conf/log4j.properties" \
        "-Dlog4j.configurationFile=file:${NEXMARK_HOME}/conf/log4j.properties" \
        -cp "${NEXMARK_HOME}/lib/*:${FLINK_HOME}/lib/*" \
        com.github.nexmark.flink.metric.cpu.CpuMetricSender \
        > "${NEXMARK_HOME}/log/metric-client-console.log" 2>&1 &
    echo "$!" > "${PERF_WORK_DIR}/metric-client.pid"
    sleep 3
    kill -0 "$(< "${PERF_WORK_DIR}/metric-client.pid")" 2>/dev/null || {
        log_message 'ERROR: Nexmark CPU metric sender exited'; return 40;
    }
    log_message 'generating q13 side input in the private Flink directory'
    "${JAVA_HOME}/bin/java" -cp "${NEXMARK_HOME}/lib/*:${FLINK_HOME}/lib/*" \
        com.github.nexmark.flink.generator.SideInputGenerator \
        --num 10000 --path "${FLINK_HOME}/data/side_input.txt" || return 40
    [[ -s "${FLINK_HOME}/data/side_input.txt" ]] || return 40
}
