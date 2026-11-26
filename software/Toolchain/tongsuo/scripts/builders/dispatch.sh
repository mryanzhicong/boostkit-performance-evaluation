#!/usr/bin/env bash
# Dispatch the declared stage function to the selected build variant.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/base.sh"
source "$(dirname "${BASH_SOURCE[0]}")/optimized.sh"

build_tongsuo() {
    case "${PERF_VARIANT}" in
        base) build_tongsuo_base ;;
        optimized) build_tongsuo_optimized ;;
        *)
            log_message "ERROR: unsupported build variant: ${PERF_VARIANT}"
            return 10
            ;;
    esac
}
