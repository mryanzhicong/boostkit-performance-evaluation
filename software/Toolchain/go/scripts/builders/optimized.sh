#!/usr/bin/env bash
# Compatibility entry point for the `optimized` dropdown value.
#
# The case runs the same unified procedure on every architecture: the official
# Go release is installed and the openEuler golang go1.24.6 toolchain is built
# from source, so both measurements always exist in one run.  The dropdown value
# only labels the result, and this file keeps dispatching with
# `variant=optimized` working (the workflow validates optimized inputs against
# the presence of this script).
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
source "${SCRIPT_DIR}/scripts/builders/base.sh"

build_go_optimized() { build_go_environment; }
