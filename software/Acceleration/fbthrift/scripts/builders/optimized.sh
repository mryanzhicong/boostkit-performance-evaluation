#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# The wiki flow in this case only implements the upstream base build.  The
# optimized entry point fails loudly instead of silently falling back.
build_fbthrift_optimized() {
    log_message 'ERROR: the optimized variant is not implemented for fbthrift'
    return 30
}
