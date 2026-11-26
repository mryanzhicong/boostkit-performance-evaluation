#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_e2b_optimized() {
    log 'ERROR: the optimized E2B profile is not implemented'
    log 'the case measures the stock vendor deployment only; record a separate'
    log 'adaptation before claiming an optimized variant'
    return 40
}
