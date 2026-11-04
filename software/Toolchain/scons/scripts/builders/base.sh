#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

package_for_command() {
    case "$1" in
        awk) printf 'gawk\n' ;;
        sha256sum|basename|dirname|nproc) printf 'coreutils\n' ;;
        cc) printf 'gcc\n' ;;
        *) printf '%s\n' "$1" ;;
    esac
}

package_for_command_apt() {
    case "$1" in
        awk) printf 'gawk\n' ;;
        cc) printf 'gcc\n' ;;
        *) printf '%s\n' "$1" ;;
    esac
}

install_missing_commands() {
    local -a missing=() packages=() apt_packages=()
    local cmd rc=0
    for cmd in "$@"; do
        command -v "${cmd}" >/dev/null 2>&1 || missing+=("${cmd}")
    done
    (( ${#missing[@]} == 0 )) && return 0
    log_message "missing commands: ${missing[*]}"
    if command -v dnf >/dev/null 2>&1; then
        for cmd in "${missing[@]}"; do packages+=("$(package_for_command "${cmd}")"); done
        local -a dnf_options=()
        [[ -n "${PERF_PROXY:-}" ]] && dnf_options+=("--setopt=proxy=${PERF_PROXY}")
        local -a runner=()
        if [[ "$(id -u)" -ne 0 ]] && command -v sudo >/dev/null 2>&1; then runner=(sudo -n); fi
        "${runner[@]}" dnf "${dnf_options[@]}" install -y "${packages[@]}" || rc=$?
    elif command -v apt-get >/dev/null 2>&1; then
        for cmd in "${missing[@]}"; do apt_packages+=("$(package_for_command_apt "${cmd}")"); done
        local -a runner=()
        if [[ "$(id -u)" -ne 0 ]] && command -v sudo >/dev/null 2>&1; then runner=(sudo -n); fi
        DEBIAN_FRONTEND=noninteractive "${runner[@]}" apt-get update || rc=$?
        if (( rc == 0 )); then
            DEBIAN_FRONTEND=noninteractive "${runner[@]}" apt-get install -y \
                --no-install-recommends "${apt_packages[@]}" || rc=$?
        fi
    else
        log_message "ERROR: neither dnf nor apt-get is available to install ${missing[*]}"
        return 30
    fi
    if (( rc != 0 )); then
        log_message "ERROR: package installation failed with exit code ${rc}"
        return 30
    fi
    # Post-install self-check: a package manager exit code is not evidence that
    # the command is usable (same lesson as the fbthrift ICU and spdk cases).
    local -a still_missing=()
    for cmd in "${missing[@]}"; do
        command -v "${cmd}" >/dev/null 2>&1 || still_missing+=("${cmd}")
    done
    if (( ${#still_missing[@]} > 0 )); then
        log_message "ERROR: required commands are still missing after installation: ${still_missing[*]}"
        return 30
    fi
    log_message "installed commands: ${missing[*]}"
}

# The host keeps only the download/verification tools; the compiler, Python and
# every SCons invocation live in the private container.
require_host_transfer_commands() {
    local command_name
    for command_name in curl sha256sum awk sed; do
        command -v "${command_name}" >/dev/null 2>&1 || {
            log_message "ERROR: required host command is unavailable: ${command_name}"
            return 30
        }
    done
}

prepare_scons_build_container() {
    require_scons_docker || return 30
    start_scons_container || return $?
    if ! scons_container_exec_root dnf --setopt=install_weak_deps=False install -y \
        gcc gcc-c++ make python3 tar gzip diffutils findutils coreutils \
        sed gawk grep util-linux file binutils glibc-devel \
        >"${PERF_WORK_DIR}/container-packages.log" 2>&1; then
        log_message "ERROR: failed to install the container build packages"
        tail -n 40 -- "${PERF_WORK_DIR}/container-packages.log" | while IFS= read -r line; do log_message "  ${line}"; done
        return 30
    fi
    log_message "container build packages are installed"
}

verify_checksum() {
    local file="$1" expected="$2" actual
    actual="$(sha256sum "${file}" | awk '{print $1}')"
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: sha256 mismatch for ${file}"
        log_message "  expected: ${expected}"
        log_message "  actual:   ${actual}"
        return 30
    fi
    log_message "verified sha256 $(basename "${file}")"
}

materialize_asset() {
    local name="$1" expected="$2" destination="$3"
    shift 3
    local -a urls=("$@")
    local offline_candidate="${SCONS_OFFLINE_DIR}/${name}"
    mkdir -p "$(dirname "${destination}")"
    if [[ -f "${destination}" ]]; then
        verify_checksum "${destination}" "${expected}" && return 0
        log_message "discarding corrupted cached asset: ${destination}"
        rm -f -- "${destination}"
    fi
    if [[ -f "${offline_candidate}" ]]; then
        log_message "using pre-placed offline asset: ${offline_candidate}"
        cp -- "${offline_candidate}" "${destination}" || return 30
        verify_checksum "${destination}" "${expected}"
        return $?
    fi
    local url
    local downloaded=0
    for url in "${urls[@]}"; do
        log_message "downloading ${url}"
        if ! curl -fL --retry 2 --retry-delay 2 --connect-timeout 20 --max-time 1800 \
            -o "${destination}.part" "${url}"; then
            log_message "WARNING: download failed, trying the next source: ${url}"
            rm -f -- "${destination}.part"
            continue
        fi
        if verify_checksum "${destination}.part" "${expected}"; then
            mv -- "${destination}.part" "${destination}"
            downloaded=1
            break
        fi
        log_message "WARNING: checksum mismatch from ${url}, trying the next source"
        rm -f -- "${destination}.part"
    done
    if (( downloaded == 0 )); then
        log_message "ERROR: every download source failed for ${name}"
        log_message "ERROR:   offline candidate: ${offline_candidate}"
        local attempted
        for attempted in "${urls[@]}"; do log_message "ERROR:   attempted: ${attempted}"; done
        return 30
    fi
    log_message "materialized ${name} ($(stat -c %s "${destination}") bytes)"
}

install_scons_source() {
    if [[ -f "${SCONS_ENTRY}" && -d "${SCONS_HOME}/SCons" ]]; then
        log_message "reusing SCons ${SOFTWARE_VERSION} source tree at ${SCONS_HOME}"
        return 0
    fi
    local archive="${PERF_WORK_DIR}/downloads/${SCONS_ARCHIVE_NAME}"
    materialize_asset "${SCONS_ARCHIVE_NAME}" "${SCONS_ARCHIVE_SHA256}" "${archive}" \
        "${SCONS_ARCHIVE_URLS[@]}" || return $?
    rm -rf -- "${SCONS_HOME}"
    mkdir -p "${SCONS_HOME}"
    log_message "extracting ${SCONS_ARCHIVE_NAME} to ${SCONS_HOME}"
    scons_container_exec tar -xzf "${archive}" -C "${SCONS_HOME}" --strip-components=1 || {
        log_message "ERROR: failed to extract the SCons source archive"
        return 30
    }
    if [[ ! -f "${SCONS_ENTRY}" || ! -d "${SCONS_HOME}/SCons" ]]; then
        log_message "ERROR: extracted SCons tree is missing scripts/scons.py or the SCons package"
        return 30
    fi
    if [[ ! -f "${SCONS_HOME}/bench/bench.py" ]]; then
        log_message "ERROR: extracted SCons tree is missing the upstream bench harness"
        return 30
    fi
}

record_actual_version() {
    local version_line scons_version
    version_line="$(scons_container_exec_at "${SCONS_HOME}" python3 scripts/scons.py --version 2>&1)" || {
        log_message "ERROR: failed to execute scripts/scons.py --version"
        return 40
    }
    scons_version="$(printf '%s\n' "${version_line}" | sed -n 's/^[[:space:]]*SCons: v\([0-9][0-9.]*\)\..*/\1/p' | head -n 1)"
    if [[ -z "${scons_version}" ]]; then
        scons_version="$(printf '%s\n' "${version_line}" | sed -n 's/^[[:space:]]*SCons: v\([0-9][0-9.]*\).*/\1/p' | head -n 1)"
    fi
    if [[ -z "${scons_version}" ]]; then
        log_message "ERROR: could not parse the SCons version from --version output"
        printf '%s\n' "${version_line}" | sed -n '1,6p'
        return 40
    fi
    SCONS_VERSION_STRING="$(printf '%s\n' "${version_line}" | sed -n 's/^[[:space:]]*SCons: \(v[^,]*\).*/\1/p' | head -n 1)"
    if [[ "${scons_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: requested SCons ${SOFTWARE_VERSION} but the source tree reports ${scons_version}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${scons_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "recorded actual SCons version: ${scons_version}"
    log_message "launcher reports: ${SCONS_VERSION_STRING:-SCons v${scons_version}}"
}

generate_project() {
    log_message "generating the deterministic ${SCONS_C_FILE_COUNT}-file C project"
    scons_container_exec python3 "${SCRIPT_DIR}/scripts/generate_project.py" \
        --output "${PROJECT_DIR}" --files "${SCONS_C_FILE_COUNT}" || return 40
    local sources
    sources="$(find "${PROJECT_DIR}/src" -name '*.c' | wc -l)"
    if [[ "${sources}" != "${SCONS_C_FILE_COUNT}" ]]; then
        log_message "ERROR: generated ${sources} C sources, expected ${SCONS_C_FILE_COUNT}"
        return 40
    fi
    [[ -f "${PROJECT_DIR}/SConstruct" ]] || {
        log_message "ERROR: generated project has no SConstruct"
        return 40
    }
}

verify_compiler() {
    local compiler
    compiler="$(scons_container_exec sh -c 'command -v cc' 2>/dev/null || true)"
    if [[ -z "${compiler}" ]]; then
        log_message "ERROR: no C compiler (cc) is available in the container"
        return 30
    fi
    log_message "C compiler: $(scons_container_exec sh -c 'cc --version 2>/dev/null | head -n 1')"
}

build_scons_base() {
    initialize_runtime || return $?
    require_host_transfer_commands || return $?
    prepare_scons_build_container || return $?
    verify_compiler || return $?
    install_scons_source || return $?
    record_actual_version || return $?
    generate_project || return $?
    log_message "base build completed: SCons ${SOFTWARE_VERSION} source tree + ${SCONS_C_FILE_COUNT}-file C project"
}
