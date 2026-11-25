#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_doris_runtime() {
    initialize_runtime || return $?
    if ! docker container inspect "${DORIS_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "container ${DORIS_CONTAINER_NAME} is already absent"
        return 0
    fi
    local label
    label="$(docker inspect --format '{{index .Config.Labels "boostkit.doris.run-id"}}' "${DORIS_CONTAINER_NAME}" 2>/dev/null)"
    [[ "${label}" == "${PERF_RUN_ID}" ]] || {
        log_error 'refusing to remove a container not owned by this task'; return 70;
    }
    if [[ "$(docker inspect --format '{{.State.Running}}' "${DORIS_CONTAINER_NAME}" 2>/dev/null)" == true ]]; then
        # pkill -f also matches the wrapping shell command, so use the exact
        # BE process name and an anchored FE class name.
        doris_exec bash -c 'pkill -9 -x doris_be || true'
        doris_exec bash -c "pkill -9 -f 'org.apache.doris.DorisFE$' || true"
        sleep 8
    fi
    if [[ -d "${DORIS_LOG_DIR}" ]] && find "${DORIS_LOG_DIR}" -type f -print -quit | grep -q .; then
        mkdir -p "${RESULTS_DIR}/service-logs"
        cp -a "${DORIS_LOG_DIR}/." "${RESULTS_DIR}/service-logs/" || true
    fi
    if [[ -d "${DORIS_FE}/log" ]]; then
        mkdir -p "${RESULTS_DIR}/fe-logs"
        cp -a "${DORIS_FE}/log/." "${RESULTS_DIR}/fe-logs/" 2>/dev/null || true
    fi
    if [[ -d "${DORIS_BE}/log" ]]; then
        mkdir -p "${RESULTS_DIR}/be-logs"
        cp -a "${DORIS_BE}/log/." "${RESULTS_DIR}/be-logs/" 2>/dev/null || true
    fi
    docker stop --time 30 "${DORIS_CONTAINER_NAME}" >/dev/null || return 70
    docker rm "${DORIS_CONTAINER_NAME}" >/dev/null || return 70
    log_message "removed private Doris container ${DORIS_CONTAINER_NAME}"
}
