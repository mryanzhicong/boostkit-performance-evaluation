#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_react() {
    validate_variant || return $?
    # The framework invokes only this function, so the runtime layout (results
    # directory, work directory, pinned archive selection, PATH) must be resolved
    # here instead of relying on a standalone entry point.
    initialize_runtime || return 30
    case "${PERF_VARIANT}" in
        base)
            source "${SCRIPT_DIR}/scripts/builders/base.sh"
            build_react_base || return $?
            ;;
        optimized)
            source "${SCRIPT_DIR}/scripts/builders/optimized.sh"
            build_react_optimized || return $?
            ;;
        *)
            log_message "ERROR: unsupported variant: ${PERF_VARIANT}"
            return 10
            ;;
    esac
    if ! printf '{"variant": "%s", "software": "%s", "version": "%s"}\n' \
        "${PERF_VARIANT}" "${SOFTWARE_NAME}" "${SOFTWARE_VERSION}" \
        > "${RESULTS_DIR}/build_variant.json"; then
        log_message "ERROR: failed to write ${RESULTS_DIR}/build_variant.json"
        return 30
    fi
    log_message "build variant: ${PERF_VARIANT}"
}
