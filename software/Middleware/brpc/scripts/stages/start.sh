#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_brpc_service() {
    local server_pid attempt

    initialize_runtime || return $?
    [[ -x "${RDMA_SERVER_BIN}" ]] || {
        log_message "ERROR: official performance server is unavailable: ${RDMA_SERVER_BIN}"
        return 40
    }
    [[ -e "${SERVICE_DIR}" ]] || mkdir -p "${SERVICE_DIR}"
    if process_is_alive "$(read_pid_file "${SERVER_PID_FILE}")"; then
        log_message "official performance server is already running"
        return 0
    fi
    port_is_free "${RDMA_SERVER_PORT}" || {
        log_message "ERROR: port ${RDMA_SERVER_PORT} is already in use"
        return 20
    }
    log_message "starting original performance server on port ${RDMA_SERVER_PORT} (TCP)"
    nohup "${RDMA_SERVER_BIN}" \
        --use_rdma=false \
        --port="${RDMA_SERVER_PORT}" \
        --bthread_concurrency=32 \
        >"${SERVER_LOG_FILE}" 2>&1 &
    server_pid=$!
    printf '%s\n' "${server_pid}" > "${SERVER_PID_FILE}"
    for ((attempt = 0; attempt < 60; attempt += 1)); do
        if ! process_is_alive "${server_pid}"; then
            break
        fi
        if curl --noproxy '*' -fsS --max-time 1 -o /dev/null \
            "http://127.0.0.1:${RDMA_SERVER_PORT}/status" 2>/dev/null; then
            break
        fi
        sleep 1
    done
    if ! process_is_alive "${server_pid}" ||
       ! curl --noproxy '*' -fsS --max-time 2 -o /dev/null \
           "http://127.0.0.1:${RDMA_SERVER_PORT}/status"; then
        terminate_process_gracefully "${server_pid}" "official performance server" || true
        log_message "ERROR: official performance server did not become ready; see ${SERVER_LOG_FILE}"
        return 40
    fi
    log_message "official performance server is ready (pid ${server_pid})"
}
