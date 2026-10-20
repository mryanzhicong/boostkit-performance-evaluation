#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

require_commands() {
    local required package
    local packages=()

    for required in git python3 make cc c++ sed tee grep ldd curl sha256sum; do
        if command -v "${required}" >/dev/null 2>&1; then
            continue
        fi
        case "${required}" in
            git) package="git" ;;
            python3) package="python3" ;;
            make) package="make" ;;
            cc) package="gcc" ;;
            c++) package="gcc-c++" ;;
            sed) package="sed" ;;
            tee) package="coreutils" ;;
            grep) package="grep" ;;
            ldd) package="glibc-common" ;;
            curl) package="curl" ;;
            sha256sum) package="coreutils" ;;
        esac
        log "missing required LZ4 command: ${required}"
        packages+=("${package}")
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log "ERROR: dnf is required to install LZ4 build prerequisites"
        return 30
    fi

    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log "installing missing LZ4 build packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log "ERROR: sudo is required to install LZ4 build prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log "ERROR: failed to install LZ4 build prerequisites"
        return 30
    fi

    for required in git python3 make cc c++ sed tee grep ldd curl sha256sum; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            log "ERROR: required LZ4 command remains unavailable: ${required}"
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

read_header_version() {
    local header="$1" major minor release
    major="$(sed -n 's/^#define LZ4_VERSION_MAJOR[[:space:]]\+\([0-9][0-9]*\).*/\1/p' "${header}")"
    minor="$(sed -n 's/^#define LZ4_VERSION_MINOR[[:space:]]\+\([0-9][0-9]*\).*/\1/p' "${header}")"
    release="$(
        sed -n 's/^#define LZ4_VERSION_RELEASE[[:space:]]\+\([0-9][0-9]*\).*/\1/p' "${header}"
    )"
    [[ -n "${major}" && -n "${minor}" && -n "${release}" ]] || return 1
    printf '%s.%s.%s\n' "${major}" "${minor}" "${release}"
}

build_lz4_base() {
    local tag actual_version
    initialize_runtime || return $?
    [[ "${SOFTWARE_VERSION}" == "1.9.4" ]] || {
        log "ERROR: this lzbench case supports only LZ4 1.9.4"
        return 10
    }
    check_architecture || return $?
    require_commands || return $?
    [[ ! -e "${SOURCE_DIR}" && ! -e "${LZBENCH_DIR}" ]] || {
        log "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    }

    export GIT_TERMINAL_PROMPT=0
    tag="${SOFTWARE_VERSION}"
    [[ "${tag}" == v* ]] || tag="v${tag}"
    log "cloning LZ4 ${tag} from ${LZ4_SOURCE_URL}"
    git clone --branch "${tag}" --depth 1 "${LZ4_SOURCE_URL}" "${SOURCE_DIR}" || {
        log "ERROR: failed to clone LZ4 ${tag}"
        return 30
    }
    log "building the official LZ4 ${SOFTWARE_VERSION} shared library"
    make -C "${SOURCE_DIR}/lib" -j4 || {
        log "ERROR: failed to build the LZ4 shared library"
        return 40
    }
    [[ -f "${SOURCE_DIR}/lib/liblz4.so.1.9.4" ]] || {
        log "ERROR: LZ4 1.9.4 shared library was not created"
        return 40
    }

    actual_version="$(read_header_version "${SOURCE_DIR}/lib/lz4.h")" || {
        log "ERROR: cannot read the built LZ4 version"
        return 40
    }
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log "ERROR: source LZ4 version ${actual_version} differs from ${SOFTWARE_VERSION}"
        return 40
    }
    log "cloning lzbench ${LZBENCH_VERSION} from ${LZBENCH_SOURCE_URL}"
    git clone --branch "${LZBENCH_VERSION}" --depth 1 \
        "${LZBENCH_SOURCE_URL}" "${LZBENCH_DIR}" || {
        log "ERROR: failed to clone lzbench ${LZBENCH_VERSION}"
        return 30
    }
    local registry="${LZBENCH_DIR}/bench/lzbench.h"
    grep -Fq '"lz4 1.10.0"' "${registry}" || {
        log "ERROR: expected lzbench LZ4 display label was not found"
        return 40
    }
    sed -i '/{ "lz4",/s/"lz4 1.10.0"/"lz4 1.9.4"/' "${registry}"
    grep -Fq '"lz4 1.9.4"' "${registry}" || {
        log "ERROR: failed to label the linked LZ4 1.9.4 library"
        return 40
    }
    log "building lzbench against this run's LZ4 1.9.4 shared library"
    make -C "${LZBENCH_DIR}" -j4 BUILD_STATIC=0 DONT_BUILD_DENSITY=1 \
        LZ4_FILES= \
        USER_LDFLAGS="-L${SOURCE_DIR}/lib -Wl,-rpath,${SOURCE_DIR}/lib -llz4" || {
        log "ERROR: failed to build lzbench against LZ4 1.9.4"
        return 40
    }
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log "ERROR: lzbench executable was not created"
        return 40
    }
    ldd "${BENCHMARK_BIN}" | grep -Fq "=> ${SOURCE_DIR}/lib/liblz4.so.1 " || {
        log "ERROR: lzbench is not linked to this run's LZ4 shared library"
        return 40
    }
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40
}
