#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_lance() {
    configure_runtime_paths || return $?
    case "${PERF_VARIANT}" in
        base) source "${SCRIPT_DIR}/scripts/builders/base.sh"; build_lance_base || return $? ;;
        optimized) source "${SCRIPT_DIR}/scripts/builders/optimized.sh"; build_lance_optimized || return $? ;;
    esac
    printf '{"variant":"%s","parameters":{"variant":"%s"}}\n' \
        "${PERF_VARIANT}" "${PERF_VARIANT}" > "${RESULTS_DIR}/build_variant.json"
}
