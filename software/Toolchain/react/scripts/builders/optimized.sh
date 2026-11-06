#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# The optimized variant is reserved for a future, separately reviewed build.
# It must fail loudly and must never fall back to the base build: a silent
# fallback would label unoptimized numbers as optimized results.
build_react_optimized() {
    log_message "ERROR: optimized build is not implemented for ${SOFTWARE_NAME}"
    log_message "the optimized variant must fail explicitly instead of falling back to base"
    return 30
}
