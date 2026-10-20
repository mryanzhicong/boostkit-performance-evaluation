#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

require_commands() {
    local command package
    local packages=() dnf_options=()
    for command in git python3 make cc c++ sed tee diff curl sha256sum; do
        command -v "${command}" >/dev/null 2>&1 && continue
        case "${command}" in
            cc) package="gcc" ;;
            c++) package="gcc-c++" ;;
            tee) package="coreutils" ;;
            diff) package="diffutils" ;;
            sha256sum) package="coreutils" ;;
            *) package="${command}" ;;
        esac
        packages+=("${package}")
    done
    if ((${#packages[@]})); then
        command -v dnf >/dev/null 2>&1 || {
            log "ERROR: dnf is required to install Zstd build dependencies"
            return 30
        }
        [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
        log "installing missing Zstd build packages: ${packages[*]}"
        if [[ "$(id -u)" -eq 0 ]]; then
            dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        else
            command -v sudo >/dev/null 2>&1 || return 30
            sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        fi
    fi
    for command in git python3 make cc c++ sed tee diff curl sha256sum; do
        command -v "${command}" >/dev/null 2>&1 || {
            log "ERROR: required command remains unavailable: ${command}"
            return 30
        }
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
    major="$(sed -n 's/^#define ZSTD_VERSION_MAJOR[[:space:]]\+\([0-9][0-9]*\).*/\1/p' "${header}")"
    minor="$(sed -n 's/^#define ZSTD_VERSION_MINOR[[:space:]]\+\([0-9][0-9]*\).*/\1/p' "${header}")"
    release="$(
        sed -n 's/^#define ZSTD_VERSION_RELEASE[[:space:]]\+\([0-9][0-9]*\).*/\1/p' "${header}"
    )"
    [[ -n "${major}" && -n "${minor}" && -n "${release}" ]] || return 1
    printf '%s.%s.%s\n' "${major}" "${minor}" "${release}"
}

build_zstd_base() {
    local tag actual_version
    initialize_runtime || return $?
    [[ "${SOFTWARE_VERSION}" == "1.5.7" ]] || {
        log "ERROR: this lzbench case supports only Zstd 1.5.7"
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
    log "cloning Zstd ${tag} from ${ZSTD_SOURCE_URL}"
    git clone --branch "${tag}" --depth 1 "${ZSTD_SOURCE_URL}" "${SOURCE_DIR}" || {
        log "ERROR: failed to clone Zstd ${tag}"
        return 30
    }

    actual_version="$(read_header_version "${SOURCE_DIR}/lib/zstd.h")"
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log "ERROR: source Zstd version ${actual_version} differs from ${SOFTWARE_VERSION}"
        return 40
    }
    log "cloning lzbench ${LZBENCH_VERSION} from ${LZBENCH_SOURCE_URL}"
    git clone --branch "${LZBENCH_VERSION}" --depth 1 \
        "${LZBENCH_SOURCE_URL}" "${LZBENCH_DIR}" || {
        log "ERROR: failed to clone lzbench ${LZBENCH_VERSION}"
        return 30
    }
    diff -qr "${SOURCE_DIR}/lib" "${LZBENCH_DIR}/lz/zstd/lib" || {
        log "ERROR: lzbench's Zstd sources differ from official ${SOFTWARE_VERSION}"
        return 40
    }
    log "building lzbench with the verified official Zstd ${SOFTWARE_VERSION} sources"
    make -C "${LZBENCH_DIR}" -j4 BUILD_STATIC=0 DONT_BUILD_DENSITY=1 || {
        log "ERROR: failed to build lzbench"
        return 40
    }
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log "ERROR: lzbench executable was not created"
        return 40
    }
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40
}
