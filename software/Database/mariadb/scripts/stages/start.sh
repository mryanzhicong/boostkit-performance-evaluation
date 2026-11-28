#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_mariadb_instance() {
    local -a user_options=()

    check_mariadb_container || return $?
    if mariadb_client_exec "${MARIADB_PASSWORD}" "${MARIADB_BIN}" \
        "-h${MARIADB_HOST}" "-P${MARIADB_PORT}" "-u${MARIADB_DB_USER}" -N -e 'SELECT 1' \
        >/dev/null 2>&1; then
        log_message "ERROR: MariaDB is already reachable on the task port ${MARIADB_HOST}:${MARIADB_PORT}"
        log_message 'ERROR: refusing to benchmark a pre-existing service'
        return 20
    fi

    log_message "initializing MariaDB instance ${MARIADB_INSTANCE_ID} under ${SERVICE_DIR}"
    rm -rf -- "${DATADIR}" "${MARIADB_TMP_DIR}"
    mkdir -p "${DATADIR}" "${MARIADB_TMP_DIR}"

    if [[ "$(id -u)" -eq 0 ]]; then
        user_options=(--user=root)
    fi
    container_exec "${MARIADB_INSTALL_DB_BIN}" \
        --no-defaults \
        "${user_options[@]}" \
        --basedir="${MARIADB_BASE_DIR}" \
        --datadir="${DATADIR}" \
        --auth-root-authentication-method=normal \
        --skip-test-db > "${RESULTS_DIR}/mariadb-install-db.log" 2>&1 || {
        log_message "ERROR: mariadb-install-db failed (see ${RESULTS_DIR}/mariadb-install-db.log)"
        return 40
    }

    launch_mariadb_server prepare || return $?

    configure_benchmark_account || {
        log_message 'ERROR: failed to configure MariaDB benchmark account'
        return 40
    }

    if ! mariadb_client_exec "${MARIADB_PASSWORD}" "${MARIADB_BIN}" \
        "-h${MARIADB_HOST}" "-P${MARIADB_PORT}" "-u${MARIADB_DB_USER}" -N -e 'SELECT 1' \
        >/dev/null 2>&1; then
        log_message 'ERROR: MariaDB benchmark account is not reachable over TCP'
        return 40
    fi
    log_message "MariaDB instance ${MARIADB_INSTANCE_ID} is ready for data preparation"
}

start_mariadb_service() {
    local instance_id
    initialize_runtime || return $?
    if [[ ! -x "${MARIADBD_BIN}" || ! -x "${MARIADB_BIN}" || ! -x "${MARIADB_INSTALL_DB_BIN}" ]]; then
        log_message 'ERROR: MariaDB is not built (run build first)'
        return 40
    fi
    for ((instance_id = 1; instance_id <= MARIADB_INSTANCE_COUNT; instance_id++)); do
        configure_mariadb_instance "${instance_id}" || return $?
        mkdir -p "${SERVICE_DIR}" "${MARIADB_TMP_DIR}"
        start_mariadb_instance || return $?
    done
    configure_mariadb_instance 1
}
