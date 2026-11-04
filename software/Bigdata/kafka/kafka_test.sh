#!/usr/bin/env bash
set -euo pipefail

CASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${CASE_DIR}/scripts/builders/dispatch.sh"
source "${CASE_DIR}/scripts/stages/start.sh"
source "${CASE_DIR}/scripts/stages/test.sh"
source "${CASE_DIR}/scripts/stages/stop.sh"

standalone_runtime() {
    python3 "${CASE_DIR}/scripts/results/standalone_runtime.py" "$@"
}

cleanup_private_workdir() {
    if [[ "${STANDALONE_KEEP_WORK_DIR:-0}" == 1 ]]; then
        log_message "keeping standalone work directory: ${PERF_WORK_DIR}"
        return 0
    fi
    [[ "${PERF_WORK_DIR}" == /home/runner/boostkit-perf/kafka/local-* && \
       "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/kafka ]] || {
        log_message "ERROR: refusing to remove unexpected work directory: ${PERF_WORK_DIR}"; return 70;
    }
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        rm -rf -- "${PERF_WORK_DIR}" || return 70
    fi
}

run_kafka_standalone() {
    local status=passed stage= cleanup=passed exit_code=0
    initialize_runtime || return $?
    trap 'stop_kafka_runtime >/dev/null 2>&1 || true' EXIT
    standalone_runtime system "${RESULTS_DIR}/system_info.json" || return 20
    standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json" || return 20
    if build_kafka; then
        standalone_runtime build-info "${RESULTS_DIR}/build_info.json" \
            "${SOFTWARE_VERSION}" "${PERF_ACTUAL_VERSION_FILE}" "${EXPECTED_ARCH}" "${PERF_RUN_ID}" || {
            status=failed; stage=build; exit_code=40;
        }
    else
        exit_code=$?; status=failed; stage=build
    fi
    if (( exit_code == 0 )); then
        if start_kafka_runtime; then :; else exit_code=$?; status=failed; stage=start; fi
    fi
    if (( exit_code == 0 )); then
        if run_kafka_benchmark; then :; else exit_code=$?; status=failed; stage=test; fi
    fi
    if ! stop_kafka_runtime; then cleanup=failed; fi
    standalone_runtime runtime "${RESULTS_DIR}/runtime_after.json" || cleanup=failed
    if ! cleanup_private_workdir; then cleanup=failed; fi
    standalone_runtime finalize "${RESULTS_DIR}" "${SOFTWARE_VERSION}" "${EXPECTED_ARCH}" \
        "${PERF_RUN_ID}" "${status}" "${cleanup}" "${stage}" || exit_code=60
    trap - EXIT
    if (( exit_code != 0 )); then return "${exit_code}"; fi
    [[ "${cleanup}" == passed ]] || return 70
}

usage() {
    printf 'Usage: %s [--version 2.5.0] [--variant base|optimized] [--results-dir DIR] [--keep-workdir]\n' "$(basename "$0")"
}

main() {
    while (( $# > 0 )); do
        case "$1" in
            --version|--variant|--results-dir)
                (( $# >= 2 )) || { usage; return 10; }
                case "$1" in
                    --version) SOFTWARE_VERSION="$2" ;;
                    --variant) PERF_VARIANT="$2" ;;
                    --results-dir) RESULTS_DIR="$2" ;;
                esac
                shift 2 ;;
            --keep-workdir) STANDALONE_KEEP_WORK_DIR=1; shift ;;
            -h|--help) usage; return 0 ;;
            *) usage; return 10 ;;
        esac
    done
    run_kafka_standalone
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
