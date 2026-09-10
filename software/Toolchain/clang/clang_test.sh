#!/usr/bin/env bash
# Clang/LLVM performance case (official prebuilt toolchain deployment).
#
# The software under test is fetched from the official LLVM prebuilt
# "LLVM-<version>-Linux-<arch>.tar.xz" release tarball and unpacked into a
# per-version directory — the distribution package manager only ships one
# version and cannot switch between patch releases.  The benchmark workload
# is the official SQLite amalgamation together with the original speedtest1
# program; both archives are pinned by version and SHA3-256 checksum.
#
# The four framework stages map to: fetch+verify the toolchain tarball
# (build), stage the pinned SQLite benchmark sources and smoke-build the
# speedtest1 binary (start), run the compile-throughput and generated-code
# scenarios (test), and remove the staged benchmark data (stop).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="clang"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-22.1.8}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

# Fixed benchmark sources from the official SQLite release area.  SQLite
# publishes SHA3-256 checksums (not SHA-256), so the archives are verified
# with python3's hashlib implementation below.
SQLITE_BENCHMARK_BASE="${SQLITE_BENCHMARK_BASE:-https://www.sqlite.org/2026}"
SQLITE_AMALGAMATION_PACKAGE="${SQLITE_AMALGAMATION_PACKAGE:-sqlite-amalgamation-3530400.zip}"
SQLITE_AMALGAMATION_SHA3_256="${SQLITE_AMALGAMATION_SHA3_256:-628a44cfe82c66aed1ccbbe85a562d2e33ebe64b3288981ed76285612227934e}"
SQLITE_SOURCE_PACKAGE="${SQLITE_SOURCE_PACKAGE:-sqlite-src-3530400.zip}"
SQLITE_SOURCE_SHA3_256="${SQLITE_SOURCE_SHA3_256:-b834d474b9b393d85a9e3ee4cc11f1329e007e9376a424ee740796f5c4bda3a8}"
SQLITE_BENCHMARK_VERSION="3.53.4"

# Official LLVM release download endpoint.
LLVM_RELEASE_BASE="${LLVM_RELEASE_BASE:-https://github.com/llvm/llvm-project/releases/download}"

# Benchmark rounds per workload and the fixed scenario ladders.
CLANG_ROUNDS="${CLANG_ROUNDS:-5}"
CLANG_COMPILE_OPTIONS=("-O0" "-O2" "-Os")
CLANG_SPEEDTEST_SIZES=(100000 500000)

# Lifecycle paths (assigned in configure_runtime_paths).
LLVM_ROOT=""
CLANG_BIN=""
CLANGXX_BIN=""
BENCHMARK_DIR=""
AMALGAMATION_DIR=""
SQLITE_SOURCE_DIR=""
SQLITE3_C=""
SQLITE3_H=""
SPEEDTEST1_C=""
SPEEDTEST1_BIN=""

log() {
    printf '[clang] %s\n' "$*"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/clang/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    LLVM_ROOT="${PERF_WORK_DIR}/llvm"
    CLANG_BIN="${LLVM_ROOT}/bin/clang"
    CLANGXX_BIN="${LLVM_ROOT}/bin/clang++"
    BENCHMARK_DIR="${PERF_WORK_DIR}/benchmark"
    AMALGAMATION_DIR="${BENCHMARK_DIR}/amalgamation"
    SQLITE_SOURCE_DIR="${BENCHMARK_DIR}/sqlite-src"
    SPEEDTEST1_BIN="${BENCHMARK_DIR}/speedtest1"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${BENCHMARK_DIR}"
}

require_clang_tools() {
    local command_name package
    local packages=()

    for command_name in sha256sum tar xz unzip sed find awk stat date tee curl python3 sudo; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            sha256sum|tee|stat) package="coreutils" ;;
            tar) package="tar" ;;
            xz) package="xz" ;;
            unzip) package="unzip" ;;
            sed) package="sed" ;;
            find) package="findutils" ;;
            awk) package="gawk" ;;
            date) package="coreutils" ;;
            curl) package="curl" ;;
            python3) package="python3" ;;
            sudo) package="sudo" ;;
        esac
        log "missing required Clang test command: ${command_name}"
        packages+=("${package}")
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log "ERROR: dnf is required to install Clang test prerequisites"
        return 30
    fi

    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log "installing missing Clang test packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log "ERROR: sudo is required to install Clang test prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log "ERROR: failed to install Clang test prerequisites"
        return 30
    fi

    for command_name in sha256sum tar xz unzip sed find awk stat date tee curl python3; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "ERROR: required Clang test command remains unavailable: ${command_name}"
            return 30
        fi
    done
}

download_archive() {
    local archive_path="$1"
    local download_url="$2"

    log "downloading ${download_url}" >&2
    if command -v curl >/dev/null 2>&1; then
        if ! curl -fSL --retry 3 --connect-timeout 30 -o "${archive_path}" "${download_url}"; then
            rm -f "${archive_path}"
            log "ERROR: failed to download ${download_url}" >&2
            return 30
        fi
    elif ! wget -q -O "${archive_path}" "${download_url}"; then
        rm -f "${archive_path}"
        log "ERROR: failed to download ${download_url}" >&2
        return 30
    fi
}

fetch_llvm_archive() {
    local archive_path
    local actual_sha256
    local archive_name
    local archive_sha256
    local local_archive_path
    local download_url

    # Every supported artifact is declared with its official archive name and
    # SHA-256 checksum.  Adding a version means adding its two architecture
    # entries here; the download, extraction, and lifecycle logic stays
    # unchanged.
    case "${SOFTWARE_VERSION}:${EXPECTED_ARCH}" in
        22.1.8:x86_64)
            archive_name="LLVM-22.1.8-Linux-X64.tar.xz"
            archive_sha256="df0e1ecf16caf3489a272a5eea4eec9b0d82878f6477fa309504f918a0006384"
            ;;
        22.1.8:aarch64)
            archive_name="LLVM-22.1.8-Linux-ARM64.tar.xz"
            archive_sha256="805efad2bb91cb4967fa569e0881d10c0f69c04461cf671cccbae19f547acc34"
            ;;
        *)
            log "ERROR: no verified LLVM release is declared for ${SOFTWARE_VERSION} on ${EXPECTED_ARCH}"
            return 10
            ;;
    esac

    local_archive_path="/home/runner/software/clang/${archive_name}"
    if [[ -f "${local_archive_path}" ]]; then
        archive_path="${local_archive_path}"
        log "using local LLVM archive ${archive_path}" >&2
    elif [[ -s "${PERF_WORK_DIR}/${archive_name}" ]]; then
        archive_path="${PERF_WORK_DIR}/${archive_name}"
        log "using cached LLVM archive ${archive_path}" >&2
    else
        archive_path="${PERF_WORK_DIR}/${archive_name}"
        download_url="${LLVM_RELEASE_BASE}/llvmorg-${SOFTWARE_VERSION}/${archive_name}"
        download_archive "${archive_path}" "${download_url}" || return 30
    fi

    actual_sha256="$(sha256sum "${archive_path}")"
    actual_sha256="${actual_sha256%% *}"
    if [[ "${actual_sha256}" != "${archive_sha256}" ]]; then
        log "ERROR: LLVM archive checksum mismatch: expected ${archive_sha256}, got ${actual_sha256}" >&2
        return 30
    fi
    printf '%s\n' "${archive_path}"
}

extract_llvm_archive() {
    local archive="$1"
    local staging_dir
    local clang_file
    local toolchain_dir

    rm -rf "${LLVM_ROOT}"
    log "extracting ${archive}"
    staging_dir="${PERF_WORK_DIR}/llvm-unpack"
    rm -rf "${staging_dir}"
    mkdir -p "${staging_dir}"
    if ! tar -xJf "${archive}" -C "${staging_dir}"; then
        rm -rf "${staging_dir}"
        log "ERROR: failed to extract ${archive}"
        return 40
    fi

    # The release tarball either unpacks into one versioned directory or
    # spreads bin/ and lib/ directly over the staging directory.  Locate the
    # directory that actually carries bin/clang and adopt it as LLVM_ROOT.
    clang_file="$(find "${staging_dir}" -maxdepth 3 -path '*/bin/clang' \( -type f -o -type l \) -print -quit)"
    if [[ -z "${clang_file}" ]]; then
        rm -rf "${staging_dir}"
        log "ERROR: cannot locate bin/clang inside the LLVM archive"
        return 40
    fi
    toolchain_dir="$(dirname "$(dirname "${clang_file}")")"
    if [[ "${toolchain_dir}" == "${staging_dir}" ]]; then
        mv "${staging_dir}" "${LLVM_ROOT}"
    else
        mv "${toolchain_dir}" "${LLVM_ROOT}"
        rm -rf "${staging_dir}"
    fi
}

fetch_sqlite_archive() {
    local package_name="$1"
    local expected_sha3="$2"
    local archive_path
    local actual_sha3
    local local_archive_path
    local download_url

    local_archive_path="/home/runner/software/clang/${package_name}"
    archive_path="${BENCHMARK_DIR}/${package_name}"
    if [[ -f "${local_archive_path}" ]]; then
        archive_path="${local_archive_path}"
        log "using local SQLite archive ${archive_path}" >&2
    elif [[ ! -s "${archive_path}" ]]; then
        download_url="${SQLITE_BENCHMARK_BASE}/${package_name}"
        download_archive "${archive_path}" "${download_url}" || return 30
    else
        log "using cached SQLite archive ${archive_path}" >&2
    fi

    actual_sha3="$(python3 - "${archive_path}" <<'PY'
import hashlib
import sys

with open(sys.argv[1], "rb") as archive:
    print(hashlib.sha3_256(archive.read()).hexdigest())
PY
)"
    if [[ "${actual_sha3}" != "${expected_sha3}" ]]; then
        log "ERROR: SQLite archive checksum mismatch for ${package_name}: expected ${expected_sha3}, got ${actual_sha3}" >&2
        return 30
    fi
    printf '%s\n' "${archive_path}"
}

prepare_benchmark_sources() {
    local amalgamation_archive
    local source_archive

    amalgamation_archive="$(fetch_sqlite_archive \
        "${SQLITE_AMALGAMATION_PACKAGE}" "${SQLITE_AMALGAMATION_SHA3_256}")" || return $?
    source_archive="$(fetch_sqlite_archive \
        "${SQLITE_SOURCE_PACKAGE}" "${SQLITE_SOURCE_SHA3_256}")" || return $?

    rm -rf "${AMALGAMATION_DIR}" "${SQLITE_SOURCE_DIR}"
    mkdir -p "${AMALGAMATION_DIR}" "${SQLITE_SOURCE_DIR}"
    log "extracting ${amalgamation_archive} and ${source_archive}"
    if ! unzip -q "${amalgamation_archive}" -d "${AMALGAMATION_DIR}"; then
        log "ERROR: failed to extract ${amalgamation_archive}"
        return 40
    fi
    if ! unzip -q "${source_archive}" -d "${SQLITE_SOURCE_DIR}"; then
        log "ERROR: failed to extract ${source_archive}"
        return 40
    fi

    SQLITE3_C="$(find "${AMALGAMATION_DIR}" -type f -name sqlite3.c -print -quit)"
    SQLITE3_H="$(find "${AMALGAMATION_DIR}" -type f -name sqlite3.h -print -quit)"
    SPEEDTEST1_C="$(find "${SQLITE_SOURCE_DIR}" -type f -name speedtest1.c -print -quit)"
    if [[ -z "${SQLITE3_C}" || -z "${SQLITE3_H}" || -z "${SPEEDTEST1_C}" ]]; then
        log "ERROR: SQLite benchmark sources are incomplete after extraction"
        return 40
    fi
    log "SQLite ${SQLITE_BENCHMARK_VERSION} benchmark sources are staged"
}

build_speedtest1_binary() {
    local output_path="$1"

    log "building speedtest1 with ${CLANG_BIN} -O2"
    if ! "${CLANG_BIN}" -O2 -I"$(dirname "${SQLITE3_H}")" \
        "${SPEEDTEST1_C}" "${SQLITE3_C}" -lm -o "${output_path}"; then
        log "ERROR: failed to build speedtest1 with clang"
        return 50
    fi
}

build_clang() {
    local archive_path
    local actual_version
    local runner_architecture

    initialize_runtime || return $?
    runner_architecture="$(uname -m)"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    require_clang_tools || return $?
    if [[ -e "${LLVM_ROOT}" ]]; then
        log "ERROR: build output is not clean under ${LLVM_ROOT}"
        return 20
    fi

    archive_path="$(fetch_llvm_archive)" || return $?
    extract_llvm_archive "${archive_path}" || return $?

    if [[ ! -x "${CLANG_BIN}" || ! -x "${CLANGXX_BIN}" ]]; then
        log "ERROR: clang/clang++ binaries not found after extraction"
        return 40
    fi
    if ldd "${CLANG_BIN}" 2>&1 | grep -q 'not found'; then
        log "ERROR: clang runtime dependencies are missing; provision them on the dedicated runner before this workflow"
        return 40
    fi
    actual_version="$("${CLANG_BIN}" --version 2>/dev/null | sed -nE 's/^clang version ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -n 1)"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: deployed clang is ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "clang ${actual_version} deployed from the official prebuilt tarball"
}

start_clang_runtime() {
    local smoke_dir

    initialize_runtime || return $?
    if [[ ! -x "${CLANG_BIN}" ]]; then
        log "ERROR: clang is not deployed (run build first)"
        return 40
    fi

    prepare_benchmark_sources || return $?

    # Smoke-build and smoke-run the benchmark binary once so the test stage
    # only ever measures the fully verified toolchain and workload pair.
    smoke_dir="${BENCHMARK_DIR}/smoke"
    rm -rf "${smoke_dir}"
    mkdir -p "${smoke_dir}"
    if ! build_speedtest1_binary "${smoke_dir}/speedtest1"; then
        rm -rf "${smoke_dir}"
        return 40
    fi
    if ! (cd "${smoke_dir}" && ./speedtest1 --size 100 --memdb test.db) >/dev/null 2>&1; then
        rm -rf "${smoke_dir}"
        log "ERROR: speedtest1 smoke run failed"
        return 40
    fi
    rm -rf "${smoke_dir}"
    log "clang benchmark runtime is ready"
}

run_compile_scenario() {
    local option
    local round
    local round_start
    local round_end
    local round_seconds
    local object_file

    for option in "${CLANG_COMPILE_OPTIONS[@]}"; do
        for round in $(seq 1 "${CLANG_ROUNDS}"); do
            object_file="${BENCHMARK_DIR}/sqlite3-${option#-}-r${round}.o"
            rm -f "${object_file}"
            round_start="$(date +%s.%N)"
            if ! "${CLANG_BIN}" "${option}" -c "${SQLITE3_C}" -o "${object_file}"; then
                log "ERROR: compile round failed: ${option} round ${round}"
                return 50
            fi
            round_end="$(date +%s.%N)"
            round_seconds="$(awk -v s="${round_start}" -v e="${round_end}" 'BEGIN { printf "%.3f", e - s }')"
            printf 'result scenario=compile workload=%s round=%d wall_seconds=%s artifact_bytes=%s\n' \
                "${option}" "${round}" "${round_seconds}" "$(stat -c %s "${object_file}")"
        done
        rm -f "${BENCHMARK_DIR}"/sqlite3-*-r*.o
    done
}

run_speedtest_scenario() {
    local size
    local round
    local round_dir
    local round_start
    local round_end
    local round_seconds
    local binary_bytes

    build_speedtest1_binary "${SPEEDTEST1_BIN}" || return $?
    binary_bytes="$(stat -c %s "${SPEEDTEST1_BIN}")"

    for size in "${CLANG_SPEEDTEST_SIZES[@]}"; do
        for round in $(seq 1 "${CLANG_ROUNDS}"); do
            round_dir="${BENCHMARK_DIR}/speedtest1-size${size}-r${round}"
            rm -rf "${round_dir}"
            mkdir -p "${round_dir}"
            round_start="$(date +%s.%N)"
            if ! (cd "${round_dir}" && "${SPEEDTEST1_BIN}" --size "${size}" --memdb test.db); then
                rm -rf "${round_dir}"
                log "ERROR: speedtest1 round failed: size ${size} round ${round}"
                return 50
            fi
            round_end="$(date +%s.%N)"
            round_seconds="$(awk -v s="${round_start}" -v e="${round_end}" 'BEGIN { printf "%.3f", e - s }')"
            printf 'result scenario=speedtest1 workload=%d round=%d wall_seconds=%s artifact_bytes=%s\n' \
                "${size}" "${round}" "${round_seconds}" "${binary_bytes}"
            rm -rf "${round_dir}"
        done
    done
}

run_clang_benchmarks() {
    local raw_output

    initialize_runtime || return $?
    require_clang_tools || return $?
    if [[ ! -x "${CLANG_BIN}" ]]; then
        log "ERROR: clang is not deployed (run build first)"
        return 50
    fi
    if [[ ! -f "${SQLITE3_C}" || ! -f "${SPEEDTEST1_C}" ]]; then
        log "ERROR: SQLite benchmark sources are not staged (run start first)"
        return 50
    fi

    raw_output="${RESULTS_DIR}/sqlite_clang_raw.log"
    export CLANG_ROUNDS
    log "running the SQLite ${SQLITE_BENCHMARK_VERSION} compile and speedtest1 scenarios with clang ${SOFTWARE_VERSION}"
    if ! {
        run_compile_scenario
        run_speedtest_scenario
    } 2>&1 | tee "${raw_output}"; then
        log "ERROR: SQLite benchmark scenarios failed (see ${raw_output})"
        return 50
    fi
    python3 "${SCRIPT_DIR}/scripts/collect_clang_benchmark.py" \
        "${raw_output}" "${RESULTS_DIR}/results.json" || return 50
    log "SQLite benchmark scenarios completed"
}

stop_clang_runtime() {
    initialize_runtime || return $?
    log "clang benchmark has no background service to stop"
    if [[ -d "${BENCHMARK_DIR}" ]]; then
        rm -rf "${BENCHMARK_DIR}"
        log "SQLite benchmark data removed from ${BENCHMARK_DIR}"
    fi
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
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/clang/local-* || \
          "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/clang" ]]; then
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
        stop_clang_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_clang_standalone() {
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
        if build_clang; then
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
        if start_clang_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_clang_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_clang_runtime; then
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

Deploy the official LLVM/Clang prebuilt toolchain and run the SQLite
compile-throughput and speedtest1 benchmarks as a standalone performance
evaluation. Results default to results/<version>/<run-id>/ inside this
directory.

Options:
  --version VERSION       LLVM/Clang version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR, CLANG_ROUNDS
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
    run_clang_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
