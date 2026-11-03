#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

install_host_dependencies() {
    local command package
    local -a packages=() dnf_options=()
    for command in docker curl tar sha512sum sha256sum awk sed; do
        command -v "${command}" >/dev/null 2>&1 && continue
        case "${command}" in
            docker) log_message 'ERROR: Docker must be installed on the Runner'; return 30 ;;
            sha512sum|sha256sum) package=coreutils ;;
            awk) package=gawk ;;
            *) package="${command}" ;;
        esac
        packages+=("${package}")
    done
    (( ${#packages[@]} > 0 )) || return 0
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing missing host packages: ${packages[*]}"
    if (( EUID == 0 )); then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    else
        sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    fi
}

prepare_release() {
    local archive_name="$1" expected="$2" version_dir="$3" url="$4"
    local archive="${PERF_WORK_DIR}/${archive_name}"
    if [[ -s "${KAFKA_OFFLINE_DIR}/${archive_name}" ]]; then
        log_message "using local release: ${KAFKA_OFFLINE_DIR}/${archive_name}"
        cp -- "${KAFKA_OFFLINE_DIR}/${archive_name}" "${archive}" || return 30
    else
        log_message "downloading official release: ${url}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}" "${url}" || return 30
    fi
    printf '%s  %s\n' "${expected}" "${archive}" | sha512sum -c - || {
        log_message "ERROR: SHA-512 mismatch for ${archive_name}"; return 30;
    }
    [[ ! -e "${version_dir}" ]] || { log_message "ERROR: release directory already exists: ${version_dir}"; return 20; }
    tar -xzf "${archive}" -C "${PERF_WORK_DIR}" || return 30
    [[ -d "${version_dir}" ]] || { log_message "ERROR: release directory missing: ${version_dir}"; return 30; }
}

prepare_container_image() {
    local name="openEuler-docker.${EXPECTED_ARCH}.tar.xz" archive checksum expected actual output image_arch release
    local url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${name}"
    if [[ -s "${KAFKA_IMAGE_FILE}" ]]; then
        KAFKA_CONTAINER_IMAGE="$(<"${KAFKA_IMAGE_FILE}")"
        docker image inspect "${KAFKA_CONTAINER_IMAGE}" >/dev/null 2>&1 || return 30
        return 0
    fi
    archive="${KAFKA_IMAGE_ARCHIVE_DIR}/${name}"
    if [[ ! -s "${archive}" ]]; then
        archive="${PERF_WORK_DIR}/${name}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}" "${url}" || return 30
    fi
    checksum="${KAFKA_IMAGE_ARCHIVE_DIR}/${name}.sha256sum"
    if [[ ! -s "${checksum}" ]]; then
        checksum="${PERF_WORK_DIR}/${name}.sha256sum"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${url}.sha256sum" || return 30
    fi
    expected="$(awk 'NR == 1 {print $1}' "${checksum}")"
    [[ "${expected}" =~ ^[[:xdigit:]]{64}$ ]] || return 30
    actual="$(sha256sum "${archive}")"
    [[ "${actual%% *}" == "${expected,,}" ]] || { log_message 'ERROR: image SHA-256 mismatch'; return 30; }
    output="$(docker load --input "${archive}")" || return 30
    KAFKA_CONTAINER_IMAGE="$(printf '%s\n' "${output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    [[ -n "${KAFKA_CONTAINER_IMAGE}" ]] && docker image inspect "${KAFKA_CONTAINER_IMAGE}" >/dev/null 2>&1 || return 30
    image_arch="$(docker image inspect --format '{{.Architecture}}' "${KAFKA_CONTAINER_IMAGE}")"
    case "${EXPECTED_ARCH}:${image_arch}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log_message "ERROR: image architecture ${image_arch} differs from ${EXPECTED_ARCH}"; return 30 ;;
    esac
    release="$(docker run --rm --network=none "${KAFKA_CONTAINER_IMAGE}" cat /etc/os-release)" || return 30
    grep -Eq '^ID="?openEuler"?$' <<< "${release}" && \
        grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}" || {
        log_message 'ERROR: loaded image is not openEuler 24.03 LTS SP4'; return 30;
    }
    printf '%s\n' "${KAFKA_CONTAINER_IMAGE}" > "${KAFKA_IMAGE_FILE}"
}

start_private_container() {
    local -a cert_mount=()
    docker container inspect "${KAFKA_CONTAINER_NAME}" >/dev/null 2>&1 && {
        log_message "ERROR: refusing to reuse existing container ${KAFKA_CONTAINER_NAME}"; return 30;
    }
    if [[ -n "${PERF_PROXY:-}" ]]; then
        [[ -d "${KAFKA_CA_ANCHORS_DIR}" ]] || { log_message 'ERROR: proxy CA anchors missing'; return 30; }
        cert_mount+=(--mount "type=bind,source=${KAFKA_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    docker run --detach --name "${KAFKA_CONTAINER_NAME}" \
        --label "boostkit.kafka.run-id=${PERF_RUN_ID}" --network=host \
        --user "$(id -u):$(id -g)" \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${KAFKA_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 30
    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec --user 0 "${KAFKA_CONTAINER_NAME}" update-ca-trust extract || return 30
    fi
    docker exec --user 0 "${KAFKA_CONTAINER_NAME}" sed -i \
        -e '/^meta/ s/^\(.*\)$/#\1/g' \
        -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
        /etc/yum.repos.d/openEuler.repo || return 30
}

build_kafka_base() {
    local actual
    initialize_runtime || return $?
    install_host_dependencies || return $?
    require_docker || return $?
    prepare_release "kafka_2.12-${SOFTWARE_VERSION}.tgz" "${KAFKA_ARCHIVE_SHA512}" "${KAFKA_HOME}" \
        "https://archive.apache.org/dist/kafka/${SOFTWARE_VERSION}/kafka_2.12-${SOFTWARE_VERSION}.tgz" || return $?
    prepare_release apache-zookeeper-3.6.2-bin.tar.gz "${ZOOKEEPER_ARCHIVE_SHA512}" "${ZOOKEEPER_HOME}" \
        https://archive.apache.org/dist/zookeeper/zookeeper-3.6.2/apache-zookeeper-3.6.2-bin.tar.gz || return $?
    prepare_container_image || return $?
    start_private_container || return $?
    log_message 'installing Java 11 in the private openEuler container'
    kafka_exec_root install -y java-11-openjdk-headless || return 30
    actual="$(kafka_exec "${KAFKA_HOME}/bin/kafka-topics.sh" --version | head -n 1)" || return 30
    [[ "${actual}" == "${SOFTWARE_VERSION}"* ]] || { log_message "ERROR: unexpected Kafka version: ${actual}"; return 30; }
    [[ -s "${ZOOKEEPER_HOME}/lib/zookeeper-3.6.2.jar" ]] || {
        log_message 'ERROR: ZooKeeper 3.6.2 distribution is incomplete'; return 30;
    }
    printf '%s\n' "${SOFTWARE_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "official Kafka ${SOFTWARE_VERSION} and ZooKeeper 3.6.2 are ready"
}
