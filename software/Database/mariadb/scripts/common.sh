#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="mariadb"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-11.8.10}"
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

# Connection and workload settings (replicated from MySQL exception topology with confirmed medium OLTP scale).
MARIADB_HOST="${MARIADB_HOST:-127.0.0.1}"
MARIADB_PORT="${MARIADB_PORT:-}"
MARIADB_BASE_PORT="${MARIADB_PORT}"
MARIADB_INSTANCE_COUNT=1
MARIADB_INSTANCE_ID=1
MARIADB_DB_USER="${MARIADB_DB_USER:-root}"
MARIADB_PASSWORD="${MARIADB_PASSWORD:-}"
MARIADB_DATA_ROOT="${MARIADB_DATA_ROOT:-}"
MARIADB_PREPARED_STMT_LIMIT=1048576
MARIADB_TABLES=16
MARIADB_TABLE_SIZE=1000000
MARIADB_PREPARE_THREADS=16
MARIADB_WARMUP_THREADS=64
MARIADB_WARMUP_SECONDS=60
MARIADB_MEASURE_SECONDS=60

MARIADB_IMAGE_ARCHIVE_DIR="${MARIADB_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
MARIADB_CA_ANCHORS_DIR="${MARIADB_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
MARIADB_OFFLINE_DIR="${MARIADB_OFFLINE_DIR:-/home/runner/software/mariadb}"
MARIADB_SOURCE_ARCHIVE="mariadb-11.8.10.tar.gz"
MARIADB_SOURCE_URL="${MARIADB_SOURCE_URL:-https://archive.mariadb.org/mariadb-11.8.10/source/mariadb-11.8.10.tar.gz}"
MARIADB_SOURCE_SHA256="${MARIADB_SOURCE_SHA256:-77d62a86477d5b836da960f5228eb4e13458692ab775f2ad95d55fd4a4d3b117}"
MARIADB_CONTAINER_IMAGE=""
MARIADB_CONTAINER_NAME=""
MARIADB_CONTAINER_LABEL="boostkit.mariadb.run-id"

# Lifecycle paths (assigned in configure_runtime_paths).
MARIADB_HOME_DIR=""
MARIADB_SOURCE_DIR=""
MARIADB_BUILD_DIR=""
MARIADB_BASE_DIR=""
MARIADBD_BIN=""
MARIADB_BIN=""
MARIADB_ADMIN_BIN=""
MARIADB_INSTALL_DB_BIN=""
MARIADB_CONFIG_BIN=""
MARIADB_INSTANCES_DIR=""
SERVICE_DIR=""
DATADIR=""
SOCKET_PATH=""
PID_FILE=""
ERR_LOG=""
MARIADB_TMP_DIR=""
MARIADB_SNAPSHOT_DIR=""
MARIADB_IMAGE_STATE_FILE=""
SYSBENCH_BIN=""
SYSBENCH_LUA_DIR=""

log_message() {
    printf '[mariadb] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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

configure_mariadb_instance() {
    local instance_id="$1"
    if [[ ! "${instance_id}" =~ ^[1-9][0-9]*$ ]] || (( instance_id > MARIADB_INSTANCE_COUNT )); then
        log_message "ERROR: MariaDB instance ${instance_id} is not enabled"
        return 10
    fi
    MARIADB_INSTANCE_ID="${instance_id}"
    SERVICE_DIR="${MARIADB_INSTANCES_DIR}/${instance_id}"
    DATADIR="${SERVICE_DIR}/data"
    SOCKET_PATH="${SERVICE_DIR}/mariadb.sock"
    PID_FILE="${SERVICE_DIR}/mariadb.pid"
    ERR_LOG="${SERVICE_DIR}/mariadb.err"
    MARIADB_TMP_DIR="${SERVICE_DIR}/tmp"
    MARIADB_SNAPSHOT_DIR="${SERVICE_DIR}/snapshot"
    MARIADB_CONTAINER_NAME="boostkit-mariadb-${EXPECTED_ARCH}-${PERF_RUN_ID}-${instance_id}"
    MARIADB_PORT="$((MARIADB_BASE_PORT + instance_id - 1))"
    TMPDIR="${MARIADB_TMP_DIR}"
    export TMPDIR
}

configure_runtime_paths() {
    [[ "${SOFTWARE_VERSION}" == "11.8.10" ]] || {
        log_message "ERROR: only MariaDB 11.8.10 is supported (got ${SOFTWARE_VERSION})"
        return 10
    }
    validate_variant || return $?
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    EXPECTED_ARCH="$(normalize_architecture "${EXPECTED_ARCH}")"
    case "${EXPECTED_ARCH}" in
        x86_64|aarch64) ;;
        *) log_message "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"; return 20 ;;
    esac
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/mariadb/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    elif [[ "${PERF_WORK_DIR}" != /* ]]; then
        log_message "ERROR: PERF_WORK_DIR must be absolute: ${PERF_WORK_DIR}"
        return 10
    fi
    case "${PERF_WORK_DIR}" in
        /|/tmp|/home|/home/runner|/home/runner/boostkit-perf)
            log_message "ERROR: PERF_WORK_DIR is too broad: ${PERF_WORK_DIR}"
            return 10
            ;;
    esac
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    if [[ -n "${MARIADB_DATA_ROOT}" && "${MARIADB_DATA_ROOT}" != "${PERF_WORK_DIR}/instances" ]]; then
        log_message "ERROR: MARIADB_DATA_ROOT must be this task's instance directory: ${PERF_WORK_DIR}/instances"
        return 10
    fi
    MARIADB_DATA_ROOT="${PERF_WORK_DIR}/instances"
    MARIADB_HOME_DIR="${PERF_WORK_DIR}/home"
    MARIADB_SOURCE_DIR="${PERF_WORK_DIR}/mariadb-${SOFTWARE_VERSION}"
    MARIADB_BUILD_DIR="${PERF_WORK_DIR}/build"
    MARIADB_BASE_DIR="${PERF_WORK_DIR}/mariadb"
    MARIADBD_BIN="${MARIADB_BASE_DIR}/bin/mariadbd"
    MARIADB_BIN="${MARIADB_BASE_DIR}/bin/mariadb"
    MARIADB_ADMIN_BIN="${MARIADB_BASE_DIR}/bin/mariadb-admin"
    MARIADB_INSTALL_DB_BIN="${MARIADB_BASE_DIR}/bin/mariadb-install-db"
    MARIADB_CONFIG_BIN="${MARIADB_BASE_DIR}/bin/mariadb_config"
    MARIADB_INSTANCES_DIR="${MARIADB_DATA_ROOT}"
    MARIADB_IMAGE_STATE_FILE="${PERF_WORK_DIR}/container-image.txt"
    if [[ -z "${MARIADB_BASE_PORT}" ]]; then
        local checksum
        checksum="$(printf '%s' "${PERF_RUN_ID}" | cksum)"
        MARIADB_BASE_PORT="$((20000 + ${checksum%% *} % 20000))"
    fi
    if [[ ! "${MARIADB_BASE_PORT}" =~ ^[1-9][0-9]{0,4}$ ]] || \
       (( MARIADB_BASE_PORT < 1024 || MARIADB_BASE_PORT + MARIADB_INSTANCE_COUNT - 1 > 65535 )); then
        log_message "ERROR: MARIADB_PORT must leave valid ports for all MariaDB instances: ${MARIADB_BASE_PORT}"
        return 10
    fi
    configure_mariadb_instance 1 || return $?
    if [[ -z "${MARIADB_PASSWORD}" ]]; then
        MARIADB_PASSWORD="boostkit-perf-${PERF_RUN_ID}"
    fi
    if [[ ! "${MARIADB_PASSWORD}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: MARIADB_PASSWORD must use only letters, numbers, dots, underscores, or hyphens"
        return 10
    fi
    SYSBENCH_BIN="${PERF_WORK_DIR}/sysbench-tools/sysbench-1.0.20/src/sysbench"
    SYSBENCH_LUA_DIR="${PERF_WORK_DIR}/sysbench-tools/sysbench-1.0.20/src/lua"
    export SOFTWARE_NAME SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID
    export RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export MARIADB_HOME_DIR MARIADB_SOURCE_DIR MARIADB_BUILD_DIR MARIADB_BASE_DIR
    export MARIADB_CONTAINER_NAME MARIADB_IMAGE_STATE_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${MARIADB_HOME_DIR}" "${SERVICE_DIR}" "${MARIADB_TMP_DIR}"
}

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else
        "$@"
    fi
}

select_container_cpu_set() {
    python3 - <<'PY'
import os
from pathlib import Path

node_cpus = []
for cpu in sorted(os.sched_getaffinity(0)):
    node_paths = sorted(Path(f"/sys/devices/system/cpu/cpu{cpu}").glob("node[0-9]*"))
    if node_paths and node_paths[0].name == "node3":
        node_cpus.append(cpu)

if len(node_cpus) < 8:
    raise SystemExit("NUMA node 3 has fewer than eight available CPUs")
print(",".join(map(str, node_cpus)), 3)
PY
}

prepare_mariadb_container_image() {
    local archive_name="openEuler-docker.${EXPECTED_ARCH}.tar.xz"
    local archive checksum expected actual load_output image_architecture release
    local image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${archive_name}"

    if [[ -s "${MARIADB_IMAGE_ARCHIVE_DIR}/${archive_name}" ]]; then
        archive="${MARIADB_IMAGE_ARCHIVE_DIR}/${archive_name}"
        log_message "using local openEuler container image archive: ${archive}"
    else
        archive="${PERF_WORK_DIR}/${archive_name}"
        rm -f -- "${archive}.part"
        log_message "downloading openEuler container image archive: ${image_url}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
            -o "${archive}.part" "${image_url}" || { rm -f -- "${archive}.part"; return 30; }
        mv -- "${archive}.part" "${archive}" || return 30
    fi

    if [[ -s "${MARIADB_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum" ]]; then
        checksum="${MARIADB_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum"
    else
        checksum="${PERF_WORK_DIR}/${archive_name}.sha256sum"
        rm -f -- "${checksum}.part"
        log_message "downloading official image checksum: ${image_url}.sha256sum"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
            -o "${checksum}.part" "${image_url}.sha256sum" || { rm -f -- "${checksum}.part"; return 30; }
        mv -- "${checksum}.part" "${checksum}" || return 30
    fi
    expected="$(awk 'NR == 1 {print $1}' "${checksum}")"
    if [[ ! "${expected}" =~ ^[[:xdigit:]]{64}$ ]]; then
        log_message "ERROR: invalid official image checksum: ${checksum}"
        return 30
    fi
    actual="$(sha256sum "${archive}")"
    if [[ "${actual%% *}" != "${expected,,}" ]]; then
        log_message "ERROR: openEuler container image checksum mismatch: ${archive}"
        return 30
    fi

    log_message "loading verified openEuler container image: ${archive}"
    load_output="$(docker load --input "${archive}")" || return 30
    MARIADB_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [[ -z "${MARIADB_CONTAINER_IMAGE}" ]] || ! docker image inspect "${MARIADB_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${MARIADB_CONTAINER_IMAGE}")"
    case "${EXPECTED_ARCH}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${EXPECTED_ARCH}"; return 30 ;;
    esac
    release="$(docker run --rm --network=none "${MARIADB_CONTAINER_IMAGE}" cat /etc/os-release)" || return 30
    if ! grep -Eq '^ID="?openEuler"?$' <<< "${release}" || \
       ! grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}"; then
        log_message "ERROR: loaded MariaDB image is not openEuler 24.03 LTS SP4"
        return 30
    fi
    printf '%s\n' "${MARIADB_CONTAINER_IMAGE}" > "${MARIADB_IMAGE_STATE_FILE}"
    log_message "openEuler container image is ready: ${MARIADB_CONTAINER_IMAGE} (${image_architecture})"
}

require_mariadb_container() {
    local cpu_set numa_node
    local -a cert_mount=() git_mount=() offline_mount=()

    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message "ERROR: an accessible Docker daemon is required for the MariaDB 8U32G container"
        return 30
    fi
    if docker container inspect "${MARIADB_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse or overwrite an existing container: ${MARIADB_CONTAINER_NAME}"
        return 40
    fi
    prepare_mariadb_container_image || return $?
    read -r cpu_set numa_node < <(select_container_cpu_set) || {
        log_message "ERROR: cannot select available CPUs on NUMA node 3"
        return 40
    }
    [[ -n "${cpu_set}" && -n "${numa_node}" ]] || {
        log_message "ERROR: cannot select available CPUs on NUMA node 3"
        return 40
    }
    if [[ -n "${PERF_PROXY:-}" ]]; then
        if [[ ! -d "${MARIADB_CA_ANCHORS_DIR}" ]]; then
            log_message "ERROR: proxy CA certificate directory is missing: ${MARIADB_CA_ANCHORS_DIR}"
            return 30
        fi
        cert_mount+=(--mount "type=bind,source=${MARIADB_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    if [[ -f /home/runner/.gitconfig ]]; then
        git_mount+=(--mount type=bind,source=/home/runner/.gitconfig,target=/home/runner/.gitconfig,readonly)
    fi
    if [[ -d "${MARIADB_OFFLINE_DIR}" ]]; then
        offline_mount+=(--mount "type=bind,source=${MARIADB_OFFLINE_DIR},target=${MARIADB_OFFLINE_DIR},readonly")
    fi
    log_message "starting 8U32G MariaDB container ${MARIADB_CONTAINER_NAME}: CPUs ${cpu_set}, NUMA ${numa_node}"
    docker run --detach --name "${MARIADB_CONTAINER_NAME}" \
        --label "${MARIADB_CONTAINER_LABEL}=${PERF_RUN_ID}" \
        --cpus=8 --cpuset-cpus="${cpu_set}" --cpuset-mems="${numa_node}" \
        --memory=32g --ulimit nofile=65535:65535 \
        --network=host --user "$(id -u):$(id -g)" \
        -e "HOME=${MARIADB_HOME_DIR}" \
        -e "XDG_CACHE_HOME=${MARIADB_HOME_DIR}/.cache" \
        -e "TMPDIR=${MARIADB_TMP_DIR}" \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${git_mount[@]}" "${offline_mount[@]}" \
        "${MARIADB_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [[ -n "${PERF_PROXY:-}" ]]; then
        log_message "updating CA trust in the private MariaDB container"
        docker exec --user 0 "${MARIADB_CONTAINER_NAME}" update-ca-trust extract || return 30
    fi
    if docker exec --user 0 "${MARIADB_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message "switching private MariaDB container repositories to the Huawei openEuler mirror"
        docker exec --user 0 "${MARIADB_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || return 30
    fi
}

check_mariadb_container() {
    local running label
    running="$(docker inspect --format '{{.State.Running}}' "${MARIADB_CONTAINER_NAME}" 2>/dev/null || true)"
    [[ "${running}" == true ]] || {
        log_message "ERROR: managed MariaDB container is not running: ${MARIADB_CONTAINER_NAME}"
        return 40
    }
    label="$(docker inspect --format "{{index .Config.Labels \"${MARIADB_CONTAINER_LABEL}\"}}" "${MARIADB_CONTAINER_NAME}" 2>/dev/null || true)"
    [[ "${label}" == "${PERF_RUN_ID}" ]] || {
        log_message "ERROR: container label mismatch on ${MARIADB_CONTAINER_NAME}"
        return 40
    }
}

container_exec() {
    local -a proxy=()
    if [[ -n "${PERF_PROXY:-}" ]]; then
        proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}")
    fi
    docker exec "${proxy[@]}" \
        -e "HOME=${MARIADB_HOME_DIR}" \
        -e "XDG_CACHE_HOME=${MARIADB_HOME_DIR}/.cache" \
        -e "TMPDIR=${MARIADB_TMP_DIR}" \
        "${MARIADB_CONTAINER_NAME}" "$@"
}

container_exec_root() {
    local -a proxy=()
    [[ -z "${PERF_PROXY:-}" ]] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}")
    docker exec --user 0 "${proxy[@]}" "${MARIADB_CONTAINER_NAME}" "$@"
}

mariadb_client_exec() {
    local password="${1:-}"
    shift
    local -a pw_env=()
    if [[ -n "${password}" ]]; then
        pw_env=(-e "MYSQL_PWD=${password}" -e "MARIADB_PWD=${password}")
    fi
    docker exec -i "${pw_env[@]}" \
        -e "HOME=${MARIADB_HOME_DIR}" \
        -e "TMPDIR=${MARIADB_TMP_DIR}" \
        "${MARIADB_CONTAINER_NAME}" "$@"
}

remove_mariadb_container() {
    local label
    if ! docker container inspect "${MARIADB_CONTAINER_NAME}" >/dev/null 2>&1; then
        return 0
    fi
    label="$(docker inspect --format "{{index .Config.Labels \"${MARIADB_CONTAINER_LABEL}\"}}" "${MARIADB_CONTAINER_NAME}" 2>/dev/null || true)"
    if [[ "${label}" != "${PERF_RUN_ID}" ]]; then
        log_message "ERROR: refusing to remove container without matching run label: ${MARIADB_CONTAINER_NAME}"
        return 70
    fi
    if [[ -n "${RESULTS_DIR:-}" && -d "${RESULTS_DIR}" ]]; then
        mkdir -p "${RESULTS_DIR}/service-logs"
        docker logs "${MARIADB_CONTAINER_NAME}" > "${RESULTS_DIR}/service-logs/container.log" 2>&1 || true
    fi
    docker stop --time 30 "${MARIADB_CONTAINER_NAME}" >/dev/null || return 70
    docker rm "${MARIADB_CONTAINER_NAME}" >/dev/null || return 70
    log_message "removed managed MariaDB container ${MARIADB_CONTAINER_NAME}"
}

verify_mariadb_source_archive() {
    local path="$1" expected actual
    expected="${MARIADB_SOURCE_SHA256,,}"
    [[ "${expected}" =~ ^[[:xdigit:]]{64}$ ]] || {
        log_message "ERROR: invalid expected MariaDB SHA-256: ${MARIADB_SOURCE_SHA256}"
        return 30
    }
    [[ -s "${path}" ]] || return 1
    actual="$(sha256sum "${path}")"
    [[ "${actual%% *}" == "${expected}" ]] || return 1
    return 0
}

acquire_mariadb_source_archive() {
    local local_archive="${MARIADB_OFFLINE_DIR}/${MARIADB_SOURCE_ARCHIVE}"
    local archive="${PERF_WORK_DIR}/${MARIADB_SOURCE_ARCHIVE}"
    local temp_archive="${archive}.part"
    if [[ -e "${archive}" ]]; then
        if verify_mariadb_source_archive "${archive}"; then
            log_message "using verified private MariaDB source archive: ${archive}"
            return 0
        fi
        log_message "WARNING: removing invalid private MariaDB archive: ${archive}"
        rm -f -- "${archive}"
    fi
    rm -f -- "${temp_archive}"
    if [[ -s "${local_archive}" ]]; then
        log_message "checking offline MariaDB source archive: ${local_archive}"
        if verify_mariadb_source_archive "${local_archive}"; then
            cp -- "${local_archive}" "${temp_archive}" || { rm -f -- "${temp_archive}"; return 30; }
            verify_mariadb_source_archive "${temp_archive}" || { rm -f -- "${temp_archive}"; return 30; }
            mv -- "${temp_archive}" "${archive}" || { rm -f -- "${temp_archive}"; return 30; }
            log_message "prepared verified MariaDB source archive from offline directory: ${archive}"
            return 0
        fi
        log_message "WARNING: offline MariaDB archive failed SHA-256 verification, falling back to upstream download"
    fi
    log_message "downloading ${MARIADB_SOURCE_ARCHIVE} from ${MARIADB_SOURCE_URL}"
    with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
        -o "${temp_archive}" "${MARIADB_SOURCE_URL}" || {
        rm -f -- "${temp_archive}"
        log_message "ERROR: failed to download ${MARIADB_SOURCE_ARCHIVE}"
        return 30
    }
    if ! verify_mariadb_source_archive "${temp_archive}"; then
        rm -f -- "${temp_archive}"
        log_message "ERROR: downloaded MariaDB archive failed SHA-256 verification (expected ${MARIADB_SOURCE_SHA256})"
        return 30
    fi
    mv -- "${temp_archive}" "${archive}" || { rm -f -- "${temp_archive}"; return 30; }
    log_message "downloaded and verified MariaDB source archive: ${archive}"
}

configure_benchmark_account() {
    if [[ "${MARIADB_DB_USER}" == "root" ]]; then
        mariadb_client_exec "" "${MARIADB_BIN}" --socket="${SOCKET_PATH}" -u root <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_PASSWORD}';
CREATE USER IF NOT EXISTS 'root'@'127.0.0.1' IDENTIFIED BY '${MARIADB_PASSWORD}';
ALTER USER 'root'@'127.0.0.1' IDENTIFIED BY '${MARIADB_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION;
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
ALTER USER 'root'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
CREATE DATABASE IF NOT EXISTS sbtest;
FLUSH PRIVILEGES;
SQL
        return $?
    fi

    mariadb_client_exec "" "${MARIADB_BIN}" --socket="${SOCKET_PATH}" -u root <<SQL
CREATE USER IF NOT EXISTS '${MARIADB_DB_USER}'@'127.0.0.1' IDENTIFIED BY '${MARIADB_PASSWORD}';
ALTER USER '${MARIADB_DB_USER}'@'127.0.0.1' IDENTIFIED BY '${MARIADB_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${MARIADB_DB_USER}'@'127.0.0.1' WITH GRANT OPTION;
CREATE USER IF NOT EXISTS '${MARIADB_DB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
ALTER USER '${MARIADB_DB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${MARIADB_DB_USER}'@'%' WITH GRANT OPTION;
CREATE DATABASE IF NOT EXISTS sbtest;
FLUSH PRIVILEGES;
SQL
}

launch_mariadb_server() {
    local mode="$1"
    local attempt actual_limit actual_connections actual_open_files server_limits auth_pwd
    local -a mode_options=() user_options=()

    if [[ "$(id -u)" -eq 0 ]]; then
        user_options=(--user=root)
    fi

    case "${mode}" in
        prepare)
            mode_options=(
                --innodb-flush-log-at-trx-commit=0
                --innodb-use-native-aio=OFF
                --skip-log-bin
            )
            auth_pwd=""
            ;;
        benchmark)
            mode_options=(
                --innodb-flush-log-at-trx-commit=1
                --innodb-use-native-aio=ON
                --log-bin="${DATADIR}/mariadb-bin"
            )
            auth_pwd="${MARIADB_PASSWORD}"
            ;;
        *)
            log_message "ERROR: unsupported MariaDB service mode: ${mode}"
            return 40
            ;;
    esac

    check_mariadb_container || return 40
    docker exec -d \
        -e "HOME=${MARIADB_HOME_DIR}" \
        -e "TMPDIR=${MARIADB_TMP_DIR}" \
        "${MARIADB_CONTAINER_NAME}" \
        "${MARIADBD_BIN}" --no-defaults \
        "${user_options[@]}" \
        --basedir="${MARIADB_BASE_DIR}" \
        --datadir="${DATADIR}" \
        --tmpdir="${MARIADB_TMP_DIR}" \
        --socket="${SOCKET_PATH}" \
        --pid-file="${PID_FILE}" \
        --port="${MARIADB_PORT}" \
        --bind-address="${MARIADB_HOST}" \
        --max-connections=2048 \
        --max-prepared-stmt-count="${MARIADB_PREPARED_STMT_LIMIT}" \
        --log-error="${ERR_LOG}" \
        "${mode_options[@]}" || {
        log_message "ERROR: failed to launch mariadbd (see ${ERR_LOG})"
        return 40
    }

    for attempt in {1..60}; do
        if mariadb_client_exec "${auth_pwd}" "${MARIADB_ADMIN_BIN}" --socket="${SOCKET_PATH}" -u root ping >/dev/null 2>&1; then
            if [[ "${mode}" == prepare ]]; then
                server_limits="$(mariadb_client_exec "" "${MARIADB_BIN}" --socket="${SOCKET_PATH}" -u root -N \
                    -e 'SELECT @@GLOBAL.max_prepared_stmt_count, @@GLOBAL.max_connections, @@GLOBAL.open_files_limit')" || {
                    log_message "ERROR: cannot verify MariaDB server limits"
                    return 40
                }
            else
                server_limits="$(mariadb_client_exec "${MARIADB_PASSWORD}" "${MARIADB_BIN}" \
                    "-h${MARIADB_HOST}" "-P${MARIADB_PORT}" "-u${MARIADB_DB_USER}" -N \
                    -e 'SELECT @@GLOBAL.max_prepared_stmt_count, @@GLOBAL.max_connections, @@GLOBAL.open_files_limit')" || {
                    log_message "ERROR: cannot verify MariaDB server limits"
                    return 40
                }
            fi
            read -r actual_limit actual_connections actual_open_files <<< "${server_limits}"
            if [[ "${actual_limit}" != "${MARIADB_PREPARED_STMT_LIMIT}" ]]; then
                log_message "ERROR: MariaDB max_prepared_stmt_count is ${actual_limit}, expected ${MARIADB_PREPARED_STMT_LIMIT}"
                return 40
            fi
            if [[ ! "${actual_connections}" =~ ^[0-9]+$ ]] || (( actual_connections < 2048 )); then
                log_message "ERROR: MariaDB max_connections is ${actual_connections:-unavailable}, expected at least 2048 (open_files_limit=${actual_open_files:-unavailable})"
                return 40
            fi
            log_message "mariadbd is ready on port ${MARIADB_PORT} (socket ${SOCKET_PATH})"
            log_message "verified MariaDB limits: max_connections=${actual_connections}, open_files_limit=${actual_open_files}"
            return 0
        fi
        sleep 1
    done
    log_message "ERROR: mariadbd did not become ready within 60s (see ${ERR_LOG})"
    return 40
}

shutdown_mariadb_server() {
    local attempt
    if [[ ! -S "${SOCKET_PATH}" ]]; then
        return 0
    fi
    if ! mariadb_client_exec "${MARIADB_PASSWORD}" "${MARIADB_ADMIN_BIN}" \
        --socket="${SOCKET_PATH}" -u root shutdown >/dev/null 2>&1; then
        # Fall back to empty password if shutdown happens before benchmark account setup completed.
        if ! mariadb_client_exec "" "${MARIADB_ADMIN_BIN}" \
            --socket="${SOCKET_PATH}" -u root shutdown >/dev/null 2>&1; then
            log_message "ERROR: failed to shut down managed MariaDB instance"
            return 50
        fi
    fi
    for attempt in {1..40}; do
        if [[ ! -S "${SOCKET_PATH}" ]]; then
            return 0
        fi
        sleep 0.5
    done
    log_message "ERROR: managed MariaDB socket is still present after shutdown"
    return 50
}

run_sysbench() {
    local workload="$1" threads="$2" duration="$3" label="$4"
    local workload_script="${SYSBENCH_LUA_DIR}/oltp_${workload}.lua"
    local raw_output="${RESULTS_DIR}/sysbench_raw.log"
    local run_output="${RESULTS_DIR}/sysbench-runs/${label}.log"
    local action=run
    local status=0
    local -a command=(
        "${SYSBENCH_BIN}" --db-driver=mysql
        "--mysql-host=${MARIADB_HOST}" "--mysql-port=${MARIADB_PORT}"
        "--mysql-user=${MARIADB_DB_USER}" "--mysql-password=${MARIADB_PASSWORD}"
        --mysql-db=sbtest "--table_size=${MARIADB_TABLE_SIZE}" "--tables=${MARIADB_TABLES}"
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
    set +e
    LUA_PATH="${SYSBENCH_LUA_DIR}/?.lua;;" \
        LD_LIBRARY_PATH="${MARIADB_BASE_DIR}/lib:${LD_LIBRARY_PATH:-}" \
        "${command[@]}" 2>&1 | tee -a "${raw_output}" "${run_output}"
    status="${PIPESTATUS[0]}"
    set -e
    if [[ "${status}" -ne 0 ]]; then
        log_message "ERROR: Sysbench ${label} failed (rc=${status})"
        return 50
    fi
    if grep -q 'FATAL:' "${run_output}"; then
        log_message "ERROR: Sysbench ${label} reported FATAL errors despite exit code 0"
        return 50
    fi
}

require_host_sysbench_tools() {
    local command_name package
    local packages=()
    local -a dnf_options=()

    for command_name in tar sed tee curl git make gcc autoreconf automake libtoolize pkg-config python3; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            tee) package="coreutils" ;;
            tar) package="tar" ;;
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
        esac
        log_message "missing required host Sysbench build command: ${command_name}"
        packages+=("${package}")
    done

    for package in openssl-devel zlib-devel; do
        if ! rpm -q "${package}" >/dev/null 2>&1; then
            log_message "missing required host Sysbench build package: ${package}"
            packages+=("${package}")
        fi
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log_message "ERROR: dnf is required to install host Sysbench prerequisites"
        return 30
    fi
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing missing host Sysbench build packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log_message "ERROR: sudo is required to install host Sysbench prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log_message "ERROR: failed to install host Sysbench prerequisites"
        return 30
    fi
}
