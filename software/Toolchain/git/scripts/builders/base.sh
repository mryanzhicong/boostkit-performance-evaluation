#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

install_build_dependencies() {
    local -a packages=(git make gcc perl python3 gawk gettext zlib-devel
        openssl-devel libcurl-devel expat-devel cargo time tar gzip)
    local -a missing=()
    local -a dnf_options=()
    local package
    for package in "${packages[@]}"; do
        rpm -q "${package}" >/dev/null 2>&1 || missing+=("${package}")
    done
    (( ${#missing[@]} > 0 )) || return 0
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing missing build packages: ${missing[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${missing[@]}" || return 30
    elif command -v sudo >/dev/null 2>&1; then
        sudo -n dnf "${dnf_options[@]}" install -y "${missing[@]}" || return 30
    else
        log_message 'ERROR: dnf requires root or passwordless sudo'
        return 30
    fi
}

clone_git() {
    log_message "cloning ${GIT_REPOSITORY} at ${GIT_TAG} (depth ${GIT_CLONE_DEPTH})"
    with_network_proxy git clone --quiet --depth "${GIT_CLONE_DEPTH}" \
        --branch "${GIT_TAG}" "${GIT_REPOSITORY}" "${GIT_SRC_DIR}" || return 30
    [[ "$(git -C "${GIT_SRC_DIR}" rev-parse HEAD)" == "${GIT_COMMIT}" ]] || {
        log_message "ERROR: cloned git is not at ${GIT_COMMIT}"
        return 30
    }
    local actual_version
    actual_version="$(git -C "${GIT_SRC_DIR}" describe --tags --exact-match 2>/dev/null | sed 's/^v//')"
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: cloned git reports ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 30
    }
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
}

build_git_base() {
    local build_jobs
    initialize_runtime || return $?
    install_build_dependencies || return $?
    command -v cargo >/dev/null 2>&1 || {
        log_message 'ERROR: cargo is required for the default git build (NO_RUST is not used)'
        return 30
    }
    clone_git || return $?
    build_jobs="$(getconf _NPROCESSORS_ONLN)"
    log_message "building git ${SOFTWARE_VERSION} with ${build_jobs} jobs"
    (cd "${GIT_SRC_DIR}" && \
        with_network_proxy env TMPDIR="${TMPDIR}" \
            make -j"${build_jobs}" NO_TCLTK=1) || {
        log_message 'ERROR: git build failed'
        return 40
    }
    [[ -x "${GIT_BIN}" ]] || {
        log_message 'ERROR: git bin-wrappers are missing after the build'
        return 40
    }
    [[ -d "${GIT_PERF_DIR}" ]] || {
        log_message 'ERROR: the checkout does not contain t/perf'
        return 40
    }
    "${GIT_BIN}" --version
}
