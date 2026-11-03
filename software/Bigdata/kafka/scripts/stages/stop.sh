#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_kafka_runtime() {
    initialize_runtime || return $?
    if ! docker container inspect "${KAFKA_CONTAINER_NAME}" >/dev/null 2>&1; then
        return 0
    fi
    local label
    label="$(docker inspect --format '{{index .Config.Labels "boostkit.kafka.run-id"}}' "${KAFKA_CONTAINER_NAME}" 2>/dev/null)"
    [[ "${label}" == "${PERF_RUN_ID}" ]] || {
        log_message 'ERROR: refusing to remove a container not owned by this task'; return 70;
    }
    if [[ "$(docker inspect --format '{{.State.Running}}' "${KAFKA_CONTAINER_NAME}" 2>/dev/null)" == true ]]; then
        kafka_exec "${KAFKA_HOME}/bin/kafka-server-stop.sh" >/dev/null 2>&1 || true
        kafka_exec "${ZOOKEEPER_HOME}/bin/zkServer.sh" stop "${PERF_WORK_DIR}/conf/zookeeper.properties" >/dev/null 2>&1 || true
    fi
    if [[ -d "${PERF_WORK_DIR}/logs" ]] && find "${PERF_WORK_DIR}/logs" -type f -print -quit | grep -q .; then
        mkdir -p "${RESULTS_DIR}/service-logs"
        cp -a "${PERF_WORK_DIR}/logs/." "${RESULTS_DIR}/service-logs/" || true
    fi
    docker stop --time 30 "${KAFKA_CONTAINER_NAME}" >/dev/null || return 70
    docker rm "${KAFKA_CONTAINER_NAME}" >/dev/null || return 70
    log_message "removed private Kafka container ${KAFKA_CONTAINER_NAME}"
}
