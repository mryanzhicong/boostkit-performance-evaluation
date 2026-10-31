#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_jenkins_runtime() {
    initialize_runtime || return $?
    export_java_env
    [[ -x "${JENKINS_JAVA}" ]] || {
        log_message "ERROR: pinned JDK is unavailable: ${JDK_HOME}"
        return 40
    }
    local java_version
    java_version="$("${JENKINS_JAVA}" -version 2>&1 | awk -F'"' '/version/ {print $2; exit}')"
    if [[ "${java_version}" != "${JDK_SEMVER}"* ]]; then
        log_message "ERROR: expected Temurin ${JDK_SEMVER}, found ${java_version}"
        return 40
    fi
    [[ -s "${JENKINS_WAR}" ]] || {
        log_message "ERROR: jenkins.war is missing: ${JENKINS_WAR}"
        return 40
    }
    [[ -f "${JENKINS_TEMPLATE_HOME}/config.xml" ]] || {
        log_message "ERROR: initialized JENKINS_HOME template is missing: ${JENKINS_TEMPLATE_HOME}"
        return 40
    }
    local war_version
    war_version="$("${JENKINS_JAVA}" -jar "${JENKINS_WAR}" --version 2>&1 | tr -d '[:space:]')"
    if [[ "${war_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: jenkins.war reports ${war_version}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    JENKINS_VERSION_STRING="${war_version}"
    log_message "Jenkins ${SOFTWARE_VERSION} runtime is ready on Temurin ${java_version}, controller port ${JENKINS_PORT}"
}
