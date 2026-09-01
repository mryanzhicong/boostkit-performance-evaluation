#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-16.2.0}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
GCC_SOURCE_BASE="${GCC_SOURCE_BASE:-https://ftp.gnu.org/gnu/gcc}"
GCC_OFFLINE_DIR="${GCC_OFFLINE_DIR:-/home/runner/software/gcc}"
GCC_BENCHMARK_DATA_ROOT="${GCC_BENCHMARK_DATA_ROOT:-/home/runner/gcc-data}"
# The benchmark workload is the official GCC regression corpus shipped inside
# the release tarball: gcc/testsuite/gcc.c-torture/compile/*.c. Every file is
# an official, self-contained C translation unit maintained in the GCC source
# tree, so no external corpus download is required and every metric name is
# verbatim the official source file name.
GCC_OPT_LEVEL="${GCC_OPT_LEVEL:-O2}"
GCC_BENCHMARK_ITERATIONS="${GCC_BENCHMARK_ITERATIONS:-3}"

SRC_DIR=""
BUILD_DIR=""
INSTALL_DIR=""
GCC_BIN=""
GCC_VERSION_STRING=""
GCC_SOURCE_SHA256=""
CORPUS_DIR=""
BENCHMARK_DATA_DIR=""
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

log() {
    printf '[gcc] %s\n' "$*"
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
            log "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    case "$(uname -m)" in
        x86_64|amd64)
            if [[ "${EXPECTED_ARCH}" != "x86_64" ]]; then
                log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is x86_64"
                return 20
            fi
            ;;
        aarch64|arm64)
            if [[ "${EXPECTED_ARCH}" != "aarch64" ]]; then
                log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is aarch64"
                return 20
            fi
            ;;
        *)
            log "ERROR: unsupported runner architecture: $(uname -m)"
            return 20
            ;;
    esac
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/tmp/gcc-perf/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${TMPDIR:-${PERF_WORK_DIR}/tmp}"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SRC_DIR="${PERF_WORK_DIR}/gcc-src"
    BUILD_DIR="${PERF_WORK_DIR}/gcc-build"
    INSTALL_DIR="${PERF_WORK_DIR}/gcc-install"
    GCC_BIN="${BUILD_DIR}/gcc/xgcc"
    CORPUS_DIR="${SRC_DIR}/gcc/testsuite/gcc.c-torture/compile"
    BENCHMARK_DATA_DIR="${GCC_BENCHMARK_DATA_ROOT}/${SOFTWARE_VERSION}/${EXPECTED_ARCH}/${PERF_RUN_ID}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
}

initialize_runtime() {
    if configure_runtime_paths; then
        :
    else
        return $?
    fi
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR:-${PERF_WORK_DIR}/tmp}"
}

install_dependencies() {
    local required missing=0
    for required in gcc g++ make tar xz sha256sum curl python3 awk date sort nproc; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            missing=1
        fi
    done
    if [[ "${missing}" -eq 0 ]] && printf \
        '#include <gmp.h>\n#include <mpfr.h>\n#include <mpc.h>\nint main(void) { return 0; }\n' | \
        g++ -x c++ -fsyntax-only - >/dev/null 2>&1; then
        return
    fi

    log "installing missing GCC build dependencies"
    if command -v dnf >/dev/null 2>&1; then
        if [[ "${EUID}" -eq 0 ]]; then
            if ! dnf install -y gcc gcc-c++ make tar xz coreutils curl python3 \
                gawk findutils gmp-devel mpfr-devel libmpc-devel bison flex; then
                log "ERROR: failed to install GCC build dependencies"
                return 30
            fi
        elif command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
            if ! sudo -n dnf install -y gcc gcc-c++ make tar xz coreutils curl python3 \
                gawk findutils gmp-devel mpfr-devel libmpc-devel bison flex; then
                log "ERROR: failed to install GCC build dependencies"
                return 30
            fi
        else
            log "ERROR: root privileges are required to install GCC build dependencies"
            return 30
        fi
    elif command -v yum >/dev/null 2>&1; then
        if [[ "${EUID}" -eq 0 ]]; then
            if ! yum install -y gcc gcc-c++ make tar xz coreutils curl python3 \
                gawk findutils gmp-devel mpfr-devel libmpc-devel bison flex; then
                log "ERROR: failed to install GCC build dependencies"
                return 30
            fi
        elif command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
            if ! sudo -n yum install -y gcc gcc-c++ make tar xz coreutils curl python3 \
                gawk findutils gmp-devel mpfr-devel libmpc-devel bison flex; then
                log "ERROR: failed to install GCC build dependencies"
                return 30
            fi
        else
            log "ERROR: root privileges are required to install GCC build dependencies"
            return 30
        fi
    elif command -v apt-get >/dev/null 2>&1; then
        if [[ "${EUID}" -eq 0 ]]; then
            if ! env DEBIAN_FRONTEND=noninteractive apt-get update; then
                log "ERROR: failed to update APT package metadata"
                return 30
            fi
            if ! env DEBIAN_FRONTEND=noninteractive apt-get install -y \
                build-essential tar xz-utils coreutils curl python3 gawk findutils \
                libgmp-dev libmpfr-dev libmpc-dev bison flex; then
                log "ERROR: failed to install GCC build dependencies"
                return 30
            fi
        elif command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
            if ! sudo -n env DEBIAN_FRONTEND=noninteractive apt-get update; then
                log "ERROR: failed to update APT package metadata"
                return 30
            fi
            if ! sudo -n env DEBIAN_FRONTEND=noninteractive apt-get install -y \
                build-essential tar xz-utils coreutils curl python3 gawk findutils \
                libgmp-dev libmpfr-dev libmpc-dev bison flex; then
                log "ERROR: failed to install GCC build dependencies"
                return 30
            fi
        else
            log "ERROR: root privileges are required to install GCC build dependencies"
            return 30
        fi
    else
        log "ERROR: unsupported package manager; cannot install GCC dependencies"
        return 30
    fi

    for required in gcc g++ make tar xz sha256sum curl python3 awk date sort nproc; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            log "ERROR: required command is still missing after installation: ${required}"
            return 30
        fi
    done
    if ! printf '#include <gmp.h>\n#include <mpfr.h>\n#include <mpc.h>\nint main(void) { return 0; }\n' | \
        g++ -x c++ -fsyntax-only - >/dev/null 2>&1; then
        log "ERROR: GMP, MPFR, or MPC development headers are unavailable after installation"
        return 30
    fi
}

prepare_gcc_source() {
    local tarball offline_tarball actual_sha256 source_root

    case "${SOFTWARE_VERSION}" in
        15.3.0)
            GCC_SOURCE_SHA256="fa59c1beef8995f27c4d71c1df227587189315d3e6faff1bb4306e61b0c530eb"
            ;;
        16.2.0)
            GCC_SOURCE_SHA256="e6738e29597f733270731aa90600f37ffdc045079dfc27ec7e8192cc81085c3e"
            ;;
        *)
            log "ERROR: unsupported GCC version: ${SOFTWARE_VERSION}"
            return 20
            ;;
    esac

    if [[ -e "${SRC_DIR}" ]]; then
        log "ERROR: source directory already exists: ${SRC_DIR}"
        return 30
    fi
    tarball="${PERF_WORK_DIR}/gcc-${SOFTWARE_VERSION}.tar.xz"
    offline_tarball="${GCC_OFFLINE_DIR}/gcc-${SOFTWARE_VERSION}.tar.xz"
    if [[ -f "${offline_tarball}" ]]; then
        log "using local GCC archive ${offline_tarball}"
        if ! cp "${offline_tarball}" "${tarball}"; then
            log "ERROR: failed to copy local GCC archive"
            return 30
        fi
    else
        log "downloading official gcc ${SOFTWARE_VERSION} release tarball from ${GCC_SOURCE_BASE}"
        if ! curl -fsSL --retry 3 --connect-timeout 30 \
            -o "${tarball}" \
            "${GCC_SOURCE_BASE}/gcc-${SOFTWARE_VERSION}/gcc-${SOFTWARE_VERSION}.tar.xz"; then
            log "ERROR: failed to download gcc-${SOFTWARE_VERSION}.tar.xz"
            return 30
        fi
    fi
    actual_sha256="$(sha256sum "${tarball}" | awk '{print $1}')"
    if [[ "${actual_sha256}" != "${GCC_SOURCE_SHA256}" ]]; then
        log "ERROR: GCC tarball checksum mismatch"
        log "expected: ${GCC_SOURCE_SHA256}"
        log "actual:   ${actual_sha256}"
        return 30
    fi
    log "extracting GCC source (checksum verified)"
    if ! tar -xJf "${tarball}" -C "${PERF_WORK_DIR}"; then
        log "ERROR: failed to extract the GCC tarball"
        return 30
    fi
    source_root="${PERF_WORK_DIR}/gcc-${SOFTWARE_VERSION}"
    if [[ ! -f "${source_root}/configure" || \
          ! -d "${source_root}/gcc/testsuite/gcc.c-torture/compile" ]]; then
        log "ERROR: tarball did not create the expected GCC source tree"
        return 30
    fi
    if ! mv "${source_root}" "${SRC_DIR}"; then
        log "ERROR: failed to place the extracted GCC source tree"
        return 30
    fi
    rm -f "${tarball}"
}

# Build only the C compiler driver (all-gcc) from the extracted source tree.
# The uninstalled in-tree driver build/gcc/xgcc is used for benchmarking, which
# avoids a full bootstrap and target-library build while still exercising the
# real compiler for the requested version.
build_gcc() {
    local version_output actual_version

    if initialize_runtime; then
        :
    else
        return $?
    fi
    if install_dependencies; then
        :
    else
        return $?
    fi
    if [[ -e "${SRC_DIR}" || -e "${BUILD_DIR}" || -e "${INSTALL_DIR}" ]]; then
        log "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    fi
    if prepare_gcc_source; then
        :
    else
        return $?
    fi

    log "configuring GCC ${SOFTWARE_VERSION} (C-only, out-of-tree build)"
    mkdir -p "${BUILD_DIR}"
    if ! (
        cd "${BUILD_DIR}"
        "${SRC_DIR}/configure" \
            --prefix="${INSTALL_DIR}" \
            --enable-languages=c \
            --disable-bootstrap \
            --disable-multilib \
            --disable-nls
    ); then
        log "ERROR: GCC configure failed"
        return 40
    fi
    log "building GCC ${SOFTWARE_VERSION} (all-gcc) with make -j$(nproc)"
    if ! (
        cd "${BUILD_DIR}"
        make all-gcc -j"$(nproc)"
    ); then
        log "ERROR: GCC make all-gcc failed"
        return 40
    fi
    if [[ ! -x "${GCC_BIN}" ]]; then
        log "ERROR: built compiler is missing: ${GCC_BIN}"
        return 40
    fi
    if ! version_output="$("${GCC_BIN}" -B"${BUILD_DIR}/gcc/" --version 2>/dev/null | head -n 1)"; then
        log "ERROR: built GCC cannot report its version"
        return 40
    fi
    actual_version="$(printf '%s\n' "${version_output}" | awk '{print $NF}')"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: built GCC reports ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 40
    fi
    GCC_VERSION_STRING="${version_output}"
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "GCC ${SOFTWARE_VERSION} compiler is ready at ${GCC_BIN}"
}

start_gcc_runtime() {
    if initialize_runtime; then
        :
    else
        return $?
    fi
    if [[ ! -x "${GCC_BIN}" ]]; then
        log "ERROR: built compiler is missing: ${GCC_BIN}"
        return 40
    fi
    if [[ ! -d "${CORPUS_DIR}" ]]; then
        log "ERROR: official corpus directory is missing: ${CORPUS_DIR}"
        return 40
    fi
    local corpus_count
    corpus_count="$(find "${CORPUS_DIR}" -maxdepth 1 -name '*.c' -type f | wc -l)"
    if [[ "${corpus_count}" -le 0 ]]; then
        log "ERROR: official corpus has no .c files: ${CORPUS_DIR}"
        return 40
    fi
    if [[ ! "${GCC_BENCHMARK_ITERATIONS}" =~ ^[1-9][0-9]*$ ]]; then
        log "ERROR: GCC_BENCHMARK_ITERATIONS must be a positive integer: ${GCC_BENCHMARK_ITERATIONS}"
        return 40
    fi
    log "official c-torture/compile corpus: ${corpus_count} C files at -${GCC_OPT_LEVEL}"
    log "GCC benchmark runtime is ready"
}

# Compile every official corpus file repeatedly with the built compiler at
# -${GCC_OPT_LEVEL}.  Each duration uses Python's monotonic clock; raw compiler
# output and the machine-readable timing stream are preserved separately.
run_gcc_benchmarks() {
    local actual_version

    if initialize_runtime; then
        :
    else
        return $?
    fi
    if [[ ! -x "${GCC_BIN}" ]]; then
        log "ERROR: built compiler is missing: ${GCC_BIN}"
        return 40
    fi
    if ! GCC_VERSION_STRING="$("${GCC_BIN}" -B"${BUILD_DIR}/gcc/" --version 2>/dev/null | head -n 1)"; then
        log "ERROR: built GCC cannot report its version"
        return 40
    fi
    actual_version="$(printf '%s\n' "${GCC_VERSION_STRING}" | awk '{print $NF}')"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: built GCC reports ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "${RESULTS_DIR}"
    local timing_output="${RESULTS_DIR}/benchmark_compile.txt"
    local compiler_output="${RESULTS_DIR}/compiler-output.log"
    : > "${timing_output}"
    printf '[gcc] raw compiler output for GCC %s\n' "${SOFTWARE_VERSION}" > "${compiler_output}"

    local corpus_files=()
    while IFS= read -r -d '' file; do
        corpus_files+=("${file}")
    done < <(find "${CORPUS_DIR}" -maxdepth 1 -name '*.c' -type f -print0 | sort -z)
    local total="${#corpus_files[@]}"
    if [[ "${total}" -le 0 ]]; then
        log "ERROR: no corpus files selected for benchmarking"
        return 50
    fi
    log "benchmarking ${total} corpus files for ${GCC_BENCHMARK_ITERATIONS} iterations with GCC ${SOFTWARE_VERSION} at -${GCC_OPT_LEVEL}"

    local file basename obj start_ns end_ns elapsed_ns compiled=0 iteration
    local obj_dir="${BENCHMARK_DATA_DIR}/obj"
    mkdir -p "${obj_dir}"
    for ((iteration = 1; iteration <= GCC_BENCHMARK_ITERATIONS; iteration++)); do
        log "starting official corpus iteration ${iteration}/${GCC_BENCHMARK_ITERATIONS}"
        for file in "${corpus_files[@]}"; do
            basename="$(basename "${file}")"
            obj="${obj_dir}/${basename%.c}.o"
            start_ns="$(python3 -c 'from time import monotonic_ns; print(monotonic_ns())')"
            printf '[gcc-compile] iteration=%s source=%s\n' "${iteration}" "${basename}" >> "${compiler_output}"
            if "${GCC_BIN}" -B"${BUILD_DIR}/gcc/" -"${GCC_OPT_LEVEL}" \
                -c "${file}" -o "${obj}" >> "${compiler_output}" 2>&1; then
                end_ns="$(python3 -c 'from time import monotonic_ns; print(monotonic_ns())')"
                elapsed_ns=$(( end_ns - start_ns ))
                printf '%s %s %s\n' "${iteration}" "${basename}" "${elapsed_ns}" >> "${timing_output}"
                compiled=$(( compiled + 1 ))
            else
                log "ERROR: official corpus file did not compile: ${basename} (iteration ${iteration})"
                return 50
            fi
            rm -f "${obj}"
        done
    done
    if [[ "${compiled}" -ne $(( total * GCC_BENCHMARK_ITERATIONS )) ]]; then
        log "ERROR: compiled file count is incomplete: ${compiled}"
        return 50
    fi
    if [[ ! -s "${timing_output}" ]]; then
        log "ERROR: benchmark timing output is empty: ${timing_output}"
        return 50
    fi
    log "compiled ${compiled} official corpus files"

    export SOFTWARE_VERSION EXPECTED_ARCH GCC_OPT_LEVEL GCC_VERSION_STRING
    export GCC_CORPUS_COMPILED="${compiled}" GCC_CORPUS_FILES="${total}"
    export GCC_BENCHMARK_ITERATIONS
    if ! python3 "${SCRIPT_DIR}/scripts/parse_benchmark.py" \
        "${timing_output}" \
        "${RESULTS_DIR}/benchmark_gcc.json"; then
        log "ERROR: failed to normalize the GCC benchmark results"
        return 50
    fi
    log "benchmark results written to benchmark_compile.txt, compiler-output.log, and benchmark_gcc.json"
}

stop_gcc_runtime() {
    if initialize_runtime; then
        :
    else
        return $?
    fi
    if [[ -d "${BENCHMARK_DATA_DIR}" ]]; then
        if [[ "${BENCHMARK_DATA_DIR}" != "${GCC_BENCHMARK_DATA_ROOT}"/* ]]; then
            log "ERROR: refusing to clean unexpected GCC benchmark data directory: ${BENCHMARK_DATA_DIR}"
            return 70
        fi
        if ! rm -rf -- "${BENCHMARK_DATA_DIR}"; then
            log "ERROR: failed to clean GCC benchmark data directory: ${BENCHMARK_DATA_DIR}"
            return 70
        fi
    fi
    log "GCC benchmark has no background service to stop"
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
    if [[ "${PERF_WORK_DIR}" != /tmp/gcc-perf/local-* || \
          "${PERF_WORK_DIR}" == "/tmp/gcc-perf" ]]; then
        log "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    fi
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        if ! rm -rf -- "${PERF_WORK_DIR}"; then
            log "ERROR: failed to clean standalone work directory: ${PERF_WORK_DIR}"
            return 70
        fi
    fi
    log "cleaned standalone work directory: ${PERF_WORK_DIR}"
}

emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then
        stop_gcc_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_gcc_standalone() {
    local stage_status=0 failed_stage="" cleanup_status="passed" finalize_status=0
    local command_status="passed"

    if configure_runtime_paths; then
        :
    else
        return $?
    fi
    STANDALONE_STOP_DONE=0
    STANDALONE_CLEANUP_DONE=0
    trap emergency_standalone_cleanup EXIT
    if initialize_runtime; then
        :
    else
        return $?
    fi

    if standalone_runtime system "${RESULTS_DIR}/system_info.json" && \
        standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json"; then
        :
    else
        stage_status=$?
        failed_stage="prepare"
    fi

    if [[ "${stage_status}" -eq 0 ]]; then
        if build_gcc; then
            if standalone_runtime build-info \
                "${RESULTS_DIR}/build_info.json" \
                "${SOFTWARE_VERSION}" \
                "${PERF_ACTUAL_VERSION_FILE}" \
                "${EXPECTED_ARCH}" \
                "${PERF_RUN_ID}" \
                "${GCC_VERSION_STRING}" \
                --source-url="${GCC_SOURCE_BASE}/gcc-${SOFTWARE_VERSION}/gcc-${SOFTWARE_VERSION}.tar.xz" \
                --source-sha256="${GCC_SOURCE_SHA256}" \
                --configure-flags="--enable-languages=c --disable-bootstrap --disable-multilib --disable-nls" \
                --opt-level="${GCC_OPT_LEVEL}"; then
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
        if start_gcc_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_gcc_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_gcc_runtime; then
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

Build the C compiler from the official GNU release tarball and time-compile
the official gcc.c-torture/compile regression corpus shipped inside the
tarball as a standalone performance evaluation. Results default to
results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       gcc version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR,
  GCC_SOURCE_BASE, GCC_OFFLINE_DIR, GCC_BENCHMARK_DATA_ROOT,
  GCC_OPT_LEVEL, GCC_BENCHMARK_ITERATIONS
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

    if configure_runtime_paths; then
        :
    else
        return $?
    fi
    if ! mkdir -p "${RESULTS_DIR}"; then
        log "ERROR: failed to create the standalone results directory: ${RESULTS_DIR}"
        return 10
    fi
    : > "${RESULTS_DIR}/results.log"
    local pipeline_status=0
    set +e
    run_gcc_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
