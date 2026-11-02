#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.10.18}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

ANT_VERSION="${SOFTWARE_VERSION}"
ANT_ARCHIVE_NAME="apache-ant-${ANT_VERSION}-bin.tar.gz"
ANT_ARCHIVE_SHA256="b45db2fdd76d639301550930d33dd7bc672c9d4fdea0fe8cfd2e6a3518388d59"
ANT_OFFICIAL_URL="https://archive.apache.org/dist/ant/binaries/${ANT_ARCHIVE_NAME}"
ANT_MIRROR_URLS=(
    "https://mirrors.tuna.tsinghua.edu.cn/apache/ant/binaries/${ANT_ARCHIVE_NAME}"
    "https://mirrors.huaweicloud.com/apache/ant/binaries/${ANT_ARCHIVE_NAME}"
    "https://dlcdn.apache.org/ant/binaries/${ANT_ARCHIVE_NAME}"
)
ANT_OFFLINE_DIR="${PERF_ANT_OFFLINE_DIR:-/home/runner/software/ant}"

# Pinned Eclipse Temurin JDK, identical to the other JVM Toolchain cases.
JDK_RELEASE="21.0.13+9"
JDK_SEMVER="21.0.13"
JDK_X64_NAME="OpenJDK21U-jdk_x64_linux_hotspot_21.0.13_9.tar.gz"
JDK_X64_SHA256="d7f5d5cf865a2902b70ff549b97586a7d3f234e016f041ab447ea740c7d66d1c"
JDK_ARM64_NAME="OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.13_9.tar.gz"
JDK_ARM64_SHA256="e3522e707fc7dbe2a72c30746b1e7068301a0213ecd213d4491f35a14eb55578"
JDK_BASE_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.13%2B9"
JDK_MIRROR_BASE_URLS=(
    "https://mirrors.tuna.tsinghua.edu.cn/Adoptium/21/jdk"
    "https://mirrors.huaweicloud.com/adoptium/21/jdk"
)
JDK_OFFLINE_DIRS=(
    "${ANT_OFFLINE_DIR}"
    "/home/runner/software/maven"
)

# 构建矩阵：clean 全量构建 + 增量（空闲/单文件变更）对比。
ANT_JAR_SCALES=(50 100 200)
ANT_REPS="${PERF_REPS:-5}"

JDK_HOME=""
ANT_HOME=""
ANT_BIN=""
PROJECTS_DIR=""
RUNS_DIR=""
ANT_VERSION_STRING=""
JDK_TARBALL_NAME=""
JDK_TARBALL_SHA256=""
JDK_TARBALL_URL=""
declare -ga JDK_TARBALL_URLS=()
declare -ga ANT_ARCHIVE_URLS=()
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[ant] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    [[ "${ANT_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${ANT_REPS}"
        return 10
    }
    if (( ANT_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${ANT_REPS} is a local link-validation value; formal evidence requires >= 5"
    fi
}

select_jdk_artifact() {
    local arch_dir
    case "${EXPECTED_ARCH}" in
        x86_64)
            JDK_TARBALL_NAME="${JDK_X64_NAME}"
            JDK_TARBALL_SHA256="${JDK_X64_SHA256}"
            arch_dir="x64"
            ;;
        aarch64)
            JDK_TARBALL_NAME="${JDK_ARM64_NAME}"
            JDK_TARBALL_SHA256="${JDK_ARM64_SHA256}"
            arch_dir="aarch64"
            ;;
        *)
            log_message "ERROR: no JDK artifact for architecture ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    JDK_TARBALL_URL="${JDK_BASE_URL}/${JDK_TARBALL_NAME}"
    JDK_TARBALL_URLS=()
    local mirror_base
    for mirror_base in "${JDK_MIRROR_BASE_URLS[@]}"; do
        JDK_TARBALL_URLS+=("${mirror_base}/${arch_dir}/linux/${JDK_TARBALL_NAME}")
    done
    JDK_TARBALL_URLS+=("${JDK_TARBALL_URL}")
}

select_ant_artifact() {
    ANT_ARCHIVE_URLS=("${ANT_MIRROR_URLS[@]}" "${ANT_OFFICIAL_URL}")
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/ant/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    select_jdk_artifact || return $?
    select_ant_artifact
    JDK_HOME="${PERF_WORK_DIR}/jdk-install"
    ANT_HOME="${PERF_WORK_DIR}/ant-install"
    ANT_BIN="${ANT_HOME}/bin/ant"
    PROJECTS_DIR="${PERF_WORK_DIR}/projects"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR
    export PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR ANT_REPS
    export JDK_HOME ANT_HOME ANT_BIN PROJECTS_DIR RUNS_DIR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

export_java_env() {
    export JAVA_HOME="${JDK_HOME}"
    export PATH="${JAVA_HOME}/bin:${PATH}"
    export ANT_HOME
}

scenario_metadata_payload() {
    python3 - "$1" "${ANT_REPS}" <<'PY'
import json
import sys

output = sys.argv[1]
reps = int(sys.argv[2])
scenarios = []
for scale in (50, 100, 200):
    scenarios.append({
        "scenario": f"clean_jar_{scale}",
        "description": f"ant clean build (javac + jar) of the generated {scale}-class project",
        "workload": f"{scale} generated Java sources",
        "throughput": {"name": "classes_per_second", "items": scale, "unit": "classes/s"},
    })
scenarios.extend([
    {
        "scenario": "clean_compile_100",
        "description": "ant clean compile (javac only) of the generated 100-class project",
        "workload": "100 generated Java sources",
        "throughput": {"name": "classes_per_second", "items": 100, "unit": "classes/s"},
    },
    {
        "scenario": "incremental_noop_100",
        "description": "ant incremental jar build with no source change (idle incremental)",
        "workload": "100 unchanged Java sources",
    },
    {
        "scenario": "incremental_touch_100",
        "description": "ant incremental jar build after modifying a single source file",
        "workload": "100 Java sources, 1 modified",
    },
])
payload = {
    "reps": reps,
    "parameters": {
        "clean_jar_scales": [50, 100, 200],
        "incremental_work_scale": 100,
        "jdk_release": "21.0.13+9",
    },
    "scenarios": scenarios,
}
with open(output, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, ensure_ascii=False, indent=2)
    handle.write("\n")
PY
}

case_tool_release_string() {
    printf 'Temurin %s\n' "${JDK_RELEASE}"
}

case_artifact_url() {
    printf '%s\n' "${ANT_OFFICIAL_URL}"
}

case_artifact_sha256() {
    printf '%s\n' "${ANT_ARCHIVE_SHA256}"
}

case_artifact_version_string() {
    printf '%s\n' "${ANT_VERSION_STRING:-Apache Ant ${SOFTWARE_VERSION}}"
}

case_build_notes() {
    printf 'apache-ant binary distribution (%s) + pinned Temurin JDK %s; Ant is not built from source\n' \
        "${ANT_ARCHIVE_NAME}" "${JDK_RELEASE}"
}
