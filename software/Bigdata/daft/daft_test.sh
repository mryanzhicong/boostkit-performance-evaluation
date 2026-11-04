#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/builders/dispatch.sh"
source "${SCRIPT_DIR}/scripts/stages/start.sh"
source "${SCRIPT_DIR}/scripts/stages/test.sh"
source "${SCRIPT_DIR}/scripts/stages/stop.sh"

usage() { printf 'Usage: %s [--version 0.7.2] [--variant base|optimized] [--results-dir DIR] [--keep-workdir]\n' "$0"; }

main() {
    local status=0 failed='' cleanup=passed keep=0 command_status=passed
    while (($#)); do
        case "$1" in
            --version) [[ $# -ge 2 ]] || return 10; SOFTWARE_VERSION="$2"; shift 2 ;;
            --variant) [[ $# -ge 2 ]] || return 10; PERF_VARIANT="$2"; shift 2 ;;
            --results-dir) [[ $# -ge 2 ]] || return 10; RESULTS_DIR="$2"; shift 2 ;;
            --keep-workdir) keep=1; shift ;;
            -h|--help) usage; return 0 ;;
            *) usage; return 10 ;;
        esac
    done
    configure_runtime_paths || return $?
    [[ ! -e "${PERF_WORK_DIR}" ]] || { log 'ERROR: refusing to reuse work directory'; return 20; }
    initialize_runtime || return $?
    trap 'stop_daft_runtime || true' EXIT
    build_daft || { status=$?; failed=build; }
    if [[ "${status}" -eq 0 ]]; then start_daft_runtime || { status=$?; failed=start; }; fi
    if [[ "${status}" -eq 0 ]]; then run_daft_benchmarks || { status=$?; failed=test; }; fi
    stop_daft_runtime || cleanup=failed
    trap - EXIT
    [[ "${status}" -eq 0 ]] || command_status=failed
    python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" "${RESULTS_DIR}" \
        "${SOFTWARE_VERSION}" "${EXPECTED_ARCH}" "${PERF_RUN_ID}" \
        "${command_status}" "${cleanup}" "${failed}" || status=60
    if [[ "${keep}" -eq 0 && "${cleanup}" == passed && "${PERF_WORK_DIR}" == /home/runner/boostkit-perf/daft/local-* ]]; then
        rm -rf -- "${PERF_WORK_DIR}"
    else
        log "keeping work directory ${PERF_WORK_DIR}"
    fi
    return "${status}"
}

main "$@"
