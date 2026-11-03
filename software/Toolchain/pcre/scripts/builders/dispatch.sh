#!/usr/bin/env bash
# Dispatch the PCRE build stage to exactly one variant implementation.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_pcre() {
    validate_variant || return $?
    case "${PERF_VARIANT}" in
        base)
            source "${SCRIPT_DIR}/scripts/builders/base.sh"
            build_pcre_base || return $?
            ;;
        optimized)
            source "${SCRIPT_DIR}/scripts/builders/optimized.sh"
            build_pcre_optimized || return $?
            ;;
    esac
    initialize_runtime || return $?
    printf '{"variant":"%s","parameters":{"variant":"%s"}}\n' \
        "${PERF_VARIANT}" "${PERF_VARIANT}" > "${RESULTS_DIR}/build_variant.json"
    return 0
}
