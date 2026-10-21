#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_sonic_cpp_runtime() {
    initialize_runtime || return $?
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log_message "ERROR: official sonic-cpp benchmark binary is unavailable: ${BENCHMARK_BIN}"
        return 40
    }
    log_message "sonic-cpp official benchmark runtime is ready"
}
