#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

require_sonic_cpp_tools() {
    local required package
    local packages=() dnf_options=()
    for required in git python3 cmake make c++ tee; do
        command -v "${required}" >/dev/null 2>&1 && continue
        case "${required}" in
            tee) package="coreutils" ;;
            c++) package="gcc-c++" ;;
            *) package="${required}" ;;
        esac
        packages+=("${package}")
    done
    if ((${#packages[@]})); then
        command -v dnf >/dev/null 2>&1 || {
            log_message "ERROR: dnf is required to install sonic-cpp build dependencies"
            return 30
        }
        [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
        log_message "installing missing sonic-cpp build packages: ${packages[*]}"
        if [[ "$(id -u)" -eq 0 ]]; then
            dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        else
            command -v sudo >/dev/null 2>&1 || return 30
            sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        fi
    fi
    for required in git python3 cmake make c++ tee; do
        command -v "${required}" >/dev/null 2>&1 || {
            log_message "ERROR: required command remains unavailable: ${required}"
            return 30
        }
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

prepare_sonic_cpp_source() {
    [[ ! -e "${SOURCE_DIR}" ]] || {
        log_message "ERROR: source directory already exists: ${SOURCE_DIR}"
        return 30
    }
    export GIT_TERMINAL_PROMPT=0
    [[ "${SOFTWARE_VERSION}" == "69deb02" ]] || {
        log_message "ERROR: supported sonic-cpp source revision is 69deb02, got ${SOFTWARE_VERSION}"
        return 10
    }
    log_message "cloning sonic-cpp from ${SONIC_CPP_SOURCE_URL}"
    git clone "${SONIC_CPP_SOURCE_URL}" "${SOURCE_DIR}" &&
        git -C "${SOURCE_DIR}" checkout --detach "${SONIC_CPP_REVISION}" || {
        log_message "ERROR: failed to check out sonic-cpp revision ${SOFTWARE_VERSION}"
        return 30
    }
}

report_actual_version() {
    local actual_revision
    actual_revision="$(git -C "${SOURCE_DIR}" rev-parse HEAD)" || return 40
    [[ "${actual_revision}" == "${SONIC_CPP_REVISION}" ]] || {
        log_message "ERROR: cloned source revision '${actual_revision}' does not match ${SONIC_CPP_REVISION}"
        return 40
    }
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${SOFTWARE_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40
    log_message "verified source commit: ${actual_revision}"
}

build_sonic_cpp_base() {
    initialize_runtime || return $?
    check_architecture || return $?
    require_sonic_cpp_tools || return $?
    [[ ! -e "${SOURCE_DIR}" && ! -e "${BUILD_DIR}" ]] || {
        log_message "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    }
    prepare_sonic_cpp_source || return $?
    report_actual_version || return $?
    COMPILER_BINARY="$(command -v c++)"
    COMPILER_VERSION_STRING="$("${COMPILER_BINARY}" --version | head -n 1)"
    log_message "building official CMake benchmark target: bench with ${COMPILER_BINARY}"

    (
        cmake -S "${SOURCE_DIR}" -B "${BUILD_DIR}" -DBUILD_BENCH=ON
        cmake --build "${BUILD_DIR}" --target bench -j
    ) || {
        log_message "ERROR: official CMake build of benchmark target failed"
        return 40
    }
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log_message "ERROR: official benchmark binary was not produced: ${BENCHMARK_BIN}"
        return 40
    }
    log_message "sonic-cpp ${SOFTWARE_VERSION} official benchmark artifact is ready"
}
