#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# The optimized variant is reserved for a future tuning effort (for example a
# pinned npm configuration profile or a link-strategy change).  It is not
# implemented yet, so it must fail loudly instead of silently running the base
# build, and it must not write build_variant.json.
build_npm_optimized() {
    log_message "ERROR: the optimized npm build variant is not implemented"
    log_message "ERROR: this case only provides the base variant; measured results must not be attributed to an optimization"
    log_message "HINT: run with --variant base or PERF_VARIANT=base"
    return 30
}
