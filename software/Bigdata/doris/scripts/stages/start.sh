#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

write_private_configs() {
    mkdir -p "${DORIS_DATA}/storage" "${DORIS_DATA}/meta" "${DORIS_LOG_DIR}" "${DORIS_RESULT_DIR}"
    cat > "${DORIS_FE}/conf/fe.conf" <<EOF
priority_networks = 127.0.0.1/32
query_port = ${DORIS_QUERY_PORT}
http_port = ${DORIS_HTTP_PORT}
rpc_port = ${DORIS_RPC_PORT}
edit_log_port = ${DORIS_EDIT_LOG_PORT}
meta_dir = ${DORIS_DATA}/meta
JAVA_OPTS = ${DORIS_FE_HEAP}
sys_log_level = INFO
EOF
    cat > "${DORIS_BE}/conf/be.conf" <<EOF
priority_networks = 127.0.0.1/32
be_port = ${DORIS_BE_PORT}
webserver_port = ${DORIS_WEBSERVER_PORT}
heartbeat_service_port = ${DORIS_HEARTBEAT_PORT}
brpc_port = ${DORIS_BRPC_PORT}
storage_root_path = ${DORIS_DATA}/storage
mem_limit = 90%
storage_flood_stage_left_capacity_bytes = 10737418240
EOF
}

doris_client() {
    doris_exec python3 "${PERF_WORK_DIR}/tools/doris_client.py" "$@"
}

start_doris_runtime() {
    initialize_runtime || return $?
    check_container || return $?
    [[ -x "${DORIS_FE}/bin/start_fe.sh" && -x "${DORIS_BE}/bin/start_be.sh" ]] || {
        log_error 'Doris FE/BE start scripts are missing'; return 40;
    }
    local port
    for port in "${DORIS_QUERY_PORT}" "${DORIS_HTTP_PORT}" "${DORIS_BE_PORT}" "${DORIS_WEBSERVER_PORT}"; do
        if doris_exec bash -c "echo > /dev/tcp/127.0.0.1/${port}" >/dev/null 2>&1; then
            log_error "task Doris port is already in use: ${port}"; return 40
        fi
    done
    write_private_configs || return 40

    log_message "starting Doris FE at 127.0.0.1:${DORIS_QUERY_PORT}"
    doris_exec bash -c "cd '${DORIS_FE}' && bin/start_fe.sh --daemon" || return 40
    doris_client wait-fe --port "${DORIS_QUERY_PORT}" --timeout 180 || {
        log_error 'Doris FE did not become ready'; return 40;
    }

    log_message "starting Doris BE at 127.0.0.1:${DORIS_BE_PORT}"
    doris_exec bash -c "cd '${DORIS_BE}' && bin/start_be.sh --daemon" || return 40
    doris_client add-backend --port "${DORIS_QUERY_PORT}" \
        --host 127.0.0.1 --heartbeat-port "${DORIS_HEARTBEAT_PORT}" || {
        log_error 'failed to register the Doris BE'; return 40;
    }
    doris_client wait-backend --port "${DORIS_QUERY_PORT}" --timeout 180 || {
        log_error 'Doris BE did not become alive'; return 40;
    }

    doris_client query --port "${DORIS_QUERY_PORT}" --sql 'SHOW FRONTENDS' \
        > "${DORIS_RESULT_DIR}/show_frontends.tsv" 2>&1 || return 40
    doris_client query --port "${DORIS_QUERY_PORT}" --sql 'SHOW BACKENDS' \
        > "${DORIS_RESULT_DIR}/show_backends.tsv" 2>&1 || return 40
    log_message 'Doris FE and BE are ready'
}
