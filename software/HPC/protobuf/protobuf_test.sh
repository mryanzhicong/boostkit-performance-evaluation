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
PROTOBUF_PYTHON_VERSION="${PROTOBUF_PYTHON_VERSION:-7.35.1}"
NUM_MESSAGES="${NUM_MESSAGES:-200000}"
ITERATIONS="${ITERATIONS:-5}"
MESSAGE_SIZE="${MESSAGE_SIZE:-100}"
THREAD_COUNTS="${THREAD_COUNTS:-1,2,4,8}"

SOURCE_DIR=""
BUILD_DIR=""
INSTALL_DIR=""
PROTOC_BIN=""
CXX_BINARY="${CXX:-g++}"
CXX_VERSION=""
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

log_message() {
    printf '[protobuf] %s\n' "$*"
}

normalized_architecture() {
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
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/tmp/protobuf-perf/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/protobuf-source"
    BUILD_DIR="${PERF_WORK_DIR}/build"
    INSTALL_DIR="${PERF_WORK_DIR}/install"
    PROTOC_BIN="${INSTALL_DIR}/bin/protoc"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${PERF_WORK_DIR}/tmp"
    export TMPDIR="${PERF_WORK_DIR}/tmp"
}

require_build_commands() {
    local required_command missing=0
    for required_command in git cmake make nproc python3 "${CXX_BINARY}"; do
        if ! command -v "${required_command}" >/dev/null 2>&1; then
            log_message "ERROR: required command is missing: ${required_command}"
            missing=1
        fi
    done
    [[ "${missing}" -eq 0 ]]
}

check_architecture() {
    local actual_architecture expected_architecture
    actual_architecture="$(normalized_architecture "$(uname -m)")"
    expected_architecture="$(normalized_architecture "${EXPECTED_ARCH}")"
    if [[ "${actual_architecture}" != "${expected_architecture}" ]]; then
        log_message "ERROR: expected architecture ${expected_architecture}, runner is ${actual_architecture}"
        return 20
    fi
}

pip_index_options() {
    local operating_system_id
    operating_system_id="$(sed -n 's/^ID=//p' /etc/os-release 2>/dev/null | head -n 1)"
    operating_system_id="${operating_system_id%\"}"
    operating_system_id="${operating_system_id#\"}"
    if [[ "${operating_system_id,,}" != "ubuntu" ]]; then
        printf '%s\n' '--trusted-host' 'mirrors.huaweicloud.com' \
            '--index-url' 'https://mirrors.huaweicloud.com/repository/pypi/simple'
    fi
}

install_private_python_runtime() {
    local -a pip_options=()
    while IFS= read -r option; do
        pip_options+=("${option}")
    done < <(pip_index_options)
    log_message "installing Python runtime into the task-private virtual environment"
    if ! python3 -m pip install --disable-pip-version-check --no-input --no-cache-dir \
        "${pip_options[@]}" "protobuf==${PROTOBUF_PYTHON_VERSION}"; then
        log_message "ERROR: failed to install the Python dependency required by the upstream benchmarks"
        return 30
    fi
    if ! python3 -c "import google.protobuf; assert google.protobuf.__version__ == '${PROTOBUF_PYTHON_VERSION}', google.protobuf.__version__; print(google.protobuf.__version__)"; then
        log_message "ERROR: task-private protobuf Python runtime version is not ${PROTOBUF_PYTHON_VERSION}"
        return 40
    fi
}

clone_protobuf_source() {
    if [[ -e "${SOURCE_DIR}" ]]; then
        log_message "ERROR: source directory already exists: ${SOURCE_DIR}"
        return 20
    fi
    export GIT_TERMINAL_PROMPT=0
    log_message "cloning protobuf v${SOFTWARE_VERSION} from ${PROTOBUF_SOURCE_URL}"
    if ! git clone --branch "v${SOFTWARE_VERSION}" --depth 1 \
        "${PROTOBUF_SOURCE_URL}" "${SOURCE_DIR}"; then
        log_message "ERROR: failed to clone protobuf v${SOFTWARE_VERSION}"
        return 30
    fi
}

record_actual_version() {
    local version_output actual_version
    if ! version_output="$("${PROTOC_BIN}" --version 2>&1)"; then
        log_message "ERROR: built protoc cannot report its version"
        return 40
    fi
    actual_version="${version_output#libprotoc }"
    actual_version="${actual_version%%[[:space:]]*}"
    if [[ -z "${actual_version}" || "${actual_version}" == "${version_output}" ]]; then
        log_message "ERROR: unexpected protoc version output: ${version_output}"
        return 40
    fi
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: built protoc reports ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 40
    fi
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
}

build_protobuf() {
    initialize_runtime || return $?
    check_architecture || return $?
    require_build_commands || return $?
    if [[ -e "${SOURCE_DIR}" || -e "${BUILD_DIR}" || -e "${INSTALL_DIR}" ]]; then
        log_message "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    fi
    clone_protobuf_source || return $?
    CXX_VERSION="$("${CXX_BINARY}" --version | head -n 1)"
    log_message "building protobuf with the upstream CMake Release configuration"
    if ! cmake -S "${SOURCE_DIR}" -B "${BUILD_DIR}" \
        -DCMAKE_BUILD_TYPE=Release \
        -Dprotobuf_BUILD_TESTS=OFF \
        -Dprotobuf_BUILD_SHARED_LIBS=OFF \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}"; then
        log_message "ERROR: upstream CMake configuration failed"
        return 40
    fi
    if ! make -C "${BUILD_DIR}" -j"$(nproc)"; then
        log_message "ERROR: upstream CMake build failed"
        return 40
    fi
    if ! make -C "${BUILD_DIR}" install; then
        log_message "ERROR: private protobuf installation failed"
        return 40
    fi
    if [[ ! -x "${PROTOC_BIN}" ]]; then
        log_message "ERROR: private protoc was not installed: ${PROTOC_BIN}"
        return 40
    fi
    record_actual_version || return $?
    install_private_python_runtime || return $?
    log_message "protobuf ${SOFTWARE_VERSION} CMake build is ready"
}

start_protobuf_runtime() {
    initialize_runtime || return $?
    if [[ ! -x "${PROTOC_BIN}" ]]; then
        log_message "ERROR: private protoc is unavailable: ${PROTOC_BIN}"
        return 40
    fi
    if ! python3 -c 'import google.protobuf'; then
        log_message "ERROR: task-private protobuf Python runtime is unavailable"
        return 40
    fi
    log_message "protobuf runtime is ready"
}

run_protobuf_benchmarks() {
    initialize_runtime || return $?
    if [[ ! -x "${PROTOC_BIN}" ]]; then
        log_message "ERROR: private protoc is unavailable: ${PROTOC_BIN}"
        return 40
    fi
    export PATH="${INSTALL_DIR}/bin:${PATH}"
    export PROTOC_BIN
    log_message "running the upstream serialization benchmark"
    if ! python3 "${SCRIPT_DIR}/scripts/benchmark_ann.py" \
        --output "${RESULTS_DIR}/benchmark_ann.json" \
        --num-messages "${NUM_MESSAGES}" --iterations "${ITERATIONS}" \
        --message-size "${MESSAGE_SIZE}"; then
        log_message "ERROR: upstream serialization benchmark failed"
        return 50
    fi
    log_message "running the upstream micro benchmark"
    if ! python3 "${SCRIPT_DIR}/scripts/micro_benchmark.py" \
        --output "${RESULTS_DIR}/micro_benchmark.json" \
        --num-messages "${NUM_MESSAGES}" --iterations "${ITERATIONS}" \
        --thread-counts "${THREAD_COUNTS}"; then
        log_message "ERROR: upstream micro benchmark failed"
        return 50
    fi
    if ! python3 "${SCRIPT_DIR}/scripts/aggregate_results.py" \
        --results-dir "${RESULTS_DIR}" --output "${RESULTS_DIR}/aggregate_results.json"; then
        log_message "ERROR: upstream result aggregation failed"
        return 50
    fi
    log_message "upstream protobuf benchmark outputs are ready"
}

stop_protobuf_runtime() {
    log_message "protobuf benchmark has no background service to stop"
}

standalone_runtime() {
    python3 "${SCRIPT_DIR}/scripts/standalone_runtime.py" "$@"
}

cleanup_standalone_workdir() {
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 1 || "${STANDALONE_OWNS_WORK_DIR}" -ne 1 ]]; then
        return 0
    fi
    if [[ "${PERF_WORK_DIR}" != /tmp/protobuf-perf/local-* || "${PERF_WORK_DIR}" == /tmp/protobuf-perf ]]; then
        log_message "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    fi
    rm -rf -- "${PERF_WORK_DIR}"
}

emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then stop_protobuf_runtime; fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then cleanup_standalone_workdir; fi
}

run_protobuf_standalone() {
    local stage_status=0 failed_stage="" cleanup_status="passed" command_status="passed" finalize_status=0
    configure_runtime_paths || return $?
    trap emergency_standalone_cleanup EXIT
    initialize_runtime || return $?
    standalone_runtime system "${RESULTS_DIR}/system_info.json"
    standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json"
    if build_protobuf; then
        standalone_runtime build-info "${RESULTS_DIR}/build_info.json" \
            "${SOFTWARE_VERSION}" "${PERF_ACTUAL_VERSION_FILE}" \
            "$(normalized_architecture "${EXPECTED_ARCH}")" "${PERF_RUN_ID}" \
            "${CXX_BINARY}" "${CXX_VERSION}" || { stage_status=$?; failed_stage="build"; }
    else
        stage_status=$?; failed_stage="build"
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if start_protobuf_runtime; then :; else stage_status=$?; failed_stage="start"; fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_protobuf_benchmarks; then :; else stage_status=$?; failed_stage="test"; fi
    fi
    if ! stop_protobuf_runtime; then cleanup_status="failed"; fi
    STANDALONE_STOP_DONE=1
    if ! standalone_runtime runtime "${RESULTS_DIR}/runtime_after.json"; then cleanup_status="failed"; fi
    if ! cleanup_standalone_workdir; then cleanup_status="failed"; fi
    STANDALONE_CLEANUP_DONE=1
    if [[ "${stage_status}" -ne 0 ]]; then command_status="failed"; fi
    if standalone_runtime finalize "${RESULTS_DIR}" "${SOFTWARE_VERSION}" \
        "$(normalized_architecture "${EXPECTED_ARCH}")" "${PERF_RUN_ID}" \
        "${command_status}" "${cleanup_status}" "${failed_stage}"; then
        :
    else
        finalize_status=$?
    fi
    trap - EXIT
    if [[ "${stage_status}" -ne 0 ]]; then return "${stage_status}"; fi
    if [[ "${cleanup_status}" != "passed" ]]; then return 70; fi
    return "${finalize_status}"
}

usage() {
    printf '%s\n' \
        "Usage: $(basename "$0") [--version VERSION] [--results-dir DIR] [--keep-workdir]" \
        "Build Protobuf with the upstream CMake Release flow, then run its upstream Python benchmarks."
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version) SOFTWARE_VERSION="$2"; shift 2 ;;
            --results-dir) RESULTS_DIR="$2"; shift 2 ;;
            --keep-workdir) STANDALONE_KEEP_WORK_DIR=1; shift ;;
            -h|--help) usage; return 0 ;;
            *) log_message "ERROR: unsupported option: $1"; return 10 ;;
        esac
    done
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}"
    : > "${RESULTS_DIR}/results.log"
    set +e
    run_protobuf_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    local pipeline_status="${PIPESTATUS[0]}"
    set -e
    log_message "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
