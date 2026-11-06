#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_jemalloc_optimized() {
    jemalloc_log 'ERROR: optimized jemalloc build is not implemented'
    return 40
}
