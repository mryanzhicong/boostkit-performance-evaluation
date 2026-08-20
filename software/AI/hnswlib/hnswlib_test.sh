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
readonly NUMPY_VERSION="2.4.6"
readonly SETUPTOOLS_VERSION="80.9.0"
readonly PYBIND11_VERSION="2.13.6"
readonly WHEEL_VERSION="0.45.1"
readonly OFFICIAL_SPEEDTEST_SHA256="18f03fca047d2e649adacbcc7b030b5e55d465a920a7a949e8114d23ec26b20b"
readonly SPEEDTEST_DIMENSION=128
readonly SPEEDTEST_SEARCH_THREADS=1
readonly SPEEDTEST_NAME="hnswlib"

# Official tests/python/speedtest.py workload for v0.7.0, v0.8.0 and v0.9.0:
# 400,000 deterministic float32 vectors x 128 dimensions (~195 MiB), HNSW
# M=16, ef_construction=60, construction_threads=64, search_ef=15, three
# searches over 5,000 vectors using one search thread. The script is identical
# in all declared versions and is executed without modification.

SOURCE_DIR=""
INSTALL_DIR=""
PYTHON_DEPENDENCY_DIR=""
BENCHMARK_RUN_DIR=""
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0


log_message() {
    printf '[hnswlib] %s\n' "$*"
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
    EXPECTED_ARCH="$(normalize_architecture "${EXPECTED_ARCH}")"
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/tmp/hnswlib-perf/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
        TMPDIR="${PERF_WORK_DIR}/tmp"
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    if [[ -z "${XDG_CACHE_HOME}" ]]; then
        XDG_CACHE_HOME="${PERF_WORK_DIR}/cache"
    fi

    SOURCE_DIR="${PERF_WORK_DIR}/hnswlib-source"
    INSTALL_DIR="${PERF_WORK_DIR}/hnswlib-install"
    PYTHON_DEPENDENCY_DIR="${PERF_WORK_DIR}/python-dependencies"
    BENCHMARK_RUN_DIR="${PERF_WORK_DIR}/speedtest-run"

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR XDG_CACHE_HOME
}


initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR:-${PERF_WORK_DIR}/tmp}" || return $?
}


require_build_commands() {
    local required_command
    local missing_command=0
    for required_command in git g++ cc nproc sed tee sha256sum python3; do
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
        pip_options+=(
            --trusted-host mirrors.huaweicloud.com
            --index-url https://mirrors.huaweicloud.com/repository/pypi/simple
        )
    fi
    log_message "installing private Python build dependencies"
    if ! python3 -m pip install "${pip_options[@]}" \
        "numpy==${NUMPY_VERSION}" \
        "setuptools==${SETUPTOOLS_VERSION}" \
        "pybind11==${PYBIND11_VERSION}" \
        "wheel==${WHEEL_VERSION}"; then
        log_message "ERROR: failed to install private Python build dependencies"
        return 30
    fi
    PYTHONPATH="${PYTHON_DEPENDENCY_DIR}${PYTHONPATH:+:${PYTHONPATH}}"
    export PYTHONPATH
}


activate_hnswlib_runtime() {
    PYTHONPATH="${INSTALL_DIR}:${PYTHON_DEPENDENCY_DIR}"
    export PYTHONPATH
    if ! python3 -c 'import hnswlib, numpy'; then
        log_message "ERROR: built hnswlib Python module cannot be imported"
        return 40
    fi
}


installed_hnswlib_version() {
    PYTHONPATH="${INSTALL_DIR}:${PYTHON_DEPENDENCY_DIR}" python3 -c '
import importlib.metadata
print(importlib.metadata.version("hnswlib"))
'
}


verify_official_speedtest() {
    local speedtest_path
    local actual_sha256
    speedtest_path="${SOURCE_DIR}/tests/python/speedtest.py"
    if [[ ! -f "${speedtest_path}" ]]; then
        log_message "ERROR: official tests/python/speedtest.py is missing"
        return 40
    fi
    actual_sha256="$(sha256sum "${speedtest_path}" | sed -n 's/ .*//p')" || return 40
    if [[ "${actual_sha256}" != "${OFFICIAL_SPEEDTEST_SHA256}" ]]; then
        log_message "ERROR: unexpected official speedtest.py SHA256: ${actual_sha256}"
        return 40
    fi
}


build_hnswlib() {
    local source_tag
    local actual_tag
    local actual_version

    if ! initialize_runtime; then
        log_message "ERROR: failed to initialize runtime paths"
        return 20
    fi
    check_architecture || return $?
    require_build_commands || return $?
    if [[ -e "${SOURCE_DIR}" || -e "${INSTALL_DIR}" || \
          -e "${PYTHON_DEPENDENCY_DIR}" ]]; then
        log_message "ERROR: build directory is not clean under ${PERF_WORK_DIR}"
        return 20
    fi

    install_python_build_dependencies || return $?
    source_tag="${SOFTWARE_VERSION}"
    if [[ "${source_tag}" != v* ]]; then
        source_tag="v${source_tag}"
    fi
    export GIT_TERMINAL_PROMPT=0
    log_message "cloning hnswlib ${source_tag} from ${HNSWLIB_SOURCE_URL}"
    if ! git clone --branch "${source_tag}" --depth 1 \
        "${HNSWLIB_SOURCE_URL}" "${SOURCE_DIR}"; then
        log_message "ERROR: failed to clone hnswlib ${source_tag}"
        return 30
    fi
    actual_tag="$(git -C "${SOURCE_DIR}" describe --tags --exact-match HEAD)" || {
        log_message "ERROR: cloned source is not at an exact version tag"
        return 30
    }
    if [[ "${actual_tag}" != "${source_tag}" ]]; then
        log_message "ERROR: cloned source tag ${actual_tag}, expected ${source_tag}"
        return 30
    fi
    verify_official_speedtest || return $?

    log_message "building and installing hnswlib ${source_tag} in the private work area"
    if ! PYTHONPATH="${PYTHON_DEPENDENCY_DIR}" python3 -m pip install \
        --disable-pip-version-check \
        --no-input \
        --no-cache-dir \
        --no-build-isolation \
        --no-deps \
        --target "${INSTALL_DIR}" \
        "${SOURCE_DIR}"; then
        log_message "ERROR: hnswlib source build failed"
        return 40
    fi
    activate_hnswlib_runtime || return $?
    actual_version="$(installed_hnswlib_version)" || return 40
    if [[ -z "${actual_version}" ]]; then
        log_message "ERROR: cannot read the built hnswlib version"
        return 40
    fi
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: built hnswlib reports ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    if ! printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"; then
        log_message "ERROR: failed to record built hnswlib version"
        return 40
    fi
    log_message "hnswlib ${actual_version} and official speedtest.py are ready"
}


start_hnswlib_runtime() {
    if ! initialize_runtime; then
        log_message "ERROR: failed to initialize runtime paths"
        return 20
    fi
    activate_hnswlib_runtime || return $?
    verify_official_speedtest || return $?
    if ! mkdir -p "${BENCHMARK_RUN_DIR}"; then
        log_message "ERROR: failed to create private speedtest run directory"
        return 40
    fi
    log_message "official hnswlib speedtest runtime is ready"
}


run_hnswlib_benchmarks() {
    local actual_version
    local benchmark_status

    if ! initialize_runtime; then
        log_message "ERROR: failed to initialize runtime paths"
        return 20
    fi
    activate_hnswlib_runtime || return $?
    verify_official_speedtest || return $?
    if [[ ! -f "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        log_message "ERROR: actual version file is missing"
        return 50
    fi
    actual_version="$(sed -n '1p' "${PERF_ACTUAL_VERSION_FILE}")" || return 50
    if [[ -e "${BENCHMARK_RUN_DIR}/log2_128_t1.txt" ]]; then
        log_message "ERROR: official speedtest result log already exists"
        return 50
    fi

    log_message "running unchanged official tests/python/speedtest.py"
    if ( cd "${BENCHMARK_RUN_DIR}" && \
        python3 "${SOURCE_DIR}/tests/python/speedtest.py" \
            -d "${SPEEDTEST_DIMENSION}" \
            -n "${SPEEDTEST_NAME}" \
            -t "${SPEEDTEST_SEARCH_THREADS}" ) \
        | tee "${RESULTS_DIR}/speedtest_stdout.log"; then
        :
    else
        benchmark_status=$?
        log_message "ERROR: official speedtest.py failed with status ${benchmark_status}"
        return "${benchmark_status}"
    fi
    if ! cp "${BENCHMARK_RUN_DIR}/log2_128_t1.txt" \
        "${RESULTS_DIR}/log2_128_t1.txt"; then
        log_message "ERROR: official speedtest result log was not created"
        return 50
    fi

    if ! python3 "${SCRIPT_DIR}/scripts/parse_speedtest_output.py" \
        --raw-output "${RESULTS_DIR}/speedtest_stdout.log" \
        --output "${RESULTS_DIR}/benchmark_speedtest.json" \
        --version "${actual_version}" \
        --architecture "$(normalize_architecture "${EXPECTED_ARCH}")"; then
        log_message "ERROR: failed to parse official speedtest output"
        return 50
    fi
    log_message "hnswlib benchmark results written to benchmark_speedtest.json"
}


stop_hnswlib_runtime() {
    log_message "hnswlib benchmark has no background service to stop"
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
    if [[ "${PERF_WORK_DIR}" != /tmp/hnswlib-perf/local-* || \
          "${PERF_WORK_DIR}" == "/tmp/hnswlib-perf" ]]; then
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

Build hnswlib from the official source, run the unchanged official
tests/python/speedtest.py benchmark, collect environment information, validate
results, generate a report, and clean the private work area.

Options:
  --version VERSION       hnswlib version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR,
  HNSWLIB_SOURCE_URL
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

    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}"
    : > "${RESULTS_DIR}/results.log"
    pipeline_status=0
    set +e
    run_hnswlib_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log_message "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}


if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
