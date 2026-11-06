#!/usr/bin/env bash
# The optimized build variant is deliberately not implemented yet.
#
# This case adapts the *open-box* (pre-optimization) measurement defined by the
# boostkit benchmark guide: the unmodified NumPy 2.4.3 import at commit
# 289c872f.  The optimized variant would have to measure the Kunpeng-optimized
# NumPy from the boostkit main branch (different source, different baseline
# data), which is a separate case; silently building the baseline again under an
# `optimized` label would publish misleading numbers.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_numpy_optimized() {
    log_message "ERROR: the optimized numpy variant is not supported by this case; dispatch with variant=base"
    return 10
}
