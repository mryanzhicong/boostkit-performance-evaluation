#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else
        "$@"
    fi
}

require_build_commands() {
    local required package
    local packages=()
    for required in git cmake make g++ python3 nproc rpm; do
        command -v "${required}" >/dev/null 2>&1 && continue
        case "${required}" in
            g++) package="gcc-c++" ;;
            nproc) package="coreutils" ;;
            *) package="${required}" ;;
        esac
        packages+=("${package}")
    done
    if ((${#packages[@]})); then
        local dnf_options=()
        [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
        command -v dnf >/dev/null 2>&1 || return 30
        if [[ "$(id -u)" -eq 0 ]]; then
            dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        else
            sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        fi
    fi
    for required in git cmake make g++ python3 nproc rpm; do
        command -v "${required}" >/dev/null 2>&1 || return 30
    done
}

prepare_folly_source() {
    local tag_commit head_commit
    [[ ! -e "${SOURCE_DIR}" ]] || { log_message "ERROR: existing source directory: ${SOURCE_DIR}"; return 40; }
    log_message "cloning upstream Folly v${SOFTWARE_VERSION}"
    with_network_proxy git clone --branch "v${SOFTWARE_VERSION}" --depth 1 \
        "${FOLLY_SOURCE_URL}" "${SOURCE_DIR}" || return 40
    tag_commit="$(git -C "${SOURCE_DIR}" rev-parse "refs/tags/v${SOFTWARE_VERSION}^{commit}")" || return 40
    head_commit="$(git -C "${SOURCE_DIR}" rev-parse HEAD)" || return 40
    if [[ "${tag_commit}" != "${head_commit}" ]]; then
        log_message "ERROR: Folly v${SOFTWARE_VERSION} tag does not match the checked-out commit"
        return 40
    fi
    printf '%s\n' "${SOFTWARE_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}"
}

prepare_fast_float() {
    if printf '#include <fast_float/fast_float.h>\nint main(){return 0;}\n' \
        | g++ -x c++ -fsyntax-only - 2>/dev/null; then
        return 0
    fi
    log_message "fetching required upstream fast_float ${FAST_FLOAT_VERSION}"
    with_network_proxy git clone --branch "${FAST_FLOAT_VERSION}" --depth 1 \
        "${FAST_FLOAT_SOURCE_URL}" "${FAST_FLOAT_DIR}" || return 40
    [[ -f "${FAST_FLOAT_DIR}/include/fast_float/fast_float.h" ]] || return 40
}

build_folly_base() {
    initialize_runtime || return $?
    require_build_commands || return $?
    [[ -d "${ACCLIB_SOURCE_ROOT}/fbthrift_folly_benchmark" && \
       -f "${ACCLIB_SOURCE_ROOT}/fb_folly_autobuild/run.py" ]] || {
        log_message "ERROR: provide AccLibBenchmark at ${ACCLIB_SOURCE_ROOT} on this runner"
        return 30
    }
    COMPILER_VERSION_STRING="$(g++ --version | head -1)"
    prepare_folly_source || return $?
    prepare_fast_float || return $?
    bash "${SCRIPT_DIR}/scripts/build_acclib_stack.sh" "${PERF_WORK_DIR}" \
        "${SOURCE_DIR}" "${FAST_FLOAT_DIR}" "${SOFTWARE_VERSION}" \
        "${ACCLIB_SOURCE_ROOT}" || {
        log_message 'ERROR: upstream Folly stack or AccLibBenchmark build failed'
        return 40
    }
}
