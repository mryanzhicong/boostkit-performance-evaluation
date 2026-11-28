#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Only the base variant is adapted today; the file exists so the dispatcher can
# keep the same shape as the other cases in this category.
build_libvirt_unixbench_optimized() {
    log 'ERROR: the optimized variant is not adapted for this case'
    return 10
}
