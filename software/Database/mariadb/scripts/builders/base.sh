#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_mariadb_base() {
    local archive actual_version ver_out ldd_out status=0
    local -a dnf_options=()

    initialize_runtime || return $?
    if [[ "$(normalize_architecture "$(uname -m)")" != "${EXPECTED_ARCH}" ]]; then
        log_message "ERROR: expected architecture ${EXPECTED_ARCH}, runner is $(normalize_architecture "$(uname -m)")"
        return 20
    fi
    if [[ -e "${MARIADBD_BIN}" ]]; then
        log_message "ERROR: build output is not clean under ${PERF_WORK_DIR}"
        return 20
    fi

    require_mariadb_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message 'installing MariaDB 11.8.10 build and runtime dependencies inside the private 8U32G container'
    container_exec_root dnf "${dnf_options[@]}" install -y \
        gcc gcc-c++ make cmake ninja-build bison \
        ncurses-devel openssl-devel zlib-devel libaio libaio-devel \
        pcre2-devel fmt-devel libxml2-devel numactl-libs numactl-devel \
        hostname findutils perl perl-Getopt-Long curl tar gzip xz || {
        log_message 'ERROR: container MariaDB build dependencies installation failed'
        return 30
    }
    container_exec sh -c 'gcc --version && g++ --version && cmake --version && ninja --version && bison --version' \
        > "${RESULTS_DIR}/toolchain-versions.txt" 2>&1 || {
        log_message 'ERROR: required MariaDB build toolchain commands are unavailable inside container'
        return 30
    }

    acquire_mariadb_source_archive || return $?
    archive="${PERF_WORK_DIR}/${MARIADB_SOURCE_ARCHIVE}"
    printf 'archive=%s\nsha256=%s\n' "${MARIADB_SOURCE_ARCHIVE}" "${MARIADB_SOURCE_SHA256}" \
        > "${RESULTS_DIR}/source-checksum.txt"
    [[ ! -e "${MARIADB_SOURCE_DIR}" ]] || {
        log_message "ERROR: refusing to extract into existing source directory: ${MARIADB_SOURCE_DIR}"
        return 30
    }
    log_message "extracting ${MARIADB_SOURCE_ARCHIVE} inside the private container"
    container_exec tar -xzf "${archive}" -C "${PERF_WORK_DIR}" || return 30
    [[ -f "${MARIADB_SOURCE_DIR}/CMakeLists.txt" ]] || {
        log_message "ERROR: extracted MariaDB source directory is missing CMakeLists.txt: ${MARIADB_SOURCE_DIR}"
        return 30
    }

    log_message 'configuring MariaDB 11.8.10 with CMake and Ninja inside the private container'
    set +e
    container_exec cmake -S "${MARIADB_SOURCE_DIR}" -B "${MARIADB_BUILD_DIR}" -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${MARIADB_BASE_DIR}" \
        -DINSTALL_LIBDIR=lib \
        -DINSTALL_SBINDIR=bin \
        -DINSTALL_SCRIPTDIR=bin \
        -DWITH_SSL=system \
        -DWITH_ZLIB=system \
        -DWITH_PCRE=system \
        -DWITH_MYSQLCOMPAT=ON \
        -DWITH_UNIT_TESTS=OFF \
        -DINSTALL_MYSQLTESTDIR= \
        -DPLUGIN_TOKUDB=NO \
        -DPLUGIN_MROONGA=NO \
        -DPLUGIN_ROCKSDB=NO \
        -DPLUGIN_SPIDER=NO \
        -DPLUGIN_CONNECT=NO \
        -DPLUGIN_OQGRAPH=NO \
        -DPLUGIN_SPHINX=NO \
        -DPLUGIN_COLUMNSTORE=NO \
        -DPLUGIN_S3=NO \
        2>&1 | tee "${RESULTS_DIR}/cmake-configure.log"
    status="${PIPESTATUS[0]}"
    set -e
    [[ "${status}" -eq 0 ]] || { log_message "ERROR: MariaDB CMake configure failed (rc=${status})"; return 40; }

    log_message 'building and installing MariaDB 11.8.10 inside the private container'
    set +e
    container_exec sh -c 'ninja -C "$1" -j 8 && ninja -C "$1" install' sh "${MARIADB_BUILD_DIR}" \
        2>&1 | tee "${RESULTS_DIR}/ninja-build.log"
    status="${PIPESTATUS[0]}"
    set -e
    [[ "${status}" -eq 0 ]] || { log_message "ERROR: MariaDB ninja build/install failed (rc=${status})"; return 40; }

    for bin in "${MARIADBD_BIN}" "${MARIADB_BIN}" "${MARIADB_ADMIN_BIN}" "${MARIADB_INSTALL_DB_BIN}" "${MARIADB_CONFIG_BIN}"; do
        [[ -x "${bin}" ]] || {
            log_message "ERROR: installed MariaDB executable is missing: ${bin}"
            return 40
        }
    done
    ldd_out="$(container_exec ldd "${MARIADBD_BIN}")" || {
        log_message 'ERROR: ldd failed on mariadbd inside the container'
        return 40
    }
    if grep -q 'not found' <<< "${ldd_out}"; then
        log_message "ERROR: missing shared libraries for mariadbd: ${ldd_out}"
        return 40
    fi

    ver_out="$(container_exec "${MARIADBD_BIN}" --version 2>&1)" || {
        log_message 'ERROR: mariadbd --version failed inside the container'
        return 40
    }
    printf '%s\n' "${ver_out}" > "${RESULTS_DIR}/binary-version.txt"
    actual_version="$(printf '%s\n' "${ver_out}" | sed -nE 's/.*Ver ([0-9]+\.[0-9]+\.[0-9]+)-MariaDB.*/\1/p' | head -n 1)"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: built mariadbd reported '${actual_version}', expected '${SOFTWARE_VERSION}'"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "MariaDB ${actual_version} built and verified inside container ${MARIADB_CONTAINER_NAME}"
}
