#!/usr/bin/env bash
# Standalone entry point for the Go CRC32 performance case.
#
# It runs exactly the same stages as the Framework (build -> start -> test ->
# stop) with the same scripts, so a developer can reproduce the complete
# evidence outside CI on either architecture:
#
#   bash software/Toolchain/go/go_test.sh --version 1.23.0 \
#       --results-dir /home/runner/boostkit-perf/go-results
#
# The run installs the official Go 1.23.0 release at /usr/local/go, builds the
# openEuler golang go1.24.6 toolchain from source at /home/local/golang inside
# the private container, installs benchstat, measures the benchmark with both
# toolchains and compares them with benchstat.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/builders/dispatch.sh"
source "${SCRIPT_DIR}/scripts/stages/start.sh"
source "${SCRIPT_DIR}/scripts/stages/test.sh"
source "${SCRIPT_DIR}/scripts/stages/stop.sh"

cleanup_standalone_workdir() {
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 1 ]]; then
        log_message "keeping standalone work directory: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${STANDALONE_OWNS_WORK_DIR}" -ne 1 ]]; then
        log_message "external work directory was not removed: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/go/local-* || \
          "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/go" ]]; then
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

run_go_standalone() {
    local stage_status=0 failed_stage="" cleanup_status="passed"

    initialize_runtime || return $?
    trap 'stop_go_runtime || :; cleanup_standalone_workdir || :' EXIT

    if ! build_go; then
        stage_status=$?
        failed_stage="build"
    fi
    if [[ "${stage_status}" -eq 0 ]] && ! start_go_runtime; then
        stage_status=$?
        failed_stage="start"
    fi
    if [[ "${stage_status}" -eq 0 ]] && ! run_go_benchmarks; then
        stage_status=$?
        failed_stage="test"
    fi
    if ! stop_go_runtime; then
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
    return 0
}

usage() {
    cat <<USAGE
Usage: $(basename "$0") [OPTIONS]

Install the official Go ${SOFTWARE_VERSION} release at /usr/local/go, build the
openEuler golang ${GO_OPTIMIZED_VERSION} toolchain from source at
/home/local/golang, install benchstat and measure the Go runtime CRC32
Castagnoli benchmark with both toolchains inside a private openEuler container.

Options:
  --version VERSION       Official Go version (default: ${SOFTWARE_VERSION})
  --variant VARIANT       Result label only: base or optimized (default: base)
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, PERF_VARIANT, RESULTS_DIR, PERF_WORK_DIR,
  GO_OFFLINE_DIR, GO_DOWNLOAD_MIRRORS, GO_OPTIMIZED_REPO, GO_OPTIMIZED_BRANCH,
  GO_GOPROXY, WARMUP_REPS, MEASURE_REPS
USAGE
}

parse_arguments() {
    while (($# > 0)); do
        case "$1" in
            --version) SOFTWARE_VERSION="$2"; shift 2 ;;
            --variant) PERF_VARIANT="$2"; shift 2 ;;
            --results-dir) RESULTS_DIR="$2"; shift 2 ;;
            --keep-workdir) STANDALONE_KEEP_WORK_DIR=1; shift ;;
            -h|--help) usage; exit 0 ;;
            *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
        esac
    done
}

parse_arguments "$@"
run_go_standalone
