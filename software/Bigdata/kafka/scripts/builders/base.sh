#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# ============================================================
# 宿主机依赖
# ============================================================
install_host_dependencies() {
    local command package
    local -a packages=() dnf_options=()

    for command in docker curl tar sha512sum sha256sum awk sed; do
        command -v "${command}" >/dev/null 2>&1 && continue
        case "${command}" in
            docker)
                log_error "Docker must be installed on the Runner"
                return 30
                ;;
            sha512sum|sha256sum) package=coreutils ;;
            awk)                 package=gawk ;;
            *)                   package="${command}" ;;
        esac
        packages+=("${package}")
    done

    (( ${#packages[@]} > 0 )) || return 0

    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")

    log_message "installing missing host packages: ${packages[*]}"
    if (( EUID == 0 )); then
        dnf "${dnf_options[@]+"${dnf_options[@]}"}" install -y "${packages[@]}" || return 30
    else
        sudo -n dnf "${dnf_options[@]+"${dnf_options[@]}"}" install -y "${packages[@]}" || return 30
    fi
}

# ============================================================
# 离线包/发行包准备
# ============================================================
prepare_release() {
    local archive_name="$1" expected="$2" version_dir="$3" url="$4"
    local archive="${PERF_WORK_DIR}/${archive_name}"

    if [[ -s "${KAFKA_OFFLINE_DIR}/${archive_name}" ]]; then
        log_message "using local release: ${KAFKA_OFFLINE_DIR}/${archive_name}"
        cp -- "${KAFKA_OFFLINE_DIR}/${archive_name}" "${archive}" || return 30
    else
        log_message "downloading official release: ${url}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
            -o "${archive}" "${url}" || return 30
    fi

    printf '%s  %s\n' "${expected}" "${archive}" | sha512sum -c - || {
        log_error "SHA-512 mismatch for ${archive_name}"
        return 30
    }

    [[ ! -e "${version_dir}" ]] || {
        log_error "release directory already exists: ${version_dir}"
        return 20
    }

    tar -xzf "${archive}" -C "${PERF_WORK_DIR}" || return 30
    [[ -d "${version_dir}" ]] || {
        log_error "release directory missing after extract: ${version_dir}"
        return 30
    }
}

# ============================================================
# 容器镜像准备
# ============================================================
prepare_container_image() {
    local name="openEuler-docker.${EXPECTED_ARCH}.tar.xz"
    local archive checksum expected actual output image_arch release
    local url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${name}"

    # 已缓存镜像引用：直接校验
    if [[ -s "${KAFKA_IMAGE_FILE}" ]]; then
        KAFKA_CONTAINER_IMAGE="$(<"${KAFKA_IMAGE_FILE}")"
        docker image inspect "${KAFKA_CONTAINER_IMAGE}" >/dev/null 2>&1 || {
            log_error "cached image reference is invalid: ${KAFKA_CONTAINER_IMAGE}"
            return 30
        }
        export KAFKA_CONTAINER_IMAGE
        return 0
    fi

    # 镜像归档
    archive="${KAFKA_IMAGE_ARCHIVE_DIR}/${name}"
    if [[ ! -s "${archive}" ]]; then
        archive="${PERF_WORK_DIR}/${name}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
            -o "${archive}" "${url}" || return 30
    fi

    # 校验文件
    checksum="${KAFKA_IMAGE_ARCHIVE_DIR}/${name}.sha256sum"
    if [[ ! -s "${checksum}" ]]; then
        checksum="${PERF_WORK_DIR}/${name}.sha256sum"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
            -o "${checksum}" "${url}.sha256sum" || return 30
    fi

    expected="$(awk 'NR == 1 {print $1}' "${checksum}")"
    [[ "${expected}" =~ ^[[:xdigit:]]{64}$ ]] || {
        log_error "invalid SHA-256 in ${checksum}"
        return 30
    }

    actual="$(sha256sum "${archive}")"
    [[ "${actual%% *}" == "${expected,,}" ]] || {
        log_error "image SHA-256 mismatch for ${archive}"
        return 30
    }

    # 加载镜像
    output="$(docker load --input "${archive}")" || return 30
    KAFKA_CONTAINER_IMAGE="$(printf '%s\n' "${output}" \
        | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' \
        | tail -n 1)"
    [[ -n "${KAFKA_CONTAINER_IMAGE}" ]] || {
        log_error "cannot determine loaded image reference from docker load output"
        return 30
    }
    docker image inspect "${KAFKA_CONTAINER_IMAGE}" >/dev/null 2>&1 || {
        log_error "loaded image is not inspectable: ${KAFKA_CONTAINER_IMAGE}"
        return 30
    }
    export KAFKA_CONTAINER_IMAGE

    # 架构校验
    image_arch="$(docker image inspect --format '{{.Architecture}}' "${KAFKA_CONTAINER_IMAGE}")"
    case "${EXPECTED_ARCH}:${image_arch}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_error "image architecture ${image_arch} differs from ${EXPECTED_ARCH}"
            return 30
            ;;
    esac

    # 发行版校验
    release="$(docker run --rm --network=none "${KAFKA_CONTAINER_IMAGE}" cat /etc/os-release)" || return 30
    grep -Eq '^ID="?openEuler"?$' <<< "${release}" || {
        log_error "loaded image is not openEuler"
        return 30
    }
    grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}" || {
        log_error "loaded image is not openEuler 24.03 LTS SP4"
        return 30
    }

    printf '%s\n' "${KAFKA_CONTAINER_IMAGE}" > "${KAFKA_IMAGE_FILE}"
}

# ============================================================
# 私有容器
# ============================================================
start_private_container() {
    local -a cert_mount=() java_mount=()

    if [[ "${KAFKA_JAVA_MODE:-package}" == "host" ]]; then
        [[ -d /usr/lib/jvm && -d /etc/java ]] || {
            log_error "host Java directories /usr/lib/jvm or /etc/java are missing"
            return 30
        }
        java_mount=(
            --mount type=bind,source=/usr/lib/jvm,target=/usr/lib/jvm,readonly
            --mount type=bind,source=/etc/java,target=/etc/java,readonly
        )
    fi

    docker container inspect "${KAFKA_CONTAINER_NAME}" >/dev/null 2>&1 && {
        log_error "refusing to reuse existing container ${KAFKA_CONTAINER_NAME}"
        return 30
    }

    if [[ -n "${PERF_PROXY:-}" ]]; then
        [[ -d "${KAFKA_CA_ANCHORS_DIR}" ]] || {
            log_error "proxy CA anchors directory is missing: ${KAFKA_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(
            --mount "type=bind,source=${KAFKA_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly"
        )
    fi

    docker run --detach --name "${KAFKA_CONTAINER_NAME}" \
        --label "boostkit.kafka.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${java_mount[@]+"${java_mount[@]}"}" \
        "${cert_mount[@]+"${cert_mount[@]}"}" \
        "${KAFKA_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 30

    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec --user 0 "${KAFKA_CONTAINER_NAME}" update-ca-trust extract || return 30
    fi

    docker exec --user 0 "${KAFKA_CONTAINER_NAME}" sed -i \
        -e '/^meta/ s/^\(.*\)$/#\1/g' \
        -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
        /etc/yum.repos.d/openEuler.repo || return 30
}

# ============================================================
# base 构建入口
# ============================================================
build_kafka_base() {
    local actual

    initialize_runtime || return $?
    install_host_dependencies || return $?
    require_docker || return $?

    prepare_release \
        "kafka_2.12-${SOFTWARE_VERSION}.tgz" \
        "${KAFKA_ARCHIVE_SHA512}" \
        "${KAFKA_HOME}" \
        "https://archive.apache.org/dist/kafka/${SOFTWARE_VERSION}/kafka_2.12-${SOFTWARE_VERSION}.tgz" \
        || return $?

    prepare_release \
        "apache-zookeeper-3.6.2-bin.tar.gz" \
        "${ZOOKEEPER_ARCHIVE_SHA512}" \
        "${ZOOKEEPER_HOME}" \
        "https://archive.apache.org/dist/zookeeper/zookeeper-3.6.2/apache-zookeeper-3.6.2-bin.tar.gz" \
        || return $?

    prepare_container_image || return $?
    start_private_container || return $?

    log_message 'preparing Java 11 in the private openEuler container'
    if [[ "${KAFKA_JAVA_MODE:-package}" == "host" ]]; then
        docker exec --user 0 "${KAFKA_CONTAINER_NAME}" sh -c \
            'ln -sf "$(ls -d /usr/lib/jvm/java-11-openjdk-*/bin/java | head -n1)" /usr/bin/java' || return 30
    else
        kafka_exec_root install -y java-11-openjdk-headless || return 30
    fi

    actual="$(kafka_exec "${KAFKA_HOME}/bin/kafka-topics.sh" --version | head -n 1)" || return 30
    [[ "${actual}" == "${SOFTWARE_VERSION}"* ]] || {
        log_error "unexpected Kafka version: ${actual} (expected ${SOFTWARE_VERSION})"
        return 30
    }

    [[ -s "${ZOOKEEPER_HOME}/lib/zookeeper-3.6.2.jar" ]] || {
        log_error "ZooKeeper 3.6.2 distribution is incomplete: ${ZOOKEEPER_HOME}/lib/zookeeper-3.6.2.jar"
        return 30
    }

    printf '%s\n' "${SOFTWARE_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "official Kafka ${SOFTWARE_VERSION} and ZooKeeper 3.6.2 are ready"
}
