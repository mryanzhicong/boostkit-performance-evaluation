#!/usr/bin/env bash
set -euo pipefail

CASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="hbase"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-2.4.14}"
HADOOP_VERSION="3.3.6"
ZOOKEEPER_VERSION="3.6.2"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

HBASE_OFFLINE_DIR="${HBASE_OFFLINE_DIR:-/home/runner/software/hbase}"
HADOOP_OFFLINE_DIR="${HADOOP_OFFLINE_DIR:-/home/runner/software/hadoop}"
ZK_OFFLINE_DIR="${HBASE_ZK_OFFLINE_DIR:-/home/runner/software/zookeeper}"
JDK_OFFLINE_DIR="${HBASE_JDK_OFFLINE_DIR:-/home/runner/software/bishengjdk}"
IMAGE_ARCHIVE_DIR="${HBASE_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
CA_ANCHORS_DIR="${HBASE_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
BISHENG_JDK_RELEASE="8u472-b11"
BISHENG_JDK_BASE_URL="https://repo.huaweicloud.com/kunpeng/archive/compiler/bisheng_jdk"

HBASE_CPUSET="${HBASE_CPUSET:-0-31}"
HBASE_MEMSET="${HBASE_MEMSET:-0}"
HBASE_MEMORY="${HBASE_MEMORY:-128g}"
HBASE_MEMORY_SWAP="${HBASE_MEMORY_SWAP:-128g}"

# Fixed software parameters from bdperf 02 §7.2. Local smoke runs may reduce the
# memory sizes because the comparison container is 128 GiB; production uses these.
HBASE_RS_HEAP="${HBASE_RS_HEAP:-30g}"
HBASE_MASTER_HEAP="${HBASE_MASTER_HEAP:-8g}"
HBASE_DIRECT_MEMORY="${HBASE_DIRECT_MEMORY:-48g}"
HBASE_BUCKET_CACHE_MB="${HBASE_BUCKET_CACHE_MB:-24576}"
HBASE_DATA_SIZE_GB="${HBASE_DATA_SIZE_GB:-2}"
HBASE_PRESPLIT="${HBASE_PRESPLIT:-16}"
HBASE_WRITE_MAPS="${HBASE_WRITE_MAPS:-4}"
HBASE_READ_THREADS="${HBASE_READ_THREADS:-8}"
HBASE_READ_ROWS="${HBASE_READ_ROWS:-100000}"
HBASE_ROUNDS="${HBASE_ROUNDS:-3}"

log_message() { printf '[hbase] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }
log_error() { printf '[hbase] [%s] ERROR: %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*" >&2; }

# SHA-256 of the official release archives used by this case.
hbase_artifact_sha256() {
    case "$1:${EXPECTED_ARCH}" in
        hbase:x86_64|hbase:aarch64)
            printf '%s' '04d5c2f46ce4d1e1b80dcf4740d7c8e6c6a371f4a44f5561dfc55c703df00b1e' ;;
        zookeeper:x86_64|zookeeper:aarch64)
            printf '%s' '476f6fce10f9528e3a4ad00e6cd1714563f602dd4924db78e506c0df28fea1e5' ;;
        hadoop:x86_64)
            printf '%s' 'f5195059c0d4102adaa7fff17f7b2a85df906bcb6e19948716319f9978641a04' ;;
        hadoop:aarch64)
            printf '%s' 'e4bbf6b80ef604912f6b9bf6ca77323dee6028d08d38f36ca077df56de8a5d0d' ;;
        jdk:x86_64)
            printf '%s' '45d5daf61a2670d20c7c2eed476577d7ef2d685a84f9f963464e8413b2b8c012' ;;
        jdk:aarch64)
            printf '%s' 'b5366023c742a29e0527c0c2d6bdd207a625084969e2693a248a0f328ad2c031' ;;
        *) return 1 ;;
    esac
}

hadoop_archive_name() {
    case "${EXPECTED_ARCH}" in
        x86_64) printf 'hadoop-%s.tar.gz' "${HADOOP_VERSION}" ;;
        aarch64) printf 'hadoop-%s-aarch64.tar.gz' "${HADOOP_VERSION}" ;;
        *) return 1 ;;
    esac
}

configure_runtime_paths() {
    [[ "${SOFTWARE_VERSION}" == "2.4.14" ]] || { log_error "unsupported HBase version: ${SOFTWARE_VERSION}"; return 10; }
    [[ "${PERF_VARIANT}" == base || "${PERF_VARIANT}" == optimized ]] || return 10
    [[ "${EXPECTED_ARCH}" == "$(uname -m)" ]] || {
        log_error "EXPECTED_ARCH ${EXPECTED_ARCH} differs from runner architecture $(uname -m)"; return 20;
    }
    HADOOP_ARCHIVE="$(hadoop_archive_name)" || { log_error "unsupported architecture: ${EXPECTED_ARCH}"; return 20; }
    PERF_RUN_ID="${PERF_RUN_ID:-local-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || return 10
    PERF_WORK_DIR="${PERF_WORK_DIR:-/home/runner/boostkit-perf/hbase/local-${PERF_RUN_ID}}"
    RESULTS_DIR="${RESULTS_DIR:-${CASE_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}}"
    [[ "${RESULTS_DIR}" == /* ]] || RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${PERF_WORK_DIR}/actual-version.txt}"
    HBASE_HOME="${PERF_WORK_DIR}/hbase-${SOFTWARE_VERSION}"
    HADOOP_HOME="${PERF_WORK_DIR}/hadoop-${HADOOP_VERSION}"
    ZK_HOME="${PERF_WORK_DIR}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin"
    JDK_HOME="${PERF_WORK_DIR}/bisheng-jdk"
    HBASE_CONF_DIR="${PERF_WORK_DIR}/conf"
    HBASE_DATA="${PERF_WORK_DIR}/data/hbase"
    HBASE_LOG_DIR="${PERF_WORK_DIR}/logs"
    HBASE_RESULT_DIR="${RESULTS_DIR}/hbase-official"
    CONTAINER_NAME="boostkit-hbase-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    IMAGE_FILE="${PERF_WORK_DIR}/container-image.txt"
    local checksum offset
    checksum="$(printf '%s' "${PERF_RUN_ID}" | cksum)"
    offset="$(( ${checksum%% *} % 500 ))"
    ZK_CLIENT_PORT="$((22100 + offset))"
    HDFS_NN_PORT="$((23000 + offset))"
    HDFS_NN_HTTP_PORT="$((23001 + offset))"
    HDFS_DN_PORT="$((23002 + offset))"
    HDFS_DN_HTTP_PORT="$((23003 + offset))"
    HBASE_MASTER_PORT="$((24000 + offset))"
    HBASE_MASTER_INFO_PORT="$((24001 + offset))"
    HBASE_RS_PORT="$((24002 + offset))"
    HBASE_RS_INFO_PORT="$((24003 + offset))"
    export PERF_WORK_DIR RESULTS_DIR PERF_ACTUAL_VERSION_FILE
    export HBASE_HOME HADOOP_HOME ZK_HOME JDK_HOME HBASE_CONF_DIR HBASE_DATA HBASE_LOG_DIR HBASE_RESULT_DIR
    export CONTAINER_NAME ZK_CLIENT_PORT HDFS_NN_PORT HDFS_NN_HTTP_PORT HDFS_DN_PORT HDFS_DN_HTTP_PORT
    export HBASE_MASTER_PORT HBASE_MASTER_INFO_PORT HBASE_RS_PORT HBASE_RS_INFO_PORT
    export HBASE_RS_HEAP HBASE_MASTER_HEAP HBASE_DIRECT_MEMORY HBASE_BUCKET_CACHE_MB
    export HBASE_DATA_SIZE_GB HBASE_PRESPLIT HBASE_WRITE_MAPS HBASE_READ_THREADS HBASE_READ_ROWS HBASE_ROUNDS
    export HADOOP_ARCHIVE HBASE_CPUSET HBASE_MEMSET HBASE_MEMORY HBASE_MEMORY_SWAP HADOOP_VERSION ZOOKEEPER_VERSION
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}/tmp" "${HBASE_LOG_DIR}" "${HBASE_RESULT_DIR}"
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

hbase_exec() {
    docker exec -e "HOME=${PERF_WORK_DIR}" -e "TMPDIR=${PERF_WORK_DIR}/tmp" \
        -e "JAVA_HOME=${JDK_HOME}" \
        -e "HADOOP_CONF_DIR=${HBASE_CONF_DIR}" -e "HBASE_CONF_DIR=${HBASE_CONF_DIR}" \
        -e "HBASE_LOG_DIR=${HBASE_LOG_DIR}" -e "HBASE_PID_DIR=${PERF_WORK_DIR}/pids" \
        -e "PATH=${JDK_HOME}/bin:${HADOOP_HOME}/bin:${HBASE_HOME}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
        "${CONTAINER_NAME}" "$@"
}

hbase_exec_root() {
    local -a proxy=()
    [[ -z "${PERF_PROXY:-}" ]] || proxy=(--setopt="proxy=${PERF_PROXY}")
    docker exec --user 0 "${CONTAINER_NAME}" dnf "${proxy[@]}" "$@"
}

check_container() {
    [[ "$(docker inspect --format '{{.State.Running}}' "${CONTAINER_NAME}" 2>/dev/null)" == true ]] || {
        log_error "managed container is not running: ${CONTAINER_NAME}"; return 40;
    }
    local label
    label="$(docker inspect --format '{{index .Config.Labels "boostkit.hbase.run-id"}}' "${CONTAINER_NAME}" 2>/dev/null)"
    [[ "${label}" == "${PERF_RUN_ID}" ]] || {
        log_error "container label differs from run id ${PERF_RUN_ID}"; return 40;
    }
}
