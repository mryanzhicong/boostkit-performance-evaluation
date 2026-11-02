#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_ant_runtime() {
    initialize_runtime || return $?
    export_java_env
    [[ -x "${JDK_HOME}/bin/java" ]] || {
        log_message "ERROR: pinned JDK is unavailable: ${JDK_HOME}"
        return 40
    }
    [[ -x "${JDK_HOME}/bin/javac" ]] || {
        log_message "ERROR: pinned JDK has no javac: ${JDK_HOME}"
        return 40
    }
    [[ -x "${ANT_BIN}" ]] || {
        log_message "ERROR: Ant launcher is unavailable: ${ANT_BIN}"
        return 40
    }
    local java_version
    java_version="$("${JDK_HOME}/bin/java" -version 2>&1 | awk -F'"' '/version/ {print $2; exit}')"
    if [[ "${java_version}" != "${JDK_SEMVER}"* ]]; then
        log_message "ERROR: expected Temurin ${JDK_SEMVER}, found ${java_version}"
        return 40
    fi
    local scale
    for scale in "${ANT_JAR_SCALES[@]}"; do
        [[ -f "${PROJECTS_DIR}/project-${scale}/build.xml" ]] || {
            log_message "ERROR: generated Ant project is missing: project-${scale}"
            return 40
        }
    done
    log_message "Ant ${SOFTWARE_VERSION} runtime is ready on Temurin ${java_version}"
}
