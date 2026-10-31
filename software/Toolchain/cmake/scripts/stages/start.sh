#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_cmake_runtime() {
    initialize_runtime || return $?
    [[ -x "${CMAKE_BIN}" ]] || {
        log_message "ERROR: CMake launcher is unavailable: ${CMAKE_BIN}"
        return 40
    }
    local version_value
    version_value="$(cmake_version_string 2>/dev/null | awk '{print $3; exit}')" || version_value=""
    if [[ "${version_value}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: expected CMake ${SOFTWARE_VERSION}, found ${version_value:-unknown}"
        return 40
    fi
    [[ -f "${CMAKE_SOURCE_DIR}/CMakeLists.txt" ]] || {
        log_message "ERROR: upstream CMake source tree is missing: ${CMAKE_SOURCE_DIR}"
        return 40
    }
    [[ -f "${CMAKE_INCREMENTAL_SOURCE_ORIG}" ]] || {
        log_message "ERROR: pristine upstream incremental source is missing: ${CMAKE_INCREMENTAL_SOURCE_ORIG}"
        return 40
    }
    local scale
    for scale in "${CMAKE_SCALES[@]}"; do
        if [[ ! -f "${PROJECTS_DIR}/project-${scale}/CMakeLists.txt" ]]; then
            log_message "ERROR: generated project for ${scale} sources is missing"
            return 40
        fi
    done
    command -v cc >/dev/null 2>&1 || {
        log_message "ERROR: C compiler driver cc is unavailable"
        return 40
    }
    command -v make >/dev/null 2>&1 || {
        log_message "ERROR: make is unavailable; the measured build tool requires it"
        return 40
    }
    log_message "CMake ${version_value} runtime is ready (compiler: $(compiler_identity), jobs: ${CMAKE_JOBS})"
}
