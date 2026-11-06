#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_php() {
    validate_variant || return $?
    case "${PERF_VARIANT}" in
        base)
            source "${SCRIPT_DIR}/scripts/builders/base.sh"
            build_php_base || return $?
            ;;
        optimized)
            source "${SCRIPT_DIR}/scripts/builders/optimized.sh"
            build_php_optimized || return $?
            ;;
    esac
    initialize_runtime || return $?
    printf '{"variant":"%s","parameters":{"variant":"%s","php_configure":"%s"}}\n' \
        "${PERF_VARIANT}" "${PERF_VARIANT}" "${PHP_CONFIGURE_SUMMARY:-}" \
        > "${RESULTS_DIR}/build_variant.json"
}
