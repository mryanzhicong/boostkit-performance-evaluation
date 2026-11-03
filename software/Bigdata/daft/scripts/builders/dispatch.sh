#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_daft() {
    validate_variant || return $?
    case "${PERF_VARIANT}" in
        base) source "${SCRIPT_DIR}/scripts/builders/base.sh"; build_daft_base || return $? ;;
        optimized) source "${SCRIPT_DIR}/scripts/builders/optimized.sh"; build_daft_optimized || return $? ;;
    esac
    printf '{"variant":"%s","parameters":{"variant":"%s"}}\n' \
        "${PERF_VARIANT}" "${PERF_VARIANT}" > "${RESULTS_DIR}/build_variant.json"
}
