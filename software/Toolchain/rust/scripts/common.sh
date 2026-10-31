#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASE_DIR="${SCRIPT_DIR}"
SOFTWARE_NAME="rust"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.99.1}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"

# Official Rust distribution endpoint and the pinned upstream benchmark suite.
RUST_RELEASE_BASE="${RUST_RELEASE_BASE:-https://static.rust-lang.org/dist}"
RUSTC_PERF_REPOSITORY="${RUSTC_PERF_REPOSITORY:-https://github.com/rust-lang/rustc-perf.git}"
RUSTC_PERF_REVISION="${RUSTC_PERF_REVISION:-9fa958a70781ab8abe5ee9e0875f0a9a62ecb20c}"
RUST_ARCHIVE_DIR="${RUST_ARCHIVE_DIR:-/home/runner/software/rust}"

# Formal workload: official rustc-perf defaults restricted to the Primary
# (real-world) benchmark category, the three default build profiles, and the
# Full (non-incremental) scenario for compile-time measurements; the runtime
# suite keeps its default iteration count.
RUST_COMPILE_PROFILES="${RUST_COMPILE_PROFILES:-Check,Debug,Opt}"
RUST_COMPILE_SCENARIOS="${RUST_COMPILE_SCENARIOS:-Full}"
RUST_COMPILE_CATEGORY="${RUST_COMPILE_CATEGORY:-Primary}"
RUST_COMPILE_ITERATIONS="${RUST_COMPILE_ITERATIONS:-1}"
RUST_RUNTIME_ITERATIONS="${RUST_RUNTIME_ITERATIONS:-5}"
RUST_BENCH_ID="${RUST_BENCH_ID:-boostkit-${SOFTWARE_VERSION}-base}"

# Per-architecture official tarballs with SHA-256 values taken from the
# official channel manifest (channel-rust-stable.toml, xz_hash).
RUST_TARGET_TRIPLE=""
RUST_ARCHIVE=""
RUST_ARCHIVE_SHA256=""
RUST_HOME=""
RUSTC_BIN=""
CARGO_BIN=""
RUSTC_PERF_DIR=""
RUST_DB=""
COLLECTOR_BIN=""

log_message() { printf '[rust] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    [[ "${SOFTWARE_VERSION}" == 1.99.1 ]] || { log_message "ERROR: unsupported Rust version: ${SOFTWARE_VERSION}"; return 10; }
    [[ "${EXPECTED_ARCH}" == "$(uname -m)" ]] || { log_message "ERROR: runner architecture differs from ${EXPECTED_ARCH}"; return 20; }
    case "${EXPECTED_ARCH}" in
        x86_64)
            RUST_TARGET_TRIPLE="x86_64-unknown-linux-gnu"
            RUST_ARCHIVE_SHA256="231fcae47ee950621374725b5fc3b5441d2fbda2955ac45dd7dc816d8876cfe7"
            ;;
        aarch64)
            RUST_TARGET_TRIPLE="aarch64-unknown-linux-gnu"
            RUST_ARCHIVE_SHA256="a48fb1e853be56ce9b8e2751f5464dbd5e16440cd81e237920f3a5e7e806333e"
            ;;
        *)
            log_message "ERROR: unsupported architecture: ${EXPECTED_ARCH}"; return 10 ;;
    esac
    RUST_ARCHIVE="rust-${SOFTWARE_VERSION}-${RUST_TARGET_TRIPLE}.tar.xz"
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || { log_message 'ERROR: unsafe run ID'; return 10; }
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/rust/local-${PERF_RUN_ID}"
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
    RUST_HOME="${PERF_WORK_DIR}/rust-install"
    RUSTC_BIN="${RUST_HOME}/bin/rustc"
    CARGO_BIN="${RUST_HOME}/bin/cargo"
    RUSTC_PERF_DIR="${PERF_WORK_DIR}/rustc-perf"
    RUST_DB="${PERF_WORK_DIR}/rustc-perf-results.db"
    COLLECTOR_BIN="${RUSTC_PERF_DIR}/target/release/collector"
    export CARGO_HOME="${CARGO_HOME:-${PERF_WORK_DIR}/cargo}"
    export SOFTWARE_VERSION PERF_VARIANT EXPECTED_ARCH PERF_RUN_ID PERF_WORK_DIR RESULTS_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR RUST_HOME RUSTC_PERF_DIR CARGO_HOME
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}" "${TMPDIR}" "${CARGO_HOME}"
}

load_rust_toolchain() {
    [[ -x "${RUSTC_BIN}" && -x "${CARGO_BIN}" ]] || {
        log_message "ERROR: private Rust toolchain is missing in ${RUST_HOME}"
        return 40
    }
    PATH="${RUST_HOME}/bin:${PATH}"
    export PATH
}

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else
        "$@"
    fi
}

# Record the version reported by the installed rustc and cargo binaries; the
# full "rustc <version> (<hash> <date>)" line keeps the commit hash traceable.
record_actual_version() {
    local rustc_output cargo_output actual_version
    rustc_output="$("${RUSTC_BIN}" --version)" || return 30
    cargo_output="$("${CARGO_BIN}" --version)" || return 30
    actual_version="$(sed -nE 's/^rustc ([0-9]+\.[0-9]+\.[0-9]+) .*/\1/p' <<< "${rustc_output}")"
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: installed rustc reports ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 30
    }
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    printf '%s\n' "${rustc_output}" > "${PERF_WORK_DIR}/rustc-version.txt"
    printf '%s\n' "${cargo_output}" > "${PERF_WORK_DIR}/cargo-version.txt"
}
