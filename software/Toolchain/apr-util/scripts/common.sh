#!/usr/bin/env bash
# Shared definitions for the APR-util 1.6.5 base64 performance case.
#
# The case builds APR 1.7.5 and APR-util 1.6.5 from the pinned upstream
# release tarballs, then measures the public base64 codec
# (apr_base64_encode_binary / apr_base64_decode_binary) over pinned
# deterministic payloads.  It also runs the upstream portable test program
# (test/testall), which covers the remaining APR-util functionality that does
# not need an external service.  Every scenario is one child process, one
# warm-up plus PERF_REPS independent repetitions, and the wall clock and peak
# RSS of that process are recorded verbatim.
set -euo pipefail

SOFTWARE_NAME="${SOFTWARE_NAME:-apr-util}"
CATEGORY_NAME="${CATEGORY_NAME:-Toolchain}"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.6.5}"
EXPECTED_ARCH="${EXPECTED_ARCH:-}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-local-$(date -u +%Y%m%dT%H%M%SZ)-$$}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPTS_DIR}/.." && pwd)"

# ---------------------------------------------------------------- upstream ----
# APR is a hard build dependency of APR-util: the pinned APR release is built
# first and APR-util is configured with --with-apr pointing at that prefix.
APR_SOURCE_NAME="apr-1.7.5.tar.bz2"
APR_SOURCE_SHA256="cd0f5d52b9ab1704c72160c5ee3ed5d3d4ca2df4a7f8ab564e3cb352b67232f2"
APR_SOURCE_SIZE=898264
APR_UTIL_SOURCE_NAME="apr-util-1.6.5.tar.bz2"
APR_UTIL_SOURCE_SHA256="96de1dd6f6a0476d2d2e7964926d8c1ddc3bb0e210e1b1812d3ba5a454a392e2"
APR_UTIL_SOURCE_SIZE=442045
PERF_APR_UTIL_OFFLINE_DIR="${PERF_APR_UTIL_OFFLINE_DIR:-/home/runner/software/apr-util}"
PERF_APR_UTIL_MIRROR="${PERF_APR_UTIL_MIRROR:-}"

APR_SOURCE_URLS=(
    "${PERF_APR_UTIL_OFFLINE_DIR}/${APR_SOURCE_NAME}"
    "https://archive.apache.org/dist/apr/${APR_SOURCE_NAME}"
    "https://dlcdn.apache.org/apr/${APR_SOURCE_NAME}"
)
APR_UTIL_SOURCE_URLS=(
    "${PERF_APR_UTIL_OFFLINE_DIR}/${APR_UTIL_SOURCE_NAME}"
    "https://archive.apache.org/dist/apr/${APR_UTIL_SOURCE_NAME}"
    "https://dlcdn.apache.org/apr/${APR_UTIL_SOURCE_NAME}"
)

# Both libraries are built as static libraries only; APR-util's optional
# external services (LDAP, MySQL, PostgreSQL, SQLite, OpenSSL/crypto, gdbm,
# ndbm, Berkeley DB) are disabled so the build is hermetic and identical on
# both architectures.  Expat cannot be disabled in APR-util 1.6.5; the copy
# bundled in the release tarball is used.  The in-tree `sdbm` DBM is the
# default and is what upstream testdbm exercises.
APR_UTIL_BUILD_JOBS="${PERF_APR_UTIL_BUILD_JOBS:-8}"
APR_UTIL_OPTIMIZATION="${PERF_APR_UTIL_OPTIMIZATION:--O2 -DNDEBUG}"
APR_UTIL_HARNESS_CFLAGS="-O2 -std=c99 -Wall -Wextra"
APR_UTIL_CONFIGURE_OPTIONS=(
    --disable-shared
    --enable-static
    --without-ldap
    --without-mysql
    --without-pgsql
    --without-sqlite3
    --without-sqlite2
    --without-odbc
    --without-oracle
    --without-openssl
    --without-crypto
    --without-gdbm
    --without-ndbm
    --without-berkeley-db
)
APR_UTIL_EXPECT_TESTALL_MODULES=19

# ------------------------------------------------------------- measurement ----
APR_UTIL_REPS="${PERF_REPS:-5}"
APR_UTIL_WARMUPS=1

# ---------------------------------------------------------------- fixtures ----
APR_UTIL_PAYLOAD_64B_BYTES=64
APR_UTIL_PAYLOAD_1KIB_BYTES=1024
APR_UTIL_PAYLOAD_64KIB_BYTES=65536
APR_UTIL_PAYLOAD_1MIB_BYTES=1048576
APR_UTIL_PAYLOAD_64B_SHA256=cb42edf62dc3629773106aa8b0797a977b2cb1decab8d4ba267200c25c42c9de
APR_UTIL_PAYLOAD_1KIB_SHA256=ad6b5ef2138fee2f4e3804413a59bb6630de5618c199da967c414b0f84989193
APR_UTIL_PAYLOAD_64KIB_SHA256=9d86408ce481394c9eb77a3869803d473e602024a0d94a1ffa0995bda0251f15
APR_UTIL_PAYLOAD_1MIB_SHA256=bccd1a6e54881be19a93a1afa5ed4e369f8ca6b870d429cd45d0153617e179d0

# Loop counts are calibrated so each scenario runs for a few hundred
# milliseconds on the reference x86_64 host; the same counts are used on both
# architectures so the per-call overhead is part of the measurement.
APR_UTIL_LOOPS_ENCODE_64B=20000000
APR_UTIL_LOOPS_ENCODE_1KIB=1000000
APR_UTIL_LOOPS_ENCODE_64KIB=24000
APR_UTIL_LOOPS_ENCODE_1MIB=1200
APR_UTIL_LOOPS_DECODE_64B=16000000
APR_UTIL_LOOPS_DECODE_1KIB=800000
APR_UTIL_LOOPS_DECODE_64KIB=15000
APR_UTIL_LOOPS_DECODE_1MIB=800

# ---------------------------------------------------------------- scenarios ---
APR_UTIL_SCENARIOS=(
    base64_encode_64b
    base64_encode_1kib
    base64_encode_64kib
    base64_encode_1mib
    base64_decode_64b
    base64_decode_1kib
    base64_decode_64kib
    base64_decode_1mib
    upstream_testall
)

APR_UTIL_SCENARIO_GROUP=(
    "base64_encode_64b:base64_encode"
    "base64_encode_1kib:base64_encode"
    "base64_encode_64kib:base64_encode"
    "base64_encode_1mib:base64_encode"
    "base64_decode_64b:base64_decode"
    "base64_decode_1kib:base64_decode"
    "base64_decode_64kib:base64_decode"
    "base64_decode_1mib:base64_decode"
    "upstream_testall:upstream_suite"
)

# ------------------------------------------------------------------ runtime ---
APR_SRC_DIR=""
APR_UTIL_SRC_DIR=""
APR_PREFIX=""
APR_SOURCE_ARCHIVE=""
APR_UTIL_SOURCE_ARCHIVE=""
APR_UTIL_BENCH_BIN=""
APR_UTIL_TESTALL_BIN=""
APR_UTIL_TESTALL_CWD=""
APR_UTIL_NETNS_PREP=""
APR_UTIL_FIXTURES_DIR=""
APR_UTIL_FIXTURE_MANIFEST=""
APR_UTIL_RUNS_DIR=""
APR_UTIL_STATE_DIR=""
APR_UTIL_OFFLINE_DIR_MODE_FILE=""

log_message() {
    printf '[apr-util] [%s] %s\n' "$(date -u '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

fail_message() {
    printf '[apr-util] [%s] ERROR: %s\n' "$(date -u '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

normalize_architecture() {
    case "$(uname -m)" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) uname -m ;;
    esac
}

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) return 0 ;;
        *) fail_message "unsupported variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

validate_reps() {
    if ! [[ "${APR_UTIL_REPS}" =~ ^[1-9][0-9]*$ ]]; then
        fail_message "PERF_REPS must be a positive integer, got ${APR_UTIL_REPS}"
        return 10
    fi
    if [[ "${APR_UTIL_REPS}" -lt 5 ]]; then
        log_message "WARNING: PERF_REPS=${APR_UTIL_REPS} is a local link-validation value; formal evidence requires >= 5"
    fi
}

validate_version() {
    if [[ -z "${SOFTWARE_VERSION}" ]]; then
        fail_message "software version is required"
        return 10
    fi
    if [[ "${SOFTWARE_VERSION}" != "1.6.5" ]]; then
        fail_message "unsupported APR-util version: ${SOFTWARE_VERSION} (this case pins 1.6.5)"
        return 10
    fi
}

configure_runtime_paths() {
    if [[ -z "${EXPECTED_ARCH}" ]]; then
        EXPECTED_ARCH="$(normalize_architecture)"
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${CASE_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${CASE_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/${SOFTWARE_NAME}/${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi

    APR_SRC_DIR="${PERF_WORK_DIR}/apr-src"
    APR_UTIL_SRC_DIR="${PERF_WORK_DIR}/apr-util-src"
    APR_PREFIX="${PERF_WORK_DIR}/apr-install"
    APR_SOURCE_ARCHIVE="${PERF_WORK_DIR}/downloads/${APR_SOURCE_NAME}"
    APR_UTIL_SOURCE_ARCHIVE="${PERF_WORK_DIR}/downloads/${APR_UTIL_SOURCE_NAME}"
    APR_UTIL_BENCH_BIN="${PERF_WORK_DIR}/apr-util-bench/base64_bench"
    APR_UTIL_TESTALL_BIN="${APR_UTIL_SRC_DIR}/test/testall"
    APR_UTIL_TESTALL_CWD="${APR_UTIL_SRC_DIR}/test"
    APR_UTIL_NETNS_PREP="${PERF_WORK_DIR}/apr-util-bench/netns_loopback_up"
    APR_UTIL_FIXTURES_DIR="${PERF_WORK_DIR}/fixtures"
    APR_UTIL_FIXTURE_MANIFEST="${APR_UTIL_FIXTURES_DIR}/payloads.json"
    APR_UTIL_RUNS_DIR="${RESULTS_DIR}/runs"
    APR_UTIL_STATE_DIR="${PERF_WORK_DIR}/state"
    APR_UTIL_OFFLINE_DIR_MODE_FILE="${APR_UTIL_STATE_DIR}/measurement-network-mode.txt"

    export SOFTWARE_NAME CATEGORY_NAME SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    export PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export APR_SRC_DIR APR_UTIL_SRC_DIR APR_PREFIX APR_SOURCE_ARCHIVE APR_UTIL_SOURCE_ARCHIVE
    export APR_UTIL_BENCH_BIN APR_UTIL_TESTALL_BIN APR_UTIL_TESTALL_CWD
    export APR_UTIL_NETNS_PREP APR_UTIL_FIXTURES_DIR APR_UTIL_FIXTURE_MANIFEST
    export APR_UTIL_RUNS_DIR APR_UTIL_STATE_DIR APR_UTIL_OFFLINE_DIR_MODE_FILE
    export APR_UTIL_REPS APR_UTIL_WARMUPS APR_UTIL_BUILD_JOBS APR_UTIL_OPTIMIZATION
    export APR_UTIL_HARNESS_CFLAGS APR_UTIL_EXPECT_TESTALL_MODULES
    export APR_SOURCE_NAME APR_SOURCE_SHA256 APR_SOURCE_SIZE
    export APR_UTIL_SOURCE_NAME APR_UTIL_SOURCE_SHA256 APR_UTIL_SOURCE_SIZE
    export APR_UTIL_PAYLOAD_64B_BYTES APR_UTIL_PAYLOAD_1KIB_BYTES
    export APR_UTIL_PAYLOAD_64KIB_BYTES APR_UTIL_PAYLOAD_1MIB_BYTES
    export APR_UTIL_PAYLOAD_64B_SHA256 APR_UTIL_PAYLOAD_1KIB_SHA256
    export APR_UTIL_PAYLOAD_64KIB_SHA256 APR_UTIL_PAYLOAD_1MIB_SHA256
    export APR_UTIL_LOOPS_ENCODE_64B APR_UTIL_LOOPS_ENCODE_1KIB
    export APR_UTIL_LOOPS_ENCODE_64KIB APR_UTIL_LOOPS_ENCODE_1MIB
    export APR_UTIL_LOOPS_DECODE_64B APR_UTIL_LOOPS_DECODE_1KIB
    export APR_UTIL_LOOPS_DECODE_64KIB APR_UTIL_LOOPS_DECODE_1MIB
    return 0
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${APR_UTIL_RUNS_DIR}" "${PERF_WORK_DIR}" \
        "${APR_UTIL_STATE_DIR}" "${APR_UTIL_FIXTURES_DIR}" \
        "${PERF_WORK_DIR}/apr-util-bench" "${TMPDIR}" || {
        fail_message "failed to create the work directories under ${PERF_WORK_DIR}"
        return 20
    }
    return 0
}

# -------------------------------------------------------------------- tools ---
require_commands() {
    local packages=()
    command -v cc >/dev/null 2>&1 || packages+=(gcc)
    command -v make >/dev/null 2>&1 || packages+=(make)
    command -v tar >/dev/null 2>&1 || packages+=(tar)
    command -v bzip2 >/dev/null 2>&1 || packages+=(bzip2)
    command -v sha256sum >/dev/null 2>&1 || packages+=(coreutils)
    command -v python3 >/dev/null 2>&1 || packages+=(python3)
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        packages+=(curl)
    fi
    # APR-util 1.6.5 always compiles its XML support and needs expat headers;
    # the dedicated runner only ships the runtime library.
    if [[ ! -f /usr/include/expat.h ]] && [[ ! -f /usr/include/aarch64-linux-gnu/expat.h ]] && [[ ! -f /usr/include/x86_64-linux-gnu/expat.h ]]; then
        if command -v dnf >/dev/null 2>&1; then
            packages+=(expat-devel)
        elif command -v apt-get >/dev/null 2>&1; then
            packages+=(libexpat1-dev)
        fi
    fi
    if (( ${#packages[@]} == 0 )); then
        return 0
    fi
    local package_manager=""
    if command -v dnf >/dev/null 2>&1; then
        package_manager=dnf
        log_message "installing build dependencies with dnf: ${packages[*]}"
        dnf install -y "${packages[@]}" >"${APR_UTIL_STATE_DIR}/deps-install.log" 2>&1 || {
            fail_message "dnf install failed, see ${APR_UTIL_STATE_DIR}/deps-install.log"
            return 30
        }
    elif command -v apt-get >/dev/null 2>&1; then
        package_manager=apt-get
        log_message "installing build dependencies with apt-get: ${packages[*]}"
        DEBIAN_FRONTEND=noninteractive apt-get update -qq \
            >"${APR_UTIL_STATE_DIR}/deps-install.log" 2>&1 || true
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${packages[@]}" \
            >>"${APR_UTIL_STATE_DIR}/deps-install.log" 2>&1 || {
            fail_message "apt-get install failed, see ${APR_UTIL_STATE_DIR}/deps-install.log"
            return 30
        }
    else
        fail_message "no supported package manager (dnf/apt-get) found for: ${packages[*]}"
        return 30
    fi
    local missing=()
    local command_name
    for command_name in cc make tar bzip2 sha256sum python3; do
        command -v "${command_name}" >/dev/null 2>&1 || missing+=("${command_name}")
    done
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        missing+=("curl|wget")
    fi
    if (( ${#missing[@]} > 0 )); then
        fail_message "required commands are still missing after ${package_manager}: ${missing[*]}"
        return 30
    fi
    return 0
}

download_file() {
    local url="$1"
    local destination="$2"
    mkdir -p "$(dirname "${destination}")" || return 1
    if command -v curl >/dev/null 2>&1; then
        curl -fSL --retry 2 --retry-delay 3 --connect-timeout 15 --max-time 300 \
            -o "${destination}.part" "${url}" && mv "${destination}.part" "${destination}"
        return $?
    fi
    if command -v wget >/dev/null 2>&1; then
        wget -q --tries=2 --timeout=30 -O "${destination}.part" "${url}" && \
            mv "${destination}.part" "${destination}"
        return $?
    fi
    return 1
}

# fetch_source <archive-name> <sha256> <size> <destination> <url>...
fetch_source() {
    local source_name="$1"
    local expected_sha="$2"
    local expected_size="$3"
    local destination="$4"
    shift 4
    local mirror_prefix=""
    local candidate=""
    local -a candidates=()
    if [[ -n "${PERF_APR_UTIL_MIRROR}" ]]; then
        mirror_prefix="${PERF_APR_UTIL_MIRROR%/}"
    fi
    mkdir -p "$(dirname "${destination}")" || {
        fail_message "cannot create the download directory for ${destination}"
        return 30
    }
    if [[ -s "${destination}" ]] && \
        [[ "$(sha256sum "${destination}" | awk '{print $1}')" == "${expected_sha}" ]] && \
        [[ "$(stat -c '%s' "${destination}")" == "${expected_size}" ]]; then
        log_message "reusing verified source archive: ${destination}"
        return 0
    fi
    for candidate in "$@"; do
        if [[ -n "${mirror_prefix}" && "${candidate}" != "${PERF_APR_UTIL_OFFLINE_DIR}"* ]]; then
            candidates+=("${mirror_prefix%/}/${candidate#*://*/}")
        else
            candidates+=("${candidate}")
        fi
    done
    local index=0
    for candidate in "${candidates[@]}"; do
        index=$((index + 1))
        rm -f "${destination}"
        if [[ -f "${candidate}" ]]; then
            log_message "using pre-placed offline archive (${index}): ${candidate}"
            cp -f "${candidate}" "${destination}" || true
        else
            log_message "downloading ${source_name} (${index}): ${candidate}"
            download_file "${candidate}" "${destination}" || {
                log_message "download failed (${index}): ${candidate}"
                rm -f "${destination}"
                continue
            }
        fi
        local actual_size
        actual_size="$(stat -c '%s' "${destination}" 2>/dev/null || echo 0)"
        if [[ "${actual_size}" != "${expected_size}" ]]; then
            fail_message "source size mismatch for ${candidate}: ${actual_size} != ${expected_size}"
            rm -f "${destination}"
            continue
        fi
        local actual_sha
        actual_sha="$(sha256sum "${destination}" | awk '{print $1}')"
        if [[ "${actual_sha}" != "${expected_sha}" ]]; then
            fail_message "source SHA-256 mismatch for ${candidate}: ${actual_sha}"
            rm -f "${destination}"
            continue
        fi
        log_message "verified ${source_name} (${actual_sha})"
        return 0
    done
    fail_message "unable to obtain ${source_name} from any candidate"
    fail_message "candidates tried:"
    for candidate in "${candidates[@]}"; do
        fail_message "  ${candidate}"
    done
    return 30
}

fetch_sources() {
    fetch_source "${APR_SOURCE_NAME}" "${APR_SOURCE_SHA256}" "${APR_SOURCE_SIZE}" \
        "${APR_SOURCE_ARCHIVE}" "${APR_SOURCE_URLS[@]}" || return $?
    fetch_source "${APR_UTIL_SOURCE_NAME}" "${APR_UTIL_SOURCE_SHA256}" "${APR_UTIL_SOURCE_SIZE}" \
        "${APR_UTIL_SOURCE_ARCHIVE}" "${APR_UTIL_SOURCE_URLS[@]}" || return $?
    return 0
}

# ---------------------------------------------------------------- scenarios ---
scenario_group() {
    local mapping
    for mapping in "${APR_UTIL_SCENARIO_GROUP[@]}"; do
        if [[ "${mapping%%:*}" == "$1" ]]; then
            printf '%s\n' "${mapping##*:}"
            return 0
        fi
    done
    printf 'base64_encode\n'
}

# Payload size key for the base64 scenarios (64b, 1kib, 64kib, 1mib).
payload_key_for() {
    case "$1" in
        *_64b) printf '64b\n' ;;
        *_1kib) printf '1kib\n' ;;
        *_64kib) printf '64kib\n' ;;
        *_1mib) printf '1mib\n' ;;
        *) return 1 ;;
    esac
}

payload_bytes_for() {
    case "$(payload_key_for "$1")" in
        64b) printf '%s\n' "${APR_UTIL_PAYLOAD_64B_BYTES}" ;;
        1kib) printf '%s\n' "${APR_UTIL_PAYLOAD_1KIB_BYTES}" ;;
        64kib) printf '%s\n' "${APR_UTIL_PAYLOAD_64KIB_BYTES}" ;;
        1mib) printf '%s\n' "${APR_UTIL_PAYLOAD_1MIB_BYTES}" ;;
        *) return 1 ;;
    esac
}

payload_sha256_for() {
    case "$(payload_key_for "$1")" in
        64b) printf '%s\n' "${APR_UTIL_PAYLOAD_64B_SHA256}" ;;
        1kib) printf '%s\n' "${APR_UTIL_PAYLOAD_1KIB_SHA256}" ;;
        64kib) printf '%s\n' "${APR_UTIL_PAYLOAD_64KIB_SHA256}" ;;
        1mib) printf '%s\n' "${APR_UTIL_PAYLOAD_1MIB_SHA256}" ;;
        *) return 1 ;;
    esac
}

payload_file_for() {
    case "$(payload_key_for "$1")" in
        64b) printf 'payload_64.bin\n' ;;
        1kib) printf 'payload_1024.bin\n' ;;
        64kib) printf 'payload_65536.bin\n' ;;
        1mib) printf 'payload_1048576.bin\n' ;;
        *) return 1 ;;
    esac
}

loops_for() {
    case "$1" in
        base64_encode_64b) printf '%s\n' "${APR_UTIL_LOOPS_ENCODE_64B}" ;;
        base64_encode_1kib) printf '%s\n' "${APR_UTIL_LOOPS_ENCODE_1KIB}" ;;
        base64_encode_64kib) printf '%s\n' "${APR_UTIL_LOOPS_ENCODE_64KIB}" ;;
        base64_encode_1mib) printf '%s\n' "${APR_UTIL_LOOPS_ENCODE_1MIB}" ;;
        base64_decode_64b) printf '%s\n' "${APR_UTIL_LOOPS_DECODE_64B}" ;;
        base64_decode_1kib) printf '%s\n' "${APR_UTIL_LOOPS_DECODE_1KIB}" ;;
        base64_decode_64kib) printf '%s\n' "${APR_UTIL_LOOPS_DECODE_64KIB}" ;;
        base64_decode_1mib) printf '%s\n' "${APR_UTIL_LOOPS_DECODE_1MIB}" ;;
        *) return 1 ;;
    esac
}

# Populates SCENARIO_CMD (array) for the measured command invocation.
scenario_argv() {
    local scenario="$1"
    SCENARIO_CMD=()
    case "${scenario}" in
        base64_encode_*|base64_decode_*)
            local mode="${scenario#base64_}"
            mode="${mode%%_*}"
            local fixture
            fixture="$(payload_file_for "${scenario}")" || return 1
            SCENARIO_CMD=("${APR_UTIL_BENCH_BIN}" "${mode}"
                --payload "${APR_UTIL_FIXTURES_DIR}/${fixture}"
                --loops "$(loops_for "${scenario}")")
            ;;
        upstream_testall)
            SCENARIO_CMD=("${APR_UTIL_TESTALL_BIN}")
            ;;
        *)
            fail_message "unknown scenario: ${scenario}"
            return 1
            ;;
    esac
    return 0
}

scenario_cwd() {
    case "$1" in
        upstream_testall) printf '%s\n' "${APR_UTIL_TESTALL_CWD}" ;;
        *) printf '\n' ;;
    esac
}

compiler_identity() {
    if command -v cc >/dev/null 2>&1; then
        cc --version 2>/dev/null | head -1
    else
        printf 'unknown\n'
    fi
}
