#!/usr/bin/env bash
# Base build: fetch and verify the pinned BusyBox source archive on the host,
# then extract, configure, build and install it inside this task's private
# openEuler container.  The actual version is read back from the built binary so
# the Framework can reject a wrong build.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

# Host-side prerequisites are limited to Docker plus the download/verification
# tools; every compiler and build dependency is installed inside the container.
require_host_transfer_commands() {
    local packages=()
    local command_name package
    for command_name in curl sha256sum tar python3; do
        command -v "${command_name}" >/dev/null 2>&1 && continue
        case "${command_name}" in
            curl) package=curl ;;
            sha256sum) package=coreutils ;;
            tar) package=tar ;;
            python3) package=python3 ;;
        esac
        packages+=("${package}")
    done
    ((${#packages[@]} == 0)) && return 0
    log_message "WARNING: host download tools are incomplete: ${packages[*]}; relying on the pre-placed offline archive"
    return 0
}

prepare_busybox_build_container() {
    local -a dnf_options=()
    require_host_transfer_commands
    require_busybox_docker || return 30
    start_busybox_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message 'installing BusyBox build dependencies inside the private container'
    busybox_container_exec_root dnf "${dnf_options[@]}" --setopt=install_weak_deps=False install -y \
        gcc gcc-c++ make tar bzip2 diffutils coreutils findutils sed gawk grep \
        util-linux file glibc-devel binutils python3 || {
        fail_message "container build dependencies failed"
        return 30
    }
}

busybox_source_tree_version() {
    # BusyBox reports its version in its banner; the banner also contains a build
    # timestamp, so only the version token is compared.
    busybox_container_exec "${BUSYBOX_BIN}" 2>&1 | head -1 | awk '{print $2}' | sed 's/^v//'
}

build_busybox_base() {
    initialize_runtime || return $?
    prepare_busybox_build_container || return $?

    log_message "fetching BusyBox ${SOFTWARE_VERSION} source archive"
    fetch_source_archive || return $?

    if [[ -d "${BUSYBOX_SRC_DIR}" ]]; then
        rm -rf -- "${BUSYBOX_SRC_DIR}"
    fi
    log_message "extracting ${BUSYBOX_SOURCE_ARCHIVE} inside the private container"
    busybox_container_exec tar -xjf "${BUSYBOX_SOURCE_ARCHIVE}" -C "${PERF_WORK_DIR}" || {
        fail_message "failed to extract ${BUSYBOX_SOURCE_ARCHIVE}"
        return 30
    }
    if busybox_container_exec test -d "${PERF_WORK_DIR}/busybox-1.38.0"; then
        busybox_container_exec mv -- "${PERF_WORK_DIR}/busybox-1.38.0" "${BUSYBOX_SRC_DIR}" || {
            fail_message "failed to place the extracted BusyBox source tree"
            return 30
        }
    fi
    if ! busybox_container_exec test -f "${BUSYBOX_SRC_DIR}/Makefile" || \
        ! busybox_container_exec test -f "${BUSYBOX_SRC_DIR}/Config.in"; then
        fail_message "source archive does not contain the expected BusyBox tree"
        return 30
    fi

    log_message "configuring BusyBox with the upstream default configuration (defconfig)"
    busybox_container_exec_at "${BUSYBOX_SRC_DIR}" make defconfig \
        > "${BUSYBOX_STATE_DIR}/configure.log" 2>&1 || {
        fail_message "make defconfig failed, see ${BUSYBOX_STATE_DIR}/configure.log"
        return 30
    }
    if ! busybox_container_exec test -f "${BUSYBOX_SRC_DIR}/.config"; then
        fail_message "BusyBox configuration was not generated"
        return 30
    fi

    log_message "building BusyBox with -j${BUSYBOX_BUILD_JOBS} inside the private container"
    busybox_container_exec_at "${BUSYBOX_SRC_DIR}" make -j "${BUSYBOX_BUILD_JOBS}" \
        > "${BUSYBOX_STATE_DIR}/build.log" 2>&1 || {
        fail_message "BusyBox build failed, see ${BUSYBOX_STATE_DIR}/build.log"
        return 30
    }

    log_message "installing BusyBox into ${BUSYBOX_INSTALL_DIR}"
    busybox_container_exec_at "${BUSYBOX_SRC_DIR}" make CONFIG_PREFIX="${BUSYBOX_INSTALL_DIR}" install \
        > "${BUSYBOX_STATE_DIR}/install.log" 2>&1 || {
        fail_message "BusyBox install failed, see ${BUSYBOX_STATE_DIR}/install.log"
        return 30
    }

    local missing=()
    local applet
    if ! busybox_container_exec test -x "${BUSYBOX_INSTALL_DIR}/bin/busybox"; then
        missing+=(busybox)
    fi
    if (( ${#missing[@]} > 0 )); then
        fail_message "installed BusyBox binary is missing: ${missing[*]}"
        return 30
    fi

    local available
    available="$(busybox_container_exec "${BUSYBOX_BIN}" --list 2>/dev/null || true)"
    local absent=()
    for applet in "${BUSYBOX_REQUIRED_APPLETS[@]}"; do
        if ! printf '%s\n' "${available}" | grep -qx "${applet}"; then
            absent+=("${applet}")
        fi
    done
    if (( ${#absent[@]} > 0 )); then
        fail_message "the built BusyBox is missing required applets: ${absent[*]}"
        return 30
    fi

    local actual_version
    actual_version="$(busybox_source_tree_version)"
    if [[ -z "${actual_version}" ]]; then
        fail_message "cannot determine the built BusyBox version"
        return 30
    fi
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        fail_message "requested BusyBox ${SOFTWARE_VERSION}, built ${actual_version}"
        return 30
    fi

    cat > "${BUSYBOX_STATE_DIR}/build-provenance.txt" <<EOF
software=busybox
version=${actual_version}
source_archive=${BUSYBOX_SOURCE_NAME}
source_sha256=${BUSYBOX_SOURCE_SHA256}
source_bytes=${BUSYBOX_SOURCE_SIZE}
configuration=defconfig
cflags=${BUSYBOX_CFLAGS}
build_jobs=${BUSYBOX_BUILD_JOBS}
c_compiler=$(compiler_identity)
applet_count=$(printf '%s\n' "${available}" | grep -c . || true)
required_applets=${BUSYBOX_REQUIRED_APPLETS[*]}
container_name=${BUSYBOX_CONTAINER_NAME}
container_image=$(busybox_container_exec cat /etc/os-release 2>/dev/null | sed -n 's/^PRETTY_NAME=//p' | tr -d '"' || true)
EOF
    log_message "BusyBox ${actual_version} built and installed (${BUSYBOX_BIN})"
    return 0
}
