#!/usr/bin/env bash
# The optimized variant is intentionally not implemented: this case publishes the
# stock/open-box build only and must fail loudly instead of mislabelling data.

build_opencv_optimized() {
    log_message "ERROR: the optimized build variant is not implemented for OpenCV ${SOFTWARE_VERSION}"
    log_message "       this case publishes the stock open-box variant only; run with --variant base"
    return 10
}
