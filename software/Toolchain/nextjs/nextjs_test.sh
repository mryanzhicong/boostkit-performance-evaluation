#!/usr/bin/env bash
# Standalone entry point of the Next.js performance case.
#
# The framework (framework/run_case.py) drives the same stage functions inside
# GitHub Actions.  This script runs the identical pipeline outside the framework so
# a developer can reproduce the evidence on a copy of the case directory:
#
#   software/Toolchain/nextjs/nextjs_test.sh --results-dir /tmp/nextjs-results
#
# The case installs the pinned Node.js archive and the pinned Next.js release with
# the committed lockfile (network only for that one installation), generates the
# deterministic project matrix, then measures nine scenarios: six production
# builds (including a warm incremental rebuild and the official upstream example)
# and three loopback HTTP scenarios against a production server.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/builders/dispatch.sh"
source "${SCRIPT_DIR}/scripts/stages/start.sh"
source "${SCRIPT_DIR}/scripts/stages/test.sh"
source "${SCRIPT_DIR}/scripts/stages/stop.sh"

STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0
STANDALONE_KEEP_WORK_DIR=0

standalone_runtime() {
    python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" "$@"
}

remove_standalone_work_dir() {
    if [[ "${STANDALONE_OWNS_WORK_DIR:-0}" != "1" ]]; then
        return 0
    fi
    case "${PERF_WORK_DIR}" in
        /home/runner/boostkit-perf/nextjs/local-*|*/boostkit-perf/nextjs/local-*) ;;
        *)
            log_message "refusing to remove a work directory that is not a standalone one: ${PERF_WORK_DIR}"
            return 1
            ;;
    esac
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        rm -rf -- "${PERF_WORK_DIR}" || {
            log_message "ERROR: failed to remove ${PERF_WORK_DIR}"
            return 1
        }
    fi
    return 0
}

emergency_standalone_cleanup() {
    if [[ "${STANDALONE_STOP_DONE}" -eq 0 ]]; then
        stop_nextjs_runtime || true
        STANDALONE_STOP_DONE=1
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -eq 0 ]]; then
        if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 0 ]]; then
            remove_standalone_work_dir || true
        fi
        STANDALONE_CLEANUP_DONE=1
    fi
}

run_nextjs_standalone() {
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
        failed_stage="build"
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if build_nextjs; then
            :
        else
            stage_status=$?
            failed_stage="build"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        # The pinned runtime is installed by the build stage, so its version is read
        # only after the build succeeded.
        node_version="$("${NODE_BIN}" --version 2>/dev/null || true)"
        if python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" build-info \
            "${RESULTS_DIR}/build_info.json" \
            "${SOFTWARE_VERSION}" \
            "${PERF_ACTUAL_VERSION_FILE}" \
            "${EXPECTED_ARCH}" \
            "${PERF_RUN_ID}" \
            "${node_version}" \
            --node-url "${NODE_TARBALL_URLS[1]}" \
            --node-sha256 "${NODE_SHA256}" \
            --next-url "${NEXT_TARBALL_URL_PRIMARY}" \
            --next-sha256 "${NEXT_TARBALL_SHA256}" \
            --next-sha512 "${NEXT_TARBALL_SHA512_B64}" \
            --npm-version "${NEXT_NPM_VERSION:-unknown}" \
            --dependency-lockfile-sha256 "${NEXT_DEPENDENCY_LOCKFILE_SHA256}" \
            --native-backend "${SWC_PACKAGE}" \
            --next-engines "${NEXT_NODE_ENGINES}" \
            --registry "${NPM_REGISTRY}"; then
            :
        else
            stage_status=$?
            failed_stage="build"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if start_nextjs_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_nextjs_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_nextjs_runtime; then
        cleanup_status="failed"
    fi
    STANDALONE_STOP_DONE=1
    if ! standalone_runtime runtime "${RESULTS_DIR}/runtime_after.json"; then
        cleanup_status="failed"
    fi
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 0 ]]; then
        if ! remove_standalone_work_dir; then
            cleanup_status="failed"
        fi
    fi
    STANDALONE_CLEANUP_DONE=1
    trap - EXIT

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
    [[ "${stage_status}" -eq 0 ]] || return "${stage_status}"
    [[ "${cleanup_status}" == "passed" ]] || return 70
    return "${finalize_status}"
}

usage() {
    cat <<USAGE
Usage: $(basename "$0") [OPTIONS]

Install the pinned Node.js runtime and Next.js 16.4.3 release with the committed
lockfile, generate the deterministic project matrix, then run the complete Next.js
workload matrix: cold production builds of 1000 and 3000 statically generated
pages, a 500 route dynamic project, 500 file-system routes, a warm incremental
rebuild, the official vercel/next.js examples/with-typescript project, and three
loopback HTTP scenarios (startup latency, 100 serial GETs of a static item page,
100 serial GETs of a server-rendered page).
The optimized variant is reserved and fails until its implementation is supplied.

Options:
  --version VERSION       Next.js version (default: ${SOFTWARE_VERSION})
  --variant VARIANT       base or optimized (default: base)
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, PERF_VARIANT, RESULTS_DIR, PERF_WORK_DIR,
  PERF_REPS, PERF_NPM_REGISTRY, PERF_NEXT_HTTP_PORT, NEXT_OFFLINE_DIR
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
    run_nextjs_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log_message "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
