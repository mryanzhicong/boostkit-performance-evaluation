#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

require_redis_commands() {
    local required package
    local packages=()

    for required in git python3 gcc make nproc curl docker sed grep cksum sha256sum; do
        if command -v "${required}" >/dev/null 2>&1; then
            continue
        fi
        case "${required}" in
            git) package="git" ;;
            python3) package="python3" ;;
            gcc) package="gcc" ;;
            make) package="make" ;;
            nproc) package="coreutils" ;;
            curl) package="curl" ;;
            docker)
                log_message "ERROR: Docker and an accessible daemon are required for Redis builds"
                return 30
                ;;
            sed) package="sed" ;;
            grep) package="grep" ;;
            cksum|sha256sum) package="coreutils" ;;
        esac
        log_message "missing required Redis command: ${required}"
        packages+=("${package}")
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log_message "ERROR: dnf is required to install Redis build prerequisites"
        return 30
    fi

    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing missing Redis build packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log_message "ERROR: sudo is required to install Redis build prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log_message "ERROR: failed to install Redis build prerequisites"
        return 30
    fi

    for required in git python3 gcc make nproc curl docker sed grep cksum sha256sum; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            log_message "ERROR: required Redis command remains unavailable: ${required}"
            return 30
        fi
    done
}

build_redis_base() {
    local binary actual_version

    initialize_runtime || return $?
    require_redis_commands || return $?
    if [[ -e "${SOURCE_DIR}" ]]; then
        log_message "ERROR: source directory is not clean under ${PERF_WORK_DIR}"
        return 20
    fi

    log_message "cloning Redis ${SOFTWARE_VERSION} from ${REDIS_SOURCE_URL}"
    if ! git clone --branch "${SOFTWARE_VERSION}" --depth 1 \
        "${REDIS_SOURCE_URL}" "${SOURCE_DIR}"; then
        log_message "ERROR: failed to clone Redis ${SOFTWARE_VERSION}"
        return 30
    fi

    log_message "building Redis on the openEuler host"
    if ! (
        cd "${SOURCE_DIR}"
        make -j"$(nproc)" BUILD_TLS=no
    ); then
        log_message "ERROR: Redis host build failed"
        return 40
    fi
    for binary in "${REDIS_SERVER_BIN}" "${REDIS_BENCHMARK_BIN}" "${REDIS_CLI_BIN}"; do
        if [[ ! -x "${binary}" ]]; then
            log_message "ERROR: expected executable not found: ${binary}"
            return 40
        fi
    done

    actual_version="$("${REDIS_SERVER_BIN}" --version | sed -n 's/.*v=\([^ ]*\).*/\1/p' | head -n 1)"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: built Redis version ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    prepare_redis_container_image || return $?
}
