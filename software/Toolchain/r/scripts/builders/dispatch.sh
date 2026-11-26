#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/base.sh"

build_r() {
    validate_variant || return $?
    if [[ "${PERF_VARIANT}" == "optimized" ]]; then
        log_message "ERROR: optimized build is not implemented for r"
        log_message "the optimized variant must fail explicitly instead of falling back to base"
        return 30
    fi
    initialize_runtime || return $?
    build_r_base || return $?
    build_variant_marker base "$(build_config_json)" || return $?
    log_message "build variant written: ${RESULTS_DIR}/build_variant.json"
}
