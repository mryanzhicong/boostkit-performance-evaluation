#!/usr/bin/env bash
# OpenCV performance case (official 5.0.0 sources with the upstream
# modules/<m>/perf benchmark framework).
#
# OpenCV is the open-source computer vision library (core matrix and
# array operations, image processing, colour transforms, filtering,
# geometry).  The software under test is cloned from the official
# repository (github.com/opencv/opencv) at the exact stable tag 5.0.0
# and compiled entirely inside the isolated work directory (nothing is
# installed system-wide).
#
# The benchmark is the official perf framework shipped inside the
# OpenCV source tree (modules/ts GTest-based performance harness): each
# module builds an opencv_perf_<module> binary that runs the module's
# perf/*.cpp fixtures with the official timing loop (default strategy
# "simple": each fixture is measured for a 1-second time limit with a
# sample cap, the framework reports samples/mean/median/min/stddev)
# and prints, per fixture:
#
#     [ RUN      ] Size_MatType_abs.abs/8, where GetParam() = (1920x1080, 8SC1)
#     [ PERFSTAT ]    (samples=100   mean=0.56   median=0.55   min=0.53   stddev=0.02 (4.0%))
#
# All PERFSTAT statistics are milliseconds.  The collected metric is
# the official median (median_ms, lower is better); mean/min/stddev are
# kept for reference.
#
# The full perf matrix (4024 core + 5256 imgproc fixtures at 5.0.0) is
# far beyond a deliverable benchmark size, so a deterministic slice is
# selected from the official --gtest_list_tests metadata at run time:
# every fixture family is represented, and inside a family the largest
# official size (1920x1080, falling back to 1280x720, 640x480, then
# the first fixture) is kept with at most 8 parameter combinations per
# family; OCL_/DISABLED fixtures are excluded (pure-CPU build).  This
# keeps ~340 core + ~540 imgproc representative fixtures (~15 minutes)
# while never depending on hard-coded fixture indices.
#
# The module matrix is the two central computational modules:
#
#   core     matrix/array arithmetic, DFT, reductions, splits/merges
#   imgproc  image filtering, morphology, colour conversion, resizing,
#            thresholds, histograms
#
# The official opencv_extra repository (same 5.0.0 tag) provides the
# fixed test-data tree (OPENCV_TEST_DATA_PATH) the perf fixtures read
# reference images from; both repositories are tag-verified with
# git describe --exact-match.
#
# The build uses the official CMake with the perf-target closure only
# (BUILD_LIST=core,imgproc,ts expands to the official dependency
# closure: core, flann, geometry, imgproc, imgcodecs, videoio, highgui,
# ts) and disables every non-benchmark target and every
# architecture-inconsistent accelerator so the comparison is pure CPU
# on both x86_64 and aarch64:
#
#   BUILD_PERF_TESTS=ON, BUILD_TESTS=OFF, apps/world/java/python OFF,
#   WITH_IPP=OFF (Intel closed-source binary, x86-only),
#   WITH_ITT=OFF, WITH_OPENCL=OFF, WITH_CUDA=OFF.
#
# CPU_BASELINE/CPU_DISPATCH are left at their official defaults (each
# architecture compiles its own baseline plus runtime-dispatched SIMD
# kernels — the official release configuration), so no ISA knob is
# forced across architectures.
#
# The four framework stages map to: clone both tag-verified
# repositories + configure + build the two perf binaries (build),
# smoke-run one official core fixture end to end (start), run the full
# core+imgproc perf matrix (test), and drop the benchmark data (stop —
# the perf binaries run to completion, no background service).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="opencv"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-5.0.0}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
OPENCV_SOURCE_URL="${OPENCV_SOURCE_URL:-https://github.com/opencv/opencv.git}"
OPENCV_EXTRA_SOURCE_URL="${OPENCV_EXTRA_SOURCE_URL:-https://github.com/opencv/opencv_extra.git}"
OPENCV_BUILD_JOBS="${OPENCV_BUILD_JOBS:-8}"
# The official perf module matrix (space-separated).
OPENCV_MODULES=(core imgproc)

STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

# Lifecycle paths (assigned in configure_runtime_paths).
SOURCE_DIR=""
EXTRA_DIR=""
TEST_DATA_DIR=""
BUILD_DIR=""
PERF_BIN_DIR=""
PERF_LIB_DIR=""

log() {
    printf '[opencv] %s\n' "$*"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/opencv/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/opencv-source"
    EXTRA_DIR="${PERF_WORK_DIR}/opencv-extra"
    TEST_DATA_DIR="${EXTRA_DIR}/testdata"
    BUILD_DIR="${PERF_WORK_DIR}/build"
    PERF_BIN_DIR="${BUILD_DIR}/bin"
    PERF_LIB_DIR="${BUILD_DIR}/lib"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}"
}

require_opencv_tools() {
    local command_name
    local packages=()

    for command_name in git python3 cmake make g++ tee; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "missing required OpenCV test command: ${command_name}"
            packages+=("${command_name}")
        fi
    done
    if [[ "${#packages[@]}" -ne 0 ]]; then
        log "ERROR: install the required tools first: ${packages[*]}"
        return 30
    fi

    # OpenCV 5.0 requires cmake >= 3.10 and a C++11 compiler
    # (CMAKE_CXX_STANDARD 11+); gcc >= 5 covers it.
    local gxx_major
    gxx_major="$(g++ -dumpversion 2>/dev/null | cut -d. -f1)"
    if [[ -z "${gxx_major}" || "${gxx_major}" -lt 5 ]]; then
        log "ERROR: g++ ${gxx_major:-unknown} is too old for the OpenCV sources (g++ >= 5)"
        return 30
    fi
    local cmake_version cmake_major cmake_minor cmake_rest
    cmake_version="$(cmake --version | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)"
    cmake_major="${cmake_version%%.*}"
    cmake_rest="${cmake_version#*.}"
    cmake_minor="${cmake_rest%%.*}"
    if [[ -z "${cmake_major}" || "${cmake_major}" -lt 3 || \
          ( "${cmake_major}" -eq 3 && "${cmake_minor}" -lt 10 ) ]]; then
        log "ERROR: cmake ${cmake_version:-unknown} is too old for the OpenCV CMake build (cmake >= 3.10)"
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

clone_tagged_repo() { # name base tag dir
    local name="$1" base="$2" tag="$3" dir="$4"
    local described

    if [[ -d "${dir}/.git" ]]; then
        log "using cached ${name} source tree ${dir}"
    else
        log "cloning the official ${name} ${tag} sources"
        if ! git clone --depth 1 --branch "${tag}" "${base}" "${dir}" \
                > "${PERF_WORK_DIR}/${name}-clone.log" 2>&1; then
            rm -rf "${dir}"
            log "ERROR: failed to clone ${base} at ${tag} (see ${PERF_WORK_DIR}/${name}-clone.log)"
            return 30
        fi
    fi
    described="$(git -C "${dir}" describe --tags --exact-match 2>/dev/null || true)"
    if [[ "${described}" != "${tag}" ]]; then
        log "ERROR: the ${name} source tree is ${described:-untagged}, expected ${tag}"
        return 30
    fi
}

read_opencv_version() {
    # The upstream version header declares the library version as
    # CV_VERSION_MAJOR/MINOR/REVISION defines (optionally followed by a
    # CV_VERSION_STATUS suffix such as "-alpha"; a stable tag carries
    # an empty status).
    local header="$1"
    local major minor revision status
    major="$(sed -n 's/^#define CV_VERSION_MAJOR[[:space:]]*\([0-9]*\).*/\1/p' "${header}")"
    minor="$(sed -n 's/^#define CV_VERSION_MINOR[[:space:]]*\([0-9]*\).*/\1/p' "${header}")"
    revision="$(sed -n 's/^#define CV_VERSION_REVISION[[:space:]]*\([0-9]*\).*/\1/p' "${header}")"
    status="$(sed -n 's/^#define CV_VERSION_STATUS[[:space:]]*"\(.*\)".*/\1/p' "${header}")"
    [[ -n "${major}" && -n "${minor}" && -n "${revision}" ]] || return 1
    printf '%s.%s.%s%s\n' "${major}" "${minor}" "${revision}" "${status}"
}

# ---------------------------------------------------------------------------
# Framework stages.
# ---------------------------------------------------------------------------

build_opencv() {
    local tag described actual_version

    initialize_runtime || return $?
    check_architecture || return $?
    require_opencv_tools || return $?
    [[ ! -e "${SOURCE_DIR}" ]] || {
        log "ERROR: source directory is not clean under ${PERF_WORK_DIR}"
        return 20
    }

    tag="${SOFTWARE_VERSION}"
    clone_tagged_repo opencv "${OPENCV_SOURCE_URL}" "${tag}" "${SOURCE_DIR}" || return $?
    clone_tagged_repo opencv_extra "${OPENCV_EXTRA_SOURCE_URL}" "${tag}" "${EXTRA_DIR}" || return $?
    [[ -d "${TEST_DATA_DIR}" ]] || {
        log "ERROR: the opencv_extra testdata tree is missing: ${TEST_DATA_DIR}"
        return 30
    }

    actual_version="$(read_opencv_version \
        "${SOURCE_DIR}/modules/core/include/opencv2/core/version.hpp")" || {
        log "ERROR: cannot read the OpenCV version from the upstream version header"
        return 40
    }
    if [[ "${actual_version}" != "${tag}" ]]; then
        log "ERROR: the OpenCV sources report ${actual_version}, which does not match tag ${tag}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40

    log "configuring the official CMake build (Release, perf-target closure)"
    local perf_targets=()
    local module
    for module in "${OPENCV_MODULES[@]}"; do
        perf_targets+=("opencv_perf_${module}")
    done
    if ! cmake -S "${SOURCE_DIR}" -B "${BUILD_DIR}" \
            -DCMAKE_BUILD_TYPE=Release \
            -DBUILD_LIST=core,imgproc,ts \
            -DBUILD_PERF_TESTS=ON \
            -DBUILD_TESTS=OFF \
            -DBUILD_SHARED_LIBS=ON \
            -DBUILD_opencv_apps=OFF \
            -DBUILD_opencv_world=OFF \
            -DBUILD_JAVA=OFF \
            -DBUILD_opencv_python3=OFF \
            -DWITH_IPP=OFF \
            -DWITH_ITT=OFF \
            -DWITH_OPENCL=OFF \
            -DWITH_CUDA=OFF \
            -DOPENCV_TEST_DATA_PATH="${TEST_DATA_DIR}" \
            > "${PERF_WORK_DIR}/cmake-configure.log" 2>&1; then
        log "ERROR: the official CMake configuration failed (see ${PERF_WORK_DIR}/cmake-configure.log)"
        return 30
    fi

    log "building the official perf targets: ${perf_targets[*]} (jobs: ${OPENCV_BUILD_JOBS})"
    if ! cmake --build "${BUILD_DIR}" --target "${perf_targets[@]}" \
            --parallel "${OPENCV_BUILD_JOBS}" \
            > "${PERF_WORK_DIR}/perf-build.log" 2>&1; then
        log "ERROR: failed to build the official perf targets (see ${PERF_WORK_DIR}/perf-build.log)"
        return 40
    fi
    for module in "${OPENCV_MODULES[@]}"; do
        [[ -x "${PERF_BIN_DIR}/opencv_perf_${module}" ]] || {
            log "ERROR: the official opencv_perf_${module} executable was not created"
            return 40
        }
    done
}

start_opencv_runtime() {
    initialize_runtime || return $?
    local module
    for module in "${OPENCV_MODULES[@]}"; do
        [[ -x "${PERF_BIN_DIR}/opencv_perf_${module}" ]] || {
            log "ERROR: the official opencv_perf_${module} executable is unavailable"
            return 40
        }
    done

    # Smoke run: one official core fixture family end to end through
    # the perf timing loop with a shortened time limit, verifying the
    # PERFSTAT output contract.
    log "smoke-running the official opencv_perf_core (abs, short time limit)"
    if ! (export LD_LIBRARY_PATH="${PERF_LIB_DIR}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}" && \
            export OPENCV_TEST_DATA_PATH="${TEST_DATA_DIR}" && \
            "${PERF_BIN_DIR}/opencv_perf_core" \
                --gtest_filter='Size_MatType_abs.abs/*' \
                --perf_time_limit=0.05) \
            > "${PERF_WORK_DIR}/smoke.log" 2>&1; then
        log "ERROR: the opencv_perf_core smoke run failed (see ${PERF_WORK_DIR}/smoke.log)"
        return 40
    fi
    if ! grep -q '\[ PERFSTAT \]' "${PERF_WORK_DIR}/smoke.log"; then
        log "ERROR: the smoke run produced no PERFSTAT result"
        return 40
    fi
    log "opencv_perf_core smoke run passed"
}

run_opencv_benchmarks() {
    initialize_runtime || return $?
    local module
    for module in "${OPENCV_MODULES[@]}"; do
        [[ -x "${PERF_BIN_DIR}/opencv_perf_${module}" ]] || {
            log "ERROR: the official opencv_perf_${module} executable is unavailable"
            return 40
        }
    done
    export SOFTWARE_VERSION EXPECTED_ARCH
    export OPENCV_SOURCE_URL OPENCV_EXTRA_SOURCE_URL
    export LD_LIBRARY_PATH="${PERF_LIB_DIR}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
    export OPENCV_TEST_DATA_PATH="${TEST_DATA_DIR}"
    python3 "${SCRIPT_DIR}/scripts/run_perf_tests.py" \
        "${PERF_BIN_DIR}" "${OPENCV_MODULES[*]}" \
        "${RESULTS_DIR}/benchmark_opencv_perf.json" || return 50
}

stop_opencv_runtime() {
    log "OpenCV perf binaries have no background service to stop"
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
    [[ "${PERF_WORK_DIR}" == /home/runner/boostkit-perf/opencv/local-* && "${PERF_WORK_DIR}" != "/home/runner/boostkit-perf/opencv" ]] || {
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
        stop_opencv_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_opencv_standalone() {
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
        if build_opencv; then
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
        if start_opencv_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi

    if [[ "${stage_status}" -eq 0 ]]; then
        if run_opencv_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_opencv_runtime; then
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
Clone the official OpenCV and opencv_extra sources (tag ${SOFTWARE_VERSION}),
build the official perf binaries (modules: ${OPENCV_MODULES[*]}), run
the full official perf matrix, collect the environment, validate
results, generate a report, and clean the isolated work directory.

Options:
  --version VERSION       OpenCV version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR,
  OPENCV_SOURCE_URL, OPENCV_EXTRA_SOURCE_URL, OPENCV_BUILD_JOBS
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
    run_opencv_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
