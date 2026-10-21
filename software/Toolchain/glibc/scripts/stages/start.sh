#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_glibc_runtime() {
    initialize_runtime || return $?
    # Each framework stage starts a new shell and therefore inherits the
    # runner environment again.  Do not let host library search paths affect
    # the freshly built glibc benchtest tools.
    unset LD_LIBRARY_PATH
    if [[ "$(make --version | head -n 1)" != "GNU Make ${MAKE_VERSION}" ]]; then
        log_message "ERROR: private GNU Make ${MAKE_VERSION} is required for glibc 2.31 benchtests"
        return 40
    fi
    if [[ ! -x "${LDCONFIG_BIN}" ]]; then
        log_message "ERROR: glibc is not built; run the build stage first"
        return 40
    fi
    log_message "building glibc 2.31 memcpy and memcmp benchtests"
    if ! make -C "${SRC_DIR}/benchtests" objdir="${BUILD_DIR}" \
        "${BUILD_DIR}/benchtests/bench-timing-type" \
        "${BUILD_DIR}/benchtests/bench-memcpy" \
        "${BUILD_DIR}/benchtests/bench-memcmp" CXX=; then
        log_message "ERROR: glibc memcpy and memcmp benchtest build failed"
        return 40
    fi
    local bench_name
    for bench_name in "${GLIBC_BENCHMARKS[@]}"; do
        if [[ ! -x "${BUILD_DIR}/benchtests/${bench_name}" ]]; then
            log_message "ERROR: benchtest binary is missing: ${BUILD_DIR}/benchtests/${bench_name}"
            return 40
        fi
    done
    if ! TIMING_TYPE_OUTPUT="$("${BUILD_DIR}/benchtests/bench-timing-type")"; then
        log_message "ERROR: bench-timing-type is not runnable"
        return 40
    fi
    if [[ "${TIMING_TYPE_OUTPUT}" != "clock_gettime_ns" ]]; then
        log_message "ERROR: benchtests use unexpected timing backend: ${TIMING_TYPE_OUTPUT}"
        return 40
    fi
    log_message "benchtests report timing backend: ${TIMING_TYPE_OUTPUT}"
    log_message "glibc official benchtest runtime is ready"
}
