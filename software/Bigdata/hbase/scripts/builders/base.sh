#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

install_host_dependencies() {
    local command package
    local -a packages=() dnf_options=()
    for command in docker curl tar sha256sum awk sed; do
        command -v "${command}" >/dev/null 2>&1 && continue
        case "${command}" in
            docker) log_error 'Docker must be installed on the Runner'; return 30 ;;
            sha256sum) package=coreutils ;;
            awk) package=gawk ;;
            *) package="${command}" ;;
        esac
        packages+=("${package}")
    done
    (( ${#packages[@]} > 0 )) || return 0
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    if (( EUID == 0 )); then
        dnf "${dnf_options[@]+"${dnf_options[@]}"}" install -y "${packages[@]}" || return 30
    else
        sudo -n dnf "${dnf_options[@]+"${dnf_options[@]}"}" install -y "${packages[@]}" || return 30
    fi
}

prepare_container_image() {
    local name="openEuler-docker.${EXPECTED_ARCH}.tar.xz"
    local archive checksum expected actual output image_arch release
    local url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${name}"
    if [[ -s "${IMAGE_FILE}" ]]; then
        CONTAINER_IMAGE="$(<"${IMAGE_FILE}")"
        docker image inspect "${CONTAINER_IMAGE}" >/dev/null 2>&1 || {
            log_error "cached image reference is invalid: ${CONTAINER_IMAGE}"; return 30;
        }
        export CONTAINER_IMAGE
        return 0
    fi
    archive="${IMAGE_ARCHIVE_DIR}/${name}"
    if [[ ! -s "${archive}" ]]; then
        archive="${PERF_WORK_DIR}/${name}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}" "${url}" || return 30
    fi
    checksum="${IMAGE_ARCHIVE_DIR}/${name}.sha256sum"
    if [[ ! -s "${checksum}" ]]; then
        checksum="${PERF_WORK_DIR}/${name}.sha256sum"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${url}.sha256sum" || return 30
    fi
    expected="$(awk 'NR == 1 {print $1}' "${checksum}")"
    [[ "${expected}" =~ ^[[:xdigit:]]{64}$ ]] || return 30
    actual="$(sha256sum "${archive}")"
    [[ "${actual%% *}" == "${expected,,}" ]] || { log_error "image SHA-256 mismatch"; return 30; }
    output="$(docker load --input "${archive}")" || return 30
    CONTAINER_IMAGE="$(printf '%s\n' "${output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    [[ -n "${CONTAINER_IMAGE}" ]] || return 30
    docker image inspect "${CONTAINER_IMAGE}" >/dev/null 2>&1 || return 30
    image_arch="$(docker image inspect --format '{{.Architecture}}' "${CONTAINER_IMAGE}")"
    case "${EXPECTED_ARCH}:${image_arch}" in x86_64:amd64|aarch64:arm64) ;; *) return 30 ;; esac
    release="$(docker run --rm --network=none "${CONTAINER_IMAGE}" cat /etc/os-release)" || return 30
    grep -Eq '^ID="?openEuler"?$' <<< "${release}" || return 30
    grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}" || return 30
    printf '%s\n' "${CONTAINER_IMAGE}" > "${IMAGE_FILE}"
    export CONTAINER_IMAGE
}

fetch_artifact() {
    local url="$1" dest="$2" expected="$3"
    if [[ -s "$(dirname "${dest}")/$(basename "${dest}")" ]]; then :; fi
    if [[ -s "${dest}" ]]; then
        printf '%s  %s\n' "${expected}" "${dest}" | sha256sum -c - >/dev/null 2>&1 && return 0
    fi
    with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${dest}.part" "${url}" || return 30
    mv "${dest}.part" "${dest}"
    printf '%s  %s\n' "${expected}" "${dest}" | sha256sum -c - || return 30
}

prepare_hbase_archives() {
    local hbase_archive="${PERF_WORK_DIR}/hbase-${SOFTWARE_VERSION}-bin.tar.gz"
    local zk_archive="${PERF_WORK_DIR}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz"
    local hadoop_archive="${PERF_WORK_DIR}/${HADOOP_ARCHIVE}"
    local jdk_archive="${PERF_WORK_DIR}/bisheng-jdk-${BISHENG_JDK_RELEASE}-linux-$( [[ "${EXPECTED_ARCH}" == x86_64 ]] && printf x64 || printf aarch64 ).tar.gz"

    if [[ -s "${HBASE_OFFLINE_DIR}/hbase-${SOFTWARE_VERSION}-bin.tar.gz" ]]; then
        cp -- "${HBASE_OFFLINE_DIR}/hbase-${SOFTWARE_VERSION}-bin.tar.gz" "${hbase_archive}" || return 30
    else
        with_network_proxy curl -fSL --retry 3 -o "${hbase_archive}" \
            "https://repo.huaweicloud.com/apache/hbase/${SOFTWARE_VERSION}/hbase-${SOFTWARE_VERSION}-bin.tar.gz" || return 30
    fi
    printf '%s  %s\n' "$(hbase_artifact_sha256 hbase)" "${hbase_archive}" | sha256sum -c - || return 30

    if [[ -s "${ZK_OFFLINE_DIR}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz" ]]; then
        cp -- "${ZK_OFFLINE_DIR}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz" "${zk_archive}" || return 30
    else
        with_network_proxy curl -fSL --retry 3 -o "${zk_archive}" \
            "https://repo.huaweicloud.com/apache/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz" || return 30
    fi
    printf '%s  %s\n' "$(hbase_artifact_sha256 zookeeper)" "${zk_archive}" | sha256sum -c - || return 30

    if [[ -s "${HADOOP_OFFLINE_DIR}/${HADOOP_ARCHIVE}" ]]; then
        cp -- "${HADOOP_OFFLINE_DIR}/${HADOOP_ARCHIVE}" "${hadoop_archive}" || return 30
    else
        with_network_proxy curl -fSL --retry 3 -o "${hadoop_archive}" \
            "https://repo.huaweicloud.com/apache/hadoop/common/hadoop-${HADOOP_VERSION}/${HADOOP_ARCHIVE}" || return 30
    fi
    printf '%s  %s\n' "$(hbase_artifact_sha256 hadoop)" "${hadoop_archive}" | sha256sum -c - || return 30

    if [[ -s "${JDK_OFFLINE_DIR}/$(basename "${jdk_archive}")" ]]; then
        cp -- "${JDK_OFFLINE_DIR}/$(basename "${jdk_archive}")" "${jdk_archive}" || return 30
    else
        with_network_proxy curl -fSL --retry 3 -o "${jdk_archive}" \
            "${BISHENG_JDK_BASE_URL}/$(basename "${jdk_archive}")" || return 30
    fi
    printf '%s  %s\n' "$(hbase_artifact_sha256 jdk)" "${jdk_archive}" | sha256sum -c - || return 30

    rm -rf -- "${HBASE_HOME}" "${HADOOP_HOME}" "${ZK_HOME}"
    tar -xzf "${hbase_archive}" -C "${PERF_WORK_DIR}" || return 30
    tar -xzf "${hadoop_archive}" -C "${PERF_WORK_DIR}" || return 30
    # Hadoop archives always unpack to hadoop-<version> regardless of the -aarch64 suffix.
    [[ -d "${HADOOP_HOME}" ]] || mv "${PERF_WORK_DIR}/hadoop-${HADOOP_VERSION}" "${HADOOP_HOME}" 2>/dev/null || true
    tar -xzf "${zk_archive}" -C "${PERF_WORK_DIR}" || return 30
    [[ -x "${HBASE_HOME}/bin/hbase" && -x "${HADOOP_HOME}/bin/hdfs" && -x "${ZK_HOME}/bin/zkServer.sh" ]] || {
        log_error 'HBase, Hadoop or ZooKeeper distribution is incomplete'; return 30;
    }
    rm -rf -- "${JDK_HOME}"
    tar -xzf "${jdk_archive}" -C "${PERF_WORK_DIR}" || return 30
}

prepare_jdk_link() {
    local java_home version_output
    java_home="$(find "${PERF_WORK_DIR}" -maxdepth 5 -type f -path '*/bin/javac' -print -quit | xargs -r dirname | xargs -r dirname)"
    [[ -n "${java_home}" ]] || { log_error 'BiSheng JDK archive has no javac'; return 30; }
    ln -sfn "${java_home}" "${JDK_HOME}"
    version_output="$("${JDK_HOME}/bin/java" -version 2>&1)" || return 30
    [[ "${version_output}" == *'1.8.0_472'* ]] || { log_error "unexpected JDK: ${version_output}"; return 30; }
}

start_private_container() {
    local -a cert_mount=()
    docker container inspect "${CONTAINER_NAME}" >/dev/null 2>&1 && {
        log_error "refusing to reuse existing container ${CONTAINER_NAME}"; return 30;
    }
    if [[ -n "${PERF_PROXY:-}" ]]; then
        [[ -d "${CA_ANCHORS_DIR}" ]] || { log_error 'proxy CA anchors directory is missing'; return 30; }
        cert_mount+=(--mount "type=bind,source=${CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    docker run --detach --name "${CONTAINER_NAME}" \
        --label "boostkit.hbase.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --cpuset-cpus="${HBASE_CPUSET}" \
        --cpuset-mems="${HBASE_MEMSET}" \
        --memory="${HBASE_MEMORY}" \
        --memory-swap="${HBASE_MEMORY_SWAP}" \
        --ulimit nofile=1048576:1048576 \
        --ulimit memlock=-1:-1 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]+"${cert_mount[@]}"}" \
        "${CONTAINER_IMAGE}" sleep infinity >/dev/null || return 30
    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec --user 0 "${CONTAINER_NAME}" update-ca-trust extract || return 30
        docker exec --user 0 "${CONTAINER_NAME}" sed -i \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || return 30
    fi
}

install_container_shims() {
    # hbase-daemon.sh calls hostname to name its log file; the minimal image
    # does not ship it. The shim only provides a stable name.
    docker exec --user 0 "${CONTAINER_NAME}" sh -c \
        'command -v hostname >/dev/null 2>&1 || { printf "#!/bin/sh\necho localhost\n" > /usr/local/bin/hostname && chmod +x /usr/local/bin/hostname; }' || return 30
}

build_hbase_base() {
    local actual
    initialize_runtime || return $?
    install_host_dependencies || return $?
    require_docker || return $?
    prepare_hbase_archives || return $?
    prepare_jdk_link || return $?
    prepare_container_image || return $?
    start_private_container || return $?
    install_container_shims || return $?

    actual="$(hbase_exec "${HBASE_HOME}/bin/hbase" version 2>&1 | tr -d '\r' \
        | sed -nE 's/^HBase ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -n 1)" || return 30
    [[ "${actual}" == "${SOFTWARE_VERSION}" ]] || {
        log_error "unexpected HBase version: ${actual:-unknown}"; return 30;
    }
    printf '%s\n' "${actual}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "HBase ${actual}, Hadoop ${HADOOP_VERSION}, ZooKeeper ${ZOOKEEPER_VERSION} are ready"
}
