#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

require_hnswlib_tools() {
    local command_name package
    local packages=()

    for command_name in git g++ make curl h5dump python3; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            git) package="git" ;;
            g++) package="gcc-c++" ;;
            make) package="make" ;;
            curl) package="curl" ;;
            h5dump) package="hdf5" ;;
            python3) package="python3" ;;
        esac
        log "missing required hnswlib command: ${command_name}"
        packages+=("${package}")
    done
    [[ -f /usr/include/H5Cpp.h || -f /usr/include/hdf5/serial/H5Cpp.h ]] || packages+=(hdf5-devel)
    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log "ERROR: dnf is required to install hnswlib prerequisites"
        return 30
    fi
    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log "installing missing hnswlib packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log "ERROR: sudo is required to install hnswlib prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log "ERROR: failed to install hnswlib prerequisites"
        return 30
    fi
    for command_name in git g++ make curl h5dump python3; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "ERROR: required hnswlib command remains unavailable: ${command_name}"
            return 30
        fi
    done
    if [[ ! -f /usr/include/H5Cpp.h && ! -f /usr/include/hdf5/serial/H5Cpp.h ]]; then
        log "ERROR: HDF5 C++ development headers remain unavailable"
        return 30
    fi
}


build_hnswlib_base() {
    local source_tag
    local actual_tag
    local config_file

    initialize_runtime || return $?
    require_hnswlib_tools || return $?
    if [[ -e "${SOURCE_DIR}" || -e "${SRA_DIR}" ]]; then
        log "ERROR: build directory is not clean under ${PERF_WORK_DIR}"
        return 20
    fi

    source_tag="${SOFTWARE_VERSION}"
    if [[ "${source_tag}" != v* ]]; then
        source_tag="v${source_tag}"
    fi
    export GIT_TERMINAL_PROMPT=0
    log "cloning hnswlib ${source_tag} from ${HNSWLIB_SOURCE_URL}"
    if ! git clone --branch "${source_tag}" --depth 1 \
        "${HNSWLIB_SOURCE_URL}" "${SOURCE_DIR}"; then
        log "ERROR: failed to clone hnswlib ${source_tag}"
        return 30
    fi
    actual_tag="$(git -C "${SOURCE_DIR}" describe --tags --exact-match HEAD)" || {
        log "ERROR: cloned source is not at an exact version tag"
        return 30
    }
    if [[ "${actual_tag}" != "${source_tag}" ]]; then
        log "ERROR: cloned source tag ${actual_tag}, expected ${source_tag}"
        return 30
    fi
    if [[ ! -f "${SOURCE_DIR}/hnswlib/hnswlib.h" ]]; then
        log "ERROR: hnswlib C++ header is unavailable"
        return 40
    fi

    log "fetching sra_test at ${SRA_REVISION}"
    if ! git init -q "${SRA_DIR}" || \
       ! git -C "${SRA_DIR}" remote add origin "${SRA_SOURCE_URL}" || \
       ! git -C "${SRA_DIR}" fetch --depth 1 --filter=blob:none origin "${SRA_REVISION}" || \
       ! git -C "${SRA_DIR}" sparse-checkout set scripts configs include src || \
       ! git -C "${SRA_DIR}" checkout --detach FETCH_HEAD; then
        log "ERROR: failed to fetch pinned sra_test source"
        return 30
    fi
    if [[ "$(git -C "${SRA_DIR}" rev-parse HEAD)" != "${SRA_REVISION}" ]]; then
        log "ERROR: sra_test revision mismatch"
        return 40
    fi
    mkdir -p "${SRA_DIR}/build"
    config_file="${SRA_DIR}/build/config_hnswlib.sh"
    printf 'export HNSWLIB_INC=%q\nexport EXTRA_DEFINES=""\n' \
        "${SOURCE_DIR}/hnswlib" > "${config_file}"
    log "building original sra_test hnswlib_test"
    if ! (cd "${SRA_DIR}" && printf '\n' | make hnswlib_test); then
        log "ERROR: sra_test hnswlib_test build failed"
        return 40
    fi
    if [[ ! -x "${SRA_DIR}/hnswlib_test" ]]; then
        log "ERROR: built hnswlib_test is unavailable"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    if ! printf '%s\n' "${SOFTWARE_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}"; then
        log "ERROR: failed to record built hnswlib version"
        return 40
    fi
    log "hnswlib ${SOFTWARE_VERSION} sra_test benchmark is ready"
}
