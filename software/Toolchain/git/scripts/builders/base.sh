#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

GIT_BUILD_PACKAGES=(git make gcc perl python3 gawk gettext zlib-devel
    openssl-devel libcurl-devel expat-devel pcre2-devel cargo time
    tar gzip curl findutils diffutils sed coreutils which)

install_build_dependencies() {
    local -a dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message 'installing build packages inside the Git container'
    container_exec_root dnf "${dnf_options[@]}" install -y "${GIT_BUILD_PACKAGES[@]}" || {
        log_message 'ERROR: failed to install build packages inside the Git container'
        return 30
    }
    container_exec command -v cargo >/dev/null 2>&1 || {
        log_message 'ERROR: cargo is required for the default git build (NO_RUST is not used)'
        return 30
    }
}

clone_git() {
    log_message "cloning ${GIT_REPOSITORY} at ${GIT_TAG} (depth ${GIT_CLONE_DEPTH}) inside the container"
    container_exec git clone --quiet --depth "${GIT_CLONE_DEPTH}" \
        --branch "${GIT_TAG}" "${GIT_REPOSITORY}" "${GIT_SRC_DIR}" || return 30
    local actual_commit
    actual_commit="$(container_exec git -C "${GIT_SRC_DIR}" rev-parse HEAD)" || return 30
    [[ "${actual_commit}" == "${GIT_COMMIT}" ]] || {
        log_message "ERROR: cloned git is not at ${GIT_COMMIT}"
        return 30
    }
    local actual_version
    actual_version="$(container_exec git -C "${GIT_SRC_DIR}" describe --tags --exact-match 2>/dev/null | sed 's/^v//')" || return 30
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: cloned git reports ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 30
    }
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
}

build_git_base() {
    local build_jobs
    initialize_runtime || return $?
    require_git_container || return $?
    install_build_dependencies || return $?
    clone_git || return $?
    build_jobs="$(getconf _NPROCESSORS_ONLN)"
    log_message "building git ${SOFTWARE_VERSION} with ${build_jobs} jobs inside the container"
    container_exec make -C "${GIT_SRC_DIR}" -j"${build_jobs}" NO_TCLTK=1 || {
        log_message 'ERROR: git build failed inside the container'
        return 40
    }
    container_exec test -x "${GIT_BIN}" || {
        log_message 'ERROR: git bin-wrappers are missing after the build'
        return 40
    }
    container_exec test -d "${GIT_PERF_DIR}" || {
        log_message 'ERROR: the checkout does not contain t/perf'
        return 40
    }
    container_exec "${GIT_BIN}" --version || return 40
}
