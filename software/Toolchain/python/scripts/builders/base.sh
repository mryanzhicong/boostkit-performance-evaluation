#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

require_python_tools() {
    local command_name package
    local packages=()

    for command_name in git gcc make python3 nproc sudo; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            git) package="git" ;;
            gcc) package="gcc" ;;
            make) package="make" ;;
            python3) package="python3" ;;
            nproc) package="coreutils" ;;
            sudo) package="sudo" ;;
        esac
        log_message "missing required Python test command: ${command_name}"
        packages+=("${package}")
    done

    for package in bzip2-devel gdbm-devel libffi-devel openssl-devel readline-devel sqlite-devel uuid-devel xz-devel zlib-devel; do
        if ! rpm -q "${package}" >/dev/null 2>&1; then
            log_message "missing required Python test package: ${package}"
            packages+=("${package}")
        fi
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log_message "ERROR: dnf is required to install Python test prerequisites"
        return 30
    fi

    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing missing Python test packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log_message "ERROR: sudo is required to install Python test prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log_message "ERROR: failed to install Python test prerequisites"
        return 30
    fi

    for command_name in git gcc make python3 nproc sudo; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log_message "ERROR: required Python test command remains unavailable: ${command_name}"
            return 30
        fi
    done
    for package in bzip2-devel gdbm-devel libffi-devel openssl-devel readline-devel sqlite-devel uuid-devel xz-devel zlib-devel; do
        if ! rpm -q "${package}" >/dev/null 2>&1; then
            log_message "ERROR: required Python test package remains unavailable: ${package}"
            return 30
        fi
    done
}

check_architecture() {
    local actual expected
    actual="$(normalize_architecture "$(uname -m)")"
    expected="$(normalize_architecture "${EXPECTED_ARCH}")"
    [[ "${actual}" == "${expected}" ]] || {
        log_message "ERROR: expected architecture ${expected}, runner is ${actual}"
        return 20
    }
}

prepare_cpython_source() {
    [[ ! -e "${SOURCE_DIR}" ]] || {
        log_message "ERROR: source directory already exists: ${SOURCE_DIR}"
        return 30
    }
    export GIT_TERMINAL_PROMPT=0
    log_message "cloning CPython v${SOFTWARE_VERSION} from ${CPYTHON_SOURCE_URL}"
    git clone --branch "v${SOFTWARE_VERSION}" --depth 1 \
        "${CPYTHON_SOURCE_URL}" "${SOURCE_DIR}" || {
        log_message "ERROR: failed to clone CPython v${SOFTWARE_VERSION}"
        return 30
    }
}

verify_cpython_build() {
    local version_output actual_version
    [[ -x "${PYTHON_BIN}" ]] || {
        log_message "ERROR: CPython interpreter was not installed: ${PYTHON_BIN}"
        return 40
    }
    version_output="$("${PYTHON_BIN}" --version 2>&1)" || {
        log_message "ERROR: built CPython cannot report its version"
        return 40
    }
    actual_version="${version_output#Python }"
    actual_version="${actual_version%%[[:space:]]*}"
    [[ -n "${actual_version}" && "${actual_version}" != "${version_output}" ]] || {
        log_message "ERROR: unexpected CPython version output: ${version_output}"
        return 40
    }
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: built CPython reports ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 40
    }
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40

    "${PYTHON_BIN}" -c "import ssl, zlib, ctypes" || {
        log_message "ERROR: built CPython is missing ssl/zlib/ctypes modules"
        log_message "the Runner is missing zlib-devel or libffi-devel"
        return 40
    }
    "${PYTHON_BIN}" -m pip --version >/dev/null 2>&1 || {
        log_message "ERROR: built CPython has no usable pip"
        return 40
    }
}

build_python_base() {
    local -a configure_options

    initialize_runtime || return $?
    check_architecture || return $?
    require_python_tools || return $?
    [[ ! -e "${SOURCE_DIR}" && ! -e "${INSTALL_DIR}" && ! -e "${BENCH_WORK_DIR}" ]] || {
        log_message "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    }
    prepare_cpython_source || return $?
    GCC_VERSION_STRING="$(gcc --version | head -n 1)"
    read -r -a configure_options <<< "${CONFIGURE_OPTIONS}"
    [[ "${#configure_options[@]}" -gt 0 ]] || {
        log_message "ERROR: CPython configure options are empty"
        return 40
    }

    log_message "configuring CPython v${SOFTWARE_VERSION} with ${CONFIGURE_OPTIONS} into a private prefix"
    (
        cd "${SOURCE_DIR}"
        ./configure --prefix="${INSTALL_DIR}" "${configure_options[@]}"
    ) || {
        log_message "ERROR: CPython configure failed"
        return 40
    }
    log_message "building CPython v${SOFTWARE_VERSION} with make -j$(nproc)"
    (
        cd "${SOURCE_DIR}"
        make -j"$(nproc)"
    ) || {
        log_message "ERROR: CPython make failed"
        return 40
    }
    (
        cd "${SOURCE_DIR}"
        make install
    ) || {
        log_message "ERROR: CPython make install failed"
        return 40
    }
    verify_cpython_build || return $?
    log_message "CPython ${SOFTWARE_VERSION} interpreter is ready at ${PYTHON_BIN}"
}
