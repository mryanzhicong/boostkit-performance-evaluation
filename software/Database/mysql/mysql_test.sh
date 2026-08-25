#!/usr/bin/env bash
# MySQL performance case (official prebuilt binary deployment).
#
# The software under test is fetched from the official MySQL 8.0 "Linux -
# Generic" prebuilt tarball and unpacked into a per-version directory — the
# distribution package manager only ships one version and cannot switch between
# 8.0.x releases.  The database_blue Sysbench driver is built in this case's
# isolated work directory during the test stage.
#
# The four framework stages map to: fetch+verify the tarball (build), launch a
# throwaway instance from it (start), run the original database_blue Sysbench
# suite (test), and tear that instance down (stop).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="mysql"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-8.0.46}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

# Connection settings for the throwaway server and for the benchmark client.
MYSQL_HOST="${MYSQL_HOST:-127.0.0.1}"
MYSQL_PORT="${MYSQL_PORT:-}"
MYSQL_DB_USER="${MYSQL_DB_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-}"

# Fixed source for the original database_blue client test scripts.
DATABASE_BLUE_REPOSITORY="${DATABASE_BLUE_REPOSITORY:-https://gitcode.com/mwx5319395/database_blue.git}"
DATABASE_BLUE_COMMIT="${DATABASE_BLUE_COMMIT:-af4759227538961f0b0bed5ffc25434d65e7456b}"

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

log() {
    printf '[mysql] %s\n' "$*"
}

configure_runtime_paths() {
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
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
            EXPECTED_ARCH="${EXPECTED_ARCH,,}"
            ;;
    esac
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/tmp/mysql-perf/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    MYSQL_BASE_DIR="${PERF_WORK_DIR}/mysql"
    MYSQLD_BIN="${MYSQL_BASE_DIR}/bin/mysqld"
    MYSQL_BIN="${MYSQL_BASE_DIR}/bin/mysql"
    MYSQLADMIN_BIN="${MYSQL_BASE_DIR}/bin/mysqladmin"
    SERVICE_DIR="${PERF_WORK_DIR}/mysql-service"
    DATADIR="${SERVICE_DIR}/data"
    SOCKET_PATH="${SERVICE_DIR}/mysql.sock"
    PID_FILE="${SERVICE_DIR}/mysql.pid"
    ERR_LOG="${SERVICE_DIR}/mysql.err"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
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
        log "ERROR: MYSQL_PASSWORD must use only letters, numbers, dots, underscores, or hyphens"
        return 10
    fi
    if [[ ! "${MYSQL_PORT}" =~ ^[0-9]+$ ]] || \
       (( MYSQL_PORT < 1024 || MYSQL_PORT > 65535 )); then
        log "ERROR: MYSQL_PORT must be an unprivileged TCP port: ${MYSQL_PORT}"
        return 10
    fi
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${SERVICE_DIR}" "${TMPDIR:-${PERF_WORK_DIR}/tmp}"
}

fetch_mysql_archive() {
    local archive_path
    local actual_md5
    local archive_md5
    local archive_name
    local download_url
    local release_directory

    # Every supported artifact is declared with its official archive name and
    # checksum.  Adding a version means adding its two architecture entries
    # here; the download, extraction, and lifecycle logic remains unchanged.
    case "${SOFTWARE_VERSION}:${EXPECTED_ARCH}" in
        8.0.46:x86_64)
            release_directory="MySQL-8.0"
            archive_name="mysql-8.0.46-linux-glibc2.28-x86_64.tar.xz"
            archive_md5="367c6adbd976c0e4bcbe39bda4ea6ecf"
            ;;
        8.0.46:aarch64)
            release_directory="MySQL-8.0"
            archive_name="mysql-8.0.46-linux-glibc2.28-aarch64.tar.xz"
            archive_md5="62376634565907ec31b74da3bc645b2b"
            ;;
        *)
            log "ERROR: no verified MySQL release is declared for ${SOFTWARE_VERSION} on ${EXPECTED_ARCH}"
            return 10
            ;;
    esac

    archive_path="${PERF_WORK_DIR}/${archive_name}"
    if [[ -s "${archive_path}" ]]; then
        log "using cached MySQL archive ${archive_path}" >&2
    else
        download_url="https://cdn.mysql.com/Downloads/${release_directory}/${archive_name}"
        log "downloading ${download_url}" >&2
        if command -v curl >/dev/null 2>&1; then
            if ! curl -fSL --retry 3 --connect-timeout 30 -o "${archive_path}" "${download_url}"; then
                rm -f "${archive_path}"
                log "ERROR: failed to download ${archive_name} from MySQL CDN" >&2
                return 30
            fi
        elif ! wget -q -O "${archive_path}" "${download_url}"; then
            rm -f "${archive_path}"
            log "ERROR: failed to download ${archive_name}" >&2
            return 30
        fi
    fi

    actual_md5="$(md5sum "${archive_path}")"
    actual_md5="${actual_md5%% *}"
    if [[ "${actual_md5}" != "${archive_md5}" ]]; then
        log "ERROR: MySQL archive checksum mismatch: expected ${archive_md5}, got ${actual_md5}" >&2
        return 30
    fi
    printf '%s\n' "${archive_path}"
}

extract_mysql_archive() {
    local archive="$1"
    local unpacked_directory

    rm -rf "${MYSQL_BASE_DIR}"
    log "extracting ${archive}"
    if [[ "${archive}" == *.tar.xz ]]; then
        tar -xJf "${archive}" -C "${PERF_WORK_DIR}"
    else
        tar -xzf "${archive}" -C "${PERF_WORK_DIR}"
    fi
    unpacked_directory="$(find "${PERF_WORK_DIR}" -maxdepth 1 -type d -name "mysql-${SOFTWARE_VERSION}-*" | head -n 1)"
    if [[ -z "${unpacked_directory}" ]]; then
        log "ERROR: cannot locate the unpacked mysql directory"
        return 40
    fi
    mv "${unpacked_directory}" "${MYSQL_BASE_DIR}"
}

require_mysql_tools() {
    local command_name

    for command_name in md5sum tar ldd sed tee; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "ERROR: required command is missing: ${command_name}"
            log "ERROR: provision the missing MySQL test prerequisites on the dedicated runner"
            return 30
        fi
    done
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        log "ERROR: curl or wget is required to fetch the tarball"
        log "ERROR: provision the missing MySQL test prerequisites on the dedicated runner"
        return 30
    fi
}

configure_benchmark_account() {
    if [[ "${MYSQL_DB_USER}" == "root" ]]; then
        "${MYSQL_BIN}" --socket="${SOCKET_PATH}" -u root <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
ALTER USER 'root'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
CREATE DATABASE IF NOT EXISTS sysbench;
FLUSH PRIVILEGES;
SQL
        return $?
    fi

    "${MYSQL_BIN}" --socket="${SOCKET_PATH}" -u root <<SQL
CREATE USER IF NOT EXISTS '${MYSQL_DB_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_DB_USER}'@'%' WITH GRANT OPTION;
CREATE DATABASE IF NOT EXISTS sysbench;
FLUSH PRIVILEGES;
SQL
}

build_mysql() {
    local archive_path
    local actual_version
    local runner_architecture

    initialize_runtime || return $?
    runner_architecture="$(uname -m)"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    require_mysql_tools || return $?
    if [[ -e "${MYSQL_BASE_DIR}/bin/mysqld" ]]; then
        log "ERROR: build output is not clean under ${PERF_WORK_DIR}"
        return 20
    fi

    archive_path="$(fetch_mysql_archive)" || return $?
    extract_mysql_archive "${archive_path}" || return $?

    if [[ ! -x "${MYSQLD_BIN}" || ! -x "${MYSQL_BIN}" ]]; then
        log "ERROR: mysqld/mysql binaries not found after extraction"
        return 40
    fi
    if ldd "${MYSQLD_BIN}" 2>&1 | grep -Eq 'libaio[^[:space:]]*[[:space:]]+=>[[:space:]]+not found'; then
        log "ERROR: libaio runtime is missing; provision it on the dedicated runner before this workflow"
        return 40
    fi
    actual_version="$("${MYSQLD_BIN}" --version 2>/dev/null | sed -nE 's/.*Ver ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p')"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: installed mysqld is ${actual_version}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "mysqld ${actual_version} deployed from the official prebuilt tarball"
}

start_mysql_service() {
    local attempt
    local mysqld_user
    initialize_runtime || return $?
    if [[ ! -x "${MYSQLD_BIN}" || ! -x "${MYSQL_BIN}" ]]; then
        log "ERROR: MySQL is not deployed (run build first)"
        return 40
    fi

    if MYSQL_PWD="${MYSQL_PASSWORD}" "${MYSQL_BIN}" \
        "-h${MYSQL_HOST}" "-P${MYSQL_PORT}" "-u${MYSQL_DB_USER}" -N -e "SELECT 1" \
        >/dev/null 2>&1; then
        log "ERROR: MySQL is already reachable on the task port ${MYSQL_HOST}:${MYSQL_PORT}"
        log "ERROR: refusing to benchmark a pre-existing service"
        return 20
    fi

    mysqld_user="$(id -un)"
    if [[ "$(id -u)" -eq 0 ]]; then
        mysqld_user="root"
    fi
    log "initializing a throwaway MySQL ${SOFTWARE_VERSION} instance under ${SERVICE_DIR}"

    rm -rf "${DATADIR}"
    mkdir -p "${DATADIR}"

    "${MYSQLD_BIN}" --initialize-insecure \
        --basedir="${MYSQL_BASE_DIR}" \
        --datadir="${DATADIR}" \
        --user="${mysqld_user}" \
        --log-error="${ERR_LOG}" || {
        log "ERROR: mysqld data directory initialization failed (see ${ERR_LOG})"
        return 40
    }

    "${MYSQLD_BIN}" --daemonize \
        --basedir="${MYSQL_BASE_DIR}" \
        --datadir="${DATADIR}" \
        --user="${mysqld_user}" \
        --socket="${SOCKET_PATH}" \
        --pid-file="${PID_FILE}" \
        --port="${MYSQL_PORT}" \
        --bind-address="${MYSQL_HOST}" \
        --log-error="${ERR_LOG}" || {
        log "ERROR: failed to launch mysqld (see ${ERR_LOG})"
        return 40
    }

    for attempt in {1..60}; do
        if "${MYSQL_BIN}" --socket="${SOCKET_PATH}" -u root -N -e "SELECT 1" >/dev/null 2>&1; then
            log "mysqld is ready on port ${MYSQL_PORT} (socket ${SOCKET_PATH})"
            break
        fi
        sleep 1
    done
    if ! "${MYSQL_BIN}" --socket="${SOCKET_PATH}" -u root -N -e "SELECT 1" >/dev/null 2>&1; then
        log "ERROR: mysqld did not become ready (see ${ERR_LOG})"
        return 40
    fi
    configure_benchmark_account || {
        log "ERROR: failed to configure benchmark account"
        return 40
    }

    if ! MYSQL_PWD="${MYSQL_PASSWORD}" "${MYSQL_BIN}" \
        "-h${MYSQL_HOST}" "-P${MYSQL_PORT}" "-u${MYSQL_DB_USER}" -N -e "SELECT 1" \
        >/dev/null 2>&1; then
        log "ERROR: benchmark account is not reachable over TCP"
        return 40
    fi
    log "MySQL service is ready for benchmarking"
}

run_mysql_benchmarks() {
    local database_blue_dir
    local raw_output
    local report_directory
    local suite_start_time

    initialize_runtime || return $?
    if ! MYSQL_PWD="${MYSQL_PASSWORD}" "${MYSQL_BIN}" \
        "-h${MYSQL_HOST}" "-P${MYSQL_PORT}" "-u${MYSQL_DB_USER}" -N -e "SELECT 1" \
        >/dev/null 2>&1; then
        log "ERROR: MySQL is not reachable on ${MYSQL_HOST}:${MYSQL_PORT}"
        return 50
    fi
    if ! command -v git >/dev/null 2>&1; then
        log "ERROR: git is required to retrieve database_blue"
        return 50
    fi
    if ! command -v python3 >/dev/null 2>&1; then
        log "ERROR: python3 is required to collect database_blue results"
        return 50
    fi
    database_blue_dir="${PERF_WORK_DIR}/database_blue"
    raw_output="${RESULTS_DIR}/database_blue_sysbench_raw.log"
    report_directory="/home/automation/client/report/sysbench"
    rm -rf "${database_blue_dir}"
    log "cloning database_blue at ${DATABASE_BLUE_COMMIT}"
    if ! git clone --quiet "${DATABASE_BLUE_REPOSITORY}" "${database_blue_dir}"; then
        log "ERROR: failed to clone database_blue from ${DATABASE_BLUE_REPOSITORY}"
        return 50
    fi
    if ! git -C "${database_blue_dir}" checkout --quiet --detach "${DATABASE_BLUE_COMMIT}"; then
        log "ERROR: database_blue commit is unavailable: ${DATABASE_BLUE_COMMIT}"
        return 50
    fi
    if ! bash "${SCRIPT_DIR}/scripts/prepare_database_blue_tools.sh" \
        "${PERF_WORK_DIR}/database-blue-tools" \
        "${MYSQL_BASE_DIR}/bin/mysql_config"; then
        log "ERROR: failed to prepare database_blue Sysbench tools"
        return 50
    fi

    if [[ ! "${MYSQL_HOST}" =~ ^[A-Za-z0-9._:-]+$ ]]; then
        log "ERROR: database_blue only accepts a hostname or IP address: ${MYSQL_HOST}"
        return 50
    fi
    if [[ "${MYSQL_DB_USER}" != "root" ]]; then
        log "ERROR: database_blue Sysbench scripts require MYSQL_DB_USER=root"
        return 50
    fi
    mkdir -p "${report_directory}"
    suite_start_time="$(date +%s)"
    log "running the original database_blue Sysbench 1.0 suite"
    if ! (
        cd "${database_blue_dir}/resources/database/client/script/sysbench_mysql_1.0"
        sed -i "s/^host=.*/host='${MYSQL_HOST}'/" runall.sh
        sed -i "s/^password=.*/password='${MYSQL_PASSWORD}'/" runall.sh
        sed -i "s/-P 3306/-P ${MYSQL_PORT}/g" runall.sh
        sed -i \
            's/--mysql-host=${HOST}/--mysql-host=${HOST} --mysql-port=${PORT}/' \
            prepare.sh
        chmod +x data_filter.sh test_oltp_*.sh
        bash prepare.sh \
            -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" \
            -u "${MYSQL_DB_USER}" -p "${MYSQL_PASSWORD}"
        bash runall.sh
    ) 2>&1 | tee "${raw_output}"; then
        log "ERROR: database_blue Sysbench suite failed (see ${raw_output})"
        return 50
    fi
    python3 "${SCRIPT_DIR}/scripts/collect_database_blue_sysbench.py" \
        "${report_directory}" "${suite_start_time}" "${RESULTS_DIR}/results.json" || return 50
    log "database_blue Sysbench suite completed"
}

stop_mysql_service() {
    local attempt
    initialize_runtime || return $?
    if [[ ! -f "${SOCKET_PATH}" ]]; then
        log "no managed MySQL socket; nothing to stop"
    else
        if ! MYSQL_PWD="${MYSQL_PASSWORD}" "${MYSQLADMIN_BIN}" --socket="${SOCKET_PATH}" -u root shutdown >/dev/null 2>&1; then
            MYSQL_PWD="${MYSQL_PASSWORD}" "${MYSQL_BIN}" --socket="${SOCKET_PATH}" -u root -N -e "SHUTDOWN" >/dev/null 2>&1 || true
        fi

        for attempt in {1..20}; do
            if [[ -f "${PID_FILE}" ]] && ! kill -0 "$(cat "${PID_FILE}" 2>/dev/null)" 2>/dev/null; then
                break
            fi
            MYSQL_PWD="${MYSQL_PASSWORD}" "${MYSQL_BIN}" --socket="${SOCKET_PATH}" -u root -N -e "SELECT 1" >/dev/null 2>&1 || break
            sleep 0.5
        done
        if MYSQL_PWD="${MYSQL_PASSWORD}" "${MYSQL_BIN}" --socket="${SOCKET_PATH}" -u root -N -e "SELECT 1" >/dev/null 2>&1; then
            log "ERROR: MySQL is still reachable on socket ${SOCKET_PATH}"
            return 50
        fi
        log "MySQL service stopped"
    fi
    if ! bash "${SCRIPT_DIR}/scripts/prepare_database_blue_tools.sh" \
        --cleanup "${PERF_WORK_DIR}/database-blue-tools"; then
        log "ERROR: failed to remove database_blue tool links"
        return 50
    fi
}

standalone_runtime() {
    python3 "${SCRIPT_DIR}/scripts/standalone_runtime.py" "$@"
}

cleanup_standalone_workdir() {
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 1 ]]; then
        log "keeping standalone work directory: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${STANDALONE_OWNS_WORK_DIR}" -ne 1 ]]; then
        log "external work directory was not removed: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${PERF_WORK_DIR}" != /tmp/mysql-perf/local-* || \
          "${PERF_WORK_DIR}" == "/tmp/mysql-perf" ]]; then
        log "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    fi
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        rm -rf -- "${PERF_WORK_DIR}" || return 70
    fi
    log "cleaned standalone work directory: ${PERF_WORK_DIR}"
}

emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then
        stop_mysql_service
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_mysql_standalone() {
    local stage_status=0 failed_stage="" cleanup_status="passed" finalize_status=0
    local command_status="passed"

    configure_runtime_paths || return $?
    STANDALONE_STOP_DONE=0
    STANDALONE_CLEANUP_DONE=0
    trap emergency_standalone_cleanup EXIT
    initialize_runtime || return $?

    if standalone_runtime system "${RESULTS_DIR}/system_info.json" && \
        standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json"; then
        :
    else
        stage_status=$?
        failed_stage="prepare"
    fi

    if [[ "${stage_status}" -eq 0 ]]; then
        if build_mysql; then
            if standalone_runtime build-info \
                "${RESULTS_DIR}/build_info.json" \
                "${SOFTWARE_VERSION}" \
                "${PERF_ACTUAL_VERSION_FILE}" \
                "${EXPECTED_ARCH}" \
                "${PERF_RUN_ID}"; then
                :
            else
                stage_status=$?
                failed_stage="build"
            fi
        else
            stage_status=$?
            failed_stage="build"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if start_mysql_service; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_mysql_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_mysql_service; then
        cleanup_status="failed"
    fi
    STANDALONE_STOP_DONE=1
    if ! standalone_runtime runtime "${RESULTS_DIR}/runtime_after.json"; then
        cleanup_status="failed"
    fi
    if ! cleanup_standalone_workdir; then
        cleanup_status="failed"
    fi
    STANDALONE_CLEANUP_DONE=1

    if [[ "${stage_status}" -ne 0 ]]; then
        command_status="failed"
    fi
    if standalone_runtime finalize \
        "${RESULTS_DIR}" \
        "${SOFTWARE_VERSION}" \
        "${EXPECTED_ARCH}" \
        "${PERF_RUN_ID}" \
        "${command_status}" \
        "${cleanup_status}" \
        "${failed_stage}"; then
        finalize_status=0
    else
        finalize_status=$?
    fi
    trap - EXIT
    if [[ "${stage_status}" -ne 0 ]]; then
        return "${stage_status}"
    fi
    if [[ "${cleanup_status}" != "passed" ]]; then
        return 70
    fi
    return "${finalize_status}"
}

usage() {
    cat <<USAGE
Usage: $(basename "$0") [OPTIONS]

Deploy MySQL 8.0.x from the official prebuilt tarball and run sysbench OLTP and
micro benchmarks as a standalone performance evaluation.
Results default to results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       MySQL version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR
USAGE
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version)
                if [[ "$#" -lt 2 ]]; then
                    log "ERROR: --version requires a value"
                    return 10
                fi
                SOFTWARE_VERSION="$2"
                shift 2
                ;;
            --results-dir)
                if [[ "$#" -lt 2 ]]; then
                    log "ERROR: --results-dir requires a value"
                    return 10
                fi
                RESULTS_DIR="$2"
                shift 2
                ;;
            --keep-workdir)
                STANDALONE_KEEP_WORK_DIR=1
                shift
                ;;
            -h|--help)
                usage
                return 0
                ;;
            *)
                log "ERROR: unsupported option: $1"
                usage
                return 10
                ;;
        esac
    done

    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" || return $?
    : > "${RESULTS_DIR}/results.log"
    local pipeline_status=0
    set +e
    run_mysql_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
