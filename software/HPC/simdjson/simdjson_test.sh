#!/usr/bin/env bash
# simdjson performance case (official v4.6.11 sources with the upstream
# Google Benchmark suites bench_parse_call + bench_dom_api).
#
# simdjson is the extremely fast JSON parsing library from
# simdjson/simdjson (SIMD-accelerated, GB/s-class).  The software under
# test is cloned from the official repository at the exact stable tag
# v4.6.11 (the latest release) and compiled entirely inside the
# isolated work directory (nothing is installed system-wide).
#
# The benchmarks are the official Google Benchmark suites shipped
# inside the simdjson source tree (benchmark/):
#
#   bench_parse_call.cpp (9 tests) — the canonical parse-throughput
#     suite: parse / minify / UTF-8-validate of the official twitter.json
#     and gsoc-2018.json corpora (each test reports an official
#     "Gigabytes" rate counter in addition to its per-iteration time),
#     plus the four empty-document error-path micro-benchmarks
#     (error_code and exception flavors).
#
#   bench_dom_api.cpp (24 tests) — the DOM API suite: document
#     serialization (minify / to_string / internal string_builder, with
#     Gigabytes rate counters), element recovery, the numbers.json
#     scans (error_code / exception / type / load variants), the
#     twitter.json element-access tasks (count / default_profile /
#     image_sizes in both API flavors) and surrogate-pair parsing.
#
# Both suites are plain google-benchmark binaries; the framework is the
# official google/benchmark v1.9.5, fetched by the upstream CMake at
# configure time via CPM from the URL pinned in the official
# dependencies/CMakeLists.txt (the same file pins the official
# simdjson-data corpus repository to an exact commit — the equivalent
# of the tarball checksums other cases use).  Building them requires
# the upstream SIMDJSON_DEVELOPER_MODE=ON switch: with it off the
# official CMake builds "only the library" and skips benchmark/tests
# targets entirely (the configure output says so explicitly).
#
# The sources are used verbatim.  The only build-level selections on
# top of the official recipe are CMake switches, not code changes:
#
#   - SIMDJSON_DEVELOPER_MODE=ON — enables the benchmark targets (the
#     officially documented way to build them).
#   - SIMDJSON_COMPETITION=OFF — skips the optional competitor
#     libraries (yyjson, rapidjson, sajson, ...) that the comparison
#     benchmark bench_ondemand links against; this case benchmarks
#     simdjson itself, so bench_ondemand is out of scope and the
#     competitor download chain is not needed.
#   - SIMDJSON_GOOGLE_BENCHMARKS=ON — fetches google/benchmark v1.9.5
#     (the official default when downloads are allowed).
#
# Each binary is executed with the google-benchmark CLI used by the
# official suites (--benchmark_repetitions=10 --benchmark_format=json),
# matching the source-level ->Repetitions(10) the upstream throughput
# tests configure.  The collector takes the median cpu_time of every
# official test in nanoseconds (lower is better) and preserves the
# official "Gigabytes"/"docs" rate counters as per-test context.
#
# The four framework stages map to: clone+verify+configure+build the
# two official binaries (build), smoke-run one official test per binary
# (start), run the full 33-test matrix and aggregate (test), and drop
# the benchmark data (stop — the suites run no background service).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="simdjson"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-4.6.11}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
SIMDJSON_SOURCE_URL="${SIMDJSON_SOURCE_URL:-https://github.com/simdjson/simdjson.git}"
SIMDJSON_BUILD_JOBS="${SIMDJSON_BUILD_JOBS:-4}"
# google-benchmark repetitions; the upstream throughput tests set
# ->Repetitions(10) in source, the CLI flag extends the same count to
# every remaining test so all of them produce aggregate rows.
SIMDJSON_REPETITIONS="${SIMDJSON_REPETITIONS:-10}"
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

# Lifecycle paths (assigned in configure_runtime_paths).
SOURCE_DIR=""
BUILD_DIR=""
BENCH_PARSE_CALL_BIN=""
BENCH_DOM_API_BIN=""

log() {
    printf '[simdjson] %s\n' "$*"
}

normalize_arch() {
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
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64) EXPECTED_ARCH="x86_64" ;;
        aarch64|arm64) EXPECTED_ARCH="aarch64" ;;
        *) EXPECTED_ARCH="${EXPECTED_ARCH,,}" ;;
    esac
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/simdjson/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/simdjson-source"
    BUILD_DIR="${PERF_WORK_DIR}/build"
    BENCH_PARSE_CALL_BIN="${BUILD_DIR}/benchmark/bench_parse_call"
    BENCH_DOM_API_BIN="${BUILD_DIR}/benchmark/bench_dom_api"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}"
}

require_simdjson_tools() {
    local command_name
    local packages=()

    for command_name in git python3 cmake make g++ tee; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "missing required simdjson test command: ${command_name}"
            packages+=("${command_name}")
        fi
    done
    if [[ "${#packages[@]}" -ne 0 ]]; then
        log "ERROR: install the required tools first: ${packages[*]}"
        return 30
    fi

    # The v4.6.11 sources need C++17 and the upstream CMake needs >= 3.14.
    local gxx_major
    gxx_major="$(g++ -dumpversion 2>/dev/null | cut -d. -f1)"
    if [[ -z "${gxx_major}" || "${gxx_major}" -lt 7 ]]; then
        log "ERROR: g++ ${gxx_major:-unknown} is too old for the simdjson sources (g++ >= 7)"
        return 30
    fi
    local cmake_version cmake_major cmake_minor cmake_rest
    cmake_version="$(cmake --version | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)"
    cmake_major="${cmake_version%%.*}"
    cmake_rest="${cmake_version#*.}"
    cmake_minor="${cmake_rest%%.*}"
    if [[ -z "${cmake_major}" || "${cmake_major}" -lt 3 || \
          ( "${cmake_major}" -eq 3 && "${cmake_minor}" -lt 14 ) ]]; then
        log "ERROR: cmake ${cmake_version:-unknown} is too old for the simdjson CMake build (cmake >= 3.14)"
        return 30
    fi
}

check_architecture() {
    local actual expected
    actual="$(normalize_arch "$(uname -m)")"
    expected="$(normalize_arch "${EXPECTED_ARCH}")"
    [[ "${actual}" == "${expected}" ]] || {
        log "ERROR: expected architecture ${expected}, runner is ${actual}"
        return 20
    }
}

read_header_version() {
    sed -n 's/^#define SIMDJSON_VERSION[[:space:]]\+"\([^"]*\)".*/\1/p' "$1"
}

build_simdjson() {
    local tag described actual_version

    initialize_runtime || return $?
    check_architecture || return $?
    require_simdjson_tools || return $?
    [[ ! -e "${SOURCE_DIR}" ]] || {
        log "ERROR: source directory is not clean under ${PERF_WORK_DIR}"
        return 20
    }

    tag="v${SOFTWARE_VERSION}"
    log "cloning the official simdjson ${tag} sources"
    if ! git clone --branch "${tag}" --depth 1 \
            "${SIMDJSON_SOURCE_URL}" "${SOURCE_DIR}" \
            > "${PERF_WORK_DIR}/simdjson-clone.log" 2>&1; then
        rm -rf "${SOURCE_DIR}"
        log "ERROR: failed to clone simdjson ${tag} (see ${PERF_WORK_DIR}/simdjson-clone.log)"
        return 30
    fi
    described="$(git -C "${SOURCE_DIR}" describe --tags --exact-match 2>/dev/null || true)"
    if [[ "${described}" != "${tag}" ]]; then
        log "ERROR: the simdjson source tree is ${described:-untagged}, expected ${tag}"
        return 30
    fi
    actual_version="$(read_header_version "${SOURCE_DIR}/include/simdjson/simdjson_version.h")"
    if [[ -z "${actual_version}" ]]; then
        log "ERROR: cannot read the simdjson version header"
        return 40
    fi
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: the simdjson sources report ${actual_version}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40

    # The official configure.  CPM downloads google/benchmark v1.9.5 and
    # the simdjson-data corpus (both URLs pinned by the upstream
    # dependencies/CMakeLists.txt) at configure time, so the runner
    # needs network access for this step.
    log "configuring the official CMake build (Release, developer mode, benchmarks on)"
    if ! cmake -S "${SOURCE_DIR}" -B "${BUILD_DIR}" \
            -DCMAKE_BUILD_TYPE=Release \
            -DSIMDJSON_DEVELOPER_MODE=ON \
            -DSIMDJSON_COMPETITION=OFF \
            -DSIMDJSON_GOOGLE_BENCHMARKS=ON \
            > "${PERF_WORK_DIR}/cmake-configure.log" 2>&1; then
        log "ERROR: the official CMake configuration failed (see ${PERF_WORK_DIR}/cmake-configure.log)"
        return 30
    fi

    log "building the official bench_parse_call and bench_dom_api targets (jobs: ${SIMDJSON_BUILD_JOBS})"
    if ! cmake --build "${BUILD_DIR}" \
            --target bench_parse_call bench_dom_api \
            --parallel "${SIMDJSON_BUILD_JOBS}" \
            > "${PERF_WORK_DIR}/benchmark-build.log" 2>&1; then
        log "ERROR: failed to build the official benchmark targets (see ${PERF_WORK_DIR}/benchmark-build.log)"
        return 40
    fi
    [[ -x "${BENCH_PARSE_CALL_BIN}" && -x "${BENCH_DOM_API_BIN}" ]] || {
        log "ERROR: the official benchmark executables were not created"
        return 40
    }
}

start_simdjson_runtime() {
    local smoke_status=0

    initialize_runtime || return $?
    [[ -x "${BENCH_PARSE_CALL_BIN}" && -x "${BENCH_DOM_API_BIN}" ]] || {
        log "ERROR: the official benchmark executables are unavailable"
        return 40
    }

    # Smoke run: one quick official test per binary, two repetitions.
    log "smoke-running the official unicode_validate_twitter and twitter_count tests"
    if ! "${BENCH_PARSE_CALL_BIN}" --benchmark_filter=unicode_validate_twitter \
            --benchmark_repetitions=2 \
            > "${PERF_WORK_DIR}/smoke-parse-call.log" 2>&1; then
        smoke_status=40
    fi
    if [[ "${smoke_status}" -eq 0 ]] && \
            ! "${BENCH_DOM_API_BIN}" --benchmark_filter=twitter_count \
                --benchmark_repetitions=2 \
                > "${PERF_WORK_DIR}/smoke-dom-api.log" 2>&1; then
        smoke_status=40
    fi
    if [[ "${smoke_status}" -ne 0 ]] || \
            ! grep -q 'unicode_validate_twitter' "${PERF_WORK_DIR}/smoke-parse-call.log" || \
            ! grep -q 'twitter_count' "${PERF_WORK_DIR}/smoke-dom-api.log"; then
        log "ERROR: the benchmark smoke run failed (see ${PERF_WORK_DIR}/smoke-*.log)"
        return 40
    fi
    log "benchmark smoke runs passed"
}

run_simdjson_benchmarks() {
    initialize_runtime || return $?
    [[ -x "${BENCH_PARSE_CALL_BIN}" && -x "${BENCH_DOM_API_BIN}" ]] || {
        log "ERROR: the official benchmark executables are unavailable"
        return 40
    }
    export SOFTWARE_VERSION EXPECTED_ARCH
    export SIMDJSON_SOURCE_URL SIMDJSON_REPETITIONS
    python3 "${SCRIPT_DIR}/scripts/run_google_benchmarks.py" \
        "${BENCH_PARSE_CALL_BIN}" "${BENCH_DOM_API_BIN}" \
        "${RESULTS_DIR}/benchmark_googlebench.json" || return 50
}

stop_simdjson_runtime() {
    log "simdjson benchmarks have no background service to stop"
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
    [[ "${PERF_WORK_DIR}" == /home/runner/boostkit-perf/simdjson/local-* && "${PERF_WORK_DIR}" != "/home/runner/boostkit-perf/simdjson" ]] || {
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
        stop_simdjson_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_simdjson_standalone() {
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
        if build_simdjson; then
            if ! standalone_runtime build-info \
                "${RESULTS_DIR}/build_info.json" \
                "${SOFTWARE_VERSION}" \
                "${PERF_ACTUAL_VERSION_FILE}" \
                "$(normalize_arch "${EXPECTED_ARCH}")" \
                "${PERF_RUN_ID}"; then
                stage_status=40
                failed_stage="build"
            fi
        else
            stage_status=$?
            failed_stage="build"
        fi
    fi

    if [[ "${stage_status}" -eq 0 ]]; then
        if start_simdjson_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi

    if [[ "${stage_status}" -eq 0 ]]; then
        if run_simdjson_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_simdjson_runtime; then
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
        "$(normalize_arch "${EXPECTED_ARCH}")" \
        "${PERF_RUN_ID}" \
        "${command_status}" \
        "${cleanup_status}" \
        "${failed_stage}"; then
        :
    else
        finalize_status=$?
    fi

    if [[ "${stage_status}" -ne 0 ]]; then
        trap - EXIT
        return "${stage_status}"
    fi
    if [[ "${cleanup_status}" != "passed" ]]; then
        trap - EXIT
        return 70
    fi
    trap - EXIT
    return "${finalize_status}"
}

usage() {
    cat <<USAGE
Usage: $(basename "$0") [OPTIONS]
Clone the official simdjson sources, build the official Google
Benchmark suites (bench_parse_call + bench_dom_api), run the full
${SIMDJSON_REPETITIONS}-repetition matrix, collect the environment,
validate results, generate a report, and clean the isolated work
directory.

Options:
  --version VERSION       simdjson version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR,
  SIMDJSON_SOURCE_URL, SIMDJSON_BUILD_JOBS, SIMDJSON_REPETITIONS
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
    run_simdjson_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
