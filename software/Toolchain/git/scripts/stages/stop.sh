#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# The whole build and benchmark ran inside this task's private container.
# stop removes only that container (verified by its ownership label) and is
# safe to call repeatedly; the host work and result directories are left for
# the framework or the standalone entry to clean.
stop_git_runtime() {
    initialize_runtime || return $?
    if ! command -v docker >/dev/null 2>&1; then
        log_message 'no Docker daemon; no managed container to stop'
        return 0
    fi
    remove_git_container || return $?
    log_message 'managed Git container stopped'
}
