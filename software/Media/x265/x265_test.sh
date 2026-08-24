#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-4.2}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
# x265's canonical upstream is the MulticoreWare Bitbucket repository, which is
# the only source carrying the official 4.1/4.2 release tags (the github.com
# videolan/x265 mirror is stale and stops at 3.4). The branch/tag overridden via
# X265_SOURCE_URL must expose the version tags declared in case.yaml.
X265_SOURCE_URL="${X265_SOURCE_URL:-https://bitbucket.org/multicoreware/x265_git.git}"
YUV_WIDTH="${YUV_WIDTH:-1280}"
YUV_HEIGHT="${YUV_HEIGHT:-720}"
YUV_FRAMES="${YUV_FRAMES:-50}"
ITERATIONS="${ITERATIONS:-1}"
X265_VERSION_STRING=""
SOURCE_DIR=""
BUILD_DIR=""
BENCHMARK_BIN=""
YUV_FILE=""
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

log() { printf '[x265] %s\n' "$*"; }

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
        PERF_WORK_DIR="/tmp/x265-perf/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
        TMPDIR="${PERF_WORK_DIR}/tmp"
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/x265-source"
    BUILD_DIR="${PERF_WORK_DIR}/x265-build"
    BENCHMARK_BIN="${BUILD_DIR}/x265"
    YUV_FILE="${PERF_WORK_DIR}/test_${YUV_WIDTH}x${YUV_HEIGHT}.yuv"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
}

initialize_runtime() {
    configure_runtime_paths
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR:-${PERF_WORK_DIR}/tmp}"
}

require_commands() {
    local required missing=0
    for required in git python3 make cmake gcc g++ sed tee; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            log "ERROR: required command is missing: ${required}"
            missing=1
        fi
    done
    if [[ "$(normalize_arch "${EXPECTED_ARCH}")" == "x86_64" ]] && ! command -v nasm >/dev/null 2>&1; then
        log "ERROR: nasm is required to build x265 on x86_64"
        missing=1
    fi
    [[ "${missing}" -eq 0 ]]
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

read_x265_version() {
    if [[ -x "${BENCHMARK_BIN}" ]]; then
        "${BENCHMARK_BIN}" --version 2>&1 | head -n 1
    else
        printf ''
    fi
}

build_x265() {
    local actual_version
    initialize_runtime || return $?
    check_architecture || return $?
    require_commands || return $?
    [[ ! -e "${SOURCE_DIR}" && ! -e "${BUILD_DIR}" ]] || {
        log "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    }

    export GIT_TERMINAL_PROMPT=0
    log "cloning x265 ${SOFTWARE_VERSION} from ${X265_SOURCE_URL}"
    if ! git clone --branch "${SOFTWARE_VERSION}" --depth 1 \
        "${X265_SOURCE_URL}" "${SOURCE_DIR}"; then
        log "WARN: shallow clone failed, trying full clone + checkout"
        if ! git clone "${X265_SOURCE_URL}" "${SOURCE_DIR}"; then
            log "ERROR: failed to clone x265 ${SOFTWARE_VERSION}"
            return 30
        fi
        (cd "${SOURCE_DIR}" && git checkout "${SOFTWARE_VERSION}") || {
            log "ERROR: failed to checkout x265 ${SOFTWARE_VERSION}"
            return 30
        }
    fi

    log "building x265 with official cmake + make"
    mkdir -p "${BUILD_DIR}"
    (
        cd "${BUILD_DIR}"
        cmake -DCMAKE_BUILD_TYPE=Release \
            -DENABLE_CLI=ON \
            -DENABLE_SHARED=OFF \
            -DENABLE_HDR=OFF \
            "${SOURCE_DIR}/source" || {
            log "ERROR: x265 cmake configure failed"
            exit 40
        }
        make -j"$(nproc)" || {
            log "ERROR: x265 make failed"
            exit 40
        }
    ) || return $?

    [[ -x "${BENCHMARK_BIN}" ]] || {
        log "ERROR: official x265 binary was not created"
        return 40
    }

    actual_version="$(read_x265_version)"
    [[ -n "${actual_version}" ]] || {
        log "ERROR: cannot read the built x265 version"
        return 40
    }
    [[ "${actual_version}" == *"${SOFTWARE_VERSION}"* ]] || {
        log "ERROR: built x265 version does not match ${SOFTWARE_VERSION}: ${actual_version}"
        return 40
    }
    X265_VERSION_STRING="${actual_version}"
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40

    log "generating test YUV (${YUV_WIDTH}x${YUV_HEIGHT}, ${YUV_FRAMES} frames)"
    python3 "${SCRIPT_DIR}/scripts/gen_yuv.py" \
        "${YUV_WIDTH}" "${YUV_HEIGHT}" "${YUV_FRAMES}" "${YUV_FILE}" || return 40
    [[ -s "${YUV_FILE}" ]] || {
        log "ERROR: test YUV generation failed"
        return 40
    }
    log "x265 ${actual_version} official benchmark binary is ready"
}

start_x265_runtime() {
    initialize_runtime || return $?
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log "ERROR: official x265 binary is unavailable"
        return 40
    }
    "${BENCHMARK_BIN}" --version >/dev/null 2>&1 || {
        log "ERROR: x265 binary is not runnable"
        return 40
    }
    [[ -f "${YUV_FILE}" ]] || {
        log "ERROR: test YUV is unavailable"
        return 40
    }
    log "x265 official benchmark runtime is ready"
}

run_x265_benchmarks() {
    initialize_runtime || return $?
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log "ERROR: official x265 binary is unavailable"
        return 40
    }
    [[ -f "${YUV_FILE}" ]] || {
        log "ERROR: test YUV is unavailable"
        return 40
    }
    export SOFTWARE_VERSION EXPECTED_ARCH X265_VERSION_STRING
    python3 "${SCRIPT_DIR}/scripts/run_benchmark.py" \
        "${BENCHMARK_BIN}" "${YUV_FILE}" "${YUV_WIDTH}" "${YUV_HEIGHT}" "${YUV_FRAMES}" \
        "${RESULTS_DIR}/benchmark_encode.txt" \
        "${RESULTS_DIR}/benchmark_x265.json" \
        "${ITERATIONS}" || return 50
}

stop_x265_runtime() {
    log "x265 benchmark has no background service to stop"
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
    [[ "${PERF_WORK_DIR}" == /tmp/x265-perf/local-* && \
       "${PERF_WORK_DIR}" != "/tmp/x265-perf" ]] || {
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
        stop_x265_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_x265_standalone() {
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
        if build_x265; then
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
        if start_x265_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_x265_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_x265_runtime; then
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

Build and run x265's official H.265/HEVC encode benchmark as a standalone
performance evaluation. Results default to results/<version>/<run-id>/ inside
this directory.

Options:
  --version VERSION       x265 version tag (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR, X265_SOURCE_URL,
  YUV_WIDTH, YUV_HEIGHT, YUV_FRAMES, ITERATIONS
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
    run_x265_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi