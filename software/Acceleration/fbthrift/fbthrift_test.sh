#!/usr/bin/env bash
# Standalone runner for the fbthrift RPC case (build -> start -> test -> stop).
set -euo pipefail

CASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="${CASE_DIR}"

usage() {
    cat <<'USAGE'
Usage: ./fbthrift_test.sh --version 2022.11.14.00 [options]

Options:
  --version VERSION      Stack tag v<VERSION> (default: 2022.11.14.00)
  --variant base         Build variant (only base is implemented)
  --results-dir DIR      Result directory (default: results/<version>/<run id>)
  --work-dir DIR         Task work directory (default: /home/runner/boostkit-perf/...)
  --keep-workdir         Keep the task work directory after the run
  -h, --help             Show this help
USAGE
}

main() {
    local version="${SOFTWARE_VERSION:-2022.11.14.00}" variant="base" results_dir="" work_dir=""
    while (($#)); do
        case "$1" in
            --version) [[ "$#" -ge 2 ]] || { echo 'ERROR: --version needs a value' >&2; return 10; }; version="$2"; shift 2 ;;
            --variant) [[ "$#" -ge 2 ]] || { echo 'ERROR: --variant needs a value' >&2; return 10; }; variant="$2"; shift 2 ;;
            --results-dir) [[ "$#" -ge 2 ]] || { echo 'ERROR: --results-dir needs a value' >&2; return 10; }; results_dir="$2"; shift 2 ;;
            --work-dir) [[ "$#" -ge 2 ]] || { echo 'ERROR: --work-dir needs a value' >&2; return 10; }; work_dir="$2"; shift 2 ;;
            --keep-workdir) STANDALONE_KEEP_WORK_DIR=1; shift ;;
            -h|--help) usage; return 0 ;;
            *) echo "ERROR: unsupported option: $1" >&2; usage; return 10 ;;
        esac
    done
    export SOFTWARE_VERSION="${version}" PERF_VARIANT="${variant}"
    export RESULTS_DIR="${results_dir}" PERF_WORK_DIR="${work_dir}"
    source "${SCRIPT_DIR}/scripts/builders/dispatch.sh"
    source "${SCRIPT_DIR}/scripts/stages/start.sh"
    source "${SCRIPT_DIR}/scripts/stages/test.sh"
    source "${SCRIPT_DIR}/scripts/stages/stop.sh"
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}"
    printf '%s\n' "${PERF_RUN_ID}" > "${RESULTS_DIR}/run-id.txt"
    local status=0
    build_fbthrift || status=$?
    if ((status == 0)); then
        start_fbthrift_runtime || status=$?
    fi
    if ((status == 0)); then
        run_fbthrift_benchmarks || status=$?
    fi
    stop_fbthrift_runtime || true
    if ((status != 0)); then
        log_message "ERROR: the run failed with status ${status}"
        return "${status}"
    fi
    log_message "results: ${RESULTS_DIR}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
