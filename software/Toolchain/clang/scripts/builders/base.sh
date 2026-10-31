#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

install_build_dependencies() {
    local -a packages=(tar xz unzip sed findutils gawk coreutils curl python3 which)
    local -a missing=()
    local -a dnf_options=()
    local package
    for package in "${packages[@]}"; do
        rpm -q "${package}" >/dev/null 2>&1 || missing+=("${package}")
    done
    (( ${#missing[@]} > 0 )) || return 0
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing missing build packages: ${missing[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${missing[@]}" || return 30
    elif command -v sudo >/dev/null 2>&1; then
        sudo -n dnf "${dnf_options[@]}" install -y "${missing[@]}" || return 30
    else
        log_message 'ERROR: dnf requires root or passwordless sudo'
        return 30
    fi
}

fetch_llvm_archive() {
    local archive_path local_archive
    local_archive="${CLANG_ARCHIVE_DIR}/${LLVM_ARCHIVE_NAME}"
    if [[ -s "${local_archive}" ]]; then
        archive_path="${local_archive}"
        log_message "using local LLVM archive: ${archive_path}"
    elif [[ -s "${PERF_WORK_DIR}/${LLVM_ARCHIVE_NAME}" ]]; then
        archive_path="${PERF_WORK_DIR}/${LLVM_ARCHIVE_NAME}"
        log_message "using cached LLVM archive: ${archive_path}"
    else
        archive_path="${PERF_WORK_DIR}/${LLVM_ARCHIVE_NAME}"
        log_message "downloading ${LLVM_ARCHIVE_NAME}"
        with_network_proxy curl -fL --retry 3 --connect-timeout 30 \
            -o "${archive_path}" \
            "${LLVM_RELEASE_BASE}/llvmorg-${SOFTWARE_VERSION}/${LLVM_ARCHIVE_NAME}" || return 30
    fi
    verify_sha256 "${archive_path}" "${LLVM_ARCHIVE_SHA256}" || return $?
    printf '%s\n' "${archive_path}"
}

extract_llvm_archive() {
    local archive="$1" staging_dir clang_file toolchain_dir
    rm -rf "${LLVM_ROOT}"
    staging_dir="${PERF_WORK_DIR}/llvm-unpack"
    rm -rf "${staging_dir}"
    mkdir -p "${staging_dir}"
    log_message "extracting ${archive}"
    tar -xJf "${archive}" -C "${staging_dir}" || {
        rm -rf "${staging_dir}"
        log_message "ERROR: failed to extract ${archive}"
        return 40
    }
    # The release tarball either unpacks into one versioned directory or
    # spreads bin/ and lib/ directly over the staging directory.
    clang_file="$(find "${staging_dir}" -maxdepth 3 -path '*/bin/clang' \( -type f -o -type l \) -print -quit)"
    [[ -n "${clang_file}" ]] || {
        rm -rf "${staging_dir}"
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
    install_build_dependencies || return $?
    archive_path="$(fetch_llvm_archive)" || return $?
    extract_llvm_archive "${archive_path}" || return $?
    [[ -x "${CLANG_BIN}" && -x "${CLANGXX_BIN}" ]] || {
        log_message 'ERROR: clang/clang++ binaries not found after extraction'
        return 40
    }
    if ldd "${CLANG_BIN}" 2>&1 | grep -q 'not found'; then
        log_message 'ERROR: clang runtime dependencies are missing on this runner'
        return 40
    fi
    actual_version="$("${CLANG_BIN}" --version 2>/dev/null | \
        sed -nE 's/^clang version ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -n 1)"
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: deployed clang is ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 40
    }
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "clang ${actual_version} deployed from the official prebuilt tarball"
}
