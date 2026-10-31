#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_maven_runtime() {
    initialize_runtime || return $?
    export_java_env
    [[ -x "${MAVEN_BIN}" ]] || {
        log_message "ERROR: Maven launcher is unavailable: ${MAVEN_BIN}"
        return 40
    }
    [[ -x "${JDK_HOME}/bin/java" ]] || {
        log_message "ERROR: pinned JDK is unavailable: ${JDK_HOME}"
        return 40
    }
    local java_version
    java_version="$("${JDK_HOME}/bin/java" -version 2>&1 | awk -F'"' '/version/ {print $2; exit}')"
    if [[ "${java_version}" != "${JDK_SEMVER}"* ]]; then
        log_message "ERROR: expected Temurin ${JDK_SEMVER}, found ${java_version}"
        return 40
    fi
    if [[ ! -d "${M2_REPO}" ]]; then
        log_message "ERROR: private Maven repository is missing: ${M2_REPO}"
        return 40
    fi
    for scale in "${MAVEN_SCALES[@]}"; do
        [[ -f "${PROJECTS_DIR}/project-${scale}/pom.xml" ]] || {
            log_message "ERROR: generated project for scale ${scale} is missing"
            return 40
        }
    done
    [[ -f "${MAVEN_SRC_DIR}/pom.xml" ]] || {
        log_message "ERROR: upstream Maven sources are missing"
        return 40
    }
    log_message "Maven ${SOFTWARE_VERSION} runtime is ready on Temurin ${java_version}"
}
