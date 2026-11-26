#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_cubesandbox_optimized() {
    log 'ERROR: the optimized CubeSandbox profile is not implemented'
    log 'the case measures the stock upstream deployment only; record a separate'
    log 'adaptation before claiming an optimized variant'
    return 40
}
