#!/usr/bin/env bash
# Standalone entry point for the OpenViking 0.5.0 benchmark-kit performance case.
#
# It runs exactly the same stages as the Framework (build -> start -> test ->
# stop) with the same scripts, so the complete evidence can be reproduced
# outside CI on either architecture:
#
#   bash software/AI/openviking/openviking_test.sh --version 0.5.0 \
#       --results-dir /home/runner/boostkit-perf/openviking-results
#
# The run installs the OpenViking v0.5.0 benchmark kit inside a private openEuler
# container, starts the kit's service plus a deterministic local provider mock,
# executes the kit's seven-step protocol (61 write commits, 152 search questions,
# 152 QA questions) out of the box -- no NUMA binding, no cpuset pinning -- and
# publishes the strict metric contract.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/builders/dispatch.sh"
source "${SCRIPT_DIR}/scripts/stages/start.sh"
source "${SCRIPT_DIR}/scripts/stages/test.sh"
source "${SCRIPT_DIR}/scripts/stages/stop.sh"

STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"

cleanup_standalone_workdir() {
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 1 ]]; then
        log_message "keeping standalone work directory: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${STANDALONE_OWNS_WORK_DIR}" -ne 1 ]]; then
        log_message "external work directory was not removed: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/openviking/local-* || \
          "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/openviking" ]]; then
        log_message "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    fi
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        if ! rm -rf -- "${PERF_WORK_DIR}"; then
            log_message "ERROR: failed to clean standalone work directory: ${PERF_WORK_DIR}"
            return 70
        fi
    fi
    log_message "cleaned standalone work directory: ${PERF_WORK_DIR}"
}

run_openviking_standalone() {
    local stage_status=0 failed_stage="" cleanup_status="passed"

    initialize_runtime || return $?
    if [[ -z "${PERF_WORK_DIR_OVERRIDE:-}" ]]; then
        STANDALONE_OWNS_WORK_DIR=1
    fi
    trap 'stop_openviking_runtime || :; cleanup_standalone_workdir || :' EXIT

    if ! build_openviking; then
        stage_status=$?
        failed_stage="build"
    fi
    if [[ "${stage_status}" -eq 0 ]] && ! start_openviking_runtime; then
        stage_status=$?
        failed_stage="start"
    fi
    if [[ "${stage_status}" -eq 0 ]] && ! run_openviking_benchmarks; then
        stage_status=$?
        failed_stage="test"
    fi
    if ! stop_openviking_runtime; then
        cleanup_status="failed"
    fi
    if ! cleanup_standalone_workdir; then
        cleanup_status="failed"
    fi
    trap - EXIT

    if [[ "${stage_status}" -ne 0 ]]; then
        log_message "standalone run failed in stage ${failed_stage} with status ${stage_status}"
        return "${stage_status}"
    fi
    if [[ "${cleanup_status}" != "passed" ]]; then
        log_message "standalone run finished but cleanup failed"
        return 70
    fi
    log_message "standalone run succeeded; results are in ${RESULTS_DIR}"
}

usage() {
    cat <<USAGE
Usage: $(basename "$0") [OPTIONS]

Install the OpenViking ${SOFTWARE_VERSION} benchmark kit in a private openEuler
24.03 LTS SP4 container, start the kit service with a deterministic local
provider mock and execute the kit's seven-step protocol out of the box
(no NUMA binding, no cpuset pinning).

Options:
  --version VERSION       Case version, must be ${SOFTWARE_VERSION} (default: ${SOFTWARE_VERSION})
  --variant VARIANT       Result label only: base or optimized (default: base)
  --results-dir DIR       Persistent result directory
  --work-dir DIR          Isolated work directory (kept as-is on exit)
  --keep-workdir          Keep the default isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, PERF_VARIANT, RESULTS_DIR, PERF_WORK_DIR,
  OPENVIKING_REPO_URL, OPENVIKING_TAG, OPENVIKING_COMMIT, OPENVIKING_OFFLINE_DIR,
  OPENVIKING_MOCK_PORT, OPENVIKING_SERVICE_PORT, OPENVIKING_QA_CONCURRENCY
USAGE
}

parse_arguments() {
    while (($# > 0)); do
        case "$1" in
            --version) SOFTWARE_VERSION="$2"; shift 2 ;;
            --variant) PERF_VARIANT="$2"; shift 2 ;;
            --results-dir) RESULTS_DIR="$2"; shift 2 ;;
            --work-dir) PERF_WORK_DIR="$2"; PERF_WORK_DIR_OVERRIDE=1; shift 2 ;;
            --keep-workdir) STANDALONE_KEEP_WORK_DIR=1; shift ;;
            -h|--help) usage; exit 0 ;;
            *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
        esac
    done
}

parse_arguments "$@"
export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT RESULTS_DIR PERF_WORK_DIR
run_openviking_standalone
