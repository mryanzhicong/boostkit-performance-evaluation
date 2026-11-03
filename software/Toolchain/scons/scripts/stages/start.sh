#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_scons_runtime() {
    initialize_runtime || return $?
    check_scons_container || return $?
    [[ -f "${SCONS_ENTRY}" ]] || {
        log_message "ERROR: SCons launcher is unavailable: ${SCONS_ENTRY}"
        return 40
    }
    [[ -d "${SCONS_HOME}/SCons" ]] || {
        log_message "ERROR: SCons package is unavailable under ${SCONS_HOME}"
        return 40
    }
    [[ -f "${SCONS_HOME}/bench/bench.py" ]] || {
        log_message "ERROR: upstream bench harness is unavailable: ${SCONS_HOME}/bench/bench.py"
        return 40
    }
    local script
    for script in "${SCONS_BENCH_SCRIPTS[@]}"; do
        [[ -f "${SCONS_HOME}/bench/${script}" ]] || {
            log_message "ERROR: upstream bench script is missing: ${script}"
            return 40
        }
    done
    [[ -f "${PROJECT_DIR}/SConstruct" ]] || {
        log_message "ERROR: generated C project is missing: ${PROJECT_DIR}"
        return 40
    }
    local sources
    sources="$(find "${PROJECT_DIR}/src" -name '*.c' | wc -l)"
    if [[ "${sources}" != "${SCONS_C_FILE_COUNT}" ]]; then
        log_message "ERROR: generated project has ${sources} sources, expected ${SCONS_C_FILE_COUNT}"
        return 40
    fi
    scons_container_exec sh -c 'command -v cc >/dev/null 2>&1' || {
        log_message "ERROR: no C compiler (cc) is available in the container"
        return 40
    }
    scons_container_exec sh -c 'command -v python3 >/dev/null 2>&1' || {
        log_message "ERROR: python3 is unavailable in the container"
        return 40
    }
    log_message "SCons ${SOFTWARE_VERSION} runtime is ready ($(scons_container_exec python3 --version 2>&1))"
}
