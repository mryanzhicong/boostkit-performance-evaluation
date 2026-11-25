#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Every measured React process runs inside this task's private container, so
# removing that container stops the whole process tree at once.  The stage then
# proves that the container is really gone; leaving it behind would keep the
# workspace mounted and would make the next run fail on a stale container name, so
# it is a stop failure (exit code 50) instead of a warning.
stop_react_runtime() {
    initialize_runtime || return $?
    remove_react_container || return $?
    react_configure_container
    if docker container inspect "${REACT_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: the managed container still exists after stop: ${REACT_CONTAINER_NAME}"
        return 50
    fi
    log_message "no measured React process is still running (container ${REACT_CONTAINER_NAME} removed)"
    return 0
}
