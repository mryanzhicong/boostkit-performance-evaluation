#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_as_root() {
    if [[ "$1" == dnf && -n "${PERF_PROXY:-}" ]]; then
        set -- "$1" "--setopt=proxy=${PERF_PROXY}" "${@:2}"
    fi
    if [[ "${EUID}" -eq 0 ]]; then
        "$@"
        return
    fi
    if ! command -v sudo >/dev/null 2>&1; then
        log_message "ERROR: root privileges are required to install missing dependencies"
        return 30
    fi
    sudo -n "$@"
}

require_envoy_tools() {
    local command_name package
    local packages=()

    for command_name in curl sha256sum tar gzip install python3 openssl awk sed tee pgrep; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            curl) package="curl" ;;
            sha256sum|install|tee) package="coreutils" ;;
            tar) package="tar" ;;
            gzip) package="gzip" ;;
            python3) package="python3" ;;
            openssl) package="openssl" ;;
            awk) package="gawk" ;;
            sed) package="sed" ;;
            pgrep) package="procps-ng" ;;
        esac
        log_message "missing required Envoy command: ${command_name}"
        packages+=("${package}")
    done
    if [[ "${#packages[@]}" -gt 0 ]]; then
        if ! command -v dnf >/dev/null 2>&1; then
            log_message "ERROR: dnf is required to install Envoy dependencies"
            return 30
        fi
        run_as_root dnf install -y "${packages[@]}" || return 30
    fi

    for command_name in curl sha256sum tar gzip install python3 openssl awk sed tee pgrep; do
        command -v "${command_name}" >/dev/null 2>&1 || {
            log_message "ERROR: required Envoy command remains unavailable: ${command_name}"
            return 30
        }
    done
}

copy_or_download_verified_file() {
    local url="$1" asset_name="$2" output="$3" expected_sha256="$4"
    local actual_sha256 download_url local_file

    local_file="${ENVOY_OFFLINE_DIR}/${asset_name}"
    if [[ -f "${local_file}" ]]; then
        log_message "using local release asset ${local_file}"
        install -m 0644 "${local_file}" "${output}" || return 30
    else
        download_url="${url}"
        if [[ -n "${PERF_GITHUB_DOWNLOAD_PROXY}" ]]; then
            download_url="${PERF_GITHUB_DOWNLOAD_PROXY%/}/${url}"
        fi
        log_message "downloading ${url}"
        curl -fsSL --retry 3 --connect-timeout 30 -o "${output}" "${download_url}" || {
            log_message "ERROR: download failed: ${url}"
            return 30
        }
    fi
    actual_sha256="$(sha256sum "${output}" | awk '{print $1}')"
    [[ "${actual_sha256}" == "${expected_sha256}" ]] || {
        log_message "ERROR: checksum mismatch for $(basename "${output}")"
        return 30
    }
}

install_release_artifacts() {
    local envoy_asset envoy_sha256 envoy_url k6_archive k6_dir k6_sha256 k6_url

    case "${EXPECTED_ARCH}" in
        x86_64)
            envoy_asset="envoy-${SOFTWARE_VERSION}-linux-x86_64"
            envoy_sha256="9b68557ccb2ef587c0374bfca75b01966ca3c6b59d96663fd7557b496e0c7ad1"
            k6_sha256="b5a8003c86f35f5cd5ceef1490312c48e587696c94d998cefc6d7b3b4cb1597d"
            ;;
        aarch64)
            envoy_asset="envoy-${SOFTWARE_VERSION}-linux-aarch_64"
            envoy_sha256="e90eff416e94eaa8b5812196d17918635e8dc0b0e12d11ef7e0fee2c0a6bdca7"
            k6_sha256="4ecd64cadcc792402d16293836115480419c4447c032858f564852d98f1bf54c"
            ;;
    esac

    mkdir -p "${INSTALL_DIR}" "${PERF_WORK_DIR}/tools" || return 30
    envoy_url="https://github.com/envoyproxy/envoy/releases/download/v${SOFTWARE_VERSION}/${envoy_asset}"
    copy_or_download_verified_file \
        "${envoy_url}" "${envoy_asset}" "${ENVOY_BIN}" "${envoy_sha256}" || return $?
    chmod 0755 "${ENVOY_BIN}" || return 30

    k6_archive="${PERF_WORK_DIR}/tools/k6-v${K6_VERSION}-linux-${K6_ARCH}.tar.gz"
    k6_url="https://github.com/grafana/k6/releases/download/v${K6_VERSION}/k6-v${K6_VERSION}-linux-${K6_ARCH}.tar.gz"
    copy_or_download_verified_file \
        "${k6_url}" "$(basename "${k6_archive}")" "${k6_archive}" "${k6_sha256}" || return $?
    k6_dir="${PERF_WORK_DIR}/tools/k6-v${K6_VERSION}-linux-${K6_ARCH}"
    tar -xzf "${k6_archive}" -C "${PERF_WORK_DIR}/tools" || return 30
    install -m 0755 "${k6_dir}/k6" "${K6_BIN}" || return 30
    "${K6_BIN}" version >/dev/null || return 30
}

build_envoy_base() {
    initialize_runtime || return $?
    require_envoy_tools || return $?
    [[ ! -e "${INSTALL_DIR}" ]] || {
        log_message "ERROR: Envoy work paths are not clean under ${PERF_WORK_DIR}"
        return 20
    }
    install_release_artifacts || return $?
    "${ENVOY_BIN}" --version | grep -Fq "${SOFTWARE_VERSION}" || {
        log_message "ERROR: official Envoy release version does not contain ${SOFTWARE_VERSION}"
        return 40
    }
    printf '%s\n' "${SOFTWARE_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40
    log_message "installed official Envoy ${SOFTWARE_VERSION} release into ${INSTALL_DIR}"
}
