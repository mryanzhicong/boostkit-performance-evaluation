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
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 1 || "${STANDALONE_OWNS_WORK_DIR}" -ne 1 ]]; then
        return 0
    fi
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/protobuf/local-* || "${PERF_WORK_DIR}" == /home/runner/boostkit-perf/protobuf ]]; then
        log_message "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    fi
    rm -rf -- "${PERF_WORK_DIR}"
}

emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then stop_protobuf_runtime; fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then cleanup_standalone_workdir; fi
}

run_protobuf_standalone() {
    local stage_status=0 failed_stage="" cleanup_status="passed" command_status="passed" finalize_status=0
    configure_runtime_paths || return $?
    trap emergency_standalone_cleanup EXIT
    initialize_runtime || return $?
    standalone_runtime system "${RESULTS_DIR}/system_info.json"
    standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json"
    if build_protobuf; then
        standalone_runtime build-info "${RESULTS_DIR}/build_info.json" \
            "${SOFTWARE_VERSION}" "${PERF_ACTUAL_VERSION_FILE}" \
            "$(normalized_architecture "${EXPECTED_ARCH}")" "${PERF_RUN_ID}" \
            "${CXX_BINARY}" "${CXX_VERSION}" || { stage_status=$?; failed_stage="build"; }
    else
        stage_status=$?; failed_stage="build"
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if start_protobuf_runtime; then :; else stage_status=$?; failed_stage="start"; fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_protobuf_benchmarks; then :; else stage_status=$?; failed_stage="test"; fi
    fi
    if ! stop_protobuf_runtime; then cleanup_status="failed"; fi
    STANDALONE_STOP_DONE=1
    if ! standalone_runtime runtime "${RESULTS_DIR}/runtime_after.json"; then cleanup_status="failed"; fi
    if ! cleanup_standalone_workdir; then cleanup_status="failed"; fi
    STANDALONE_CLEANUP_DONE=1
    if [[ "${stage_status}" -ne 0 ]]; then command_status="failed"; fi
    if standalone_runtime finalize "${RESULTS_DIR}" "${SOFTWARE_VERSION}" \
        "$(normalized_architecture "${EXPECTED_ARCH}")" "${PERF_RUN_ID}" \
        "${command_status}" "${cleanup_status}" "${failed_stage}"; then
        :
    else
        finalize_status=$?
    fi
    trap - EXIT
    if [[ "${stage_status}" -ne 0 ]]; then return "${stage_status}"; fi
    if [[ "${cleanup_status}" != "passed" ]]; then return 70; fi
    return "${finalize_status}"
}

usage() {
    printf '%s\n' \
        "Usage: $(basename "$0") [--version VERSION] [--variant base|optimized] [--results-dir DIR] [--keep-workdir]" \
        "Build Protobuf and run the pinned AccLibBenchmark C++ serialization cases."
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version) SOFTWARE_VERSION="$2"; shift 2 ;;
            --variant) [[ "$#" -ge 2 ]] || return 10; PERF_VARIANT="$2"; shift 2 ;;
            --results-dir) RESULTS_DIR="$2"; shift 2 ;;
            --keep-workdir) STANDALONE_KEEP_WORK_DIR=1; shift ;;
            -h|--help) usage; return 0 ;;
            *) log_message "ERROR: unsupported option: $1"; return 10 ;;
        esac
    done
    validate_variant || return $?
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}"
    : > "${RESULTS_DIR}/results.log"
    set +e
    run_protobuf_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    local pipeline_status="${PIPESTATUS[0]}"
    set -e
    log_message "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
