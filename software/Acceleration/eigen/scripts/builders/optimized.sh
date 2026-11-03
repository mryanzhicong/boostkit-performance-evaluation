#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_eigen_optimized() {
    log_message "ERROR: optimized Eigen build is not implemented"
    log_message "the optimized variant must fail explicitly instead of falling back to base"
    return 30
}
