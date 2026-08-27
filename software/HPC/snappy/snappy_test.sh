#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.2.2}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
SNAPPY_SOURCE_URL="${SNAPPY_SOURCE_URL:-https://github.com/google/snappy.git}"
SOURCE_DIR=""
BUILD_DIR=""
BENCHMARK_BIN=""
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

log() { printf '[snappy] %s\n' "$*"; }

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
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/tmp/snappy-perf/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
        TMPDIR="${PERF_WORK_DIR}/tmp"
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/snappy-source"
    BUILD_DIR="${SOURCE_DIR}/build"
    BENCHMARK_BIN="${BUILD_DIR}/snappy_benchmark"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
}

initialize_runtime() {
    configure_runtime_paths
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR:-${PERF_WORK_DIR}/tmp}"
}

require_commands() {
    local required package
    local packages=()

    for required in git python3 cmake make c++ sed tee; do
        if command -v "${required}" >/dev/null 2>&1; then
            continue
        fi
        case "${required}" in
            git) package="git" ;;
            python3) package="python3" ;;
            cmake) package="cmake" ;;
            make) package="make" ;;
            c++) package="gcc-c++" ;;
            sed) package="sed" ;;
            tee) package="coreutils" ;;
        esac
        log "missing required Snappy build command: ${required}"
        packages+=("${package}")
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log "ERROR: dnf is required to install Snappy build prerequisites"
        return 30
    fi

    log "installing missing Snappy build packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log "ERROR: sudo is required to install Snappy build prerequisites"
        return 30
    elif ! sudo -n dnf install -y "${packages[@]}"; then
        log "ERROR: failed to install Snappy build prerequisites"
        return 30
    fi

    for required in git python3 cmake make c++ sed tee; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            log "ERROR: required Snappy build command remains unavailable: ${required}"
            return 30
        fi
    done
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

read_source_version() {
    sed -n \
        's/^project(Snappy VERSION \([^ )][^ )]*\).*$/\1/p' \
        "${SOURCE_DIR}/CMakeLists.txt" | head -n 1
}

build_snappy() {
    local actual_version
    initialize_runtime || return $?
    check_architecture || return $?
    require_commands || return $?
    [[ ! -e "${SOURCE_DIR}" && ! -e "${BUILD_DIR}" ]] || {
        log "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    }

    export GIT_TERMINAL_PROMPT=0
    log "cloning Snappy ${SOFTWARE_VERSION} from ${SNAPPY_SOURCE_URL}"
    git clone --branch "${SOFTWARE_VERSION}" --depth 1 \
        "${SNAPPY_SOURCE_URL}" "${SOURCE_DIR}" || {
        log "ERROR: failed to clone Snappy ${SOFTWARE_VERSION}"
        return 30
    }
    log "building Snappy with the commands documented in the official README"
    (
        cd "${SOURCE_DIR}"
        git submodule update --init
        mkdir build
        cd build
        cmake -DCMAKE_BUILD_TYPE=Release ../
        make
    ) || {
        log "ERROR: failed to build Snappy with the official README commands"
        return 40
    }
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log "ERROR: official snappy_benchmark executable was not created"
        return 40
    }

    actual_version="$(read_source_version)"
    [[ -n "${actual_version}" ]] || {
        log "ERROR: cannot read the built Snappy version"
        return 40
    }
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log "ERROR: built Snappy ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 40
    }
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40
}

start_snappy_runtime() {
    initialize_runtime || return $?
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log "ERROR: official snappy_benchmark executable is unavailable"
        return 40
    }
    [[ -d "${SOURCE_DIR}/testdata" ]] || {
        log "ERROR: official Snappy testdata directory is unavailable"
        return 40
    }
    log "Snappy official benchmark runtime is ready"
}

run_snappy_benchmarks() {
    initialize_runtime || return $?
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log "ERROR: official snappy_benchmark executable is unavailable"
        return 40
    }
    export SOFTWARE_VERSION EXPECTED_ARCH
    python3 "${SCRIPT_DIR}/scripts/run_benchmark.py" \
        "${SOURCE_DIR}" \
        "${RESULTS_DIR}/benchmark_google.txt" \
        "${RESULTS_DIR}/benchmark_snappy.json" || return 50
}

stop_snappy_runtime() {
    log "Snappy benchmark has no background service to stop"
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
    [[ "${PERF_WORK_DIR}" == /tmp/snappy-perf/local-* && \
       "${PERF_WORK_DIR}" != "/tmp/snappy-perf" ]] || {
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
        stop_snappy_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_snappy_standalone() {
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
        if build_snappy; then
            if standalone_runtime build-info \
                "${RESULTS_DIR}/build_info.json" \
                "${SOFTWARE_VERSION}" \
                "${PERF_ACTUAL_VERSION_FILE}" \
                "$(normalize_arch "${EXPECTED_ARCH}")" \
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
        if start_snappy_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_snappy_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_snappy_runtime; then
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

Build and run Snappy's official benchmark as a standalone performance evaluation.
Results default to results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       Snappy version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR, SNAPPY_SOURCE_URL
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
    run_snappy_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
