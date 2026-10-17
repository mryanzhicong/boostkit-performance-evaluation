#!/usr/bin/env bash
# libwebp performance case (official v1.6.0 sources, official cwebp/dwebp
# timing instrumentation).
#
# libwebp is the reference implementation of the WebP image format.  The
# software under test is cloned from the official repository
# (chromium.googlesource.com/webm/libwebp) at the exact stable tag v1.6.0 and
# built inside this case's isolated work directory (nothing is installed
# system-wide).
#
# libwebp ships no dedicated benchmark tool.  Its official command-line apps
# carry the maintainers' own timing instrumentation: in verbose mode cwebp
# prints "Time to encode picture: X.XXXs" around the pure WebPEncode call
# and dwebp prints "Time to decode picture: X.XXXs" around the pure
# DecodeWebP call (both exclude file I/O, see examples/cwebp.c and
# examples/dwebp.c).  The benchmark runs the official CLIs over fixed
# LCG-generated PPM images (byte-identical on every architecture) across
# cwebp's two compression modes (lossy defaults and the documented -z 6
# lossless preset) and takes the median of repeated runs per scenario.
#
# The official -mt flag is not part of the matrix: libwebp's lossy pipeline
# is effectively single-threaded (measured delta < 3%), so a thread ladder
# would only measure scheduler noise.
#
# The four framework stages map to: clone+verify+build cwebp/dwebp and
# generate the fixed images (build), smoke-run one official encode+decode
# scenario (start), run the full 8-scenario matrix (test), and drop the
# benchmark data (stop — the CLIs run to completion, no background service).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="libwebp"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.6.0}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
LIBWEBP_SOURCE_URL="${LIBWEBP_SOURCE_URL:-https://chromium.googlesource.com/webm/libwebp}"
LIBWEBP_BUILD_JOBS="${LIBWEBP_BUILD_JOBS:-8}"

# The fixed benchmark loads (name width height), matching run_benchmark.py.
LIBWEBP_LOADS=(1920x1080:1920:1080 3840x2160:3840:2160)

STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

# Lifecycle paths (assigned in configure_runtime_paths).
SOURCE_DIR=""
BUILD_DIR=""
CWEBP_BIN=""
DWEBP_BIN=""
LOAD_DIR=""
RAW_OUTPUT=""

log() {
    printf '[libwebp] %s\n' "$*"
}

configure_runtime_paths() {
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64)
            EXPECTED_ARCH="x86_64"
            ;;
        aarch64|arm64)
            EXPECTED_ARCH="aarch64"
            ;;
        *)
            EXPECTED_ARCH="${EXPECTED_ARCH,,}"
            ;;
    esac
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/libwebp/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/libwebp-source"
    BUILD_DIR="${SOURCE_DIR}/build"
    CWEBP_BIN="${BUILD_DIR}/cwebp"
    DWEBP_BIN="${BUILD_DIR}/dwebp"
    LOAD_DIR="${PERF_WORK_DIR}/loads"
    RAW_OUTPUT="${RESULTS_DIR}/webp_benchmark_raw.log"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}"
}

require_libwebp_tools() {
    local command_name package
    local packages=()

    for command_name in git python3 cmake make gcc tee; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            git) package="git" ;;
            python3) package="python3" ;;
            cmake) package="cmake" ;;
            make) package="make" ;;
            gcc) package="gcc" ;;
            tee) package="coreutils" ;;
        esac
        log "missing required libwebp test command: ${command_name}"
        packages+=("${package}")
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log "ERROR: dnf is required to install libwebp test prerequisites"
        return 30
    fi

    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log "installing missing libwebp test packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log "ERROR: sudo is required to install libwebp test prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log "ERROR: failed to install libwebp test prerequisites"
        return 30
    fi

    for command_name in git python3 cmake make gcc tee; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "ERROR: required libwebp test command remains unavailable: ${command_name}"
            return 30
        fi
    done

    # The upstream CMake needs cmake >= 3.7 and a C99 compiler; gcc >= 5
    # covers it.
    local cmake_version cmake_major cmake_minor cmake_rest
    cmake_version="$(cmake --version | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)"
    cmake_major="${cmake_version%%.*}"
    cmake_rest="${cmake_version#*.}"
    cmake_minor="${cmake_rest%%.*}"
    if [[ -z "${cmake_major}" || "${cmake_major}" -lt 3 || \
          ( "${cmake_major}" -eq 3 && "${cmake_minor}" -lt 7 ) ]]; then
        log "ERROR: cmake ${cmake_version:-unknown} is too old for the libwebp CMake build (cmake >= 3.7)"
        return 30
    fi
}

read_libwebp_version() {
    # The upstream configure.ac declares the library version in its AC_INIT
    # line (the release tag carries the same number).
    sed -n 's/^AC_INIT(\[libwebp\], \[\([0-9.]*\)\].*/\1/p' "$1"
}

generate_loads() {
    # Fixed LCG-generated PPM images: byte-identical on every architecture,
    # so the encoder always sees the exact same input.
    mkdir -p "${LOAD_DIR}"
    local load_spec load_name width height
    for load_spec in "${LIBWEBP_LOADS[@]}"; do
        load_name="${load_spec%%:*}"
        width="${load_spec#*:}"
        width="${width%%:*}"
        height="${load_spec##*:}"
        if [[ ! -s "${LOAD_DIR}/${load_name}.ppm" ]]; then
            log "generating the fixed ${load_name} load image"
            if ! python3 "${SCRIPT_DIR}/scripts/gen_ppm.py" \
                    "${LOAD_DIR}/${load_name}.ppm" "${width}" "${height}"; then
                log "ERROR: failed to generate the ${load_name} load image"
                return 40
            fi
        fi
    done
}

build_libwebp() {
    local described source_version runtime_version

    initialize_runtime || return $?
    local runner_architecture
    runner_architecture="$(uname -m)"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    require_libwebp_tools || return $?
    if [[ -e "${BUILD_DIR}" ]]; then
        log "ERROR: build output is not clean under ${PERF_WORK_DIR}"
        return 20
    fi

    if [[ -d "${SOURCE_DIR}/.git" ]]; then
        log "using cached libwebp source tree ${SOURCE_DIR}"
    else
        log "cloning the official libwebp v${SOFTWARE_VERSION} sources"
        if ! git clone --depth 1 --branch "v${SOFTWARE_VERSION}" \
                "${LIBWEBP_SOURCE_URL}" "${SOURCE_DIR}" \
                > "${PERF_WORK_DIR}/libwebp-clone.log" 2>&1; then
            rm -rf "${SOURCE_DIR}"
            log "ERROR: failed to clone libwebp v${SOFTWARE_VERSION} (see ${PERF_WORK_DIR}/libwebp-clone.log)"
            return 30
        fi
    fi
    described="$(git -C "${SOURCE_DIR}" describe --tags --exact-match 2>/dev/null || true)"
    if [[ "${described}" != "v${SOFTWARE_VERSION}" ]]; then
        log "ERROR: the libwebp source tree is ${described:-untagged}, expected v${SOFTWARE_VERSION}"
        return 30
    fi

    source_version="$(read_libwebp_version "${SOURCE_DIR}/configure.ac")"
    if [[ "${source_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: the libwebp sources report ${source_version:-unknown}, which does not match tag v${SOFTWARE_VERSION}"
        return 40
    fi

    log "configuring the official CMake build (Release)"
    if ! cmake -S "${SOURCE_DIR}" -B "${BUILD_DIR}" \
            -DCMAKE_BUILD_TYPE=Release \
            > "${PERF_WORK_DIR}/cmake-configure.log" 2>&1; then
        log "ERROR: the official CMake configuration failed (see ${PERF_WORK_DIR}/cmake-configure.log)"
        return 40
    fi

    log "building the official cwebp and dwebp tools (jobs: ${LIBWEBP_BUILD_JOBS})"
    if ! cmake --build "${BUILD_DIR}" --target cwebp dwebp \
            --parallel "${LIBWEBP_BUILD_JOBS}" \
            > "${PERF_WORK_DIR}/libwebp-build.log" 2>&1; then
        log "ERROR: failed to build cwebp/dwebp (see ${PERF_WORK_DIR}/libwebp-build.log)"
        return 40
    fi
    [[ -x "${CWEBP_BIN}" && -x "${DWEBP_BIN}" ]] || {
        log "ERROR: the official cwebp/dwebp executables were not created"
        return 40
    }

    runtime_version="$("${CWEBP_BIN}" -version 2>/dev/null | head -1)"
    if [[ "${runtime_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: cwebp reports version ${runtime_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${runtime_version}" > "${PERF_ACTUAL_VERSION_FILE}"

    generate_loads || return $?
    log "libwebp ${runtime_version} built with the official cwebp/dwebp tools"
}

start_libwebp_runtime() {
    initialize_runtime || return $?
    if [[ ! -x "${CWEBP_BIN}" || ! -x "${DWEBP_BIN}" ]]; then
        log "ERROR: the official cwebp/dwebp tools are unavailable (run build first)"
        return 40
    fi

    # Smoke run: one official encode + decode over the smallest load, end
    # to end through the official timing instrumentation.
    log "smoke-running the official cwebp/dwebp (1920x1080 lossy)"
    if ! (cd "${PERF_WORK_DIR}" && \
            "${CWEBP_BIN}" -v "${LOAD_DIR}/1920x1080.ppm" -o smoke.webp \
                > "${PERF_WORK_DIR}/smoke.log" 2>&1 && \
            "${DWEBP_BIN}" -v -ppm smoke.webp -o smoke.ppm \
                >> "${PERF_WORK_DIR}/smoke.log" 2>&1); then
        log "ERROR: the smoke run failed (see ${PERF_WORK_DIR}/smoke.log)"
        return 40
    fi
    if ! grep -q 'Time to encode picture' "${PERF_WORK_DIR}/smoke.log" || \
       ! grep -q 'Time to decode picture' "${PERF_WORK_DIR}/smoke.log"; then
        log "ERROR: the smoke run produced no official timing lines"
        return 40
    fi
    rm -f "${PERF_WORK_DIR}/smoke.webp" "${PERF_WORK_DIR}/smoke.ppm"
    log "smoke run passed"
}

run_libwebp_benchmarks() {
    initialize_runtime || return $?
    if [[ ! -x "${CWEBP_BIN}" || ! -x "${DWEBP_BIN}" ]]; then
        log "ERROR: the official cwebp/dwebp tools are unavailable (run build first)"
        return 50
    fi
    local load_spec load_name
    for load_spec in "${LIBWEBP_LOADS[@]}"; do
        load_name="${load_spec%%:*}"
        [[ -s "${LOAD_DIR}/${load_name}.ppm" ]] || {
            log "ERROR: the ${load_name} load image is unavailable"
            return 50
        }
    done

    export SOFTWARE_VERSION EXPECTED_ARCH
    log "running the full benchmark matrix (2 ops x 2 loads x 2 modes)"
    if ! python3 "${SCRIPT_DIR}/scripts/run_benchmark.py" \
            "${CWEBP_BIN}" "${DWEBP_BIN}" "${LOAD_DIR}" \
            "${RAW_OUTPUT}" "${RESULTS_DIR}/results.json" 2>&1 | \
            tee "${RESULTS_DIR}/webp_benchmark_run.log"; then
        log "ERROR: the benchmark matrix failed (see ${RESULTS_DIR}/webp_benchmark_run.log)"
        return 50
    fi
    log "benchmark matrix completed"
}

stop_libwebp_runtime() {
    log "libwebp cwebp/dwebp have no background service to stop"
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
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/libwebp/local-* || \
          "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/libwebp" ]]; then
        log "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    fi
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        rm -rf -- "${PERF_WORK_DIR}" || return 70
    fi
    log "cleaned standalone work directory: ${PERF_WORK_DIR}"
}

emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then
        stop_libwebp_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_libwebp_standalone() {
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
        if build_libwebp; then
            if standalone_runtime build-info \
                "${RESULTS_DIR}/build_info.json" \
                "${SOFTWARE_VERSION}" \
                "${PERF_ACTUAL_VERSION_FILE}" \
                "${EXPECTED_ARCH}" \
                "${PERF_RUN_ID}"; then
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
        if start_libwebp_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_libwebp_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_libwebp_runtime; then
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
    if [[ "${stage_status}" -ne 0 ]]; then
        return "${stage_status}"
    fi
    if [[ "${cleanup_status}" != "passed" ]]; then
        return 70
    fi
    return "${finalize_status}"
}

usage() {
    cat <<USAGE
Usage: $(basename "$0") [OPTIONS]

Build the official libwebp ${SOFTWARE_VERSION} with its cwebp/dwebp tools and
run the WebP encode/decode benchmark matrix (2 ops x 2 loads x 2 modes) as a
standalone performance evaluation.  Results default to
results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       libwebp version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR,
  LIBWEBP_SOURCE_URL, LIBWEBP_BUILD_JOBS
USAGE
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version)
                if [[ "$#" -lt 2 ]]; then
                    log "ERROR: --version requires a value"
                    return 10
                fi
                SOFTWARE_VERSION="$2"
                shift 2
                ;;
            --results-dir)
                if [[ "$#" -lt 2 ]]; then
                    log "ERROR: --results-dir requires a value"
                    return 10
                fi
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
    run_libwebp_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
