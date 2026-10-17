#!/usr/bin/env bash
# libavif performance case (official v1.4.2 sources, statically linked with
# the project's own pinned AV1 stack).
#
# libavif is the reference implementation library of the AV1 Image File
# Format.  The software under test is cloned from the official repository
# (github.com/AOMediaCodec/libavif) at the exact stable tag v1.4.2 and built
# inside this case's isolated work directory (nothing is installed
# system-wide).
#
# libavif ships no benchmark tool: aviftest is a functional sweep, avifyuv
# is a color-conversion checker, and the avifenc/avifdec apps print no
# timing.  The benchmark driver in src/avif_benchmark.c therefore calls the
# public API exactly as the official apps do (avifEncoderAddImage/Finish
# and avifDecoder SetIOMemory/Parse/NextImage with the avifenc defaults
# speed=6, quality=60) over a fixed, deterministically generated image set,
# measuring encode/decode latency across a 1/4/16 thread ladder.
#
# The dependency chain is the project's own pinned stack, fetched from the
# official channels fixed by the upstream build files:
#   aom     v3.14.1     ext/aom.cmd / LocalAom.cmake pinned tag
#   libyuv  644251f...  LocalLibyuv.cmake pinned commit
#   nasm    2.16.03     official nasm.us release tarball, SHA-256 verified
#                       (required to assemble aom's SIMD kernels)
#
# The four framework stages map to: clone+verify+build everything (build),
# smoke-run the driver on one scenario (start), run the full 18-scenario
# matrix and collect results (test), and drop the benchmark data (stop —
# the driver runs to completion, no background service).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="libavif"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.4.2}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# Fixed sources for the software under test and its pinned dependency
# stack (matching the upstream cmake/Modules/*.cmake pins).
LIBAVIF_SOURCE_URL="${LIBAVIF_SOURCE_URL:-https://github.com/AOMediaCodec/libavif.git}"
AOM_SOURCE_URL="${AOM_SOURCE_URL:-https://aomedia.googlesource.com/aom}"
LIBYUV_SOURCE_URL="${LIBYUV_SOURCE_URL:-https://chromium.googlesource.com/libyuv/libyuv}"
AOM_TAG="v3.14.1"
LIBYUV_COMMIT="644251f252a84bf8ce91ff0aca86a9b16b069ab8"
NASM_VERSION="2.16.03"
NASM_SHA256="1412a1c760bbd05db026b6c0d1657affd6631cd0a63cddb6f73cc6d4aa616148"
NASM_URL="https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VERSION}/nasm-${NASM_VERSION}.tar.xz"
LIBAVIF_BUILD_JOBS="${LIBAVIF_BUILD_JOBS:-8}"

STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

# Lifecycle paths (assigned in configure_runtime_paths).
SOURCE_DIR=""
BUILD_DIR=""
DEPS_SRC_DIR=""
PREFIX_DIR=""
BENCH_BIN=""
RAW_OUTPUT=""

log() {
    printf '[libavif] %s\n' "$*"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/libavif/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/libavif-source"
    BUILD_DIR="${SOURCE_DIR}/build"
    DEPS_SRC_DIR="${PERF_WORK_DIR}/deps-src"
    PREFIX_DIR="${PERF_WORK_DIR}/prefix"
    BENCH_BIN="${PERF_WORK_DIR}/avif_benchmark"
    RAW_OUTPUT="${RESULTS_DIR}/avif_benchmark_raw.log"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}"
}

require_libavif_tools() {
    local command_name package
    local packages=()

    for command_name in git python3 cmake make gcc curl tar xz sha256sum tee; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            git) package="git" ;;
            python3) package="python3" ;;
            cmake) package="cmake" ;;
            make) package="make" ;;
            gcc) package="gcc" ;;
            curl) package="curl" ;;
            tar) package="tar" ;;
            xz) package="xz" ;;
            sha256sum) package="coreutils" ;;
            tee) package="coreutils" ;;
        esac
        log "missing required libavif test command: ${command_name}"
        packages+=("${package}")
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log "ERROR: dnf is required to install libavif test prerequisites"
        return 30
    fi

    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log "installing missing libavif test packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log "ERROR: sudo is required to install libavif test prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log "ERROR: failed to install libavif test prerequisites"
        return 30
    fi

    for command_name in git python3 cmake make gcc curl tar xz sha256sum tee; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "ERROR: required libavif test command remains unavailable: ${command_name}"
            return 30
        fi
    done

    # The upstream build needs cmake >= 3.13 (FetchContent) and a C11
    # compiler; gcc >= 8 covers it.
    local cmake_version cmake_major cmake_minor cmake_rest
    cmake_version="$(cmake --version | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)"
    cmake_major="${cmake_version%%.*}"
    cmake_rest="${cmake_version#*.}"
    cmake_minor="${cmake_rest%%.*}"
    if [[ -z "${cmake_major}" || "${cmake_major}" -lt 3 || \
          ( "${cmake_major}" -eq 3 && "${cmake_minor}" -lt 13 ) ]]; then
        log "ERROR: cmake ${cmake_version:-unknown} is too old for the libavif build (cmake >= 3.13)"
        return 30
    fi
}

build_nasm() {
    # aom's SIMD kernels need an assembler; nasm is not part of the base
    # runner image, so build the official release tarball into this case's
    # isolated prefix (nothing is installed system-wide).
    if [[ -x "${PREFIX_DIR}/bin/nasm" ]]; then
        log "nasm ${NASM_VERSION} already available in the prefix"
        return 0
    fi
    mkdir -p "${DEPS_SRC_DIR}"
    local tarball="${DEPS_SRC_DIR}/nasm-${NASM_VERSION}.tar.xz"
    if [[ ! -f "${tarball}" ]]; then
        log "downloading the official nasm ${NASM_VERSION} release tarball"
        if ! curl -fSL --retry 3 --connect-timeout 30 -o "${tarball}" "${NASM_URL}"; then
            rm -f "${tarball}"
            log "ERROR: failed to download the nasm tarball from nasm.us"
            return 30
        fi
    fi
    log "verifying the nasm tarball SHA-256"
    local actual_sha256
    actual_sha256="$(sha256sum "${tarball}")"
    actual_sha256="${actual_sha256%% *}"
    if [[ "${actual_sha256}" != "${NASM_SHA256}" ]]; then
        log "ERROR: nasm tarball checksum mismatch: expected ${NASM_SHA256}, got ${actual_sha256}"
        return 30
    fi
    if [[ ! -d "${DEPS_SRC_DIR}/nasm-${NASM_VERSION}" ]]; then
        tar -xJf "${tarball}" -C "${DEPS_SRC_DIR}" || return 30
    fi
    log "building nasm ${NASM_VERSION} into the prefix"
    (cd "${DEPS_SRC_DIR}/nasm-${NASM_VERSION}" && \
        ./configure --prefix="${PREFIX_DIR}" && \
        make -j"${LIBAVIF_BUILD_JOBS}" && \
        make install) > "${PERF_WORK_DIR}/nasm-build.log" 2>&1 || {
        log "ERROR: failed to build nasm (see ${PERF_WORK_DIR}/nasm-build.log)"
        return 30
    }
    [[ -x "${PREFIX_DIR}/bin/nasm" ]] || {
        log "ERROR: the nasm executable was not installed"
        return 30
    }
}

clone_pinned_sources() {
    # libavif itself at the requested stable tag.
    if [[ -d "${SOURCE_DIR}/.git" ]]; then
        log "using cached libavif source tree ${SOURCE_DIR}"
    else
        log "cloning the official libavif v${SOFTWARE_VERSION} sources"
        if ! git clone --depth 1 --branch "v${SOFTWARE_VERSION}" \
                "${LIBAVIF_SOURCE_URL}" "${SOURCE_DIR}" \
                > "${PERF_WORK_DIR}/libavif-clone.log" 2>&1; then
            rm -rf "${SOURCE_DIR}"
            log "ERROR: failed to clone libavif v${SOFTWARE_VERSION} (see ${PERF_WORK_DIR}/libavif-clone.log)"
            return 30
        fi
    fi
    local described
    described="$(git -C "${SOURCE_DIR}" describe --tags --exact-match 2>/dev/null || true)"
    if [[ "${described}" != "v${SOFTWARE_VERSION}" ]]; then
        log "ERROR: the libavif source tree is ${described:-untagged}, expected v${SOFTWARE_VERSION}"
        return 30
    fi

    # aom at the tag pinned by the upstream ext/aom.cmd / LocalAom.cmake,
    # cloned at the in-tree location the upstream build looks for.
    local aom_dir="${SOURCE_DIR}/ext/aom"
    if [[ -d "${aom_dir}/.git" ]]; then
        log "using cached aom source tree ${aom_dir}"
    else
        log "cloning the pinned aom ${AOM_TAG} sources"
        if ! git clone --depth 1 --branch "${AOM_TAG}" \
                "${AOM_SOURCE_URL}" "${aom_dir}" \
                > "${PERF_WORK_DIR}/aom-clone.log" 2>&1; then
            rm -rf "${aom_dir}"
            log "ERROR: failed to clone aom ${AOM_TAG} (see ${PERF_WORK_DIR}/aom-clone.log)"
            return 30
        fi
    fi
    described="$(git -C "${aom_dir}" describe --tags --exact-match 2>/dev/null || true)"
    if [[ "${described}" != "${AOM_TAG}" ]]; then
        log "ERROR: the aom source tree is ${described:-untagged}, expected ${AOM_TAG}"
        return 30
    fi

    # libyuv at the commit pinned by the upstream LocalLibyuv.cmake, cloned
    # at the in-tree location the upstream build looks for.
    local libyuv_dir="${SOURCE_DIR}/ext/libyuv"
    if [[ -d "${libyuv_dir}/.git" ]]; then
        log "using cached libyuv source tree ${libyuv_dir}"
    else
        log "cloning the pinned libyuv ${LIBYUV_COMMIT} sources"
        if ! git clone "${LIBYUV_SOURCE_URL}" "${libyuv_dir}" \
                > "${PERF_WORK_DIR}/libyuv-clone.log" 2>&1; then
            rm -rf "${libyuv_dir}"
            log "ERROR: failed to clone libyuv (see ${PERF_WORK_DIR}/libyuv-clone.log)"
            return 30
        fi
        if ! git -C "${libyuv_dir}" checkout --quiet --detach "${LIBYUV_COMMIT}"; then
            rm -rf "${libyuv_dir}"
            log "ERROR: the pinned libyuv commit is unavailable: ${LIBYUV_COMMIT}"
            return 30
        fi
    fi
}

read_libavif_version() {
    # The upstream version header declares the library version as
    # AVIF_VERSION_MAJOR/MINOR/PATCH defines (official release tags carry
    # AVIF_VERSION_DEVEL 0).
    local header="$1"
    local major minor patch devel
    major="$(sed -n 's/^#define AVIF_VERSION_MAJOR[[:space:]]*\([0-9]*\).*/\1/p' "${header}")"
    minor="$(sed -n 's/^#define AVIF_VERSION_MINOR[[:space:]]*\([0-9]*\).*/\1/p' "${header}")"
    patch="$(sed -n 's/^#define AVIF_VERSION_PATCH[[:space:]]*\([0-9]*\).*/\1/p' "${header}")"
    devel="$(sed -n 's/^#define AVIF_VERSION_DEVEL[[:space:]]*\([0-9]*\).*/\1/p' "${header}")"
    [[ -n "${major}" && -n "${minor}" && -n "${patch}" ]] || return 1
    if [[ -n "${devel}" && "${devel}" != "0" ]]; then
        patch="${patch}d${devel}"
    fi
    printf '%s.%s.%s\n' "${major}" "${minor}" "${patch}"
}

build_libavif() {
    local actual_version

    initialize_runtime || return $?
    local runner_architecture
    runner_architecture="$(uname -m)"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    require_libavif_tools || return $?
    if [[ -e "${BUILD_DIR}" ]]; then
        log "ERROR: build output is not clean under ${PERF_WORK_DIR}"
        return 20
    fi

    clone_pinned_sources || return $?

    actual_version="$(read_libavif_version \
        "${SOURCE_DIR}/include/avif/avif.h")" || {
        log "ERROR: cannot read the libavif version from the upstream version header"
        return 40
    }
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: the libavif sources report ${actual_version}, which does not match tag v${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"

    build_nasm || return $?

    log "configuring the official CMake build (Release, static, pinned aom/libyuv)"
    # FETCHCONTENT_SOURCE_DIR_LIBAOM points the aom FetchContent at the
    # in-tree clone: the upstream LocalAom.cmake sets the AOM-suffixed
    # variable while its FetchContent_Declare name is libaom, so without
    # this override cmake re-clones aom from the network.
    if ! (export PATH="${PREFIX_DIR}/bin:${PATH}" && \
            export FETCHCONTENT_SOURCE_DIR_LIBAOM="${SOURCE_DIR}/ext/aom" && \
            cmake -S "${SOURCE_DIR}" -B "${BUILD_DIR}" \
                -DCMAKE_BUILD_TYPE=Release \
                -DBUILD_SHARED_LIBS=OFF \
                -DAVIF_CODEC_AOM=LOCAL \
                -DAVIF_LIBYUV=LOCAL \
                -DAVIF_BUILD_APPS=OFF \
                -DAVIF_BUILD_TESTS=OFF) \
            > "${PERF_WORK_DIR}/cmake-configure.log" 2>&1; then
        log "ERROR: the official CMake configuration failed (see ${PERF_WORK_DIR}/cmake-configure.log)"
        return 40
    fi

    log "building libavif with the pinned aom/libyuv (jobs: ${LIBAVIF_BUILD_JOBS})"
    if ! (export PATH="${PREFIX_DIR}/bin:${PATH}" && \
            cmake --build "${BUILD_DIR}" --parallel "${LIBAVIF_BUILD_JOBS}" \
                > "${PERF_WORK_DIR}/libavif-build.log" 2>&1); then
        log "ERROR: failed to build libavif (see ${PERF_WORK_DIR}/libavif-build.log)"
        return 40
    fi
    [[ -f "${BUILD_DIR}/libavif.a" ]] || {
        log "ERROR: the official libavif static library was not created"
        return 40
    }

    log "building the benchmark driver"
    if ! gcc -O2 -Wall -o "${BENCH_BIN}" \
            "${SCRIPT_DIR}/src/avif_benchmark.c" \
            -I"${SOURCE_DIR}/include" \
            "${BUILD_DIR}/libavif.a" -lpthread -lm; then
        log "ERROR: failed to compile the benchmark driver"
        return 40
    fi
    log "libavif ${actual_version} built with aom ${AOM_TAG} and libyuv ${LIBYUV_COMMIT}"
}

start_libavif_runtime() {
    initialize_runtime || return $?
    if [[ ! -x "${BENCH_BIN}" ]]; then
        log "ERROR: the benchmark driver is unavailable (run build first)"
        return 40
    fi

    log "smoke-running the benchmark driver (1080p, 1 thread, 1 run)"
    if ! "${BENCH_BIN}" --smoke > "${PERF_WORK_DIR}/smoke.log" 2>&1; then
        log "ERROR: the smoke run failed (see ${PERF_WORK_DIR}/smoke.log)"
        return 40
    fi
    if ! grep -q "AVIFBENCH version libavif ${SOFTWARE_VERSION}" "${PERF_WORK_DIR}/smoke.log"; then
        log "ERROR: the smoke run reports an unexpected libavif version"
        return 40
    fi
    if [[ "$(grep -c '^AVIFBENCH|' "${PERF_WORK_DIR}/smoke.log")" -ne 2 ]]; then
        log "ERROR: the smoke run produced an unexpected number of results"
        return 40
    fi
    log "smoke run passed"
}

run_libavif_benchmarks() {
    initialize_runtime || return $?
    if [[ ! -x "${BENCH_BIN}" ]]; then
        log "ERROR: the benchmark driver is unavailable (run build first)"
        return 50
    fi

    export SOFTWARE_VERSION EXPECTED_ARCH
    log "running the full benchmark matrix (2 ops x 3 workloads x 3 thread steps)"
    if ! "${BENCH_BIN}" 2>&1 | tee "${RAW_OUTPUT}"; then
        log "ERROR: the benchmark matrix failed (see ${RAW_OUTPUT})"
        return 50
    fi
    python3 "${SCRIPT_DIR}/scripts/collect_avif_benchmark.py" \
        "${RAW_OUTPUT}" "${RESULTS_DIR}/results.json" || return 50
    log "benchmark matrix completed"
}

stop_libavif_runtime() {
    log "libavif benchmark driver has no background service to stop"
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
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/libavif/local-* || \
          "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/libavif" ]]; then
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
        stop_libavif_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_libavif_standalone() {
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
        if build_libavif; then
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
        if start_libavif_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_libavif_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_libavif_runtime; then
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

Build the official libavif ${SOFTWARE_VERSION} with its pinned AV1 stack
(aom ${AOM_TAG}, libyuv ${LIBYUV_COMMIT}, nasm ${NASM_VERSION}) and run the
AVIF encode/decode benchmark matrix (2 ops x 3 workloads x threads
1/4/16) as a standalone performance evaluation.  Results default to
results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       libavif version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR,
  LIBAVIF_SOURCE_URL, AOM_SOURCE_URL, LIBYUV_SOURCE_URL,
  LIBAVIF_BUILD_JOBS
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
    run_libavif_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
