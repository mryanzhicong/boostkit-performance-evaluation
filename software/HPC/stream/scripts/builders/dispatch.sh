#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_stream() {
    configure_runtime_paths || return $?
    case "${PERF_VARIANT}" in
        base)
            source "${SCRIPT_DIR}/scripts/builders/base.sh"
            build_stream_base || return $?
            ;;
        optimized)
            source "${SCRIPT_DIR}/scripts/builders/optimized.sh"
            build_stream_optimized || return $?
            ;;
    esac
    printf '{"variant":"%s","parameters":{"variant":"%s","array_size":%s,"ntimes":%s}}\n' \
        "${PERF_VARIANT}" "${PERF_VARIANT}" "${STREAM_ARRAY_SIZE}" "${STREAM_NTIMES}" \
        > "${RESULTS_DIR}/build_variant.json"
}
