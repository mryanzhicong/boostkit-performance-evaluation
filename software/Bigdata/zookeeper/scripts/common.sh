#!/usr/bin/env bash
set -euo pipefail

CASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="zookeeper"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-3.6.2}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# Offline inputs. Production runners keep them under /home/runner/software;
# a local run may point these variables at any prepared directory.
ZK_OFFLINE_DIR="${ZOOKEEPER_OFFLINE_DIR:-/home/runner/software/zookeeper}"
ZK_IMAGE_ARCHIVE_DIR="${ZOOKEEPER_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
ZK_JDK_OFFLINE_DIR="${ZOOKEEPER_JDK_OFFLINE_DIR:-/home/runner/software/bishengjdk}"
ZK_CA_ANCHORS_DIR="${ZOOKEEPER_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
ZK_ARCHIVE_NAME="apache-zookeeper-3.6.2-bin.tar.gz"
ZK_ARCHIVE_SHA512="caff5111bb6876b7124760bc006e6fa2523efa54b99321a3c9cd8192ea0d5596abc7d70a054b1aac9b20a411407dae7611c7aba870c23bff28eb1643ba499199"
BISHENG_JDK_RELEASE="8u472-b11"
BISHENG_JDK_BASE_URL="https://repo.huaweicloud.com/kunpeng/archive/compiler/bisheng_jdk"

# Container specification. The fixed values below are the comparison boundary:
# 32 physical cores on one NUMA node, 128 GiB, unlimited memlock. They can be
# overridden only for a local smoke run on a smaller machine; the README records
# which values the formal run uses.
ZK_CPUSET="${ZOOKEEPER_CPUSET:-0-31}"
ZK_MEMSET="${ZOOKEEPER_MEMSET:-0}"
ZK_MEMORY="${ZOOKEEPER_MEMORY:-128g}"
ZK_MEMORY_SWAP="${ZOOKEEPER_MEMORY_SWAP:-128g}"

# Fixed workload (bdperf 01 §9/§10). Per-thread warmup is applied inside ZkBench.
ZK_KEYSPACE="${ZOOKEEPER_KEYSPACE:-1000000}"
ZK_VALUE_SIZE="${ZOOKEEPER_VALUE_SIZE:-1024}"
ZK_ROUNDS="${ZOOKEEPER_ROUNDS:-3}"
ZK_MODES="${ZOOKEEPER_MODES:-read update mixed create}"
ZK_THREADS="${ZOOKEEPER_THREADS:-1 8 32 64}"
ZK_WARMUP_OPS="${ZOOKEEPER_WARMUP_OPS:-2000}"
ZK_JVM_FLAGS="${ZOOKEEPER_JVM_FLAGS:--Xms4g -Xmx4g -XX:ActiveProcessorCount=8 -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch}"

log_message() { printf '[zookeeper] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }
log_error() { printf '[zookeeper] [%s] ERROR: %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*" >&2; }

# Total operations per concurrency level, from bdperf 01 §9.
zk_total_ops() {
    case "$1" in
        1)  printf '20000' ;;
        8)  printf '40000' ;;
        32) printf '200000' ;;
        64) printf '400000' ;;
        *)  printf '200000' ;;
    esac
}

zk_threads_valid() {
    local thread
    for thread in ${ZK_THREADS}; do
        [[ "${thread}" == "1" || "${thread}" == "8" || "${thread}" == "32" || "${thread}" == "64" ]] || return 1
    done
}

configure_runtime_paths() {
    [[ "${SOFTWARE_VERSION}" == "3.6.2" ]] || {
        log_error "unsupported ZooKeeper version: ${SOFTWARE_VERSION}"; return 10;
    }
    [[ "${PERF_VARIANT}" == base || "${PERF_VARIANT}" == optimized ]] || return 10
    [[ "${EXPECTED_ARCH}" == "$(uname -m)" ]] || {
        log_error "EXPECTED_ARCH ${EXPECTED_ARCH} differs from runner architecture $(uname -m)"; return 20;
    }
    case "${EXPECTED_ARCH}" in
        x86_64|aarch64) ;;
        *) log_error "unsupported architecture: ${EXPECTED_ARCH}"; return 20 ;;
    esac
    PERF_RUN_ID="${PERF_RUN_ID:-local-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || return 10
    PERF_WORK_DIR="${PERF_WORK_DIR:-/home/runner/boostkit-perf/zookeeper/local-${PERF_RUN_ID}}"
    RESULTS_DIR="${RESULTS_DIR:-${CASE_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}}"
    [[ "${RESULTS_DIR}" == /* ]] || RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${PERF_WORK_DIR}/actual-version.txt}"
    ZK_HOME="${PERF_WORK_DIR}/apache-zookeeper-3.6.2-bin"
    ZK_JDK_HOME="${PERF_WORK_DIR}/bisheng-jdk"
    ZK_CONF_DIR="${PERF_WORK_DIR}/conf"
    ZK_DATA_DIR="${PERF_WORK_DIR}/data/zk/data"
    ZK_LOG_DIR="${PERF_WORK_DIR}/data/zk/log"
    ZK_BENCH_DIR="${PERF_WORK_DIR}/tools/zkbench"
    ZK_RESULT_DIR="${RESULTS_DIR}/zookeeper-official"
    ZK_CONTAINER_NAME="boostkit-zookeeper-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    ZK_IMAGE_FILE="${PERF_WORK_DIR}/container-image.txt"
    local checksum
    checksum="$(printf '%s' "${PERF_RUN_ID}" | cksum)"
    ZK_CLIENT_PORT="$((22000 + ${checksum%% *} % 10000))"
    [[ -n "${ZK_KEYSPACE}" && "${ZK_KEYSPACE}" =~ ^[1-9][0-9]*$ ]] || {
        log_error "ZOOKEEPER_KEYSPACE must be a positive integer"; return 10;
    }
    [[ "${ZK_ROUNDS}" =~ ^[1-9][0-9]*$ ]] || { log_error "ZOOKEEPER_ROUNDS must be positive"; return 10; }
    zk_threads_valid || { log_error "unsupported ZOOKEEPER_THREADS: ${ZK_THREADS}"; return 10; }
    export PERF_WORK_DIR RESULTS_DIR PERF_ACTUAL_VERSION_FILE
    export ZK_HOME ZK_JDK_HOME ZK_CONF_DIR ZK_DATA_DIR ZK_LOG_DIR ZK_BENCH_DIR ZK_RESULT_DIR
    export ZK_CLIENT_PORT ZK_KEYSPACE ZK_VALUE_SIZE ZK_ROUNDS ZK_MODES ZK_THREADS ZK_WARMUP_OPS
    export ZK_CONTAINER_NAME ZK_JVM_FLAGS ZK_CPUSET ZK_MEMSET ZK_MEMORY ZK_MEMORY_SWAP
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}/tmp" "${PERF_WORK_DIR}/logs" "${RESULTS_DIR}"
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

zk_exec() {
    docker exec -e "HOME=${PERF_WORK_DIR}" -e "TMPDIR=${PERF_WORK_DIR}/tmp" \
        -e "JAVA_HOME=${ZK_JDK_HOME}" \
        -e "PATH=${ZK_JDK_HOME}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
        "${ZK_CONTAINER_NAME}" "$@"
}

zk_exec_root() {
    local -a proxy=()
    [[ -z "${PERF_PROXY:-}" ]] || proxy=(--setopt="proxy=${PERF_PROXY}")
    docker exec --user 0 "${ZK_CONTAINER_NAME}" dnf "${proxy[@]}" "$@"
}

# Shared by start and test: every stage runs in a new shell.
zk_mntr() {
    zk_exec bash -c "exec 3<>/dev/tcp/127.0.0.1/${ZK_CLIENT_PORT}; printf 'mntr\n' >&3; cat <&3" 2>/dev/null
}

check_container() {
    [[ "$(docker inspect --format '{{.State.Running}}' "${ZK_CONTAINER_NAME}" 2>/dev/null)" == true ]] || {
        log_error "managed container is not running: ${ZK_CONTAINER_NAME}"; return 40;
    }
    local label
    label="$(docker inspect --format '{{index .Config.Labels "boostkit.zookeeper.run-id"}}' "${ZK_CONTAINER_NAME}" 2>/dev/null)"
    [[ "${label}" == "${PERF_RUN_ID}" ]] || {
        log_error "container label differs from run id ${PERF_RUN_ID}"; return 40;
    }
}
