#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

build_flatbuffers() {
    validate_variant || return $?
    case "${PERF_VARIANT}" in
        base)
            # shellcheck source=builders/base.sh
            source "${SCRIPT_DIR}/scripts/builders/base.sh"
            build_flatbuffers_base || return $?
            ;;
        optimized)
            # shellcheck source=builders/optimized.sh
            source "${SCRIPT_DIR}/scripts/builders/optimized.sh"
            build_flatbuffers_optimized || return $?
            ;;
        *)
            log_message "ERROR: invalid build variant: ${PERF_VARIANT}"
            return 10
            ;;
    esac
    initialize_runtime || return $?
    printf '{"variant":"%s","parameters":{"variant":"%s"}}\n' \
        "${PERF_VARIANT}" "${PERF_VARIANT}" > "${RESULTS_DIR}/build_variant.json"
}
