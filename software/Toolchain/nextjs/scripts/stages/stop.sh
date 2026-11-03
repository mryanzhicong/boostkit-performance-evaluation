#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Stop stage: every measured process runs inside this task's private container, so
# removing that container stops the whole process tree at once.  The stage then
# proves that the container is really gone; a leftover container would keep the
# measured server alive and silently make the next run measure the wrong process,
# so it is a stop failure (exit code 50) instead of a warning.
stop_nextjs_runtime() {
    initialize_runtime || return $?
    remove_nextjs_container || return $?
    nextjs_configure_container
    if docker container inspect "${NEXTJS_CONTAINER_NAME}" >/dev/null 2>&1; then
        fail_message "the managed container still exists after stop: ${NEXTJS_CONTAINER_NAME}"
        return 50
    fi
    log_message "no measured Next.js process is still running (container ${NEXTJS_CONTAINER_NAME} removed)"
    return 0
}
