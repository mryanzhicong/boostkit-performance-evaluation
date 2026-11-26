#!/usr/bin/env bash
# The optimized SPDK build is intentionally not implemented yet: selecting it
# must fail loudly (exit 30) instead of silently running the base build.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_spdk_optimized() {
    log_message "ERROR: optimized SPDK build is not implemented for version ${SOFTWARE_VERSION}"
    log_message "ERROR: the base build and the optimized build must not be mixed"
    return 30
}
