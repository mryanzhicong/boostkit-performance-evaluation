#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

prepare_rocksdb_benchmark_data() {
    local cpu_set numa_node
    local -a mounts dnf_options=()

    initialize_runtime || return $?
    if [[ ! -s "${YCSB_DIST_DIR}/bin/ycsb" ]]; then
        log_message "ERROR: YCSB RocksDB binding is not built"
        return 40
    fi
    if [[ -e "${BENCH_DATA_DIR}" ]]; then
        log_message "ERROR: benchmark data directory already exists: ${BENCH_DATA_DIR}"
        return 20
    fi
    prepare_rocksdb_container_image || return $?
    if docker container inspect "${ROCKSDB_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${ROCKSDB_CONTAINER_NAME}"
        return 40
    fi
    read -r cpu_set numa_node < <(select_rocksdb_cpu_set) || return 40
    if [[ -z "${cpu_set}" || -z "${numa_node}" ]]; then
        log_message "ERROR: NUMA node ${ROCKSDB_NUMA_NODE} has fewer than two available CPUs"
        return 40
    fi
    mkdir -p "${BENCH_DATA_DIR}"
    mounts=(--mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}")
    if [[ "${RESULTS_DIR}" != "${PERF_WORK_DIR}" && "${RESULTS_DIR}" != "${PERF_WORK_DIR}/"* ]]; then
        mounts+=(--mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}")
    fi
    if [[ -n "${PERF_PROXY:-}" ]]; then
        if [[ ! -d "${ROCKSDB_CA_ANCHORS_DIR}" ]]; then
            log_message "ERROR: proxy CA certificate directory is missing: ${ROCKSDB_CA_ANCHORS_DIR}"
            return 30
        fi
        mounts+=(--mount "type=bind,source=${ROCKSDB_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    log_message "starting 2U8G RocksDB/YCSB container ${ROCKSDB_CONTAINER_NAME}: CPUs ${cpu_set}, NUMA ${numa_node}"
    docker run --detach --name "${ROCKSDB_CONTAINER_NAME}" \
        --label "boostkit.rocksdb.run-id=${PERF_RUN_ID}" \
        --cpus=2 --cpuset-cpus="${cpu_set}" --cpuset-mems="${numa_node}" \
        --memory=8g --network=host --user "$(id -u):$(id -g)" \
        "${mounts[@]}" "${ROCKSDB_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40

    if [[ -n "${PERF_PROXY:-}" ]]; then
        log_message "updating CA trust in the private RocksDB container"
        docker exec --user 0 "${ROCKSDB_CONTAINER_NAME}" update-ca-trust extract || {
            log_message "ERROR: failed to update CA trust in the RocksDB container"
            return 30
        }
    fi
    log_message "switching private RocksDB container repositories to the Huawei openEuler mirror"
    docker exec --user 0 "${ROCKSDB_CONTAINER_NAME}" sed -i \
        -e '/^meta/ s/^\(.*\)$/#\1/g' \
        -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
        /etc/yum.repos.d/openEuler.repo || {
        log_message "ERROR: failed to update openEuler repositories in the RocksDB container"
        return 30
    }
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing RocksDB/YCSB runtime dependencies inside the private container"
    docker exec --user 0 "${ROCKSDB_CONTAINER_NAME}" \
        dnf "${dnf_options[@]}" install -y \
        java-11-openjdk-headless python3 libatomic snappy zlib bzip2 lz4 zstd || return 30
    if ! docker exec "${ROCKSDB_CONTAINER_NAME}" java -version 2>&1 | grep -Eq 'version "11([."]|$)' || \
       ! docker exec "${ROCKSDB_CONTAINER_NAME}" python3 --version >/dev/null 2>&1; then
        log_message "ERROR: container requires Java 11 and Python 3"
        return 40
    fi
    log_message "prepared task-private benchmark data directory: ${BENCH_DATA_DIR}"
}
