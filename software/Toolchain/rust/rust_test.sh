#!/usr/bin/env bash
# Rust performance case (official prebuilt toolchain deployment).
#
# The software under test is fetched from the official static.rust-lang.org
# prebuilt "rust-<version>-<target>.tar.xz" release tarball and installed into
# a per-version prefix through the tarball's own install.sh — the
# distribution package manager only ships one version and cannot switch
# between releases.  The benchmark workload is the official ripgrep crate
# release from crates.io (SHA-256 verified, Cargo.lock included, every
# dependency additionally checksum-verified by cargo itself).
#
# The benchmark evaluates both compiler dimensions, mirroring the clang case:
# compile throughput (three cargo optimization profiles over the whole
# ripgrep workspace, the Rust counterpart of -O0/-O2/-Os) and generated-code
# quality (the release binary searching deterministically generated corpora).
#
# The four framework stages map to: fetch+verify+install the toolchain
# tarball (build), stage the pinned ripgrep sources, pre-fetch its locked
# dependencies, smoke-build and generate the corpora (start), run the compile
# and search scenarios (test), and remove the staged benchmark data (stop).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="rust"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.98.1}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

# Official Rust distribution endpoint.
RUST_RELEASE_BASE="${RUST_RELEASE_BASE:-https://static.rust-lang.org/dist}"

# Pinned benchmark workload: the official ripgrep crate release.  The .crate
# archive ships Cargo.lock, so `cargo build --locked` resolves every
# dependency to a fixed version whose crates.io checksum cargo verifies
# itself.
RIPGREP_VERSION="${RIPGREP_VERSION:-15.2.0}"
RIPGREP_CRATE_BASE="${RIPGREP_CRATE_BASE:-https://static.crates.io/crates/ripgrep}"
RIPGREP_SHA256="${RIPGREP_SHA256:-a30750b6d0743bfdd2656ebbaf4555aa278c43144b84bc389bcbfa399485ec71}"

# Benchmark rounds per workload, the compile profile ladder, and the corpus
# sizes for the search scenario.
RUST_ROUNDS="${RUST_ROUNDS:-5}"
RUST_COMPILE_PROFILES=(dev release opt-level=s)
RUST_SEARCH_NEEDLE="boostkit-perf-needle-7f3a"
RUST_SEARCH_CORPUS_SIZES_MIB=(64 512)

# Lifecycle paths (assigned in configure_runtime_paths).
RUST_ROOT=""
RUSTC_BIN=""
CARGO_BIN=""
BENCHMARK_DIR=""
RIPGREP_DIR=""
CARGO_HOME_DIR=""

log() {
    printf '[rust] %s\n' "$*"
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
            ;;
        aarch64|arm64)
            EXPECTED_ARCH="aarch64"
            ;;
        *)
            EXPECTED_ARCH="${EXPECTED_ARCH,,}"
            ;;
    esac
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/rust/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    RUST_ROOT="${PERF_WORK_DIR}/rust"
    RUSTC_BIN="${RUST_ROOT}/bin/rustc"
    CARGO_BIN="${RUST_ROOT}/bin/cargo"
    BENCHMARK_DIR="${PERF_WORK_DIR}/benchmark"
    RIPGREP_DIR="${BENCHMARK_DIR}/ripgrep-${RIPGREP_VERSION}"
    CARGO_HOME_DIR="${CARGO_HOME:-${PERF_WORK_DIR}/cargo-home}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE CARGO_HOME_DIR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${BENCHMARK_DIR}" "${CARGO_HOME_DIR}"
}

require_rust_tools() {
    local command_name package
    local packages=()

    for command_name in sha256sum tar xz sed find awk stat date tee curl python3 sudo; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            sha256sum|tee|stat|date) package="coreutils" ;;
            tar) package="tar" ;;
            xz) package="xz" ;;
            sed) package="sed" ;;
            find) package="findutils" ;;
            awk) package="gawk" ;;
            curl) package="curl" ;;
            python3) package="python3" ;;
            sudo) package="sudo" ;;
        esac
        log "missing required Rust test command: ${command_name}"
        packages+=("${package}")
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log "ERROR: dnf is required to install Rust test prerequisites"
        return 30
    fi

    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log "installing missing Rust test packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log "ERROR: sudo is required to install Rust test prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log "ERROR: failed to install Rust test prerequisites"
        return 30
    fi

    for command_name in sha256sum tar xz sed find awk stat date tee curl python3; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "ERROR: required Rust test command remains unavailable: ${command_name}"
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

fetch_rust_archive() {
    local archive_path
    local actual_sha256
    local archive_name
    local archive_sha256
    local local_archive_path
    local download_url

    # Every supported artifact is declared with its official archive name and
    # SHA-256 checksum from the official channel manifest.  Adding a version
    # means adding its two architecture entries here; the download,
    # installation, and lifecycle logic stays unchanged.
    case "${SOFTWARE_VERSION}:${EXPECTED_ARCH}" in
        1.98.1:x86_64)
            archive_name="rust-1.98.1-x86_64-unknown-linux-gnu.tar.xz"
            archive_sha256="5326b36c53de11d148c8f8dab6553a3d1006c2cfd32123683073fad3c302605b"
            ;;
        1.98.1:aarch64)
            archive_name="rust-1.98.1-aarch64-unknown-linux-gnu.tar.xz"
            archive_sha256="0b514a8cc1cbcd939bff0f151661fe58b6ea5c7a7f645a5098c69e32e8c1e0a2"
            ;;
        *)
            log "ERROR: no verified Rust release is declared for ${SOFTWARE_VERSION} on ${EXPECTED_ARCH}"
            return 10
            ;;
    esac

    local_archive_path="/home/runner/software/rust/${archive_name}"
    if [[ -f "${local_archive_path}" ]]; then
        archive_path="${local_archive_path}"
        log "using local Rust archive ${archive_path}" >&2
    elif [[ -s "${PERF_WORK_DIR}/${archive_name}" ]]; then
        archive_path="${PERF_WORK_DIR}/${archive_name}"
        log "using cached Rust archive ${archive_path}" >&2
    else
        archive_path="${PERF_WORK_DIR}/${archive_name}"
        download_url="${RUST_RELEASE_BASE}/${archive_name}"
        download_archive "${archive_path}" "${download_url}" || return 30
    fi

    actual_sha256="$(sha256sum "${archive_path}")"
    actual_sha256="${actual_sha256%% *}"
    if [[ "${actual_sha256}" != "${archive_sha256}" ]]; then
        log "ERROR: Rust archive checksum mismatch: expected ${archive_sha256}, got ${actual_sha256}" >&2
        return 30
    fi
    printf '%s\n' "${archive_path}"
}

install_rust_archive() {
    local archive="$1"
    local staging_dir

    rm -rf "${RUST_ROOT}"
    log "extracting ${archive}"
    staging_dir="${PERF_WORK_DIR}/rust-unpack"
    rm -rf "${staging_dir}"
    mkdir -p "${staging_dir}"
    if ! tar -xJf "${archive}" -C "${staging_dir}"; then
        rm -rf "${staging_dir}"
        log "ERROR: failed to extract ${archive}"
        return 40
    fi
    local unpacked_dir
    unpacked_dir="$(find "${staging_dir}" -mindepth 1 -maxdepth 1 -type d -print -quit)"
    if [[ -z "${unpacked_dir}" || ! -f "${unpacked_dir}/install.sh" ]]; then
        rm -rf "${staging_dir}"
        log "ERROR: the Rust archive does not contain the official install.sh"
        return 40
    fi

    # Install through the tarball's own install.sh into the task-private
    # prefix.  rust-docs are not needed for benchmarking; ldconfig is
    # disabled so nothing outside the work directory is touched.
    if ! (cd "${unpacked_dir}" && ./install.sh \
            --prefix="${RUST_ROOT}" \
            --without=rust-docs \
            --disable-ldconfig); then
        rm -rf "${staging_dir}"
        log "ERROR: the official Rust install.sh failed"
        return 40
    fi
    rm -rf "${staging_dir}"
}

fetch_ripgrep_crate() {
    local crate_name="ripgrep-${RIPGREP_VERSION}.crate"
    local crate_path="${BENCHMARK_DIR}/${crate_name}"
    local actual_sha256

    if [[ -f "/home/runner/software/rust/${crate_name}" ]]; then
        log "using local ripgrep archive /home/runner/software/rust/${crate_name}" >&2
        cp "/home/runner/software/rust/${crate_name}" "${crate_path}" || return 30
    elif [[ ! -s "${crate_path}" ]]; then
        download_archive "${crate_path}" "${RIPGREP_CRATE_BASE}/${crate_name}" || return 30
    else
        log "using cached ripgrep archive ${crate_path}" >&2
    fi

    actual_sha256="$(sha256sum "${crate_path}")"
    actual_sha256="${actual_sha256%% *}"
    if [[ "${actual_sha256}" != "${RIPGREP_SHA256}" ]]; then
        log "ERROR: ripgrep crate checksum mismatch: expected ${RIPGREP_SHA256}, got ${actual_sha256}" >&2
        return 30
    fi
    printf '%s\n' "${crate_path}"
}

cargo_env() {
    # The deployed toolchain's cargo must find its rustc; dependencies are
    # cached in the task-private CARGO_HOME.  A configured PERF_PROXY is
    # propagated to cargo's HTTP layer for the dependency pre-fetch.
    export CARGO_HOME="${CARGO_HOME_DIR}"
    export PATH="${RUST_ROOT}/bin:${PATH}"
    if [[ -n "${PERF_PROXY:-}" ]]; then
        export http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}"
    fi
}

stage_benchmark_workload() {
    local crate_path
    local corpus_size

    crate_path="$(fetch_ripgrep_crate)" || return $?
    rm -rf "${RIPGREP_DIR}"
    log "extracting ${crate_path}"
    mkdir -p "${RIPGREP_DIR}"
    if ! tar -xzf "${crate_path}" -C "${RIPGREP_DIR}" --strip-components=1; then
        log "ERROR: failed to extract ${crate_path}"
        return 40
    fi
    if [[ ! -f "${RIPGREP_DIR}/Cargo.lock" ]]; then
        log "ERROR: the pinned ripgrep release has no Cargo.lock"
        return 40
    fi

    cargo_env
    log "pre-fetching ripgrep ${RIPGREP_VERSION} locked dependencies"
    if ! (cd "${RIPGREP_DIR}" && cargo fetch --locked --quiet); then
        log "ERROR: failed to pre-fetch the locked ripgrep dependencies"
        return 40
    fi

    log "generating deterministic search corpora"
    for corpus_size in "${RUST_SEARCH_CORPUS_SIZES_MIB[@]}"; do
        if [[ ! -s "${BENCHMARK_DIR}/corpus-${corpus_size}mib.txt" ]]; then
            if ! python3 "${SCRIPT_DIR}/scripts/gen_corpus.py" \
                "${corpus_size}" "${BENCHMARK_DIR}/corpus-${corpus_size}mib.txt" \
                "${RUST_SEARCH_NEEDLE}"; then
                log "ERROR: failed to generate the ${corpus_size} MiB corpus"
                return 40
            fi
        fi
    done
    log "ripgrep ${RIPGREP_VERSION} workload is staged"
}

build_profile_binary() {
    local profile="$1"
    local target_dir="$2"
    local -a cargo_args=(--locked --offline --quiet)

    case "${profile}" in
        dev)
            (cd "${RIPGREP_DIR}" && CARGO_TARGET_DIR="${target_dir}" \
                cargo build "${cargo_args[@]}")
            ;;
        release)
            (cd "${RIPGREP_DIR}" && CARGO_TARGET_DIR="${target_dir}" \
                cargo build --release "${cargo_args[@]}")
            ;;
        opt-level=s)
            (cd "${RIPGREP_DIR}" && CARGO_TARGET_DIR="${target_dir}" \
                RUSTFLAGS="-C opt-level=s" cargo build --release "${cargo_args[@]}")
            ;;
        *)
            log "ERROR: unknown compile profile: ${profile}"
            return 10
            ;;
    esac
}

profile_binary_path() {
    local profile="$1"
    local target_dir="$2"

    case "${profile}" in
        dev) printf '%s\n' "${target_dir}/debug/rg" ;;
        *) printf '%s\n' "${target_dir}/release/rg" ;;
    esac
}

build_rust() {
    local archive_path
    local actual_version
    local runner_architecture

    initialize_runtime || return $?
    runner_architecture="$(uname -m)"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    require_rust_tools || return $?
    if [[ -e "${RUST_ROOT}" ]]; then
        log "ERROR: build output is not clean under ${RUST_ROOT}"
        return 20
    fi

    archive_path="$(fetch_rust_archive)" || return $?
    install_rust_archive "${archive_path}" || return $?

    if [[ ! -x "${RUSTC_BIN}" || ! -x "${CARGO_BIN}" ]]; then
        log "ERROR: rustc/cargo binaries not found after installation"
        return 40
    fi
    actual_version="$("${RUSTC_BIN}" --version 2>/dev/null | sed -nE 's/^rustc ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -n 1)"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: installed rustc is ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "rust ${actual_version} installed from the official prebuilt tarball"
}

start_rust_runtime() {
    local smoke_dir
    local smoke_binary

    initialize_runtime || return $?
    if [[ ! -x "${RUSTC_BIN}" ]]; then
        log "ERROR: Rust is not installed (run build first)"
        return 40
    fi

    stage_benchmark_workload || return $?

    # Smoke-build the release profile and smoke-run the produced binary so
    # the test stage only ever times the fully verified toolchain and
    # workload pair.
    smoke_dir="${BENCHMARK_DIR}/smoke"
    rm -rf "${smoke_dir}"
    log "smoke-building ripgrep release profile"
    if ! build_profile_binary release "${smoke_dir}"; then
        rm -rf "${smoke_dir}"
        return 40
    fi
    smoke_binary="$(profile_binary_path release "${smoke_dir}")"
    if [[ ! -x "${smoke_binary}" ]]; then
        rm -rf "${smoke_dir}"
        log "ERROR: ripgrep smoke build did not produce the rg binary"
        return 40
    fi
    if ! "${smoke_binary}" --version >/dev/null 2>&1; then
        rm -rf "${smoke_dir}"
        log "ERROR: ripgrep smoke run failed"
        return 40
    fi
    if ! "${smoke_binary}" -c --no-mmap -j1 --no-ignore --no-messages \
        "${RUST_SEARCH_NEEDLE}" "${BENCHMARK_DIR}/corpus-64mib.txt" >/dev/null; then
        rm -rf "${smoke_dir}"
        log "ERROR: ripgrep smoke search failed"
        return 40
    fi
    rm -rf "${smoke_dir}"
    log "Rust benchmark runtime is ready"
}

run_compile_scenario() {
    local profile
    local profile_slug
    local round
    local target_dir
    local binary_path
    local round_start
    local round_end
    local round_seconds

    for profile in "${RUST_COMPILE_PROFILES[@]}"; do
        if [[ "${profile}" == "opt-level=s" ]]; then
            profile_slug="opts"
        else
            profile_slug="${profile}"
        fi
        for round in $(seq 1 "${RUST_ROUNDS}"); do
            target_dir="${BENCHMARK_DIR}/target-${profile_slug}-r${round}"
            rm -rf "${target_dir}"
            round_start="$(date +%s.%N)"
            if ! build_profile_binary "${profile}" "${target_dir}"; then
                log "ERROR: compile round failed: ${profile} round ${round}"
                return 50
            fi
            round_end="$(date +%s.%N)"
            binary_path="$(profile_binary_path "${profile}" "${target_dir}")"
            if [[ ! -x "${binary_path}" ]]; then
                log "ERROR: compile round produced no rg binary: ${profile} round ${round}"
                return 50
            fi
            round_seconds="$(awk -v s="${round_start}" -v e="${round_end}" 'BEGIN { printf "%.3f", e - s }')"
            printf 'result scenario=compile workload=%s round=%d wall_seconds=%s artifact_bytes=%s\n' \
                "${profile}" "${round}" "${round_seconds}" "$(stat -c %s "${binary_path}")"
            rm -rf "${target_dir}"
        done
    done
}

run_search_scenario() {
    local release_dir="${BENCHMARK_DIR}/target-release-final"
    local rg_binary
    local corpus_size
    local corpus_path
    local round
    local round_start
    local round_end
    local round_seconds
    local binary_bytes

    rm -rf "${release_dir}"
    log "building the release binary for the search scenario"
    if ! build_profile_binary release "${release_dir}"; then
        log "ERROR: failed to build the release binary for the search scenario"
        return 50
    fi
    rg_binary="$(profile_binary_path release "${release_dir}")"
    if [[ ! -x "${rg_binary}" ]]; then
        log "ERROR: the release build did not produce the rg binary"
        return 50
    fi
    binary_bytes="$(stat -c %s "${rg_binary}")"

    for corpus_size in "${RUST_SEARCH_CORPUS_SIZES_MIB[@]}"; do
        corpus_path="${BENCHMARK_DIR}/corpus-${corpus_size}mib.txt"
        if [[ ! -s "${corpus_path}" ]]; then
            log "ERROR: corpus is missing: ${corpus_path}"
            return 50
        fi
        for round in $(seq 1 "${RUST_ROUNDS}"); do
            round_start="$(date +%s.%N)"
            if ! "${rg_binary}" -c --no-mmap -j1 --no-ignore --no-messages \
                "${RUST_SEARCH_NEEDLE}" "${corpus_path}" >/dev/null; then
                log "ERROR: search round failed: corpus ${corpus_size} MiB round ${round}"
                return 50
            fi
            round_end="$(date +%s.%N)"
            round_seconds="$(awk -v s="${round_start}" -v e="${round_end}" 'BEGIN { printf "%.3f", e - s }')"
            printf 'result scenario=search workload=%d round=%d wall_seconds=%s artifact_bytes=%s\n' \
                "${corpus_size}" "${round}" "${round_seconds}" "${binary_bytes}"
        done
    done
    rm -rf "${release_dir}"
}

run_rust_benchmarks() {
    local raw_output

    initialize_runtime || return $?
    require_rust_tools || return $?
    if [[ ! -x "${RUSTC_BIN}" ]]; then
        log "ERROR: Rust is not installed (run build first)"
        return 50
    fi
    if [[ ! -f "${RIPGREP_DIR}/Cargo.lock" ]]; then
        log "ERROR: ripgrep workload is not staged (run start first)"
        return 50
    fi
    cargo_env

    raw_output="${RESULTS_DIR}/ripgrep_benchmark_raw.log"
    export RUST_ROUNDS
    log "running the ripgrep ${RIPGREP_VERSION} compile and search scenarios with rust ${SOFTWARE_VERSION}"
    if ! {
        run_compile_scenario
        run_search_scenario
    } 2>&1 | tee "${raw_output}"; then
        log "ERROR: ripgrep benchmark scenarios failed (see ${raw_output})"
        return 50
    fi
    python3 "${SCRIPT_DIR}/scripts/collect_rust_benchmark.py" \
        "${raw_output}" "${RESULTS_DIR}/results.json" || return 50
    log "ripgrep benchmark scenarios completed"
}

stop_rust_runtime() {
    initialize_runtime || return $?
    log "Rust benchmark has no background service to stop"
    if [[ -d "${BENCHMARK_DIR}" ]]; then
        rm -rf "${BENCHMARK_DIR}"
        log "ripgrep benchmark data removed from ${BENCHMARK_DIR}"
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
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/rust/local-* || \
          "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/rust" ]]; then
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
        stop_rust_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_rust_standalone() {
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
        if build_rust; then
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
        if start_rust_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_rust_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_rust_runtime; then
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

Install the official Rust prebuilt toolchain and run the ripgrep
compile-throughput and search benchmarks as a standalone performance
evaluation. Results default to results/<version>/<run-id>/ inside this
directory.

Options:
  --version VERSION       Rust version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR, RUST_ROUNDS
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
    run_rust_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
