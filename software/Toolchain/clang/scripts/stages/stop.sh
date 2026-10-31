#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Clang runs as plain child processes of the test stage and has already
# exited. No service is started, so stop is a deliberate no-op that stays
# safe on success and failure paths; the private work directory is removed
# by the framework or by the standalone entry.
stop_clang_runtime() {
    initialize_runtime || return $?
    log_message 'no service to stop for this task'
}
