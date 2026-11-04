#!/usr/bin/env bash
# Start stage: verify inside this task's private container that the JDK, the Scala
# compiler distribution, the generated compile projects and the precompiled run
# workloads are all present and usable.  This case measures short-lived CLI tools,
# so no service is started; "start" means "the measured workload is ready".
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_scala_runtime() {
    initialize_runtime || return $?
    check_scala_container || return $?
    load_container_jdk
    export_java_env
    local java_version
    java_version="$(java_version_string)" || java_version=""
    if [[ "${java_version}" != "${JDK_MAJOR}."* ]]; then
        log_message "ERROR: expected container JDK ${JDK_MAJOR}.x, found ${java_version:-<unknown>}"
        return 40
    fi
    scala_container_exec test -x "${SCALAC_BIN}" || {
        log_message "ERROR: Scala compiler is unavailable: ${SCALAC_BIN}"
        return 40
    }
    local scale workload
    for scale in "${SCALA_COMPILE_SCALES[@]}"; do
        scala_container_exec test -d "${PROJECTS_DIR}/project-${scale}/src/bench" || {
            log_message "ERROR: generated project for scale ${scale} is missing"
            return 40
        }
    done
    for workload in "${SCALA_RUN_WORKLOADS[@]}"; do
        scala_container_exec test -f "${SCALA_PROGRAMS_OUT}/${workload}/bench/Main.class" || {
            log_message "ERROR: precompiled workload is missing: ${workload}"
            return 40
        }
    done
    log_message "Scala ${SOFTWARE_VERSION} runtime is ready in ${SCALA_CONTAINER_NAME} (container JDK ${java_version})"
}
