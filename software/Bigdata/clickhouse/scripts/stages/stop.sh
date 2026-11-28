#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_clickhouse_runtime() {
    initialize_runtime || return $?
    if ! docker container inspect "${CH_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "container ${CH_CONTAINER_NAME} is already absent"
        return 0
    fi
    local label
    label="$(docker inspect --format '{{index .Config.Labels "boostkit.clickhouse.run-id"}}' "${CH_CONTAINER_NAME}" 2>/dev/null)"
    [[ "${label}" == "${PERF_RUN_ID}" ]] || {
        log_error 'refusing to remove a container not owned by this task'; return 70;
    }
    if [[ "$(docker inspect --format '{{.State.Running}}' "${CH_CONTAINER_NAME}" 2>/dev/null)" == true ]]; then
        ch_exec "${CH_BIN}" client --host 127.0.0.1 --port "${CH_TCP_PORT}" \
            --query 'SYSTEM SHUTDOWN' >/dev/null 2>&1 || true
    fi
    if [[ -d "${CH_LOG_DIR}" ]] && find "${CH_LOG_DIR}" -type f -print -quit | grep -q .; then
        mkdir -p "${RESULTS_DIR}/service-logs"
        cp -a "${CH_LOG_DIR}/." "${RESULTS_DIR}/service-logs/" || true
    fi
    docker stop --time 30 "${CH_CONTAINER_NAME}" >/dev/null || return 70
    docker rm "${CH_CONTAINER_NAME}" >/dev/null || return 70
    log_message "removed private ClickHouse container ${CH_CONTAINER_NAME}"
}
