#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-2.44}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
GLIBC_SOURCE_URL="${GLIBC_SOURCE_URL:-https://ftp.gnu.org/gnu/glibc}"
# Official benchmark selection: the benchtests shipped inside the glibc source
# tree (benchtests/Makefile BENCHSET groups), covering math inlines, stdio,
# stdio-common formatting and stdlib workloads. USE_CLOCK_GETTIME=1 switches
# every benchtest to clock_gettime timing so both x86_64 and aarch64 report
# nanoseconds instead of architecture-specific cycles.
GLIBC_BENCHSET="${GLIBC_BENCHSET:-math-benchset stdio-benchset stdio-common-benchset stdlib-benchset}"
GLIBC_USE_CLOCK_GETTIME=1
# Benchtest outputs whose JSON documents carry verbatim named metric paths;
# the remaining bench-set outputs (bench-arc4random, bench-bsearch,
# bench-strtod) print unnamed arrays or text and are archived as evidence only.
GLIBC_PARSED_OUTPUTS="bench-math-inlines bench-fclose bench-sprintf bench-random-lock"
# All bench-set outputs produced by GLIBC_BENCHSET, copied into the results
# directory as permanent raw evidence.
GLIBC_EVIDENCE_OUTPUTS="bench-math-inlines bench-fclose bench-sprintf bench-arc4random bench-bsearch bench-random-lock bench-strtod"

SRC_DIR=""
BUILD_DIR=""
INSTALL_DIR=""
LDCONFIG_BIN=""
GCC_VERSION_STRING=""
TIMING_TYPE_OUTPUT=""
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

log_message() { printf '[glibc] %s\n' "$*"; }

normalize_architecture() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

# Print the official SHA-256 checksum of the GNU release tarball for
# SOFTWARE_VERSION; errors go to stderr so the caller can capture the result
# with a command substitution.
glibc_tarball_sha256() {
    case "${SOFTWARE_VERSION}" in
        2.43)
            printf '%s\n' "d9c86c6b5dbddb43a3e08270c5844fc5177d19442cf5b8df4be7c07cd5fa3831"
            ;;
        2.44)
            printf '%s\n' "37f600f2bef3c5e8300147059568b2a2e40a7ad6ccc65ce942556d49429cc667"
            ;;
        *)
            printf '[glibc] ERROR: unsupported glibc version: %s\n' \
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
        PERF_WORK_DIR="/tmp/glibc-perf/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
        TMPDIR="${PERF_WORK_DIR}/tmp"
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SRC_DIR="${PERF_WORK_DIR}/glibc-src"
    BUILD_DIR="${PERF_WORK_DIR}/glibc-build"
    INSTALL_DIR="${PERF_WORK_DIR}/glibc-install"
    LDCONFIG_BIN="${BUILD_DIR}/elf/ldconfig"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
}

initialize_runtime() {
    configure_runtime_paths
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR:-${PERF_WORK_DIR}/tmp}"
}

require_commands() {
    local required missing=0
    for required in gcc make tar xz sha256sum curl python3 awk nproc bison; do
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

prepare_glibc_source() {
    local tarball expected_sha256 actual_sha256 source_root
    [[ ! -e "${SRC_DIR}" ]] || {
        log_message "ERROR: source directory already exists: ${SRC_DIR}"
        return 30
    }
    tarball="${PERF_WORK_DIR}/glibc-${SOFTWARE_VERSION}.tar.xz"
    log_message "downloading official glibc ${SOFTWARE_VERSION} release tarball from ${GLIBC_SOURCE_URL}"
    curl -fsSL --retry 3 --connect-timeout 30 \
        -o "${tarball}" \
        "${GLIBC_SOURCE_URL}/glibc-${SOFTWARE_VERSION}.tar.xz" || {
        log_message "ERROR: failed to download glibc-${SOFTWARE_VERSION}.tar.xz"
        return 30
    }
    expected_sha256="$(glibc_tarball_sha256)" || return 30
    actual_sha256="$(sha256sum "${tarball}" | awk '{print $1}')"
    [[ "${actual_sha256}" == "${expected_sha256}" ]] || {
        log_message "ERROR: glibc tarball checksum mismatch"
        log_message "expected: ${expected_sha256}"
        log_message "actual:   ${actual_sha256}"
        return 30
    }
    tar -xJf "${tarball}" -C "${PERF_WORK_DIR}" || {
        log_message "ERROR: failed to extract the glibc tarball"
        return 30
    }
    source_root="${PERF_WORK_DIR}/glibc-${SOFTWARE_VERSION}"
    [[ -f "${source_root}/configure" ]] || {
        log_message "ERROR: tarball did not create glibc-${SOFTWARE_VERSION}/configure"
        return 30
    }
    mv "${source_root}" "${SRC_DIR}" || return 30
    rm -f "${tarball}"
}

# Verify the built glibc by asking a real build artifact (elf/ldconfig) for
# its version string and recording it as the actual software version.
verify_glibc_build() {
    local version_output actual_version
    [[ -x "${LDCONFIG_BIN}" ]] || {
        log_message "ERROR: built ldconfig is missing: ${LDCONFIG_BIN}"
        return 40
    }
    version_output="$("${LDCONFIG_BIN}" --version 2>/dev/null | head -n 1)" || {
        log_message "ERROR: built ldconfig cannot report its version"
        return 40
    }
    # Output format: "ldconfig (GNU libc) 2.44"
    actual_version="$(printf '%s\n' "${version_output}" | awk '{print $NF}')"
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: built glibc reports ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 40
    }
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40
}

build_glibc() {
    initialize_runtime || return $?
    check_architecture || return $?
    require_commands || return $?
    [[ ! -e "${SRC_DIR}" && ! -e "${BUILD_DIR}" && ! -e "${INSTALL_DIR}" ]] || {
        log_message "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    }
    glibc_tarball_sha256 >/dev/null || return $?
    prepare_glibc_source || return $?
    GCC_VERSION_STRING="$(gcc --version | head -n 1)"

    log_message "configuring glibc ${SOFTWARE_VERSION} (out-of-tree build)"
    mkdir -p "${BUILD_DIR}"
    (
        cd "${BUILD_DIR}"
        "${SRC_DIR}/configure" \
            --prefix="${INSTALL_DIR}" \
            --disable-werror
    ) || {
        log_message "ERROR: glibc configure failed"
        return 40
    }
    log_message "building glibc ${SOFTWARE_VERSION} with make -j$(nproc)"
    (
        cd "${BUILD_DIR}"
        make -j"$(nproc)"
    ) || {
        log_message "ERROR: glibc make build failed"
        return 40
    }
    verify_glibc_build || return $?
    log_message "glibc ${SOFTWARE_VERSION} build is ready at ${BUILD_DIR}"
}

start_glibc_runtime() {
    initialize_runtime || return $?
    check_architecture || return $?
    verify_glibc_build || return $?
    log_message "building official benchtests for benchset: ${GLIBC_BENCHSET}"
    log_message "timing: USE_CLOCK_GETTIME=${GLIBC_USE_CLOCK_GETTIME} (clock_gettime, ns on all architectures)"
    (
        cd "${BUILD_DIR}"
        make bench-build \
            BENCHSET="${GLIBC_BENCHSET}" \
            USE_CLOCK_GETTIME="${GLIBC_USE_CLOCK_GETTIME}"
    ) || {
        log_message "ERROR: glibc bench-build failed"
        return 40
    }
    local bench_name
    for bench_name in ${GLIBC_PARSED_OUTPUTS}; do
        [[ -x "${BUILD_DIR}/benchtests/${bench_name}" ]] || {
            log_message "ERROR: benchtest binary is missing: ${BUILD_DIR}/benchtests/${bench_name}"
            return 40
        }
    done
    TIMING_TYPE_OUTPUT="$("${BUILD_DIR}/benchtests/bench-timing-type")" || {
        log_message "ERROR: bench-timing-type is not runnable"
        return 40
    }
    log_message "benchtests report timing backend: ${TIMING_TYPE_OUTPUT}"
    log_message "glibc official benchtest runtime is ready"
}

run_glibc_benchmarks() {
    initialize_runtime || return $?
    check_architecture || return $?
    verify_glibc_build || return $?
    mkdir -p "${RESULTS_DIR}"
    log_message "running official benchtests with make bench (BENCHSET=\"${GLIBC_BENCHSET}\" USE_CLOCK_GETTIME=${GLIBC_USE_CLOCK_GETTIME})"
    if ! (
        cd "${BUILD_DIR}"
        make bench \
            BENCHSET="${GLIBC_BENCHSET}" \
            USE_CLOCK_GETTIME="${GLIBC_USE_CLOCK_GETTIME}"
    ) 2>&1 | tee "${RESULTS_DIR}/benchmark_bench.txt"; then
        log_message "ERROR: glibc make bench run failed"
        return 50
    fi
    [[ -s "${RESULTS_DIR}/benchmark_bench.txt" ]] || {
        log_message "ERROR: make bench output is empty: ${RESULTS_DIR}/benchmark_bench.txt"
        return 50
    }
    local output_name
    for output_name in ${GLIBC_EVIDENCE_OUTPUTS}; do
        [[ -s "${BUILD_DIR}/benchtests/${output_name}.out" ]] || {
            log_message "ERROR: benchtest output is missing: ${BUILD_DIR}/benchtests/${output_name}.out"
            return 50
        }
    done
    mkdir -p "${RESULTS_DIR}/benchtests"
    for output_name in ${GLIBC_EVIDENCE_OUTPUTS}; do
        cp "${BUILD_DIR}/benchtests/${output_name}.out" \
            "${RESULTS_DIR}/benchtests/${output_name}.out" || return 50
    done
    export SOFTWARE_VERSION EXPECTED_ARCH GLIBC_BENCHSET GLIBC_USE_CLOCK_GETTIME \
        TIMING_TYPE_OUTPUT
    python3 "${SCRIPT_DIR}/scripts/parse_benchmark.py" \
        "${RESULTS_DIR}/benchtests" \
        "${RESULTS_DIR}/benchmark_glibc.json" || {
        log_message "ERROR: failed to normalize official glibc benchtest results"
        return 50
    }
    log_message "benchtest results written to benchmark_bench.txt and benchmark_glibc.json"
}

stop_glibc_runtime() {
    log_message "glibc benchmark has no background service to stop"
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
    [[ "${PERF_WORK_DIR}" == /tmp/glibc-perf/local-* && \
       "${PERF_WORK_DIR}" != "/tmp/glibc-perf" ]] || {
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
        stop_glibc_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_glibc_standalone() {
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
        if build_glibc; then
            if standalone_runtime build-info \
                "${RESULTS_DIR}/build_info.json" \
                "${SOFTWARE_VERSION}" \
                "${PERF_ACTUAL_VERSION_FILE}" \
                "$(normalize_architecture "${EXPECTED_ARCH}")" \
                "${PERF_RUN_ID}" \
                "${GCC_VERSION_STRING}" \
                --source-url="${GLIBC_SOURCE_URL}" \
                --benchset="${GLIBC_BENCHSET}" \
                --use-clock-gettime="${GLIBC_USE_CLOCK_GETTIME}"; then
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
        if start_glibc_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_glibc_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_glibc_runtime; then
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

Build glibc from the official GNU release tarball and run the official
benchtests (make bench) as a standalone performance evaluation. Results
default to results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       glibc version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR,
  GLIBC_SOURCE_URL, GLIBC_BENCHSET
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
    run_glibc_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log_message "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
