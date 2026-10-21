#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

require_commands() {
    local required package missing=0
    local packages=()

    for required in gcc make tar xz sha256sum curl python3 awk nproc bison patch; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            log_message "missing required command: ${required}"
            missing=1
            case "${required}" in
                gcc) package="gcc" ;;
                make) package="make" ;;
                tar) package="tar" ;;
                xz) package="xz" ;;
                sha256sum|nproc) package="coreutils" ;;
                curl) package="curl" ;;
                python3) package="python3" ;;
                awk) package="gawk" ;;
                bison) package="bison" ;;
                patch) package="patch" ;;
            esac
            packages+=("${package}")
        fi
    done
    if [[ "${missing}" -eq 0 ]]; then
        return 0
    fi

    if ! command -v dnf >/dev/null 2>&1; then
        log_message "ERROR: dnf is required to install glibc build prerequisites"
        return 30
    fi
    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing missing glibc build packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log_message "ERROR: sudo is required to install glibc build prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log_message "ERROR: failed to install glibc build prerequisites"
        return 30
    fi

    for required in gcc make tar xz sha256sum curl python3 awk nproc bison patch; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            log_message "ERROR: required command is still missing after installation: ${required}"
            return 30
        fi
    done
}

prepare_glibc_source() {
    local tarball local_tarball expected_sha256 actual_sha256 source_root
    if [[ -e "${SRC_DIR}" ]]; then
        log_message "ERROR: source directory already exists: ${SRC_DIR}"
        return 30
    fi
    # The official GNU release checksums are declared beside the download
    # logic: adding a version requires adding its checksum here.
    case "${SOFTWARE_VERSION}" in
        2.31)
            expected_sha256="9246fe44f68feeec8c666bb87973d590ce0137cca145df014c72ec95be9ffd17"
            ;;
        *)
            log_message "ERROR: no official GNU checksum is declared for glibc ${SOFTWARE_VERSION}"
            return 20
            ;;
    esac
    tarball="${PERF_WORK_DIR}/glibc-${SOFTWARE_VERSION}.tar.xz"
    local_tarball="/home/runner/software/glibc/glibc-${SOFTWARE_VERSION}.tar.xz"
    if [[ -f "${local_tarball}" ]]; then
        tarball="${local_tarball}"
        log_message "using local glibc source archive ${tarball}"
    else
        log_message "downloading official glibc ${SOFTWARE_VERSION} release tarball from ${GLIBC_SOURCE_URL}"
        if ! curl -fsSL --retry 3 --connect-timeout 30 \
            -o "${tarball}" \
            "${GLIBC_SOURCE_URL}/glibc-${SOFTWARE_VERSION}.tar.xz"; then
            rm -f "${tarball}"
            log_message "ERROR: failed to download glibc-${SOFTWARE_VERSION}.tar.xz"
            return 30
        fi
    fi
    actual_sha256="$(sha256sum "${tarball}" | awk '{print $1}')"
    if [[ "${actual_sha256}" != "${expected_sha256}" ]]; then
        log_message "ERROR: glibc tarball checksum mismatch"
        log_message "expected: ${expected_sha256}"
        log_message "actual:   ${actual_sha256}"
        return 30
    fi
    if ! tar -xJf "${tarball}" -C "${PERF_WORK_DIR}"; then
        log_message "ERROR: failed to extract the glibc tarball"
        return 30
    fi
    source_root="${PERF_WORK_DIR}/glibc-${SOFTWARE_VERSION}"
    if [[ ! -f "${source_root}/configure" ]]; then
        log_message "ERROR: tarball did not create glibc-${SOFTWARE_VERSION}/configure"
        return 30
    fi
    if ! mv "${source_root}" "${SRC_DIR}"; then
        log_message "ERROR: failed to move the unpacked source into ${SRC_DIR}"
        return 30
    fi
    # The upstream 2.31 benchtests use TSC ticks on x86_64 and nanoseconds
    # on aarch64. Apply the same measurement-only changes to both builds.
    if ! patch --batch --forward --fuzz=0 -l -p1 -d "${SRC_DIR}" \
        -i "${SCRIPT_DIR}/scripts/glibc-2.31-benchtests.patch"; then
        log_message "ERROR: failed to apply the glibc 2.31 benchtest measurement patch"
        return 30
    fi
    if [[ "${tarball}" == "${PERF_WORK_DIR}/"* ]]; then
        rm -f "${tarball}"
    fi
}

prepare_compatible_make() {
    local archive="${PERF_WORK_DIR}/make-${MAKE_VERSION}.tar.gz"
    local local_archive="/home/runner/software/glibc/make-${MAKE_VERSION}.tar.gz"
    local source_dir="${PERF_WORK_DIR}/make-${MAKE_VERSION}-src"
    local actual_sha256

    if [[ -f "${local_archive}" ]]; then
        archive="${local_archive}"
        log_message "using local GNU Make archive ${archive}"
    else
        log_message "downloading GNU Make ${MAKE_VERSION} from ${MAKE_SOURCE_URL}"
        if ! curl -fsSL --retry 3 --connect-timeout 30 \
            -o "${archive}" "${MAKE_SOURCE_URL}/make-${MAKE_VERSION}.tar.gz"; then
            rm -f "${archive}"
            log_message "ERROR: failed to download GNU Make ${MAKE_VERSION}"
            return 30
        fi
    fi
    actual_sha256="$(sha256sum "${archive}" | awk '{print $1}')"
    if [[ "${actual_sha256}" != "${MAKE_ARCHIVE_SHA256}" ]]; then
        log_message "ERROR: GNU Make ${MAKE_VERSION} archive checksum mismatch"
        return 30
    fi
    mkdir -p "${source_dir}"
    if ! tar -xzf "${archive}" -C "${source_dir}" --strip-components=1; then
        log_message "ERROR: failed to extract GNU Make ${MAKE_VERSION}"
        return 30
    fi
    if [[ "${archive}" == "${PERF_WORK_DIR}/"* ]]; then
        rm -f "${archive}"
    fi
    log_message "building GNU Make ${MAKE_VERSION} in the private work directory"
    (
        cd "${source_dir}"
        ./configure --prefix="${MAKE_INSTALL_DIR}" --disable-nls
        make -j4
        make install
    ) || {
        log_message "ERROR: failed to build GNU Make ${MAKE_VERSION}"
        return 30
    }
    if [[ "$("${MAKE_INSTALL_DIR}/bin/make" --version | head -n 1)" != "GNU Make ${MAKE_VERSION}" ]]; then
        log_message "ERROR: private GNU Make ${MAKE_VERSION} is unavailable"
        return 30
    fi
    PATH="${MAKE_INSTALL_DIR}/bin:${PATH}"
    export PATH
    log_message "using private $(make --version | head -n 1)"
}

build_glibc_base() {
    local actual_version
    local version_output

    initialize_runtime || return $?
    require_commands || return $?
    if [[ -e "${SRC_DIR}" || -e "${BUILD_DIR}" || -e "${INSTALL_DIR}" ]]; then
        log_message "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    fi
    prepare_glibc_source || return $?
    prepare_compatible_make || return $?
    GCC_VERSION_STRING="$(gcc --version | head -n 1)"

    log_message "configuring glibc ${SOFTWARE_VERSION} (out-of-tree build)"
    mkdir -p "${BUILD_DIR}"
    (
        cd "${BUILD_DIR}"
        unset LD_LIBRARY_PATH
        "${SRC_DIR}/configure" \
            --prefix="${INSTALL_DIR}" \
            --disable-werror \
            --without-selinux \
            CC=gcc CFLAGS=-O3
    ) || {
        log_message "ERROR: glibc configure failed"
        return 40
    }
    log_message "building glibc ${SOFTWARE_VERSION} with make -j$(nproc)"
    (
        cd "${BUILD_DIR}"
        unset LD_LIBRARY_PATH
        # The runner's newer libstdc++ requires symbols absent from glibc 2.31.
        # Use glibc's C implementation of its build-only links-dso helper.
        make -j"$(nproc)" CXX=
    ) || {
        log_message "ERROR: glibc make build failed"
        return 40
    }
    # Benchtest executables embed the dynamic-loader path below --prefix.
    # Install into this run's isolated prefix so that path exists without
    # touching the runner's system glibc. cross-compiling=yes suppresses
    # glibc's install-time ldconfig update of the system cache.
    log_message "installing glibc ${SOFTWARE_VERSION} into the isolated prefix ${INSTALL_DIR}"
    (
        cd "${BUILD_DIR}"
        unset LD_LIBRARY_PATH
        make install cross-compiling=yes CXX=
    ) || {
        log_message "ERROR: glibc installation into ${INSTALL_DIR} failed"
        return 40
    }
    if [[ ! -x "${LDCONFIG_BIN}" ]]; then
        log_message "ERROR: built ldconfig is missing: ${LDCONFIG_BIN}"
        return 40
    fi
    if ! find "${INSTALL_DIR}/lib" -maxdepth 1 \
        \( -type f -o -type l \) -name 'ld-linux-*.so.*' -print -quit | grep -q .; then
        log_message "ERROR: installed glibc dynamic loader is missing under ${INSTALL_DIR}/lib"
        return 40
    fi
    if ! version_output="$("${LDCONFIG_BIN}" --version 2>/dev/null | head -n 1)"; then
        log_message "ERROR: built ldconfig cannot report its version"
        return 40
    fi
    # Output format: "ldconfig (GNU libc) 2.31".
    actual_version="$(printf '%s\n' "${version_output}" | awk '{print $NF}')"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: built glibc reports ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40
    log_message "glibc ${SOFTWARE_VERSION} build is ready at ${BUILD_DIR}"
}
