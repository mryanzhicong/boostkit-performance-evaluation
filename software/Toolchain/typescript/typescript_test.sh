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
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 1 ]]; then
        log_message "keeping standalone work directory: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${STANDALONE_OWNS_WORK_DIR}" -ne 1 ]]; then
        log_message "external work directory was not removed: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/typescript/local-* || \
          "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/typescript" ]]; then
        log_message "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    fi
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        if ! rm -rf -- "${PERF_WORK_DIR}"; then
            log_message "ERROR: failed to clean standalone work directory: ${PERF_WORK_DIR}"
            return 70
        fi
    fi
    log_message "cleaned standalone work directory: ${PERF_WORK_DIR}"
}

emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then
        stop_typescript_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_typescript_standalone() {
    local stage_status=0 failed_stage="" cleanup_status="passed" finalize_status=0
    local command_status="passed" node_version=""

    configure_runtime_paths || return $?
    STANDALONE_STOP_DONE=0
    STANDALONE_CLEANUP_DONE=0
    trap emergency_standalone_cleanup EXIT
    initialize_runtime || return $?

    if standalone_runtime system "${RESULTS_DIR}/system_info.json" && \
        standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json"; then
        :
    else
        stage_status=$?
        failed_stage="prepare"
    fi

    if [[ "${stage_status}" -eq 0 ]]; then
        if build_typescript; then
            node_version="$("${NODE_BIN}" --version 2>/dev/null || true)"
            if standalone_runtime build-info \
                "${RESULTS_DIR}/build_info.json" \
                "${SOFTWARE_VERSION}" \
                "${PERF_ACTUAL_VERSION_FILE}" \
                "${EXPECTED_ARCH}" \
                "${PERF_RUN_ID}" \
                "${node_version}" \
                --node-url="${TARBALL_URLS[0]}" \
                --node-sha256="${TARBALL_SHA256}" \
                --typescript-url="${TS_REGISTRY}/typescript/-/${TS_TARBALL_NAME}" \
                --typescript-sha256="${TS_TARBALL_SHA256}" \
                --typescript-sha512="${TS_TARBALL_SHA512_B64}" \
                --native-backend="${PLATFORM_NAME}" \
                --native-backend-url="${PLATFORM_TARBALL_URL}" \
                --native-backend-sha256="${PLATFORM_SHA256}" \
                --native-backend-sha512="${PLATFORM_SHA512}" \
                --typescript-engines="${TS_NODE_ENGINES}" \
                --registry="${TS_REGISTRY}"; then
                :
            else
                stage_status=$?
                failed_stage="build"
            fi
        else
            stage_status=$?
            failed_stage="build"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if start_typescript_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_typescript_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_typescript_runtime; then
        cleanup_status="failed"
    fi
    STANDALONE_STOP_DONE=1
    if ! standalone_runtime runtime "${RESULTS_DIR}/runtime_after.json"; then
        cleanup_status="failed"
    fi
    if ! cleanup_standalone_workdir; then
        cleanup_status="failed"
    fi
    STANDALONE_CLEANUP_DONE=1

    if [[ "${stage_status}" -ne 0 ]]; then
        command_status="failed"
    fi
    if standalone_runtime finalize \
        "${RESULTS_DIR}" \
        "${SOFTWARE_VERSION}" \
        "${EXPECTED_ARCH}" \
        "${PERF_RUN_ID}" \
        "${command_status}" \
        "${cleanup_status}" \
        "${failed_stage}"; then
        finalize_status=0
    else
        finalize_status=$?
    fi
    trap - EXIT
    [[ "${stage_status}" -eq 0 ]] || return "${stage_status}"
    [[ "${cleanup_status}" == "passed" ]] || return 70
    return "${finalize_status}"
}

usage() {
    cat <<USAGE
Usage: $(basename "$0") [OPTIONS]

Install the pinned Node.js runtime and the pinned TypeScript 7.0.2 release with
its native compiler backend, generate the deterministic project matrix, then run
the complete TypeScript workload matrix: full type checks of 100/1000/5000
module programs, a real upstream project (zod), JavaScript + declaration emit,
a warm incremental re-check, an incremental re-check after a source change and a
project-references build.
The optimized variant is reserved and fails until its implementation is supplied.

Options:
  --version VERSION       TypeScript version (default: ${SOFTWARE_VERSION})
  --variant VARIANT       base or optimized (default: base)
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, PERF_VARIANT, RESULTS_DIR, PERF_WORK_DIR,
  PERF_REPS, PERF_TS_REGISTRY, TS_OFFLINE_DIR
USAGE
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --version requires a value"; return 10; }
                SOFTWARE_VERSION="$2"
                shift 2
                ;;
            --variant)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --variant requires a value"; return 10; }
                PERF_VARIANT="$2"
                shift 2
                ;;
            --results-dir)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --results-dir requires a value"; return 10; }
                RESULTS_DIR="$2"
                shift 2
                ;;
            --keep-workdir)
                STANDALONE_KEEP_WORK_DIR=1
                shift
                ;;
            -h|--help)
                usage
                return 0
                ;;
            *)
                log_message "ERROR: unsupported option: $1"
                usage
                return 10
                ;;
        esac
    done

    validate_variant || return $?
    configure_runtime_paths || return $?
    if ! mkdir -p "${RESULTS_DIR}"; then
        log_message "ERROR: failed to create the standalone results directory: ${RESULTS_DIR}"
        return 10
    fi
    : > "${RESULTS_DIR}/results.log"
    local pipeline_status=0
    set +e
    run_typescript_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log_message "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
