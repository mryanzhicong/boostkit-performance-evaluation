#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_mysql_instance() {
    local -a user_options=()
    if MYSQL_PWD="${MYSQL_PASSWORD}" "${MYSQL_BIN}" \
        "-h${MYSQL_HOST}" "-P${MYSQL_PORT}" "-u${MYSQL_DB_USER}" -N -e "SELECT 1" \
        >/dev/null 2>&1; then
        log_message "ERROR: MySQL is already reachable on the task port ${MYSQL_HOST}:${MYSQL_PORT}"
        log_message "ERROR: refusing to benchmark a pre-existing service"
        return 20
    fi

    log_message "initializing MySQL instance ${MYSQL_INSTANCE_ID} under ${SERVICE_DIR}"

    rm -rf "${DATADIR}" "${MYSQL_TMP_DIR}"
    mkdir -p "${DATADIR}" "${MYSQL_TMP_DIR}"

    require_mysql_container || return $?
    if [[ "$(id -u)" -eq 0 ]]; then
        user_options=(--user=root)
    fi
    docker exec "${MYSQL_CONTAINER_NAME}" "${MYSQLD_BIN}" --no-defaults --initialize-insecure \
        "${user_options[@]}" \
        --basedir="${MYSQL_BASE_DIR}" \
        --datadir="${DATADIR}" \
        --log-error="${ERR_LOG}" || {
        log_message "ERROR: mysqld data directory initialization failed (see ${ERR_LOG})"
        return 40
    }

    launch_mysql_server prepare || return $?

    configure_benchmark_account || {
        log_message "ERROR: failed to configure benchmark account"
        return 40
    }

    if ! MYSQL_PWD="${MYSQL_PASSWORD}" "${MYSQL_BIN}" \
        "-h${MYSQL_HOST}" "-P${MYSQL_PORT}" "-u${MYSQL_DB_USER}" -N -e "SELECT 1" \
        >/dev/null 2>&1; then
        log_message "ERROR: benchmark account is not reachable over TCP"
        return 40
    fi
    log_message "MySQL instance ${MYSQL_INSTANCE_ID} is ready for data preparation"
}

start_mysql_service() {
    local instance_id
    initialize_runtime || return $?
    if [[ ! -x "${MYSQLD_BIN}" || ! -x "${MYSQL_BIN}" ]]; then
        log_message "ERROR: MySQL is not deployed (run build first)"
        return 40
    fi
    for ((instance_id = 1; instance_id <= MYSQL_INSTANCE_COUNT; instance_id++)); do
        configure_mysql_instance "${instance_id}" || return $?
        mkdir -p "${SERVICE_DIR}" "${MYSQL_TMP_DIR}"
        start_mysql_instance || return $?
    done
    configure_mysql_instance 1
}
