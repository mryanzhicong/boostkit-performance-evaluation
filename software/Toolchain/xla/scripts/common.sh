#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASE_DIR="${SCRIPT_DIR}"
SOFTWARE_NAME="xla"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1930995a8aab}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"

# openxla/xla is developed on a rolling main branch, so the software version
# is the commit itself (short 12 characters in the manifest, full SHA in the
# script).
XLA_REPOSITORY="${XLA_REPOSITORY:-https://github.com/openxla/xla.git}"
XLA_COMMIT="${XLA_COMMIT:-1930995a8aabe45a13854f701b5b39ab732aef94}"
XLA_ARCHIVE_DIR="${XLA_ARCHIVE_DIR:-/home/runner/software/xla}"

# Bazel is provisioned through the official bazelisk release; the actual
# Bazel version is pinned by the repository's .bazelversion file.
BAZELISK_VERSION="${BAZELISK_VERSION:-v1.29.0}"
BAZELISK_RELEASE_BASE="${BAZELISK_RELEASE_BASE:-https://github.com/bazelbuild/bazelisk/releases/download}"
BAZELISK_X86_64_SHA256="${BAZELISK_X86_64_SHA256:-5a408715e932c0250d28bd84555f12edbf70117de42f9181691c736eacc4a992}"
BAZELISK_AARCH64_SHA256="${BAZELISK_AARCH64_SHA256:-e20e8b0f4f240091b7a55bf17b9398bd4f40ee70ae0208dff95dd4c445fb4010}"

# Official CPU benchmark registry entries (xla/tools/benchmarks). The two
# Keras/Flax workloads are served from the official GCS bucket referenced by
# the registry; the bf16 workload ships inside the pinned commit.
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

log_message() { printf '[xla] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    [[ "${SOFTWARE_VERSION}" == "1930995a8aab" ]] || {
        log_message "ERROR: unsupported XLA version: ${SOFTWARE_VERSION}"
        return 10
    }
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
            log_message "ERROR: unsupported architecture: ${EXPECTED_ARCH}"
            return 10
            ;;
    esac
    [[ "${EXPECTED_ARCH}" == "$(uname -m)" ]] || {
        log_message "ERROR: runner architecture differs from ${EXPECTED_ARCH}"
        return 20
    }
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log_message 'ERROR: unsafe run ID'
        return 10
    }
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/xla/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${CASE_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${CASE_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    TMPDIR="${PERF_WORK_DIR}/tmp"
    XLA_SRC_DIR="${PERF_WORK_DIR}/xla-src"
    BAZELISK_BIN="${PERF_WORK_DIR}/bazelisk/bazelisk"
    HLO_RUNNER_BIN="${XLA_SRC_DIR}/bazel-bin/xla/tools/multihost_hlo_runner/hlo_runner_main"
    XSPACE_STATS_BIN="${XLA_SRC_DIR}/bazel-bin/xla/tools/compute_xspace_stats_main"
    OFFICIAL_RUN_BENCHMARK="${XLA_SRC_DIR}/.github/workflows/benchmarks/run_benchmark.sh"
    BENCHMARK_DIR="${PERF_WORK_DIR}/benchmark"
    export SOFTWARE_VERSION PERF_VARIANT EXPECTED_ARCH PERF_RUN_ID PERF_WORK_DIR RESULTS_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR HARDWARE_CATEGORY CONFIG_ID
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}" "${TMPDIR}"
}

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else
        "$@"
    fi
}

verify_sha256() {
    local file_path="$1" expected="$2" actual
    actual="$(sha256sum "${file_path}" | cut -d' ' -f1)"
    [[ "${actual}" == "${expected}" ]] || {
        log_message "ERROR: checksum mismatch for ${file_path}: expected ${expected}, got ${actual}"
        return 30
    }
}
