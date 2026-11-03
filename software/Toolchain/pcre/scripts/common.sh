#!/usr/bin/env bash
# Shared configuration and helpers for the PCRE 8.45 (PCRE1) performance case.
#
# Architecture neutrality: every value that ends up in the benchmark
# ``parameters`` object is a relative, reproducible constant (iteration counts,
# pattern set identifiers, pinned digests, configure options).  Absolute paths,
# the runner host name, the compiler banner and the network mode are runtime
# context only.  The case therefore submits the same workload signature on
# x86_64 and aarch64, which is what the cross-architecture report pairs on.
set -euo pipefail

# SCRIPT_DIR is the case root (software/Toolchain/pcre).  All shell libraries
# live below it, so every entry point sources scripts/common.sh relatively.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASE_DIR="${SCRIPT_DIR}"

SOFTWARE_NAME="pcre"
CATEGORY_NAME="Toolchain"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-8.45}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# ---------------------------------------------------------------- source ------
# Official PCRE1 8.45 release archive.  pcre.org stopped publishing over ftp
# after the project moved to GitHub, and sourceforge.net is unreachable from the
# dedicated runner network, so the long-standing exim.org mirror, the pcre.org
# TLS host and the SourceForge redirect are all listed; every candidate is
# verified against the same pinned SHA-256 before use.
PCRE_SOURCE_NAME="pcre-${SOFTWARE_VERSION}.tar.gz"
PCRE_SOURCE_SHA256="4e6ce03e0336e8b4a3d6c2b70b1c5e18590a5673a98186da90d4f33c23defc09"
PCRE_SOURCE_SIZE=2096552
PCRE_OFFLINE_DIR="${PERF_PCRE_OFFLINE_DIR:-/home/runner/software/pcre}"
PCRE_SOURCE_URLS=(
    "${PCRE_OFFLINE_DIR}/${PCRE_SOURCE_NAME}"
    "https://ftp.exim.org/pub/pcre/${PCRE_SOURCE_NAME}"
    "https://sourceforge.net/projects/pcre/files/pcre/${SOFTWARE_VERSION}/${PCRE_SOURCE_NAME}/download"
    "https://downloads.sourceforge.net/project/pcre/pcre/${SOFTWARE_VERSION}/${PCRE_SOURCE_NAME}"
    "https://master.dl.sourceforge.net/project/pcre/pcre/${SOFTWARE_VERSION}/${PCRE_SOURCE_NAME}?viasf=1"
)
# Optional mirror prefix for restricted networks (for example a local file
# server); it is prepended to each non-offline candidate when set.
PERF_PCRE_MIRROR="${PERF_PCRE_MIRROR:-}"

# ---------------------------------------------------------------- build -------
# One fixed configuration for every architecture.  JIT is compiled in because
# the delivery scope compares the interpreter loop with the JIT-compiled loop;
# UTF-8 and Unicode properties are required by the UTF scenario; the readline /
# libedit and pcregrep compression dependencies are disabled so that the built
# artefacts depend only on the pinned source archive and the system C library.
PCRE_CONFIGURE_OPTIONS=(
    --enable-utf
    --enable-unicode-properties
    --enable-jit
    --disable-shared
    --enable-static
    --disable-pcretest-libreadline
    --disable-pcretest-libedit
    --enable-pcre8
    --disable-pcre16
    --disable-pcre32
)
PCRE_CFLAGS="-O2 -DNDEBUG"
PCRE_BUILD_JOBS="${PERF_PCRE_BUILD_JOBS:-8}"
PCRE_MAKE_TARGETS=(all install)

# ------------------------------------------------------------ measurement ----
PCRE_REPS="${PERF_REPS:-5}"
PCRE_WARMUPS=1
# Fixed iteration counts.  They are constants of the workload, not of the
# machine: each scenario is sized so that one measurement takes roughly 1.5-4 s
# on the x86_64 development host and scales with the CPU on aarch64.
PCRE_PCRETEST_LITERAL_ITERS=300000
PCRE_PCRETEST_BACKTRACK_ITERS=600
PCRE_PCRETEST_UTF8_ITERS=1200000
PCRE_PCRETEST_DFA_ITERS=300000
PCRE_BENCH_LITERAL_ITERS=10000000
PCRE_BENCH_BACKTRACK_ITERS=600
PCRE_BENCH_UTF8_ITERS=12000000
PCRE_BENCH_DFA_ITERS=5000000
PCRE_BENCH_JIT_ITERS=60000000
PCRE_BENCH_COMPILE_ITERS=3000000

# Fixed upstream RunTest subset: every 8-bit-library test that is meaningful for
# this build configuration (tests 3/13 are excluded by upstream itself; 17-26
# cover the 16/32-bit libraries that this case does not build).  The parser
# requires at least PCRE_RUNTEST_MIN_OK "OK" lines and zero failures, because
# upstream skips a test when the optional feature it exercises is unavailable
# (lower bound + strict failure detection, never an exact count).
PCRE_RUNTEST_TESTS=(1 2 4 5 6 7 8 9 10 11 12 14 15 16)
PCRE_RUNTEST_MIN_OK="${PCRE_RUNTEST_MIN_OK:-30}"

# Fixed fixture digests.  They are produced by scripts/fixtures/
# generate_fixtures.py from deterministic rules and verified by the start stage
# before any measurement; a mismatch aborts the run instead of measuring
# different input than the other architecture.
PCRE_FIXTURE_LITERAL_SHA256="47d7ac545b3a5b052a8ff30391b29f757e02ae8bc6cfb86dd94fc0454f9c5260"
PCRE_FIXTURE_BACKTRACK_SHA256="dda0f0d0e80395cd0a535d79fb6fd0d22b1f3d843b55ae8d8e914d56642bed46"
PCRE_FIXTURE_UTF8_SHA256="49b9895ec5b47ecc36e1980af67e30bc08540381b5c060cba8e2f8af7246eb66"
PCRE_FIXTURE_DFA_SHA256="e284e13bc16c8bde4e7a5d494287a79e9d9da8360dcbcc29e63b96b7aa8a4e19"
PCRE_FIXTURE_SCAN_PATTERNS_SHA256="3f067bb24e13505eecc085aef18dfbf0ff4ef519e30f8d286f726746d5b735be"
PCRE_FIXTURE_SCAN_CORPUS_SHA256="1a4ad1797740481f4643fe08302911e872ca95994f7376f738b9b32052db458c"
PCRE_SCAN_CORPUS_BYTES=57499392
PCRE_SCAN_PATTERNS=8
PCRE_SCAN_MATCHES_TOTAL=725100
PCRE_SCAN_MATCHES=(49892 50029 175259 199638 261 99935 50068 100018)

# Scenario execution order.  The authoritative metric extraction lives in
# scripts/results/parse_benchmark.py; this list only drives execution.
PCRE_SCENARIOS=(
    pcretest_timing_literal
    pcretest_timing_backtrack
    pcretest_timing_utf8
    pcretest_dfa
    upstream_runtest
    pcre_exec_literal
    pcre_exec_backtrack
    pcre_exec_utf8
    pcre_exec_dfa
    pcre_exec_jit
    pcre_compile
    pcregrep_scan
)

# --------------------------------------------------------------- runtime ------
PCRE_INSTALL_DIR=""
PCRE_SRC_DIR=""
PCRE_BENCH_DIR=""
PCRE_BENCH_BIN=""
PCRE_FIXTURES_DIR=""
PCRE_FIXTURE_MANIFEST=""
PCRE_RUNS_DIR=""
PCRE_SOURCE_ARCHIVE=""
PCRE_OFFLINE_DIR_MODE_FILE=""
PCRE_STATE_DIR=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[pcre] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
}

fail_message() {
    printf '[pcre] [%s] ERROR: %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*" >&2
}

normalize_architecture() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) return 0 ;;
        *)
            fail_message "unsupported variant: ${PERF_VARIANT} (expected base or optimized)"
            return 10
            ;;
    esac
}

validate_reps() {
    if ! [[ "${PCRE_REPS}" =~ ^[0-9]+$ ]] || [[ "${PCRE_REPS}" -lt 1 ]]; then
        fail_message "PERF_REPS must be a positive integer, got: ${PCRE_REPS}"
        return 10
    fi
    if [[ "${PCRE_REPS}" -gt 50 ]]; then
        fail_message "PERF_REPS is unreasonably large: ${PCRE_REPS}"
        return 10
    fi
    if [[ "${PCRE_REPS}" -lt 5 ]]; then
        log_message "WARNING: PERF_REPS=${PCRE_REPS} is a local link-validation value; formal evidence requires >= 5"
    fi
    return 0
}

validate_version() {
    case "${SOFTWARE_VERSION}" in
        8.45) return 0 ;;
        *)
            fail_message "unsupported PCRE version: ${SOFTWARE_VERSION} (the case pins 8.45)"
            return 10
            ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    validate_reps || return $?
    validate_version || return $?
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        fail_message "PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64) EXPECTED_ARCH="x86_64" ;;
        aarch64|arm64) EXPECTED_ARCH="aarch64" ;;
        *)
            fail_message "unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    local runner_architecture
    runner_architecture="$(normalize_architecture "$(uname -m)")"
    case "${runner_architecture}" in
        x86_64|aarch64) ;;
        *)
            fail_message "unsupported runner architecture: $(uname -m)"
            return 20
            ;;
    esac
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        fail_message "expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${CASE_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${CASE_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        # Standalone entry point: keep the work directory clearly marked as local
        # so that a copy of the case outside the repository can remove only its
        # own directory.  The framework always provides PERF_WORK_DIR.
        PERF_WORK_DIR="/home/runner/boostkit-perf/${SOFTWARE_NAME}/${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi

    PCRE_INSTALL_DIR="${PERF_WORK_DIR}/pcre-install"
    PCRE_SRC_DIR="${PERF_WORK_DIR}/pcre-src"
    PCRE_SOURCE_ARCHIVE="${PERF_WORK_DIR}/downloads/${PCRE_SOURCE_NAME}"
    PCRE_BENCH_DIR="${PERF_WORK_DIR}/pcre-bench"
    PCRE_BENCH_BIN="${PCRE_BENCH_DIR}/pcre_bench"
    PCRE_FIXTURES_DIR="${PERF_WORK_DIR}/fixtures"
    PCRE_FIXTURE_MANIFEST="${PCRE_FIXTURES_DIR}/fixtures.json"
    PCRE_RUNS_DIR="${RESULTS_DIR}/runs"
    PCRE_STATE_DIR="${PERF_WORK_DIR}/state"
    PCRE_OFFLINE_DIR_MODE_FILE="${PCRE_STATE_DIR}/measurement-network-mode.txt"

    export SOFTWARE_NAME CATEGORY_NAME SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    export PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export PCRE_INSTALL_DIR PCRE_SRC_DIR PCRE_SOURCE_ARCHIVE PCRE_BENCH_DIR PCRE_BENCH_BIN
    export PCRE_FIXTURES_DIR PCRE_FIXTURE_MANIFEST PCRE_RUNS_DIR PCRE_STATE_DIR
    export PCRE_OFFLINE_DIR_MODE_FILE PCRE_REPS PCRE_WARMUPS PCRE_BUILD_JOBS
    export PCRE_SOURCE_NAME PCRE_SOURCE_SHA256 PCRE_SOURCE_SIZE PCRE_CFLAGS
    export PCRE_SCAN_CORPUS_BYTES PCRE_SCAN_PATTERNS PCRE_SCAN_MATCHES_TOTAL
    export PCRE_RUNTEST_MIN_OK
    return 0
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PCRE_RUNS_DIR}" "${PERF_WORK_DIR}" \
        "${PCRE_STATE_DIR}" "${PCRE_FIXTURES_DIR}" "${PCRE_BENCH_DIR}" "${TMPDIR}" || {
        fail_message "failed to create the work directories under ${PERF_WORK_DIR}"
        return 20
    }
    return 0
}

# ------------------------------------------------------------------ tools -----
pcre_tool() {
    printf '%s/bin/%s\n' "${PCRE_INSTALL_DIR}" "$1"
}

require_commands() {
    local packages=()
    local package_manager=""
    command -v cc >/dev/null 2>&1 || packages+=(gcc)
    command -v make >/dev/null 2>&1 || packages+=(make)
    command -v tar >/dev/null 2>&1 || packages+=(tar)
    command -v sha256sum >/dev/null 2>&1 || packages+=(coreutils)
    command -v python3 >/dev/null 2>&1 || packages+=(python3)
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        packages+=(curl)
    fi
    if (( ${#packages[@]} == 0 )); then
        return 0
    fi
    if command -v dnf >/dev/null 2>&1; then
        package_manager="dnf"
    elif command -v apt-get >/dev/null 2>&1; then
        package_manager="apt-get"
    else
        fail_message "no supported package manager for: ${packages[*]}"
        return 30
    fi
    log_message "installing build prerequisites (${package_manager}): ${packages[*]}"
    local proxy_options=()
    if [[ -n "${PERF_PROXY:-}" && "${package_manager}" == "dnf" ]]; then
        proxy_options+=("--setopt=proxy=${PERF_PROXY}")
    fi
    if [[ "$(id -u)" -eq 0 ]]; then
        if [[ "${package_manager}" == "dnf" ]]; then
            dnf "${proxy_options[@]}" install -y "${packages[@]}"
        else
            DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
        fi
    else
        if [[ "${package_manager}" == "dnf" ]]; then
            sudo -n dnf "${proxy_options[@]}" install -y "${packages[@]}"
        else
            sudo -n env DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
        fi
    fi || {
        fail_message "failed to install build prerequisites"
        return 30
    }
    # Self-check after installation: a missing compiler or archiver must fail the
    # build stage instead of surfacing later as a confusing benchmark failure.
    local missing=()
    for command_name in cc make tar sha256sum python3; do
        command -v "${command_name}" >/dev/null 2>&1 || missing+=("${command_name}")
    done
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        missing+=(curl)
    fi
    if (( ${#missing[@]} > 0 )); then
        fail_message "build prerequisites still missing: ${missing[*]}"
        return 30
    fi
    return 0
}

download_file() {
    local url="$1" destination="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fSL --retry 2 --retry-delay 3 --connect-timeout 15 --max-time 300 \
            -o "${destination}.part" "${url}" && mv "${destination}.part" "${destination}"
        return $?
    fi
    wget -q -T 20 -t 3 -O "${destination}.part" "${url}" \
        && mv "${destination}.part" "${destination}"
}

fetch_source_archive() {
    local candidate="" mirror_prefix=""
    local -a candidates=()
    if [[ -n "${PERF_PCRE_MIRROR}" ]]; then
        mirror_prefix="${PERF_PCRE_MIRROR%/}"
    fi
    mkdir -p "$(dirname "${PCRE_SOURCE_ARCHIVE}")" || {
        fail_message "cannot create the download directory for ${PCRE_SOURCE_ARCHIVE}"
        return 30
    }
    # Reuse an archive that was already verified in an earlier attempt of this
    # task (the build stage may be re-run after a later stage failed).
    if [[ -s "${PCRE_SOURCE_ARCHIVE}" ]] && \
        [[ "$(sha256sum "${PCRE_SOURCE_ARCHIVE}" | awk '{print $1}')" == "${PCRE_SOURCE_SHA256}" ]]; then
        log_message "reusing verified source archive: ${PCRE_SOURCE_ARCHIVE}"
        return 0
    fi
    for candidate in "${PCRE_SOURCE_URLS[@]}"; do
        if [[ -n "${mirror_prefix}" && "${candidate}" == http* ]]; then
            candidates+=("${mirror_prefix}/${candidate}")
        fi
        candidates+=("${candidate}")
    done
    local attempt=0
    for candidate in "${candidates[@]}"; do
        attempt=$((attempt + 1))
        if [[ -f "${candidate}" ]]; then
            log_message "using pre-placed offline archive (${attempt}): ${candidate}"
            cp -f "${candidate}" "${PCRE_SOURCE_ARCHIVE}"
        else
            log_message "downloading PCRE source (${attempt}): ${candidate}"
            if ! download_file "${candidate}" "${PCRE_SOURCE_ARCHIVE}"; then
                log_message "download failed (${attempt}): ${candidate}"
                rm -f "${PCRE_SOURCE_ARCHIVE}.part"
                continue
            fi
        fi
        local actual_size actual_sha
        actual_size="$(stat -c %s "${PCRE_SOURCE_ARCHIVE}" 2>/dev/null || echo 0)"
        if [[ "${actual_size}" != "${PCRE_SOURCE_SIZE}" ]]; then
            fail_message "source size mismatch for ${candidate}: ${actual_size} != ${PCRE_SOURCE_SIZE}"
            rm -f "${PCRE_SOURCE_ARCHIVE}"
            continue
        fi
        actual_sha="$(sha256sum "${PCRE_SOURCE_ARCHIVE}" | awk '{print $1}')"
        if [[ "${actual_sha}" != "${PCRE_SOURCE_SHA256}" ]]; then
            fail_message "source SHA-256 mismatch for ${candidate}: ${actual_sha}"
            rm -f "${PCRE_SOURCE_ARCHIVE}"
            continue
        fi
        printf '%s\n' "${candidate}" > "${PCRE_STATE_DIR}/source-origin.txt"
        log_message "source archive verified: sha256=${actual_sha} size=${actual_size}"
        return 0
    done
    fail_message "unable to obtain pcre-${SOFTWARE_VERSION}.tar.gz from any candidate"
    fail_message "candidates tried:"
    for candidate in "${candidates[@]}"; do
        fail_message "  ${candidate}"
    done
    return 30
}

# -------------------------------------------------------------- scenarios -----
scenario_group() {
    case "$1" in
        pcretest_timing_literal|pcretest_timing_backtrack|pcretest_timing_utf8|pcretest_dfa)
            printf 'pcretest_upstream\n'
            ;;
        upstream_runtest) printf 'runtest_upstream\n' ;;
        pcre_exec_literal|pcre_exec_backtrack|pcre_exec_utf8|pcre_exec_dfa|pcre_exec_jit|pcre_compile)
            printf 'pcre_exec_matrix\n'
            ;;
        pcregrep_scan) printf 'pcregrep_tool\n' ;;
        *) return 1 ;;
    esac
}

# Human readable, architecture independent description of the measured command;
# the absolute work directory paths appear only in the per-repetition logs.
scenario_command_text() {
    case "$1" in
        pcretest_timing_literal) printf 'pcretest -q -T -t %s pcretest_literal.txt\n' "${PCRE_PCRETEST_LITERAL_ITERS}" ;;
        pcretest_timing_backtrack) printf 'pcretest -q -T -t %s pcretest_backtrack.txt\n' "${PCRE_PCRETEST_BACKTRACK_ITERS}" ;;
        pcretest_timing_utf8) printf 'pcretest -q -T -t %s pcretest_utf8.txt\n' "${PCRE_PCRETEST_UTF8_ITERS}" ;;
        pcretest_dfa) printf 'pcretest -q -T -dfa -TM %s pcretest_dfa.txt\n' "${PCRE_PCRETEST_DFA_ITERS}" ;;
        upstream_runtest) printf './RunTest %s\n' "${PCRE_RUNTEST_TESTS[*]}" ;;
        pcre_exec_literal) printf 'pcre_bench literal %s\n' "${PCRE_BENCH_LITERAL_ITERS}" ;;
        pcre_exec_backtrack) printf 'pcre_bench backtrack %s\n' "${PCRE_BENCH_BACKTRACK_ITERS}" ;;
        pcre_exec_utf8) printf 'pcre_bench utf8 %s\n' "${PCRE_BENCH_UTF8_ITERS}" ;;
        pcre_exec_dfa) printf 'pcre_bench dfa %s\n' "${PCRE_BENCH_DFA_ITERS}" ;;
        pcre_exec_jit) printf 'pcre_bench jit %s\n' "${PCRE_BENCH_JIT_ITERS}" ;;
        pcre_compile) printf 'pcre_bench compile %s\n' "${PCRE_BENCH_COMPILE_ITERS}" ;;
        pcregrep_scan) printf 'pcregrep -c <pattern> scan_corpus.txt x %s patterns\n' "${PCRE_SCAN_PATTERNS}" ;;
        *) return 1 ;;
    esac
}

# Build the measured argv for one scenario into the SCENARIO_CMD array and set
# SCENARIO_WORKDIR.  The function is used by the test stage and by the
# standalone entry point so both execute identical commands.
SCENARIO_CMD=()
SCENARIO_WORKDIR=""
scenario_argv() {
    local scenario="$1"
    SCENARIO_CMD=()
    SCENARIO_WORKDIR="${PERF_WORK_DIR}"
    local pcretest_bin pcregrep_bin
    pcretest_bin="$(pcre_tool pcretest)"
    pcregrep_bin="$(pcre_tool pcregrep)"
    case "${scenario}" in
        pcretest_timing_literal)
            SCENARIO_CMD=("${pcretest_bin}" -q -T -t "${PCRE_PCRETEST_LITERAL_ITERS}" \
                "${PCRE_FIXTURES_DIR}/pcretest_literal.txt")
            ;;
        pcretest_timing_backtrack)
            SCENARIO_CMD=("${pcretest_bin}" -q -T -t "${PCRE_PCRETEST_BACKTRACK_ITERS}" \
                "${PCRE_FIXTURES_DIR}/pcretest_backtrack.txt")
            ;;
        pcretest_timing_utf8)
            SCENARIO_CMD=("${pcretest_bin}" -q -T -t "${PCRE_PCRETEST_UTF8_ITERS}" \
                "${PCRE_FIXTURES_DIR}/pcretest_utf8.txt")
            ;;
        pcretest_dfa)
            SCENARIO_CMD=("${pcretest_bin}" -q -T -dfa -TM "${PCRE_PCRETEST_DFA_ITERS}" \
                "${PCRE_FIXTURES_DIR}/pcretest_dfa.txt")
            ;;
        upstream_runtest)
            SCENARIO_WORKDIR="${PCRE_SRC_DIR}"
            SCENARIO_CMD=(env "PATH=$(dirname "${pcretest_bin}"):${PATH}" \
                ./RunTest "${PCRE_RUNTEST_TESTS[@]}")
            ;;
        pcre_exec_literal) SCENARIO_CMD=("${PCRE_BENCH_BIN}" literal "${PCRE_BENCH_LITERAL_ITERS}") ;;
        pcre_exec_backtrack) SCENARIO_CMD=("${PCRE_BENCH_BIN}" backtrack "${PCRE_BENCH_BACKTRACK_ITERS}") ;;
        pcre_exec_utf8) SCENARIO_CMD=("${PCRE_BENCH_BIN}" utf8 "${PCRE_BENCH_UTF8_ITERS}") ;;
        pcre_exec_dfa) SCENARIO_CMD=("${PCRE_BENCH_BIN}" dfa "${PCRE_BENCH_DFA_ITERS}") ;;
        pcre_exec_jit) SCENARIO_CMD=("${PCRE_BENCH_BIN}" jit "${PCRE_BENCH_JIT_ITERS}") ;;
        pcre_compile) SCENARIO_CMD=("${PCRE_BENCH_BIN}" compile "${PCRE_BENCH_COMPILE_ITERS}") ;;
        pcregrep_scan)
            SCENARIO_CMD=(env "PCREGREP_BIN=${pcregrep_bin}" \
                bash "${SCRIPT_DIR}/scripts/fixtures/pcregrep_scan.sh" \
                "${PCRE_FIXTURES_DIR}" "${PCRE_SCAN_MATCHES_TOTAL}")
            ;;
        *) return 1 ;;
    esac
    return 0
}

fixture_sha256() {
    case "$1" in
        pcretest_literal.txt) printf '%s\n' "${PCRE_FIXTURE_LITERAL_SHA256}" ;;
        pcretest_backtrack.txt) printf '%s\n' "${PCRE_FIXTURE_BACKTRACK_SHA256}" ;;
        pcretest_utf8.txt) printf '%s\n' "${PCRE_FIXTURE_UTF8_SHA256}" ;;
        pcretest_dfa.txt) printf '%s\n' "${PCRE_FIXTURE_DFA_SHA256}" ;;
        scan_patterns.txt) printf '%s\n' "${PCRE_FIXTURE_SCAN_PATTERNS_SHA256}" ;;
        scan_corpus.txt) printf '%s\n' "${PCRE_FIXTURE_SCAN_CORPUS_SHA256}" ;;
        *) return 1 ;;
    esac
}

compiler_identity() {
    local compiler
    # The compiler that actually built PCRE lives inside the private container.
    if ! compiler="$(pcre_container_exec cc --version 2>&1 | head -n 1)"; then
        compiler="unknown"
    fi
    printf '%s\n' "${compiler:-unknown}"
}

# >>> container-runtime:begin
# ==============================================================================
# Private openEuler container runtime
# ==============================================================================
# Every stage of this case runs inside a per-run openEuler 24.03 LTS SP4
# container.  The host keeps only Docker, download/verification tooling, the
# framework and the strict result parser; package installation, source
# extraction, builds, the measured process tree and cleanup happen inside the
# container.  The contract mirrors software/Database/mysql,
# software/Bigdata/ray and software/Others/unixbench.
#
# Generated by adaptation/scripts/add-container-block.py -- do not hand edit the
# region between the markers; change the template instead.
PCRE_IMAGE_ARCHIVE_DIR="${PCRE_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
PCRE_CA_ANCHORS_DIR="${PCRE_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
PCRE_CONTAINER_IMAGE="${PCRE_CONTAINER_IMAGE:-}"
PCRE_CONTAINER_NAME="${PCRE_CONTAINER_NAME:-}"
PCRE_CONTAINER_HOME="${PCRE_CONTAINER_HOME:-}"
declare -p PCRE_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || PCRE_CONTAINER_EXTRA_ARGS=()

pcre_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

pcre_configure_container() {
    local arch
    arch="$(pcre_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${PCRE_CONTAINER_NAME}" ] || PCRE_CONTAINER_NAME="boostkit-pcre-${arch}-${PERF_RUN_ID}"
    [ -n "${PCRE_CONTAINER_HOME}" ] || PCRE_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export PCRE_CONTAINER_NAME PCRE_CONTAINER_HOME
}

pcre_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_pcre_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_pcre_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${PCRE_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_pcre_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(pcre_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${PCRE_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${PCRE_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        pcre_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        pcre_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
    fi
    if [ -s "${checksum}" ]; then
        ( cd "$(dirname "${archive}")" && sha256sum -c "$(basename "${checksum}")" ) >/dev/null || {
            log_message "ERROR: container image checksum mismatch: ${archive}"
            return 30
        }
    else
        log_message "WARNING: no checksum file next to ${archive}; relying on the pinned path only"
    fi
    log_message "loading verified openEuler container image: ${archive}"
    load_output="$(docker load --input "${archive}")" || return 30
    PCRE_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${PCRE_CONTAINER_IMAGE}" ] || ! docker image inspect "${PCRE_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${PCRE_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_pcre_container_image_release || return $?
    export PCRE_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${PCRE_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_pcre_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-pcre-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${PCRE_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.pcre.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_pcre_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    pcre_configure_container
    require_pcre_docker || return $?
    if docker container inspect "${PCRE_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${PCRE_CONTAINER_NAME}"
        return 40
    fi
    sweep_pcre_stale_containers || true
    prepare_pcre_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${PCRE_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${PCRE_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${PCRE_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${PCRE_CONTAINER_HOME}" || return 40
    log_message "starting private container ${PCRE_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${PCRE_CONTAINER_NAME}" \
        --label "boostkit.pcre.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${PCRE_CONTAINER_EXTRA_ARGS[@]}" \
        "${PCRE_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${PCRE_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${PCRE_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${PCRE_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${PCRE_CONTAINER_NAME}"
}

check_pcre_container() {
    pcre_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${PCRE_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${PCRE_CONTAINER_NAME}"
        return 40
    }
}

pcre_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    pcre_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${PCRE_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${PCRE_CONTAINER_NAME}" "$@"
}

pcre_container_exec() { pcre_docker_exec '' '' "$@"; }

pcre_container_exec_at() {
    local workdir="$1"
    shift
    pcre_docker_exec "${workdir}" '' "$@"
}

pcre_container_exec_root() { pcre_docker_exec '' root "$@"; }

pcre_container_exec_root_at() {
    local workdir="$1"
    shift
    pcre_docker_exec "${workdir}" root "$@"
}

remove_pcre_container() {
    pcre_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${PCRE_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.pcre.run-id"}}' "${PCRE_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${PCRE_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${PCRE_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${PCRE_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${PCRE_CONTAINER_NAME}"
}
# >>> container-runtime:end
