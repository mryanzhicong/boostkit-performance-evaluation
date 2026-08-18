#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.5.6}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
ZSTD_SOURCE_URL="${ZSTD_SOURCE_URL:-https://github.com/facebook/zstd.git}"
SOURCE_DIR=""
FULLBENCH_BIN=""
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

log() { printf '[zstd] %s\n' "$*"; }

normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

configure_runtime_paths() {
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    }
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/tmp/zstd-perf/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
        TMPDIR="${PERF_WORK_DIR}/tmp"
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/zstd-source"
    FULLBENCH_BIN="${SOURCE_DIR}/tests/fullbench"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
}

initialize_runtime() {
    configure_runtime_paths
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR:-${PERF_WORK_DIR}/tmp}"
}

require_commands() {
    local command missing=0
    for command in git python3 make cc sed tee; do
        if ! command -v "${command}" >/dev/null 2>&1; then
            log "ERROR: required command is missing: ${command}"
            missing=1
        fi
    done
    [[ "${missing}" -eq 0 ]]
}

check_architecture() {
    local actual expected
    actual="$(normalize_arch "$(uname -m)")"
    expected="$(normalize_arch "${EXPECTED_ARCH}")"
    [[ "${actual}" == "${expected}" ]] || {
        log "ERROR: expected architecture ${expected}, runner is ${actual}"
        return 20
    }
}

read_header_version() {
    local header="$1" major minor release
    major="$(sed -n 's/^#define ZSTD_VERSION_MAJOR[[:space:]]\+\([0-9][0-9]*\).*/\1/p' "${header}")"
    minor="$(sed -n 's/^#define ZSTD_VERSION_MINOR[[:space:]]\+\([0-9][0-9]*\).*/\1/p' "${header}")"
    release="$(
        sed -n 's/^#define ZSTD_VERSION_RELEASE[[:space:]]\+\([0-9][0-9]*\).*/\1/p' "${header}"
    )"
    [[ -n "${major}" && -n "${minor}" && -n "${release}" ]] || return 1
    printf '%s.%s.%s\n' "${major}" "${minor}" "${release}"
}

build_zstd() {
    local tag actual_version
    initialize_runtime || return $?
    check_architecture || return $?
    require_commands || return $?
    [[ ! -e "${SOURCE_DIR}" ]] || {
        log "ERROR: source directory is not clean under ${PERF_WORK_DIR}"
        return 20
    }

    tag="${SOFTWARE_VERSION}"
    [[ "${tag}" == v* ]] || tag="v${tag}"
    log "cloning Zstd ${tag} from ${ZSTD_SOURCE_URL}"
    git clone --branch "${tag}" --depth 1 "${ZSTD_SOURCE_URL}" "${SOURCE_DIR}" || {
        log "ERROR: failed to clone Zstd ${tag}"
        return 30
    }

    log "building the official tests/fullbench target"
    (cd "${SOURCE_DIR}/tests" && make fullbench) || {
        log "ERROR: failed to build the official fullbench target"
        return 40
    }
    [[ -x "${FULLBENCH_BIN}" ]] || {
        log "ERROR: official fullbench executable was not created"
        return 40
    }

    actual_version="$(read_header_version "${SOURCE_DIR}/lib/zstd.h")"
    [[ -n "${actual_version}" ]] || {
        log "ERROR: cannot read the built Zstd version"
        return 40
    }
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40
}

start_zstd_runtime() {
    initialize_runtime || return $?
    [[ -x "${FULLBENCH_BIN}" ]] || {
        log "ERROR: official fullbench executable is unavailable"
        return 40
    }
    log "Zstd fullbench runtime is ready"
}

run_zstd_benchmarks() {
    initialize_runtime || return $?
    [[ -x "${FULLBENCH_BIN}" ]] || {
        log "ERROR: official fullbench executable is unavailable"
        return 40
    }
    export SOFTWARE_VERSION EXPECTED_ARCH
    python3 "${SCRIPT_DIR}/scripts/run_fullbench.py" \
        "${FULLBENCH_BIN}" "${RESULTS_DIR}/benchmark_fullbench.json" || return 50
}

stop_zstd_runtime() {
    log "Zstd fullbench has no background service to stop"
}

standalone_runtime() {
    python3 "${SCRIPT_DIR}/scripts/standalone_runtime.py" "$@"
}

cleanup_standalone_workdir() {
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 1 ]]; then
        log "keeping standalone work directory: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${STANDALONE_OWNS_WORK_DIR}" -ne 1 ]]; then
        log "external work directory was not removed: ${PERF_WORK_DIR}"
        return 0
    fi
    [[ "${PERF_WORK_DIR}" == /tmp/zstd-perf/local-* && \
       "${PERF_WORK_DIR}" != "/tmp/zstd-perf" ]] || {
        log "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    }
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        rm -rf -- "${PERF_WORK_DIR}" || return 70
    fi
    log "cleaned standalone work directory: ${PERF_WORK_DIR}"
}

emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then
        stop_zstd_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_zstd_standalone() {
    local stage_status=0 failed_stage="" cleanup_status="passed" finalize_status=0
    local command_status="passed"

    configure_runtime_paths || return $?
    STANDALONE_STOP_DONE=0
    STANDALONE_CLEANUP_DONE=0
    trap emergency_standalone_cleanup EXIT
    initialize_runtime || return $?

    if standalone_runtime system "${RESULTS_DIR}/system_info.json" && \
        standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json"; then
        :
    else
        stage_status=$?
        failed_stage="prepare"
    fi

    if [[ "${stage_status}" -eq 0 ]]; then
        if build_zstd; then
            if standalone_runtime build-info \
                "${RESULTS_DIR}/build_info.json" \
                "${SOFTWARE_VERSION}" \
                "${PERF_ACTUAL_VERSION_FILE}" \
                "$(normalize_arch "${EXPECTED_ARCH}")" \
                "${PERF_RUN_ID}"; then
                :
            else
                stage_status=$?
                failed_stage="build"
            fi
        else
            stage_status=$?
            failed_stage="build"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if start_zstd_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_zstd_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_zstd_runtime; then
        cleanup_status="failed"
    fi
    STANDALONE_STOP_DONE=1
    if ! standalone_runtime runtime "${RESULTS_DIR}/runtime_after.json"; then
        cleanup_status="failed"
    fi
    if ! cleanup_standalone_workdir; then
        cleanup_status="failed"
    fi
    STANDALONE_CLEANUP_DONE=1

    if [[ "${stage_status}" -ne 0 ]]; then
        command_status="failed"
    fi
    if standalone_runtime finalize \
        "${RESULTS_DIR}" \
        "${SOFTWARE_VERSION}" \
        "$(normalize_arch "${EXPECTED_ARCH}")" \
        "${PERF_RUN_ID}" \
        "${command_status}" \
        "${cleanup_status}" \
        "${failed_stage}"; then
        finalize_status=0
    else
        finalize_status=$?
    fi
    trap - EXIT
    [[ "${stage_status}" -eq 0 ]] || return "${stage_status}"
    [[ "${cleanup_status}" == "passed" ]] || return 70
    return "${finalize_status}"
}

usage() {
    cat <<USAGE
Usage: $(basename "$0") [OPTIONS]

Build Zstd's official fullbench target and run its standalone performance evaluation.
Results default to results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       Zstd version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR, ZSTD_SOURCE_URL
USAGE
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version)
                [[ "$#" -ge 2 ]] || { log "ERROR: --version requires a value"; return 10; }
                SOFTWARE_VERSION="$2"
                shift 2
                ;;
            --results-dir)
                [[ "$#" -ge 2 ]] || { log "ERROR: --results-dir requires a value"; return 10; }
                RESULTS_DIR="$2"
                shift 2
                ;;
            --keep-workdir)
                STANDALONE_KEEP_WORK_DIR=1
                shift
                ;;
            -h|--help)
                usage
                return 0
                ;;
            *)
                log "ERROR: unsupported option: $1"
                usage
                return 10
                ;;
        esac
    done

    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" || return $?
    : > "${RESULTS_DIR}/results.log"
    local pipeline_status=0
    set +e
    run_zstd_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
