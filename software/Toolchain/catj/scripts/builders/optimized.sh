#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_catj_optimized() {
    log_message "ERROR: the optimized catj variant is reserved; only the base variant is implemented"
    log_message "a reserved variant must fail instead of producing a misleading build_variant.json"
    return 30
}