#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_jenkins_runtime() {
    # Service first, container second: every measured repetition starts its own
    # controller process and the driver terminates it, so stop only reaps a
    # controller left behind for this run's derived port (inside the container,
    # which is the definite kill for anything still alive), then removes this run's
    # private container.  The removal is idempotent and never touches a container
    # that belongs to another run.
    initialize_runtime || return $?
    stop_stray_controllers_in_container || return 0
    rm -rf -- "${PERF_WORK_DIR}/homes"
    remove_jenkins_container || return $?
    log_message "Jenkins runtime stop completed (controller stopped, private container removed)"
    return 0
}

stop_stray_controllers_in_container() {
    jenkins_container_exec test -x "${JDK_HOME}/bin/java" >/dev/null 2>&1 || return 0
    jenkins_container_exec pgrep -f "jenkins.war.*--httpPort=${JENKINS_PORT}" >/dev/null 2>&1 || return 0
    log_message "stopping stray controller process(es) on port ${JENKINS_PORT} inside the private container"
    jenkins_container_exec pkill -TERM -f "jenkins.war.*--httpPort=${JENKINS_PORT}" 2>/dev/null || true
    sleep 2
    jenkins_container_exec pkill -KILL -f "jenkins.war.*--httpPort=${JENKINS_PORT}" 2>/dev/null || true
    return 0
}
