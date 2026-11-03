#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/builders/dispatch.sh"
source "${SCRIPT_DIR}/scripts/stages/start.sh"
source "${SCRIPT_DIR}/scripts/stages/test.sh"
source "${SCRIPT_DIR}/scripts/stages/stop.sh"

standalone_runtime() {
    python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" "$1" \
        --version "${SOFTWARE_VERSION}" --architecture "${EXPECTED_ARCH}" \
        --run-id "${PERF_RUN_ID}" --results-dir "${RESULTS_DIR}" \
        --work-dir "${PERF_WORK_DIR}" "${@:2}"
}

cleanup_standalone_workdir() {
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 1 || "${STANDALONE_OWNS_WORK_DIR}" -ne 1 ]]; then
        log_message "keeping standalone work directory: ${PERF_WORK_DIR}"
        return 0
    fi
    [[ "${PERF_WORK_DIR}" == /home/runner/boostkit-perf/ray/local-* && \
       "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/ray ]] || return 70
    rm -rf -- "${PERF_WORK_DIR}"
}

run_ray_standalone() {
    local stage=prepare code=0 cleanup_code=0 finalize_code=0
    initialize_runtime || return $?
    if standalone_runtime prepare; then
        stage=build
        if build_ray && standalone_runtime build-info; then
            stage=start
            if start_ray_runtime; then
                stage=test
                if run_ray_benchmark; then stage=complete; else code=$?; fi
            else code=$?; fi
        else code=$?; fi
    else code=$?; fi
    stop_ray_runtime || cleanup_code=$?
    if [[ "${code}" -eq 0 && "${cleanup_code}" -eq 0 ]]; then
        standalone_runtime finalize || finalize_code=$?
    else
        standalone_runtime finalize --status failed --failed-stage "${stage}" || finalize_code=$?
    fi
    cleanup_standalone_workdir || cleanup_code=$?
    if [[ "${code}" -ne 0 ]]; then return "${code}"; fi
    if [[ "${cleanup_code}" -ne 0 ]]; then return "${cleanup_code}"; fi
    return "${finalize_code}"
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version) [[ "$#" -ge 2 ]] || return 10; SOFTWARE_VERSION="$2"; shift 2 ;;
            --variant) [[ "$#" -ge 2 ]] || return 10; PERF_VARIANT="$2"; shift 2 ;;
            --results-dir) [[ "$#" -ge 2 ]] || return 10; RESULTS_DIR="$2"; shift 2 ;;
            --keep-workdir) STANDALONE_KEEP_WORK_DIR=1; shift ;;
            -h|--help)
                printf 'Usage: %s [--version 2.55.1] [--variant base|optimized] [--results-dir DIR] [--keep-workdir]\n' "$0"
                return 0 ;;
            *) log_message "ERROR: unsupported option: $1"; return 10 ;;
        esac
    done
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}"
    local result=0
    set +e
    run_ray_standalone 2>&1 | tee "${RESULTS_DIR}/results.log"
    result="${PIPESTATUS[0]}"
    set -e
    log_message "standalone results: ${RESULTS_DIR}"
    return "${result}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
