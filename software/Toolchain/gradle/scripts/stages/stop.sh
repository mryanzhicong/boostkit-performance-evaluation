#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_gradle_runtime() {
    # Gradle always runs with --no-daemon: every measured invocation starts and
    # stops its own single-use daemon, so there is no background service to stop.
    log_message "Gradle runs with --no-daemon; nothing to stop"
    return 0
}
