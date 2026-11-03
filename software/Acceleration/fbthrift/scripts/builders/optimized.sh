#!/usr/bin/env bash
# Optimized variant entry point.
#
# The optimized build is not implemented yet: it must fail explicitly and must
# not fall back to the base build or write build_variant.json.  A future
# optimized variant would add host-tuned flags (for example
# -march=armv8-a+crypto on Kunpeng aarch64 or -mavx2 on x86_64) and a tuned
# allocator, and must be validated as its own from-scratch build.
build_fbthrift_optimized() {
    log_message "ERROR: optimized fbthrift build is not implemented yet"
    return 30
}
