#!/usr/bin/env bash
# RapidJSON performance case (official v1.1.0 sources with the upstream
# test/perftest suite).
#
# RapidJSON is Tencent's fast JSON parser/generator for C++ (header
# only).  The software under test is cloned from the official
# repository (github.com/Tencent/rapidjson) at the exact stable tag
# v1.1.0 (the latest release of the project) and compiled entirely
# inside the isolated work directory (nothing is installed
# system-wide).
#
# The benchmark is the official perftest suite shipped inside the
# RapidJSON source tree (test/perftest), built and registered by the
# upstream CMake build.  It is the tool the RapidJSON authors use to
# track the performance of the core parsing, DOM, serialization,
# whitespace skipping, UTF-8 validation and schema validation paths:
#
#   - rapidjsontest.cpp: Reader SAX parsing (plain / insitu /
#     iterative / full-precision / encoding-validating, plus seven
#     single-type corpora from the official bin/types data), Document
#     DOM parsing (four allocator/stream variants), tree traversal
#     (member iteration + Accept visitor), Writer/PrettyWriter
#     serialization, SkipWhitespace, UTF8::Validate, FileReadStream
#     and StringBuffer micro-benchmarks — every test executes its
#     workload kTrialCount (1000, 10000 for typed corpora) times;
#   - schematest.cpp: JSON Schema draft-4 validation over the official
#     bin/jsonschema test-suite corpus.
#
# The suite is driven by the googletest framework (the official
# thirdparty/gtest submodule pinned by the upstream repo), so each
# test reports its own wall-clock duration:
#
#     [       OK ] RapidJson.ReaderParse_DummyHandler_SSE42 (312 ms)
#
# The full run repeats the official binary five times through the
# framework's own --gtest_repeat option and reports the median
# duration of every test in milliseconds (lower is better), giving 51
# metrics (50 RapidJson.* + 1 Schema.TestSuite).
#
# The sources are used verbatim.  Two build-level adaptations of the
# official recipe are documented here:
#
#   1. -Wno-error (appended through CMAKE_CXX_FLAGS_RELEASE so it
#      overrides the upstream -Werror appended to CMAKE_CXX_FLAGS):
#      v1.1.0 dates from 2016 and its official CI flags include
#      -Wall -Wextra -Werror; warning classes introduced in GCC 7/8
#      (-Wimplicit-fallthrough, -Wformat-overflow, -Wclass-memaccess)
#      did not exist then and fire on the 2016 sources under modern
#      compilers.  Disabling -Werror changes no generated code (the
#      warnings remain visible as warnings); the optimization level
#      stays the official Release -O3 -DNDEBUG and the upstream
#      -march=native is kept.
#   2. On x86 the suite appends an _SSE42/_SSE2 suffix to the SIMD
#      test names (perftest.h SIMD_SUFFIX), while aarch64 has no SIMD
#      path in v1.1.0 and uses unsuffixed names.  The collector
#      normalizes the suffix away so metric names are identical
#      across architectures; the suffix itself is preserved in each
#      result's simd_suffix field for context.
#
# The four framework stages map to: clone+verify+init the gtest
# submodule+build the official perftest target (build), smoke-run one
# official test end to end (start), run the full suite five times and
# aggregate (test), and drop the benchmark data (stop — the suite
# runs no background service).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="rapidjson"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.1.0}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
RAPIDJSON_SOURCE_URL="${RAPIDJSON_SOURCE_URL:-https://github.com/Tencent/rapidjson.git}"
RAPIDJSON_BUILD_JOBS="${RAPIDJSON_BUILD_JOBS:-4}"
# The official gtest --gtest_repeat repetitions; the median of the
# per-test durations is reported.
RAPIDJSON_REPETITIONS="${RAPIDJSON_REPETITIONS:-5}"
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

# Lifecycle paths (assigned in configure_runtime_paths).
SOURCE_DIR=""
BUILD_DIR=""
PERFTEST_BIN=""
DATA_DIR=""

log() {
    printf '[rapidjson] %s\n' "$*"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/rapidjson/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/rapidjson-source"
    BUILD_DIR="${PERF_WORK_DIR}/build"
    PERFTEST_BIN="${BUILD_DIR}/bin/perftest"
    DATA_DIR="${SOURCE_DIR}/bin"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}"
}

require_rapidjson_tools() {
    local command_name
    local packages=()

    for command_name in git python3 cmake make g++ tee; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "missing required RapidJSON test command: ${command_name}"
            packages+=("${command_name}")
        fi
    done
    if [[ "${#packages[@]}" -ne 0 ]]; then
        log "ERROR: install the required tools first: ${packages[*]}"
        return 30
    fi

    # The v1.1.0 sources build with C++11 (set by the upstream CMake).
    local gxx_major
    gxx_major="$(g++ -dumpversion 2>/dev/null | cut -d. -f1)"
    if [[ -z "${gxx_major}" || "${gxx_major}" -lt 5 ]]; then
        log "ERROR: g++ ${gxx_major:-unknown} is too old for the RapidJSON sources (g++ >= 5)"
        return 30
    fi
    local cmake_version cmake_major cmake_minor cmake_rest
    cmake_version="$(cmake --version | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)"
    cmake_major="${cmake_version%%.*}"
    cmake_rest="${cmake_version#*.}"
    cmake_minor="${cmake_rest%%.*}"
    if [[ -z "${cmake_major}" || "${cmake_major}" -lt 3 || \
          ( "${cmake_major}" -eq 3 && "${cmake_minor}" -lt 5 ) ]]; then
        log "ERROR: cmake ${cmake_version:-unknown} is too old for the RapidJSON CMake build (cmake >= 3.5)"
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

read_cmake_version() {
    local major minor patch
    major="$(sed -n 's/^set(LIB_MAJOR_VERSION "\(.*\)")/\1/p' "$1")"
    minor="$(sed -n 's/^set(LIB_MINOR_VERSION "\(.*\)")/\1/p' "$1")"
    patch="$(sed -n 's/^set(LIB_PATCH_VERSION "\(.*\)")/\1/p' "$1")"
    [[ -n "${major}" && -n "${minor}" && -n "${patch}" ]] || return 1
    printf '%s.%s.%s\n' "${major}" "${minor}" "${patch}"
}

build_rapidjson() {
    local tag described actual_version

    initialize_runtime || return $?
    check_architecture || return $?
    require_rapidjson_tools || return $?
    [[ ! -e "${SOURCE_DIR}" ]] || {
        log "ERROR: source directory is not clean under ${PERF_WORK_DIR}"
        return 20
    }

    tag="v${SOFTWARE_VERSION}"
    log "cloning the official RapidJSON ${tag} sources"
    if ! git clone --branch "${tag}" --depth 1 \
            "${RAPIDJSON_SOURCE_URL}" "${SOURCE_DIR}" \
            > "${PERF_WORK_DIR}/rapidjson-clone.log" 2>&1; then
        rm -rf "${SOURCE_DIR}"
        log "ERROR: failed to clone RapidJSON ${tag} (see ${PERF_WORK_DIR}/rapidjson-clone.log)"
        return 30
    fi
    described="$(git -C "${SOURCE_DIR}" describe --tags --exact-match 2>/dev/null || true)"
    if [[ "${described}" != "${tag}" ]]; then
        log "ERROR: the RapidJSON source tree is ${described:-untagged}, expected ${tag}"
        return 30
    fi
    actual_version="$(read_cmake_version "${SOURCE_DIR}/CMakeLists.txt")" || {
        log "ERROR: cannot read the RapidJSON version from the upstream CMakeLists"
        return 40
    }
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: the RapidJSON sources report ${actual_version}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40

    log "initializing the official googletest submodule"
    if ! git -C "${SOURCE_DIR}" submodule update --init \
            > "${PERF_WORK_DIR}/gtest-submodule.log" 2>&1; then
        log "ERROR: failed to initialize the gtest submodule (see ${PERF_WORK_DIR}/gtest-submodule.log)"
        return 30
    fi

    log "configuring the official CMake build (Release)"
    # -Wno-error rides in CMAKE_CXX_FLAGS_RELEASE so that it is
    # emitted after the upstream -Werror appended to CMAKE_CXX_FLAGS
    # (see the header comment); -O3 -DNDEBUG matches the official
    # Release default.  Doc/examples are unrelated to the benchmark
    # and are disabled to keep the build minimal.
    if ! cmake -S "${SOURCE_DIR}" -B "${BUILD_DIR}" \
            -DCMAKE_BUILD_TYPE=Release \
            -DRAPIDJSON_BUILD_DOC=OFF \
            -DRAPIDJSON_BUILD_EXAMPLES=OFF \
            -DRAPIDJSON_BUILD_THIRDPARTY_GTEST=ON \
            -DCMAKE_CXX_FLAGS_RELEASE="-O3 -DNDEBUG -Wno-error" \
            > "${PERF_WORK_DIR}/cmake-configure.log" 2>&1; then
        log "ERROR: the official CMake configuration failed (see ${PERF_WORK_DIR}/cmake-configure.log)"
        return 30
    fi

    log "building the official perftest target (jobs: ${RAPIDJSON_BUILD_JOBS})"
    if ! cmake --build "${BUILD_DIR}" --target perftest --parallel "${RAPIDJSON_BUILD_JOBS}" \
            > "${PERF_WORK_DIR}/perftest-build.log" 2>&1; then
        log "ERROR: failed to build the official perftest target (see ${PERF_WORK_DIR}/perftest-build.log)"
        return 40
    fi
    [[ -x "${PERFTEST_BIN}" ]] || {
        log "ERROR: the official perftest executable was not created"
        return 40
    }
}

start_rapidjson_runtime() {
    local smoke_output

    initialize_runtime || return $?
    [[ -x "${PERFTEST_BIN}" ]] || {
        log "ERROR: the official perftest executable is unavailable"
        return 40
    }

    # Smoke run: one official test whose name is architecture-stable
    # (no SIMD suffix), executed once from the official bin data
    # directory (the WORKING_DIRECTORY of the upstream ctest
    # registration).
    log "smoke-running the official SkipWhitespace_Basic test"
    if ! (cd "${DATA_DIR}" && "${PERFTEST_BIN}" --gtest_filter='RapidJson.SkipWhitespace_Basic') \
            > "${PERF_WORK_DIR}/smoke.log" 2>&1; then
        log "ERROR: the perftest smoke run failed (see ${PERF_WORK_DIR}/smoke.log)"
        return 40
    fi
    smoke_output="$(grep -cE '^\[\s+OK \] RapidJson\.SkipWhitespace_Basic \([0-9]+ ms\)$' \
        "${PERF_WORK_DIR}/smoke.log" || true)"
    if [[ "${smoke_output}" -ne 1 ]]; then
        log "ERROR: the smoke run produced no passing SkipWhitespace_Basic result"
        return 40
    fi
    log "perftest smoke run passed"
}

run_rapidjson_benchmarks() {
    initialize_runtime || return $?
    [[ -x "${PERFTEST_BIN}" && -d "${DATA_DIR}" ]] || {
        log "ERROR: the official perftest executable or data directory is unavailable"
        return 40
    }
    export SOFTWARE_VERSION EXPECTED_ARCH
    export RAPIDJSON_SOURCE_URL RAPIDJSON_REPETITIONS
    python3 "${SCRIPT_DIR}/scripts/run_perftest.py" \
        "${PERFTEST_BIN}" "${DATA_DIR}" \
        "${RESULTS_DIR}/benchmark_perftest.json" || return 50
}

stop_rapidjson_runtime() {
    log "RapidJSON perftest has no background service to stop"
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
    [[ "${PERF_WORK_DIR}" == /home/runner/boostkit-perf/rapidjson/local-* && "${PERF_WORK_DIR}" != "/home/runner/boostkit-perf/rapidjson" ]] || {
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
        stop_rapidjson_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_rapidjson_standalone() {
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
        if build_rapidjson; then
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
        if start_rapidjson_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi

    if [[ "${stage_status}" -eq 0 ]]; then
        if run_rapidjson_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_rapidjson_runtime; then
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
Clone the official RapidJSON sources, build the official perftest
suite, run the full test set ${RAPIDJSON_REPETITIONS} times, collect
the environment, validate results, generate a report, and clean the
isolated work directory.

Options:
  --version VERSION       RapidJSON version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR,
  RAPIDJSON_SOURCE_URL, RAPIDJSON_BUILD_JOBS, RAPIDJSON_REPETITIONS
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
    run_rapidjson_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
