#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_hbase() {
    case "${PERF_VARIANT}" in
        base)
            source "${CASE_DIR}/scripts/builders/base.sh"
            build_hbase_base || return $?
            ;;
        optimized)
            source "${CASE_DIR}/scripts/builders/optimized.sh"
            build_hbase_optimized || return $?
            ;;
        *) return 10 ;;
    esac
    printf '{"variant":"%s","parameters":{"variant":"%s"}}\n' \
        "${PERF_VARIANT}" "${PERF_VARIANT}" > "${RESULTS_DIR}/build_variant.json"
}
