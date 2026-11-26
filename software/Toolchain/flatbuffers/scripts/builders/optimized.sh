#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

# The optimized variant is reserved for a future change (for example a
# different allocator or a PGO build).  Until it is implemented it must fail
# explicitly instead of silently falling back to the base build, so that a
# missing implementation can never be mistaken for a valid comparison point.
build_flatbuffers_optimized() {
    log_message "ERROR: optimized build is not implemented for flatbuffers"
    log_message "the optimized variant must fail explicitly instead of falling back to base"
    return 30
}
