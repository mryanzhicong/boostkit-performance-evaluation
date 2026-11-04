#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_scann() {
    case "${PERF_VARIANT}" in
        base)
            source "${SCRIPT_DIR}/scripts/builders/base.sh"
            build_scann_base || return $?
            ;;
        optimized)
            source "${SCRIPT_DIR}/scripts/builders/optimized.sh"
            build_scann_optimized || return $?
            ;;
        *) log 'ERROR: invalid build variant'; return 10 ;;
    esac
    printf '{"variant":"%s","parameters":{"variant":"%s"}}\n' \
        "${PERF_VARIANT}" "${PERF_VARIANT}" > "${RESULTS_DIR}/build_variant.json"
}
