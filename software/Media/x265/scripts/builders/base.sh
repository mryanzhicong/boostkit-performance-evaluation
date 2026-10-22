#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

require_commands() {
    local required package
    local packages=() dnf_options=()
    for required in python3 make cmake gcc g++ sed tee nproc wget tar taskset bc; do
        command -v "${required}" >/dev/null 2>&1 && continue
        case "${required}" in
            g++) package="gcc-c++" ;;
            tee) package="coreutils" ;;
            nproc) package="coreutils" ;;
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
            log_message "ERROR: dnf is required to install x265 build dependencies"
            return 30
        }
        [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
        log_message "installing missing x265 build packages: ${packages[*]}"
        if [[ "$(id -u)" -eq 0 ]]; then
            dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        else
            command -v sudo >/dev/null 2>&1 || return 30
            sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        fi
    fi
    for required in python3 make cmake gcc g++ sed tee nproc wget tar taskset bc; do
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

read_x265_version() {
    local version_output
    if [[ ! -x "${BENCHMARK_BIN}" ]]; then
        printf ''
        return 0
    fi

    if ! version_output="$("${BENCHMARK_BIN}" --version 2>&1)"; then
        printf ''
        return 0
    fi
    sed -n 's/^x265 \[info\]: HEVC encoder version \([^[:space:]]*\).*$/\1/p' <<<"${version_output}"
}

build_x265_base() {
    local actual_version archive_name
    initialize_runtime || return $?
    check_architecture || return $?
    require_commands || return $?
    [[ ! -e "${SOURCE_DIR}" ]] || {
        log_message "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    }

    [[ "${SOFTWARE_VERSION}" == "4.2" ]] || {
        log_message "ERROR: the reference installation only defines x265 4.2"
        return 10
    }
    archive_name="x265_${SOFTWARE_VERSION}.tar.gz"
    log_message "downloading official x265 source archive ${archive_name}"
    (
        cd "${PERF_WORK_DIR}"
        wget "${X265_ARCHIVE_BASE_URL}/${archive_name}" || exit 30
        tar -zxvf "${archive_name}" || exit 30
    ) || return $?
    [[ -d "${SOURCE_DIR}/source" ]] || {
        log_message "ERROR: x265 source directory was not extracted: ${SOURCE_DIR}"
        return 30
    }

    log_message "building and installing x265 into ${INSTALL_DIR}"
    mkdir -p "${BUILD_DIR}" "${INSTALL_DIR}"
    (
        cd "${BUILD_DIR}"
        cmake -S ../source/ -DCMAKE_BUILD_TYPE=Release \
            -DENABLE_PIC=ON \
            -DENABLE_ASSEMBLY=ON \
            -DCMAKE_VERBOSE_MAKEFILE=ON \
            -DCMAKE_C_FLAGS="-O3" \
            -DCMAKE_CXX_FLAGS="-O3" \
            -DHIGH_BIT_DEPTH=off \
            -DENABLE_TESTS=on \
            -DENABLE_SHARED=on \
            -DENABLE_LIBNUMA=off \
            -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" || {
            log_message "ERROR: x265 cmake configure failed"
            exit 40
        }
        make -j"$(nproc)" && make install || {
            log_message "ERROR: x265 make or install failed"
            exit 40
        }
    ) || return $?

    [[ -x "${BENCHMARK_BIN}" ]] || {
        log_message "ERROR: official x265 binary was not created"
        return 40
    }

    actual_version="$(read_x265_version)"
    [[ -n "${actual_version}" ]] || {
        log_message "ERROR: cannot read the built x265 version"
        return 40
    }
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" || \
       "${actual_version}" == "${SOFTWARE_VERSION}"+* ]] || {
        log_message "ERROR: built x265 version does not match ${SOFTWARE_VERSION}: ${actual_version}"
        return 40
    }
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${SOFTWARE_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40
    log_message "x265 ${actual_version} private installation is ready"
}
