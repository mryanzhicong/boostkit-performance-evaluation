#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="jenkins"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-2.588}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

JENKINS_WAR_NAME="jenkins.war"
JENKINS_WAR_SHA256="e84790335e973f1c051f32cb1e64808049a31a17dbeaa98014937842710bf37a"
JENKINS_WAR_SIZE="52583800"
JENKINS_WAR_URLS=(
    "https://get.jenkins.io/war/${SOFTWARE_VERSION}/${JENKINS_WAR_NAME}"
    "https://mirrors.huaweicloud.com/jenkins/war/${SOFTWARE_VERSION}/${JENKINS_WAR_NAME}"
    "https://mirrors.tuna.tsinghua.edu.cn/jenkins/war/${SOFTWARE_VERSION}/${JENKINS_WAR_NAME}"
    "https://mirrors.aliyun.com/jenkins/war/${SOFTWARE_VERSION}/${JENKINS_WAR_NAME}"
)
JENKINS_OFFICIAL_WAR_BASE="https://get.jenkins.io/war/${SOFTWARE_VERSION}"

# Jenkins 2.588 requires a supported long-term JDK.  Temurin 21 is the same
# runtime the Maven case uses, which keeps the Java performance baseline
# comparable across the two JVM-based Toolchain cases.
JDK_RELEASE="21.0.13+9"
JDK_SEMVER="21.0.13"
JDK_X64_NAME="OpenJDK21U-jdk_x64_linux_hotspot_21.0.13_9.tar.gz"
JDK_X64_SHA256="d7f5d5cf865a2902b70ff549b97586a7d3f234e016f041ab447ea740c7d66d1c"
JDK_ARM64_NAME="OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.13_9.tar.gz"
JDK_ARM64_SHA256="e3522e707fc7dbe2a72c30746b1e7068301a0213ecd213d4491f35a14eb55578"
JDK_BASE_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.13%2B9"

JENKINS_OFFLINE_DIR="${JENKINS_OFFLINE_DIR:-/home/runner/software/jenkins}"
JENKINS_HEAP_FLAGS=(-Xms512m -Xmx512m -Djava.awt.headless=true)
JENKINS_JVM_FLAGS=(
    -Djenkins.install.runSetupWizard=false
    -Dhudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION=true
    -Dhudson.model.UpdateCenter.updateCenterUrl=http://127.0.0.1:1/update-center.json
    -Djenkins.model.DownloadService.noSignatureCheck=true
    -Dhudson.model.UsageStatistics.disabled=true
)
JENKINS_DRIVER_TIMEOUT_SECONDS="${JENKINS_DRIVER_TIMEOUT_SECONDS:-900}"
JENKINS_REPS="${PERF_REPS:-5}"

JENKINS_SCENARIOS_FILE="${SCRIPT_DIR}/benchmarks/scenarios.psv"
JENKINS_DRIVER="${SCRIPT_DIR}/scripts/run_jenkins_case.py"

JENKINS_WAR=""
JENKINS_HOMES_DIR=""
JENKINS_TEMPLATE_HOME=""
JDK_HOME=""
JENKINS_JAVA=""
JENKINS_VERSION_STRING=""
JENKINS_PORT=""
RUNS_DIR=""
JDK_TARBALL_NAME=""
JDK_TARBALL_SHA256=""
JDK_TARBALL_URL=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[jenkins] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
        *)
            log_message "ERROR: invalid build variant: ${PERF_VARIANT}"
            return 10
            ;;
    esac
}

validate_reps() {
    [[ "${JENKINS_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${JENKINS_REPS}"
        return 10
    }
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
    [[ "${SOFTWARE_VERSION}" == "2.588" ]] || {
        log_message "ERROR: unsupported Jenkins version: ${SOFTWARE_VERSION}"
        return 10
    }
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    local runner_architecture
    runner_architecture="$(normalize_architecture "$(uname -m)")"
    EXPECTED_ARCH="$(normalize_architecture "${EXPECTED_ARCH}")"
    case "${EXPECTED_ARCH}" in
        x86_64|aarch64) ;;
        *)
            log_message "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log_message "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/jenkins/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    TMPDIR="${PERF_WORK_DIR}/tmp"
    JENKINS_WAR="${PERF_WORK_DIR}/${JENKINS_WAR_NAME}"
    JENKINS_HOMES_DIR="${PERF_WORK_DIR}/homes"
    JENKINS_TEMPLATE_HOME="${PERF_WORK_DIR}/jenkins-home-template"
    JDK_HOME="${PERF_WORK_DIR}/jdk-${JDK_SEMVER}"
    JENKINS_JAVA="${JDK_HOME}/bin/java"
    RUNS_DIR="${RESULTS_DIR}/runs"
    # The controller port is derived from the run ID so that concurrent runs on
    # one machine do not collide, while repeated repetitions reuse one port.
    JENKINS_PORT="$((18200 + $(printf '%s' "${PERF_RUN_ID}" | cksum | cut -d ' ' -f 1) % 2000))"
    select_jdk_artifact || return $?
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID PERF_WORK_DIR
    export RESULTS_DIR PERF_ACTUAL_VERSION_FILE TMPDIR JENKINS_REPS
    export JENKINS_WAR JENKINS_HOMES_DIR JENKINS_TEMPLATE_HOME JDK_HOME
    export JENKINS_JAVA RUNS_DIR JENKINS_PORT
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${JENKINS_HOMES_DIR}"
}

export_java_env() {
    export JAVA_HOME="${JDK_HOME}"
    export PATH="${JAVA_HOME}/bin:${PATH}"
}

scenario_count() {
    local count=0 scenario dimension action scale check expected workload
    while IFS='|' read -r scenario dimension action scale check expected workload; do
        [[ -z "${scenario}" || "${scenario}" == \#* ]] && continue
        count=$((count + 1))
    done < "${JENKINS_SCENARIOS_FILE}"
    printf '%s\n' "${count}"
}
