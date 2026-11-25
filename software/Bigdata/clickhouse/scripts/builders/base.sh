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

    if [[ -s "${CH_IMAGE_FILE}" ]]; then
        CH_CONTAINER_IMAGE="$(<"${CH_IMAGE_FILE}")"
        docker image inspect "${CH_CONTAINER_IMAGE}" >/dev/null 2>&1 || {
            log_error "cached image reference is invalid: ${CH_CONTAINER_IMAGE}"; return 30;
        }
        export CH_CONTAINER_IMAGE
        return 0
    fi
    archive="${CH_IMAGE_ARCHIVE_DIR}/${name}"
    if [[ ! -s "${archive}" ]]; then
        archive="${PERF_WORK_DIR}/${name}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}" "${url}" || return 30
    fi
    checksum="${CH_IMAGE_ARCHIVE_DIR}/${name}.sha256sum"
    if [[ ! -s "${checksum}" ]]; then
        checksum="${PERF_WORK_DIR}/${name}.sha256sum"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${url}.sha256sum" || return 30
    fi
    expected="$(awk 'NR == 1 {print $1}' "${checksum}")"
    [[ "${expected}" =~ ^[[:xdigit:]]{64}$ ]] || { log_error "invalid SHA-256 in ${checksum}"; return 30; }
    actual="$(sha256sum "${archive}")"
    [[ "${actual%% *}" == "${expected,,}" ]] || { log_error "image SHA-256 mismatch for ${archive}"; return 30; }

    output="$(docker load --input "${archive}")" || return 30
    CH_CONTAINER_IMAGE="$(printf '%s\n' "${output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    [[ -n "${CH_CONTAINER_IMAGE}" ]] || { log_error 'cannot determine loaded image reference'; return 30; }
    docker image inspect "${CH_CONTAINER_IMAGE}" >/dev/null 2>&1 || return 30
    image_arch="$(docker image inspect --format '{{.Architecture}}' "${CH_CONTAINER_IMAGE}")"
    case "${EXPECTED_ARCH}:${image_arch}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log_error "image architecture ${image_arch} differs from ${EXPECTED_ARCH}"; return 30 ;;
    esac
    release="$(docker run --rm --network=none "${CH_CONTAINER_IMAGE}" cat /etc/os-release)" || return 30
    grep -Eq '^ID="?openEuler"?$' <<< "${release}" || { log_error 'loaded image is not openEuler'; return 30; }
    grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}" || { log_error 'loaded image is not openEuler 24.03 LTS SP4'; return 30; }
    printf '%s\n' "${CH_CONTAINER_IMAGE}" > "${CH_IMAGE_FILE}"
    export CH_CONTAINER_IMAGE
}

prepare_clickhouse_packages() {
    local package archive expected url
    mkdir -p "${CH_PKG_DIR}" "${CH_HOME}/bin"
    for package in common-static server client; do
        archive="${CH_PKG_DIR}/clickhouse-${package}-${SOFTWARE_VERSION}-${CH_PACKAGE_ARCH}.tgz"
        url="${CH_PACKAGE_BASE_URL}/clickhouse-${package}-${SOFTWARE_VERSION}-${CH_PACKAGE_ARCH}.tgz"
        expected="$(ch_package_sha256 "${package}" "${CH_PACKAGE_ARCH}")" || {
            log_error "no recorded checksum for ${package}/${CH_PACKAGE_ARCH}"; return 30;
        }
        if [[ -s "${CH_OFFLINE_DIR}/$(basename "${archive}")" ]]; then
            log_message "using local ClickHouse package: ${package}"
            cp -- "${CH_OFFLINE_DIR}/$(basename "${archive}")" "${archive}" || return 30
        elif [[ -s "${archive}" ]]; then
            log_message "using cached ClickHouse package: ${archive}"
        else
            log_message "downloading ClickHouse package: ${url}"
            with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}" "${url}" || return 30
        fi
        printf '%s  %s\n' "${expected}" "${archive}" | sha256sum -c - || {
            log_error "SHA-256 mismatch for $(basename "${archive}")"; return 30;
        }
        tar -xzf "${archive}" -C "${CH_PKG_DIR}" || return 30
    done
    local binary="${CH_PKG_DIR}/clickhouse-common-static-${SOFTWARE_VERSION}/usr/bin/clickhouse"
    [[ -x "${binary}" ]] || { log_error "ClickHouse multiplexer binary is missing: ${binary}"; return 30; }
    ln -sfn "${binary}" "${CH_BIN}"
    chmod +x "${binary}"
}

start_private_container() {
    local -a cert_mount=()
    docker container inspect "${CH_CONTAINER_NAME}" >/dev/null 2>&1 && {
        log_error "refusing to reuse existing container ${CH_CONTAINER_NAME}"; return 30;
    }
    if [[ -n "${PERF_PROXY:-}" ]]; then
        [[ -d "${CH_CA_ANCHORS_DIR}" ]] || { log_error "proxy CA anchors directory is missing: ${CH_CA_ANCHORS_DIR}"; return 30; }
        cert_mount+=(--mount "type=bind,source=${CH_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    docker run --detach --name "${CH_CONTAINER_NAME}" \
        --label "boostkit.clickhouse.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --cpuset-cpus="${CH_CPUSET}" \
        --cpuset-mems="${CH_MEMSET}" \
        --memory="${CH_MEMORY}" \
        --memory-swap="${CH_MEMORY_SWAP}" \
        --ulimit nofile=1048576:1048576 \
        --ulimit memlock=-1:-1 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]+"${cert_mount[@]}"}" \
        "${CH_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 30
    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec --user 0 "${CH_CONTAINER_NAME}" update-ca-trust extract || return 30
        docker exec --user 0 "${CH_CONTAINER_NAME}" sed -i \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || return 30
    fi
}

install_container_tools() {
    if ! ch_exec bash -c 'command -v gcc >/dev/null 2>&1 && command -v make >/dev/null 2>&1'; then
        log_message 'installing gcc and make in the container'
        ch_exec_root install -y gcc make || return 30
    fi
    ch_exec bash -c 'gcc --version >/dev/null 2>&1 && make --version >/dev/null 2>&1' || {
        log_error 'gcc/make are not usable in the container'; return 30;
    }
}

prepare_tpch_kit() {
    local zip="${CH_TPCH_OFFLINE_DIR}/tpch-kit-master.zip"
    local kit="${PERF_WORK_DIR}/tpch-kit"
    if [[ ! -d "${kit}/dbgen" ]]; then
        if [[ -s "${zip}" ]]; then
            log_message "using local tpch-kit: ${zip}"
            cp -- "${zip}" "${PERF_WORK_DIR}/tpch-kit-master.zip" || return 30
        else
            log_message 'downloading tpch-kit'
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
        ch_exec bash -c "cd '${kit}/dbgen' && make -j\"\$(nproc)\"" >/dev/null || {
            log_error 'TPC-H dbgen build failed'; return 30;
        }
    fi
    [[ -x "${kit}/dbgen/dbgen" ]] || { log_error 'TPC-H dbgen binary is missing'; return 30; }
}

build_clickhouse_base() {
    local actual
    initialize_runtime || return $?
    install_host_dependencies || return $?
    require_docker || return $?
    prepare_clickhouse_packages || return $?
    prepare_container_image || return $?
    start_private_container || return $?
    install_container_tools || return $?
    prepare_tpch_kit || return $?

    actual="$(ch_exec "${CH_BIN}" --version 2>&1 | tr -d '\r' \
        | sed -nE 's/.*version ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -n 1)" || return 30
    [[ "${actual}" == "${SOFTWARE_VERSION}" ]] || {
        log_error "unexpected ClickHouse version: ${actual:-unknown}"; return 30;
    }
    printf '%s\n' "${actual}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "official ClickHouse ${actual} is ready in ${CH_CONTAINER_NAME}"
}
