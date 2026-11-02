#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_catj() {
    validate_variant || return $?
    case "${PERF_VARIANT}" in
        base)
            source "${SCRIPT_DIR}/scripts/builders/base.sh"
            build_catj_base || return $?
            ;;
        optimized)
            source "${SCRIPT_DIR}/scripts/builders/optimized.sh"
            build_catj_optimized || return $?
            ;;
    esac
    initialize_runtime || return $?
    if [[ ! -s "${RESULTS_DIR}/build_variant.json" ]]; then
        log_message "ERROR: build variant metadata was not written"
        return 30
    fi
}