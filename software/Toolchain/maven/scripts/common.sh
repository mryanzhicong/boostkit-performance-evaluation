#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-3.10.0}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

MAVEN_VERSION="${SOFTWARE_VERSION}"
MAVEN_DIST_BASE="https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}"
MAVEN_BIN_NAME="apache-maven-${MAVEN_VERSION}-bin.tar.gz"
MAVEN_SRC_NAME="apache-maven-${MAVEN_VERSION}-src.tar.gz"
MAVEN_BIN_URL="${MAVEN_DIST_BASE}/binaries/${MAVEN_BIN_NAME}"
MAVEN_SRC_URL="${MAVEN_DIST_BASE}/source/${MAVEN_SRC_NAME}"
MAVEN_BIN_SHA512="908b1501bfb420bf7c8affb855534a9c407fd6099367bfb9f2f2dcb8e9799102bffb84518cde74c679bd76870247c6528683abdd620581bffa90f95d92d175aa"
MAVEN_SRC_SHA512="5b95db2740e5e11c29ce372541c4e00829ad58ca490749c9810aacb9ea1855166d85734cbf6ed4c178001eddba3719ed912807dfe1aa8f9036f09d862aa1d05c"
MAVEN_OFFLINE_DIR="${MAVEN_OFFLINE_DIR:-/home/runner/software/maven}"

JDK_RELEASE="21.0.13+9"
JDK_SEMVER="21.0.13"
JDK_X64_NAME="OpenJDK21U-jdk_x64_linux_hotspot_21.0.13_9.tar.gz"
JDK_X64_SHA256="d7f5d5cf865a2902b70ff549b97586a7d3f234e016f041ab447ea740c7d66d1c"
JDK_ARM64_NAME="OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.13_9.tar.gz"
JDK_ARM64_SHA256="e3522e707fc7dbe2a72c30746b1e7068301a0213ecd213d4491f35a14eb55578"
JDK_BASE_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.13%2B9"

MAVEN_SCALES=(100 1000 10000)
MAVEN_TASKS=(clean_package incremental_package noop_package)
MAVEN_EXTRA_SCENARIOS=(maven_self_build)
MAVEN_REPS="${PERF_REPS:-5}"
# Optional settings.xml override, used by offline/intranet environments that
# cannot reach Maven Central directly.  Unset by default: CI runs against the
# repositories declared by Maven's own POM without any mirror.
PERF_MAVEN_SETTINGS="${PERF_MAVEN_SETTINGS:-}"
declare -ga MAVEN_SETTINGS_ARGV=()

JDK_HOME=""
MAVEN_SRC_DIR=""
MAVEN_HOME=""
MAVEN_BIN=""
M2_REPO=""
PROJECTS_DIR=""
RUNS_DIR=""
JDK_TARBALL_NAME=""
JDK_TARBALL_SHA256=""
JDK_TARBALL_URL=""
MAVEN_VERSION_STRING=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[maven] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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

validate_reps() {
    [[ "${MAVEN_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${MAVEN_REPS}"
        return 10
    }
    if (( MAVEN_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${MAVEN_REPS} is a local link-validation value; formal evidence requires >= 5"
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
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64) EXPECTED_ARCH="x86_64" ;;
        aarch64|arm64) EXPECTED_ARCH="aarch64" ;;
        *)
            log_message "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    local runner_architecture
    runner_architecture="$(normalize_architecture "$(uname -m)")"
    case "${runner_architecture}" in
        x86_64|aarch64) ;;
        *)
            log_message "ERROR: unsupported runner architecture: $(uname -m)"
            return 20
            ;;
    esac
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log_message "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/maven/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    select_jdk_artifact || return $?
    MAVEN_SETTINGS_ARGV=()
    if [[ -n "${PERF_MAVEN_SETTINGS}" ]]; then
        if [[ ! -f "${PERF_MAVEN_SETTINGS}" ]]; then
            log_message "ERROR: PERF_MAVEN_SETTINGS does not point to a file: ${PERF_MAVEN_SETTINGS}"
            return 10
        fi
        MAVEN_SETTINGS_ARGV=(-s "${PERF_MAVEN_SETTINGS}")
        log_message "using explicit Maven settings file: ${PERF_MAVEN_SETTINGS}"
    fi
    JDK_HOME="${PERF_WORK_DIR}/jdk-install"
    MAVEN_SRC_DIR="${PERF_WORK_DIR}/maven-src"
    MAVEN_HOME="${PERF_WORK_DIR}/maven-install"
    MAVEN_BIN="${MAVEN_HOME}/bin/mvn"
    M2_REPO="${PERF_WORK_DIR}/m2repo"
    PROJECTS_DIR="${PERF_WORK_DIR}/projects"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR MAVEN_REPS
    export JDK_HOME MAVEN_SRC_DIR MAVEN_HOME MAVEN_BIN M2_REPO PROJECTS_DIR RUNS_DIR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

export_java_env() {
    export JAVA_HOME="${JDK_HOME}"
    export PATH="${JAVA_HOME}/bin:${PATH}"
    export MAVEN_OPTS=""
}

maven_command() {
    printf '%s\n' "${MAVEN_BIN}" -B -o -ntp \
        "-Dmaven.repo.local=${M2_REPO}" \
        -Dstyle.color=never
}

scenario_list() {
    local scale task
    for scale in "${MAVEN_SCALES[@]}"; do
        for task in "${MAVEN_TASKS[@]}"; do
            printf '%s_%s\n' "${task}" "${scale}"
        done
    done
    printf '%s\n' "${MAVEN_EXTRA_SCENARIOS[@]}"
}

scenario_scale() {
    local scenario="$1"
    if [[ "${scenario}" == "maven_self_build" ]]; then
        printf 'upstream\n'
        return 0
    fi
    printf '%s\n' "${scenario##*_}"
}
