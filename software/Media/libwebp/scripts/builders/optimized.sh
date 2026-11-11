#!/usr/bin/env bash
# The optimized variant is intentionally not implemented: this case publishes the
# stock/open-box build only, and must fail loudly instead of silently measuring
# the baseline under the optimized label.

build_libwebp_optimized() {
    log_message "ERROR: the optimized build variant is not implemented for libwebp ${SOFTWARE_VERSION}"
    log_message "       this case publishes the stock open-box variant only; run with --variant base"
    return 10
}
