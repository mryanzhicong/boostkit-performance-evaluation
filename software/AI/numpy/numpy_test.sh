#!/usr/bin/env bash
#
# Standalone entry point for the numpy performance case.
#
# A normal CI run executes the Framework stages one by one; this script runs the
# same functions in one process so an operator can reproduce a full measurement
# (and inspect the raw samples) on a workstation.  The private openEuler
# container is created by the build stage and removed by the stop stage, exactly
# as in the workflow.
#
#   ./numpy_test.sh                          # full measurement (PERF_REPS samples)
#   PERF_REPS=1 ./numpy_test.sh --keep-workdir
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
    case "${PERF_WORK_DIR}" in
        /home/runner/boostkit-perf/numpy/local-*) ;;
        *)
            log_message "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
            return 70
            ;;
    esac
    rm -rf -- "${PERF_WORK_DIR}" || return 70
    log_message "cleaned standalone work directory: ${PERF_WORK_DIR}"
}

emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then
        stop_numpy_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_numpy_standalone() {
    local stage_status=0 failed_stage=""
    configure_runtime_paths || return $?
    STANDALONE_STOP_DONE=0
    STANDALONE_CLEANUP_DONE=0
    trap emergency_standalone_cleanup EXIT
    initialize_runtime || return $?

    if ! build_numpy; then
        stage_status=$?
        failed_stage="build"
    fi
    if [[ "${stage_status}" -eq 0 ]] && ! start_numpy_runtime; then
        stage_status=$?
        failed_stage="start"
    fi
    if [[ "${stage_status}" -eq 0 ]] && ! run_numpy_benchmarks; then
        stage_status=$?
        failed_stage="test"
    fi

    if ! stop_numpy_runtime; then
        log_message "WARNING: the stop stage reported a cleanup problem"
        [[ "${stage_status}" -eq 0 ]] && stage_status=70
    fi
    STANDALONE_STOP_DONE=1
    if ! cleanup_standalone_workdir; then
        [[ "${stage_status}" -eq 0 ]] && stage_status=70
    fi
    STANDALONE_CLEANUP_DONE=1
    trap - EXIT

    log_message "standalone results: ${RESULTS_DIR}"
    if [[ "${stage_status}" -ne 0 ]]; then
        log_message "ERROR: standalone run failed in stage ${failed_stage} (exit ${stage_status})"
    else
        log_message "standalone run passed"
    fi
    return "${stage_status}"
}

usage() {
    cat <<USAGE
Usage: $(basename "$0") [OPTIONS]

Build the pinned CPython runtime inside the private openEuler container, build
the pinned NumPy 2.4.3 baseline from commit 289c872f, measure the vendored
aggregate ASV suite and publish results/ plus html/.

Options:
  --version VERSION       numpy version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, PERF_REPS, PERF_WARMUPS, PERF_BUILD_JOBS,
  PERF_RUN_ID, RESULTS_DIR, PERF_WORK_DIR, PERF_PROXY
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
            --results-dir)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --results-dir requires a value"; return 10; }
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
                log_message "ERROR: unsupported option: $1"
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
    run_numpy_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log_message "standalone log: ${RESULTS_DIR}/results.log"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
