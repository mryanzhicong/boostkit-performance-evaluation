#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

require_unixbench_commands() {
    local command_name package
    local packages=()
    require_docker || return $?
    for command_name in curl sha256sum tar python3 awk sed grep; do
        command -v "${command_name}" >/dev/null 2>&1 && continue
        case "${command_name}" in
            curl) package=curl ;; sha256sum) package=coreutils ;;
            tar) package=tar ;; python3) package=python3 ;;
            awk) package=gawk ;; sed) package=sed ;; grep) package=grep ;;
        esac
        packages+=("${package}")
    done
    ((${#packages[@]} == 0)) && return 0
    command -v dnf >/dev/null 2>&1 || { log 'ERROR: dnf is required'; return 30; }
    local options=()
    [[ -z "${PERF_PROXY:-}" ]] || options+=("--setopt=proxy=${PERF_PROXY}")
    log "installing missing build packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${options[@]}" install -y "${packages[@]}" || return 30
    else
        sudo -n dnf "${options[@]}" install -y "${packages[@]}" || return 30
    fi
    for command_name in curl sha256sum tar python3 awk sed grep; do
        command -v "${command_name}" >/dev/null 2>&1 || return 30
    done
}

build_unixbench_base() {
    local archive local_archive actual_version
    local -a dnf_options=()
    initialize_runtime || return $?
    [[ "${SOFTWARE_VERSION}" == 6.0.1 ]] || { log 'ERROR: only UnixBench 6.0.1 is supported'; return 10; }
    [[ "$(normalize_arch "$(uname -m)")" == "$(normalize_arch "${EXPECTED_ARCH}")" ]] || {
        log 'ERROR: runner architecture differs from requested architecture'; return 20;
    }
    require_unixbench_commands || return $?
    [[ ! -e "${UNIXBENCH_SOURCE_DIR}" ]] || { log 'ERROR: source directory already exists'; return 20; }
    require_unixbench_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log 'installing UnixBench build and runtime packages inside the container'
    container_exec_root dnf "${dnf_options[@]}" install -y \
        gcc make perl perl-Time-HiRes tar gzip coreutils findutils procps-ng \
        sed gawk grep util-linux || {
        log 'ERROR: container build dependencies failed'; return 30;
    }
    archive="${PERF_WORK_DIR}/v6.0.1.tar.gz"
    local_archive="${UNIXBENCH_ARCHIVE_DIR}/v6.0.1.tar.gz"
    if [[ -f "${local_archive}" ]]; then
        log "using local archive ${local_archive}"
        cp -- "${local_archive}" "${archive}" || return 30
    else
        log "downloading official archive ${UNIXBENCH_ARCHIVE_URL}"
        with_network_proxy curl -fL --retry 3 --connect-timeout 30 -o "${archive}.part" "${UNIXBENCH_ARCHIVE_URL}" || return 30
        mv -- "${archive}.part" "${archive}" || return 30
    fi
    printf '%s  %s\n' "${UNIXBENCH_ARCHIVE_SHA256}" "${archive}" | sha256sum -c - || {
        log 'ERROR: official archive checksum mismatch'; return 30;
    }
    tar -tzf "${archive}" | python3 "${SCRIPT_DIR}/scripts/results/verify_archive.py" || return 30
    container_exec tar -xzf "${archive}" -C "${PERF_WORK_DIR}" || return 30
    container_exec test -f "${UNIXBENCH_RUN_DIR}/Run" || { log 'ERROR: UnixBench/Run is missing'; return 30; }
    actual_version="$(sed -n 's/^my \$version = "\([^"]*\)";.*/\1/p' "${UNIXBENCH_RUN_DIR}/Run")"
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log "ERROR: requested ${SOFTWARE_VERSION}, source reports ${actual_version}"; return 40;
    }
    log 'building upstream UnixBench inside the private container without source patches'
    container_exec make -C "${UNIXBENCH_RUN_DIR}" -j "$(nproc)" || return 40
    container_exec test -x "${UNIXBENCH_RUN_DIR}/pgms/dhry2reg" || {
        log 'ERROR: UnixBench build is incomplete'; return 40;
    }
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
}
