#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_torchvision() {
    configure_runtime_paths || return $?
    case "${PERF_VARIANT}" in
        base)
            source "${SCRIPT_DIR}/scripts/builders/base.sh"
            build_torchvision_base || return $?
            ;;
        optimized)
            source "${SCRIPT_DIR}/scripts/builders/optimized.sh"
            build_torchvision_optimized || return $?
            ;;
    esac
    initialize_runtime || return $?
    printf '{"variant":"%s","parameters":{"variant":"%s"}}\n' \
        "${PERF_VARIANT}" "${PERF_VARIANT}" > "${RESULTS_DIR}/build_variant.json"
}
