#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_jenkins_runtime() {
    # Every measured repetition starts its own controller process, waits for it
    # and terminates it inside the driver.  Stop only verifies that no stray
    # java process from this run still listens on the controller port.
    local stray=""
    if command -v pgrep >/dev/null 2>&1; then
        stray="$(pgrep -f "jenkins.war.*--httpPort=${JENKINS_PORT}" | tr '\n' ' ' || true)"
    fi
    if [[ -n "${stray}" ]]; then
        log_message "WARNING: controller process still alive on port ${JENKINS_PORT}: ${stray}"
        pkill -f "jenkins.war.*--httpPort=${JENKINS_PORT}" 2>/dev/null || true
    fi
    rm -rf -- "${PERF_WORK_DIR}/homes"
    log_message "Jenkins runtime stop completed"
    return 0
}
