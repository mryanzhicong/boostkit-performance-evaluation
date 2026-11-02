#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_gmp_runtime() {
    local output
    initialize_runtime || return $?
    [[ -x "${GMP_SPEED_BIN}" ]] || {
        log_message "ERROR: upstream tune/speed is unavailable: ${GMP_SPEED_BIN}"
        return 40
    }
    output="$( cd "${GMP_SOURCE_DIR}/tune" && ./speed -s 512 mpn_mul_n 2>&1 )" || {
        log_message "ERROR: tune/speed smoke run failed"
        return 40
    }
    printf '%s\n' "${output}" | while IFS= read -r line; do log_message "  ${line}"; done
    printf '%s\n' "${output}" | grep -Eq '^[[:space:]]*512[[:space:]]+[0-9.eE+-]+[[:space:]]*$' || {
        log_message "ERROR: tune/speed smoke run did not print a parseable 512-limb result"
        return 40
    }
    log_message "GMP tune/speed benchmark runtime is ready"
}
