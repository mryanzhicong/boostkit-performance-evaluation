#!/usr/bin/env bash
# Shared configuration for the Celeborn single-node TPC-DS case.
#
# Every stage runs inside one private openEuler 24.03 LTS SP4 container on the
# host network: Apache Celeborn 0.5.3 master and worker, Apache Spark 3.5.2 in
# local-cluster mode and the TPC-DS workload generator all live in that single
# container.  The host only keeps Docker, the download cache, the framework and
# the strict result parser.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

SOFTWARE_VERSION="${SOFTWARE_VERSION:-0.5.3}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# Sampling contract: one warm-up run plus at least five measured runs.
PERF_REPS="${PERF_REPS:-6}"

# TPC-DS scale factor.  One container cannot host the document's 100 GB data
# set with 200 executors, so the default is the largest scale factor that fits
# the single-node container budget; it is recorded in every result file.
CELEBORN_SCALE_FACTOR="${CELEBORN_SCALE_FACTOR:-3}"

SPARK_VERSION=3.5.2
SPARK_FLAVOUR=bin-hadoop3
SPARK_DIR_NAME="spark-${SPARK_VERSION}-${SPARK_FLAVOUR}"
CELEBORN_DIR_NAME="apache-celeborn-${SOFTWARE_VERSION}-bin"
TPCDS_KIT_DIR_NAME=tpcds-kit
TESTBENCH_DIR_NAME=hive-testbench-hdp3

CELEBORN_OFFLINE_DIR="${CELEBORN_OFFLINE_DIR:-/home/runner/software/celeborn}"
CELEBORN_IMAGE_ARCHIVE_DIR="${CELEBORN_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
CELEBORN_CA_ANCHORS_DIR="${CELEBORN_CA_ANCHORS_DIR:-/home/runner/software/anchors}"

# Pinned downloads (official digests).
CELEBORN_ARCHIVE_SHA512=cc294b8589bde1a5c5340dd18f7b20ab3dfd904d072228ee473e76d05cbaf4d5152a61c8502fe9505e3f25ce05241b43dda72a028caf044043810fee15fb18c9
CELEBORN_ARCHIVE_URL="https://archive.apache.org/dist/celeborn/celeborn-${SOFTWARE_VERSION}/apache-celeborn-${SOFTWARE_VERSION}-bin.tgz"
CELEBORN_ARCHIVE_MIRROR_URL="https://mirrors.huaweicloud.com/apache/celeborn/celeborn-${SOFTWARE_VERSION}/apache-celeborn-${SOFTWARE_VERSION}-bin.tgz"
SPARK_ARCHIVE_SHA512=ae243483c2d07dc0feade02ac681956e9577e22935e32bb4ffca4fce02243682ca71dadeff9e6566153e132b0a71c518ded2dc58d08a124679843bffd3237539
SPARK_ARCHIVE_URL="https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_DIR_NAME}.tgz"
SPARK_ARCHIVE_MIRROR_URL="https://mirrors.huaweicloud.com/apache/spark/spark-${SPARK_VERSION}/${SPARK_DIR_NAME}.tgz"
# databricks/tpcds-kit master as of 2023-08-15; source build keeps the generator
# arch-neutral, so x86_64 and aarch64 produce byte-identical data.
TPCDS_KIT_COMMIT=1b7fb7529edae091684201fab142d956d6afd881
# codeload re-packs archives, so the tarball bytes are not stable; pin the
# canonical digest of the extracted tree instead (path + file digest pairs).
TPCDS_KIT_TREE_SHA256=6bc2cdf0e91b07e4e3374d0f765051e2f8411a7d074fd4f88c411eaa6eabc5ee
TPCDS_KIT_URL="https://codeload.github.com/databricks/tpcds-kit/tar.gz/${TPCDS_KIT_COMMIT}"
TPCDS_KIT_MIRROR_URL="${TPCDS_KIT_URL}"
# hive-testbench-hdp3 supplies the pinned TPC-DS DDL and the 99 statement files
# that the document's workload uses; only its text assets are consumed.
TESTBENCH_SHA256=7248c0f9d3d4dfe8435cd6e8137c2023ed8008dcf9bc2d55ff7f2427699b81ee
TESTBENCH_URL="https://gitcode.com/helloxteen_/OmniOperatorDebugAgent/releases/download/tpcds/hive-testbench-hdp3-x86.zip"

CELEBORN_MASTER_PORT=9097
CELEBORN_MASTER_HTTP_PORT=9098
CELEBORN_WORKER_HTTP_PORT=9099
CELEBORN_MASTER_HEAP=4g
CELEBORN_WORKER_HEAP=4g
CELEBORN_WORKER_OFFHEAP=8g
# The document runs 103 statements on a 200-executor YARN cluster.  The pinned
# hive-testbench statement set has 99 files, all of which are executed here.
CELEBORN_QUERY_COUNT="${CELEBORN_QUERY_COUNT:-99}"
CELEBORN_SHUFFLE_PARTITIONS="${CELEBORN_SHUFFLE_PARTITIONS:-200}"
CELEBORN_DRIVER_MEMORY="${CELEBORN_DRIVER_MEMORY:-}"
CELEBORN_PARALLEL_GENERATORS="${CELEBORN_PARALLEL_GENERATORS:-}"

log_message() {
    printf '[celeborn] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
}

configure_runtime_paths() {
    [[ "${SOFTWARE_VERSION}" == 0.5.3 ]] || { log_message "ERROR: unsupported version: ${SOFTWARE_VERSION}"; return 10; }
    [[ "${PERF_VARIANT}" == base || "${PERF_VARIANT}" == optimized ]] || { log_message "ERROR: unsupported variant: ${PERF_VARIANT}"; return 10; }
    [[ "${EXPECTED_ARCH}" == "$(uname -m)" ]] || { log_message 'ERROR: runner architecture differs from EXPECTED_ARCH'; return 20; }
    [[ "${PERF_REPS}" =~ ^[1-9][0-9]*$ ]] || { log_message "ERROR: PERF_REPS must be a positive integer: ${PERF_REPS}"; return 10; }
    # dsdgen 2.13 crashes on fractional scale factors, so only whole gigabytes
    # of generated data are accepted.
    [[ "${CELEBORN_SCALE_FACTOR}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: CELEBORN_SCALE_FACTOR must be a whole TPC-DS scale factor >= 1: ${CELEBORN_SCALE_FACTOR}"; return 10;
    }
    PERF_RUN_ID="${PERF_RUN_ID:-local-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || { log_message "ERROR: invalid PERF_RUN_ID: ${PERF_RUN_ID}"; return 10; }
    PERF_WORK_DIR="${PERF_WORK_DIR:-/home/runner/boostkit-perf/celeborn/local-${PERF_RUN_ID}}"
    RESULTS_DIR="${RESULTS_DIR:-${CASE_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}}"
    [[ "${RESULTS_DIR}" == /* ]] || RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${PERF_WORK_DIR}/actual-version.txt}"

    CELEBORN_HOME="${PERF_WORK_DIR}/${CELEBORN_DIR_NAME}"
    SPARK_HOME="${PERF_WORK_DIR}/${SPARK_DIR_NAME}"
    TPCDS_KIT_HOME="${PERF_WORK_DIR}/${TPCDS_KIT_DIR_NAME}"
    TESTBENCH_HOME="${PERF_WORK_DIR}/${TESTBENCH_DIR_NAME}"
    DATA_DIR="${PERF_WORK_DIR}/data/tpcds-${CELEBORN_SCALE_FACTOR}"
    WAREHOUSE_DIR="${PERF_WORK_DIR}/warehouse/tpcds-${CELEBORN_SCALE_FACTOR}"
    METASTORE_DIR="${PERF_WORK_DIR}/metastore/tpcds-${CELEBORN_SCALE_FACTOR}"
    QUERY_DIR="${PERF_WORK_DIR}/queries/tpcds-${CELEBORN_SCALE_FACTOR}"
    RUNS_DIR="${PERF_WORK_DIR}/runs"
    CELEBORN_STORAGE_DIR_1="${PERF_WORK_DIR}/celeborn/storage-1"
    CELEBORN_STORAGE_DIR_2="${PERF_WORK_DIR}/celeborn/storage-2"
    CELEBORN_MASTER_URL="celeborn://server1:${CELEBORN_MASTER_PORT}"
    CELEBORN_CLIENT_ENDPOINTS="server1:${CELEBORN_MASTER_PORT}"
    CELEBORN_SHUFFLE_MANAGER="org.apache.spark.shuffle.celeborn.SparkShuffleManager"
    CELEBORN_CLIENT_JAR="${CELEBORN_HOME}/spark/celeborn-client-spark-3-shaded_2.12-${SOFTWARE_VERSION}.jar"
    CELEBORN_LOG_DIR="${PERF_WORK_DIR}/celeborn/logs"
    CELEBORN_PID_DIR="${PERF_WORK_DIR}/celeborn/pids"
    CELEBORN_CONF_DIR="${PERF_WORK_DIR}/celeborn/conf"
    WORKLOAD_DIR="${PERF_WORK_DIR}/workload"
    WORKLOAD_MANIFEST="${WORKLOAD_DIR}/manifest.json"
    DDL_FILE="${TESTBENCH_HOME}/ddl-tpcds/text/alltables.sql"
    STATEMENT_DIR="${TESTBENCH_HOME}/sample-queries-tpcds"
    export PERF_WORK_DIR RESULTS_DIR PERF_ACTUAL_VERSION_FILE PERF_REPS CELEBORN_SCALE_FACTOR
    export CELEBORN_HOME SPARK_HOME TPCDS_KIT_HOME TESTBENCH_HOME DATA_DIR WAREHOUSE_DIR METASTORE_DIR
    export QUERY_DIR RUNS_DIR CELEBORN_STORAGE_DIR_1 CELEBORN_STORAGE_DIR_2 CELEBORN_LOG_DIR CELEBORN_PID_DIR
    export WORKLOAD_DIR WORKLOAD_MANIFEST DDL_FILE STATEMENT_DIR CELEBORN_CONF_DIR CELEBORN_CLIENT_JAR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}/tmp" "${RESULTS_DIR}" || return 30
}

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

# fetch_verified <url> <target-file> <sha512|sha256> <expected-digest>
# Reuses the offline cache under ${CELEBORN_OFFLINE_DIR} and never accepts a
# digest mismatch, a partial download or a redirected HTML error page.
fetch_verified() {
    # Usage: fetch_verified <target> <sha512|sha256> <expected-digest> <url> [fallback-url ...]
    # Every candidate URL must yield the same digest, so a domestic mirror is tried
    # before the upstream site without weakening verification.
    local target="$1" algorithm="$2" expected="$3"
    shift 3
    local cache="${CELEBORN_OFFLINE_DIR}/$(basename "${target}")" actual url
    mkdir -p "$(dirname "${target}")" "${CELEBORN_OFFLINE_DIR}" || return 30
    if [[ ! -s "${target}" ]]; then
        if [[ -s "${cache}" ]]; then
            log_message "using cached download: ${cache}"
            cp -- "${cache}" "${target}.part" || return 30
        else
            for url in "$@"; do
                log_message "downloading ${url}"
                if with_network_proxy curl -fSL --retry 3 --retry-delay 5 --connect-timeout 30 \
                    -o "${target}.part" "${url}"; then
                    actual="$("${algorithm}"sum "${target}.part" | awk '{print $1}')"
                    if [[ "${actual}" == "${expected,,}" ]]; then
                        break
                    fi
                    log_message "WARNING: ${algorithm} mismatch from ${url} (got ${actual}), trying the next source"
                fi
                rm -f "${target}.part"
            done
            [[ -s "${target}.part" ]] || { log_message "ERROR: all download sources failed for $(basename "${target}")"; return 30; }
        fi
        mv -f "${target}.part" "${target}" || return 30
    fi
    actual="$("${algorithm}"sum "${target}" | awk '{print $1}')"
    if [[ "${actual}" != "${expected,,}" ]]; then
        log_message "ERROR: ${algorithm} mismatch for ${target} (expected ${expected}, got ${actual})"
        return 30
    fi
    case "${target}" in
        "${CELEBORN_OFFLINE_DIR}"/*) ;;
        *)
            if [[ ! -s "${cache}" ]]; then
                cp -- "${target}" "${cache}.part" && mv -f "${cache}.part" "${cache}" || log_message "WARNING: cannot cache ${target}"
            fi
            ;;
    esac
    log_message "verified ${algorithm} of $(basename "${target}")"
}

extract_archive() {
    local archive="$1" destination="$2" expect_dir="$3"
    [[ -d "${expect_dir}" ]] && return 0
    log_message "extracting $(basename "${archive}")"
    tar -xf "${archive}" -C "${destination}" || return 30
}

java_home_in_container() {
    # Java 8 in openEuler lives under <jdk>/jre/bin/java, so only the /bin/java
    # suffix is removed and JAVA_HOME always points at a directory with bin/java.
    celeborn_container_exec bash -lc 'readlink -f "$(command -v java)"' |
        sed -E 's#/bin/java$##'
}

# The JVM heap has to fit the container: half of the container memory, capped at
# 24 GB so a very large runner does not oversubscribe a single-JVM local run.
spark_driver_memory() {
    if [[ -n "${CELEBORN_DRIVER_MEMORY}" ]]; then
        printf '%s\n' "${CELEBORN_DRIVER_MEMORY}"
        return 0
    fi
    celeborn_container_exec bash -lc 'awk "/MemTotal/ {printf \"%d\", \$2 / 1024 / 1024}" /proc/meminfo' |
        awk '{ half = int($1 / 2); if (half > 24) half = 24; if (half < 4) half = 4; printf "%dg\n", half }'
}

container_cpu_count() {
    celeborn_container_exec nproc
}

require_tool() {
    command -v "$1" >/dev/null 2>&1 || { log_message "ERROR: required tool is missing: $1"; return 30; }
}

# >>> container-runtime:begin
# ==============================================================================
# Private openEuler container runtime
# ==============================================================================
# Every stage of this case runs inside a per-run openEuler 24.03 LTS SP4
# container.  The host keeps only Docker, download/verification tooling, the
# framework and the strict result parser; package installation, source
# extraction, builds, the measured process tree and cleanup happen inside the
# container.  The contract mirrors software/Database/mysql,
# software/Bigdata/ray and software/Others/unixbench.
#
# Generated by adaptation/scripts/add-container-block.py -- do not hand edit the
# region between the markers; change the template instead.
CELEBORN_IMAGE_ARCHIVE_DIR="${CELEBORN_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
CELEBORN_CA_ANCHORS_DIR="${CELEBORN_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
CELEBORN_CONTAINER_IMAGE="${CELEBORN_CONTAINER_IMAGE:-}"
CELEBORN_CONTAINER_NAME="${CELEBORN_CONTAINER_NAME:-}"
CELEBORN_CONTAINER_HOME="${CELEBORN_CONTAINER_HOME:-}"
declare -p CELEBORN_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || CELEBORN_CONTAINER_EXTRA_ARGS=()

celeborn_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

celeborn_configure_container() {
    local arch
    arch="$(celeborn_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${CELEBORN_CONTAINER_NAME}" ] || CELEBORN_CONTAINER_NAME="boostkit-celeborn-${arch}-${PERF_RUN_ID}"
    [ -n "${CELEBORN_CONTAINER_HOME}" ] || CELEBORN_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export CELEBORN_CONTAINER_NAME CELEBORN_CONTAINER_HOME
}

celeborn_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_celeborn_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_celeborn_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${CELEBORN_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_celeborn_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(celeborn_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${CELEBORN_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${CELEBORN_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        celeborn_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        celeborn_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
    fi
    if [ -s "${checksum}" ]; then
        ( cd "$(dirname "${archive}")" && sha256sum -c "$(basename "${checksum}")" ) >/dev/null || {
            log_message "ERROR: container image checksum mismatch: ${archive}"
            return 30
        }
    else
        log_message "WARNING: no checksum file next to ${archive}; relying on the pinned path only"
    fi
    log_message "loading verified openEuler container image: ${archive}"
    load_output="$(docker load --input "${archive}")" || return 30
    CELEBORN_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${CELEBORN_CONTAINER_IMAGE}" ] || ! docker image inspect "${CELEBORN_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${CELEBORN_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_celeborn_container_image_release || return $?
    export CELEBORN_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${CELEBORN_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_celeborn_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-celeborn-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${CELEBORN_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.celeborn.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_celeborn_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    celeborn_configure_container
    require_celeborn_docker || return $?
    if docker container inspect "${CELEBORN_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${CELEBORN_CONTAINER_NAME}"
        return 40
    fi
    sweep_celeborn_stale_containers || true
    prepare_celeborn_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${CELEBORN_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${CELEBORN_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${CELEBORN_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${CELEBORN_CONTAINER_HOME}" || return 40
    log_message "starting private container ${CELEBORN_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${CELEBORN_CONTAINER_NAME}" \
        --label "boostkit.celeborn.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${CELEBORN_CONTAINER_EXTRA_ARGS[@]}" \
        "${CELEBORN_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${CELEBORN_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${CELEBORN_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${CELEBORN_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${CELEBORN_CONTAINER_NAME}"
}

check_celeborn_container() {
    celeborn_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${CELEBORN_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${CELEBORN_CONTAINER_NAME}"
        return 40
    }
}

celeborn_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    celeborn_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${CELEBORN_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${CELEBORN_CONTAINER_NAME}" "$@"
}

celeborn_container_exec() { celeborn_docker_exec '' '' "$@"; }

celeborn_container_exec_at() {
    local workdir="$1"
    shift
    celeborn_docker_exec "${workdir}" '' "$@"
}

celeborn_container_exec_root() { celeborn_docker_exec '' root "$@"; }

celeborn_container_exec_root_at() {
    local workdir="$1"
    shift
    celeborn_docker_exec "${workdir}" root "$@"
}

remove_celeborn_container() {
    celeborn_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${CELEBORN_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.celeborn.run-id"}}' "${CELEBORN_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${CELEBORN_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${CELEBORN_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${CELEBORN_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${CELEBORN_CONTAINER_NAME}"
}
# >>> container-runtime:end
