#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.0.2}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
SONIC_CPP_SOURCE_URL="${SONIC_CPP_SOURCE_URL:-https://github.com/bytedance/sonic-cpp.git}"
# Repetitions used by the official CI benchmark workflow (repetitions=5).
BENCHMARK_REPETITIONS="5"

SOURCE_DIR=""
BUILD_DIR=""
BENCHMARK_BIN=""
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

log() { printf '[sonic-cpp] %s\n' "$*"; }

normalize_architecture() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

configure_runtime_paths() {
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    }
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/tmp/sonic-cpp-perf/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
        TMPDIR="${PERF_WORK_DIR}/tmp"
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/sonic-cpp-source"
    BUILD_DIR="${PERF_WORK_DIR}/build"
    BENCHMARK_BIN="${BUILD_DIR}/benchmark/bench"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
}

initialize_runtime() {
    configure_runtime_paths
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR:-${PERF_WORK_DIR}/tmp}"
}

require_commands() {
    local required missing=0
    for required in git python3 cmake sed tee; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            log "ERROR: required command is missing: ${required}"
            missing=1
        fi
    done
    [[ "${missing}" -eq 0 ]]
}

check_architecture() {
    local actual expected
    actual="$(normalize_architecture "$(uname -m)")"
    expected="$(normalize_architecture "${EXPECTED_ARCH}")"
    [[ "${actual}" == "${expected}" ]] || {
        log "ERROR: expected architecture ${expected}, runner is ${actual}"
        return 20
    }
}

prepare_sonic_cpp_source() {
    [[ ! -e "${SOURCE_DIR}" ]] || {
        log "ERROR: source directory already exists: ${SOURCE_DIR}"
        return 30
    }
    export GIT_TERMINAL_PROMPT=0
    log "cloning sonic-cpp v${SOFTWARE_VERSION} from ${SONIC_CPP_SOURCE_URL}"
    git clone --branch "v${SOFTWARE_VERSION}" --depth 1 \
        "${SONIC_CPP_SOURCE_URL}" "${SOURCE_DIR}" || {
        log "ERROR: failed to clone sonic-cpp v${SOFTWARE_VERSION}"
        return 30
    }
}

report_actual_version() {
    # sonic-cpp is header-only and has no --version binary; the cloned source
    # tag is the authoritative version evidence.
    local actual_version
    actual_version="$(git -C "${SOURCE_DIR}" describe --tags --exact-match 2>/dev/null || true)"
    [[ "${actual_version}" == "v${SOFTWARE_VERSION}" ]] || {
        log "ERROR: cloned source tag '${actual_version}' does not match v${SOFTWARE_VERSION}"
        return 40
    }
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version#v}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40
}

repair_gflags_source_reference() {
    local external_cmake_file="${SOURCE_DIR}/cmake/external.cmake"

    [[ -f "${external_cmake_file}" ]] || {
        log "ERROR: Sonic CMake dependency file is missing: ${external_cmake_file}"
        return 40
    }
    # Sonic v1.0.2 requests gflags' retired master branch.  Keep the upstream
    # CMake build path intact while selecting the repository's current branch.
    if ! sed -i \
        '\|GIT_REPOSITORY https://github.com/gflags/gflags.git|,\|GIT_SHALLOW TRUE| s/GIT_TAG  master/GIT_TAG  main/' \
        "${external_cmake_file}"; then
        log "ERROR: failed to update Sonic's stale gflags branch reference"
        return 40
    fi
    log "using gflags main because the v1.0.2 master reference is retired"
}

build_sonic_cpp() {
    initialize_runtime || return $?
    check_architecture || return $?
    require_commands || return $?
    [[ ! -e "${SOURCE_DIR}" && ! -e "${BUILD_DIR}" ]] || {
        log "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    }
    prepare_sonic_cpp_source || return $?
    report_actual_version || return $?
    repair_gflags_source_reference || return $?

    log "building official CMake benchmark target: bench"
    (
        cmake -S "${SOURCE_DIR}" -B "${BUILD_DIR}" -DBUILD_BENCH=ON
        cmake --build "${BUILD_DIR}" --target bench -j
    ) || {
        log "ERROR: official CMake build of benchmark target failed"
        return 40
    }
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log "ERROR: official benchmark binary was not produced: ${BENCHMARK_BIN}"
        return 40
    }
    log "sonic-cpp ${SOFTWARE_VERSION} official benchmark artifact is ready"
}

start_sonic_cpp_runtime() {
    initialize_runtime || return $?
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log "ERROR: official sonic-cpp benchmark binary is unavailable: ${BENCHMARK_BIN}"
        return 40
    }
    log "sonic-cpp official benchmark runtime is ready"
}

run_sonic_cpp_benchmarks() {
    initialize_runtime || return $?
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log "ERROR: official sonic-cpp benchmark binary is unavailable: ${BENCHMARK_BIN}"
        return 40
    }
    log "running official CMake benchmark (benchmark/main.cpp)"
    # Uses Google Benchmark repetitions=5,
    # report_aggregates_only=true) but omits its --benchmark_filter=Sonic so the
    # full official scenario matrix (all libraries / all testdata files) is kept.
    (
        # The binary loads testdata/ relative to the working directory.
        cd "${SOURCE_DIR}"
        "${BENCHMARK_BIN}" \
            "--benchmark_out_format=json" \
            "--benchmark_out=${RESULTS_DIR}/benchmark.json" \
            "--benchmark_repetitions=${BENCHMARK_REPETITIONS}" \
            "--benchmark_report_aggregates_only=true"
    ) || {
        log "ERROR: official sonic-cpp benchmark failed"
        return 50
    }
    export SOFTWARE_VERSION EXPECTED_ARCH BENCHMARK_REPETITIONS
    python3 "${SCRIPT_DIR}/scripts/parse_benchmark.py" \
        "${RESULTS_DIR}/benchmark.json" \
        "${RESULTS_DIR}/benchmark_sonic_cpp.json" || {
        log "ERROR: failed to normalize official sonic-cpp benchmark results"
        return 50
    }
    log "sonic-cpp benchmark results written to benchmark.json and benchmark_sonic_cpp.json"
}

stop_sonic_cpp_runtime() {
    log "sonic-cpp benchmark has no background service to stop"
}

standalone_runtime() {
    python3 "${SCRIPT_DIR}/scripts/standalone_runtime.py" "$@"
}

cleanup_standalone_workdir() {
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 1 ]]; then
        log "keeping standalone work directory: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${STANDALONE_OWNS_WORK_DIR}" -ne 1 ]]; then
        log "external work directory was not removed: ${PERF_WORK_DIR}"
        return 0
    fi
    [[ "${PERF_WORK_DIR}" == /tmp/sonic-cpp-perf/local-* && \
       "${PERF_WORK_DIR}" != "/tmp/sonic-cpp-perf" ]] || {
        log "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    }
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        rm -rf -- "${PERF_WORK_DIR}" || return 70
    fi
    log "cleaned standalone work directory: ${PERF_WORK_DIR}"
}

emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then
        stop_sonic_cpp_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_sonic_cpp_standalone() {
    local stage_status=0 failed_stage="" cleanup_status="passed" finalize_status=0
    local command_status="passed"

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
        if build_sonic_cpp; then
            if standalone_runtime build-info \
                "${RESULTS_DIR}/build_info.json" \
                "${SOFTWARE_VERSION}" \
                "${PERF_ACTUAL_VERSION_FILE}" \
                "$(normalize_architecture "${EXPECTED_ARCH}")" \
                "${PERF_RUN_ID}" \
                "${COMPILER_BINARY}" \
                "${COMPILER_VERSION_STRING}"; then
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
        if start_sonic_cpp_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_sonic_cpp_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_sonic_cpp_runtime; then
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
        "$(normalize_architecture "${EXPECTED_ARCH}")" \
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

Build and run sonic-cpp's official CMake benchmark (benchmark/main.cpp) as a
standalone performance evaluation. Results default to
results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       sonic-cpp version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR, SONIC_CPP_SOURCE_URL
USAGE
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version)
                [[ "$#" -ge 2 ]] || { log "ERROR: --version requires a value"; return 10; }
                SOFTWARE_VERSION="$2"
                shift 2
                ;;
            --results-dir)
                [[ "$#" -ge 2 ]] || { log "ERROR: --results-dir requires a value"; return 10; }
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
                log "ERROR: unsupported option: $1"
                usage
                return 10
                ;;
        esac
    done

    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" || return $?
    : > "${RESULTS_DIR}/results.log"
    local pipeline_status=0
    set +e
    run_sonic_cpp_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
