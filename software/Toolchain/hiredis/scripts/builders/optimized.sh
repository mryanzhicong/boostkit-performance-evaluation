#!/usr/bin/env bash
# Optimized variant placeholder.
#
# The optimized hiredis build is not implemented yet.  The function logs why,
# returns the documented build-stage exit code (30) and writes nothing, so the
# framework records a failed build for the requested variant instead of silently
# producing a base measurement.
set -euo pipefail

build_hiredis_optimized() {
    fail_message "the optimized hiredis build variant is not implemented"
    return 30
}
