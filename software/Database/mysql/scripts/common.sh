#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="mysql"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-8.0.43}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

# Connection settings for the throwaway server and for the benchmark client.
MYSQL_HOST="${MYSQL_HOST:-127.0.0.1}"
MYSQL_PORT="${MYSQL_PORT:-}"
MYSQL_DB_USER="${MYSQL_DB_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-}"
MYSQL_DATA_ROOT="${MYSQL_DATA_ROOT:-}"
MYSQL_PREPARED_STMT_LIMIT=1048576

# Lifecycle paths (assigned in configure_runtime_paths).
MYSQL_BASE_DIR=""
MYSQLD_BIN=""
MYSQL_BIN=""
MYSQLADMIN_BIN=""
SERVICE_DIR=""
DATADIR=""
SOCKET_PATH=""
PID_FILE=""
ERR_LOG=""
MYSQL_TMP_DIR=""
MYSQL_SNAPSHOT_DIR=""
SYSBENCH_BIN=""
SYSBENCH_LUA_DIR=""

log_message() {
    printf '[mysql] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
}

normalize_architecture() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64)
            EXPECTED_ARCH="x86_64"
            ;;
        aarch64|arm64)
            EXPECTED_ARCH="aarch64"
            ;;
        *)
            log_message "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    local runner_architecture
    runner_architecture="$(normalize_architecture "$(uname -m)")"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log_message "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/mysql/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    if [[ -z "${MYSQL_DATA_ROOT}" ]]; then
        MYSQL_DATA_ROOT="${PERF_WORK_DIR}/data"
    fi
    MYSQL_BASE_DIR="${PERF_WORK_DIR}/mysql"
    MYSQLD_BIN="${MYSQL_BASE_DIR}/bin/mysqld"
    MYSQL_BIN="${MYSQL_BASE_DIR}/bin/mysql"
    MYSQLADMIN_BIN="${MYSQL_BASE_DIR}/bin/mysqladmin"
    SERVICE_DIR="${MYSQL_DATA_ROOT}"
    DATADIR="${SERVICE_DIR}/data"
    SOCKET_PATH="${SERVICE_DIR}/mysql.sock"
    PID_FILE="${SERVICE_DIR}/mysql.pid"
    ERR_LOG="${SERVICE_DIR}/mysql.err"
    MYSQL_TMP_DIR="${SERVICE_DIR}/tmp"
    MYSQL_SNAPSHOT_DIR="${PERF_WORK_DIR}/mysql-data-snapshot"
    SYSBENCH_BIN="${PERF_WORK_DIR}/sysbench-tools/sysbench-1.0.20/src/sysbench"
    SYSBENCH_LUA_DIR="${PERF_WORK_DIR}/sysbench-tools/sysbench-1.0.20/src/lua"
    TMPDIR="${MYSQL_TMP_DIR}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    if [[ -z "${MYSQL_PORT}" ]]; then
        local checksum
        checksum="$(printf '%s' "${PERF_RUN_ID}" | cksum)"
        MYSQL_PORT="$((20000 + ${checksum%% *} % 20000))"
    fi
    if [[ -z "${MYSQL_PASSWORD}" ]]; then
        MYSQL_PASSWORD="boostkit-perf-${PERF_RUN_ID}"
    fi
    if [[ ! "${MYSQL_PASSWORD}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: MYSQL_PASSWORD must use only letters, numbers, dots, underscores, or hyphens"
        return 10
    fi
    if [[ ! "${MYSQL_PORT}" =~ ^[0-9]+$ ]] || \
       (( MYSQL_PORT < 1024 || MYSQL_PORT > 65535 )); then
        log_message "ERROR: MYSQL_PORT must be an unprivileged TCP port: ${MYSQL_PORT}"
        return 10
    fi
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${SERVICE_DIR}" "${MYSQL_TMP_DIR}"
}

configure_benchmark_account() {
    if [[ "${MYSQL_DB_USER}" == "root" ]]; then
        "${MYSQL_BIN}" --socket="${SOCKET_PATH}" -u root <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
ALTER USER 'root'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
CREATE DATABASE IF NOT EXISTS sbtest;
FLUSH PRIVILEGES;
SQL
        return $?
    fi

    "${MYSQL_BIN}" --socket="${SOCKET_PATH}" -u root <<SQL
CREATE USER IF NOT EXISTS '${MYSQL_DB_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_DB_USER}'@'%' WITH GRANT OPTION;
CREATE DATABASE IF NOT EXISTS sbtest;
FLUSH PRIVILEGES;
SQL
}

launch_mysql_server() {
    local mode="$1"
    local attempt actual_limit
    local -a mode_options

    case "${mode}" in
        prepare)
            mode_options=(
                --innodb-flush-log-at-trx-commit=0
                --innodb-use-native-aio=OFF
                --skip-log-bin
            )
            ;;
        benchmark)
            mode_options=(
                --innodb-flush-log-at-trx-commit=1
                --innodb-use-native-aio=ON
                --log-bin="${DATADIR}/mysql-bin"
            )
            ;;
        *)
            log_message "ERROR: unsupported MySQL service mode: ${mode}"
            return 40
            ;;
    esac

    "${MYSQLD_BIN}" --no-defaults --daemonize \
        --basedir="${MYSQL_BASE_DIR}" \
        --datadir="${DATADIR}" \
        --tmpdir="${MYSQL_TMP_DIR}" \
        --user="$(id -un)" \
        --socket="${SOCKET_PATH}" \
        --pid-file="${PID_FILE}" \
        --port="${MYSQL_PORT}" \
        --bind-address="${MYSQL_HOST}" \
        --max-connections=2048 \
        --max-prepared-stmt-count="${MYSQL_PREPARED_STMT_LIMIT}" \
        --log-error="${ERR_LOG}" \
        "${mode_options[@]}" || {
        log_message "ERROR: failed to launch mysqld (see ${ERR_LOG})"
        return 40
    }

    for attempt in {1..60}; do
        if "${MYSQLADMIN_BIN}" --socket="${SOCKET_PATH}" -u root ping >/dev/null 2>&1; then
            if [[ "${mode}" == prepare ]]; then
                actual_limit="$("${MYSQL_BIN}" --socket="${SOCKET_PATH}" -u root -N \
                    -e 'SELECT @@GLOBAL.max_prepared_stmt_count')" || {
                    log_message "ERROR: cannot verify MySQL prepared-statement limit"
                    return 40
                }
            else
                actual_limit="$(MYSQL_PWD="${MYSQL_PASSWORD}" "${MYSQL_BIN}" \
                    "-h${MYSQL_HOST}" "-P${MYSQL_PORT}" "-u${MYSQL_DB_USER}" -N \
                    -e 'SELECT @@GLOBAL.max_prepared_stmt_count')" || {
                    log_message "ERROR: cannot verify MySQL prepared-statement limit"
                    return 40
                }
            fi
            if [[ "${actual_limit}" != "${MYSQL_PREPARED_STMT_LIMIT}" ]]; then
                log_message "ERROR: MySQL max_prepared_stmt_count is ${actual_limit}, expected ${MYSQL_PREPARED_STMT_LIMIT}"
                return 40
            fi
            log_message "mysqld is ready on port ${MYSQL_PORT} (socket ${SOCKET_PATH})"
            return 0
        fi
        sleep 1
    done
    log_message "ERROR: mysqld did not become ready (see ${ERR_LOG})"
    return 40
}

shutdown_mysql_server() {
    local attempt

    if [[ ! -S "${SOCKET_PATH}" ]]; then
        return 0
    fi
    if ! MYSQL_PWD="${MYSQL_PASSWORD}" "${MYSQLADMIN_BIN}" \
        --socket="${SOCKET_PATH}" -u root shutdown; then
        log_message "ERROR: failed to shut down managed MySQL instance"
        return 50
    fi
    for attempt in {1..40}; do
        if [[ ! -S "${SOCKET_PATH}" ]]; then
            return 0
        fi
        sleep 0.5
    done
    log_message "ERROR: managed MySQL socket is still present after shutdown"
    return 50
}

run_sysbench() {
    local workload="$1" threads="$2" duration="$3" label="$4"
    local workload_script="${SYSBENCH_LUA_DIR}/oltp_${workload}.lua"
    local raw_output="${RESULTS_DIR}/sysbench_raw.log"
    local run_output="${RESULTS_DIR}/sysbench-runs/${label}.log"
    local action=run
    local -a command=(
        "${SYSBENCH_BIN}" --db-driver=mysql
        "--mysql-host=${MYSQL_HOST}" "--mysql-port=${MYSQL_PORT}"
        "--mysql-user=${MYSQL_DB_USER}" "--mysql-password=${MYSQL_PASSWORD}"
        --mysql-db=sbtest --table_size=10000000 --tables=64
        "--threads=${threads}" "--percentile=95" --report-interval=1
    )

    if [[ "${duration}" -gt 0 ]]; then
        command+=("--time=${duration}")
    fi
    if [[ "${label}" == prepare ]]; then
        action=prepare
    fi
    command+=("${workload_script}" "${action}")
    printf '# %s: oltp_%s %s, threads=%s, time=%s\n' \
        "${label}" "${workload}" "${action}" "${threads}" "${duration}" | tee -a "${raw_output}" "${run_output}"
    if ! LUA_PATH="${SYSBENCH_LUA_DIR}/?.lua;;" "${command[@]}" 2>&1 \
        | tee -a "${raw_output}" "${run_output}"; then
        log_message "ERROR: Sysbench ${label} failed"
        return 50
    fi
}

require_mysql_tools() {
    local command_name package
    local packages=()

    # The MySQL binary archive needs the first group.  The remaining tools and
    # development headers are required later when this case builds the
    # pinned upstream Sysbench client from its original source.
    for command_name in md5sum tar ldd sed tee curl git make gcc autoreconf automake libtoolize pkg-config python3 sudo; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            md5sum|tee) package="coreutils" ;;
            tar) package="tar" ;;
            ldd) package="glibc-common" ;;
            sed) package="sed" ;;
            curl) package="curl" ;;
            git) package="git" ;;
            make) package="make" ;;
            gcc) package="gcc" ;;
            autoreconf) package="autoconf" ;;
            automake) package="automake" ;;
            libtoolize) package="libtool" ;;
            pkg-config) package="pkgconf-pkg-config" ;;
            python3) package="python3" ;;
            sudo) package="sudo" ;;
        esac
        log_message "missing required MySQL test command: ${command_name}"
        packages+=("${package}")
    done

    for package in libaio-devel openssl-devel; do
        if ! rpm -q "${package}" >/dev/null 2>&1; then
            log_message "missing required MySQL test package: ${package}"
            packages+=("${package}")
        fi
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log_message "ERROR: dnf is required to install MySQL test prerequisites"
        return 30
    fi

    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing missing MySQL test packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log_message "ERROR: sudo is required to install MySQL test prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log_message "ERROR: failed to install MySQL test prerequisites"
        return 30
    fi

    for command_name in md5sum tar ldd sed tee curl git make gcc autoreconf automake libtoolize pkg-config python3 sudo; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log_message "ERROR: required MySQL test command remains unavailable: ${command_name}"
            return 30
        fi
    done
    for package in libaio-devel openssl-devel; do
        if ! rpm -q "${package}" >/dev/null 2>&1; then
            log_message "ERROR: required MySQL test package remains unavailable: ${package}"
            return 30
        fi
    done
}
