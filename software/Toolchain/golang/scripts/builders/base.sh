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

install_dependencies() {
    local missing=0 command_name
    for command_name in git curl gcc tar gzip sha256sum awk python3 nproc; do
        command -v "${command_name}" >/dev/null 2>&1 || missing=1
    done
    if [[ "${missing}" -eq 0 ]]; then
        return
    fi

    log_message "installing missing Go runtime and official benchmark dependencies"
    if ! command -v dnf >/dev/null 2>&1; then
        log_message "ERROR: dnf is required to install Go dependencies"
        return 30
    fi
    run_as_root dnf install -y git curl gcc tar gzip coreutils gawk python3 || return 30

    for command_name in git curl gcc tar gzip sha256sum awk python3 nproc; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log_message "ERROR: required command is still missing after installation: ${command_name}"
            return 30
        fi
    done
}

copy_or_download_go_archive() {
    local filename="$1" archive="$2" expected actual
    local offline_archive="${GO_OFFLINE_DIR}/${filename}"

    case "${SOFTWARE_VERSION}:${GO_ARCH}" in
        1.26.9:amd64)
            expected="42d158b4d8f7b61ac0a830567c940a86098fb7aac52e467a5ebec03ef5cc2f8d"
            ;;
        1.26.9:arm64)
            expected="4a97373d49fcacdcf3694fea368a500b00ee3e963974f3e7514132717632f052"
            ;;
        *)
            log_message "ERROR: no verified Go binary release is declared for ${SOFTWARE_VERSION} on ${GO_ARCH}"
            return 10
            ;;
    esac

    if [[ -f "${offline_archive}" ]]; then
        log_message "using offline Go archive ${offline_archive}"
        cp "${offline_archive}" "${archive}"
    else
        log_message "downloading official Go archive ${filename}"
        if ! curl -fsSL --retry 3 --connect-timeout 30 -o "${archive}" \
            "${GO_RELEASE_URL}/${filename}"; then
            log_message "ERROR: failed to download ${filename}"
            return 30
        fi
    fi
    actual="$(sha256sum "${archive}" | awk '{print $1}')"
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: Go archive checksum mismatch: ${filename}"
        return 30
    fi
}

verify_golang_binary() {
    local actual_version actual_arch
    if [[ ! -x "${GO_BIN}" ]]; then
        log_message "ERROR: installed Go binary is missing: ${GO_BIN}"
        return 40
    fi
    actual_version="$("${GO_BIN}" version | awk '{print $3}' | sed 's/^go//')" || return 40
    actual_arch="$("${GO_BIN}" env GOARCH)" || return 40
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" || "${actual_arch}" != "${GO_ARCH}" ]]; then
        log_message "ERROR: installed Go is ${actual_version}/${actual_arch}, expected ${SOFTWARE_VERSION}/${GO_ARCH}"
        return 40
    fi
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
}

build_golang_base() {
    local archive

    initialize_runtime || return $?
    install_dependencies || return $?
    if [[ -e "${GO_INSTALL_DIR}" ]]; then
        log_message "ERROR: installation directories are not clean under ${PERF_WORK_DIR}"
        return 20
    fi
    archive="${PERF_WORK_DIR}/go${SOFTWARE_VERSION}.linux-${GO_ARCH}.tar.gz"
    copy_or_download_go_archive "$(basename "${archive}")" "${archive}" || return $?
    if ! mkdir -p "${GO_INSTALL_DIR}" || \
       ! tar -xzf "${archive}" -C "${GO_INSTALL_DIR}" --strip-components=1; then
        log_message "ERROR: failed to install official Go binary ${SOFTWARE_VERSION}"
        return 30
    fi
    rm -f "${archive}"
    GCC_VERSION_STRING="$(gcc --version | head -n 1)"
    log_message "installed official precompiled Go ${SOFTWARE_VERSION} for ${GO_ARCH}"
    configure_go_environment
    verify_golang_binary || return $?
}
