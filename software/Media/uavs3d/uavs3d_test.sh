#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/builders/dispatch.sh"
source "${SCRIPT_DIR}/scripts/stages/start.sh"
source "${SCRIPT_DIR}/scripts/stages/test.sh"
source "${SCRIPT_DIR}/scripts/stages/stop.sh"

usage() {
    cat <<EOF
Usage: $(basename "$0") [--version 1.2] [--variant base|optimized] [--results-dir DIR]
                        [--video-dir DIR] [--keep-workdir]
Build uavs3d 1.2 and uavs3e 1.3 in a private openEuler container, prepare the
Film2012 AVS3 stream, and run the 16/24-thread decode benchmark.
EOF
}

cleanup_workdir() {
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 1 || "${STANDALONE_OWNS_WORK_DIR}" -ne 1 ]]; then
        log "keeping work directory: ${PERF_WORK_DIR}"
        return 0
    fi
    [[ "${PERF_WORK_DIR}" == /home/runner/boostkit-perf/uavs3d/local-* ]] || {
        log "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    }
    rm -rf -- "${PERF_WORK_DIR}"
}

emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then
        stop_uavs3d_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_workdir
    fi
}

run_standalone() {
    local stage_status=0 failed_stage="" cleanup_status=passed finalize_status=0
    configure_runtime_paths || return $?
    STANDALONE_STOP_DONE=0
    STANDALONE_CLEANUP_DONE=0
    trap emergency_standalone_cleanup EXIT
    initialize_runtime || return $?
    python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" system "${RESULTS_DIR}/system_info.json"
    python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" runtime "${RESULTS_DIR}/runtime_before.json"
    if build_uavs3d; then
        python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" build-info \
            "${RESULTS_DIR}/build_info.json" "${SOFTWARE_VERSION}" \
            "${PERF_ACTUAL_VERSION_FILE}" "${EXPECTED_ARCH}" "${PERF_RUN_ID}" || {
            stage_status=40; failed_stage=build;
        }
    else
        stage_status=$?; failed_stage=build
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if start_uavs3d_runtime; then :; else stage_status=$?; failed_stage=start; fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_uavs3d_benchmarks; then :; else stage_status=$?; failed_stage=test; fi
    fi
    stop_uavs3d_runtime || cleanup_status=failed
    STANDALONE_STOP_DONE=1
    python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" runtime "${RESULTS_DIR}/runtime_after.json" || cleanup_status=failed
    cleanup_workdir || cleanup_status=failed
    STANDALONE_CLEANUP_DONE=1
    local command_status=passed
    [[ "${stage_status}" -eq 0 ]] || command_status=failed
    python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" finalize \
        "${RESULTS_DIR}" "${SOFTWARE_VERSION}" "${EXPECTED_ARCH}" \
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
            --video-dir) [[ "$#" -ge 2 ]] || return 10; UAVS3D_VIDEO_DIR="$2"; shift 2 ;;
            --keep-workdir) STANDALONE_KEEP_WORK_DIR=1; shift ;;
            -h|--help) usage; return 0 ;;
            *) log "ERROR: unsupported option: $1"; usage; return 10 ;;
        esac
    done
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}"
    : > "${RESULTS_DIR}/results.log"
    local status=0
    run_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log" || status="${PIPESTATUS[0]}"
    log "standalone results: ${RESULTS_DIR}"
    return "${status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
