#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

check_architecture() {
    local actual expected
    actual="$(normalize_architecture "$(uname -m)")"
    expected="$(normalize_architecture "${EXPECTED_ARCH}")"
    [[ "${actual}" == "${expected}" ]] || {
        log_message "ERROR: expected architecture ${expected}, runner is ${actual}"
        return 20
    }
}

version_from_header() {
    local header="${GMP_SOURCE_DIR}/gmp.h"
    [[ -f "${header}" ]] || return 1
    local major minor patch
    major="$(awk '$1 == "#define" && $2 == "__GNU_MP_VERSION" {print $3; exit}' "${header}")"
    minor="$(awk '$1 == "#define" && $2 == "__GNU_MP_VERSION_MINOR" {print $3; exit}' "${header}")"
    patch="$(awk '$1 == "#define" && $2 == "__GNU_MP_VERSION_PATCHLEVEL" {print $3; exit}' "${header}")"
    [[ -n "${major}" && -n "${minor}" ]] || return 1
    printf '%s.%s' "${major}" "${minor}"
    if [[ -n "${patch}" ]]; then
        printf '.%s' "${patch}"
    fi
    printf '\n'
}

verify_gmp_build() {
    local actual_version
    [[ -x "${GMP_SPEED_BIN}" ]] || {
        log_message "ERROR: upstream tune/speed was not built: ${GMP_SPEED_BIN}"
        return 30
    }
    [[ -f "${GMP_PREFIX}/include/gmp.h" ]] || {
        log_message "ERROR: GMP headers were not installed into the private prefix"
        return 30
    }
    actual_version="$(version_from_header)" || {
        log_message "ERROR: cannot read the GMP version from gmp.h"
        return 30
    }
    GMP_VERSION_STRING="${actual_version}"
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: built GMP reports ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 30
    }
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 30
    log_message "GMP ${actual_version} build verified (prefix ${GMP_PREFIX})"
}

build_gmp_base() {
    local started
    initialize_runtime || return $?
    check_architecture || return $?
    require_build_commands || return $?
    [[ ! -e "${GMP_SOURCE_DIR}" ]] || {
        log_message "ERROR: source directory already exists: ${GMP_SOURCE_DIR}"
        return 20
    }

    download_gmp_archive "${GMP_ARCHIVE}" || return $?

    log_message "extracting ${GMP_ARCHIVE_NAME}"
    tar -C "${PERF_WORK_DIR}/src" -xf "${GMP_ARCHIVE}" || {
        log_message "ERROR: cannot extract ${GMP_ARCHIVE}"
        return 30
    }

    log_message "configuring GMP ${GMP_VERSION} with ${GMP_CONFIGURE_OPTIONS[*]} into ${GMP_PREFIX}"
    started=$(date +%s)
    if ! ( cd "${GMP_SOURCE_DIR}" && \
        ./configure --prefix="${GMP_PREFIX}" "${GMP_CONFIGURE_OPTIONS[@]}" \
        ) >"${LOG_DIR}/configure.log" 2>&1; then
        log_message "ERROR: GMP configure failed after $(( $(date +%s) - started ))s"
        log_message "---- tail of logs/configure.log ----"
        tail -n 40 -- "${LOG_DIR}/configure.log" | while IFS= read -r line; do log_message "  ${line}"; done
        log_message "---- end of logs/configure.log ----"
        return 30
    fi

    log_message "building GMP ${GMP_VERSION} with make -j${GMP_BUILD_JOBS} (log: logs/make.log)"
    started=$(date +%s)
    if ! ( cd "${GMP_SOURCE_DIR}" && make -j"${GMP_BUILD_JOBS}" ) \
        >"${LOG_DIR}/make.log" 2>&1; then
        log_message "ERROR: GMP make failed after $(( $(date +%s) - started ))s"
        log_message "---- tail of logs/make.log ----"
        tail -n 40 -- "${LOG_DIR}/make.log" | while IFS= read -r line; do log_message "  ${line}"; done
        log_message "---- end of logs/make.log ----"
        return 30
    fi

    log_message "building the upstream tune/speed benchmark (log: logs/speed-build.log)"
    if ! ( cd "${GMP_SOURCE_DIR}" && make -j"${GMP_BUILD_JOBS}" -C tune speed ) \
        >"${LOG_DIR}/speed-build.log" 2>&1; then
        log_message "ERROR: building GMP tune/speed failed"
        tail -n 40 -- "${LOG_DIR}/speed-build.log" | while IFS= read -r line; do log_message "  ${line}"; done
        return 30
    fi

    log_message "installing GMP ${GMP_VERSION} into the private prefix"
    if ! ( cd "${GMP_SOURCE_DIR}" && make install ) >"${LOG_DIR}/install.log" 2>&1; then
        log_message "ERROR: GMP make install failed"
        tail -n 40 -- "${LOG_DIR}/install.log" | while IFS= read -r line; do log_message "  ${line}"; done
        return 30
    fi

    verify_gmp_build || return $?
}
