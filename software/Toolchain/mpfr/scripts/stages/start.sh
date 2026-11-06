#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_mpfr_runtime() {
    local output
    initialize_runtime || return $?
    check_mpfr_container || return $?
    mpfr_container_exec test -x "${MPFR_BENCH_BIN}" || {
        log_message "ERROR: MPFR benchmark harness is unavailable in the container: ${MPFR_BENCH_BIN}"
        return 40
    }
    mpfr_container_exec test -f "${MPFR_PREFIX}/include/mpfr.h" || {
        log_message "ERROR: MPFR headers were not installed in the container: ${MPFR_PREFIX}/include/mpfr.h"
        return 40
    }
    output="$( mpfr_container_exec "${MPFR_BENCH_BIN}" mpfr_mul 256 2>&1 )" || {
        log_message "ERROR: MPFR benchmark harness smoke run failed"
        return 40
    }
    printf '%s\n' "${output}" | while IFS= read -r line; do log_message "  ${line}"; done
    printf '%s\n' "${output}" | grep -Eq '^RESULT routine=mpfr_mul precision=256 iterations=[1-9][0-9]* .*ops_per_second=[0-9]' || {
        log_message "ERROR: harness smoke run did not print a parseable mpfr_mul result"
        return 40
    }
    log_message "MPFR benchmark runtime is ready (GMP ${GMP_VERSION})"
}
