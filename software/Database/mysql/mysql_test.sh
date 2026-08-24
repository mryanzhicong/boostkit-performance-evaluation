#!/usr/bin/env bash
# MySQL performance case (official prebuilt binary deployment).
#
# To benchmark several MySQL release lines (5.7.x / 8.0.x) the software under
# test is fetched from the official MySQL "Linux - Generic" prebuilt tarball and
# unpacked into a per-version directory — the distribution package manager only
# ships one version and cannot switch between 5.7 and 8.0. sysbench, the
# benchmark *driver* (not the software under test), is installed from the system
# repositories.
#
# The four framework stages map to: fetch+verify the tarball (build), launch a
# throwaway instance from it (start), run the official sysbench OLTP + micro
# benchmarks (test), and tear that instance down (stop).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="mysql"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-8.0.35}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
RESULTS_DIR="${RESULTS_DIR:-${SCRIPT_DIR}/results/${SOFTWARE_VERSION}}"
PERF_WORK_DIR="${PERF_WORK_DIR:-/tmp/boostkit-perf/local/Database/mysql/${SOFTWARE_VERSION}}"

# Connection settings for the throwaway server and for the benchmark client.
MYSQL_HOST="${MYSQL_HOST:-127.0.0.1}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_DB_USER="${MYSQL_DB_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-}"
MYSQL_DB="${MYSQL_DB:-sbtest}"

# Benchmark parameters.
TABLES="${TABLES:-4}"
TABLE_SIZE="${TABLE_SIZE:-10000}"
TIME_PER_TEST="${TIME_PER_TEST:-60}"
ITERATIONS="${ITERATIONS:-1}"

# Prebuilt tarball source. Set MYSQL_SOURCE_BASE to a (faster) mirror to try it
# first; the official MySQL CDN/archives is always consulted as a fallback, so an
# out-of-date mirror never blocks a build for the exact requested version.
MYSQL_SOURCE_BASE="${MYSQL_SOURCE_BASE:-}"

# Lifecycle paths.
MYSQL_BASE_DIR="${PERF_WORK_DIR}/mysql"
MYSQLD_BIN="${MYSQL_BASE_DIR}/bin/mysqld"
MYSQL_BIN="${MYSQL_BASE_DIR}/bin/mysql"
MYSQLADMIN_BIN="${MYSQL_BASE_DIR}/bin/mysqladmin"
SERVICE_DIR="${PERF_WORK_DIR}/mysql-service"
DATADIR="${SERVICE_DIR}/data"
SOCKET_PATH="${SERVICE_DIR}/mysql.sock"
PID_FILE="${SERVICE_DIR}/mysql.pid"
ERR_LOG="${SERVICE_DIR}/mysql.err"
MYSQL_EXTERNAL=0

log() { printf '[mysql] %s\n' "$*"; }

initialize_runtime() {
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${SERVICE_DIR}" "${TMPDIR:-${PERF_WORK_DIR}/tmp}"
}

normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

check_architecture() {
    local actual expected
    actual="$(normalize_arch "$(uname -m)")"
    expected="$(normalize_arch "${EXPECTED_ARCH}")"
    [[ "${actual}" == "${expected}" ]] || {
        log "ERROR: expected architecture ${expected}, runner is ${actual}"
        return 20
    }
}

detect_os_id() {
    if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        printf '%s\n' "${ID}"
    else
        printf 'unknown\n'
    fi
}

has_root() { [[ "$(id -u)" -eq 0 ]]; }

# The subdirectory that holds a release line inside the mirror/CDN.
source_subdir() {
    case "${SOFTWARE_VERSION}" in
        5.7.*) printf 'MySQL-5.7\n' ;;
        8.0.*) printf 'MySQL-8.0\n' ;;
        *) log "ERROR: unsupported MySQL version ${SOFTWARE_VERSION}"; return 1 ;;
    esac
}

# The canonical official tarball filename for this version + architecture.
tarball_name() {
    local arch
    arch="$(normalize_arch "${EXPECTED_ARCH}")"
    case "${SOFTWARE_VERSION}" in
        5.7.*) printf 'mysql-%s-linux-glibc2.12-%s.tar.gz\n' "${SOFTWARE_VERSION}" "${arch}" ;;
        8.0.*) printf 'mysql-%s-linux-glibc2.28-%s.tar.xz\n' "${SOFTWARE_VERSION}" "${arch}" ;;
        *) log "ERROR: unsupported MySQL version ${SOFTWARE_VERSION}"; return 1 ;;
    esac
}

candidate_urls() {
    local name subdir
    name="$(tarball_name)" || return 1
    subdir="$(source_subdir)" || return 1
    if [[ -n "${MYSQL_SOURCE_BASE}" ]]; then
        printf '%s/%s/%s\n' "${MYSQL_SOURCE_BASE%/}" "${subdir}" "${name}"
    fi
    # Official first (after any mirror): exact-version artifacts always live here
    # regardless of how recently a mirror was synced.
    case "${SOFTWARE_VERSION}" in
        5.7.*) printf 'https://downloads.mysql.com/archives/get/p/23/file/%s\n' "${name}" ;;
        *) printf 'https://cdn.mysql.com/Downloads/%s/%s\n' "${subdir}" "${name}" ;;
    esac
    printf 'https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/%s/%s\n' "${subdir}" "${name}"
}

fetch_tarball() {
    local url dest name
    name="$(tarball_name)" || return 1
    dest="${PERF_WORK_DIR}/${name}"
    [[ -s "${dest}" ]] && { log "using cached tarball ${dest}"; printf '%s\n' "${dest}"; return 0; }
    while IFS= read -r url; do
        [[ -n "${url}" ]] || continue
        log "downloading ${url}"
        if command -v curl >/dev/null 2>&1; then
            curl -fSL --retry 3 --connect-timeout 30 -o "${dest}" "${url}" && break
        else
            wget -q -O "${dest}" "${url}" && break
        fi
        log "WARN: download failed from ${url}"
        rm -f "${dest}"
    done < <(candidate_urls)
    [[ -s "${dest}" ]] || {
        log "ERROR: failed to download ${name}"
        return 30
    }
    printf '%s\n' "${dest}"
}

extract_tarball() {
    local tarball
    tarball="$1"
    rm -rf "${MYSQL_BASE_DIR}"
    mkdir -p "${MYSQL_BASE_DIR}"
    log "extracting ${tarball}"
    if [[ "${tarball}" == *.tar.xz ]]; then
        tar -xJf "${tarball}" -C "${PERF_WORK_DIR}"
    else
        tar -xzf "${tarball}" -C "${PERF_WORK_DIR}"
    fi
    # The tarball unpacks into mysql-<version>-linux-glibc*-<arch>; relocate it.
    local unpacked
    unpacked="$(find "${PERF_WORK_DIR}" -maxdepth 1 -type d -name "mysql-${SOFTWARE_VERSION}-*" | head -n 1)"
    [[ -n "${unpacked}" ]] || {
        log "ERROR: cannot locate the unpacked mysql directory"
        return 40
    }
    mv "${unpacked}" "${MYSQL_BASE_DIR}"
}

ensure_tools() {
    local os_id missing=0
    command -v python3 >/dev/null 2>&1 || { log "ERROR: python3 is missing"; missing=1; }
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        log "ERROR: curl or wget is required to fetch the tarball"
        missing=1
    fi
    if ! command -v sysbench >/dev/null 2>&1; then
        os_id="$(detect_os_id)"
        log "installing sysbench (benchmark driver) and libaio"
        case "${os_id}" in
            ubuntu|debian)
                apt-get update -qq
                apt-get install -y -qq sysbench libaio1 2>/dev/null || apt-get install -y -qq sysbench libaio1t64 2>/dev/null || true
                ;;
            openeuler|centos|rhel|fedora|rocky|almalinux|anolis)
                dnf install -y sysbench libaio 2>/dev/null || yum install -y sysbench libaio 2>/dev/null || true
                ;;
            *)
                log "WARN: unsupported OS \"${os_id}\"; install sysbench manually"
                ;;
        esac
    fi
    command -v sysbench >/dev/null 2>&1 || { log "ERROR: sysbench is still missing"; missing=1; }
    [[ "${missing}" -eq 0 ]]
}

read_mysqld_version() {
    "${MYSQLD_BIN}" --version 2>/dev/null | sed -nE 's/.*Ver ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p'
}

resolve_mysqld_user() {
    if has_root; then
        printf 'root\n'
    else
        printf '%s\n' "$(id -un)"
    fi
}

server_reachable() {
    "${MYSQL_BIN}" -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_DB_USER}" \
        ${MYSQL_PASSWORD:+-p"${MYSQL_PASSWORD}"} -N -e "SELECT 1" >/dev/null 2>&1
}

build_mysql() {
    local tarball actual_version
    initialize_runtime || return $?
    check_architecture || return $?
    ensure_tools || return 30
    [[ ! -e "${MYSQL_BASE_DIR}/bin/mysqld" ]] || {
        log "ERROR: build output is not clean under ${PERF_WORK_DIR}"
        return 20
    }

    tarball="$(fetch_tarball)" || return 30
    extract_tarball "${tarball}" || return 40

    [[ -x "${MYSQLD_BIN}" && -x "${MYSQL_BIN}" ]] || {
        log "ERROR: mysqld/mysql binaries not found after extraction"
        return 40
    }
    actual_version="$(read_mysqld_version)"
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log "ERROR: installed mysqld is ${actual_version}, expected ${SOFTWARE_VERSION}"
        return 40
    }
    : "${PERF_ACTUAL_VERSION_FILE:?Framework did not provide PERF_ACTUAL_VERSION_FILE}"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "mysqld ${actual_version} deployed from the official prebuilt tarball"
}

start_mysql_service() {
    local mysqld_user attempt
    initialize_runtime || return $?
    [[ -x "${MYSQLD_BIN}" && -x "${MYSQL_BIN}" ]] || {
        log "ERROR: MySQL is not deployed (run build first)"
        return 40
    }

    if server_reachable; then
        log "using the already running MySQL at ${MYSQL_HOST}:${MYSQL_PORT}"
        MYSQL_EXTERNAL=1
        return 0
    fi

    mysqld_user="$(resolve_mysqld_user)"
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
    "${MYSQL_BIN}" --socket="${SOCKET_PATH}" -u root -N -e "SELECT 1" >/dev/null 2>&1 || {
        log "ERROR: mysqld did not become ready (see ${ERR_LOG})"
        return 40
    }

    # Allow the benchmark client to connect over TCP with the configured account.
    if [[ "${MYSQL_DB_USER}" == "root" ]]; then
        "${MYSQL_BIN}" --socket="${SOCKET_PATH}" -u root <<'SQL' || return 40
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SQL
    else
        "${MYSQL_BIN}" --socket="${SOCKET_PATH}" -u root <<SQL || return 40
CREATE USER IF NOT EXISTS '${MYSQL_DB_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_DB_USER}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SQL
    fi

    server_reachable || {
        log "ERROR: benchmark account is not reachable over TCP"
        return 40
    }
    log "MySQL service is ready for benchmarking"
}

run_mysql_benchmarks() {
    initialize_runtime || return $?
    server_reachable || {
        log "ERROR: MySQL is not reachable on ${MYSQL_HOST}:${MYSQL_PORT}"
        return 50
    }
    export SOFTWARE_VERSION EXPECTED_ARCH
    log "running OLTP benchmark (sysbench)"
    python3 "${SCRIPT_DIR}/scripts/benchmark_mysql.py" \
        "${RESULTS_DIR}/benchmark_mysql.json" \
        "${MYSQL_HOST}" "${MYSQL_PORT}" "${MYSQL_DB_USER}" "${MYSQL_PASSWORD}" "${MYSQL_DB}" \
        "${TABLES}" "${TABLE_SIZE}" "${ITERATIONS}" "${TIME_PER_TEST}" || return 50
    log "running micro benchmark (sysbench)"
    python3 "${SCRIPT_DIR}/scripts/micro_benchmark.py" \
        "${RESULTS_DIR}/micro_benchmark.json" \
        "${MYSQL_HOST}" "${MYSQL_PORT}" "${MYSQL_DB_USER}" "${MYSQL_PASSWORD}" \
        "${TABLES}" "${TABLE_SIZE}" "${ITERATIONS}" "${TIME_PER_TEST}" || return 50
    python3 "${SCRIPT_DIR}/scripts/aggregate_results.py" \
        "${RESULTS_DIR}" "${RESULTS_DIR}/results.json" || return 50
}

stop_mysql_service() {
    local attempt
    [[ "${MYSQL_EXTERNAL}" -eq 1 ]] && {
        log "MySQL was pre-existing; leaving it running"
        return 0
    }
    [[ -f "${SOCKET_PATH}" ]] || {
        log "no managed MySQL socket; nothing to stop"
        return 0
    }
    "${MYSQLADMIN_BIN}" --socket="${SOCKET_PATH}" -u root shutdown >/dev/null 2>&1 || \
        "${MYSQL_BIN}" --socket="${SOCKET_PATH}" -u root -e "SHUTDOWN" >/dev/null 2>&1 || true

    for attempt in {1..20}; do
        if [[ -f "${PID_FILE}" ]] && ! kill -0 "$(cat "${PID_FILE}" 2>/dev/null)" 2>/dev/null; then
            break
        fi
        "${MYSQL_BIN}" --socket="${SOCKET_PATH}" -u root -N -e "SELECT 1" >/dev/null 2>&1 || break
        sleep 0.5
    done
    if "${MYSQL_BIN}" --socket="${SOCKET_PATH}" -u root -N -e "SELECT 1" >/dev/null 2>&1; then
        log "ERROR: MySQL is still reachable on socket ${SOCKET_PATH}"
        return 50
    fi
    log "MySQL service stopped"
}