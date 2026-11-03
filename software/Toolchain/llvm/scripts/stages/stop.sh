#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Every measured LLVM invocation is a short-lived child process, so removing this
# task's private container is enough to guarantee that nothing survives the test
# stage.  The stage also proves the container is really gone (a stale container
# would keep the work tree mounted and break the next run on the reused name) and
# clears the standalone marker if one is left.
stop_llvm_runtime() {
    initialize_runtime || return $?
    remove_llvm_container || return $?
    llvm_configure_container
    if docker container inspect "${LLVM_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: the managed container still exists after stop: ${LLVM_CONTAINER_NAME}"
        return 50
    fi
    local marker="${PERF_WORK_DIR}/running"
    if [[ -f "${marker}" ]]; then
        log_message "WARNING: a measured LLVM run left a marker behind: ${marker}"
        rm -f -- "${marker}"
    fi
    log_message "no measured LLVM process is still running (container ${LLVM_CONTAINER_NAME} removed)"
    return 0
}
