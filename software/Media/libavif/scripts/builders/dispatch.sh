#!/usr/bin/env bash
# Dispatch the declared stage function to the selected build variant.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/base.sh"
source "$(dirname "${BASH_SOURCE[0]}")/optimized.sh"

build_libavif() {
    case "${PERF_VARIANT}" in
        base) build_libavif_base ;;
        optimized) build_libavif_optimized ;;
        *)
            log_message "ERROR: unsupported build variant: ${PERF_VARIANT}"
            return 10
            ;;
    esac
}
