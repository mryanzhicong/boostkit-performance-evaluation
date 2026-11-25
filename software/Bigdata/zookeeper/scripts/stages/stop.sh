#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_zookeeper_runtime() {
    initialize_runtime || return $?
    if ! docker container inspect "${ZK_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "container ${ZK_CONTAINER_NAME} is already absent"
        return 0
    fi
    local label
    label="$(docker inspect --format '{{index .Config.Labels "boostkit.zookeeper.run-id"}}' "${ZK_CONTAINER_NAME}" 2>/dev/null)"
    [[ "${label}" == "${PERF_RUN_ID}" ]] || {
        log_error 'refusing to remove a container not owned by this task'; return 70;
    }
    if [[ "$(docker inspect --format '{{.State.Running}}' "${ZK_CONTAINER_NAME}" 2>/dev/null)" == true ]]; then
        zk_exec "${ZK_HOME}/bin/zkServer.sh" --config "${ZK_CONF_DIR}" stop >/dev/null 2>&1 || true
    fi
    if [[ -d "${PERF_WORK_DIR}/logs" ]] && find "${PERF_WORK_DIR}/logs" -type f -print -quit | grep -q .; then
        mkdir -p "${RESULTS_DIR}/service-logs"
        cp -a "${PERF_WORK_DIR}/logs/." "${RESULTS_DIR}/service-logs/" || true
    fi
    if [[ -d "${ZK_LOG_DIR}" ]]; then
        mkdir -p "${RESULTS_DIR}/server-logs"
        cp -a "${ZK_LOG_DIR}/." "${RESULTS_DIR}/server-logs/" 2>/dev/null || true
    fi
    docker stop --time 30 "${ZK_CONTAINER_NAME}" >/dev/null || return 70
    docker rm "${ZK_CONTAINER_NAME}" >/dev/null || return 70
    log_message "removed private ZooKeeper container ${ZK_CONTAINER_NAME}"
}
