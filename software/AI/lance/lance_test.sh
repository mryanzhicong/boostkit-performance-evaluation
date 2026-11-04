#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/builders/dispatch.sh"
source "${SCRIPT_DIR}/scripts/stages/start.sh"
source "${SCRIPT_DIR}/scripts/stages/test.sh"
source "${SCRIPT_DIR}/scripts/stages/stop.sh"

usage() {
    printf 'Usage: %s [--version 13.0.0] [--variant base|optimized] [--results-dir DIR] [--keep-workdir]\n' "$(basename "$0")"
}

main() {
    local keep_workdir=0 status=0 failed_stage="" cleanup_status=passed final_status=0
    while (($#)); do
        case "$1" in
            --version) [[ $# -ge 2 ]] || return 10; SOFTWARE_VERSION="$2"; shift 2 ;;
            --variant) [[ $# -ge 2 ]] || return 10; PERF_VARIANT="$2"; shift 2 ;;
            --results-dir) [[ $# -ge 2 ]] || return 10; RESULTS_DIR="$2"; shift 2 ;;
            --keep-workdir) keep_workdir=1; shift ;;
            -h|--help) usage; return 0 ;;
            *) usage; return 10 ;;
        esac
    done
    configure_runtime_paths || return $?
    if [[ "${STANDALONE_OWNS_WORK_DIR}" -eq 1 && -e "${PERF_WORK_DIR}" ]]; then
        log "ERROR: refusing to reuse an existing standalone work directory: ${PERF_WORK_DIR}"
        return 20
    fi
    initialize_runtime || return $?
    trap 'stop_lance_runtime || true' EXIT
    python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" system "${RESULTS_DIR}/system_info.json"
    python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" runtime "${RESULTS_DIR}/runtime_before.json"
    if build_lance; then
        python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" build-info \
            "${RESULTS_DIR}/build_info.json" "${SOFTWARE_VERSION}" \
            "${PERF_ACTUAL_VERSION_FILE}" "${EXPECTED_ARCH}" "${PERF_RUN_ID}" || {
            status=40; failed_stage=build;
        }
    else
        status=$?; failed_stage=build
    fi
    if [[ "${status}" -eq 0 ]]; then
        start_lance_runtime || { status=$?; failed_stage=start; }
    fi
    if [[ "${status}" -eq 0 ]]; then
        run_lance_benchmarks || { status=$?; failed_stage=test; }
    fi
    stop_lance_runtime || cleanup_status=failed
    trap - EXIT
    python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" runtime "${RESULTS_DIR}/runtime_after.json" || cleanup_status=failed
    local command_status=passed
    [[ "${status}" -eq 0 ]] || command_status=failed
    python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" finalize \
        "${RESULTS_DIR}" "${SOFTWARE_VERSION}" "${EXPECTED_ARCH}" "${PERF_RUN_ID}" \
        "${command_status}" "${cleanup_status}" "${failed_stage}" || final_status=$?
    if [[ "${cleanup_status}" == passed && "${keep_workdir}" -ne 1 && \
          "${STANDALONE_OWNS_WORK_DIR}" -eq 1 && \
          "${PERF_WORK_DIR}" == /home/runner/boostkit-perf/lance/local-* ]]; then
        rm -rf -- "${PERF_WORK_DIR}"
    else
        log "keeping private work directory: ${PERF_WORK_DIR}"
    fi
    [[ "${status}" -eq 0 ]] || return "${status}"
    [[ "${cleanup_status}" == passed ]] || return 70
    return "${final_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
