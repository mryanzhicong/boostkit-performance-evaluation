#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# The optimized variant exists only to prove that CI fails when the
# performance matrix cannot produce samples; it must not publish a build
# variant or results.
build_jenkins_optimized() {
    log_message "optimized variant intentionally returns 30 without writing build_variant.json"
    return 30
}
