#!/usr/bin/env bash
# Compare upstream Folly using AccLibBenchmark's fbthrift RPC client/server.
#
# The four framework stages map to: build the unmodified upstream Folly stack
# and the AccLibBenchmark RPC tool inside this task's private directory
# (build), start the private press_server on a derived local port (start),
# run the AccLibBenchmark RPC matrix through press_client (test), and stop the
# private press_server (stop).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/builders/dispatch.sh"
source "${SCRIPT_DIR}/scripts/stages/start.sh"
source "${SCRIPT_DIR}/scripts/stages/test.sh"
source "${SCRIPT_DIR}/scripts/stages/stop.sh"

standalone_runtime() { python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" "$@"; }

cleanup_standalone_workdir() {
    [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 0 && "${STANDALONE_OWNS_WORK_DIR}" -eq 1 ]] || return 0
    [[ "${PERF_WORK_DIR}" == /home/runner/boostkit-perf/folly/local-* ]] || return 70
    rm -rf -- "${PERF_WORK_DIR}"
}

run_folly_standalone() {
    local status=0 failed_stage="" cleanup_status="passed"
    initialize_runtime || return $?
    standalone_runtime system "${RESULTS_DIR}/system_info.json" || return $?
    standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json" || return $?
    if ! build_folly; then status=40; failed_stage="build"; fi
    if [[ "${status}" -eq 0 ]]; then
        standalone_runtime build-info "${RESULTS_DIR}/build_info.json" \
            "${SOFTWARE_VERSION}" "${PERF_ACTUAL_VERSION_FILE}" \
            "$(normalize_architecture "${EXPECTED_ARCH}")" "${PERF_RUN_ID}" \
            "${COMPILER_BINARY}" "${COMPILER_VERSION_STRING}" || { status=40; failed_stage="build"; }
    fi
    if [[ "${status}" -eq 0 ]] && ! start_folly_runtime; then status=40; failed_stage="start"; fi
    if [[ "${status}" -eq 0 ]] && ! run_folly_benchmarks; then status=50; failed_stage="test"; fi
    stop_folly_runtime || cleanup_status="failed"
    standalone_runtime runtime "${RESULTS_DIR}/runtime_after.json" || cleanup_status="failed"
    cleanup_standalone_workdir || cleanup_status="failed"
    local command_status="passed"
    [[ "${status}" -eq 0 ]] || command_status="failed"
    standalone_runtime finalize "${RESULTS_DIR}" "${SOFTWARE_VERSION}" \
        "$(normalize_architecture "${EXPECTED_ARCH}")" "${PERF_RUN_ID}" \
        "${command_status}" "${cleanup_status}" "${failed_stage}" || return $?
    return "${status}"
}

usage() {
    cat <<USAGE
Usage: $(basename "$0") [OPTIONS]

Build the unmodified upstream Folly stack and run the AccLibBenchmark RPC
matrix as a standalone performance evaluation. The optimized build is
reserved and fails until its implementation is supplied. Results default to
results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       Folly version (default: ${SOFTWARE_VERSION})
  --variant VARIANT       base or optimized (default: base)
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, PERF_VARIANT, RESULTS_DIR, PERF_WORK_DIR,
  FOLLY_SOURCE_URL, FAST_FLOAT_SOURCE_URL
USAGE
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --version requires a value"; return 10; }
                SOFTWARE_VERSION="$2"; shift 2 ;;
            --variant)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --variant requires a value"; return 10; }
                PERF_VARIANT="$2"; shift 2 ;;
            --results-dir)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --results-dir requires a value"; return 10; }
                RESULTS_DIR="$2"; shift 2 ;;
            --keep-workdir) STANDALONE_KEEP_WORK_DIR=1; shift ;;
            -h|--help) usage; return 0 ;;
            *) log_message "ERROR: unsupported option: $1"; usage; return 10 ;;
        esac
    done
    validate_variant || return $?
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}"
    : > "${RESULTS_DIR}/results.log"
    local status=0
    set +e
    run_folly_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log" || status="${PIPESTATUS[0]}"
    set -e
    log_message "standalone results: ${RESULTS_DIR}"
    return "${status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
