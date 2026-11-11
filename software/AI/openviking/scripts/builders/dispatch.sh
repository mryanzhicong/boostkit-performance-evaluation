#!/usr/bin/env bash
# Build-stage dispatch: the adaptation provides one out-of-the-box procedure, so
# the ``base`` and ``optimized`` variants execute the same steps (the kit is
# never rebuilt or tuned).  The variant only labels the published evidence.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/base.sh"
source "$(dirname "${BASH_SOURCE[0]}")/optimized.sh"

build_openviking() {
    case "${PERF_VARIANT}" in
        base) build_openviking_base ;;
        optimized) build_openviking_optimized ;;
        *)
            log_message "ERROR: invalid build variant: ${PERF_VARIANT}"
            return 10
            ;;
    esac
}
