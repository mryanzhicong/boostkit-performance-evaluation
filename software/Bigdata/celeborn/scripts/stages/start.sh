#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

prepare_celeborn_hosts_alias() {
    # The document addresses the shuffle service as server1:9097.  Inside the
    # single-node container that name must resolve to the loopback address, so
    # the alias is asserted instead of silently switching to 127.0.0.1.
    celeborn_container_exec_root bash -lc \
        "grep -qE '^[0-9.:]+[[:space:]]+server1([[:space:]]|\$)' /etc/hosts || printf '127.0.0.1 server1\n' >> /etc/hosts" || {
        log_message 'ERROR: cannot add the server1 alias to /etc/hosts'; return 20;
    }
    celeborn_container_exec bash -lc 'getent hosts server1 >/dev/null' || {
        log_message 'ERROR: the server1 alias does not resolve inside the container'; return 20;
    }
}

write_celeborn_configuration() {
    local java_home="$1"
    mkdir -p "${CELEBORN_CONF_DIR}" "${CELEBORN_STORAGE_DIR_1}" "${CELEBORN_STORAGE_DIR_2}" \
        "${CELEBORN_HOME}/conf" || return 30
    cat > "${CELEBORN_HOME}/conf/celeborn-defaults.conf" <<EOF
celeborn.master.host=server1
celeborn.master.port=${CELEBORN_MASTER_PORT}
celeborn.master.endpoints=${CELEBORN_CLIENT_ENDPOINTS}
celeborn.master.http.port=${CELEBORN_MASTER_HTTP_PORT}
celeborn.worker.http.port=${CELEBORN_WORKER_HTTP_PORT}
celeborn.worker.storage.dirs=${CELEBORN_STORAGE_DIR_1},${CELEBORN_STORAGE_DIR_2}
celeborn.worker.memory=${CELEBORN_WORKER_OFFHEAP}
EOF
    cat > "${CELEBORN_HOME}/conf/celeborn-env.sh" <<EOF
export JAVA_HOME=${java_home}
export CELEBORN_LOG_DIR=${CELEBORN_LOG_DIR}
export CELEBORN_PID_DIR=${CELEBORN_PID_DIR}
export CELEBORN_LOCAL_IP=127.0.0.1
EOF
    cp -f "${CELEBORN_HOME}/conf/celeborn-env.sh" "${CELEBORN_CONF_DIR}/celeborn-env.sh" || return 30
    cp -f "${CELEBORN_HOME}/conf/celeborn-defaults.conf" "${CELEBORN_CONF_DIR}/celeborn-defaults.conf" || return 30
    rm -rf "${CELEBORN_LOG_DIR}" "${CELEBORN_PID_DIR}"
    mkdir -p "${CELEBORN_LOG_DIR}" "${CELEBORN_PID_DIR}" || return 30
}

wait_for_log() {
    local pattern="$1" timeout="$2" description="$3" waited=0
    while (( waited < timeout )); do
        if celeborn_container_exec bash -lc "grep -lq '${pattern}' '${CELEBORN_LOG_DIR}'/* 2>/dev/null"; then
            return 0
        fi
        sleep 3
        waited=$((waited + 3))
    done
    log_message "ERROR: ${description} did not become ready within ${timeout}s"
    return 20
}

celeborn_process_running() {
    local pattern="$1"
    celeborn_container_exec bash -lc "pgrep -f '${pattern}' >/dev/null"
}

check_celeborn_services() {
    celeborn_process_running 'org.apache.celeborn.service.deploy.master.Master' || {
        log_message 'ERROR: the Celeborn master process is not running'; return 20;
    }
    celeborn_process_running 'org.apache.celeborn.service.deploy.worker.Worker' || {
        log_message 'ERROR: the Celeborn worker process is not running'; return 20;
    }
    celeborn_container_exec bash -lc "grep -q 'Register worker successfully' '${CELEBORN_LOG_DIR}'/*worker* 2>/dev/null" || {
        log_message 'ERROR: the Celeborn worker is not registered with the master'; return 20;
    }
}

start_celeborn_runtime() {
    initialize_runtime || return $?
    check_celeborn_container || return 40
    local java_home driver_memory
    java_home="$(java_home_in_container)" || return 40
    [[ -n "${java_home}" ]] || { log_message 'ERROR: cannot locate the in-container JDK'; return 30; }
    driver_memory="$(spark_driver_memory)" || return 40
    prepare_celeborn_hosts_alias || return $?
    write_celeborn_configuration "${java_home}" || return $?

    log_message "starting Celeborn master on ${CELEBORN_CLIENT_ENDPOINTS} (${CELEBORN_MASTER_HEAP} heap)"
    celeborn_container_exec "${CELEBORN_HOME}/sbin/start-master.sh" \
        >"${RESULTS_DIR}/celeborn-master-start.log" 2>&1 || {
        log_message 'ERROR: Celeborn master failed to start'; return 20;
    }
    wait_for_log 'Master started' 180 'the Celeborn master' || return $?

    log_message "starting Celeborn worker (${CELEBORN_WORKER_HEAP} heap, ${CELEBORN_WORKER_OFFHEAP} off-heap)"
    celeborn_container_exec "${CELEBORN_HOME}/sbin/start-worker.sh" "${CELEBORN_MASTER_URL}" \
        >"${RESULTS_DIR}/celeborn-worker-start.log" 2>&1 || {
        log_message 'ERROR: Celeborn worker failed to start'; return 20;
    }
    wait_for_log 'Register worker successfully' 240 'the Celeborn worker registration' || return $?
    check_celeborn_services || return $?

    local device1 device2 statement_count
    device1="$(celeborn_container_exec stat -c '%d' "${CELEBORN_STORAGE_DIR_1}")"
    device2="$(celeborn_container_exec stat -c '%d' "${CELEBORN_STORAGE_DIR_2}")"
    statement_count="$(ls "${STATEMENT_DIR}"/query*.sql | wc -l)"
    python3 - "${RESULTS_DIR}/service-state.json" <<PY
import json
import sys

payload = {
    "celeborn": {
        "version": "${SOFTWARE_VERSION}",
        "master": {"endpoint": "${CELEBORN_CLIENT_ENDPOINTS}", "heap": "${CELEBORN_MASTER_HEAP}",
                   "http_port": ${CELEBORN_MASTER_HTTP_PORT}, "recorded": "Master started"},
        "worker": {"count": 1, "heap": "${CELEBORN_WORKER_HEAP}",
                   "off_heap": "${CELEBORN_WORKER_OFFHEAP}",
                   "http_port": ${CELEBORN_WORKER_HTTP_PORT},
                   "recorded": "Register worker successfully"},
        "storage_dirs": [
            {"path": "${CELEBORN_STORAGE_DIR_1}", "device_id": ${device1}},
            {"path": "${CELEBORN_STORAGE_DIR_2}", "device_id": ${device2}},
        ],
        "shuffle_manager": "${CELEBORN_SHUFFLE_MANAGER}",
        "client_jar": "${CELEBORN_CLIENT_JAR}",
    },
    "spark": {
        "version": "${SPARK_VERSION}",
        "master": "local[*]",
        "driver_memory": "${driver_memory}",
        "shuffle_partitions": ${CELEBORN_SHUFFLE_PARTITIONS},
    },
    "workload": {"scale_factor": ${CELEBORN_SCALE_FACTOR}, "statements": ${statement_count},
                 "tpcds_kit_commit": "${TPCDS_KIT_COMMIT}"},
    "java_home": "${java_home}",
}
with open(sys.argv[1], "w", encoding="utf-8") as handle:
    json.dump(payload, handle, indent=2, sort_keys=True)
    handle.write("\n")
PY
    log_message "Celeborn is serving shuffle on ${CELEBORN_CLIENT_ENDPOINTS} with one registered worker"
}
