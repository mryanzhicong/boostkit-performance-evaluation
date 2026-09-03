#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-0.8.0}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
HNSWLIB_SOURCE_URL="${HNSWLIB_SOURCE_URL:-https://github.com/nmslib/hnswlib.git}"
HNSWLIB_DATA_ROOT="${HNSWLIB_DATA_ROOT:-}"
readonly NUMPY_VERSION="2.4.6"
readonly SETUPTOOLS_VERSION="80.9.0"
readonly PYBIND11_VERSION="2.13.6"
readonly WHEEL_VERSION="0.45.1"
readonly H5PY_VERSION="3.16.0"

SOURCE_DIR=""
INSTALL_DIR=""
PYTHON_DEPENDENCY_DIR=""
BENCHMARK_RUN_DIR=""
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0


log() {
    printf '[hnswlib] %s\n' "$*"
}


configure_runtime_paths() {
    local actual_architecture

    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64) EXPECTED_ARCH="x86_64" ;;
        aarch64|arm64) EXPECTED_ARCH="aarch64" ;;
        *)
            log "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    case "$(uname -m)" in
        x86_64|amd64) actual_architecture="x86_64" ;;
        aarch64|arm64) actual_architecture="aarch64" ;;
        *) actual_architecture="$(uname -m)" ;;
    esac
    if [[ "${actual_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log "ERROR: expected ${EXPECTED_ARCH}, runner is ${actual_architecture}"
        return 20
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/hnswlib/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    if [[ -z "${HNSWLIB_DATA_ROOT}" ]]; then
        HNSWLIB_DATA_ROOT="${PERF_WORK_DIR}/data"
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    XDG_CACHE_HOME="${PERF_WORK_DIR}/cache"

    SOURCE_DIR="${PERF_WORK_DIR}/hnswlib-source"
    INSTALL_DIR="${PERF_WORK_DIR}/hnswlib-install"
    PYTHON_DEPENDENCY_DIR="${PERF_WORK_DIR}/python-dependencies"
    BENCHMARK_RUN_DIR="${PERF_WORK_DIR}/ann-benchmark-run"

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR HNSWLIB_DATA_ROOT
    export PERF_ACTUAL_VERSION_FILE TMPDIR XDG_CACHE_HOME
}


initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${XDG_CACHE_HOME}" \
        "${HNSWLIB_DATA_ROOT}" || return $?
}


require_hnswlib_tools() {
    local command_name package
    local packages=()

    for command_name in git g++ sed tee sha256sum python3; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            git) package="git" ;;
            g++) package="gcc-c++" ;;
            sed) package="sed" ;;
            tee|sha256sum) package="coreutils" ;;
            python3) package="python3" ;;
        esac
        log "missing required hnswlib command: ${command_name}"
        packages+=("${package}")
    done
    if ! python3 -m pip --version >/dev/null 2>&1; then
        log "missing required hnswlib Python module: pip"
        packages+=("python3-pip")
    fi
    if ! rpm -q python3-devel >/dev/null 2>&1; then
        log "missing required hnswlib build package: python3-devel"
        packages+=("python3-devel")
    fi
    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log "ERROR: dnf is required to install hnswlib prerequisites"
        return 30
    fi
    log "installing missing hnswlib packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log "ERROR: sudo is required to install hnswlib prerequisites"
        return 30
    elif ! sudo -n dnf install -y "${packages[@]}"; then
        log "ERROR: failed to install hnswlib prerequisites"
        return 30
    fi
    for command_name in git g++ sed tee sha256sum python3; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "ERROR: required hnswlib command remains unavailable: ${command_name}"
            return 30
        fi
    done
    if ! python3 -m pip --version >/dev/null 2>&1 || ! rpm -q python3-devel >/dev/null 2>&1; then
        log "ERROR: required hnswlib Python build dependencies remain unavailable"
        return 30
    fi
}


install_python_build_dependencies() {
    local os_id
    local pip_options
    pip_options=(
        --disable-pip-version-check
        --no-input
        --upgrade
        --only-binary=:all:
        --target "${PYTHON_DEPENDENCY_DIR}"
    )
    os_id="$(sed -n 's/^ID=//p' /etc/os-release 2>/dev/null | head -n 1)"
    os_id="${os_id%\"}"
    os_id="${os_id#\"}"
    if [[ "${os_id}" != "ubuntu" ]]; then
        pip_options+=(
            --trusted-host mirrors.huaweicloud.com
            --index-url https://mirrors.huaweicloud.com/repository/pypi/simple
        )
    fi
    log "installing private Python build dependencies"
    if ! python3 -m pip install "${pip_options[@]}" \
        "numpy==${NUMPY_VERSION}" \
        "setuptools==${SETUPTOOLS_VERSION}" \
        "pybind11==${PYBIND11_VERSION}" \
        "wheel==${WHEEL_VERSION}" \
        "h5py==${H5PY_VERSION}"; then
        log "ERROR: failed to install private Python build dependencies"
        return 30
    fi
    PYTHONPATH="${PYTHON_DEPENDENCY_DIR}${PYTHONPATH:+:${PYTHONPATH}}"
    export PYTHONPATH
}


activate_hnswlib_runtime() {
    PYTHONPATH="${INSTALL_DIR}:${PYTHON_DEPENDENCY_DIR}"
    export PYTHONPATH
    if ! python3 -c 'import hnswlib, numpy'; then
        log "ERROR: built hnswlib Python module cannot be imported"
        return 40
    fi
}


build_hnswlib() {
    local source_tag
    local actual_tag
    local actual_version

    initialize_runtime || return $?
    require_hnswlib_tools || return $?
    if [[ -e "${SOURCE_DIR}" || -e "${INSTALL_DIR}" || \
          -e "${PYTHON_DEPENDENCY_DIR}" ]]; then
        log "ERROR: build directory is not clean under ${PERF_WORK_DIR}"
        return 20
    fi

    install_python_build_dependencies || return $?
    source_tag="${SOFTWARE_VERSION}"
    if [[ "${source_tag}" != v* ]]; then
        source_tag="v${source_tag}"
    fi
    export GIT_TERMINAL_PROMPT=0
    log "cloning hnswlib ${source_tag} from ${HNSWLIB_SOURCE_URL}"
    if ! git clone --branch "${source_tag}" --depth 1 \
        "${HNSWLIB_SOURCE_URL}" "${SOURCE_DIR}"; then
        log "ERROR: failed to clone hnswlib ${source_tag}"
        return 30
    fi
    actual_tag="$(git -C "${SOURCE_DIR}" describe --tags --exact-match HEAD)" || {
        log "ERROR: cloned source is not at an exact version tag"
        return 30
    }
    if [[ "${actual_tag}" != "${source_tag}" ]]; then
        log "ERROR: cloned source tag ${actual_tag}, expected ${source_tag}"
        return 30
    fi
    log "building and installing hnswlib ${source_tag} in the private work area"
    if ! PYTHONPATH="${PYTHON_DEPENDENCY_DIR}" python3 -m pip install \
        --disable-pip-version-check \
        --no-input \
        --no-cache-dir \
        --no-build-isolation \
        --no-deps \
        --target "${INSTALL_DIR}" \
        "${SOURCE_DIR}"; then
        log "ERROR: hnswlib source build failed"
        return 40
    fi
    activate_hnswlib_runtime || return $?
    actual_version="$(PYTHONPATH="${INSTALL_DIR}:${PYTHON_DEPENDENCY_DIR}" python3 -c '
import importlib.metadata
print(importlib.metadata.version("hnswlib"))
')" || return 40
    if [[ -z "${actual_version}" ]]; then
        log "ERROR: cannot read the built hnswlib version"
        return 40
    fi
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: built hnswlib reports ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    if ! printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"; then
        log "ERROR: failed to record built hnswlib version"
        return 40
    fi
    log "hnswlib ${actual_version} is ready for ANN-Benchmarks datasets"
}


start_hnswlib_runtime() {
    initialize_runtime || return $?
    activate_hnswlib_runtime || return $?
    if ! mkdir -p "${BENCHMARK_RUN_DIR}"; then
        log "ERROR: failed to create private ANN benchmark run directory"
        return 40
    fi
    log "hnswlib ANN-Benchmarks runtime is ready"
}


run_hnswlib_benchmarks() {
    local actual_version
    local benchmark_status

    initialize_runtime || return $?
    activate_hnswlib_runtime || return $?
    if [[ ! -f "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        log "ERROR: actual version file is missing"
        return 50
    fi
    actual_version="$(sed -n '1p' "${PERF_ACTUAL_VERSION_FILE}")" || return 50
    if [[ -e "${RESULTS_DIR}/benchmark_hnswlib.json" ]]; then
        log "ERROR: hnswlib benchmark result already exists"
        return 50
    fi

    log "running hnswlib on five ANN-Benchmarks datasets"
    if PYTHONPATH="${INSTALL_DIR}:${PYTHON_DEPENDENCY_DIR}" python3 \
        "${SCRIPT_DIR}/scripts/run_ann_benchmark.py" \
        --data-root "${HNSWLIB_DATA_ROOT}" \
        --output "${RESULTS_DIR}/benchmark_hnswlib.json" \
        --raw-output "${RESULTS_DIR}/hnswlib_ann_raw.log" \
        --version "${actual_version}" \
        --architecture "${EXPECTED_ARCH}"; then
        :
    else
        benchmark_status=$?
        log "ERROR: hnswlib ANN-Benchmarks test failed with status ${benchmark_status}"
        return "${benchmark_status}"
    fi
    log "hnswlib benchmark results written to benchmark_hnswlib.json"
}


stop_hnswlib_runtime() {
    log "hnswlib benchmark has no background service to stop"
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
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/hnswlib/local-* || \
          "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/hnswlib" ]]; then
        log "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    fi
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        if ! rm -rf -- "${PERF_WORK_DIR}"; then
            log "ERROR: failed to clean standalone work directory"
            return 70
        fi
    fi
    log "cleaned standalone work directory: ${PERF_WORK_DIR}"
}


emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then
        stop_hnswlib_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}


run_hnswlib_standalone() {
    local stage_status=0
    local failed_stage=""
    local cleanup_status="passed"
    local command_status="passed"
    local finalize_status=0

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
        if build_hnswlib; then
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
        if start_hnswlib_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_hnswlib_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_hnswlib_runtime; then
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
        :
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

Build hnswlib from the official source, run the five-dataset ANN-Benchmarks
workload, collect environment information, validate results, generate a
report, and clean the private work area.

Options:
  --version VERSION       hnswlib version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR,
  HNSWLIB_SOURCE_URL, HNSWLIB_DATA_ROOT
USAGE
}


main() {
    local pipeline_status
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
    mkdir -p "${RESULTS_DIR}"
    : > "${RESULTS_DIR}/results.log"
    pipeline_status=0
    set +e
    run_hnswlib_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}


if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
