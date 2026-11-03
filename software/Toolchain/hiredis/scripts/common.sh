#!/usr/bin/env bash
# Shared definitions for the hiredis 1.5.0 parser/formatting performance case.
#
# The case builds hiredis from the pinned upstream release, then measures the
# streaming RESP reply parser (redisReaderFeed / redisReaderGetReply) over
# deterministic RESP byte streams and the command formatters
# (redisFormatCommand / redisFormatCommandArgv).  It also runs the server-free
# part of the upstream test suite (test.c: allocator hooks, command formatting,
# reply reader, connection error paths).  Every scenario is one child process,
# one warm-up plus PERF_REPS independent repetitions, and the wall clock and peak
# RSS of that process are recorded verbatim.
set -euo pipefail

SOFTWARE_NAME="${SOFTWARE_NAME:-hiredis}"
CATEGORY_NAME="${CATEGORY_NAME:-Toolchain}"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.5.0}"
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
# The shared container runtime mounts the case directory read-only; the entry
# script also exports SCRIPT_DIR, but the framework sources the builders
# directly, so the case root must be available here as well.
SCRIPT_DIR="${SCRIPT_DIR:-${CASE_DIR}}"

# ---------------------------------------------------------------- upstream ----
HIREDIS_SOURCE_NAME="hiredis-1.5.0.tar.gz"
HIREDIS_SOURCE_SHA256="eec7ef8641d221e144a58d5ef8d733c8c75c7fd487097a233aacb4fa33981cfb"
HIREDIS_SOURCE_SIZE=183116
PERF_HIREDIS_OFFLINE_DIR="${PERF_HIREDIS_OFFLINE_DIR:-/home/runner/software/hiredis}"
PERF_HIREDIS_MIRROR="${PERF_HIREDIS_MIRROR:-}"

HIREDIS_SOURCE_URLS=(
    "${SCRIPTS_DIR}/../fixtures/${HIREDIS_SOURCE_NAME}"
    "${PERF_HIREDIS_OFFLINE_DIR}/${HIREDIS_SOURCE_NAME}"
    "https://github.com/redis/hiredis/releases/download/v1.5.0/${HIREDIS_SOURCE_NAME}"
    "https://ghfast.top/https://github.com/redis/hiredis/releases/download/v1.5.0/${HIREDIS_SOURCE_NAME}"
    "https://gh-proxy.com/https://github.com/redis/hiredis/releases/download/v1.5.0/${HIREDIS_SOURCE_NAME}"
)

# Library build: upstream Makefile defaults (static library target only; the
# shared library, examples and SSL support are not needed by this case).
HIREDIS_BUILD_JOBS="${PERF_HIREDIS_BUILD_JOBS:-8}"
HIREDIS_OPTIMIZATION="${PERF_HIREDIS_OPTIMIZATION:--O2 -DNDEBUG}"
HIREDIS_HARNESS_CFLAGS="-O2 -std=c99 -Wall -Wextra"
HIREDIS_EXPECT_LOCAL_TESTS=77

# ------------------------------------------------------------- measurement ----
HIREDIS_REPS="${PERF_REPS:-5}"
HIREDIS_WARMUPS=1

# ---------------------------------------------------------------- fixtures ----
HIREDIS_FIXTURE_PIPELINE_BYTES=2282319
HIREDIS_FIXTURE_PIPELINE_REPLIES=100000
HIREDIS_FIXTURE_BULK_BYTES=16777920
HIREDIS_FIXTURE_BULK_REPLIES=64
HIREDIS_FIXTURE_NESTED_BYTES=1833348
HIREDIS_FIXTURE_NESTED_REPLIES=50000
HIREDIS_FIXTURE_MIXED_BYTES=831880
HIREDIS_FIXTURE_MIXED_REPLIES=100000
HIREDIS_FIXTURE_PIPELINE_SHA256=ac15006e70d22fa44d621389ca0748d1603cc7fece210ed5449d1bcafaf63672
HIREDIS_FIXTURE_BULK_SHA256=35a5fa5f11dfe12937afd029d201e2ba1e42003af1d25b5af8db677fb4db3625
HIREDIS_FIXTURE_NESTED_SHA256=73ec938e1320884f0edbbf9cb013a5942c173ffc33724b09ccb7dca899c2677c
HIREDIS_FIXTURE_MIXED_SHA256=5eba8bd264eacb16a4e9137f2061401a7d56f6dff23d71212916d0c3d7a02c2d
HIREDIS_LOOPS_PIPELINE=128
HIREDIS_LOOPS_BULK=256
HIREDIS_LOOPS_NESTED=32
HIREDIS_LOOPS_MIXED=128
HIREDIS_LOOPS_FRAGMENTED=256
HIREDIS_ITERATIONS_FORMAT_COMMAND=1000000
HIREDIS_ITERATIONS_FORMAT_ARGV=1000000

# ---------------------------------------------------------------- scenarios ---
HIREDIS_SCENARIOS=(
    reader_pipeline
    reader_bulk
    reader_nested
    reader_mixed
    reader_fragmented
    format_command
    format_argv
    upstream_local_suite
)

HIREDIS_SCENARIO_GROUP=(
    "reader_pipeline:resp_reader"
    "reader_bulk:resp_reader"
    "reader_nested:resp_reader"
    "reader_mixed:resp_reader"
    "reader_fragmented:resp_reader"
    "format_command:command_format"
    "format_argv:command_format"
    "upstream_local_suite:upstream_suite"
)

# ------------------------------------------------------------------ runtime ---
HIREDIS_SRC_DIR=""
HIREDIS_SOURCE_ARCHIVE=""
HIREDIS_LIBRARY=""
HIREDIS_BENCH_BIN=""
HIREDIS_UPSTREAM_BIN=""
HIREDIS_FIXTURES_DIR=""
HIREDIS_FIXTURE_MANIFEST=""
HIREDIS_RUNS_DIR=""
HIREDIS_STATE_DIR=""
HIREDIS_OFFLINE_DIR_MODE_FILE=""

log_message() {
    printf '[hiredis] [%s] %s\n' "$(date -u '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

fail_message() {
    printf '[hiredis] [%s] ERROR: %s\n' "$(date -u '+%Y-%m-%d %H:%M:%S')" "$*" >&2
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
    if ! [[ "${HIREDIS_REPS}" =~ ^[1-9][0-9]*$ ]]; then
        fail_message "PERF_REPS must be a positive integer, got ${HIREDIS_REPS}"
        return 10
    fi
    if [[ "${HIREDIS_REPS}" -lt 5 ]]; then
        log_message "WARNING: PERF_REPS=${HIREDIS_REPS} is a local link-validation value; formal evidence requires >= 5"
    fi
}

validate_version() {
    if [[ -z "${SOFTWARE_VERSION}" ]]; then
        fail_message "software version is required"
        return 10
    fi
    if [[ "${SOFTWARE_VERSION}" != "1.5.0" ]]; then
        fail_message "unsupported hiredis version: ${SOFTWARE_VERSION} (this case pins 1.5.0)"
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

    HIREDIS_SRC_DIR="${PERF_WORK_DIR}/hiredis-src"
    HIREDIS_SOURCE_ARCHIVE="${PERF_WORK_DIR}/downloads/${HIREDIS_SOURCE_NAME}"
    HIREDIS_LIBRARY="${PERF_WORK_DIR}/hiredis-src/libhiredis.a"
    HIREDIS_BENCH_BIN="${PERF_WORK_DIR}/hiredis-bench/resp_bench"
    HIREDIS_UPSTREAM_BIN="${PERF_WORK_DIR}/hiredis-bench/upstream_local"
    HIREDIS_NETNS_PREP="${PERF_WORK_DIR}/hiredis-bench/netns_loopback_up"
    HIREDIS_FIXTURES_DIR="${PERF_WORK_DIR}/fixtures"
    HIREDIS_FIXTURE_MANIFEST="${HIREDIS_FIXTURES_DIR}/fixtures.json"
    HIREDIS_RUNS_DIR="${RESULTS_DIR}/runs"
    HIREDIS_STATE_DIR="${PERF_WORK_DIR}/state"
    HIREDIS_OFFLINE_DIR_MODE_FILE="${HIREDIS_STATE_DIR}/measurement-network-mode.txt"

    export SOFTWARE_NAME CATEGORY_NAME SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    export PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export HIREDIS_SRC_DIR HIREDIS_SOURCE_ARCHIVE HIREDIS_LIBRARY
    export HIREDIS_BENCH_BIN HIREDIS_UPSTREAM_BIN HIREDIS_NETNS_PREP HIREDIS_FIXTURES_DIR
    export HIREDIS_FIXTURE_MANIFEST HIREDIS_RUNS_DIR HIREDIS_STATE_DIR
    export HIREDIS_OFFLINE_DIR_MODE_FILE
    export HIREDIS_REPS HIREDIS_WARMUPS HIREDIS_BUILD_JOBS HIREDIS_OPTIMIZATION
    export HIREDIS_HARNESS_CFLAGS HIREDIS_EXPECT_LOCAL_TESTS
    export HIREDIS_SOURCE_NAME HIREDIS_SOURCE_SHA256 HIREDIS_SOURCE_SIZE
    export HIREDIS_FIXTURE_PIPELINE_BYTES HIREDIS_FIXTURE_PIPELINE_REPLIES
    export HIREDIS_FIXTURE_BULK_BYTES HIREDIS_FIXTURE_BULK_REPLIES
    export HIREDIS_FIXTURE_NESTED_BYTES HIREDIS_FIXTURE_NESTED_REPLIES
    export HIREDIS_FIXTURE_MIXED_BYTES HIREDIS_FIXTURE_MIXED_REPLIES
    export HIREDIS_FIXTURE_PIPELINE_SHA256 HIREDIS_FIXTURE_BULK_SHA256
    export HIREDIS_FIXTURE_NESTED_SHA256 HIREDIS_FIXTURE_MIXED_SHA256
    export HIREDIS_LOOPS_PIPELINE HIREDIS_LOOPS_BULK HIREDIS_LOOPS_NESTED
    export HIREDIS_LOOPS_MIXED HIREDIS_LOOPS_FRAGMENTED
    export HIREDIS_ITERATIONS_FORMAT_COMMAND HIREDIS_ITERATIONS_FORMAT_ARGV
    return 0
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${HIREDIS_RUNS_DIR}" "${PERF_WORK_DIR}" \
        "${HIREDIS_STATE_DIR}" "${HIREDIS_FIXTURES_DIR}" \
        "${PERF_WORK_DIR}/hiredis-bench" "${TMPDIR}" || {
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
    command -v sha256sum >/dev/null 2>&1 || packages+=(coreutils)
    command -v python3 >/dev/null 2>&1 || packages+=(python3)
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        packages+=(curl)
    fi
    if (( ${#packages[@]} == 0 )); then
        return 0
    fi
    local package_manager=""
    if command -v dnf >/dev/null 2>&1; then
        package_manager=dnf
        log_message "installing build dependencies with dnf: ${packages[*]}"
        dnf install -y "${packages[@]}" >"${HIREDIS_STATE_DIR}/deps-install.log" 2>&1 || {
            fail_message "dnf install failed, see ${HIREDIS_STATE_DIR}/deps-install.log"
            return 30
        }
    elif command -v apt-get >/dev/null 2>&1; then
        package_manager=apt-get
        log_message "installing build dependencies with apt-get: ${packages[*]}"
        DEBIAN_FRONTEND=noninteractive apt-get update -qq \
            >"${HIREDIS_STATE_DIR}/deps-install.log" 2>&1 || true
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${packages[@]}" \
            >>"${HIREDIS_STATE_DIR}/deps-install.log" 2>&1 || {
            fail_message "apt-get install failed, see ${HIREDIS_STATE_DIR}/deps-install.log"
            return 30
        }
    else
        fail_message "no supported package manager (dnf/apt-get) found for: ${packages[*]}"
        return 30
    fi
    local missing=()
    local command_name
    for command_name in cc make tar sha256sum python3; do
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

fetch_source_archive() {
    local candidate="" mirror_prefix=""
    local -a candidates=()
    if [[ -n "${PERF_HIREDIS_MIRROR}" ]]; then
        mirror_prefix="${PERF_HIREDIS_MIRROR%/}"
    fi
    mkdir -p "$(dirname "${HIREDIS_SOURCE_ARCHIVE}")" || {
        fail_message "cannot create the download directory for ${HIREDIS_SOURCE_ARCHIVE}"
        return 30
    }
    if [[ -s "${HIREDIS_SOURCE_ARCHIVE}" ]] && \
        [[ "$(sha256sum "${HIREDIS_SOURCE_ARCHIVE}" | awk '{print $1}')" == "${HIREDIS_SOURCE_SHA256}" ]]; then
        log_message "reusing verified source archive: ${HIREDIS_SOURCE_ARCHIVE}"
        return 0
    fi
    for candidate in "${HIREDIS_SOURCE_URLS[@]}"; do
        if [[ -n "${mirror_prefix}" && "${candidate}" != "${PERF_HIREDIS_OFFLINE_DIR}"* ]]; then
            candidates+=("${mirror_prefix%/}/${candidate#*://*/}")
        else
            candidates+=("${candidate}")
        fi
    done
    local index=0
    for candidate in "${candidates[@]}"; do
        index=$((index + 1))
        rm -f "${HIREDIS_SOURCE_ARCHIVE}"
        if [[ -f "${candidate}" ]]; then
            log_message "using pre-placed offline archive (${index}): ${candidate}"
            cp -f "${candidate}" "${HIREDIS_SOURCE_ARCHIVE}" || true
        else
            log_message "downloading hiredis source (${index}): ${candidate}"
            download_file "${candidate}" "${HIREDIS_SOURCE_ARCHIVE}" || {
                log_message "download failed (${index}): ${candidate}"
                rm -f "${HIREDIS_SOURCE_ARCHIVE}"
                continue
            }
        fi
        local actual_size
        actual_size="$(stat -c '%s' "${HIREDIS_SOURCE_ARCHIVE}" 2>/dev/null || echo 0)"
        if [[ "${actual_size}" != "${HIREDIS_SOURCE_SIZE}" ]]; then
            fail_message "source size mismatch for ${candidate}: ${actual_size} != ${HIREDIS_SOURCE_SIZE}"
            rm -f "${HIREDIS_SOURCE_ARCHIVE}"
            continue
        fi
        local actual_sha
        actual_sha="$(sha256sum "${HIREDIS_SOURCE_ARCHIVE}" | awk '{print $1}')"
        if [[ "${actual_sha}" != "${HIREDIS_SOURCE_SHA256}" ]]; then
            fail_message "source SHA-256 mismatch for ${candidate}: ${actual_sha}"
            rm -f "${HIREDIS_SOURCE_ARCHIVE}"
            continue
        fi
        log_message "verified ${HIREDIS_SOURCE_NAME} (${actual_sha})"
        return 0
    done
    fail_message "unable to obtain ${HIREDIS_SOURCE_NAME} from any candidate"
    fail_message "candidates tried:"
    for candidate in "${candidates[@]}"; do
        fail_message "  ${candidate}"
    done
    return 30
}

# ---------------------------------------------------------------- scenarios ---
scenario_group() {
    local mapping
    for mapping in "${HIREDIS_SCENARIO_GROUP[@]}"; do
        if [[ "${mapping%%:*}" == "$1" ]]; then
            printf '%s\n' "${mapping##*:}"
            return 0
        fi
    done
    printf 'resp_reader\n'
}

scenario_command_text() {
    case "$1" in
        reader_pipeline)
            printf 'resp_bench reader --mode pipeline --fixture pipeline_get.resp --loops %s\n' "${HIREDIS_LOOPS_PIPELINE}"
            ;;
        reader_bulk)
            printf 'resp_bench reader --mode bulk --fixture bulk_256k.resp --loops %s\n' "${HIREDIS_LOOPS_BULK}"
            ;;
        reader_nested)
            printf 'resp_bench reader --mode nested --fixture nested_arrays.resp --loops %s\n' "${HIREDIS_LOOPS_NESTED}"
            ;;
        reader_mixed)
            printf 'resp_bench reader --mode mixed --fixture mixed_types.resp --loops %s\n' "${HIREDIS_LOOPS_MIXED}"
            ;;
        reader_fragmented)
            printf 'resp_bench reader --mode fragmented --fixture pipeline_get.resp --loops %s\n' "${HIREDIS_LOOPS_FRAGMENTED}"
            ;;
        format_command)
            printf 'resp_bench format --mode format_command --iterations %s\n' "${HIREDIS_ITERATIONS_FORMAT_COMMAND}"
            ;;
        format_argv)
            printf 'resp_bench format --mode format_argv --iterations %s\n' "${HIREDIS_ITERATIONS_FORMAT_ARGV}"
            ;;
        upstream_local_suite)
            printf 'upstream_local (test.c local tests)\n'
            ;;
        *)
            printf 'unknown scenario: %s\n' "$1"
            return 1
            ;;
    esac
}

fixture_name_for() {
    case "$1" in
        reader_pipeline|reader_fragmented) printf 'pipeline_get.resp\n' ;;
        reader_bulk) printf 'bulk_256k.resp\n' ;;
        reader_nested) printf 'nested_arrays.resp\n' ;;
        reader_mixed) printf 'mixed_types.resp\n' ;;
        *) return 1 ;;
    esac
}

fixture_bytes_for() {
    case "$1" in
        reader_pipeline|reader_fragmented) printf '%s\n' "${HIREDIS_FIXTURE_PIPELINE_BYTES}" ;;
        reader_bulk) printf '%s\n' "${HIREDIS_FIXTURE_BULK_BYTES}" ;;
        reader_nested) printf '%s\n' "${HIREDIS_FIXTURE_NESTED_BYTES}" ;;
        reader_mixed) printf '%s\n' "${HIREDIS_FIXTURE_MIXED_BYTES}" ;;
        *) return 1 ;;
    esac
}

fixture_replies_for() {
    case "$1" in
        reader_pipeline|reader_fragmented) printf '%s\n' "${HIREDIS_FIXTURE_PIPELINE_REPLIES}" ;;
        reader_bulk) printf '%s\n' "${HIREDIS_FIXTURE_BULK_REPLIES}" ;;
        reader_nested) printf '%s\n' "${HIREDIS_FIXTURE_NESTED_REPLIES}" ;;
        reader_mixed) printf '%s\n' "${HIREDIS_FIXTURE_MIXED_REPLIES}" ;;
        *) return 1 ;;
    esac
}

loops_for() {
    case "$1" in
        reader_pipeline) printf '%s\n' "${HIREDIS_LOOPS_PIPELINE}" ;;
        reader_bulk) printf '%s\n' "${HIREDIS_LOOPS_BULK}" ;;
        reader_nested) printf '%s\n' "${HIREDIS_LOOPS_NESTED}" ;;
        reader_mixed) printf '%s\n' "${HIREDIS_LOOPS_MIXED}" ;;
        reader_fragmented) printf '%s\n' "${HIREDIS_LOOPS_FRAGMENTED}" ;;
        *) return 1 ;;
    esac
}

iterations_for() {
    case "$1" in
        format_command) printf '%s\n' "${HIREDIS_ITERATIONS_FORMAT_COMMAND}" ;;
        format_argv) printf '%s\n' "${HIREDIS_ITERATIONS_FORMAT_ARGV}" ;;
        *) return 1 ;;
    esac
}

# Populates SCENARIO_CMD (array) for the measured harness invocation.
scenario_argv() {
    local scenario="$1"
    SCENARIO_CMD=()
    case "${scenario}" in
        reader_pipeline|reader_bulk|reader_nested|reader_mixed|reader_fragmented)
            local mode="${scenario#reader_}"
            local fixture
            fixture="$(fixture_name_for "${scenario}")" || return 1
            SCENARIO_CMD=("${HIREDIS_BENCH_BIN}" reader
                --mode "${mode}"
                --fixture "${HIREDIS_FIXTURES_DIR}/${fixture}"
                --loops "$(loops_for "${scenario}")"
                --expected-replies "$(( $(fixture_replies_for "${scenario}") * $(loops_for "${scenario}") ))")
            ;;
        format_command|format_argv)
            local mode="${scenario#format_}"
            SCENARIO_CMD=("${HIREDIS_BENCH_BIN}" format
                --mode "format_${mode}"
                --iterations "$(iterations_for "${scenario}")")
            ;;
        upstream_local_suite)
            SCENARIO_CMD=("${HIREDIS_UPSTREAM_BIN}")
            ;;
        *)
            fail_message "unknown scenario: ${scenario}"
            return 1
            ;;
    esac
    return 0
}

compiler_identity() {
    # The compiler that actually built hiredis lives inside the private
    # container, so provenance records the container toolchain.
    if hiredis_container_exec cc --version >/dev/null 2>&1; then
        hiredis_container_exec cc --version 2>/dev/null | head -1
    else
        printf 'unknown\n'
    fi
}

# The offline measurement mode creates a fresh network namespace with
# ``unshare -n`` (CAP_SYS_ADMIN) and the launcher raises ``lo`` inside it
# (CAP_NET_ADMIN); both are required or the upstream local-test suite cannot
# connect to its own loopback listener.
HIREDIS_CONTAINER_EXTRA_ARGS=(--cap-add=SYS_ADMIN --cap-add=NET_ADMIN)

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
HIREDIS_IMAGE_ARCHIVE_DIR="${HIREDIS_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
HIREDIS_CA_ANCHORS_DIR="${HIREDIS_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
HIREDIS_CONTAINER_IMAGE="${HIREDIS_CONTAINER_IMAGE:-}"
HIREDIS_CONTAINER_NAME="${HIREDIS_CONTAINER_NAME:-}"
HIREDIS_CONTAINER_HOME="${HIREDIS_CONTAINER_HOME:-}"
declare -p HIREDIS_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || HIREDIS_CONTAINER_EXTRA_ARGS=()

hiredis_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

hiredis_configure_container() {
    local arch
    arch="$(hiredis_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${HIREDIS_CONTAINER_NAME}" ] || HIREDIS_CONTAINER_NAME="boostkit-hiredis-${arch}-${PERF_RUN_ID}"
    [ -n "${HIREDIS_CONTAINER_HOME}" ] || HIREDIS_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export HIREDIS_CONTAINER_NAME HIREDIS_CONTAINER_HOME
}

hiredis_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_hiredis_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_hiredis_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${HIREDIS_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_hiredis_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(hiredis_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${HIREDIS_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${HIREDIS_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        hiredis_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        hiredis_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    HIREDIS_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${HIREDIS_CONTAINER_IMAGE}" ] || ! docker image inspect "${HIREDIS_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${HIREDIS_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_hiredis_container_image_release || return $?
    export HIREDIS_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${HIREDIS_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_hiredis_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-hiredis-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${HIREDIS_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.hiredis.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_hiredis_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    hiredis_configure_container
    require_hiredis_docker || return $?
    if docker container inspect "${HIREDIS_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${HIREDIS_CONTAINER_NAME}"
        return 40
    fi
    sweep_hiredis_stale_containers || true
    prepare_hiredis_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${HIREDIS_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${HIREDIS_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${HIREDIS_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${HIREDIS_CONTAINER_HOME}" || return 40
    log_message "starting private container ${HIREDIS_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${HIREDIS_CONTAINER_NAME}" \
        --label "boostkit.hiredis.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${HIREDIS_CONTAINER_EXTRA_ARGS[@]}" \
        "${HIREDIS_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${HIREDIS_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${HIREDIS_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${HIREDIS_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${HIREDIS_CONTAINER_NAME}"
}

check_hiredis_container() {
    hiredis_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${HIREDIS_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${HIREDIS_CONTAINER_NAME}"
        return 40
    }
}

hiredis_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    hiredis_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${HIREDIS_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${HIREDIS_CONTAINER_NAME}" "$@"
}

hiredis_container_exec() { hiredis_docker_exec '' '' "$@"; }

hiredis_container_exec_at() {
    local workdir="$1"
    shift
    hiredis_docker_exec "${workdir}" '' "$@"
}

hiredis_container_exec_root() { hiredis_docker_exec '' root "$@"; }

hiredis_container_exec_root_at() {
    local workdir="$1"
    shift
    hiredis_docker_exec "${workdir}" root "$@"
}

remove_hiredis_container() {
    hiredis_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${HIREDIS_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.hiredis.run-id"}}' "${HIREDIS_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${HIREDIS_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${HIREDIS_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${HIREDIS_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${HIREDIS_CONTAINER_NAME}"
}
# >>> container-runtime:end
