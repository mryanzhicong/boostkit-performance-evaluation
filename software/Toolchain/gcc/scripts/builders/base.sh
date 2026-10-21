#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

install_dependencies() {
    local required missing=0
    local required_commands=(gcc g++ gfortran make tar xz sha256sum curl python3 awk date sort nproc grep perl mount umount numactl)
    local packages=(gcc gcc-c++ gcc-gfortran make tar xz coreutils curl python3 grep
        gawk findutils gmp-devel mpfr-devel libmpc-devel bison flex perl util-linux libnsl numactl)
    for required in "${required_commands[@]}"; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            missing=1
        fi
    done
    if [[ "${missing}" -eq 0 ]] && printf \
        '#include <gmp.h>\n#include <mpfr.h>\n#include <mpc.h>\nint main(void) { return 0; }\n' | \
        g++ -x c++ -fsyntax-only - >/dev/null 2>&1 && \
        ldconfig -p 2>/dev/null | grep -q 'libnsl\.so\.1'; then
        return
    fi

    log_message "installing missing GCC build dependencies"
    local package_manager_options=()
    [[ -z "${PERF_PROXY:-}" ]] || package_manager_options+=("--setopt=proxy=${PERF_PROXY}")
    if ! command -v dnf >/dev/null 2>&1; then
        log_message "ERROR: dnf is required to install GCC build dependencies"
        return 30
    fi
    local install_command=(dnf)
    if [[ "${EUID}" -ne 0 ]]; then
        if ! command -v sudo >/dev/null 2>&1; then
            log_message "ERROR: root privileges are required to install GCC build dependencies"
            return 30
        fi
        install_command=(sudo -n dnf)
    fi
    if ! "${install_command[@]}" "${package_manager_options[@]}" install -y "${packages[@]}"; then
        log_message "ERROR: failed to install GCC build dependencies"
        return 30
    fi

    for required in "${required_commands[@]}"; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            log_message "ERROR: required command is still missing after installation: ${required}"
            return 30
        fi
    done
    if ! printf '#include <gmp.h>\n#include <mpfr.h>\n#include <mpc.h>\nint main(void) { return 0; }\n' | \
        g++ -x c++ -fsyntax-only - >/dev/null 2>&1; then
        log_message "ERROR: GMP, MPFR, or MPC development headers are unavailable after installation"
        return 30
    fi
    if ! ldconfig -p 2>/dev/null | grep -q 'libnsl\.so\.1'; then
        log_message "ERROR: SPEC CPU2017 tools require libnsl.so.1, but libnsl did not provide it"
        return 30
    fi
}

prepare_gcc_source() {
    local tarball offline_tarball actual_sha256 source_root

    case "${SOFTWARE_VERSION}" in
        14.4.0)
            GCC_SOURCE_SHA256="752b6f567beac83159c77a7680b1316bdd784738bff9a9d070112c09da90f6d9"
            ;;
        *)
            log_message "ERROR: unsupported GCC version: ${SOFTWARE_VERSION}"
            return 20
            ;;
    esac

    if [[ -e "${SRC_DIR}" ]]; then
        log_message "ERROR: source directory already exists: ${SRC_DIR}"
        return 30
    fi
    tarball="${PERF_WORK_DIR}/gcc-${SOFTWARE_VERSION}.tar.xz"
    offline_tarball="${GCC_OFFLINE_DIR}/gcc-${SOFTWARE_VERSION}.tar.xz"
    if [[ -f "${offline_tarball}" ]]; then
        log_message "using local GCC archive ${offline_tarball}"
        if ! cp "${offline_tarball}" "${tarball}"; then
            log_message "ERROR: failed to copy local GCC archive"
            return 30
        fi
    else
        log_message "downloading official gcc ${SOFTWARE_VERSION} release tarball from ${GCC_SOURCE_BASE}"
        if ! curl -fsSL --retry 3 --connect-timeout 30 \
            -o "${tarball}" \
            "${GCC_SOURCE_BASE}/gcc-${SOFTWARE_VERSION}/gcc-${SOFTWARE_VERSION}.tar.xz"; then
            log_message "ERROR: failed to download gcc-${SOFTWARE_VERSION}.tar.xz"
            return 30
        fi
    fi
    actual_sha256="$(sha256sum "${tarball}" | awk '{print $1}')"
    if [[ "${actual_sha256}" != "${GCC_SOURCE_SHA256}" ]]; then
        log_message "ERROR: GCC tarball checksum mismatch"
        log_message "expected: ${GCC_SOURCE_SHA256}"
        log_message "actual:   ${actual_sha256}"
        return 30
    fi
    log_message "extracting GCC source (checksum verified)"
    if ! tar -xJf "${tarball}" -C "${PERF_WORK_DIR}"; then
        log_message "ERROR: failed to extract the GCC tarball"
        return 30
    fi
    source_root="${PERF_WORK_DIR}/gcc-${SOFTWARE_VERSION}"
    if [[ ! -f "${source_root}/configure" || \
          ! -d "${source_root}/gcc/testsuite/gcc.c-torture/compile" ]]; then
        log_message "ERROR: tarball did not create the expected GCC source tree"
        return 30
    fi
    if ! mv "${source_root}" "${SRC_DIR}"; then
        log_message "ERROR: failed to place the extracted GCC source tree"
        return 30
    fi
    rm -f "${tarball}"
}

build_gcc_base() {
    local version_output actual_version

    initialize_runtime || return $?
    install_dependencies || return $?
    if [[ -e "${SRC_DIR}" || -e "${BUILD_DIR}" || -e "${INSTALL_DIR}" ]]; then
        log_message "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    fi
    prepare_gcc_source || return $?

    log_message "configuring GCC ${SOFTWARE_VERSION} (C and C++, out-of-tree build)"
    mkdir -p "${BUILD_DIR}"
    if ! (
        cd "${BUILD_DIR}"
        "${SRC_DIR}/configure" \
            --prefix="${INSTALL_DIR}" \
            --enable-languages=c,c++,fortran \
            --disable-bootstrap \
            --disable-multilib \
            --disable-nls
    ); then
        log_message "ERROR: GCC configure failed"
        return 40
    fi
    log_message "building GCC ${SOFTWARE_VERSION} with make -j$(nproc)"
    if ! (
        cd "${BUILD_DIR}"
        make -j"$(nproc)"
    ); then
        log_message "ERROR: GCC build failed"
        return 40
    fi
    log_message "installing GCC ${SOFTWARE_VERSION} into ${INSTALL_DIR}"
    if ! (
        cd "${BUILD_DIR}"
        make install
    ); then
        log_message "ERROR: GCC private installation failed"
        return 40
    fi
    if [[ ! -x "${GCC_BIN}" || ! -x "${GXX_BIN}" || ! -x "${GFORTRAN_BIN}" ]]; then
        log_message "ERROR: private GCC C, C++, or Fortran compiler is missing"
        return 40
    fi
    if ! version_output="$("${GCC_BIN}" --version 2>/dev/null | head -n 1)"; then
        log_message "ERROR: built GCC cannot report its version"
        return 40
    fi
    actual_version="$(printf '%s\n' "${version_output}" | awk '{print $NF}')"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: built GCC reports ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 40
    fi
    GCC_VERSION_STRING="${version_output}"
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "GCC ${SOFTWARE_VERSION} compiler is ready at ${GCC_BIN}"
}
