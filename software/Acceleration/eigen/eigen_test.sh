#!/usr/bin/env bash
# Standalone entry point for the Eigen 5.0.1 Acceleration performance case.
#
# Runs the same six stages the framework drives (prepare -> build -> start ->
# test -> stop -> finalize) from one shell command.  The host only downloads and
# SHA-256 verifies the pinned upstream release archive; the archive is extracted
# inside the per-run openEuler 24.03 LTS SP4 container, where the unmodified
# upstream GEMM driver (bench/bench_gemm.cpp) is compiled once with the container
# C++ compiler (Eigen is header-only, so there is no cmake step and no per-flag
# build groups).  The measured matrix is the pinned 44-point dense float GEMM
# matrix: for every (m, k, n) point of C(m x n) = A(m x k) * B(k x n) the test
# stage runs one warm-up plus EIGEN_REPS independent measurements of
# `bench_gemm -s <m> <n> <k> -t 5 -p 10`, and the only reported metric is the
# upstream `eigen cpu ... GFLOPS` line (unit GFLOP/s, higher is better).
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
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/eigen/local-* || \
          "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/eigen" ]]; then
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
        stop_eigen_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_eigen_standalone() {
    local stage_status=0 failed_stage="" cleanup_status="passed" finalize_status=0
    local command_status="passed"
    local compiler=""

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
        if build_eigen; then
            # The build identity is the container C++ compiler that actually
            # compiled bench/bench_gemm.cpp; there is no cmake step any more.
            compiler="$(head -n 1 "${PERF_WORK_DIR}/compiler.txt" 2>/dev/null || true)"
            if standalone_runtime build-info \
                "${RESULTS_DIR}/build_info.json" \
                "${SOFTWARE_VERSION}" \
                "${PERF_ACTUAL_VERSION_FILE}" \
                "${EXPECTED_ARCH}" \
                "${PERF_RUN_ID}" \
                "${compiler}" \
                --archive-name="${EIGEN_ARCHIVE_NAME}" \
                --archive-url="${EIGEN_ARCHIVE_URL}" \
                --archive-sha256="${EIGEN_ARCHIVE_SHA256}"; then
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
        if start_eigen_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_eigen_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_eigen_runtime; then
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
        "${stage_status}" \
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

Extract the pinned Eigen ${SOFTWARE_VERSION} release archive, verify it against the
pinned SHA-256 and compile the unmodified upstream GEMM driver
(bench/bench_gemm.cpp) once inside the per-run openEuler 24.03 LTS SP4 container.
Eigen is header-only, so there is no cmake step and no per-flag build groups.

Then measure the pinned dense float GEMM matrix: for every one of the 44
(m, k, n) points of C(m x n) = A(m x k) * B(k x n) the driver runs once as

  bench_gemm -s <m> <n> <k> -t 5 -p 10

(upstream -s takes rows, columns and depth in that order) with one warm-up and
${EIGEN_REPS} independent measurements per point.  The only reported metric is the
upstream 'eigen cpu ... GFLOPS' line: unit GFLOP/s, higher is better.

Options:
  --version VERSION       Eigen version (default: ${SOFTWARE_VERSION})
  --variant VARIANT       base or optimized (default: base)
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, PERF_VARIANT, RESULTS_DIR, PERF_WORK_DIR,
  PERF_REPS, PERF_EIGEN_OFFLINE_DIR, PERF_EIGEN_ARCHIVE_URL, PERF_EIGEN_MIRROR,
  PERF_EIGEN_PROXY_PREFIX, PERF_EIGEN_RUN_TIMEOUT
USAGE
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --version requires a value"; return 20; }
                SOFTWARE_VERSION="$2"
                shift 2
                ;;
            --variant)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --variant requires a value"; return 20; }
                PERF_VARIANT="$2"
                shift 2
                ;;
            --results-dir)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --results-dir requires a value"; return 20; }
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
                return 20
                ;;
        esac
    done

    validate_variant || return $?
    if [[ "${SOFTWARE_VERSION}" != "5.0.1" ]]; then
        log_message "ERROR: unsupported version ${SOFTWARE_VERSION}; this case pins 5.0.1"
        return 20
    fi
    configure_runtime_paths || return $?
    if ! mkdir -p "${RESULTS_DIR}"; then
        log_message "ERROR: failed to create the standalone results directory: ${RESULTS_DIR}"
        return 20
    fi
    : > "${RESULTS_DIR}/raw-output.log"
    local pipeline_status=0
    set +e
    run_eigen_standalone 2>&1 | tee -a "${RESULTS_DIR}/raw-output.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log_message "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
