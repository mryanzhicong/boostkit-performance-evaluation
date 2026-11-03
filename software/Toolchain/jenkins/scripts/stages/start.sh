#!/usr/bin/env bash
# Start stage: verify inside this task's private container that the JDK, the
# jenkins.war and the one-time JENKINS_HOME template are usable.  The controller
# itself is started and stopped per measured sample by the driver, so "start"
# means "the service workload is ready", not "a service is running".
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_jenkins_runtime() {
    initialize_runtime || return $?
    check_jenkins_container || return $?
    load_container_jdk
    export_java_env
    jenkins_container_exec test -x "${JENKINS_JAVA}" || {
        log_message "ERROR: container JDK java is unavailable: ${JENKINS_JAVA}"
        return 40
    }
    local java_version
    java_version="$(java_version_string)" || java_version=""
    if [[ "${java_version}" != "${JDK_MAJOR}."* ]]; then
        log_message "ERROR: expected container JDK ${JDK_MAJOR}.x, found ${java_version:-<unknown>}"
        return 40
    fi
    jenkins_container_exec test -s "${JENKINS_WAR}" || {
        log_message "ERROR: jenkins.war is missing: ${JENKINS_WAR}"
        return 40
    }
    jenkins_container_exec test -f "${JENKINS_TEMPLATE_HOME}/config.xml" || {
        log_message "ERROR: initialized JENKINS_HOME template is missing: ${JENKINS_TEMPLATE_HOME}"
        return 40
    }
    local war_version
    war_version="$(jenkins_container_env_exec timeout --kill-after=5 \
        "${JENKINS_VERSION_PROBE_TIMEOUT_SECONDS}" \
        "${JENKINS_JAVA}" -jar "${JENKINS_WAR}" --version 2>&1 | tr -d '[:space:]')" || {
        log_message "ERROR: the jenkins.war --version probe failed or exceeded ${JENKINS_VERSION_PROBE_TIMEOUT_SECONDS}s"
        return 40
    }
    if [[ "${war_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: jenkins.war reports ${war_version}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    JENKINS_VERSION_STRING="${war_version}"
    log_message "Jenkins ${SOFTWARE_VERSION} runtime is ready in ${JENKINS_CONTAINER_NAME} (container JDK ${java_version}), controller port ${JENKINS_PORT}"
}
