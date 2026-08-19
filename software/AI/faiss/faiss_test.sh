#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.14.3}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
FAISS_SOURCE_URL="${FAISS_SOURCE_URL:-https://github.com/facebookresearch/faiss.git}"
DATA_SCALE="${DATA_SCALE:-100K}"
DATA_DIM="${DATA_DIM:-128}"
ITERATIONS="${ITERATIONS:-1}"
K="${K:-10}"
readonly NUMPY_VERSION="2.4.6"
readonly SETUPTOOLS_VERSION="80.9.0"

SOURCE_DIR=""
BUILD_DIR=""
PYTHON_DEPENDENCY_DIR=""
FAISS_PYTHON_BUILD_ROOT=""
FAISS_PYTHON_PACKAGE_DIR=""
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0


log_message() {
    printf '[faiss] %s\n' "$*"
}


normalize_architecture() {
    local architecture
    architecture="${1,,}"
    case "${architecture}" in
        x86_64|amd64)
            printf 'x86_64\n'
            ;;
        aarch64|arm64)
            printf 'aarch64\n'
            ;;
        *)
            printf '%s\n' "${architecture}"
            ;;
    esac
}


configure_runtime_paths() {
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/tmp/faiss-perf/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
        TMPDIR="${PERF_WORK_DIR}/tmp"
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi

    SOURCE_DIR="${PERF_WORK_DIR}/faiss-source"
    BUILD_DIR="${PERF_WORK_DIR}/faiss-build"
    PYTHON_DEPENDENCY_DIR="${PERF_WORK_DIR}/python-dependencies"
    FAISS_PYTHON_BUILD_ROOT="${BUILD_DIR}/faiss/python/build"

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR DATA_SCALE DATA_DIM ITERATIONS K
}


initialize_runtime() {
    if configure_runtime_paths; then
        :
    else
        return $?
    fi
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" \
        "${TMPDIR:-${PERF_WORK_DIR}/tmp}"
}


require_build_commands() {
    local required_command
    local missing_command=0
    for required_command in git python3 cmake make c++ swig find nproc sed tee; do
        if ! command -v "${required_command}" >/dev/null 2>&1; then
            log_message "ERROR: required command is missing: ${required_command}"
            missing_command=1
        fi
    done
    if ! python3 -m pip --version >/dev/null 2>&1; then
        log_message "ERROR: python3 pip module is unavailable"
        missing_command=1
    fi
    if [[ "${missing_command}" -ne 0 ]]; then
        return 20
    fi
}


check_architecture() {
    local actual_architecture
    local expected_architecture
    actual_architecture="$(normalize_architecture "$(uname -m)")"
    expected_architecture="$(normalize_architecture "${EXPECTED_ARCH}")"
    if [[ "${actual_architecture}" != "${expected_architecture}" ]]; then
        log_message "ERROR: expected ${expected_architecture}, runner is ${actual_architecture}"
        return 20
    fi
}


operating_system_id() {
    local os_id
    os_id="$(sed -n 's/^ID=//p' /etc/os-release 2>/dev/null | head -n 1)"
    os_id="${os_id%\"}"
    os_id="${os_id#\"}"
    printf '%s\n' "${os_id,,}"
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
    os_id="$(operating_system_id)"
    if [[ "${os_id}" != "ubuntu" ]]; then
        pip_options+=(--index-url https://mirrors.aliyun.com/pypi/simple/)
    fi
    log_message "installing private Python build dependencies"
    if ! python3 -m pip install "${pip_options[@]}" \
        "numpy==${NUMPY_VERSION}" \
        "setuptools==${SETUPTOOLS_VERSION}"; then
        log_message "ERROR: failed to install private Python build dependencies"
        return 30
    fi
    PYTHONPATH="${PYTHON_DEPENDENCY_DIR}${PYTHONPATH:+:${PYTHONPATH}}"
    export PYTHONPATH
}


activate_faiss_python_runtime() {
    FAISS_PYTHON_PACKAGE_DIR="$(
        find "${FAISS_PYTHON_BUILD_ROOT}" \
            -mindepth 1 -maxdepth 1 -type d -name 'lib*' -print -quit \
            2>/dev/null
    )"
    if [[ -z "${FAISS_PYTHON_PACKAGE_DIR}" ]]; then
        log_message "ERROR: built Faiss Python package directory is unavailable"
        return 40
    fi
    PYTHONPATH="${FAISS_PYTHON_PACKAGE_DIR}:${PYTHON_DEPENDENCY_DIR}"
    export PYTHONPATH
    if ! python3 -c 'import faiss, numpy; print(f"Faiss {faiss.__version__}, NumPy {numpy.__version__}")'; then
        log_message "ERROR: built Faiss Python module cannot be imported"
        return 40
    fi
}


build_faiss() {
    local source_tag
    local actual_version
    local parallel_jobs
    local python_executable

    if initialize_runtime; then
        :
    else
        return $?
    fi
    if check_architecture; then
        :
    else
        return $?
    fi
    if require_build_commands; then
        :
    else
        return $?
    fi
    if [[ -e "${SOURCE_DIR}" || -e "${BUILD_DIR}" || \
          -e "${PYTHON_DEPENDENCY_DIR}" ]]; then
        log_message "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    fi

    if install_python_build_dependencies; then
        :
    else
        return $?
    fi
    source_tag="${SOFTWARE_VERSION}"
    if [[ "${source_tag}" != v* ]]; then
        source_tag="v${source_tag}"
    fi
    export GIT_TERMINAL_PROMPT=0
    log_message "cloning Faiss ${source_tag} from ${FAISS_SOURCE_URL}"
    if ! git clone --branch "${source_tag}" --depth 1 \
        "${FAISS_SOURCE_URL}" "${SOURCE_DIR}"; then
        log_message "ERROR: failed to clone Faiss ${source_tag}"
        return 30
    fi

    python_executable="$(command -v python3)"
    log_message "configuring CPU-only Release build with Python bindings"
    if ! cmake -B "${BUILD_DIR}" -S "${SOURCE_DIR}" \
        -DFAISS_ENABLE_GPU=OFF \
        -DFAISS_ENABLE_PYTHON=ON \
        -DBUILD_TESTING=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DPython_EXECUTABLE="${python_executable}"; then
        log_message "ERROR: Faiss CMake configuration failed"
        return 40
    fi

    parallel_jobs="$(nproc)"
    log_message "building official faiss and swigfaiss targets"
    if ! make -C "${BUILD_DIR}" -j"${parallel_jobs}" faiss; then
        log_message "ERROR: Faiss C++ library build failed"
        return 40
    fi
    if ! make -C "${BUILD_DIR}" -j"${parallel_jobs}" swigfaiss; then
        log_message "ERROR: Faiss Python binding build failed"
        return 40
    fi
    if ! (
        cd "${BUILD_DIR}/faiss/python"
        python3 setup.py build
    ); then
        log_message "ERROR: Faiss Python package build failed"
        return 40
    fi

    if activate_faiss_python_runtime; then
        :
    else
        return $?
    fi
    actual_version="$(python3 -c 'import faiss; print(faiss.__version__)')"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: built Faiss ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    if ! printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"; then
        log_message "ERROR: failed to record built Faiss version"
        return 40
    fi
}


start_faiss_runtime() {
    if initialize_runtime; then
        :
    else
        return $?
    fi
    if activate_faiss_python_runtime; then
        :
    else
        return $?
    fi
    if ! python3 -c '
import faiss
import numpy as np

vectors = np.zeros((8, 4), dtype="float32")
index = faiss.IndexFlatL2(4)
index.add(vectors)
distances, neighbors = index.search(vectors[:1], 1)
assert neighbors.shape == (1, 1)
'; then
        log_message "ERROR: Faiss IndexFlatL2 runtime validation failed"
        return 40
    fi
    log_message "Faiss CPU Python runtime is ready"
}


run_faiss_benchmarks() {
    if initialize_runtime; then
        :
    else
        return $?
    fi
    if activate_faiss_python_runtime; then
        :
    else
        return $?
    fi
    if ! python3 "${SCRIPT_DIR}/scripts/benchmark_ann.py"; then
        log_message "ERROR: Faiss ANN benchmark failed"
        return 50
    fi
    if ! python3 "${SCRIPT_DIR}/scripts/benchmark_micro.py"; then
        log_message "ERROR: Faiss micro benchmark failed"
        return 50
    fi
}


stop_faiss_runtime() {
    log_message "Faiss CPU benchmark has no background service to stop"
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
    if [[ "${PERF_WORK_DIR}" != /tmp/faiss-perf/local-* || \
          "${PERF_WORK_DIR}" == "/tmp/faiss-perf" ]]; then
        log_message "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    fi
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        if ! rm -rf -- "${PERF_WORK_DIR}"; then
            log_message "ERROR: failed to clean standalone work directory"
            return 70
        fi
    fi
    log_message "cleaned standalone work directory: ${PERF_WORK_DIR}"
}


emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then
        stop_faiss_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}


run_faiss_standalone() {
    local stage_status=0
    local failed_stage=""
    local cleanup_status="passed"
    local command_status="passed"
    local finalize_status=0

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

    if standalone_runtime system "${RESULTS_DIR}/system_info.json"; then
        if standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json"; then
            :
        else
            stage_status=$?
            failed_stage="prepare"
        fi
    else
        stage_status=$?
        failed_stage="prepare"
    fi

    if [[ "${stage_status}" -eq 0 ]]; then
        if build_faiss; then
            if standalone_runtime build-info \
                "${RESULTS_DIR}/build_info.json" \
                "${SOFTWARE_VERSION}" \
                "${PERF_ACTUAL_VERSION_FILE}" \
                "$(normalize_architecture "${EXPECTED_ARCH}")" \
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
        if start_faiss_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_faiss_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_faiss_runtime; then
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

Build Faiss CPU from source, run ANN and API benchmarks, collect environment
information, validate results, generate a report, and clean the private work area.

Options:
  --version VERSION       Faiss version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR, FAISS_SOURCE_URL,
  DATA_SCALE, DATA_DIM, ITERATIONS, K
USAGE
}


main() {
    local pipeline_status
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version)
                if [[ "$#" -lt 2 ]]; then
                    log_message "ERROR: --version requires a value"
                    return 10
                fi
                SOFTWARE_VERSION="$2"
                shift 2
                ;;
            --results-dir)
                if [[ "$#" -lt 2 ]]; then
                    log_message "ERROR: --results-dir requires a value"
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
                log_message "ERROR: unsupported option: $1"
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
    mkdir -p "${RESULTS_DIR}"
    : > "${RESULTS_DIR}/results.log"
    pipeline_status=0
    set +e
    run_faiss_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log_message "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}


if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
