#!/usr/bin/env bash
# Start stage: verify inside this task's private container that the JDK, the Ant
# launcher and the generated projects are all present and usable.  Ant is a
# command line tool, so "start" means "the measured workload is ready"; no
# long-running service is involved.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_ant_runtime() {
    initialize_runtime || return $?
    check_ant_container || return $?
    load_container_jdk

    ant_container_java_exec test -x "${JDK_HOME}/bin/java" || {
        log_message "ERROR: container JDK is unavailable: ${JDK_HOME}"
        return 40
    }
    ant_container_java_exec test -x "${JDK_HOME}/bin/javac" || {
        log_message "ERROR: container JDK has no javac: ${JDK_HOME}"
        return 40
    }
    ant_container_exec test -x "${ANT_BIN}" || {
        log_message "ERROR: Ant launcher is unavailable: ${ANT_BIN}"
        return 40
    }
    local java_version
    local java_banner
    java_banner="$(ant_container_java_exec java -version 2>&1)" || java_banner=""
    java_version="$(printf '%s\n' "${java_banner}" | awk -F'"' '/version/ {print $2; exit}')"
    if [[ "${java_version}" != "${JDK_MAJOR}."* ]]; then
        log_message "ERROR: expected container JDK ${JDK_MAJOR}.x, found ${java_version}"
        return 40
    fi
    local ant_version
    local ant_banner
    ant_banner="$(ant_container_java_exec "${ANT_BIN}" -version 2>&1)" || ant_banner=""
    ant_version="$(printf '%s\n' "${ant_banner}" | sed -n 's/^Apache Ant(TM) version \([^ ]*\).*/\1/p')"
    ant_version="${ant_version%%$'\n'*}"
    if [[ "${ant_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: expected Apache Ant ${SOFTWARE_VERSION}, found ${ant_version}"
        return 40
    fi
    local scale
    for scale in "${ANT_JAR_SCALES[@]}"; do
        ant_container_exec test -f "${PROJECTS_DIR}/project-${scale}/build.xml" || {
            log_message "ERROR: generated Ant project is missing: project-${scale}"
            return 40
        }
    done
    log_message "Ant ${SOFTWARE_VERSION} runtime is ready in ${ANT_CONTAINER_NAME} on JDK ${java_version}"
}
