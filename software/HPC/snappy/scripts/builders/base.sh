#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

require_commands() {
    local required package
    local packages=()

    for required in git python3 cmake make c++ sed tee cmp ldd curl sha256sum grep; do
        if command -v "${required}" >/dev/null 2>&1; then
            continue
        fi
        case "${required}" in
            git) package="git" ;;
            python3) package="python3" ;;
            cmake) package="cmake" ;;
            make) package="make" ;;
            c++) package="gcc-c++" ;;
            sed) package="sed" ;;
            tee) package="coreutils" ;;
            cmp) package="diffutils" ;;
            ldd) package="glibc-common" ;;
            curl) package="curl" ;;
            sha256sum) package="coreutils" ;;
            grep) package="grep" ;;
        esac
        log "missing required Snappy build command: ${required}"
        packages+=("${package}")
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log "ERROR: dnf is required to install Snappy build prerequisites"
        return 30
    fi

    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log "installing missing Snappy build packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log "ERROR: sudo is required to install Snappy build prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log "ERROR: failed to install Snappy build prerequisites"
        return 30
    fi

    for required in git python3 cmake make c++ sed tee cmp ldd curl sha256sum grep; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            log "ERROR: required Snappy build command remains unavailable: ${required}"
            return 30
        fi
    done
}

check_architecture() {
    local actual expected
    actual="$(normalize_arch "$(uname -m)")"
    expected="$(normalize_arch "${EXPECTED_ARCH}")"
    [[ "${actual}" == "${expected}" ]] || {
        log "ERROR: expected architecture ${expected}, runner is ${actual}"
        return 20
    }
}

read_source_version() {
    sed -n \
        's/^project(Snappy VERSION \([^ )][^ )]*\).*$/\1/p' \
        "${SOURCE_DIR}/CMakeLists.txt" | head -n 1
}

build_snappy_base() {
    local actual_version
    initialize_runtime || return $?
    [[ "${SOFTWARE_VERSION}" == "1.2.2" ]] || {
        log "ERROR: this lzbench case supports only Snappy 1.2.2"
        return 10
    }
    check_architecture || return $?
    require_commands || return $?
    [[ ! -e "${SOURCE_DIR}" && ! -e "${LZBENCH_DIR}" ]] || {
        log "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    }

    export GIT_TERMINAL_PROMPT=0
    log "cloning Snappy ${SOFTWARE_VERSION} from ${SNAPPY_SOURCE_URL}"
    git clone --branch "${SOFTWARE_VERSION}" --depth 1 \
        "${SNAPPY_SOURCE_URL}" "${SOURCE_DIR}" || {
        log "ERROR: failed to clone Snappy ${SOFTWARE_VERSION}"
        return 30
    }
    log "building Google Snappy ${SOFTWARE_VERSION} as a private shared library"
    (
        cd "${SOURCE_DIR}"
        mkdir build
        cd build
        cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON \
            -DSNAPPY_BUILD_TESTS=OFF -DSNAPPY_BUILD_BENCHMARKS=OFF ../
        make
    ) || {
        log "ERROR: failed to build the private Snappy shared library"
        return 40
    }
    [[ -f "${BUILD_DIR}/libsnappy.so" ]] || {
        log "ERROR: Snappy shared library was not created"
        return 40
    }

    actual_version="$(read_source_version)"
    [[ -n "${actual_version}" ]] || {
        log "ERROR: cannot read the built Snappy version"
        return 40
    }
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log "ERROR: built Snappy ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 40
    }
    log "cloning lzbench ${LZBENCH_VERSION} from ${LZBENCH_SOURCE_URL}"
    git clone --branch "${LZBENCH_VERSION}" --depth 1 \
        "${LZBENCH_SOURCE_URL}" "${LZBENCH_DIR}" || {
        log "ERROR: failed to clone lzbench ${LZBENCH_VERSION}"
        return 30
    }
    cmp "${SOURCE_DIR}/snappy.h" "${LZBENCH_DIR}/lz/snappy/snappy.h" || {
        log "ERROR: lzbench's Snappy header differs from Google Snappy ${SOFTWARE_VERSION}"
        return 40
    }
    log "building lzbench against this run's Snappy shared library"
    make -C "${LZBENCH_DIR}" -j4 BUILD_STATIC=0 DONT_BUILD_DENSITY=1 \
        SNAPPY_FILES= \
        USER_LDFLAGS="-L${BUILD_DIR} -Wl,-rpath,${BUILD_DIR} -lsnappy" || {
        log "ERROR: failed to build lzbench against Snappy ${SOFTWARE_VERSION}"
        return 40
    }
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log "ERROR: lzbench executable was not created"
        return 40
    }
    ldd "${BENCHMARK_BIN}" | grep -Fq "=> ${BUILD_DIR}/libsnappy.so.1 " || {
        log "ERROR: lzbench is not linked to this run's Snappy shared library"
        return 40
    }
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40
}
