#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

fetch_sqlite_archive() {
    local package_name="$1" expected_sha3="$2"
    local archive_path="${BENCHMARK_DIR}/${package_name}"
    local local_archive="${CLANG_ARCHIVE_DIR}/${package_name}"
    if [[ -s "${local_archive}" ]]; then
        log_message "using local SQLite archive: ${local_archive}"
        cp "${local_archive}" "${archive_path}" || return 30
    elif [[ ! -s "${archive_path}" ]]; then
        log_message "downloading ${package_name}"
        with_network_proxy curl -fL --retry 3 --connect-timeout 30 \
            -o "${archive_path}" \
            "${SQLITE_BENCHMARK_BASE}/${package_name}" || return 30
    else
        log_message "using cached SQLite archive: ${archive_path}"
    fi
    verify_sha3_256 "${archive_path}" "${expected_sha3}" || return $?
    printf '%s\n' "${archive_path}"
}

prepare_benchmark_sources() {
    local amalgamation_archive source_archive
    amalgamation_archive="$(fetch_sqlite_archive \
        "${SQLITE_AMALGAMATION_PACKAGE}" "${SQLITE_AMALGAMATION_SHA3_256}")" || return $?
    source_archive="$(fetch_sqlite_archive \
        "${SQLITE_SOURCE_PACKAGE}" "${SQLITE_SOURCE_SHA3_256}")" || return $?
    rm -rf "${AMALGAMATION_DIR}" "${SQLITE_SOURCE_DIR}"
    mkdir -p "${AMALGAMATION_DIR}" "${SQLITE_SOURCE_DIR}"
    unzip -q "${amalgamation_archive}" -d "${AMALGAMATION_DIR}" || {
        log_message 'ERROR: failed to extract the SQLite amalgamation'
        return 40
    }
    unzip -q "${source_archive}" -d "${SQLITE_SOURCE_DIR}" || {
        log_message 'ERROR: failed to extract the SQLite source tree'
        return 40
    }
    SQLITE3_C="$(find "${AMALGAMATION_DIR}" -type f -name sqlite3.c -print -quit)"
    SQLITE3_H="$(find "${AMALGAMATION_DIR}" -type f -name sqlite3.h -print -quit)"
    SPEEDTEST1_C="$(find "${SQLITE_SOURCE_DIR}" -type f -name speedtest1.c -print -quit)"
    [[ -n "${SQLITE3_C}" && -n "${SQLITE3_H}" && -n "${SPEEDTEST1_C}" ]] || {
        log_message 'ERROR: SQLite benchmark sources are incomplete after extraction'
        return 40
    }
    log_message "SQLite ${SQLITE_BENCHMARK_VERSION} benchmark sources are staged"
}

build_speedtest1_binary() {
    local output_path="$1"
    log_message "building speedtest1 with ${CLANG_BIN} -O2"
    "${CLANG_BIN}" -O2 -I"$(dirname "${SQLITE3_H}")" \
        "${SPEEDTEST1_C}" "${SQLITE3_C}" -lm -o "${output_path}" || {
        log_message 'ERROR: failed to build speedtest1 with clang'
        return 50
    }
}

start_clang_runtime() {
    local smoke_dir
    initialize_runtime || return $?
    [[ -x "${CLANG_BIN}" && -x "${CLANGXX_BIN}" ]] || {
        log_message 'ERROR: clang is not deployed; build stage did not complete'
        return 40
    }
    prepare_benchmark_sources || return $?
    smoke_dir="${BENCHMARK_DIR}/smoke"
    rm -rf "${smoke_dir}"
    mkdir -p "${smoke_dir}"
    build_speedtest1_binary "${smoke_dir}/speedtest1" || {
        rm -rf "${smoke_dir}"
        return 40
    }
    (cd "${smoke_dir}" && ./speedtest1 --size 100 --memdb test.db) >/dev/null 2>&1 || {
        rm -rf "${smoke_dir}"
        log_message 'ERROR: speedtest1 smoke run failed'
        return 40
    }
    rm -rf "${smoke_dir}"
    log_message 'clang benchmark runtime is ready'
}
