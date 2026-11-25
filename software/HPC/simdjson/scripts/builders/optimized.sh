#!/usr/bin/env bash
# The optimized variant needs the boostkit SVE2 patch on top of upstream
# c2f25ab; this case only adapts the unmodified upstream release, so the
# variant fails explicitly instead of silently falling back to the base build.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_simdjson_optimized() {
    log_message 'ERROR: the optimized variant is not implemented for simdjson 4.6.11'
    log_message 'upstream 4.6.11 ships NEON/AVX kernels only; an SVE2 comparison requires the boostkit kunpeng_opti_sve2 patch, which this case does not apply'
    log_message 'rerun with --variant base (or PERF_VARIANT=base) to measure the unmodified upstream release'
    return 30
}
