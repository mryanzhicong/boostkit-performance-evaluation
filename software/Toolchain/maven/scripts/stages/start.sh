#!/usr/bin/env bash
# Start stage: verify inside this task's private container that the JDK, the Maven
# launcher, the private repository and the pinned projects/sources are all present
# and usable.  Maven is a short-lived command-line build tool, so no service is
# started; "start" means "the measured workload is ready".
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_maven_runtime() {
    initialize_runtime || return $?
    check_maven_container || return $?
    load_container_jdk
    export_java_env
    maven_container_exec test -x "${MAVEN_BIN}" || {
        log_message "ERROR: Maven launcher is unavailable: ${MAVEN_BIN}"
        return 40
    }
    local java_version
    java_version="$(java_version_string)" || java_version=""
    if [[ "${java_version}" != "${JDK_MAJOR}."* ]]; then
        log_message "ERROR: expected container JDK ${JDK_MAJOR}.x, found ${java_version:-<unknown>}"
        return 40
    fi
    maven_container_exec test -d "${M2_REPO}" || {
        log_message "ERROR: private Maven repository is missing: ${M2_REPO}"
        return 40
    }
    local scale
    for scale in "${MAVEN_SCALES[@]}"; do
        maven_container_exec test -f "${PROJECTS_DIR}/project-${scale}/pom.xml" || {
            log_message "ERROR: generated project for scale ${scale} is missing"
            return 40
        }
    done
    maven_container_exec test -f "${MAVEN_SRC_DIR}/pom.xml" || {
        log_message "ERROR: upstream Maven sources are missing"
        return 40
    }
    log_message "Maven ${SOFTWARE_VERSION} runtime is ready in ${MAVEN_CONTAINER_NAME} (container JDK ${java_version})"
}
