#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

write_private_configs() {
    mkdir -p "${CH_DATA}/data" "${CH_DATA}/tmp" "${CH_DATA}/user_files" "${CH_DATA}/access" "${CH_LOG_DIR}" "${CH_RESULT_DIR}"
    mkdir -p "$(dirname "${CH_CONF}")"
    cat > "${CH_CONF}" <<EOF
<clickhouse>
    <logger>
        <level>information</level>
        <log>${CH_LOG_DIR}/server.log</log>
        <errorlog>${CH_LOG_DIR}/server.err.log</errorlog>
        <size>100M</size>
        <count>2</count>
    </logger>
    <tcp_port>${CH_TCP_PORT}</tcp_port>
    <http_port>${CH_HTTP_PORT}</http_port>
    <listen_host>127.0.0.1</listen_host>
    <path>${CH_DATA}/data/</path>
    <tmp_path>${CH_DATA}/tmp/</tmp_path>
    <user_files_path>${CH_DATA}/user_files/</user_files_path>
    <users_config>users.xml</users_config>
    <max_server_memory_usage>${CH_MAX_SERVER_MEMORY_USAGE}</max_server_memory_usage>
    <mark_cache_size>${CH_MARK_CACHE_SIZE}</mark_cache_size>
    <max_concurrent_queries>100</max_concurrent_queries>
    <max_thread_pool_size>20000</max_thread_pool_size>
    <uncompressed_cache_size>0</uncompressed_cache_size>
    <mmap_cache_size>16384</mmap_cache_size>
    <mlock_executable>false</mlock_executable>
    <default_profile>default</default_profile>
    <default_database>default</default_database>
    <pid_file>${PERF_WORK_DIR}/clickhouse.pid</pid_file>
    <query_log>
        <database>system</database>
        <table>query_log</table>
        <flush_interval_milliseconds>7500</flush_interval_milliseconds>
    </query_log>
    <metric_log>
        <database>system</database>
        <table>metric_log</table>
    </metric_log>
    <user_directories>
        <users_xml><path>users.xml</path></users_xml>
        <local_directory><path>${CH_DATA}/access/</path></local_directory>
    </user_directories>
</clickhouse>
EOF
    cat > "${CH_USERS}" <<EOF
<clickhouse>
    <profiles>
        <default>
            <max_threads>${CH_MAX_THREADS}</max_threads>
            <max_memory_usage>${CH_MAX_MEMORY_USAGE}</max_memory_usage>
            <max_block_size>65536</max_block_size>
            <log_queries>1</log_queries>
            <log_query_threads>0</log_query_threads>
            <max_bytes_before_external_group_by>40000000000</max_bytes_before_external_group_by>
            <max_bytes_before_external_sort>40000000000</max_bytes_before_external_sort>
        </default>
    </profiles>
    <users>
        <default>
            <password></password>
            <networks>
                <ip>::/0</ip>
            </networks>
            <profile>default</profile>
            <quota>default</quota>
            <access_management>1</access_management>
        </default>
    </users>
    <quotas>
        <default></default>
    </quotas>
</clickhouse>
EOF
}

wait_for_clickhouse() {
    local attempt output
    for attempt in {1..120}; do
        if output="$(ch_exec "${CH_BIN}" client --host 127.0.0.1 --port "${CH_TCP_PORT}" \
                --query 'SELECT 1' 2>/dev/null)" && [[ "${output//[[:space:]]/}" == 1 ]]; then
            return 0
        fi
        sleep 1
    done
    log_error 'ClickHouse server did not become ready'
    return 40
}

start_clickhouse_runtime() {
    initialize_runtime || return $?
    check_container || return $?
    [[ -x "${CH_BIN}" ]] || { log_error 'ClickHouse binary is missing'; return 40; }
    if ch_exec bash -c "echo > /dev/tcp/127.0.0.1/${CH_TCP_PORT}" >/dev/null 2>&1; then
        log_error "task ClickHouse port is already in use: ${CH_TCP_PORT}"; return 40
    fi
    write_private_configs || return 40
    log_message "starting ClickHouse ${SOFTWARE_VERSION} at 127.0.0.1:${CH_TCP_PORT}"
    docker exec --detach -e "HOME=${PERF_WORK_DIR}" -e "TMPDIR=${PERF_WORK_DIR}/tmp" \
        "${CH_CONTAINER_NAME}" sh -c \
        "exec '${CH_BIN}' server --config-file='${CH_CONF}' >>'${CH_LOG_DIR}/stdout.log' 2>&1" || return 40
    wait_for_clickhouse || return $?
    {
        ch_exec "${CH_BIN}" client --host 127.0.0.1 --port "${CH_TCP_PORT}" \
            --query 'SELECT version(), timezone(), uptime()'
        ch_exec "${CH_BIN}" client --host 127.0.0.1 --port "${CH_TCP_PORT}" --query \
            "SELECT name, value FROM system.settings WHERE name IN ('max_threads','max_memory_usage','max_bytes_before_external_group_by')"
    } > "${CH_RESULT_DIR}/server_settings.txt" 2>&1 || return 40
    log_message 'ClickHouse is ready'
}
