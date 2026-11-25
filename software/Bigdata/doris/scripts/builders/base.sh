#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

install_host_dependencies() {
    local command package
    local -a packages=() dnf_options=()
    for command in docker curl tar sha256sum awk sed python3; do
        command -v "${command}" >/dev/null 2>&1 && continue
        case "${command}" in
            docker) log_error 'Docker must be installed on the Runner'; return 30 ;;
            sha256sum) package=coreutils ;;
            awk) package=gawk ;;
            python3) package=python3 ;;
            *) package="${command}" ;;
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
    if [[ -s "${DORIS_IMAGE_FILE}" ]]; then
        DORIS_CONTAINER_IMAGE="$(<"${DORIS_IMAGE_FILE}")"
        docker image inspect "${DORIS_CONTAINER_IMAGE}" >/dev/null 2>&1 || {
            log_error "cached image reference is invalid: ${DORIS_CONTAINER_IMAGE}"; return 30;
        }
        export DORIS_CONTAINER_IMAGE
        return 0
    fi
    archive="${DORIS_IMAGE_ARCHIVE_DIR}/${name}"
    if [[ ! -s "${archive}" ]]; then
        archive="${PERF_WORK_DIR}/${name}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}" "${url}" || return 30
    fi
    checksum="${DORIS_IMAGE_ARCHIVE_DIR}/${name}.sha256sum"
    if [[ ! -s "${checksum}" ]]; then
        checksum="${PERF_WORK_DIR}/${name}.sha256sum"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${url}.sha256sum" || return 30
    fi
    expected="$(awk 'NR == 1 {print $1}' "${checksum}")"
    [[ "${expected}" =~ ^[[:xdigit:]]{64}$ ]] || { log_error "invalid SHA-256 in ${checksum}"; return 30; }
    actual="$(sha256sum "${archive}")"
    [[ "${actual%% *}" == "${expected,,}" ]] || { log_error "image SHA-256 mismatch for ${archive}"; return 30; }
    output="$(docker load --input "${archive}")" || return 30
    DORIS_CONTAINER_IMAGE="$(printf '%s\n' "${output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    [[ -n "${DORIS_CONTAINER_IMAGE}" ]] || { log_error 'cannot determine loaded image reference'; return 30; }
    docker image inspect "${DORIS_CONTAINER_IMAGE}" >/dev/null 2>&1 || return 30
    image_arch="$(docker image inspect --format '{{.Architecture}}' "${DORIS_CONTAINER_IMAGE}")"
    case "${EXPECTED_ARCH}:${image_arch}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log_error "image architecture ${image_arch} differs from ${EXPECTED_ARCH}"; return 30 ;;
    esac
    release="$(docker run --rm --network=none "${DORIS_CONTAINER_IMAGE}" cat /etc/os-release)" || return 30
    grep -Eq '^ID="?openEuler"?$' <<< "${release}" || { log_error 'loaded image is not openEuler'; return 30; }
    grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}" || { log_error 'loaded image is not openEuler 24.03 LTS SP4'; return 30; }
    printf '%s\n' "${DORIS_CONTAINER_IMAGE}" > "${DORIS_IMAGE_FILE}"
    export DORIS_CONTAINER_IMAGE
}

prepare_doris_release() {
    local archive="${PERF_WORK_DIR}/${DORIS_RELEASE}"
    local url="${DORIS_RELEASE_BASE_URL}/${DORIS_RELEASE}"
    local expected
    expected="$(doris_package_sha256 "${EXPECTED_ARCH}")" || {
        log_error "no recorded checksum for ${DORIS_RELEASE}"; return 30;
    }
    if [[ -s "${DORIS_OFFLINE_DIR}/${DORIS_RELEASE}" ]]; then
        log_message "using local Doris release: ${DORIS_OFFLINE_DIR}/${DORIS_RELEASE}"
        cp -- "${DORIS_OFFLINE_DIR}/${DORIS_RELEASE}" "${archive}" || return 30
    elif [[ -s "${archive}" ]]; then
        log_message "using cached Doris release: ${archive}"
    else
        log_message "downloading Doris ${SOFTWARE_VERSION}: ${url}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}" "${url}" || return 30
    fi
    printf '%s  %s\n' "${expected}" "${archive}" | sha256sum -c - || {
        log_error "SHA-256 mismatch for ${DORIS_RELEASE}"; return 30;
    }
    [[ ! -e "${DORIS_HOME}" ]] || { log_error "release directory already exists: ${DORIS_HOME}"; return 20; }
    tar -xzf "${archive}" -C "${PERF_WORK_DIR}" || return 30
    [[ -x "${DORIS_FE}/bin/start_fe.sh" && -x "${DORIS_BE}/bin/start_be.sh" ]] || {
        log_error 'Doris release is incomplete (missing start_fe.sh or start_be.sh)'; return 30;
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
        *) return 30 ;;
    esac
    archive="${PERF_WORK_DIR}/${archive_name}"
    if [[ -s "${DORIS_JDK_OFFLINE_DIR}/${archive_name}" ]]; then
        cp -- "${DORIS_JDK_OFFLINE_DIR}/${archive_name}" "${archive}" || return 30
    else
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
            -o "${archive}" "${BISHENG_JDK_BASE_URL}/${archive_name}" || return 30
    fi
    printf '%s  %s\n' "${checksum}" "${archive}" | sha256sum -c - || return 30
    [[ ! -e "${DORIS_JDK_HOME}" ]] || rm -rf -- "${DORIS_JDK_HOME}"
    tar -xzf "${archive}" -C "${PERF_WORK_DIR}" || return 30
    java_home="$(find "${PERF_WORK_DIR}" -maxdepth 5 -type f -path '*/bin/javac' -print -quit | xargs -r dirname | xargs -r dirname)"
    [[ -n "${java_home}" ]] || { log_error 'BiSheng JDK archive has no javac'; return 30; }
    ln -sfn "${java_home}" "${DORIS_JDK_HOME}"
    version_output="$("${DORIS_JDK_HOME}/bin/java" -version 2>&1)" || return 30
    [[ "${version_output}" == *'1.8.0_472'* ]] || {
        log_error "unexpected JDK version: ${version_output}"; return 30;
    }
}

prepare_python_dependency() {
    local wheel
    wheel="$(find "${DORIS_PYTHON_OFFLINE_DIR}" -maxdepth 1 -name 'pymysql-*.whl' -print -quit 2>/dev/null || true)"
    if [[ -z "${wheel}" ]]; then
        log_message 'downloading the pure-Python pymysql wheel on the host'
        mkdir -p "${DORIS_PYTHON_OFFLINE_DIR}"
        python3 -m pip download --no-deps -d "${DORIS_PYTHON_OFFLINE_DIR}" \
            -i https://repo.huaweicloud.com/repository/pypi/simple pymysql || return 30
        wheel="$(find "${DORIS_PYTHON_OFFLINE_DIR}" -maxdepth 1 -name 'pymysql-*.whl' -print -quit)"
    fi
    [[ -n "${wheel}" ]] || { log_error 'pymysql wheel is missing'; return 30; }
    rm -rf -- "${PERF_WORK_DIR}/python"
    mkdir -p "${PERF_WORK_DIR}/python"
    python3 -m zipfile -e "${wheel}" "${PERF_WORK_DIR}/python" || return 30
    doris_exec python3 -c 'import pymysql' || {
        log_error 'pymysql is not importable in the container'; return 30;
    }
}

start_private_container() {
    local -a cert_mount=()
    docker container inspect "${DORIS_CONTAINER_NAME}" >/dev/null 2>&1 && {
        log_error "refusing to reuse existing container ${DORIS_CONTAINER_NAME}"; return 30;
    }
    if [[ -n "${PERF_PROXY:-}" ]]; then
        [[ -d "${DORIS_CA_ANCHORS_DIR}" ]] || { log_error "proxy CA anchors directory is missing"; return 30; }
        cert_mount+=(--mount "type=bind,source=${DORIS_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    docker run --detach --name "${DORIS_CONTAINER_NAME}" \
        --label "boostkit.doris.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --cpuset-cpus="${DORIS_CPUSET}" \
        --cpuset-mems="${DORIS_MEMSET}" \
        --memory="${DORIS_MEMORY}" \
        --memory-swap="${DORIS_MEMORY_SWAP}" \
        --ulimit nofile=1048576:1048576 \
        --ulimit memlock=-1:-1 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]+"${cert_mount[@]}"}" \
        "${DORIS_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 30
    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec --user 0 "${DORIS_CONTAINER_NAME}" update-ca-trust extract || return 30
    fi
    # Switch the package source only inside this task's container: the official
    # openEuler repo is slow or unreachable on many runners.
    docker exec --user 0 "${DORIS_CONTAINER_NAME}" sed -i \
        -e '/^meta/ s/^\(.*\)$/#\1/g' \
        -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
        /etc/yum.repos.d/openEuler.repo || return 30
}

read_doris_version() {
    # The FE jar manifest carries a stale 1.2-SNAPSHOT; the BE binary reports
    # the real release, e.g. "doris-2.1.2-rc04(AVX2) RELEASE ...".
    doris_exec bash -c "cd '${DORIS_HOME}' && be/lib/doris_be --version" 2>/dev/null \
        | sed -nE 's/^doris-([^ (]+).*/\1/p' | head -n 1
}

install_container_tools() {
    local -a missing=()
    doris_exec bash -c 'command -v gcc' >/dev/null 2>&1 || missing+=(gcc)
    doris_exec bash -c 'command -v make' >/dev/null 2>&1 || missing+=(make)
    doris_exec bash -c 'command -v curl' >/dev/null 2>&1 || missing+=(curl)
    if (( ${#missing[@]} > 0 )); then
        log_message "installing container tools: ${missing[*]}"
        doris_exec_root install -y "${missing[@]}" || return 30
    fi
    doris_exec bash -c 'gcc --version >/dev/null 2>&1 && make --version >/dev/null 2>&1 && curl --version >/dev/null 2>&1' || {
        log_error 'gcc/make/curl are not usable in the container'; return 30;
    }
}

prepare_tpch_kit() {
    local zip="${DORIS_TPCH_OFFLINE_DIR}/tpch-kit-master.zip"
    local kit="${PERF_WORK_DIR}/tpch-kit"
    if [[ ! -d "${kit}/dbgen" ]]; then
        if [[ -s "${zip}" ]]; then
            cp -- "${zip}" "${PERF_WORK_DIR}/tpch-kit-master.zip" || return 30
        else
            with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
                -o "${PERF_WORK_DIR}/tpch-kit-master.zip" \
                "https://codeload.github.com/gregrahn/tpch-kit/zip/refs/heads/master" || return 30
        fi
        rm -rf "${PERF_WORK_DIR}/tpch-kit-extract"
        mkdir -p "${PERF_WORK_DIR}/tpch-kit-extract"
        python3 -m zipfile -e "${PERF_WORK_DIR}/tpch-kit-master.zip" \
            "${PERF_WORK_DIR}/tpch-kit-extract" || return 30
        local dbgen_dir
        dbgen_dir="$(find "${PERF_WORK_DIR}/tpch-kit-extract" -maxdepth 3 -type d -name dbgen -print -quit)"
        [[ -n "${dbgen_dir}" ]] || { log_error 'tpch-kit archive has no dbgen'; return 30; }
        ln -sfn "$(dirname "${dbgen_dir}")" "${kit}"
    fi
    if [[ ! -x "${kit}/dbgen/dbgen" ]]; then
        log_message 'building TPC-H dbgen in the container'
        doris_exec bash -c "cd '${kit}/dbgen' && make -j\"\$(nproc)\"" >/dev/null || {
            log_error 'TPC-H dbgen build failed'; return 30;
        }
    fi
    [[ -x "${kit}/dbgen/dbgen" ]] || { log_error 'TPC-H dbgen binary is missing'; return 30; }
}

build_doris_base() {
    local raw_version version
    initialize_runtime || return $?
    install_host_dependencies || return $?
    require_docker || return $?
    prepare_doris_release || return $?
    prepare_bisheng_jdk || return $?
    prepare_container_image || return $?
    start_private_container || return $?
    docker exec --user 0 "${DORIS_CONTAINER_NAME}" sh -c \
        'command -v hostname >/dev/null 2>&1 || { printf "#!/bin/sh\necho localhost\n" > /usr/local/bin/hostname && chmod +x /usr/local/bin/hostname; }' || return 30
    install_container_tools || return $?
    prepare_tpch_kit || return $?
    mkdir -p "${PERF_WORK_DIR}/tools"
    cp -- "${CASE_DIR}/scripts/tools/doris_client.py" "${PERF_WORK_DIR}/tools/" || return 30
    prepare_python_dependency || return $?

    raw_version="$(read_doris_version)" || return 30
    # The BE binary reports the release candidate build string, e.g.
    # 2.1.2-rc04; the Framework compares the plain release version.
    version="${raw_version%%-rc*}"
    [[ -n "${version}" && "${version}" == "${SOFTWARE_VERSION}" ]] || {
        log_error "unexpected Doris version: ${raw_version:-unknown}"; return 30;
    }
    printf '%s\n' "${version}" > "${PERF_ACTUAL_VERSION_FILE}"
    printf '%s\n' "${raw_version}" > "${RESULTS_DIR}/doris_build_string.txt"
    log_message "Doris ${raw_version} (release ${version}) and BiSheng JDK are ready in ${DORIS_CONTAINER_NAME}"
}
