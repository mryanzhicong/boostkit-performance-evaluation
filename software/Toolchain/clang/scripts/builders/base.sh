#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

CLANG_BUILD_PACKAGES=(tar xz unzip sed findutils gawk coreutils curl python3
    which diffutils bash)

install_build_dependencies() {
    local -a dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message 'installing build packages inside the Clang container'
    container_exec_root dnf "${dnf_options[@]}" install -y "${CLANG_BUILD_PACKAGES[@]}" || {
        log_message 'ERROR: failed to install build packages inside the Clang container'
        return 30
    }
    local command_name
    for command_name in tar xz unzip sed find awk stat python3; do
        container_exec command -v "${command_name}" >/dev/null 2>&1 || {
            log_message "ERROR: required command is missing in the Clang container: ${command_name}"
            return 30
        }
    done
}

# The archive is staged under PERF_WORK_DIR, which is bind-mounted into the
# container; an offline archive is copied there first.
fetch_llvm_archive() {
    local archive_path local_archive
    local_archive="${CLANG_ARCHIVE_DIR}/${LLVM_ARCHIVE_NAME}"
    archive_path="${PERF_WORK_DIR}/${LLVM_ARCHIVE_NAME}"
    if [[ -s "${local_archive}" ]]; then
        log_message "using local LLVM archive: ${local_archive}"
        cp "${local_archive}" "${archive_path}" || return 30
    elif [[ -s "${archive_path}" ]]; then
        log_message "using cached LLVM archive: ${archive_path}"
    else
        log_message "downloading ${LLVM_ARCHIVE_NAME}"
        with_network_proxy curl -fL --retry 3 --connect-timeout 30 \
            -o "${archive_path}" "${LLVM_ARCHIVE_URL}" || return 30
    fi
    verify_sha256 "${archive_path}" "${LLVM_ARCHIVE_SHA256}" || return $?
    printf '%s\n' "${archive_path}"
}

extract_llvm_archive() {
    local archive="$1" staging_dir clang_file toolchain_dir
    staging_dir="${PERF_WORK_DIR}/llvm-unpack"
    container_exec rm -rf "${LLVM_ROOT}" "${staging_dir}"
    container_exec mkdir -p "${staging_dir}"
    log_message "extracting ${archive} inside the container"
    container_exec tar -xJf "${archive}" -C "${staging_dir}" || {
        log_message "ERROR: failed to extract ${archive}"
        return 40
    }
    # The release tarball either unpacks into one versioned directory or
    # spreads bin/ and lib/ directly over the staging directory. The work
    # directory is bind-mounted, so the host sees the same paths.
    clang_file="$(find "${staging_dir}" -maxdepth 3 -path '*/bin/clang' \( -type f -o -type l \) -print -quit)"
    [[ -n "${clang_file}" ]] || {
        log_message 'ERROR: cannot locate bin/clang inside the LLVM archive'
        return 40
    }
    toolchain_dir="$(dirname "$(dirname "${clang_file}")")"
    if [[ "${toolchain_dir}" == "${staging_dir}" ]]; then
        mv "${staging_dir}" "${LLVM_ROOT}"
    else
        mv "${toolchain_dir}" "${LLVM_ROOT}"
        rm -rf "${staging_dir}"
    fi
}

build_clang_base() {
    local archive_path actual_version
    initialize_runtime || return $?
    require_clang_container || return $?
    install_build_dependencies || return $?
    archive_path="$(fetch_llvm_archive)" || return $?
    extract_llvm_archive "${archive_path}" || return $?
    container_exec test -x "${CLANG_BIN}" || {
        log_message 'ERROR: clang/clang++ binaries not found after extraction'
        return 40
    }
    container_exec test -x "${CLANGXX_BIN}" || {
        log_message 'ERROR: clang/clang++ binaries not found after extraction'
        return 40
    }
    if container_exec ldd "${CLANG_BIN}" 2>&1 | grep -q 'not found'; then
        log_message 'ERROR: clang runtime dependencies are missing in the container'
        return 40
    fi
    actual_version="$(container_exec "${CLANG_BIN}" --version 2>/dev/null | \
        sed -nE 's/^clang version ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -n 1)"
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: deployed clang is ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 40
    }
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "clang ${actual_version} deployed from the official prebuilt tarball"
}
