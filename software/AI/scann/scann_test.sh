#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.4.2}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
readonly NUMPY_VERSION="2.4.6"
readonly PROTOBUF_VERSION="5.29.5"
readonly BAZEL_VERSION="7.4.1"
DATA_SCALE="${DATA_SCALE:-100K}"
DATA_DIM="${DATA_DIM:-128}"
ITERATIONS="${ITERATIONS:-1}"
K="${K:-10}"

SCANN_INSTALL_DIR=""
PYTHON_DEPENDENCY_DIR=""
BUILD_TOOLCHAIN_DIR=""
BUILD_VENV_DIR=""
SCANN_SOURCE_DIR=""
SCANN_WHEEL_FILE=""
CLANG_BINARY=""
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0


log_message() {
    printf '[scann] %s\n' "$*"
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

github_download_url() {
    local source_url="$1"

    if [[ -n "${PERF_GITHUB_DOWNLOAD_PROXY:-}" && "${source_url}" == https://github.com/* ]]; then
        printf '%s/%s\n' "${PERF_GITHUB_DOWNLOAD_PROXY%/}" "${source_url}"
        return
    fi
    printf '%s\n' "${source_url}"
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
        PERF_WORK_DIR="/tmp/scann-perf/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
        TMPDIR="${PERF_WORK_DIR}/tmp"
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi

    SCANN_INSTALL_DIR="${PERF_WORK_DIR}/scann-install"
    PYTHON_DEPENDENCY_DIR="${PERF_WORK_DIR}/python-dependencies"
    BUILD_TOOLCHAIN_DIR="${PERF_WORK_DIR}/build-toolchain"
    BUILD_VENV_DIR="${PERF_WORK_DIR}/build-venv"
    SCANN_SOURCE_DIR="${PERF_WORK_DIR}/scann-src"

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
    for required_command in python3 nproc sed tee curl git rsync g++; do
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


install_python_dependencies() {
    local os_id
    local pip_options
    pip_options=(
        --disable-pip-version-check
        --no-input
        --no-cache-dir
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
    log_message "installing private Python dependencies numpy==${NUMPY_VERSION} protobuf==${PROTOBUF_VERSION}"
    if ! python3 -m pip install "${pip_options[@]}" \
        "numpy==${NUMPY_VERSION}" "protobuf==${PROTOBUF_VERSION}"; then
        log_message "ERROR: failed to install private Python dependencies"
        return 30
    fi
    PYTHONPATH="${PYTHON_DEPENDENCY_DIR}${PYTHONPATH:+:${PYTHONPATH}}"
    export PYTHONPATH
}


scann_source_commit() {
    case "${SOFTWARE_VERSION}" in
        1.3.5) printf 'e220e62ef332d80219a8a141c751dfdedbfccc6c\n' ;;
        1.4.2) printf '634a79fb5b4b23237a81eac028d27b5d34a5dba4\n' ;;
        *)
            log_message "ERROR: no source revision mapped for ScaNN ${SOFTWARE_VERSION}"
            return 30
            ;;
    esac
}


scann_tensorflow_version() {
    case "${SOFTWARE_VERSION}" in
        1.3.5) printf '2.18.0\n' ;;
        1.4.2) printf '2.20.0\n' ;;
        *)
            log_message "ERROR: no TensorFlow version mapped for ScaNN ${SOFTWARE_VERSION}"
            return 30
            ;;
    esac
}


scann_clang_version() {
    case "${SOFTWARE_VERSION}" in
        1.3.5) printf '17\n' ;;
        1.4.2) printf '19\n' ;;
        *)
            log_message "ERROR: no Clang version mapped for ScaNN ${SOFTWARE_VERSION}"
            return 30
            ;;
    esac
}


python_pip_index_options() {
    local os_id
    os_id="$(operating_system_id)"
    if [[ "${os_id}" != "ubuntu" ]]; then
        printf '%s\n' \
            '--trusted-host' 'mirrors.huaweicloud.com' \
            '--index-url' 'https://mirrors.huaweicloud.com/repository/pypi/simple'
    fi
}


prepare_build_venv() {
    local tf_version
    local pip_index_options
    tf_version="$(scann_tensorflow_version)" || return $?
    mapfile -t pip_index_options < <(python_pip_index_options)
    log_message "creating build virtualenv with TensorFlow ${tf_version}"
    if ! python3 -m venv "${BUILD_VENV_DIR}"; then
        log_message "ERROR: failed to create build virtualenv"
        return 30
    fi
    if ! "${BUILD_VENV_DIR}/bin/python" -m pip install \
        --disable-pip-version-check --no-input --no-cache-dir \
        "${pip_index_options[@]}" \
        "tensorflow==${tf_version}" numpy protobuf build wheel setuptools; then
        log_message "ERROR: failed to install build-time Python dependencies"
        return 30
    fi
}


prepare_bazel() {
    local arch
    local bazel_file
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
        return 0
    fi
    log_message "downloading bazel ${BAZEL_VERSION} for ${arch}"
    if ! curl -fsSL -o "${BUILD_TOOLCHAIN_DIR}/bazel" \
        "$(github_download_url "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/${bazel_file}")"; then
        log_message "ERROR: failed to download bazel ${BAZEL_VERSION} for ${arch}"
        return 30
    fi
    chmod +x "${BUILD_TOOLCHAIN_DIR}/bazel"
    "${BUILD_TOOLCHAIN_DIR}/bazel" --version
}


locate_clang() {
    local clang_version="$1"
    local candidate
    for candidate in \
        "clang-${clang_version}" \
        "/usr/bin/clang-${clang_version}" \
        "/usr/lib/llvm-${clang_version}/bin/clang" \
        "/opt/rh/llvm-toolset-${clang_version}/root/usr/bin/clang"; do
        if command -v "${candidate}" >/dev/null 2>&1 || [[ -x "${candidate}" ]]; then
            printf '%s\n' "${candidate}"
            return 0
        fi
    done
    return 1
}


llvm_clang_download_url() {
    local clang_version="$1"
    local arch="$2"
    case "${clang_version}:${arch}" in
        17:x86_64) printf 'https://github.com/llvm/llvm-project/releases/download/llvmorg-17.0.6/clang+llvm-17.0.6-x86_64-linux-gnu-ubuntu-22.04.tar.xz\n' ;;
        17:aarch64) printf 'https://github.com/llvm/llvm-project/releases/download/llvmorg-17.0.6/clang+llvm-17.0.6-aarch64-linux-gnu.tar.xz\n' ;;
        19:x86_64) printf 'https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.7/LLVM-19.1.7-Linux-X64.tar.xz\n' ;;
        19:aarch64) printf 'https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.7/clang+llvm-19.1.7-aarch64-linux-gnu.tar.xz\n' ;;
        *) return 30 ;;
    esac
}


prepare_clang() {
    local clang_version arch download_url archive_name clang_dir
    clang_version="$(scann_clang_version)" || return $?
    if CLANG_BINARY="$(locate_clang "${clang_version}")"; then
        log_message "using system clang: ${CLANG_BINARY}"
        "${CLANG_BINARY}" --version
        return 0
    fi
    arch="$(normalize_architecture "${EXPECTED_ARCH}")"
    download_url="$(llvm_clang_download_url "${clang_version}" "${arch}")" || return $?
    archive_name="${download_url##*/}"
    clang_dir="${BUILD_TOOLCHAIN_DIR}/clang-${clang_version}"
    if [[ ! -x "${clang_dir}/bin/clang" ]]; then
        log_message "downloading clang ${clang_version} for ${arch} into the work area"
        mkdir -p "${BUILD_TOOLCHAIN_DIR}"
        if ! curl -fsSL -o "${BUILD_TOOLCHAIN_DIR}/${archive_name}" \
            "$(github_download_url "${download_url}")"; then
            log_message "ERROR: failed to download clang ${clang_version} for ${arch}"
            return 30
        fi
        if ! mkdir -p "${clang_dir}" \
            || ! tar -xJf "${BUILD_TOOLCHAIN_DIR}/${archive_name}" -C "${clang_dir}" --strip-components=1; then
            log_message "ERROR: failed to extract clang ${clang_version}"
            return 30
        fi
        rm -f "${BUILD_TOOLCHAIN_DIR}/${archive_name}"
    fi
    CLANG_BINARY="${clang_dir}/bin/clang"
    log_message "using clang: ${CLANG_BINARY}"
    "${CLANG_BINARY}" --version
}


prepare_scann_source() {
    local source_commit
    source_commit="$(scann_source_commit)" || return $?
    if [[ -e "${SCANN_SOURCE_DIR}" ]]; then
        log_message "ERROR: source directory already exists: ${SCANN_SOURCE_DIR}"
        return 30
    fi
    log_message "fetching ScaNN ${SOFTWARE_VERSION} source (${source_commit})"
    if ! git clone --filter=blob:none --no-checkout \
        https://github.com/google-research/google-research.git \
        "${SCANN_SOURCE_DIR}"; then
        log_message "ERROR: failed to clone ScaNN source repository"
        return 30
    fi
    if ! (cd "${SCANN_SOURCE_DIR}" \
        && git sparse-checkout set scann \
        && git checkout "${source_commit}"); then
        log_message "ERROR: failed to check out ScaNN ${SOFTWARE_VERSION} source"
        return 30
    fi
}


build_scann_wheel_from_source() {
    local arch
    local bazel_bin="${BUILD_TOOLCHAIN_DIR}/bazel"
    local build_python="${BUILD_VENV_DIR}/bin/python"
    local scann_root="${SCANN_SOURCE_DIR}/scann"
    local bazel_startup_flags
    local bazel_flags
    arch="$(normalize_architecture "${EXPECTED_ARCH}")"

    log_message "configuring ScaNN build (${arch})"
    if ! (cd "${scann_root}" \
        && PATH="${BUILD_VENV_DIR}/bin:${PATH}" \
           exec "${build_python}" configure.py); then
        log_message "ERROR: ScaNN configure.py failed"
        return 30
    fi
    if ! grep -q 'TF_HEADER_DIR' "${scann_root}/.bazelrc"; then
        log_message "ERROR: configure.py did not produce a valid TensorFlow configuration"
        return 30
    fi

    bazel_startup_flags=(
        "--output_user_root=${BUILD_TOOLCHAIN_DIR}/bazel-cache"
    )
    bazel_flags=(
        build
        "--repository_cache=${BUILD_TOOLCHAIN_DIR}/bazel-repo-cache"
        -c
        opt
        --features=thin_lto
        --cxxopt="-std=c++17"
        --copt=-fsized-deallocation
        --copt=-w
    )
    case "${arch}" in
        x86_64)
            bazel_flags+=(--copt=-mavx --copt=-mfma)
            ;;
        aarch64)
            bazel_flags+=(--copt=-march=armv8-a+simd)
            ;;
        *)
            log_message "ERROR: unsupported build architecture: ${arch}"
            return 30
            ;;
    esac
    bazel_flags+=(:build_pip_pkg)

    log_message "compiling ScaNN ${SOFTWARE_VERSION} with bazel (${arch})"
    if ! (cd "${scann_root}" \
        && PATH="${BUILD_VENV_DIR}/bin:${PATH}" \
           CC="${CLANG_BINARY}" \
           exec "${bazel_bin}" "${bazel_startup_flags[@]}" "${bazel_flags[@]}"); then
        log_message "ERROR: ScaNN bazel build failed"
        return 30
    fi

    log_message "packaging ScaNN wheel"
    if ! (cd "${scann_root}" \
        && PATH="${BUILD_VENV_DIR}/bin:${PATH}" \
           PYTHON="${build_python}" \
           CC="${CLANG_BINARY}" \
           exec "${scann_root}/bazel-bin/build_pip_pkg"); then
        log_message "ERROR: ScaNN wheel packaging failed"
        return 30
    fi

    SCANN_WHEEL_FILE="$(cd "${scann_root}" && ls -1 ./*.whl 2>/dev/null | head -n 1)"
    if [[ -z "${SCANN_WHEEL_FILE}" ]]; then
        log_message "ERROR: ScaNN wheel was not produced"
        return 30
    fi
    log_message "ScaNN wheel built: ${SCANN_WHEEL_FILE}"
}


install_scann_wheel() {
    local pip_options
    if [[ -z "${SCANN_WHEEL_FILE}" ]]; then
        log_message "ERROR: no ScaNN wheel available to install"
        return 30
    fi
    pip_options=(
        --disable-pip-version-check
        --no-input
        --no-cache-dir
        --no-deps
        --target "${SCANN_INSTALL_DIR}"
    )
    log_message "installing built ScaNN ${SOFTWARE_VERSION} wheel into the private work area"
    if ! python3 -m pip install "${pip_options[@]}" "${SCANN_WHEEL_FILE}"; then
        log_message "ERROR: failed to install built ScaNN ${SOFTWARE_VERSION} wheel"
        return 30
    fi
}


activate_scann_runtime() {
    PYTHONPATH="${SCANN_INSTALL_DIR}:${PYTHON_DEPENDENCY_DIR}"
    export PYTHONPATH
    if ! python3 -c 'import scann, numpy'; then
        log_message "ERROR: installed ScaNN Python module cannot be imported"
        return 40
    fi
}


installed_scann_version() {
    PYTHONPATH="${SCANN_INSTALL_DIR}:${PYTHON_DEPENDENCY_DIR}" python3 -c '
import importlib.metadata
print(importlib.metadata.version("scann"))
'
}


build_scann() {
    local actual_version

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
    if [[ -e "${SCANN_INSTALL_DIR}" || -e "${PYTHON_DEPENDENCY_DIR}" \
        || -e "${BUILD_TOOLCHAIN_DIR}" || -e "${BUILD_VENV_DIR}" || -e "${SCANN_SOURCE_DIR}" ]]; then
        log_message "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    fi

    if install_python_dependencies; then
        :
    else
        return $?
    fi
    if prepare_build_venv; then
        :
    else
        return $?
    fi
    if prepare_bazel; then
        :
    else
        return $?
    fi
    if prepare_clang; then
        :
    else
        return $?
    fi
    if prepare_scann_source; then
        :
    else
        return $?
    fi
    if build_scann_wheel_from_source; then
        :
    else
        return $?
    fi
    if install_scann_wheel; then
        :
    else
        return $?
    fi
    if activate_scann_runtime; then
        :
    else
        return $?
    fi
    actual_version="$(installed_scann_version)"
    if [[ -z "${actual_version}" ]]; then
        log_message "ERROR: cannot read the installed ScaNN version"
        return 40
    fi
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: installed ScaNN reports ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    if ! printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"; then
        log_message "ERROR: failed to record installed ScaNN version"
        return 40
    fi
    log_message "ScaNN ${actual_version} is ready (built from source for ${EXPECTED_ARCH})"
}


start_scann_runtime() {
    if initialize_runtime; then
        :
    else
        return $?
    fi
    if activate_scann_runtime; then
        :
    else
        return $?
    fi
    if ! python3 -c '
import numpy as np
import scann

rng = np.random.default_rng(0)
vectors = rng.random((32, 8), dtype="float32")
searcher = (
    scann.scann_ops_pybind.builder(vectors, 3, "dot_product")
    .tree(8, 1, training_sample_size=32, spherical=True, quantize_centroids=True)
    .score_ah(2, anisotropic_quantization_threshold=0.2)
    .reorder(3)
    .build()
)
neighbors, distances = searcher.search(vectors[0], 3, 3, 1)
assert neighbors.shape == (3,)
assert distances.shape == (3,)
'; then
        log_message "ERROR: ScaNN dot_product runtime validation failed"
        return 40
    fi
    log_message "ScaNN CPU Python runtime is ready"
}


run_scann_benchmarks() {
    if initialize_runtime; then
        :
    else
        return $?
    fi
    if activate_scann_runtime; then
        :
    else
        return $?
    fi
    if ! python3 "${SCRIPT_DIR}/scripts/benchmark.py"; then
        log_message "ERROR: ScaNN benchmark failed"
        return 50
    fi
    log_message "ScaNN benchmark results written to benchmark.json"
}


stop_scann_runtime() {
    log_message "ScaNN benchmark has no background service to stop"
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
    if [[ "${PERF_WORK_DIR}" != /tmp/scann-perf/local-* || \
          "${PERF_WORK_DIR}" == "/tmp/scann-perf" ]]; then
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
        stop_scann_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}


run_scann_standalone() {
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
        if build_scann; then
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
        if start_scann_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_scann_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_scann_runtime; then
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

Install the official ScaNN wheel into a private work area, run the ScaNN vector
search benchmark, collect environment information, validate results, generate a
report, and clean the private work area.

Options:
  --version VERSION       ScaNN version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR,
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
    run_scann_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log_message "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}


if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
