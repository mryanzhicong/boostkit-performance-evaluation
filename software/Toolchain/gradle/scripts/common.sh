#!/usr/bin/env bash
set -euo pipefail

# Re-sourcing this file must not reset values that configure_runtime_paths already
# computed (dispatch.sh, base.sh and the stage scripts each source it).
if [[ -n "${GRADLE_COMMON_SOURCED:-}" ]]; then
    return 0
fi
GRADLE_COMMON_SOURCED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SOFTWARE_NAME="gradle"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-9.8.2}"
CATEGORY="Toolchain"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

GRADLE_VERSION="${SOFTWARE_VERSION}"
GRADLE_ZIP_NAME="gradle-${GRADLE_VERSION}-bin.zip"
# Official Gradle distribution digest (the checksum published next to the
# distribution on services.gradle.org and mirrored by the download mirrors).
GRADLE_ZIP_SHA256="21bd5da2de49b642904077f38c0efdc7778e92b3ed0889392dca61b97e389607"
GRADLE_ZIP_URL_PRIMARY="https://repo.huaweicloud.com/gradle/${GRADLE_ZIP_NAME}"
GRADLE_ZIP_URL_SECONDARY="https://mirrors.cloud.tencent.com/gradle/${GRADLE_ZIP_NAME}"
GRADLE_ZIP_URL_OFFICIAL="https://services.gradle.org/distributions/${GRADLE_ZIP_NAME}"

# Pinned Gradle source release, used as the upstream multi-module engineering load.
GRADLE_SRC_NAME="gradle-${GRADLE_VERSION}-source.tar.gz"
GRADLE_SRC_SHA256="54b41c997ff95f61e74ed257e02012ebbc855b3c4c2637837e744a82595f6d8a"
GRADLE_SRC_URL="https://codeload.github.com/gradle/gradle/tar.gz/refs/tags/v${GRADLE_VERSION}"
GRADLE_SRC_URL_FALLBACK="https://gh-proxy.com/${GRADLE_SRC_URL}"

# Upstream sample projects from the pinned source release.  They are part of
# Gradle's own documentation/integration sample suite, contain real Java sources
# and multi-module layouts (library + annotation processor + consumer), require
# no external Maven dependency, and build without network access once the shared
# Gradle user home has been warmed.
GRADLE_UPSTREAM_SCENARIO="upstream_multiproject_build"
GRADLE_UPSTREAM_SAMPLES=(
    "platforms/documentation/docs/src/snippets/integration-tests/java/incrementalAnnotationProcessing/groovy"
    "platforms/documentation/docs/src/snippets/reference/platforms/jvm/incrementalAnnotationProcessing/groovy"
)
# Child processes (the upstream batch runner, the result parser) cannot read a bash
# array, so the same fixed list is also exposed as a newline separated scalar.
GRADLE_UPSTREAM_SAMPLE_LIST="$(printf '%s\n' "${GRADLE_UPSTREAM_SAMPLES[@]}")"

# Pinned JDK: Eclipse Temurin 21.0.13+9 (the same runtime used by the Maven case).
JDK_RELEASE="21.0.13+9"
JDK_SEMVER="21.0.13"
JDK_X64_NAME="OpenJDK21U-jdk_x64_linux_hotspot_21.0.13_9.tar.gz"
JDK_X64_SHA256="d7f5d5cf865a2902b70ff549b97586a7d3f234e016f041ab447ea740c7d66d1c"
JDK_ARM64_NAME="OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.13_9.tar.gz"
JDK_ARM64_SHA256="e3522e707fc7dbe2a72c30746b1e7068301a0213ecd213d4491f35a14eb55578"
JDK_BASE_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.13%2B9"

GRADLE_SCALES=(100 1000 10000)
GRADLE_MATRIX_TASKS=(clean_build incremental_build noop_build)
GRADLE_REPS="${PERF_REPS:-5}"
GRADLE_OFFLINE_DIR="${PERF_GRADLE_OFFLINE_DIR:-/home/runner/software/gradle}"

GRADLE_HOME=""
GRADLE_BIN=""
GRADLE_SRC_DIR=""
GRADLE_USER_HOME_DIR=""
PROJECTS_DIR=""
RUNS_DIR=""
JDK_HOME=""
JDK_TARBALL_NAME=""
JDK_TARBALL_SHA256=""
JDK_TARBALL_URL=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"

log_message() {
    printf '[gradle] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
}

normalize_architecture() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

validate_architecture() {
    local normalized
    normalized="$(normalize_architecture "${EXPECTED_ARCH}")" || return 20
    case "${normalized}" in
        x86_64|aarch64) ;;
        *)
            log_message "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
}

validate_reps() {
    [[ "${GRADLE_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${GRADLE_REPS}"
        return 10
    }
    if (( GRADLE_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${GRADLE_REPS} is a local link-validation value; formal evidence requires >= 5"
    fi
}

select_jdk_artifact() {
    case "${EXPECTED_ARCH}" in
        x86_64)
            JDK_TARBALL_NAME="${JDK_X64_NAME}"
            JDK_TARBALL_SHA256="${JDK_X64_SHA256}"
            ;;
        aarch64)
            JDK_TARBALL_NAME="${JDK_ARM64_NAME}"
            JDK_TARBALL_SHA256="${JDK_ARM64_SHA256}"
            ;;
        *)
            log_message "ERROR: no JDK artifact for architecture ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    JDK_TARBALL_URL="${JDK_BASE_URL}/${JDK_TARBALL_NAME}"
}

configure_runtime_paths() {
    validate_variant || return $?
    validate_reps || return $?
    EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
    EXPECTED_ARCH="$(normalize_architecture "${EXPECTED_ARCH}")" || {
        log_message "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
        return 20
    }
    local runner_architecture
    runner_architecture="$(normalize_architecture "$(uname -m)")" || {
        log_message "ERROR: unsupported runner architecture: $(uname -m)"
        return 20
    }
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log_message "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    if [[ -z "${PERF_RUN_ID:-}" ]]; then
        PERF_RUN_ID="$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    if [[ -z "${RESULTS_DIR:-}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${PERF_WORK_DIR:-}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/gradle/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    TMPDIR="${TMPDIR:-${PERF_WORK_DIR}/tmp}"
    select_jdk_artifact || return $?
    JDK_HOME="${PERF_WORK_DIR}/jdk-install"
    GRADLE_HOME="${PERF_WORK_DIR}/gradle-install"
    GRADLE_BIN="${GRADLE_HOME}/bin/gradle"
    GRADLE_SRC_DIR="${PERF_WORK_DIR}/gradle-source"
    GRADLE_USER_HOME_DIR="${PERF_WORK_DIR}/gradle-home"
    PROJECTS_DIR="${PERF_WORK_DIR}/projects"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export JAVA_HOME="${JDK_HOME}"
    export PATH="${JAVA_HOME}/bin:${GRADLE_HOME}/bin:${PATH}"
    export GRADLE_USER_HOME="${GRADLE_USER_HOME_DIR}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR GRADLE_REPS GRADLE_OFFLINE_DIR
    export JDK_HOME GRADLE_HOME GRADLE_BIN GRADLE_SRC_DIR GRADLE_USER_HOME_DIR
    export PROJECTS_DIR RUNS_DIR
    export GRADLE_SCALES GRADLE_MATRIX_TASKS GRADLE_UPSTREAM_SCENARIO GRADLE_UPSTREAM_SAMPLE_LIST
    export GRADLE_SRC_NAME GRADLE_SRC_SHA256 GRADLE_ZIP_NAME GRADLE_ZIP_SHA256
}

initialize_runtime() {
    if [[ -z "${GRADLE_BIN:-}" || -z "${RUNS_DIR:-}" ]]; then
        configure_runtime_paths || return $?
    fi
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${GRADLE_USER_HOME_DIR}"
}

gradle_flags() {
    # --no-daemon: every measured invocation pays the full JVM start-up of a
    # single-use daemon, exactly like the delivery manual prescribes, so daemon
    # reuse can never mask build differences between architectures.
    printf '%s\n' --no-daemon --max-workers=1 --console=plain --no-build-cache --warning-mode=none
}

gradle_version_string() {
    if [[ ! -x "${GRADLE_BIN}" ]]; then
        return 1
    fi
    "${GRADLE_BIN}" --version 2>/dev/null | awk '/^Gradle /{print $2; exit}'
}

java_version_string() {
    if [[ ! -x "${JAVA_HOME}/bin/java" ]]; then
        return 1
    fi
    "${JAVA_HOME}/bin/java" -version 2>&1 | sed -n '1{s/^openjdk version "//;s/".*$//;p}'
}

gradle_source_revision_string() {
    # The source archive is a GitHub tag archive: the tag itself is the revision.
    printf '%s\n' "v${GRADLE_VERSION}"
}

scenario_list() {
    local scale task
    for scale in "${GRADLE_SCALES[@]}"; do
        for task in "${GRADLE_MATRIX_TASKS[@]}"; do
            printf '%s_%s\n' "${task}" "${scale}"
        done
    done
    printf '%s\n' "${GRADLE_UPSTREAM_SCENARIO}"
}

scenario_scale() {
    local scenario="$1"
    if [[ "${scenario}" == "${GRADLE_UPSTREAM_SCENARIO}" ]]; then
        printf 'upstream\n'
        return 0
    fi
    printf '%s\n' "${scenario##*_}"
}

record_actual_version() {
    local version
    version="$(gradle_version_string)" || version=""
    if [[ "${version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: requested Gradle ${SOFTWARE_VERSION} but installed: ${version:-<unknown>}"
        return 30
    fi
    if [[ "$(java_version_string)" != "${JDK_SEMVER}"* ]]; then
        log_message "ERROR: expected Temurin JDK ${JDK_SEMVER}, got: $(java_version_string || true)"
        return 30
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "recorded actual Gradle version: ${version} (Temurin JDK $(java_version_string))"
}
