#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-35.1}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
PROTOBUF_SOURCE_URL="${PROTOBUF_SOURCE_URL:-https://github.com/protocolbuffers/protobuf.git}"
# Bazel version pinned by the official .bazeliskrc of protobuf v35.1.
BAZEL_VERSION="8.6.0"
# Clang toolchain used by the official benchmarks/compare.py (CC=clang).
CLANG_VERSION="19"
# Repetitions used by the official benchmarks/compare.py.
BENCHMARK_REPETITIONS="12"

SOURCE_DIR=""
BUILD_TOOLCHAIN_DIR=""
BENCHMARK_BIN=""
PROTOC_BIN=""
CLANG_BINARY=""
CLANG_VERSION_STRING=""
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

log_message() { printf '[protobuf] %s\n' "$*"; }

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
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    }
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/tmp/protobuf-perf/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
        TMPDIR="${PERF_WORK_DIR}/tmp"
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/protobuf-source"
    BUILD_TOOLCHAIN_DIR="${PERF_WORK_DIR}/build-toolchain"
    BENCHMARK_BIN="${SOURCE_DIR}/bazel-bin/benchmarks/benchmark"
    PROTOC_BIN="${SOURCE_DIR}/bazel-bin/protoc"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
}

initialize_runtime() {
    configure_runtime_paths
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR:-${PERF_WORK_DIR}/tmp}"
}

require_commands() {
    local required missing=0
    for required in git python3 curl tar sed tee nproc; do
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

prepare_bazel() {
    local arch bazel_file
    arch="$(normalize_architecture "${EXPECTED_ARCH}")"
    case "${arch}" in
        x86_64) bazel_file="bazel-${BAZEL_VERSION}-linux-x86_64" ;;
        aarch64) bazel_file="bazel-${BAZEL_VERSION}-linux-arm64" ;;
        *)
            log_message "ERROR: unsupported build architecture: ${arch}"
            return 30
            ;;
    esac
    mkdir -p "${BUILD_TOOLCHAIN_DIR}"
    if [[ -x "${BUILD_TOOLCHAIN_DIR}/bazel" ]]; then
        "${BUILD_TOOLCHAIN_DIR}/bazel" --version
        return 0
    fi
    log_message "downloading bazel ${BAZEL_VERSION} (official .bazeliskrc pin) for ${arch}"
    curl -fsSL -o "${BUILD_TOOLCHAIN_DIR}/bazel" \
        "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/${bazel_file}" || {
        log_message "ERROR: failed to download bazel ${BAZEL_VERSION} for ${arch}"
        return 30
    }
    chmod +x "${BUILD_TOOLCHAIN_DIR}/bazel"
    "${BUILD_TOOLCHAIN_DIR}/bazel" --version
}

locate_clang() {
    local candidate
    for candidate in "clang-${CLANG_VERSION}" "clang" \
        "/usr/bin/clang-${CLANG_VERSION}" "/usr/bin/clang" \
        "/usr/lib/llvm-${CLANG_VERSION}/bin/clang"; do
        if command -v "${candidate}" >/dev/null 2>&1 || [[ -x "${candidate}" ]]; then
            printf '%s\n' "${candidate}"
            return 0
        fi
    done
    return 1
}

prepare_clang() {
    local arch download_url archive_name clang_dir
    CLANG_BINARY="$(locate_clang || true)"
    if [[ -n "${CLANG_BINARY}" ]]; then
        log_message "using system clang: ${CLANG_BINARY}"
        "${CLANG_BINARY}" --version
        return 0
    fi
    arch="$(normalize_architecture "${EXPECTED_ARCH}")"
    case "${arch}" in
        x86_64) download_url="https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.7/LLVM-19.1.7-Linux-X64.tar.xz" ;;
        aarch64) download_url="https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.7/clang+llvm-19.1.7-aarch64-linux-gnu.tar.xz" ;;
        *)
            log_message "ERROR: no clang download URL for architecture ${arch}"
            return 30
            ;;
    esac
    archive_name="${download_url##*/}"
    clang_dir="${BUILD_TOOLCHAIN_DIR}/clang-${CLANG_VERSION}"
    if [[ ! -x "${clang_dir}/bin/clang" ]]; then
        log_message "downloading clang ${CLANG_VERSION} for ${arch} into the work area"
        curl -fsSL -o "${BUILD_TOOLCHAIN_DIR}/${archive_name}" "${download_url}" || {
            log_message "ERROR: failed to download clang ${CLANG_VERSION} for ${arch}"
            return 30
        }
        mkdir -p "${clang_dir}" \
            && tar -xJf "${BUILD_TOOLCHAIN_DIR}/${archive_name}" -C "${clang_dir}" --strip-components=1 || {
            log_message "ERROR: failed to extract clang ${CLANG_VERSION}"
            return 30
        }
        rm -f "${BUILD_TOOLCHAIN_DIR}/${archive_name}"
    fi
    CLANG_BINARY="${clang_dir}/bin/clang"
    log_message "using clang: ${CLANG_BINARY}"
    "${CLANG_BINARY}" --version
}

prepare_protobuf_source() {
    [[ ! -e "${SOURCE_DIR}" ]] || {
        log_message "ERROR: source directory already exists: ${SOURCE_DIR}"
        return 30
    }
    export GIT_TERMINAL_PROMPT=0
    log_message "cloning protobuf v${SOFTWARE_VERSION} from ${PROTOBUF_SOURCE_URL}"
    git clone --branch "v${SOFTWARE_VERSION}" --depth 1 \
        "${PROTOBUF_SOURCE_URL}" "${SOURCE_DIR}" || {
        log_message "ERROR: failed to clone protobuf v${SOFTWARE_VERSION}"
        return 30
    }
}

report_actual_version() {
    local version_output actual_version
    version_output="$("${PROTOC_BIN}" --version 2>&1)" || {
        log_message "ERROR: built protoc cannot report its version"
        return 40
    }
    actual_version="${version_output#libprotoc }"
    actual_version="${actual_version%%[[:space:]]*}"
    [[ -n "${actual_version}" && "${actual_version}" != "${version_output}" ]] || {
        log_message "ERROR: unexpected protoc version output: ${version_output}"
        return 40
    }
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: built protoc reports ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 40
    }
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40
}

build_protobuf() {
    initialize_runtime || return $?
    check_architecture || return $?
    require_commands || return $?
    [[ ! -e "${SOURCE_DIR}" && ! -e "${BUILD_TOOLCHAIN_DIR}" ]] || {
        log_message "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    }
    prepare_bazel || return $?
    prepare_clang || return $?
    CLANG_VERSION_STRING="$("${CLANG_BINARY}" --version | head -n 1)"
    prepare_protobuf_source || return $?

    log_message "building official benchmarks:benchmark and //:protoc with bazel ${BAZEL_VERSION} (CC=clang)"
    (
        cd "${SOURCE_DIR}"
        CC="${CLANG_BINARY}" "${BUILD_TOOLCHAIN_DIR}/bazel" \
            "--output_user_root=${BUILD_TOOLCHAIN_DIR}/bazel-cache" \
            "--repository_cache=${BUILD_TOOLCHAIN_DIR}/bazel-repo-cache" \
            build -c opt --copt=-march=native benchmarks:benchmark //:protoc
    ) || {
        log_message "ERROR: official bazel build of benchmarks:benchmark failed"
        return 40
    }
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log_message "ERROR: official benchmark binary was not produced: ${BENCHMARK_BIN}"
        return 40
    }
    [[ -x "${PROTOC_BIN}" ]] || {
        log_message "ERROR: official protoc binary was not produced: ${PROTOC_BIN}"
        return 40
    }
    report_actual_version || return $?
    log_message "protobuf ${SOFTWARE_VERSION} official benchmark artifacts are ready"
}

start_protobuf_runtime() {
    initialize_runtime || return $?
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log_message "ERROR: official protobuf benchmark binary is unavailable: ${BENCHMARK_BIN}"
        return 40
    }
    [[ -x "${PROTOC_BIN}" ]] || {
        log_message "ERROR: official protoc binary is unavailable: ${PROTOC_BIN}"
        return 40
    }
    log_message "protobuf official benchmark runtime is ready"
}

run_protobuf_benchmarks() {
    initialize_runtime || return $?
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log_message "ERROR: official protobuf benchmark binary is unavailable: ${BENCHMARK_BIN}"
        return 40
    }
    log_message "running official benchmarks/benchmark with the compare.py parameters"
    (
        cd "${SOURCE_DIR}"
        "${BENCHMARK_BIN}" \
            "--benchmark_out_format=json" \
            "--benchmark_out=${RESULTS_DIR}/benchmark.json" \
            "--benchmark_repetitions=${BENCHMARK_REPETITIONS}" \
            "--benchmark_min_time=0.05" \
            "--benchmark_enable_random_interleaving=true"
    ) || {
        log_message "ERROR: official protobuf benchmark failed"
        return 50
    }
    export SOFTWARE_VERSION EXPECTED_ARCH BENCHMARK_REPETITIONS
    python3 "${SCRIPT_DIR}/scripts/parse_benchmark.py" \
        "${RESULTS_DIR}/benchmark.json" \
        "${RESULTS_DIR}/benchmark_protobuf.json" || {
        log_message "ERROR: failed to normalize official protobuf benchmark results"
        return 50
    }
    log_message "protobuf benchmark results written to benchmark.json and benchmark_protobuf.json"
}

stop_protobuf_runtime() {
    log_message "protobuf benchmark has no background service to stop"
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
    [[ "${PERF_WORK_DIR}" == /tmp/protobuf-perf/local-* && \
       "${PERF_WORK_DIR}" != "/tmp/protobuf-perf" ]] || {
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
        stop_protobuf_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_protobuf_standalone() {
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
        if build_protobuf; then
            if standalone_runtime build-info \
                "${RESULTS_DIR}/build_info.json" \
                "${SOFTWARE_VERSION}" \
                "${PERF_ACTUAL_VERSION_FILE}" \
                "$(normalize_architecture "${EXPECTED_ARCH}")" \
                "${PERF_RUN_ID}" \
                "${CLANG_BINARY}" \
                "${CLANG_VERSION_STRING}"; then
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
        if start_protobuf_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_protobuf_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_protobuf_runtime; then
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

Build and run protobuf's official Bazel benchmark as a standalone performance
evaluation. Results default to results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       protobuf version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR, PROTOBUF_SOURCE_URL
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
    mkdir -p "${RESULTS_DIR}" || return $?
    : > "${RESULTS_DIR}/results.log"
    local pipeline_status=0
    set +e
    run_protobuf_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log_message "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
