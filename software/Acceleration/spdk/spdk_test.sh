#!/usr/bin/env bash
# Standalone entry point for the SPDK v26.09 bdevperf performance case.
#
# The four framework stages map to: build the pinned SPDK/DPDK/ISA-L sources
# inside this task's private directory (build), probe a DPDK runtime profile on
# the local machine (start), run the bdevperf matrix with a warmup and five
# measured repetitions per scenario (test), and make sure no bdevperf process
# survives (stop).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/builders/dispatch.sh"
source "${SCRIPT_DIR}/scripts/stages/start.sh"
source "${SCRIPT_DIR}/scripts/stages/test.sh"
source "${SCRIPT_DIR}/scripts/stages/stop.sh"

standalone_runtime() { python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" "$@"; }

cleanup_standalone_workdir() {
    [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 0 && "${STANDALONE_OWNS_WORK_DIR}" -eq 1 ]] || return 0
    [[ "${PERF_WORK_DIR}" == /home/runner/boostkit-perf/spdk/local-* ]] || return 70
    rm -rf -- "${PERF_WORK_DIR}"
}

run_spdk_standalone() {
    local status=0 failed_stage="" cleanup_status="passed" stage_status=0
    initialize_runtime || return $?
    standalone_runtime system "${RESULTS_DIR}/system_info.json" || return $?
    standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json" || return $?
    build_spdk || stage_status=$?
    if [[ "${stage_status}" -ne 0 ]]; then
        status="${stage_status}"
        failed_stage="build"
    fi
    if [[ "${status}" -eq 0 ]]; then
        standalone_runtime build-info "${RESULTS_DIR}/build_info.json" \
            "${SOFTWARE_VERSION}" "${PERF_ACTUAL_VERSION_FILE}" \
            "$(normalize_architecture "${EXPECTED_ARCH}")" "${PERF_RUN_ID}" \
            "cc" "$(spdk_container_exec cc --version 2>/dev/null | sed -n '1p')" \
            "${BUILD_META_FILE}" || { status=30; failed_stage="build"; }
    fi
    if [[ "${status}" -eq 0 ]]; then
        stage_status=0
        start_spdk_runtime || stage_status=$?
        if [[ "${stage_status}" -ne 0 ]]; then
            status="${stage_status}"
            failed_stage="start"
        fi
    fi
    if [[ "${status}" -eq 0 ]]; then
        stage_status=0
        run_spdk_benchmarks || stage_status=$?
        if [[ "${stage_status}" -ne 0 ]]; then
            status="${stage_status}"
            failed_stage="test"
        fi
    fi
    stop_spdk_runtime || cleanup_status="failed"
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

Build SPDK v26.09 from pinned sources and run the bdevperf matrix over Malloc
bdevs. This measures the SPDK userspace block stack path, not a physical SSD.
The optimized build is reserved and fails with exit code 30 until implemented.
Results default to results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       SPDK version (default: ${SOFTWARE_VERSION}, only 26.09 is supported)
  --variant VARIANT       base or optimized (default: base)
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, PERF_VARIANT, RESULTS_DIR, PERF_WORK_DIR,
  PERF_REPS (measurement repetitions, default 5),
  PERF_SPDK_DURATION (seconds per measurement, default 5),
  PERF_SPDK_OFFLINE_DIR (pre-provisioned archive directory),
  PERF_SPDK_BUILD_JOBS (build parallelism, default 6), PERF_PROXY
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
    run_spdk_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log" || status="${PIPESTATUS[0]}"
    set -e
    log_message "standalone results: ${RESULTS_DIR}"
    return "${status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
