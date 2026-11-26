#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_mysql() {
    validate_variant || return $?
    case "${PERF_VARIANT}" in
        base)
            source "${SCRIPT_DIR}/scripts/builders/base.sh"
            build_mysql_base || return $?
            ;;
        optimized)
            source "${SCRIPT_DIR}/scripts/builders/optimized.sh"
            build_mysql_optimized || return $?
            ;;
    esac
    initialize_runtime || return $?
    if [[ "${PERF_VARIANT}" == optimized ]]; then
        # The optimized builder records the artifact it deployed itself; the
        # dispatch layer only verifies that the provenance file exists.
        if [[ ! -s "${RESULTS_DIR}/build_variant.json" ]]; then
            log_message "ERROR: optimized build did not record ${RESULTS_DIR}/build_variant.json"
            return 40
        fi
        log_message "build variant recorded in ${RESULTS_DIR}/build_variant.json"
        return 0
    fi
    printf '{"variant":"%s","parameters":{"variant":"%s"}}\n' \
        "${PERF_VARIANT}" "${PERF_VARIANT}" > "${RESULTS_DIR}/build_variant.json"
}
