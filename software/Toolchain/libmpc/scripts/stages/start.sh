#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_mpc_runtime() {
    local output
    initialize_runtime || return $?
    check_libmpc_container || return $?
    libmpc_container_exec test -x "${MPC_BENCH_BIN}" || {
        log_message "ERROR: MPC benchmark harness is unavailable in the container: ${MPC_BENCH_BIN}"
        return 40
    }
    libmpc_container_exec test -f "${MPC_PREFIX}/include/mpc.h" || {
        log_message "ERROR: libmpc headers were not installed in the container: ${MPC_PREFIX}/include/mpc.h"
        return 40
    }
    output="$( libmpc_container_exec "${MPC_BENCH_BIN}" mpc_mul 256 2>&1 )" || {
        log_message "ERROR: MPC benchmark harness smoke run failed"
        return 40
    }
    printf '%s\n' "${output}" | while IFS= read -r line; do log_message "  ${line}"; done
    printf '%s\n' "${output}" | grep -Eq '^RESULT routine=mpc_mul precision=256 iterations=[1-9][0-9]* .*ops_per_second=[0-9]' || {
        log_message "ERROR: harness smoke run did not print a parseable mpc_mul result"
        return 40
    }
    log_message "MPC benchmark runtime is ready (GMP ${GMP_VERSION})"
}
