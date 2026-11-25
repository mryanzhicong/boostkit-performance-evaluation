#!/usr/bin/env bash
# Reserved optimized variant.
#
# The case deliberately ships only the pinned base build: both architectures
# must be measured with the same upstream configure flags and ``-O2 -DNDEBUG``,
# and no architecture-specific optimisation has been reviewed for this case.
# Selecting the optimized variant therefore fails the build stage with exit
# code 30, before any source is fetched and without writing build_variant.json
# or results.json.  It never falls back to the base build.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

build_apr_util_optimized() {
    fail_message "the optimized APR-util build variant is not implemented"
    fail_message "only PERF_VARIANT=base is supported; refusing to fall back to the base build"
    return 30
}
