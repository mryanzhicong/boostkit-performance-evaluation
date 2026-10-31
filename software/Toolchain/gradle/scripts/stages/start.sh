#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_gradle_runtime() {
    initialize_runtime || return 20
    validate_architecture || return 20

    local version
    version="$(gradle_version_string)" || version=""
    if [[ "${version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: expected Gradle ${SOFTWARE_VERSION}, got: ${version:-<unknown>}"
        return 20
    fi
    if [[ ! -x "${GRADLE_BIN}" ]]; then
        log_message "ERROR: Gradle launcher is not executable: ${GRADLE_BIN}"
        return 20
    fi
    version="$(java_version_string)" || version=""
    if [[ "${version}" != "${JDK_SEMVER}"* ]]; then
        log_message "ERROR: expected Temurin JDK ${JDK_SEMVER}, got: ${version:-<unknown>}"
        return 20
    fi
    if [[ ! -d "${GRADLE_USER_HOME_DIR}" ]]; then
        log_message "ERROR: shared Gradle user home is missing: ${GRADLE_USER_HOME_DIR}"
        return 20
    fi
    if [[ ! -f "${PERF_WORK_DIR}/.gradle-home-warmed" ]]; then
        log_message "ERROR: shared Gradle user home was not warmed during the build stage"
        return 20
    fi

    local scale project
    for scale in "${GRADLE_SCALES[@]}"; do
        project="${PROJECTS_DIR}/project-${scale}"
        if [[ ! -f "${project}/settings.gradle" || ! -f "${project}/build.gradle" ]]; then
            log_message "ERROR: generated project is incomplete: ${project}"
            return 20
        fi
        if [[ ! -f "${project}/.generated-classes" ]]; then
            log_message "ERROR: generated project has no class-count marker: ${project}"
            return 20
        fi
        if [[ "$(cat "${project}/.generated-classes")" != "${scale}" ]]; then
            log_message "ERROR: generated project class count mismatch: ${project}"
            return 20
        fi
    done

    local sample directory
    for sample in "${GRADLE_UPSTREAM_SAMPLES[@]}"; do
        directory="${PERF_WORK_DIR}/upstream-samples/$(printf '%s' "${sample}" | tr '/' '_')"
        if [[ ! -f "${directory}/settings.gradle" ]]; then
            log_message "ERROR: upstream sample project is missing: ${directory}"
            return 20
        fi
    done
    log_message "Gradle ${SOFTWARE_VERSION} runtime is ready (Temurin JDK ${JDK_SEMVER}, $(python3 -V 2>&1), shared user home warmed, upstream samples present)"
}
