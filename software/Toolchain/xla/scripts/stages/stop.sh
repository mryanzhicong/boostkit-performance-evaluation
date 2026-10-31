#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Every benchmark runs as a child process of the test stage and has already
# exited. No service is started, so stop is a deliberate no-op that is safe
# on both success and failure paths; the private work directory is removed
# by the framework or by the standalone entry.
stop_xla_runtime() {
    initialize_runtime || return $?
    log_message 'no service to stop for this task'
}
