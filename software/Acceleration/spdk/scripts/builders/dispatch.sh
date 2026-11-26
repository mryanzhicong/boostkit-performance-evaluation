#!/usr/bin/env bash
# Build entry declared in case.yaml: select the variant and record the choice.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_spdk() {
    validate_variant || return $?
    case "${PERF_VARIANT}" in
        base)
            source "${SCRIPT_DIR}/scripts/builders/base.sh"
            build_spdk_base || return $?
            ;;
        optimized)
            source "${SCRIPT_DIR}/scripts/builders/optimized.sh"
            build_spdk_optimized || return $?
            ;;
    esac
    initialize_runtime || return $?
    printf '{"variant":"%s","parameters":{"variant":"%s","benchmark":"bdevperf","bdev":"Malloc","io_path":"SPDK userspace bdev stack"}}\n' \
        "${PERF_VARIANT}" "${PERF_VARIANT}" > "${RESULTS_DIR}/build_variant.json"
    log_message "recorded build variant ${PERF_VARIANT}"
}
