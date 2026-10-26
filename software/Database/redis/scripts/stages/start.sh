#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_redis_instance() {
    local attempt cpu_set numa_node
    local -a dnf_options=()

    if [[ -e "${SERVICE_DIR}" ]]; then
        log_message "ERROR: Redis data directory already exists: ${SERVICE_DIR}"
        return 20
    fi
    if "${REDIS_CLI_BIN}" -h 127.0.0.1 -p "${REDIS_SERVICE_PORT}" PING 2>/dev/null | grep -qx PONG; then
        log_message "ERROR: port ${REDIS_SERVICE_PORT} already has a Redis service"
        return 20
    fi

    mkdir -p "${SERVICE_DIR}"
    read -r cpu_set numa_node < <(select_redis_cpu_set) || return 40
    if [[ -z "${cpu_set}" || -z "${numa_node}" ]]; then
        log_message "ERROR: NUMA node ${REDIS_NUMA_NODE} has fewer than two available CPUs"
        return 40
    fi
    if docker container inspect "${REDIS_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${REDIS_CONTAINER_NAME}"
        return 40
    fi
    log_message "starting 2U8G Redis container ${REDIS_CONTAINER_NAME}: CPUs ${cpu_set}, NUMA ${numa_node}, port ${REDIS_SERVICE_PORT}"
    docker run --detach --name "${REDIS_CONTAINER_NAME}" \
        --label "boostkit.redis.run-id=${PERF_RUN_ID}" \
        --cpus=2 --cpuset-cpus="${cpu_set}" --cpuset-mems="${numa_node}" \
        --memory=8g --network=host --user "$(id -u):$(id -g)" \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        "${REDIS_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if ! docker exec "${REDIS_CONTAINER_NAME}" "${REDIS_SERVER_BIN}" --version >/dev/null 2>&1; then
        log_message "installing missing Redis runtime library in ${REDIS_CONTAINER_NAME}"
        [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
        docker exec --user 0 "${REDIS_CONTAINER_NAME}" \
            dnf "${dnf_options[@]}" install -y libatomic || return 30
        docker exec "${REDIS_CONTAINER_NAME}" "${REDIS_SERVER_BIN}" --version >/dev/null 2>&1 || {
            log_message "ERROR: Redis binary cannot run in ${REDIS_CONTAINER_IMAGE}"
            return 40
        }
    fi
    if ! docker exec "${REDIS_CONTAINER_NAME}" "${REDIS_SERVER_BIN}" \
        --bind 127.0.0.1 \
        --protected-mode yes \
        --port "${REDIS_SERVICE_PORT}" \
        --dir "${SERVICE_DIR}" \
        --daemonize yes \
        --pidfile "${PID_FILE}" \
        --logfile "${LOG_FILE}"; then
        log_message "ERROR: Redis instance ${REDIS_INSTANCE_ID} failed to start; see ${LOG_FILE}"
        return 40
    fi

    for attempt in {1..60}; do
        if "${REDIS_CLI_BIN}" -h 127.0.0.1 -p "${REDIS_SERVICE_PORT}" PING 2>/dev/null | grep -qx PONG; then
            log_message "Redis instance ${REDIS_INSTANCE_ID} is ready on port ${REDIS_SERVICE_PORT}"
            return 0
        fi
        sleep 1
    done
    log_message "ERROR: Redis service did not become ready; see ${LOG_FILE}"
    return 40
}

start_redis_service() {
    local instance_id
    initialize_runtime || return $?
    if [[ ! -x "${REDIS_SERVER_BIN}" || ! -x "${REDIS_CLI_BIN}" ]]; then
        log_message "ERROR: Redis is not built; run the build stage first"
        return 40
    fi
    prepare_redis_container_image || return $?
    if [[ -e "${REDIS_INSTANCE_COUNT_FILE}" ]]; then
        log_message "ERROR: Redis instance count record already exists: ${REDIS_INSTANCE_COUNT_FILE}"
        return 20
    fi
    printf '%s\n' "${REDIS_INSTANCE_COUNT}" > "${REDIS_INSTANCE_COUNT_FILE}"
    for ((instance_id = 1; instance_id <= REDIS_INSTANCE_COUNT; instance_id++)); do
        configure_redis_instance "${instance_id}" || return $?
        start_redis_instance || return $?
    done
    configure_redis_instance 1
}
