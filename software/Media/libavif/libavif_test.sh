#!/usr/bin/env bash
#
# Standalone entry point for the libavif performance case.
#
# A normal CI run executes the Framework stages one by one; this script runs the
# same functions in one process so an operator can reproduce a full measurement
# (and inspect the raw samples) on a workstation.  The private openEuler
# container is created by the build stage and removed by the stop stage, exactly
# as in the workflow.
#
#   ./libavif_test.sh                       # full measurement (20 samples/scenario)
#   LIBAVIF_SAMPLES=5 ./libavif_test.sh --keep-workdir
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
        /home/runner/boostkit-perf/libavif/local-*) ;;
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
        stop_libavif_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_libavif_standalone() {
    local stage_status=0 failed_stage=""
    configure_runtime_paths || return $?
    STANDALONE_STOP_DONE=0
    STANDALONE_CLEANUP_DONE=0
    trap emergency_standalone_cleanup EXIT
    initialize_runtime || return $?

    if ! build_libavif; then
        stage_status=$?
        failed_stage="build"
    fi
    if [[ "${stage_status}" -eq 0 ]] && ! start_libavif_runtime; then
        stage_status=$?
        failed_stage="start"
    fi
    if [[ "${stage_status}" -eq 0 ]] && ! run_libavif_benchmarks; then
        stage_status=$?
        failed_stage="test"
    fi

    if ! stop_libavif_runtime; then
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

Build stock libavif ${SOFTWARE_VERSION} + AOM ${AOM_VERSION} inside the private
openEuler 24.03 LTS SP4 container, encode three 1080p frame-0 images at QP 20/32
with avifenc (AOM, speed 8, 8 jobs, 1x4 tiles) and publish results/ with the
reference CSV, the raw samples and benchmark_libavif.json.
No CPU or memory pinning is applied at any point.

Options:
  --variant base|optimized  Build variant (default: ${PERF_VARIANT}; only base exists)
  --results-dir DIR         Persistent result directory
  --samples N               Measured samples per scenario (default: ${LIBAVIF_SAMPLES}, minimum 5)
  --warmups N               Warm-up iterations (default: ${LIBAVIF_WARMUPS}, minimum 1)
  --keep-workdir            Keep the isolated work directory for debugging
  -h, --help                Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, LIBAVIF_SAMPLES, LIBAVIF_WARMUPS,
  LIBAVIF_BUILD_JOBS, LIBAVIF_MEDIA_DIR, LIBAVIF_SOURCE_ARCHIVE_DIR,
  PERF_RUN_ID, RESULTS_DIR, PERF_WORK_DIR, PERF_PROXY
USAGE
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --variant)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --variant requires a value"; return 10; }
                PERF_VARIANT="$2"
                shift 2
                ;;
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
            --samples)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --samples requires a value"; return 10; }
                LIBAVIF_SAMPLES="$2"
                shift 2
                ;;
            --warmups)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --warmups requires a value"; return 10; }
                LIBAVIF_WARMUPS="$2"
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
    run_libavif_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log_message "standalone log: ${RESULTS_DIR}/results.log"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
