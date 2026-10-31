#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASE_DIR="${SCRIPT_DIR}"
SOFTWARE_NAME="git"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-2.56.0}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"

# Official git repository, pinned release tag and its peeled commit.
GIT_REPOSITORY="${GIT_REPOSITORY:-https://github.com/git/git.git}"
GIT_TAG="${GIT_TAG:-v2.56.0}"
GIT_COMMIT="${GIT_COMMIT:-a018953688f1b10bddf91bff8747068f5f4746a4}"
GIT_CLONE_DEPTH="${GIT_CLONE_DEPTH:-1}"

# Formal workload: the fixed subset of the upstream t/perf suite that runs
# on the pinned shallow checkout, with the official default best-of-5
# repeats. p0000 (harness self-test), p0001 (history traversal) and p0006
# (needs HEAD^) are excluded because a depth-1 checkout would make them
# trivial or unusable; that limitation is documented in the README.
GIT_PERF_REPEAT_COUNT="${GIT_PERF_REPEAT_COUNT:-5}"
GIT_PERF_SCRIPTS=(
    p0002-read-cache.sh
    p0003-delta-base-cache.sh
    p0004-lazy-init-name-hash.sh
    p0005-status.sh
    p0007-write-cache.sh
    p0008-odb-fsync.sh
    p0009-diff-pathspec.sh
    p0071-sort.sh
    p0090-cache-tree.sh
    p0100-globbing.sh
)

# Lifecycle paths (assigned in configure_runtime_paths).
GIT_SRC_DIR=""
GIT_BIN=""
GIT_PERF_DIR=""

log_message() { printf '[git] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    [[ "${SOFTWARE_VERSION}" == "2.56.0" ]] || {
        log_message "ERROR: unsupported git version: ${SOFTWARE_VERSION}"
        return 10
    }
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64) EXPECTED_ARCH="x86_64" ;;
        aarch64|arm64) EXPECTED_ARCH="aarch64" ;;
        *) log_message "ERROR: unsupported architecture: ${EXPECTED_ARCH}"; return 10 ;;
    esac
    [[ "${EXPECTED_ARCH}" == "$(uname -m)" ]] || {
        log_message "ERROR: runner architecture differs from ${EXPECTED_ARCH}"
        return 20
    }
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log_message 'ERROR: unsafe run ID'
        return 10
    }
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/git/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${CASE_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${CASE_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    TMPDIR="${PERF_WORK_DIR}/tmp"
    GIT_SRC_DIR="${PERF_WORK_DIR}/git-src"
    GIT_BIN="${GIT_SRC_DIR}/bin-wrappers/git"
    GIT_PERF_DIR="${GIT_SRC_DIR}/t/perf"
    export SOFTWARE_VERSION PERF_VARIANT EXPECTED_ARCH PERF_RUN_ID PERF_WORK_DIR RESULTS_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}" "${TMPDIR}"
}

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else
        "$@"
    fi
}
