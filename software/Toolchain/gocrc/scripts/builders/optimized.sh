#!/usr/bin/env bash
# Compatibility entry point for the `optimized` dropdown value.
#
# The case runs the same procedure on every architecture: the bootstrap Go release
# is installed only to compile the measured openEuler golang go1.24.6 toolchain
# from source.  The dropdown value only labels the result, and this file keeps
# dispatching with `variant=optimized` working (the workflow validates optimized
# inputs against the presence of this script).
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
source "${SCRIPT_DIR}/scripts/builders/base.sh"

build_gocrc_optimized() { build_gocrc_environment; }
