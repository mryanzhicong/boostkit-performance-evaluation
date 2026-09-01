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
# The benchmark workload is the official GCC regression corpus shipped inside
# the release tarball: gcc/testsuite/gcc.c-torture/compile/*.c. Every file is
# an official, self-contained C translation unit maintained in the GCC source
# tree, so no external corpus download is required and every metric name is
# verbatim the official source file name.
GCC_OPT_LEVEL="${GCC_OPT_LEVEL:-O2}"
# Limit the number of corpus files benchmarked (empty = all files). A positive
# integer bounds the run to a deterministic prefix of the sorted corpus.
GCC_CORPUS_LIMIT="${GCC_CORPUS_LIMIT:-}"

SRC_DIR=""
BUILD_DIR=""
INSTALL_DIR=""
GCC_BIN=""
GCC_VERSION_STRING=""
CORPUS_DIR=""
CORPUS_COUNT=0
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

log_message() { printf '[gcc] %s\n' "$*"; }

normalize_architecture() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

# Print the official SHA-256 checksum of the GNU release tarball for
# SOFTWARE_VERSION. Checksums were computed from the files mirrored by
# ftp.gnu.org (content-length cross-checked against the official server).
gcc_tarball_sha256() {
    case "${SOFTWARE_VERSION}" in
        15.3.0)
            printf '%s\n' "fa59c1beef8995f27c4d71c1df227587189315d3e6faff1bb4306e61b0c530eb"
            ;;
        16.2.0)
            printf '%s\n' "e6738e29597f733270731aa90600f37ffdc045079dfc27ec7e8192cc81085c3e"
            ;;
        *)
            printf '[gcc] ERROR: unsupported gcc version: %s\n' \
                "${SOFTWARE_VERSION}" >&2
            return 20
            ;;
    esac
}

configure_runtime_paths() {
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    }
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/tmp/gcc-perf/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
        TMPDIR="${PERF_WORK_DIR}/tmp"
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SRC_DIR="${PERF_WORK_DIR}/gcc-src"
    BUILD_DIR="${PERF_WORK_DIR}/gcc-build"
    INSTALL_DIR="${PERF_WORK_DIR}/gcc-install"
    GCC_BIN="${BUILD_DIR}/gcc/xgcc"
    CORPUS_DIR="${SRC_DIR}/gcc/testsuite/gcc.c-torture/compile"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
}

initialize_runtime() {
    configure_runtime_paths
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR:-${PERF_WORK_DIR}/tmp}"
}

require_commands() {
    local required missing=0
    for required in gcc g++ make tar xz sha256sum curl python3 awk date sort nproc; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            log_message "ERROR: required command is missing: ${required}"
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
        log_message "ERROR: expected architecture ${expected}, runner is ${actual}"
        return 20
    }
}

prepare_gcc_source() {
    local tarball expected_sha256 actual_sha256 source_root
    [[ ! -e "${SRC_DIR}" ]] || {
        log_message "ERROR: source directory already exists: ${SRC_DIR}"
        return 30
    }
    tarball="${PERF_WORK_DIR}/gcc-${SOFTWARE_VERSION}.tar.xz"
    log_message "downloading official gcc ${SOFTWARE_VERSION} release tarball from ${GCC_SOURCE_BASE}"
    curl -fsSL --retry 3 --connect-timeout 30 \
        -o "${tarball}" \
        "${GCC_SOURCE_BASE}/gcc-${SOFTWARE_VERSION}/gcc-${SOFTWARE_VERSION}.tar.xz" || {
        log_message "ERROR: failed to download gcc-${SOFTWARE_VERSION}.tar.xz"
        return 30
    }
    expected_sha256="$(gcc_tarball_sha256)" || return 30
    actual_sha256="$(sha256sum "${tarball}" | awk '{print $1}')"
    [[ "${actual_sha256}" == "${expected_sha256}" ]] || {
        log_message "ERROR: gcc tarball checksum mismatch"
        log_message "expected: ${expected_sha256}"
        log_message "actual:   ${actual_sha256}"
        return 30
    }
    log_message "extracting gcc source (checksum verified)"
    tar -xJf "${tarball}" -C "${PERF_WORK_DIR}" || {
        log_message "ERROR: failed to extract the gcc tarball"
        return 30
    }
    source_root="${PERF_WORK_DIR}/gcc-${SOFTWARE_VERSION}"
    [[ -f "${source_root}/configure" && -d "${source_root}/gcc/testsuite/gcc.c-torture/compile" ]] || {
        log_message "ERROR: tarball did not create the expected gcc source tree"
        return 30
    }
    mv "${source_root}" "${SRC_DIR}" || return 30
    rm -f "${tarball}"
}

# Build only the C compiler driver (all-gcc) from the extracted source tree.
# The uninstalled in-tree driver build/gcc/xgcc is used for benchmarking, which
# avoids a full bootstrap and target-library build while still exercising the
# real compiler for the requested version.
build_gcc() {
    initialize_runtime || return $?
    check_architecture || return $?
    require_commands || return $?
    [[ ! -e "${SRC_DIR}" && ! -e "${BUILD_DIR}" && ! -e "${INSTALL_DIR}" ]] || {
        log_message "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    }
    gcc_tarball_sha256 >/dev/null || return $?
    prepare_gcc_source || return $?

    log_message "configuring gcc ${SOFTWARE_VERSION} (C-only, out-of-tree build)"
    mkdir -p "${BUILD_DIR}"
    (
        cd "${BUILD_DIR}"
        "${SRC_DIR}/configure" \
            --prefix="${INSTALL_DIR}" \
            --enable-languages=c \
            --disable-bootstrap \
            --disable-multilib \
            --disable-nls
    ) || {
        log_message "ERROR: gcc configure failed"
        return 40
    }
    log_message "building gcc ${SOFTWARE_VERSION} (all-gcc) with make -j$(nproc)"
    (
        cd "${BUILD_DIR}"
        make all-gcc -j"$(nproc)"
    ) || {
        log_message "ERROR: gcc make all-gcc failed"
        return 40
    }
    verify_gcc_build || return $?
    log_message "gcc ${SOFTWARE_VERSION} compiler is ready at ${GCC_BIN}"
}

# Verify the freshly built compiler by asking it for its version string and
# recording it as the actual software version.
verify_gcc_build() {
    local version_output actual_version
    [[ -x "${GCC_BIN}" ]] || {
        log_message "ERROR: built compiler is missing: ${GCC_BIN}"
        return 40
    }
    version_output="$("${GCC_BIN}" -B"${BUILD_DIR}/gcc/" --version 2>/dev/null | head -n 1)" || {
        log_message "ERROR: built gcc cannot report its version"
        return 40
    }
    # Output format: "xgcc (GCC) 16.2.0"
    actual_version="$(printf '%s\n' "${version_output}" | awk '{print $NF}')"
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: built gcc reports ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 40
    }
    GCC_VERSION_STRING="${version_output}"
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40
}

start_gcc_runtime() {
    initialize_runtime || return $?
    check_architecture || return $?
    verify_gcc_build || return $?
    [[ -d "${CORPUS_DIR}" ]] || {
        log_message "ERROR: official corpus directory is missing: ${CORPUS_DIR}"
        return 40
    }
    CORPUS_COUNT="$(find "${CORPUS_DIR}" -maxdepth 1 -name '*.c' -type f | wc -l)"
    [[ "${CORPUS_COUNT}" -gt 0 ]] || {
        log_message "ERROR: official corpus has no .c files: ${CORPUS_DIR}"
        return 40
    }
    log_message "official c-torture/compile corpus: ${CORPUS_COUNT} C files at -${GCC_OPT_LEVEL}"
    log_message "gcc benchmark runtime is ready"
}

# Time-compilation of the official corpus. Each translation unit is compiled
# with the built compiler at -${GCC_OPT_LEVEL}; the wall-clock duration is
# captured with nanosecond timestamps. One line "<basename> <elapsed_ns>" is
# written per successfully compiled file.
run_gcc_benchmarks() {
    initialize_runtime || return $?
    check_architecture || return $?
    verify_gcc_build || return $?
    mkdir -p "${RESULTS_DIR}"
    local raw_output="${RESULTS_DIR}/benchmark_compile.txt"
    : > "${raw_output}"

    local corpus_files=()
    while IFS= read -r -d '' file; do
        corpus_files+=("${file}")
    done < <(find "${CORPUS_DIR}" -maxdepth 1 -name '*.c' -type f -print0 | sort -z)
    if [[ -n "${GCC_CORPUS_LIMIT}" ]]; then
        [[ "${GCC_CORPUS_LIMIT}" =~ ^[1-9][0-9]*$ ]] || {
            log_message "ERROR: GCC_CORPUS_LIMIT must be a positive integer: ${GCC_CORPUS_LIMIT}"
            return 50
        }
        corpus_files=("${corpus_files[@]:0:${GCC_CORPUS_LIMIT}}")
    fi
    local total="${#corpus_files[@]}"
    [[ "${total}" -gt 0 ]] || {
        log_message "ERROR: no corpus files selected for benchmarking"
        return 50
    }
    log_message "benchmarking ${total} corpus files with gcc ${SOFTWARE_VERSION} at -${GCC_OPT_LEVEL}"

    local file basename obj start_ns end_ns elapsed_ns compiled=0 skipped=0
    local obj_dir="${PERF_WORK_DIR}/obj"
    mkdir -p "${obj_dir}"
    for file in "${corpus_files[@]}"; do
        basename="$(basename "${file}")"
        obj="${obj_dir}/${basename%.c}.o"
        start_ns="$(date +%s%N)"
        if "${GCC_BIN}" -B"${BUILD_DIR}/gcc/" -"${GCC_OPT_LEVEL}" \
            -c "${file}" -o "${obj}" >/dev/null 2>&1; then
            end_ns="$(date +%s%N)"
            elapsed_ns=$(( end_ns - start_ns ))
            printf '%s %s\n' "${basename}" "${elapsed_ns}" >> "${raw_output}"
            compiled=$(( compiled + 1 ))
        else
            end_ns="$(date +%s%N)"
            skipped=$(( skipped + 1 ))
            log_message "WARN: corpus file did not compile, skipped: ${basename}"
        fi
        rm -f "${obj}"
    done
    [[ "${compiled}" -gt 0 ]] || {
        log_message "ERROR: no corpus file compiled successfully"
        return 50
    }
    [[ -s "${raw_output}" ]] || {
        log_message "ERROR: benchmark output is empty: ${raw_output}"
        return 50
    }
    log_message "compiled ${compiled} files, skipped ${skipped}"

    export SOFTWARE_VERSION EXPECTED_ARCH GCC_OPT_LEVEL GCC_VERSION_STRING
    export GCC_CORPUS_COMPILED="${compiled}" GCC_CORPUS_SKIPPED="${skipped}"
    python3 "${SCRIPT_DIR}/scripts/parse_benchmark.py" \
        "${raw_output}" \
        "${RESULTS_DIR}/benchmark_gcc.json" || {
        log_message "ERROR: failed to normalize the gcc benchmark results"
        return 50
    }
    log_message "benchmark results written to benchmark_compile.txt and benchmark_gcc.json"
}

stop_gcc_runtime() {
    log_message "gcc benchmark has no background service to stop"
}

standalone_runtime() {
    python3 "${SCRIPT_DIR}/scripts/standalone_runtime.py" "$@"
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
    [[ "${PERF_WORK_DIR}" == /tmp/gcc-perf/local-* && \
       "${PERF_WORK_DIR}" != "/tmp/gcc-perf" ]] || {
        log_message "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    }
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        rm -rf -- "${PERF_WORK_DIR}" || return 70
    fi
    log_message "cleaned standalone work directory: ${PERF_WORK_DIR}"
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
        if build_gcc; then
            if standalone_runtime build-info \
                "${RESULTS_DIR}/build_info.json" \
                "${SOFTWARE_VERSION}" \
                "${PERF_ACTUAL_VERSION_FILE}" \
                "$(normalize_architecture "${EXPECTED_ARCH}")" \
                "${PERF_RUN_ID}" \
                "${GCC_VERSION_STRING}" \
                --source-url="${GCC_SOURCE_BASE}/gcc-${SOFTWARE_VERSION}/gcc-${SOFTWARE_VERSION}.tar.xz" \
                --source-sha256="$(gcc_tarball_sha256)" \
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
  GCC_SOURCE_BASE, GCC_OPT_LEVEL, GCC_CORPUS_LIMIT
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

    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" || return 10
    : > "${RESULTS_DIR}/results.log"
    local pipeline_status=0
    set +e
    run_gcc_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log_message "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
