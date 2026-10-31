#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# The optimized variant is reserved for a future tuning effort (for example a
# different production build profile or a different static generation strategy).
# It is not implemented yet, so it must fail loudly instead of silently running
# the base workload, and it must not write build_variant.json.
build_nextjs_optimized() {
    log_message "ERROR: the optimized Next.js build variant is not implemented"
    log_message "ERROR: this case only provides the base variant; measured results must not be attributed to an optimization"
    log_message "HINT: run with --variant base or PERF_VARIANT=base"
    return 30
}
