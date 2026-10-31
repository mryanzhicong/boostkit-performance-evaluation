#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="cmake"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-4.4.5}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

CMAKE_VERSION="${SOFTWARE_VERSION}"
CMAKE_RELEASE_BASE="https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}"

# Official distribution archives.  The digests are the ones published in the
# release's cmake-<version>-SHA-256.txt (the aarch64 and x86_64 entries were
# cross-checked against the release asset metadata).
CMAKE_X86_NAME="cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz"
CMAKE_ARM_NAME="cmake-${CMAKE_VERSION}-linux-aarch64.tar.gz"
CMAKE_X86_SHA256="ed85135c5a5135b45e50423cb406dea04ca3338da0b8ef3c9ede963559680be0"
CMAKE_ARM_SHA256="301d5063ab259577c1b57ce5490b1aab9ea5c56dc4c822f73499553dab94925f"

# Official source release archive, used as the upstream project workload and to
# prove the version from the registered release.  GitHub publishes this asset
# digest only through the release metadata; it was verified against the
# downloaded archive before this file was written.
CMAKE_SOURCE_NAME="cmake-${CMAKE_VERSION}.tar.gz"
CMAKE_SOURCE_SHA256="a0c54c88abb8078dd8eccadb717fc6bb194bf18e7d44c86309910288886e04e2"

CMAKE_OFFICIAL_SHA256_FILE="cmake-${CMAKE_VERSION}-SHA-256.txt"
CMAKE_OFFICIAL_SHA256_FILE_SHA256="f502d7058129606f8e468d2373178a5b48eb2c5f9785641b706f45952956dd25"

# Pre-placed offline assets are the preferred input; the directory is read-only
# for the case.  PERF_CMAKE_MIRROR may prefix GitHub download URLs for restricted
# networks (for example a GitHub release proxy used by a local workstation).
CMAKE_OFFLINE_DIR="${PERF_CMAKE_OFFLINE_DIR:-/home/runner/software/cmake}"
PERF_CMAKE_MIRROR="${PERF_CMAKE_MIRROR:-}"

CMAKE_SCALES=(100 1000 10000)
CMAKE_TASKS=(configure clean_build incremental_build noop_build)
CMAKE_UPSTREAM_SCENARIOS=(
    upstream_configure
    upstream_build
    upstream_incremental_build
    upstream_noop_build
)
CMAKE_UPSTREAM_BUILD_TARGET="cmake"
CMAKE_UPSTREAM_INCREMENTAL_SOURCE="Source/cmWorkingDirectory.cxx"

# One warm-up plus five independent measurements per scenario; the build
# parallelism is pinned so the measured build tasks never mix in the machine's
# core count and both architectures submit the same amount of work.
CMAKE_REPS="${PERF_REPS:-5}"
CMAKE_JOBS="${PERF_CMAKE_JOBS:-8}"

CMAKE_ARCHIVE_NAME=""
CMAKE_ARCHIVE_SHA256=""
CMAKE_ARCHIVE_URL=""
CMAKE_HOME=""
CMAKE_BIN=""
CMAKE_SOURCE_ARCHIVE=""
CMAKE_SOURCE_DIR=""
CMAKE_SOURCE_URL=""
CMAKE_INCREMENTAL_SOURCE_ORIG=""
PROJECTS_DIR=""
BENCH_DIR=""
RUNS_DIR=""
CMAKE_VERSION_STRING=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[cmake] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    [[ "${CMAKE_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${CMAKE_REPS}"
        return 10
    }
    if (( CMAKE_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${CMAKE_REPS} is a local link-validation value; formal evidence requires >= 5"
    fi
}

validate_jobs() {
    [[ "${CMAKE_JOBS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_CMAKE_JOBS must be a positive integer, got ${CMAKE_JOBS}"
        return 10
    }
    if (( CMAKE_JOBS > 256 )); then
        log_message "ERROR: PERF_CMAKE_JOBS is unreasonably large: ${CMAKE_JOBS}"
        return 10
    fi
}

select_cmake_archive() {
    case "${EXPECTED_ARCH}" in
        x86_64)
            CMAKE_ARCHIVE_NAME="${CMAKE_X86_NAME}"
            CMAKE_ARCHIVE_SHA256="${CMAKE_X86_SHA256}"
            ;;
        aarch64)
            CMAKE_ARCHIVE_NAME="${CMAKE_ARM_NAME}"
            CMAKE_ARCHIVE_SHA256="${CMAKE_ARM_SHA256}"
            ;;
        *)
            log_message "ERROR: no CMake distribution for architecture ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    CMAKE_ARCHIVE_URL="${CMAKE_RELEASE_BASE}/${CMAKE_ARCHIVE_NAME}"
    CMAKE_SOURCE_URL="${CMAKE_RELEASE_BASE}/${CMAKE_SOURCE_NAME}"
}

configure_runtime_paths() {
    validate_variant || return $?
    validate_reps || return $?
    validate_jobs || return $?
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/cmake/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    select_cmake_archive || return $?
    CMAKE_HOME="${PERF_WORK_DIR}/cmake-install"
    CMAKE_BIN="${CMAKE_HOME}/bin/cmake"
    CMAKE_SOURCE_ARCHIVE="${PERF_WORK_DIR}/downloads/${CMAKE_SOURCE_NAME}"
    CMAKE_SOURCE_DIR="${PERF_WORK_DIR}/cmake-source"
    CMAKE_INCREMENTAL_SOURCE_ORIG="${PERF_WORK_DIR}/incremental-source.orig"
    PROJECTS_DIR="${PERF_WORK_DIR}/projects"
    BENCH_DIR="${PERF_WORK_DIR}/bench"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export SOFTWARE_NAME SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID
    export RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export CMAKE_VERSION CMAKE_HOME CMAKE_BIN CMAKE_SOURCE_DIR CMAKE_SOURCE_ARCHIVE
    export CMAKE_INCREMENTAL_SOURCE_ORIG
    export PROJECTS_DIR BENCH_DIR RUNS_DIR CMAKE_REPS CMAKE_JOBS
    export CMAKE_ARCHIVE_NAME CMAKE_ARCHIVE_SHA256 CMAKE_SOURCE_NAME CMAKE_SOURCE_SHA256
    export CMAKE_UPSTREAM_BUILD_TARGET CMAKE_UPSTREAM_INCREMENTAL_SOURCE
    export CMAKE_OFFLINE_DIR PERF_CMAKE_MIRROR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

compiler_identity() {
    local compiler
    if ! compiler="$(cc --version 2>&1 | head -n 1)"; then
        compiler="unknown"
    fi
    printf '%s\n' "${compiler:-unknown}"
}

cmake_version_string() {
    "${CMAKE_BIN}" --version 2>&1 | head -n 1
}

# Configure arguments.  Both architectures use the same release build type, the
# same fixed optimisation flags and the same compiler driver (the Runner's cc).
# The upstream CMake build additionally disables its own tests and the system
# OpenSSL dependency so the workload depends only on the pinned source archive.
declare -ga PROJECT_CONFIGURE_ARGV=(
    -DCMAKE_BUILD_TYPE=Release
    '-DCMAKE_C_FLAGS_RELEASE=-O2 -DNDEBUG'
)
declare -ga UPSTREAM_CONFIGURE_ARGV=(
    -DCMAKE_BUILD_TYPE=Release
    '-DCMAKE_C_FLAGS_RELEASE=-O2 -DNDEBUG'
    '-DCMAKE_CXX_FLAGS_RELEASE=-O2 -DNDEBUG'
    -DBUILD_TESTING=OFF
    -DCMAKE_USE_OPENSSL=OFF
)

scenario_scale() {
    local scenario="$1"
    case "${scenario}" in
        upstream_*)
            printf 'upstream\n'
            return 0
            ;;
    esac
    printf '%s\n' "${scenario##*_}"
}

scenario_task() {
    local scenario="$1"
    case "${scenario}" in
        upstream_configure) printf 'configure\n' ;;
        upstream_incremental_build) printf 'incremental_build\n' ;;
        upstream_noop_build) printf 'noop_build\n' ;;
        *) printf '%s\n' "${scenario%_*}" ;;
    esac
}

scenario_list() {
    local scale task
    for scale in "${CMAKE_SCALES[@]}"; do
        for task in "${CMAKE_TASKS[@]}"; do
            printf '%s_%s\n' "${task}" "${scale}"
        done
    done
    printf '%s\n' "${CMAKE_UPSTREAM_SCENARIOS[@]}"
}
