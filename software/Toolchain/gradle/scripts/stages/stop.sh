#!/usr/bin/env bash
# Stop stage: Gradle always runs with --no-daemon, so there is no daemon to keep
# alive, but the stage still removes this task's private container (which also
# terminates every process the container owns) and is idempotent.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_gradle_runtime() {
    initialize_runtime || return $?
    remove_gradle_container || return $?
    rm -rf -- "${TMPDIR}" 2>/dev/null || true
    mkdir -p "${TMPDIR}"
    log_message "Gradle runs with --no-daemon; private container removed, transient files cleaned"
    return 0
}
