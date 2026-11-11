#!/usr/bin/env bash
# Optimized variant: the adaptation intentionally does not define a tuned build.
# The upstream benchmark kit is executed exactly as shipped (no NUMA binding, no
# cpuset pinning, no compiler or runtime flags), so this variant repeats the base
# procedure and only labels the evidence differently.  This keeps the workflow's
# base/optimized comparison contract intact without inventing a non-out-of-the-box
# configuration.
source "$(dirname "${BASH_SOURCE[0]}")/base.sh"

build_openviking_optimized() {
    log_message "variant=optimized: no tuned build is defined for this case; running the out-of-the-box procedure"
    build_openviking_base
}
