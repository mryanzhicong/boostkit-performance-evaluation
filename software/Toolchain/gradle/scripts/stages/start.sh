#!/usr/bin/env bash
# Start stage: verify inside this task's private container that the JDK, the
# Gradle launcher, the shared Gradle user home and the pinned projects/samples are
# all present and usable.  Gradle always runs with --no-daemon, so no service is
# started; "start" means "the measured workload is ready".
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_gradle_runtime() {
    initialize_runtime || return 20
    validate_architecture || return 20
    check_gradle_container || return $?
    load_container_jdk

    local version
    version="$(gradle_version_string)" || version=""
    if [[ "${version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: expected Gradle ${SOFTWARE_VERSION}, got: ${version:-<unknown>}"
        return 20
    fi
    gradle_container_exec test -x "${GRADLE_BIN}" || {
        log_message "ERROR: Gradle launcher is not executable: ${GRADLE_BIN}"
        return 20
    }
    version="$(java_version_string)" || version=""
    if [[ "${version}" != "${JDK_MAJOR}."* ]]; then
        log_message "ERROR: expected container JDK ${JDK_MAJOR}.x, got: ${version:-<unknown>}"
        return 20
    fi
    gradle_container_exec test -d "${GRADLE_USER_HOME_DIR}" || {
        log_message "ERROR: shared Gradle user home is missing: ${GRADLE_USER_HOME_DIR}"
        return 20
    }
    if [[ ! -f "${PERF_WORK_DIR}/.gradle-home-warmed" ]]; then
        log_message "ERROR: shared Gradle user home was not warmed during the build stage"
        return 20
    fi

    local scale project
    for scale in "${GRADLE_SCALES[@]}"; do
        project="${PROJECTS_DIR}/project-${scale}"
        gradle_container_exec test -f "${project}/settings.gradle" || {
            log_message "ERROR: generated project is incomplete: ${project}"
            return 20
        }
        gradle_container_exec test -f "${project}/build.gradle" || {
            log_message "ERROR: generated project is incomplete: ${project}"
            return 20
        }
        gradle_container_exec test -f "${project}/.generated-classes" || {
            log_message "ERROR: generated project has no class-count marker: ${project}"
            return 20
        }
        if [[ "$(cat "${project}/.generated-classes")" != "${scale}" ]]; then
            log_message "ERROR: generated project class count mismatch: ${project}"
            return 20
        fi
    done

    local sample directory
    for sample in "${GRADLE_UPSTREAM_SAMPLES[@]}"; do
        directory="${PERF_WORK_DIR}/upstream-samples/$(printf '%s' "${sample}" | tr '/' '_')"
        gradle_container_exec test -f "${directory}/settings.gradle" || {
            log_message "ERROR: upstream sample project is missing: ${directory}"
            return 20
        }
    done
    log_message "Gradle ${SOFTWARE_VERSION} runtime is ready in ${GRADLE_CONTAINER_NAME} (container JDK ${version}, $(gradle_container_env_exec python3 -V 2>&1), shared user home warmed, upstream samples present)"
}
