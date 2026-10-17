#!/usr/bin/env bash
# Eigen performance case (official 5.0.1 sources with the upstream
# bench/perf_monitoring benchmark suite).
#
# Eigen is a header-only C++ template library for linear algebra.  The
# software under test is cloned from the official repository
# (gitlab.com/libeigen/eigen) at the exact stable tag and used entirely
# from the isolated work directory (nothing is installed system-wide:
# the benchmarks are single-translation-unit programs that only consume
# the Eigen headers).
#
# The benchmark is the official perf_monitoring suite shipped inside
# the Eigen source tree (bench/perf_monitoring).  It is the tool the
# Eigen developers use to monitor the compute performance of the core
# dense kernels across releases; its runall.sh drives the full
# workload set, and its run.sh defines the official build-and-run
# recipe:
#
#     $CXX -O3 -DNDEBUG -march=native $CXX_FLAGS -I eigen_src \
#         <workload>.cpp -DSCALAR=<scalar> -o <binary>
#     ./<binary> <workload>_settings.txt
#
# The workload set (runall.sh order) is the dense linear-algebra
# kernels of the official suite, each driven by its official settings
# ladder:
#
#   gemm:            C += A * B    (general matrix product)
#   gemv/gemvt:      y += A * x / y += A^T * x
#   trmv_up/upt/lo/lot: y += U/L (transposed or not) * x
#   llt:             Cholesky factorization L*L^T = A (blocked
#                     llt_inplace kernel)
#
# crossed with the three official scalar types (run.sh order):
# float, double and std::complex<double> — 24 combinations in total.
# (runall.sh also lists lazy_gemm; it is excluded here because its
# "#include \"../../BenchTimer.h\"" points at the repository root and
# the official recipe cannot compile it from the 5.0.1 tree.)
# Every binary prints one space-separated line of GFLOPS values (one
# per settings row, higher is better) measured by the official
# BenchTimer (best of several tries, each try repeating the kernel a
# workload-adaptive number of times).
#
# The sources are used verbatim.  The only setup step is the
# eigen_src/ symlink the official sources expect next to themselves
# (run.sh clones the sources there; the symlink to the verified
# checkout is the exact same layout without a second download).  One
# deviation from the letter of run.sh: it passes
# -DSCALAR=std::complex<double> unquoted, which the shell splits at
# the '<' redirection character, so the complex binaries cannot build
# from the official script as written; this case passes the identical
# compiler argument with correct quoting.
#
# The four framework stages map to: clone+verify+compile the 24
# official benchmark binaries (build), smoke-run one official ladder
# point end to end (start), run the full 24-combination matrix with
# the official settings files (test), and drop the benchmark data
# (stop — the suite runs no background service).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="eigen"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-5.0.1}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
EIGEN_SOURCE_URL="${EIGEN_SOURCE_URL:-https://gitlab.com/libeigen/eigen.git}"
EIGEN_CXX="${EIGEN_CXX:-g++}"
EIGEN_CXX_FLAGS="${EIGEN_CXX_FLAGS:-}"
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

# The official perf_monitoring workload set (runall.sh order) with the
# official settings ladder each workload is driven by.  lazy_gemm is
# excluded: its "#include \"../../BenchTimer.h\"" resolves to the
# repository root, where no BenchTimer.h exists, so the official run.sh
# recipe cannot compile it from the 5.0.1 tree (all other workloads
# include "../BenchTimer.h" and build fine).
EIGEN_WORKLOADS=(
    "gemm gemm_settings.txt"
    "gemv gemv_settings.txt"
    "gemvt gemv_settings.txt"
    "trmv_up gemv_square_settings.txt"
    "trmv_lo gemv_square_settings.txt"
    "trmv_upt gemv_square_settings.txt"
    "trmv_lot gemv_square_settings.txt"
    "llt gemm_square_settings.txt"
)

# The official scalar ladder (run.sh order): prefix, scalar type.
EIGEN_SCALARS=(
    "s float"
    "d double"
    "c std::complex<double>"
)

# Parallel compilation of the benchmark binaries.  Each binary is one
# translation unit instantiating the whole kernel family; a low cap
# keeps the memory footprint bounded on any runner.
EIGEN_BUILD_JOBS="${EIGEN_BUILD_JOBS:-4}"

# Lifecycle paths (assigned in configure_runtime_paths).
SOURCE_DIR=""
PERF_MONITORING_DIR=""
BIN_DIR=""
SMOKE_SETTINGS=""
SMOKE_LOG=""

log() {
    printf '[eigen] %s\n' "$*"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/eigen/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/eigen-source"
    PERF_MONITORING_DIR="${SOURCE_DIR}/bench/perf_monitoring"
    BIN_DIR="${PERF_WORK_DIR}/bin"
    SMOKE_SETTINGS="${PERF_WORK_DIR}/smoke_settings.txt"
    SMOKE_LOG="${PERF_WORK_DIR}/smoke.log"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}"
}

require_eigen_tools() {
    local command_name
    local packages=()

    for command_name in git python3 "${EIGEN_CXX}" tee; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "missing required Eigen test command: ${command_name}"
            packages+=("${command_name}")
        fi
    done
    if [[ "${#packages[@]}" -ne 0 ]]; then
        log "ERROR: install the required tools first: ${packages[*]}"
        return 30
    fi

    # The Eigen 5.0.1 sources require at least C++14.
    local gxx_major
    gxx_major="$("${EIGEN_CXX}" -dumpversion 2>/dev/null | cut -d. -f1)"
    if [[ -z "${gxx_major}" || "${gxx_major}" -lt 5 ]]; then
        log "ERROR: ${EIGEN_CXX} ${gxx_major:-unknown} is too old, the Eigen sources need C++14 (g++ >= 5)"
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
    local header="$1"
    sed -n 's/^#define EIGEN_VERSION_STRING[[:space:]]\+"\([^"]*\)".*/\1/p' "${header}"
}

compile_benchmark_binary() { # scalar_prefix scalar_type workload
    local prefix="$1" scalar="$2" workload="$3"
    local binary="${BIN_DIR}/${prefix}_${workload}"

    # The official run.sh recipe, with the SCALAR argument quoted so
    # that std::complex<double> survives the shell (run.sh passes it
    # unquoted and the '<' breaks the command line).
    if ! "${EIGEN_CXX}" -O3 -DNDEBUG -march=native \
            ${EIGEN_CXX_FLAGS} \
            -I "${SOURCE_DIR}" \
            "${PERF_MONITORING_DIR}/${workload}.cpp" \
            "-DSCALAR=${scalar}" \
            -o "${binary}" \
            > "${binary}.build.log" 2>&1; then
        log "ERROR: failed to compile ${workload} for ${scalar} (see ${binary}.build.log)"
        return 40
    fi
    [[ -x "${binary}" ]]
}

build_eigen() {
    local tag described actual_version entry workload settings prefix scalar
    local -a jobs=()

    initialize_runtime || return $?
    check_architecture || return $?
    require_eigen_tools || return $?
    [[ ! -e "${SOURCE_DIR}" ]] || {
        log "ERROR: source directory is not clean under ${PERF_WORK_DIR}"
        return 20
    }

    tag="${SOFTWARE_VERSION}"
    log "cloning the official Eigen ${tag} sources"
    if ! git clone --branch "${tag}" --depth 1 \
            "${EIGEN_SOURCE_URL}" "${SOURCE_DIR}" \
            > "${PERF_WORK_DIR}/eigen-clone.log" 2>&1; then
        rm -rf "${SOURCE_DIR}"
        log "ERROR: failed to clone Eigen ${tag} (see ${PERF_WORK_DIR}/eigen-clone.log)"
        return 30
    fi
    described="$(git -C "${SOURCE_DIR}" describe --tags --exact-match 2>/dev/null || true)"
    if [[ "${described}" != "${tag}" ]]; then
        log "ERROR: the Eigen source tree is ${described:-untagged}, expected ${tag}"
        return 30
    fi
    actual_version="$(read_header_version "${SOURCE_DIR}/Eigen/Version")"
    if [[ -z "${actual_version}" ]]; then
        log "ERROR: cannot read the Eigen version header"
        return 40
    fi
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: the Eigen sources report ${actual_version}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40

    # The official sources include "eigen_src/Eigen/Core" relative to
    # bench/perf_monitoring; run.sh populates that path by cloning the
    # sources.  The symlink provides the identical layout pointing at
    # the already verified checkout.
    ln -sfn "${SOURCE_DIR}" "${PERF_MONITORING_DIR}/eigen_src" || return 40

    log "compiling the official perf_monitoring binaries (jobs: ${EIGEN_BUILD_JOBS})"
    mkdir -p "${BIN_DIR}"
    for entry in "${EIGEN_SCALARS[@]}"; do
        read -r prefix scalar <<<"${entry}"
        for workload_entry in "${EIGEN_WORKLOADS[@]}"; do
            read -r workload _ <<<"${workload_entry}"
            jobs+=("${prefix}|${scalar}|${workload}")
        done
    done

    local failure=0 running=0
    for entry in "${jobs[@]}"; do
        IFS='|' read -r prefix scalar workload <<<"${entry}"
        compile_benchmark_binary "${prefix}" "${scalar}" "${workload}" &
        running=$((running + 1))
        if (( running >= EIGEN_BUILD_JOBS )); then
            if ! wait -n; then
                failure=1
            fi
            running=$((running - 1))
        fi
    done
    if ! wait; then
        failure=1
    fi
    if [[ "${failure}" -ne 0 ]]; then
        log "ERROR: one or more official benchmark binaries failed to compile"
        return 40
    fi

    local expected=0
    for entry in "${EIGEN_SCALARS[@]}"; do
        read -r prefix _ <<<"${entry}"
        for workload_entry in "${EIGEN_WORKLOADS[@]}"; do
            read -r workload _ <<<"${workload_entry}"
            expected=$((expected + 1))
            [[ -x "${BIN_DIR}/${prefix}_${workload}" ]] || {
                log "ERROR: official benchmark binary is missing: ${prefix}_${workload}"
                return 40
            }
        done
    done
    log "built ${expected} official perf_monitoring binaries"
}

start_eigen_runtime() {
    local smoke_output smoke_value

    initialize_runtime || return $?
    [[ -x "${BIN_DIR}/d_gemm" ]] || {
        log "ERROR: official benchmark binary is unavailable: d_gemm"
        return 40
    }

    # Smoke run: the first row of the official gemm_settings.txt
    # ladder (8 8 8) through the double-precision gemm binary.
    printf '8 8 8\n' > "${SMOKE_SETTINGS}" || return 40
    log "smoke-running the official d_gemm on a one-point ladder"
    if ! "${BIN_DIR}/d_gemm" "${SMOKE_SETTINGS}" > "${SMOKE_LOG}" 2>&1; then
        log "ERROR: the official d_gemm smoke run failed (see ${SMOKE_LOG})"
        return 40
    fi
    smoke_output="$(tr -s '[:space:]' ' ' < "${SMOKE_LOG}")"
    smoke_value="${smoke_output%% *}"
    if ! [[ "${smoke_value}" =~ ^[0-9]+([.][0-9]+)?([eE][-+]?[0-9]+)?$ ]] || \
            ! awk -v v="${smoke_value}" 'BEGIN { if (v + 0 > 0) exit 0; exit 1 }'; then
        log "ERROR: the d_gemm smoke run produced no positive GFLOPS value: ${smoke_output}"
        return 40
    fi
    log "d_gemm smoke GFLOPS: ${smoke_value}"
}

run_eigen_benchmarks() {
    initialize_runtime || return $?
    [[ -d "${BIN_DIR}" && -d "${PERF_MONITORING_DIR}" ]] || {
        log "ERROR: official benchmark binaries are unavailable"
        return 40
    }
    export SOFTWARE_VERSION EXPECTED_ARCH
    export EIGEN_SOURCE_URL EIGEN_CXX EIGEN_CXX_FLAGS
    python3 "${SCRIPT_DIR}/scripts/run_perf_monitoring.py" \
        "${BIN_DIR}" "${PERF_MONITORING_DIR}" \
        "${RESULTS_DIR}/benchmark_perf_monitoring.json" || return 50
}

stop_eigen_runtime() {
    log "Eigen perf_monitoring has no background service to stop"
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
    [[ "${PERF_WORK_DIR}" == /home/runner/boostkit-perf/eigen/local-* && "${PERF_WORK_DIR}" != "/home/runner/boostkit-perf/eigen" ]] || {
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
        stop_eigen_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_eigen_standalone() {
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
        if build_eigen; then
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
        if start_eigen_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi

    if [[ "${stage_status}" -eq 0 ]]; then
        if run_eigen_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_eigen_runtime; then
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
Clone the official Eigen sources, compile the official perf_monitoring
benchmark binaries, run the official 27-combination workload matrix,
collect the environment, validate results, generate a report, and clean
the isolated work directory.

Options:
  --version VERSION       Eigen version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR,
  EIGEN_SOURCE_URL, EIGEN_CXX, EIGEN_CXX_FLAGS, EIGEN_BUILD_JOBS
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
    run_eigen_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
