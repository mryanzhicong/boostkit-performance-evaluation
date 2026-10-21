#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/builders/dispatch.sh"
source "${SCRIPT_DIR}/scripts/stages/start.sh"
source "${SCRIPT_DIR}/scripts/stages/test.sh"
source "${SCRIPT_DIR}/scripts/stages/stop.sh"

standalone_runtime() {
    python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" "$@"
}

cleanup_standalone_workdir() {
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 1 ]]; then
        log_message "keeping standalone work directory: ${PERF_WORK_DIR}"
        return
    fi
    if [[ "${STANDALONE_OWNS_WORK_DIR}" -ne 1 ]]; then
        log_message "external work directory was not removed: ${PERF_WORK_DIR}"
        return
    fi
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/golang/local-* || "${PERF_WORK_DIR}" == /home/runner/boostkit-perf/golang ]]; then
        log_message "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    fi
    rm -rf -- "${PERF_WORK_DIR}"
}

run_golang_standalone() {
    local stage_status=0 failed_stage="" cleanup_status="passed"
    local command_status="passed" finalize_status=0

    initialize_runtime || return $?
    trap 'stop_golang_runtime || :; cleanup_standalone_workdir || :' EXIT

    if standalone_runtime system "${RESULTS_DIR}/system_info.json"; then
        :
    else
        stage_status=$?
        failed_stage="prepare"
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json"; then
            :
        else
            stage_status=$?
            failed_stage="prepare"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if build_golang; then
            :
        else
            stage_status=$?
            failed_stage="build"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if standalone_runtime build-info "${RESULTS_DIR}/build_info.json" \
            "${SOFTWARE_VERSION}" "${PERF_ACTUAL_VERSION_FILE}" "${EXPECTED_ARCH}" \
            "${PERF_RUN_ID}" "${GCC_VERSION_STRING}" \
            --release-url="${GO_RELEASE_URL}"; then
            :
        else
            stage_status=$?
            failed_stage="build"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if start_golang_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_golang_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_golang_runtime; then
        cleanup_status="failed"
    fi
    if ! standalone_runtime runtime "${RESULTS_DIR}/runtime_after.json"; then
        cleanup_status="failed"
    fi
    if ! cleanup_standalone_workdir; then
        cleanup_status="failed"
    fi
    trap - EXIT

    if [[ "${stage_status}" -ne 0 ]]; then
        command_status="failed"
    fi
    if standalone_runtime finalize "${RESULTS_DIR}" "${SOFTWARE_VERSION}" "${EXPECTED_ARCH}" \
        "${PERF_RUN_ID}" "${command_status}" "${cleanup_status}" "${failed_stage}"; then
        finalize_status=0
    else
        finalize_status=$?
    fi

    if [[ "${stage_status}" -ne 0 ]]; then
        return "${stage_status}"
    fi
    if [[ "${cleanup_status}" != "passed" ]]; then
        return 70
    fi
    return "${finalize_status}"
}

usage() {
    cat <<USAGE
Usage: $(basename "$0") [OPTIONS]

Install the official precompiled Go release and run the selected
golang.org/x/benchmarks/cmd/bent suite. The optimized build is reserved
and fails until its implementation is supplied.

Options:
  --version VERSION       Go version (default: ${SOFTWARE_VERSION})
  --variant VARIANT       base or optimized (default: base)
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Offline archives take priority from ${GO_OFFLINE_DIR}:
  go<VERSION>.linux-<amd64|arm64>.tar.gz

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, PERF_VARIANT, RESULTS_DIR, PERF_WORK_DIR,
  GO_RELEASE_URL, GO_OFFLINE_DIR, BENT_MODULE_CACHE_DIR, GO_RUNTIME_ROOT
USAGE
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --version requires a value"; return 10; }
                SOFTWARE_VERSION="$2"
                shift 2
                ;;
            --variant)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --variant requires a value"; return 10; }
                PERF_VARIANT="$2"
                shift 2
                ;;
            --results-dir)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --results-dir requires a value"; return 10; }
                RESULTS_DIR="$2"
                shift 2
                ;;
            --keep-workdir) STANDALONE_KEEP_WORK_DIR=1; shift ;;
            -h|--help) usage; return 0 ;;
            *) log_message "ERROR: unsupported option: $1"; usage; return 10 ;;
        esac
    done
    validate_variant || return $?
    initialize_runtime || return $?
    : > "${RESULTS_DIR}/results.log"
    set +e
    run_golang_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    local result="${PIPESTATUS[0]}"
    set -e
    log_message "standalone results: ${RESULTS_DIR}"
    return "${result}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
