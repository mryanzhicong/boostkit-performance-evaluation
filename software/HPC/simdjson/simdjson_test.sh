#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/builders/dispatch.sh"
source "${SCRIPT_DIR}/scripts/stages/start.sh"
source "${SCRIPT_DIR}/scripts/stages/test.sh"
source "${SCRIPT_DIR}/scripts/stages/stop.sh"

usage() {
    cat <<EOF
Usage: $(basename "$0") [--version 4.6.11] [--variant base] [--results-dir DIR] [--keep-workdir]
Build unmodified upstream simdjson 4.6.11 inside a private openEuler container and run
the official DOM tools plus the three Google Benchmark suites.
EOF
}

cleanup_workdir() {
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 1 || "${STANDALONE_OWNS_WORK_DIR}" -ne 1 ]]; then
        log_message "keeping work directory: ${PERF_WORK_DIR}"
        return 0
    fi
    local pattern="/.perf-work/simdjson/${SOFTWARE_VERSION}/"
    [[ "${PERF_WORK_DIR}" == *"${pattern}"* ]] || {
        log_message "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    }
    rm -rf -- "${PERF_WORK_DIR}"
}

emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then
        stop_simdjson_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_workdir
    fi
}

run_standalone() {
    local stage_status=0 failed_stage="" cleanup_status=passed finalize_status=0
    STANDALONE_OWNS_WORK_DIR=1
    simdjson_configure_paths || return $?
    STANDALONE_STOP_DONE=0
    STANDALONE_CLEANUP_DONE=0
    export PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual_version.txt"
    trap emergency_standalone_cleanup EXIT
    simdjson_initialize_runtime || return $?
    python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" system "${RESULTS_DIR}/system_info.json"
    python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" runtime "${RESULTS_DIR}/runtime_before.json"
    if build_simdjson; then
        python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" build-info \
            "${RESULTS_DIR}/build_info.json" "${SOFTWARE_VERSION}" \
            "${PERF_ACTUAL_VERSION_FILE}" "$(simdjson_arch "${EXPECTED_ARCH}")" "${PERF_RUN_ID}" || {
            stage_status=40; failed_stage=build;
        }
    else
        stage_status=$?; failed_stage=build
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if start_simdjson_runtime; then :; else stage_status=$?; failed_stage=start; fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_simdjson_benchmarks; then :; else stage_status=$?; failed_stage=test; fi
    fi
    stop_simdjson_runtime || cleanup_status=failed
    STANDALONE_STOP_DONE=1
    python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" runtime "${RESULTS_DIR}/runtime_after.json" || cleanup_status=failed
    cleanup_workdir || cleanup_status=failed
    STANDALONE_CLEANUP_DONE=1
    local command_status=passed
    [[ "${stage_status}" -eq 0 ]] || command_status=failed
    python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" finalize \
        "${RESULTS_DIR}" "${SOFTWARE_VERSION}" "$(simdjson_arch "${EXPECTED_ARCH}")" \
        "${PERF_RUN_ID}" "${command_status}" "${cleanup_status}" "${failed_stage}" || finalize_status=$?
    trap - EXIT
    [[ "${stage_status}" -eq 0 ]] || return "${stage_status}"
    [[ "${cleanup_status}" == passed ]] || return 70
    return "${finalize_status}"
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version) [[ "$#" -ge 2 ]] || return 10; SOFTWARE_VERSION="$2"; shift 2 ;;
            --variant) [[ "$#" -ge 2 ]] || return 10; PERF_VARIANT="$2"; shift 2 ;;
            --results-dir) [[ "$#" -ge 2 ]] || return 10; RESULTS_DIR="$2"; shift 2 ;;
            --keep-workdir) STANDALONE_KEEP_WORK_DIR=1; shift ;;
            -h|--help) usage; return 0 ;;
            *) log_message "ERROR: unsupported option: $1"; usage; return 10 ;;
        esac
    done
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: unsupported build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
    simdjson_configure_paths || return $?
    mkdir -p "${RESULTS_DIR}"
    : > "${RESULTS_DIR}/results.log"
    local status=0
    run_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log" || status="${PIPESTATUS[0]}"
    log_message "standalone results: ${RESULTS_DIR}"
    return "${status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
