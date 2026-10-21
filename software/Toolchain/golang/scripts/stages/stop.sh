#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_golang_runtime() {
    initialize_runtime || return $?
    configure_go_environment
    if [[ ! -e "${GO_RUNTIME_DIR}" ]]; then
        log_message "Go benchmark suite has no background service to stop"
        return
    fi
    if [[ "${GO_RUNTIME_DIR}" != "${GO_RUNTIME_ROOT}" ]]; then
        log_message "ERROR: refusing to clean unexpected Go runtime directory: ${GO_RUNTIME_DIR}"
        return 50
    fi
    if ! chmod -R u+w "${GO_RUNTIME_DIR}"; then
        log_message "ERROR: failed to make the private Go runtime directory writable for cleanup"
        return 50
    fi
    if ! rm -rf -- "${GO_RUNTIME_DIR}"; then
        log_message "ERROR: failed to remove the private Go runtime directory"
        return 50
    fi
    log_message "removed private Go runtime directory: ${GO_RUNTIME_DIR}"
}
