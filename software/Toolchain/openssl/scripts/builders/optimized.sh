#!/usr/bin/env bash
# The optimized variant would need a BoostKit patch on top of upstream
# openssl-4.1.0; no such reference implementation exists, so this case only
# measures the unmodified upstream release and fails explicitly instead of
# silently falling back to the base build.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_openssl_optimized() {
    log_message 'ERROR: the optimized variant is not implemented for openssl 4.1.0'
    log_message 'BoostKit does not publish an optimized OpenSSL build; this case measures the unmodified upstream release only'
    log_message 'rerun with --variant base (or PERF_VARIANT=base) to measure the unmodified upstream release'
    return 30
}
