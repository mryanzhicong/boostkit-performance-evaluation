#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_lua_optimized() {
    log_message "ERROR: optimized build is not implemented for lua"
    log_message "the optimized variant must fail explicitly instead of falling back to base"
    return 30
}
