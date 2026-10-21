#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_sonic_go_runtime() {
    initialize_runtime || return $?
    verify_go_toolchain || return $?
    if [[ ! -f "${TOOLCHAIN_DIR}/toolchain_meta.json" ]]; then
        log_message "ERROR: toolchain metadata is unavailable: ${TOOLCHAIN_DIR}/toolchain_meta.json"
        return 40
    fi
    if [[ ! -f "${SOURCE_DIR}/go.mod" || ! -d "${SOURCE_DIR}/internal/native" ]]; then
        log_message "ERROR: Sonic source tree is unavailable: ${SOURCE_DIR}"
        return 40
    fi
    if [[ ! -f "${SCRIPT_DIR}/scripts/go/sonic_bench.sh" ]]; then
        log_message "ERROR: sonic benchmark script is unavailable"
        return 40
    fi
    log_message "Sonic benchmark runtime is ready (toolchain: ${TOOLCHAIN_TARGET}, go${GO_SRC_VERSION})"
}
