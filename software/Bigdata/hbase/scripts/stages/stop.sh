#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_hbase_runtime() {
    initialize_runtime || return $?
    if ! docker container inspect "${CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "container ${CONTAINER_NAME} is already absent"
        return 0
    fi
    local label
    label="$(docker inspect --format '{{index .Config.Labels "boostkit.hbase.run-id"}}' "${CONTAINER_NAME}" 2>/dev/null)"
    [[ "${label}" == "${PERF_RUN_ID}" ]] || {
        log_error 'refusing to remove a container not owned by this task'; return 70;
    }
    if [[ "$(docker inspect --format '{{.State.Running}}' "${CONTAINER_NAME}" 2>/dev/null)" == true ]]; then
        hbase_exec "${HBASE_HOME}/bin/hbase-daemon.sh" stop regionserver >/dev/null 2>&1 || true
        hbase_exec "${HBASE_HOME}/bin/hbase-daemon.sh" stop master >/dev/null 2>&1 || true
        hbase_exec "${HADOOP_HOME}/bin/hdfs" --daemon stop datanode >/dev/null 2>&1 || true
        hbase_exec "${HADOOP_HOME}/bin/hdfs" --daemon stop namenode >/dev/null 2>&1 || true
        hbase_exec "${ZK_HOME}/bin/zkServer.sh" --config "${HBASE_CONF_DIR}" stop >/dev/null 2>&1 || true
    fi
    if [[ -d "${HBASE_LOG_DIR}" ]] && find "${HBASE_LOG_DIR}" -type f -print -quit | grep -q .; then
        mkdir -p "${RESULTS_DIR}/service-logs"
        cp -a "${HBASE_LOG_DIR}/." "${RESULTS_DIR}/service-logs/" || true
    fi
    docker stop --time 60 "${CONTAINER_NAME}" >/dev/null || return 70
    docker rm "${CONTAINER_NAME}" >/dev/null || return 70
    log_message "removed private HBase container ${CONTAINER_NAME}"
}
