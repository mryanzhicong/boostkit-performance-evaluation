#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/builders/dispatch.sh"
source "$SCRIPT_DIR/scripts/stages/start.sh"
source "$SCRIPT_DIR/scripts/stages/test.sh"
source "$SCRIPT_DIR/scripts/stages/stop.sh"
main() {
    local status=0 failed='' cleanup=passed command_status=passed
    while (($#)); do
        case "$1" in
            --version) [[ $# -ge 2 ]] || return 10; SOFTWARE_VERSION="$2"; shift 2 ;;
            --variant) [[ $# -ge 2 ]] || return 10; PERF_VARIANT="$2"; shift 2 ;;
            --results-dir) [[ $# -ge 2 ]] || return 10; RESULTS_DIR="$2"; shift 2 ;;
            -h|--help) echo 'Usage: spark_test.sh --version 3.5.2 --variant base --results-dir DIR'; return 0 ;;
            *) return 10 ;;
        esac
    done
    configure_runtime_paths || return $?
    [[ ! -e "$PERF_WORK_DIR" ]] || { echo 'Refusing to reuse work directory'; return 20; }
    initialize_runtime || return $?
    trap 'if stop_spark_runtime; then rm -rf -- "$PERF_WORK_DIR"; fi' EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    build_spark || { status=$?; failed=build; }
    if [[ "$status" == 0 ]]; then start_spark_runtime || { status=$?; failed=start; }; fi
    if [[ "$status" == 0 ]]; then run_spark_benchmarks || { status=$?; failed=test; }; fi
    stop_spark_runtime || cleanup=failed
    trap - EXIT
    [[ "$status" == 0 ]] || command_status=failed
    python3 "$SCRIPT_DIR/scripts/results/standalone_runtime.py" "$RESULTS_DIR" "$SOFTWARE_VERSION" \
        "$EXPECTED_ARCH" "$PERF_RUN_ID" "$command_status" "$cleanup" "$failed" || status=60
    if [[ "$cleanup" == passed ]]; then rm -rf -- "$PERF_WORK_DIR"; fi
    return "$status"
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi
