#!/usr/bin/env bash
# XLA performance case (official source build with the official benchmark
# harness).
#
# openxla/xla is developed on a rolling main branch without release tags, so
# the software under test is pinned by commit (the same pinning style the
# mysql case uses for database_blue).  The build stage clones the official
# repository at that commit and compiles the two binaries of the official
# benchmark harness with Bazel; the Bazel version itself is pinned by the
# repository's .bazelversion file and provisioned through bazelisk from the
# official GitHub release (SHA-256 verified).
#
# The benchmark workloads are the CPU entries of the official benchmark
# registry shipped in the repository (xla/tools/benchmarks): three Gemma HLO
# modules, each executed by the repository's own run_benchmark.sh, which
# drives hlo_runner_main, collects an XSpace profile, and derives the
# CPU_TIME/WALL_TIME metrics through compute_xspace_stats_main.
#
# The four framework stages map to: clone+compile the pinned XLA (build),
# stage and smoke-verify the pinned HLO workloads (start), run the official
# benchmark suite (test), and drop the staged benchmark data (stop).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="xla"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-46bedfb7bd71}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

# Pinned XLA source (rolling main has no releases; the commit is the version).
XLA_REPOSITORY="${XLA_REPOSITORY:-https://github.com/openxla/xla.git}"
XLA_COMMIT="${XLA_COMMIT:-46bedfb7bd71ae6574ca6d8d4109fdd44fa2971d}"

# Bazel provisioned via the official bazelisk release.  Bazel itself is
# pinned by the repository's .bazelversion file, which bazelisk honors.
BAZELISK_VERSION="${BAZELISK_VERSION:-v1.29.0}"
BAZELISK_RELEASE_BASE="${BAZELISK_RELEASE_BASE:-https://github.com/bazelbuild/bazelisk/releases/download}"
BAZELISK_X86_64_SHA256="${BAZELISK_X86_64_SHA256:-5a408715e932c0250d28bd84555f12edbf70117de42f9181691c736eacc4a992}"
BAZELISK_AARCH64_SHA256="${BAZELISK_AARCH64_SHA256:-e20e8b0f4f240091b7a55bf17b9398bd4f40ee70ae0208dff95dd4c445fb4010}"

# Official CPU benchmark registry entries (xla/tools/benchmarks).  The two
# Keras/Flax workloads are served from the official GCS bucket referenced by
# the registry; the bf16 workload ships inside the repository itself.
XLA_NUM_REPEATS="${XLA_NUM_REPEATS:-5}"
XLA_GEMMA3_BENCHMARK="gemma3_1b_flax_call"
XLA_GEMMA3_HLO_NAME="gemma3_1b_flax_call.hlo"
XLA_GEMMA3_HLO_URL="${XLA_GEMMA3_HLO_URL:-https://storage.googleapis.com/xla-benchmarking-temp/gemma3_1b_flax_call.hlo}"
XLA_GEMMA3_HLO_SHA256="${XLA_GEMMA3_HLO_SHA256:-b3bee2a908477a49d41dd6d0adb8ccf2a25fe0bfecb5aa7d6bdb7cee4633b7de}"
XLA_GEMMA2_BENCHMARK="gemma2_2b_keras_jax"
XLA_GEMMA2_HLO_NAME="gemma2_2b_keras_jax.hlo"
XLA_GEMMA2_HLO_URL="${XLA_GEMMA2_HLO_URL:-https://storage.googleapis.com/xla-benchmarking-temp/gemma2_2b_keras_jax.hlo}"
XLA_GEMMA2_HLO_SHA256="${XLA_GEMMA2_HLO_SHA256:-78aaab6a47a87edbaba4d6acc10f3d5175a09c4a38b9a4cf02900c96558eb49c}"
XLA_GEMMA4_BENCHMARK="gemma4_2b_bf16"
XLA_GEMMA4_HLO_NAME="hlo_gemma4_2b_bf16.hlo"
XLA_GEMMA4_HLO_SHA256="${XLA_GEMMA4_HLO_SHA256:-b3a724c8d9990f10b8b788a8879129bf47024b847da665fccc2271ce9331f5f0}"

# Lifecycle paths (assigned in configure_runtime_paths).
XLA_SRC_DIR=""
BAZELISK_BIN=""
HLO_RUNNER_BIN=""
XSPACE_STATS_BIN=""
OFFICIAL_RUN_BENCHMARK=""
BENCHMARK_DIR=""
HARDWARE_CATEGORY=""
CONFIG_ID=""

log() {
    printf '[xla] %s\n' "$*"
}

configure_runtime_paths() {
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64)
            EXPECTED_ARCH="x86_64"
            HARDWARE_CATEGORY="CPU_X86"
            CONFIG_ID="cpu_x86"
            ;;
        aarch64|arm64)
            EXPECTED_ARCH="aarch64"
            HARDWARE_CATEGORY="CPU_ARM64"
            CONFIG_ID="cpu_arm64"
            ;;
        *)
            log "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/xla/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    XLA_SRC_DIR="${PERF_WORK_DIR}/xla-src"
    BAZELISK_BIN="${PERF_WORK_DIR}/bazelisk/bazelisk"
    HLO_RUNNER_BIN="${XLA_SRC_DIR}/bazel-bin/xla/tools/multihost_hlo_runner/hlo_runner_main"
    XSPACE_STATS_BIN="${XLA_SRC_DIR}/bazel-bin/xla/tools/compute_xspace_stats_main"
    OFFICIAL_RUN_BENCHMARK="${XLA_SRC_DIR}/.github/workflows/benchmarks/run_benchmark.sh"
    BENCHMARK_DIR="${PERF_WORK_DIR}/benchmark"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}"
}

require_xla_tools() {
    local command_name package
    local packages=()

    for command_name in sha256sum tee stat date sed find curl git python3 jq sudo; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            sha256sum|tee|stat|date) package="coreutils" ;;
            sed) package="sed" ;;
            find) package="findutils" ;;
            curl) package="curl" ;;
            git) package="git" ;;
            python3) package="python3" ;;
            jq) package="jq" ;;
            sudo) package="sudo" ;;
        esac
        log "missing required XLA test command: ${command_name}"
        packages+=("${package}")
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log "ERROR: dnf is required to install XLA test prerequisites"
        return 30
    fi

    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log "installing missing XLA test packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log "ERROR: sudo is required to install XLA test prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log "ERROR: failed to install XLA test prerequisites"
        return 30
    fi

    for command_name in sha256sum tee stat date sed find curl git python3 jq; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "ERROR: required XLA test command remains unavailable: ${command_name}"
            return 30
        fi
    done
}

download_archive() {
    local archive_path="$1"
    local download_url="$2"

    log "downloading ${download_url}" >&2
    if command -v curl >/dev/null 2>&1; then
        if ! curl -fSL --retry 3 --connect-timeout 30 -o "${archive_path}" "${download_url}"; then
            rm -f "${archive_path}"
            log "ERROR: failed to download ${download_url}" >&2
            return 30
        fi
    elif ! wget -q -O "${archive_path}" "${download_url}"; then
        rm -f "${archive_path}"
        log "ERROR: failed to download ${download_url}" >&2
        return 30
    fi
}

verify_sha256() {
    local archive_path="$1"
    local expected_sha256="$2"
    local actual_sha256

    actual_sha256="$(sha256sum "${archive_path}")"
    actual_sha256="${actual_sha256%% *}"
    if [[ "${actual_sha256}" != "${expected_sha256}" ]]; then
        log "ERROR: checksum mismatch for ${archive_path}: expected ${expected_sha256}, got ${actual_sha256}" >&2
        return 30
    fi
}

fetch_bazelisk() {
    local archive_name
    local expected_sha256
    local local_archive_path

    case "${EXPECTED_ARCH}" in
        x86_64)
            archive_name="bazelisk-linux-amd64"
            expected_sha256="${BAZELISK_X86_64_SHA256}"
            ;;
        aarch64)
            archive_name="bazelisk-linux-arm64"
            expected_sha256="${BAZELISK_AARCH64_SHA256}"
            ;;
        *)
            log "ERROR: no bazelisk release is declared for ${EXPECTED_ARCH}"
            return 10
            ;;
    esac

    mkdir -p "$(dirname "${BAZELISK_BIN}")"
    if [[ -x "${BAZELISK_BIN}" ]]; then
        log "reusing cached bazelisk ${BAZELISK_VERSION}"
        return 0
    fi
    local_archive_path="/home/runner/software/xla/${archive_name}-${BAZELISK_VERSION}"
    if [[ -f "${local_archive_path}" ]]; then
        log "using local bazelisk archive ${local_archive_path}" >&2
        if ! cp "${local_archive_path}" "${BAZELISK_BIN}"; then
            log "ERROR: failed to stage the local bazelisk archive"
            return 30
        fi
    else
        if ! download_archive "${BAZELISK_BIN}" \
            "${BAZELISK_RELEASE_BASE}/${BAZELISK_VERSION}/${archive_name}"; then
            return 30
        fi
    fi
    verify_sha256 "${BAZELISK_BIN}" "${expected_sha256}" || return 30
    chmod 0755 "${BAZELISK_BIN}"
    log "bazelisk ${BAZELISK_VERSION} provisioned"
}

build_xla() {
    local actual_commit
    local runner_architecture
    local build_jobs

    initialize_runtime || return $?
    runner_architecture="$(uname -m)"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    require_xla_tools || return $?
    if [[ -e "${XLA_SRC_DIR}" ]]; then
        log "ERROR: build output is not clean under ${XLA_SRC_DIR}"
        return 20
    fi

    log "cloning ${XLA_REPOSITORY} at ${XLA_COMMIT}"
    if ! git clone --quiet --filter=blob:none "${XLA_REPOSITORY}" "${XLA_SRC_DIR}"; then
        log "ERROR: failed to clone ${XLA_REPOSITORY}"
        return 30
    fi
    if ! git -C "${XLA_SRC_DIR}" checkout --quiet --detach "${XLA_COMMIT}"; then
        log "ERROR: XLA commit is unavailable: ${XLA_COMMIT}"
        return 30
    fi
    actual_commit="$(git -C "${XLA_SRC_DIR}" rev-parse --short=12 HEAD)"
    if [[ "${actual_commit}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: cloned XLA is ${actual_commit}, expected ${SOFTWARE_VERSION}"
        return 30
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_commit}" > "${PERF_ACTUAL_VERSION_FILE}"
    if [[ ! -f "${XLA_SRC_DIR}/.bazelversion" ]]; then
        log "ERROR: the pinned XLA checkout has no .bazelversion"
        return 40
    fi
    log "building the official benchmark harness binaries (bazel $(<"${XLA_SRC_DIR}/.bazelversion"))"

    fetch_bazelisk || return $?
    build_jobs="$(getconf _NPROCESSORS_ONLN)"
    if ! (
        cd "${XLA_SRC_DIR}"
        "${BAZELISK_BIN}" --output_user_root="${PERF_WORK_DIR}/bazel-root" \
            build -c opt --config=nonccl --jobs="${build_jobs}" \
            //xla/tools/multihost_hlo_runner:hlo_runner_main \
            //xla/tools:compute_xspace_stats_main
    ); then
        log "ERROR: the Bazel build of the benchmark harness failed"
        return 40
    fi

    if [[ ! -x "${HLO_RUNNER_BIN}" || ! -x "${XSPACE_STATS_BIN}" ]]; then
        log "ERROR: benchmark harness binaries are missing after the build"
        return 40
    fi
    if [[ ! -f "${OFFICIAL_RUN_BENCHMARK}" ]]; then
        log "ERROR: the official run_benchmark.sh is missing in the checkout"
        return 40
    fi
    log "XLA ${actual_commit} built with the official benchmark harness"
}

stage_hlo_artifact() {
    local hlo_name="$1"
    local expected_sha256="$2"
    local download_url="$3"
    local staged_path

    staged_path="${BENCHMARK_DIR}/${hlo_name}"
    if [[ -s "${staged_path}" ]]; then
        log "using staged HLO artifact ${staged_path}" >&2
    elif [[ -f "/home/runner/software/xla/${hlo_name}" ]]; then
        log "using local HLO artifact /home/runner/software/xla/${hlo_name}" >&2
        cp "/home/runner/software/xla/${hlo_name}" "${staged_path}" || return 30
    elif [[ -n "${download_url}" ]]; then
        download_archive "${staged_path}" "${download_url}" || return 30
    else
        log "ERROR: HLO artifact is unavailable: ${hlo_name}"
        return 40
    fi
    verify_sha256 "${staged_path}" "${expected_sha256}" || return 30
    printf '%s\n' "${staged_path}"
}

stage_benchmark_workloads() {
    local gemma4_repo_path="${XLA_SRC_DIR}/xla/tools/benchmarks/hlo/${XLA_GEMMA4_HLO_NAME}"

    mkdir -p "${BENCHMARK_DIR}"
    stage_hlo_artifact "${XLA_GEMMA3_HLO_NAME}" "${XLA_GEMMA3_HLO_SHA256}" \
        "${XLA_GEMMA3_HLO_URL}" >/dev/null || return $?
    stage_hlo_artifact "${XLA_GEMMA2_HLO_NAME}" "${XLA_GEMMA2_HLO_SHA256}" \
        "${XLA_GEMMA2_HLO_URL}" >/dev/null || return $?
    if [[ ! -s "${BENCHMARK_DIR}/${XLA_GEMMA4_HLO_NAME}" ]]; then
        if [[ ! -f "${gemma4_repo_path}" ]]; then
            log "ERROR: the pinned checkout does not contain ${XLA_GEMMA4_HLO_NAME}"
            return 40
        fi
        cp "${gemma4_repo_path}" "${BENCHMARK_DIR}/${XLA_GEMMA4_HLO_NAME}" || return 40
    fi
    verify_sha256 "${BENCHMARK_DIR}/${XLA_GEMMA4_HLO_NAME}" "${XLA_GEMMA4_HLO_SHA256}" || return 30
    log "all three official HLO workloads are staged and verified"
}

# Drive one benchmark through the repository's own run_benchmark.sh.  The
# script derives CPU_TIME/WALL_TIME (milliseconds) from the XSpace profile
# and writes results.json into the given output directory.
run_official_benchmark() {
    local benchmark_name="$1"
    local hlo_path="$2"
    local num_repeats="$3"
    local output_dir="$4"

    mkdir -p "${output_dir}"
    (
        export BENCHMARK_NAME="${benchmark_name}"
        export CONFIG_ID="${CONFIG_ID}"
        export HARDWARE_CATEGORY="${HARDWARE_CATEGORY}"
        export OUTPUT_DIR="${output_dir}"
        export RUNNER_BINARY="${HLO_RUNNER_BIN}"
        export STATS_BINARY="${XSPACE_STATS_BIN}"
        export DEVICE_TYPE_FLAG="host"
        export LOCAL_ARTIFACT_PATH="${hlo_path}"
        export INPUT_FORMAT=""
        export XLA_FLAGS_JSON="[]"
        export RUNTIME_FLAGS_JSON="[\"--num_repeats=${num_repeats}\"]"
        export COMMIT_SHA="${XLA_COMMIT}"
        export WORKFLOW_RUN_ID="${PERF_RUN_ID}"
        bash "${OFFICIAL_RUN_BENCHMARK}"
    )
}

verify_benchmark_result() {
    local results_json="$1"
    local benchmark_name="$2"

    if ! jq -e --arg name "${benchmark_name}" \
        '.benchmark_name == $name and .run_status == "SUCCESS" and
         (.metrics.CPU_TIME.value > 0) and (.metrics.WALL_TIME.value > 0) and
         (.metrics.CPU_TIME.unit == "ms") and (.metrics.WALL_TIME.unit == "ms")' \
        "${results_json}" >/dev/null; then
        log "ERROR: benchmark result is not a successful CPU measurement: ${results_json}"
        return 50
    fi
}

start_xla_runtime() {
    local smoke_dir

    initialize_runtime || return $?
    if [[ ! -x "${HLO_RUNNER_BIN}" ]]; then
        log "ERROR: XLA is not built (run build first)"
        return 40
    fi

    stage_benchmark_workloads || return $?

    # Smoke-run the smallest official workload once through the complete
    # official chain (runner, XSpace profile, stats) so the test stage only
    # ever times a fully verified toolchain/workload pair.
    smoke_dir="${PERF_WORK_DIR}/smoke"
    rm -rf "${smoke_dir}"
    log "smoke-running ${XLA_GEMMA3_BENCHMARK} through the official harness"
    if ! run_official_benchmark "${XLA_GEMMA3_BENCHMARK}" \
        "${BENCHMARK_DIR}/${XLA_GEMMA3_HLO_NAME}" 1 "${smoke_dir}"; then
        rm -rf "${smoke_dir}"
        log "ERROR: the official harness smoke run failed"
        return 40
    fi
    if ! verify_benchmark_result "${smoke_dir}/results.json" "${XLA_GEMMA3_BENCHMARK}"; then
        rm -rf "${smoke_dir}"
        return 40
    fi
    rm -rf "${smoke_dir}"
    log "XLA benchmark runtime is ready"
}

run_xla_benchmarks() {
    local raw_output
    local benchmark_name
    local hlo_name
    local benchmark_runs_dir
    local work_dir

    initialize_runtime || return $?
    require_xla_tools || return $?
    if [[ ! -x "${HLO_RUNNER_BIN}" ]]; then
        log "ERROR: XLA is not built (run build first)"
        return 50
    fi
    verify_sha256 "${BENCHMARK_DIR}/${XLA_GEMMA3_HLO_NAME}" "${XLA_GEMMA3_HLO_SHA256}" || return 50
    verify_sha256 "${BENCHMARK_DIR}/${XLA_GEMMA2_HLO_NAME}" "${XLA_GEMMA2_HLO_SHA256}" || return 50
    verify_sha256 "${BENCHMARK_DIR}/${XLA_GEMMA4_HLO_NAME}" "${XLA_GEMMA4_HLO_SHA256}" || return 50

    raw_output="${RESULTS_DIR}/hlo_benchmark_raw.log"
    benchmark_runs_dir="${RESULTS_DIR}/benchmark_runs"
    rm -rf "${benchmark_runs_dir}"
    mkdir -p "${benchmark_runs_dir}"
    log "running the official XLA CPU benchmark registry entries with ${XLA_NUM_REPEATS} repeats"

    if ! (
        for benchmark_name in "${XLA_GEMMA3_BENCHMARK}" "${XLA_GEMMA2_BENCHMARK}" "${XLA_GEMMA4_BENCHMARK}"; do
            case "${benchmark_name}" in
                "${XLA_GEMMA3_BENCHMARK}") hlo_name="${XLA_GEMMA3_HLO_NAME}" ;;
                "${XLA_GEMMA2_BENCHMARK}") hlo_name="${XLA_GEMMA2_HLO_NAME}" ;;
                "${XLA_GEMMA4_BENCHMARK}") hlo_name="${XLA_GEMMA4_HLO_NAME}" ;;
            esac
            work_dir="${PERF_WORK_DIR}/bench-${benchmark_name}"
            rm -rf "${work_dir}"
            run_official_benchmark "${benchmark_name}" \
                "${BENCHMARK_DIR}/${hlo_name}" "${XLA_NUM_REPEATS}" "${work_dir}" || exit 50
            verify_benchmark_result "${work_dir}/results.json" "${benchmark_name}" || exit 50
            mkdir -p "${benchmark_runs_dir}/${benchmark_name}"
            cp "${work_dir}/results.json" "${benchmark_runs_dir}/${benchmark_name}/results.json" || exit 50
            cp "${work_dir}/runner_stdout.txt" "${benchmark_runs_dir}/${benchmark_name}/runner_stdout.txt" || exit 50
            rm -rf "${work_dir}"
            log "benchmark ${benchmark_name} completed"
        done
    ) 2>&1 | tee "${raw_output}"; then
        log "ERROR: the official XLA benchmark suite failed (see ${raw_output})"
        return 50
    fi

    python3 "${SCRIPT_DIR}/scripts/collect_xla_benchmark.py" \
        "${benchmark_runs_dir}" "${RESULTS_DIR}/results.json" || return 50
    log "official XLA benchmark suite completed"
}

stop_xla_runtime() {
    initialize_runtime || return $?
    log "XLA benchmark has no background service to stop"
    if [[ -d "${BENCHMARK_DIR}" ]]; then
        rm -rf "${BENCHMARK_DIR}"
        log "staged HLO workloads removed from ${BENCHMARK_DIR}"
    fi
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
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/xla/local-* || \
          "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/xla" ]]; then
        log "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    fi
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        rm -rf -- "${PERF_WORK_DIR}" || return 70
    fi
    log "cleaned standalone work directory: ${PERF_WORK_DIR}"
}

emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then
        stop_xla_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_xla_standalone() {
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
        if build_xla; then
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
        if start_xla_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_xla_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_xla_runtime; then
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
        finalize_status=0
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

Build the pinned openxla/xla revision with Bazel and run the official CPU
benchmark registry entries (Gemma HLO workloads via run_benchmark.sh) as a
standalone performance evaluation. Results default to
results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       XLA revision (12-character commit id, default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR, XLA_COMMIT,
  XLA_NUM_REPEATS
USAGE
}

main() {
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
    mkdir -p "${RESULTS_DIR}" || return $?
    : > "${RESULTS_DIR}/results.log"
    local pipeline_status=0
    set +e
    run_xla_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
