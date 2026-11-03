#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_scala_optimized() {
    log_message "ERROR: optimized build is not implemented for Scala"
    log_message "the optimized variant must fail explicitly instead of falling back to base"
    return 30
}
