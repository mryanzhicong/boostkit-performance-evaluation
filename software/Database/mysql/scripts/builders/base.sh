#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

fetch_mysql_archive() {
    local archive_path
    local actual_md5
    local archive_md5
    local archive_name
    local download_url
    local local_archive_path
    local release_directory

    # Every supported artifact is declared with its official archive name and
    # checksum.  Adding a version means adding its two architecture entries
    # here; the download, extraction, and lifecycle logic remains unchanged.
    case "${SOFTWARE_VERSION}:${EXPECTED_ARCH}" in
        8.0.43:x86_64)
            release_directory="MySQL-8.0"
            archive_name="mysql-8.0.43-linux-glibc2.28-x86_64.tar.xz"
            archive_md5="9b6ef0d08e5506eab12fe2c1b619f664"
            ;;
        8.0.43:aarch64)
            release_directory="MySQL-8.0"
            archive_name="mysql-8.0.43-linux-glibc2.28-aarch64.tar.xz"
            archive_md5="c51923a9b540cd2f886734d3e0366e9a"
            ;;
        *)
            log_message "ERROR: no verified MySQL release is declared for ${SOFTWARE_VERSION} on ${EXPECTED_ARCH}"
            return 10
            ;;
    esac

    local_archive_path="/home/runner/software/mysql/${archive_name}"
    if [[ -f "${local_archive_path}" ]]; then
        archive_path="${local_archive_path}"
        log_message "using local MySQL archive ${archive_path}" >&2
    elif [[ -s "${PERF_WORK_DIR}/${archive_name}" ]]; then
        archive_path="${PERF_WORK_DIR}/${archive_name}"
        log_message "using cached MySQL archive ${archive_path}" >&2
    else
        archive_path="${PERF_WORK_DIR}/${archive_name}"
        download_url="https://dev.mysql.com/get/Downloads/${release_directory}/${archive_name}"
        log_message "downloading ${download_url}" >&2
        if command -v curl >/dev/null 2>&1; then
            if ! curl -fSL --retry 3 --connect-timeout 30 -o "${archive_path}" "${download_url}"; then
                rm -f "${archive_path}"
                log_message "ERROR: failed to download ${archive_name} from the official MySQL download endpoint" >&2
                return 30
            fi
        elif ! wget -q -O "${archive_path}" "${download_url}"; then
            rm -f "${archive_path}"
            log_message "ERROR: failed to download ${archive_name}" >&2
            return 30
        fi
    fi

    actual_md5="$(md5sum "${archive_path}")"
    actual_md5="${actual_md5%% *}"
    if [[ "${actual_md5}" != "${archive_md5}" ]]; then
        log_message "ERROR: MySQL archive checksum mismatch: expected ${archive_md5}, got ${actual_md5}" >&2
        return 30
    fi
    printf '%s\n' "${archive_path}"
}

extract_mysql_archive() {
    local archive="$1"
    local unpacked_directory

    rm -rf "${MYSQL_BASE_DIR}"
    log_message "extracting ${archive}"
    if [[ "${archive}" == *.tar.xz ]]; then
        tar -xJf "${archive}" -C "${PERF_WORK_DIR}"
    else
        tar -xzf "${archive}" -C "${PERF_WORK_DIR}"
    fi
    unpacked_directory="$(find "${PERF_WORK_DIR}" -maxdepth 1 -type d -name "mysql-${SOFTWARE_VERSION}-*" | head -n 1)"
    if [[ -z "${unpacked_directory}" ]]; then
        log_message "ERROR: cannot locate the unpacked mysql directory"
        return 40
    fi
    mv "${unpacked_directory}" "${MYSQL_BASE_DIR}"
}

build_mysql_base() {
    local archive_path
    local actual_version

    initialize_runtime || return $?
    require_mysql_tools || return $?
    if [[ -e "${MYSQL_BASE_DIR}/bin/mysqld" ]]; then
        log_message "ERROR: build output is not clean under ${PERF_WORK_DIR}"
        return 20
    fi

    archive_path="$(fetch_mysql_archive)" || return $?
    extract_mysql_archive "${archive_path}" || return $?

    if [[ ! -x "${MYSQLD_BIN}" || ! -x "${MYSQL_BIN}" ]]; then
        log_message "ERROR: mysqld/mysql binaries not found after extraction"
        return 40
    fi
    if ldd "${MYSQLD_BIN}" 2>&1 | grep -Eq 'libaio[^[:space:]]*[[:space:]]+=>[[:space:]]+not found'; then
        log_message "ERROR: libaio runtime is missing; provision it on the dedicated runner before this workflow"
        return 40
    fi
    actual_version="$("${MYSQLD_BIN}" --version 2>/dev/null | sed -nE 's/.*Ver ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p')"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: installed mysqld is ${actual_version}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "mysqld ${actual_version} deployed from the official prebuilt tarball"
}
