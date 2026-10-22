#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_mysql_service() {
    local mysqld_user
    initialize_runtime || return $?
    if [[ ! -x "${MYSQLD_BIN}" || ! -x "${MYSQL_BIN}" ]]; then
        log_message "ERROR: MySQL is not deployed (run build first)"
        return 40
    fi

    if MYSQL_PWD="${MYSQL_PASSWORD}" "${MYSQL_BIN}" \
        "-h${MYSQL_HOST}" "-P${MYSQL_PORT}" "-u${MYSQL_DB_USER}" -N -e "SELECT 1" \
        >/dev/null 2>&1; then
        log_message "ERROR: MySQL is already reachable on the task port ${MYSQL_HOST}:${MYSQL_PORT}"
        log_message "ERROR: refusing to benchmark a pre-existing service"
        return 20
    fi

    mysqld_user="$(id -un)"
    if [[ "$(id -u)" -eq 0 ]]; then
        mysqld_user="root"
    fi
    log_message "initializing a throwaway MySQL ${SOFTWARE_VERSION} instance under ${SERVICE_DIR}"

    rm -rf "${DATADIR}" "${MYSQL_TMP_DIR}"
    mkdir -p "${DATADIR}" "${MYSQL_TMP_DIR}"

    "${MYSQLD_BIN}" --no-defaults --initialize-insecure \
        --basedir="${MYSQL_BASE_DIR}" \
        --datadir="${DATADIR}" \
        --user="${mysqld_user}" \
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
    log_message "MySQL service is ready for data preparation"
}
