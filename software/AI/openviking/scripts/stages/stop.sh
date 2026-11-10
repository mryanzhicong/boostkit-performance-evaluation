#!/usr/bin/env bash
# Stop stage: stop the measured runtime and remove the private container.
#
# The stage is idempotent: every step tolerates an already stopped process and a
# container that never started, so the Framework can always call it after a
# failed build/start/test stage or in the standalone entry point.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/start.sh"

openviking_container_running() {
    openviking_configure_container
    [[ "$(docker inspect --format '{{.State.Running}}' "${OPENVIKING_CONTAINER_NAME}" 2>/dev/null)" == "true" ]]
}

stop_openviking_runtime() {
    local status=0
    if ! command -v docker >/dev/null 2>&1; then
        log_message "docker is unavailable; nothing to stop"
        return 0
    fi
    configure_runtime_paths || return $?
    if openviking_container_running; then
        stop_openviking_server || status=60
        openviking_run "pkill -f 'benchmark/mock_openai.py' || true" >/dev/null 2>&1 || true
    fi
    if ! remove_openviking_container; then
        log_message "ERROR: the private container could not be removed"
        status=60
    fi
    log_message "runtime stopped"
    return "${status}"
}
