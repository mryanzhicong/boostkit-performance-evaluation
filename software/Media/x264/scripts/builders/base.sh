#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

require_commands() {
    local required package
    local packages=() dnf_options=()
    for required in curl tar sha256sum python3 make gcc sed tee nproc taskset bc; do
        command -v "${required}" >/dev/null 2>&1 && continue
        case "${required}" in
            sha256sum|tee|nproc) package="coreutils" ;;
            taskset) package="util-linux" ;;
            *) package="${required}" ;;
        esac
        packages+=("${package}")
    done
    if [[ "$(normalize_architecture "${EXPECTED_ARCH}")" == "x86_64" ]] && ! command -v nasm >/dev/null 2>&1; then
        packages+=(nasm)
    fi
    if ((${#packages[@]})); then
        command -v dnf >/dev/null 2>&1 || {
            log_message "ERROR: dnf is required to install x264 build dependencies"
            return 30
        }
        [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
        log_message "installing missing x264 build packages: ${packages[*]}"
        if [[ "$(id -u)" -eq 0 ]]; then
            dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        else
            command -v sudo >/dev/null 2>&1 || return 30
            sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        fi
    fi
    for required in curl tar sha256sum python3 make gcc sed tee nproc taskset bc; do
        command -v "${required}" >/dev/null 2>&1 || {
            log_message "ERROR: required command remains unavailable: ${required}"
            return 30
        }
    done
    if [[ "$(normalize_architecture "${EXPECTED_ARCH}")" == "x86_64" ]] && ! command -v nasm >/dev/null 2>&1; then
        log_message "ERROR: nasm remains unavailable"
        return 30
    fi
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

read_x264_version() {
    local version_line version_text
    if [[ -x "${BENCHMARK_BIN}" ]]; then
        version_line="$("${BENCHMARK_BIN}" --version 2>&1 | head -n 1)"
        version_text="${version_line#x264 }"
        printf '%s\n' "${version_text%% *}"
    else
        printf ''
    fi
}

build_x264_base() {
    local actual_version archive_path archive_name
    initialize_runtime || return $?
    check_architecture || return $?
    require_commands || return $?
    [[ ! -e "${SOURCE_DIR}" && ! -e "${INSTALL_DIR}" ]] || {
        log_message "ERROR: source directory is not clean under ${PERF_WORK_DIR}"
        return 20
    }

    archive_name="x264-${X264_SOURCE_REVISION}.tar.gz"
    archive_path="/home/runner/software/x264/${archive_name}"
    if [[ -s "${archive_path}" ]]; then
        log_message "using local x264 source archive ${archive_path}"
    else
        archive_path="${PERF_WORK_DIR}/${archive_name}"
        log_message "downloading x264 source archive from ${X264_SOURCE_ARCHIVE_URL}"
        curl -fSL --connect-timeout 30 --retry 3 \
            -o "${archive_path}" "${X264_SOURCE_ARCHIVE_URL}" || {
            log_message "ERROR: failed to download x264 source archive"
            return 30
        }
    fi
    if ! printf '%s  %s\n' "${X264_SOURCE_SHA256}" "${archive_path}" | sha256sum -c -; then
        log_message "ERROR: x264 source archive SHA-256 mismatch"
        return 30
    fi
    mkdir -p "${SOURCE_DIR}"
    if ! tar -xzf "${archive_path}" -C "${SOURCE_DIR}" --strip-components=1; then
        log_message "ERROR: failed to extract x264 source archive"
        return 30
    fi

    log_message "building and installing x264 into ${INSTALL_DIR}"
    mkdir -p "${BUILD_DIR}" "${INSTALL_DIR}"
    (
        cd "${BUILD_DIR}"
        ../configure --enable-shared --enable-pic --prefix="${INSTALL_DIR}" || {
            log_message "ERROR: x264 configure failed"
            exit 40
        }
        make -j"$(nproc)" && make install || {
            log_message "ERROR: x264 make or install failed"
            exit 40
        }
    ) || return $?

    [[ -x "${BENCHMARK_BIN}" ]] || {
        log_message "ERROR: official x264 binary was not created"
        return 40
    }

    actual_version="$(read_x264_version)"
    [[ -n "${actual_version}" ]] || {
        log_message "ERROR: cannot read the built x264 version"
        return 40
    }
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: requested x264 ${SOFTWARE_VERSION}, but built ${actual_version}"
        return 40
    }
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40
    log_message "x264 ${actual_version} private installation is ready"
}
