#!/usr/bin/env bash
set -euo pipefail

CASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="clickhouse"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-24.5.1.1763}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

CH_OFFLINE_DIR="${CLICKHOUSE_OFFLINE_DIR:-/home/runner/software/clickhouse}"
CH_IMAGE_ARCHIVE_DIR="${CLICKHOUSE_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
CH_TPCH_OFFLINE_DIR="${CLICKHOUSE_TPCH_OFFLINE_DIR:-/home/runner/software/tpch}"
CH_CA_ANCHORS_DIR="${CLICKHOUSE_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
CH_PACKAGE_BASE_URL="https://packages.clickhouse.com/tgz/stable"

# Container specification, identical to the ZooKeeper case.
CH_CPUSET="${CLICKHOUSE_CPUSET:-0-31}"
CH_MEMSET="${CLICKHOUSE_MEMSET:-0}"
CH_MEMORY="${CLICKHOUSE_MEMORY:-128g}"
CH_MEMORY_SWAP="${CLICKHOUSE_MEMORY_SWAP:-128g}"

# Fixed query settings from bdperf 03 §7.2; must be identical on both architectures.
CH_MAX_THREADS="${CLICKHOUSE_MAX_THREADS:-32}"
CH_MAX_MEMORY_USAGE="${CLICKHOUSE_MAX_MEMORY_USAGE:-110000000000}"
CH_MAX_SERVER_MEMORY_USAGE="${CLICKHOUSE_MAX_SERVER_MEMORY_USAGE:-120000000000}"
CH_MARK_CACHE_SIZE="${CLICKHOUSE_MARK_CACHE_SIZE:-5368709120}"
CH_SF="${CLICKHOUSE_SF:-1}"
CH_ROUNDS="${CLICKHOUSE_ROUNDS:-3}"
CH_DATABASE="tpch_sf${CH_SF}"

log_message() { printf '[clickhouse] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }
log_error() { printf '[clickhouse] [%s] ERROR: %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*" >&2; }

# SHA-256 of the official packages.clickhouse.com archives, recorded when this
# case was adapted. They are the only checksum the vendor publishes.
ch_package_sha256() {
    local package="$1" arch="$2"
    case "${package}:${arch}" in
        common-static:amd64) printf '%s' '81b6bbe064a72d9008e7f5f15d5401ed6a2f2a3ebe7681d9770d308c41ceec71' ;;
        common-static:arm64) printf '%s' 'ba5b731a48f453692f50efde7cf84b481752224b87363f5619eaadd09d9f79ab' ;;
        server:amd64)        printf '%s' 'cc0bfd012b8bd508df480b94110f2c22cd3b6229d401418a4783a6b507e5f7de' ;;
        server:arm64)        printf '%s' 'fb9422f18871a98e6bad7f333f5bff4110817d4fdde3e3b2c432925b3e36f59f' ;;
        client:amd64)        printf '%s' '17efe91fe17527eafd31247f288bafbeee6356eecba8a537ee396b6eac5a0ed4' ;;
        client:arm64)        printf '%s' '7a08cd6401b62535bbb0743abee318f8b945ef7687f7fe2f904c01e22600327f' ;;
        *) return 1 ;;
    esac
}

configure_runtime_paths() {
    [[ "${SOFTWARE_VERSION}" == "24.5.1.1763" ]] || {
        log_error "unsupported ClickHouse version: ${SOFTWARE_VERSION}"; return 10;
    }
    [[ "${PERF_VARIANT}" == base || "${PERF_VARIANT}" == optimized ]] || return 10
    [[ "${EXPECTED_ARCH}" == "$(uname -m)" ]] || {
        log_error "EXPECTED_ARCH ${EXPECTED_ARCH} differs from runner architecture $(uname -m)"; return 20;
    }
    case "${EXPECTED_ARCH}" in
        x86_64) CH_PACKAGE_ARCH="amd64" ;;
        aarch64) CH_PACKAGE_ARCH="arm64" ;;
        *) log_error "unsupported architecture: ${EXPECTED_ARCH}"; return 20 ;;
    esac
    PERF_RUN_ID="${PERF_RUN_ID:-local-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || return 10
    PERF_WORK_DIR="${PERF_WORK_DIR:-/home/runner/boostkit-perf/clickhouse/local-${PERF_RUN_ID}}"
    RESULTS_DIR="${RESULTS_DIR:-${CASE_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}}"
    [[ "${RESULTS_DIR}" == /* ]] || RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${PERF_WORK_DIR}/actual-version.txt}"
    CH_PKG_DIR="${PERF_WORK_DIR}/ch-pkgs"
    CH_HOME="${PERF_WORK_DIR}/clickhouse"
    CH_BIN="${CH_HOME}/bin/clickhouse"
    CH_CONF="${PERF_WORK_DIR}/conf/config.xml"
    CH_USERS="${PERF_WORK_DIR}/conf/users.xml"
    CH_DATA="${PERF_WORK_DIR}/data/clickhouse"
    CH_LOG_DIR="${PERF_WORK_DIR}/logs"
    CH_RESULT_DIR="${RESULTS_DIR}/clickhouse-official"
    CH_CONTAINER_NAME="boostkit-clickhouse-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    CH_IMAGE_FILE="${PERF_WORK_DIR}/container-image.txt"
    local checksum
    checksum="$(printf '%s' "${PERF_RUN_ID}" | cksum)"
    CH_TCP_PORT="$((19000 + ${checksum%% *} % 400))"
    CH_HTTP_PORT="$((19500 + ${checksum%% *} % 400))"
    [[ "${CH_ROUNDS}" =~ ^[1-9][0-9]*$ ]] || { log_error "CLICKHOUSE_ROUNDS must be positive"; return 10; }
    [[ "${CH_SF}" =~ ^[1-9][0-9]*$ ]] || { log_error "CLICKHOUSE_SF must be positive"; return 10; }
    export PERF_WORK_DIR RESULTS_DIR PERF_ACTUAL_VERSION_FILE
    export CH_PKG_DIR CH_HOME CH_BIN CH_CONF CH_USERS CH_DATA CH_LOG_DIR CH_RESULT_DIR
    export CH_CONTAINER_NAME CH_TCP_PORT CH_HTTP_PORT CH_SF CH_ROUNDS CH_DATABASE
    export CH_PACKAGE_ARCH CH_MAX_THREADS CH_MAX_MEMORY_USAGE CH_MAX_SERVER_MEMORY_USAGE
    export CH_MARK_CACHE_SIZE CH_CPUSET CH_MEMSET CH_MEMORY CH_MEMORY_SWAP
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}/tmp" "${CH_LOG_DIR}" "${CH_RESULT_DIR}"
}

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else
        "$@"
    fi
}

require_docker() {
    command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1 || {
        log_error 'an accessible Docker daemon is required'; return 30;
    }
}

ch_exec() {
    docker exec -e "HOME=${PERF_WORK_DIR}" -e "TMPDIR=${PERF_WORK_DIR}/tmp" \
        "${CH_CONTAINER_NAME}" "$@"
}

ch_exec_root() {
    local -a proxy=()
    [[ -z "${PERF_PROXY:-}" ]] || proxy=(--setopt="proxy=${PERF_PROXY}")
    docker exec --user 0 "${CH_CONTAINER_NAME}" dnf "${proxy[@]}" "$@"
}

check_container() {
    [[ "$(docker inspect --format '{{.State.Running}}' "${CH_CONTAINER_NAME}" 2>/dev/null)" == true ]] || {
        log_error "managed container is not running: ${CH_CONTAINER_NAME}"; return 40;
    }
    local label
    label="$(docker inspect --format '{{index .Config.Labels "boostkit.clickhouse.run-id"}}' "${CH_CONTAINER_NAME}" 2>/dev/null)"
    [[ "${label}" == "${PERF_RUN_ID}" ]] || {
        log_error "container label differs from run id ${PERF_RUN_ID}"; return 40;
    }
}
