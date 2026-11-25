#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

write_private_configs() {
    mkdir -p "${ZK_CONF_DIR}" "${ZK_DATA_DIR}" "${ZK_LOG_DIR}" "${ZK_RESULT_DIR}"
    cat > "${ZK_CONF_DIR}/zoo.cfg" <<EOF
tickTime=2000
initLimit=10
syncLimit=5
dataDir=${ZK_DATA_DIR}
dataLogDir=${ZK_LOG_DIR}
clientPort=${ZK_CLIENT_PORT}
clientPortAddress=127.0.0.1
admin.enableServer=false
maxClientCnxns=0
minSessionTimeout=4000
maxSessionTimeout=60000
autopurge.snapRetainCount=10
autopurge.purgeInterval=6
4lw.commands.whitelist=mntr,ruok,stat,srvr,cons
EOF
}

wait_for_zookeeper() {
    local attempt output
    for attempt in {1..60}; do
        if output="$(zk_mntr)" && printf '%s\n' "${output}" | grep -q $'zk_server_state\tstandalone'; then
            printf '%s\n' "${output}" > "${ZK_RESULT_DIR}/mntr_start.txt"
            return 0
        fi
        sleep 1
    done
    log_error 'ZooKeeper did not become ready on 127.0.0.1:'"${ZK_CLIENT_PORT}"
    return 40
}

start_zookeeper_runtime() {
    initialize_runtime || return $?
    check_container || return $?
    [[ -x "${ZK_HOME}/bin/zkServer.sh" && -x "${ZK_JDK_HOME}/bin/java" ]] || {
        log_error 'ZooKeeper distribution or BiSheng JDK is missing'; return 40;
    }
    if zk_exec bash -c "echo > /dev/tcp/127.0.0.1/${ZK_CLIENT_PORT}" >/dev/null 2>&1; then
        log_error "task ZooKeeper port is already in use: ${ZK_CLIENT_PORT}"; return 40
    fi
    write_private_configs || return 40
    log_message "starting ZooKeeper 3.6.2 standalone at 127.0.0.1:${ZK_CLIENT_PORT}"
    docker exec \
        -e "HOME=${PERF_WORK_DIR}" \
        -e "TMPDIR=${PERF_WORK_DIR}/tmp" \
        -e "JAVA_HOME=${ZK_JDK_HOME}" \
        -e "PATH=${ZK_JDK_HOME}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
        -e "ZOO_LOG_DIR=${PERF_WORK_DIR}/logs" \
        -e "SERVER_JVMFLAGS=${ZK_JVM_FLAGS} -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:${PERF_WORK_DIR}/logs/zk_gc.log" \
        "${ZK_CONTAINER_NAME}" \
        "${ZK_HOME}/bin/zkServer.sh" --config "${ZK_CONF_DIR}" start || return 40
    wait_for_zookeeper || return $?
    log_message "ZooKeeper is ready: $(grep -c . "${ZK_RESULT_DIR}/mntr_start.txt") mntr lines collected"
}
