#!/usr/bin/env bash
# Stand-alone entry point of the GDB performance case.
#
# The framework (framework/run_case.py) drives the same stage functions inside
# GitHub Actions.  This entry point runs the identical pipeline outside the
# framework, e.g. on a copy of the case directory:
#
#   software/Toolchain/gdb/gdb_test.sh --results-dir /tmp/gdb-results
#
# The build stage downloads the pinned GDB 18.1 source archive once, builds an
# isolated GDB with the distribution toolchain, compiles the deterministic C
# fixtures and generates a core file.  The test stage then runs ten scenarios
# (startup, three symbol-table sizes, 200 breakpoints, 500 single steps, a full
# symbol traversal, 5000 GDB-Python symbol lookups, a 2000-frame backtrace, a
# 2000-frame backtrace from a core file, and a fixed upstream GDB testsuite
# subset) with one warmup and PERF_REPS independent measurements each.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/builders/dispatch.sh"
source "${SCRIPT_DIR}/scripts/stages/start.sh"
source "${SCRIPT_DIR}/scripts/stages/test.sh"
source "${SCRIPT_DIR}/scripts/stages/stop.sh"

STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0
STANDALONE_KEEP_WORK_DIR=0

standalone_runtime() {
    python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" "$@"
}

remove_standalone_work_dir() {
    if [[ "${STANDALONE_OWNS_WORK_DIR:-0}" != "1" ]]; then
        return 0
    fi
    case "${PERF_WORK_DIR}" in
        /home/runner/boostkit-perf/gdb/local-*|*/boostkit-perf/gdb/local-*) ;;
        *)
            log_message "refusing to remove a work directory that is not a standalone one: ${PERF_WORK_DIR}"
            return 1
            ;;
    esac
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        rm -rf -- "${PERF_WORK_DIR}" || {
            log_message "ERROR: failed to remove ${PERF_WORK_DIR}"
            return 1
        }
    fi
    return 0
}

emergency_standalone_cleanup() {
    if [[ "${STANDALONE_STOP_DONE}" -eq 0 ]]; then
        stop_gdb_runtime || true
        STANDALONE_STOP_DONE=1
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -eq 0 ]]; then
        if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 0 ]]; then
            remove_standalone_work_dir || true
        fi
        STANDALONE_CLEANUP_DONE=1
    fi
}

run_gdb_standalone() {
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
        failed_stage="build"
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if build_gdb; then
            :
        else
            stage_status=$?
            failed_stage="build"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if start_gdb_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_gdb_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_gdb_runtime; then
        cleanup_status="failed"
    fi
    STANDALONE_STOP_DONE=1
    if ! standalone_runtime runtime "${RESULTS_DIR}/runtime_after.json"; then
        cleanup_status="failed"
    fi
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 0 ]]; then
        if ! remove_standalone_work_dir; then
            cleanup_status="failed"
        fi
    fi
    STANDALONE_CLEANUP_DONE=1
    trap - EXIT

    if [[ "${stage_status}" -ne 0 ]]; then
        command_status="failed"
    fi
    if standalone_runtime finalize \
        "${RESULTS_DIR}" \
        "${SOFTWARE_VERSION}" \
        "${EXPECTED_ARCH}" \
        "${PERF_RUN_ID}" \
        "${command_status}" \
        "${cleanup_status}" \
        "${failed_stage}"; then
        finalize_status=0
    else
        finalize_status=$?
    fi
    [[ "${stage_status}" -eq 0 ]] || return "${stage_status}"
    [[ "${cleanup_status}" == "passed" ]] || return 70
    return "${finalize_status}"
}

usage() {
    cat <<USAGE
Usage: $(basename "$0") [OPTIONS]

Build GDB 18.1 from the pinned official source archive into an isolated prefix,
compile the deterministic C fixtures and generate a core file, then run the complete
GDB workload matrix: startup, symbol loads of 1000/10000/50000 functions, 200 function
breakpoints, 500 single steps, a full symbol traversal, 5000 GDB-Python symbol lookups,
a 2000-frame backtrace, a 2000-frame backtrace from a core file, and a fixed upstream
GDB testsuite subset.  One warmup and PERF_REPS (default 5) independent measurements
are taken per scenario; the median is reported and the complete distribution is kept.

Options:
  --version VERSION       Source version (default: ${SOFTWARE_VERSION})
  --variant VARIANT       base or optimized (default: base; optimized is unsupported)
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, PERF_VARIANT, RESULTS_DIR, PERF_WORK_DIR,
  PERF_REPS, GDB_BUILD_JOBS, GDB_OFFLINE_DIR
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

    validate_variant || return $?
    configure_runtime_paths || return $?
    if ! mkdir -p "${RESULTS_DIR}"; then
        log_message "ERROR: failed to create the standalone results directory: ${RESULTS_DIR}"
        return 10
    fi
    : > "${RESULTS_DIR}/results.log"
    local pipeline_status=0
    set +e
    run_gdb_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log_message "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
