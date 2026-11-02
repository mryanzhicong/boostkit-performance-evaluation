#!/usr/bin/env bash
# Standalone entry point for the fbthrift ProtocolBench performance case.
#
# The four framework stages map to: build the pinned fbthrift/folly stack and
# ProtocolBench in this task's private directory (build), verify the private
# binary and its case matrix (start), run the warmup + repetition matrix
# (test), and confirm the stateless benchmark left nothing behind (stop).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/builders/dispatch.sh"
source "${SCRIPT_DIR}/scripts/stages/start.sh"
source "${SCRIPT_DIR}/scripts/stages/test.sh"
source "${SCRIPT_DIR}/scripts/stages/stop.sh"

standalone_runtime() { python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" "$@"; }

cleanup_standalone_workdir() {
    [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 0 && "${STANDALONE_OWNS_WORK_DIR}" -eq 1 ]] || return 0
    [[ "${PERF_WORK_DIR}" == /home/runner/boostkit-perf/fbthrift/local-* ]] || return 70
    rm -rf -- "${PERF_WORK_DIR}"
}

run_fbthrift_standalone() {
    local status=0 failed_stage="" cleanup_status="passed"
    local compiler_binary="${CXX:-c++}"
    local compiler_version
    compiler_version="$("${compiler_binary}" --version 2>/dev/null | head -n 1)"
    initialize_runtime || return $?
    standalone_runtime system "${RESULTS_DIR}/system_info.json" || return $?
    standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json" || return $?
    if ! build_fbthrift; then status=30; failed_stage="build"; fi
    if [[ "${status}" -eq 0 ]]; then
        standalone_runtime build-info "${RESULTS_DIR}/build_info.json" \
            "${SOFTWARE_VERSION}" "${PERF_ACTUAL_VERSION_FILE}" \
            "$(normalize_architecture "${EXPECTED_ARCH}")" "${PERF_RUN_ID}" \
            "${compiler_binary}" "${compiler_version:-unknown}" || { status=30; failed_stage="build"; }
    fi
    if [[ "${status}" -eq 0 ]] && ! start_fbthrift_runtime; then
        status=20
        failed_stage="start"
    fi
    if [[ "${status}" -eq 0 ]] && ! run_fbthrift_benchmarks; then
        status=50
        failed_stage="test"
    fi
    stop_fbthrift_runtime || cleanup_status="failed"
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

Build the pinned fbthrift v${SOFTWARE_VERSION} stack (folly + google benchmark
included) and run the upstream ProtocolBench protocol serialization matrix as a
standalone performance evaluation. The optimized build is reserved and fails
until its implementation is supplied. Results default to
results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       fbthrift version (default: ${SOFTWARE_VERSION})
  --variant VARIANT       base or optimized (default: base)
  --results-dir DIR       Persistent result directory
  --work-dir DIR          Reuse a specific private work directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, PERF_VARIANT, RESULTS_DIR, PERF_WORK_DIR,
  PERF_REPS (default 5), PERF_WARMUP_RUNS (default 1),
  PERF_BENCHMARK_MIN_TIME (default 5s), PERF_BUILD_JOBS (default 6),
  PERF_CMAKE_BIN, PERF_PROXY, PERF_FBTHRIFT_OFFLINE_DIR
USAGE
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --version requires a value"; return 20; }
                SOFTWARE_VERSION="$2"; shift 2 ;;
            --variant)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --variant requires a value"; return 20; }
                PERF_VARIANT="$2"; shift 2 ;;
            --results-dir)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --results-dir requires a value"; return 20; }
                RESULTS_DIR="$2"; shift 2 ;;
            --work-dir)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --work-dir requires a value"; return 20; }
                PERF_WORK_DIR="$2"; shift 2 ;;
            --keep-workdir) STANDALONE_KEEP_WORK_DIR=1; shift ;;
            -h|--help) usage; return 0 ;;
            *) log_message "ERROR: unsupported option: $1"; usage; return 20 ;;
        esac
    done
    validate_variant || return 20
    configure_runtime_paths || return 20
    mkdir -p "${RESULTS_DIR}"
    : > "${RESULTS_DIR}/results.log"
    local status=0
    set +e
    run_fbthrift_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log" || status="${PIPESTATUS[0]}"
    set -e
    log_message "standalone results: ${RESULTS_DIR}"
    return "${status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
