#!/usr/bin/env bash
# Framework entry point for the numpy build stage: selects the build variant.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_numpy() {
    validate_variant || return $?
    initialize_runtime || return $?
    case "${PERF_VARIANT}" in
        base)
            source "${SCRIPT_DIR}/scripts/builders/base.sh"
            build_numpy_base || return $?
            ;;
        optimized)
            source "${SCRIPT_DIR}/scripts/builders/optimized.sh"
            build_numpy_optimized || return $?
            ;;
    esac
    if [[ ! -s "${RESULTS_DIR}/build_variant.json" ]]; then
        log_message "ERROR: the build stage did not produce ${RESULTS_DIR}/build_variant.json"
        return 30
    fi
    log_message "build stage complete for numpy ${SOFTWARE_VERSION} (${PERF_VARIANT})"
}
