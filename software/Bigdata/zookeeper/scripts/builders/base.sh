#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

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

prepare_container_image() {
    local name="openEuler-docker.${EXPECTED_ARCH}.tar.xz"
    local archive checksum expected actual output image_arch release
    local url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${name}"

    if [[ -s "${ZK_IMAGE_FILE}" ]]; then
        ZK_CONTAINER_IMAGE="$(<"${ZK_IMAGE_FILE}")"
        docker image inspect "${ZK_CONTAINER_IMAGE}" >/dev/null 2>&1 || {
            log_error "cached image reference is invalid: ${ZK_CONTAINER_IMAGE}"; return 30;
        }
        export ZK_CONTAINER_IMAGE
        return 0
    fi

    archive="${ZK_IMAGE_ARCHIVE_DIR}/${name}"
    if [[ ! -s "${archive}" ]]; then
        archive="${PERF_WORK_DIR}/${name}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
            -o "${archive}" "${url}" || return 30
    fi

    checksum="${ZK_IMAGE_ARCHIVE_DIR}/${name}.sha256sum"
    if [[ ! -s "${checksum}" ]]; then
        checksum="${PERF_WORK_DIR}/${name}.sha256sum"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
            -o "${checksum}" "${url}.sha256sum" || return 30
    fi

    expected="$(awk 'NR == 1 {print $1}' "${checksum}")"
    [[ "${expected}" =~ ^[[:xdigit:]]{64}$ ]] || {
        log_error "invalid SHA-256 in ${checksum}"; return 30;
    }
    actual="$(sha256sum "${archive}")"
    [[ "${actual%% *}" == "${expected,,}" ]] || {
        log_error "image SHA-256 mismatch for ${archive}"; return 30;
    }

    output="$(docker load --input "${archive}")" || return 30
    ZK_CONTAINER_IMAGE="$(printf '%s\n' "${output}" \
        | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    [[ -n "${ZK_CONTAINER_IMAGE}" ]] || {
        log_error 'cannot determine loaded image reference from docker load output'; return 30;
    }
    docker image inspect "${ZK_CONTAINER_IMAGE}" >/dev/null 2>&1 || {
        log_error "loaded image is not inspectable: ${ZK_CONTAINER_IMAGE}"; return 30;
    }

    image_arch="$(docker image inspect --format '{{.Architecture}}' "${ZK_CONTAINER_IMAGE}")"
    case "${EXPECTED_ARCH}:${image_arch}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log_error "image architecture ${image_arch} differs from ${EXPECTED_ARCH}"; return 30 ;;
    esac

    release="$(docker run --rm --network=none "${ZK_CONTAINER_IMAGE}" cat /etc/os-release)" || return 30
    grep -Eq '^ID="?openEuler"?$' <<< "${release}" || {
        log_error 'loaded image is not openEuler'; return 30;
    }
    grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}" || {
        log_error 'loaded image is not openEuler 24.03 LTS SP4'; return 30;
    }

    printf '%s\n' "${ZK_CONTAINER_IMAGE}" > "${ZK_IMAGE_FILE}"
    export ZK_CONTAINER_IMAGE
}

prepare_zookeeper_release() {
    local archive="${PERF_WORK_DIR}/${ZK_ARCHIVE_NAME}"
    local remote="https://repo.huaweicloud.com/apache/zookeeper/zookeeper-3.6.2/${ZK_ARCHIVE_NAME}"

    if [[ -s "${ZK_OFFLINE_DIR}/${ZK_ARCHIVE_NAME}" ]]; then
        log_message "using local ZooKeeper archive: ${ZK_OFFLINE_DIR}/${ZK_ARCHIVE_NAME}"
        cp -- "${ZK_OFFLINE_DIR}/${ZK_ARCHIVE_NAME}" "${archive}" || return 30
    else
        log_message "downloading ZooKeeper 3.6.2: ${remote}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
            -o "${archive}" "${remote}" || return 30
    fi

    printf '%s  %s\n' "${ZK_ARCHIVE_SHA512}" "${archive}" | sha512sum -c - || {
        log_error "SHA-512 mismatch for ${ZK_ARCHIVE_NAME}"; return 30;
    }

    [[ ! -e "${ZK_HOME}" ]] || { log_error "release directory already exists: ${ZK_HOME}"; return 20; }
    tar -xzf "${archive}" -C "${PERF_WORK_DIR}" || return 30
    [[ -x "${ZK_HOME}/bin/zkServer.sh" ]] || {
        log_error "ZooKeeper distribution is incomplete: ${ZK_HOME}/bin/zkServer.sh"; return 30;
    }
}

prepare_bisheng_jdk() {
    local archive_name checksum archive java_home version_output
    case "${EXPECTED_ARCH}" in
        x86_64)
            archive_name="bisheng-jdk-${BISHENG_JDK_RELEASE}-linux-x64.tar.gz"
            checksum="45d5daf61a2670d20c7c2eed476577d7ef2d685a84f9f963464e8413b2b8c012"
            ;;
        aarch64)
            archive_name="bisheng-jdk-${BISHENG_JDK_RELEASE}-linux-aarch64.tar.gz"
            checksum="b5366023c742a29e0527c0c2d6bdd207a625084969e2693a248a0f328ad2c031"
            ;;
        *) log_error "no BiSheng JDK 8 archive for ${EXPECTED_ARCH}"; return 30 ;;
    esac

    archive="${PERF_WORK_DIR}/${archive_name}"
    if [[ -s "${ZK_JDK_OFFLINE_DIR}/${archive_name}" ]]; then
        log_message "using local BiSheng JDK: ${ZK_JDK_OFFLINE_DIR}/${archive_name}"
        cp -- "${ZK_JDK_OFFLINE_DIR}/${archive_name}" "${archive}" || return 30
    else
        log_message "downloading BiSheng JDK ${BISHENG_JDK_RELEASE}: ${archive_name}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
            -o "${archive}" "${BISHENG_JDK_BASE_URL}/${archive_name}" || return 30
    fi
    printf '%s  %s\n' "${checksum}" "${archive}" | sha256sum -c - || {
        log_error "SHA-256 mismatch for ${archive_name}"; return 30;
    }

    [[ ! -e "${ZK_JDK_HOME}" ]] || rm -rf -- "${ZK_JDK_HOME}"
    tar -xzf "${archive}" -C "${PERF_WORK_DIR}" || return 30
    java_home="$(find "${PERF_WORK_DIR}" -maxdepth 5 -type f -path '*/bin/javac' -print -quit | xargs -r dirname | xargs -r dirname)"
    [[ -n "${java_home}" && -x "${java_home}/bin/java" ]] || {
        log_error 'BiSheng JDK archive does not contain a usable javac'; return 30;
    }
    ln -sfn "${java_home}" "${ZK_JDK_HOME}"
    version_output="$("${ZK_JDK_HOME}/bin/java" -version 2>&1)" || return 30
    [[ "${version_output}" == *'1.8.0_472'* ]] || {
        log_error "unexpected JDK version: ${version_output}"; return 30;
    }
}

start_private_container() {
    local -a cert_mount=()

    docker container inspect "${ZK_CONTAINER_NAME}" >/dev/null 2>&1 && {
        log_error "refusing to reuse existing container ${ZK_CONTAINER_NAME}"; return 30;
    }
    if [[ -n "${PERF_PROXY:-}" ]]; then
        [[ -d "${ZK_CA_ANCHORS_DIR}" ]] || {
            log_error "proxy CA anchors directory is missing: ${ZK_CA_ANCHORS_DIR}"; return 30;
        }
        cert_mount+=(
            --mount "type=bind,source=${ZK_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly"
        )
    fi

    docker run --detach --name "${ZK_CONTAINER_NAME}" \
        --label "boostkit.zookeeper.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --cpuset-cpus="${ZK_CPUSET}" \
        --cpuset-mems="${ZK_MEMSET}" \
        --memory="${ZK_MEMORY}" \
        --memory-swap="${ZK_MEMORY_SWAP}" \
        --ulimit nofile=1048576:1048576 \
        --ulimit memlock=-1:-1 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]+"${cert_mount[@]}"}" \
        "${ZK_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 30

    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec --user 0 "${ZK_CONTAINER_NAME}" update-ca-trust extract || return 30
    fi
    # Switch the package source only inside this task's container: the official
    # openEuler repo is slow or unreachable on many runners.
    docker exec --user 0 "${ZK_CONTAINER_NAME}" sed -i \
        -e '/^meta/ s/^\(.*\)$/#\1/g' \
        -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
        /etc/yum.repos.d/openEuler.repo || return 30
}

compile_zkbench() {
    local source="${CASE_DIR}/scripts/tools/ZkBench.java"
    mkdir -p "${ZK_BENCH_DIR}"
    cp -- "${source}" "${CASE_DIR}/scripts/tools/log4j.properties" "${ZK_BENCH_DIR}/" || return 30
    # The container locale is POSIX; the tool source is UTF-8.
    zk_exec "${ZK_JDK_HOME}/bin/javac" -encoding UTF-8 -nowarn -cp "${ZK_HOME}/lib/*" \
        -d "${ZK_BENCH_DIR}" "${ZK_BENCH_DIR}/ZkBench.java" || return 30
    [[ -f "${ZK_BENCH_DIR}/ZkBench.class" ]] || { log_error 'ZkBench compilation produced no class'; return 30; }
}

build_zookeeper_base() {
    local actual

    initialize_runtime || return $?
    install_host_dependencies || return $?
    require_docker || return $?

    prepare_zookeeper_release || return $?
    prepare_bisheng_jdk || return $?
    prepare_container_image || return $?
    start_private_container || return $?
    compile_zkbench || return $?

    actual="$(zk_exec "${ZK_HOME}/bin/zkServer.sh" version 2>&1 | tr -d '\r' \
        | sed -nE 's/.*version ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | tail -n 1)" || return 30
    [[ "${actual}" == "3.6.2" ]] || {
        log_error "unexpected ZooKeeper version: ${actual:-unknown}"; return 30;
    }
    printf '%s\n' "${actual}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "BiSheng JDK and ZooKeeper ${actual} are ready in ${ZK_CONTAINER_NAME}"
}
