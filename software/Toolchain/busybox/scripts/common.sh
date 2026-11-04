#!/usr/bin/env bash
# Shared definitions for the BusyBox 1.38.0 applet performance case.
#
# The case builds BusyBox from the pinned upstream source archive and measures a
# fixed set of single-applet workloads over deterministic corpora: hashing
# (sha256sum), numeric sorting (sort -n), pattern counting (grep -c), in-place
# substitution (sed), record aggregation (awk), deflate compression (gzip -6),
# gzip-compressed archiving (tar -czf) and field extraction (cut). Each scenario
# is one child process, one warm-up plus PERF_REPS independent repetitions, and
# the wall clock and peak RSS of that process are recorded verbatim.
set -euo pipefail

SOFTWARE_NAME="${SOFTWARE_NAME:-busybox}"
CATEGORY_NAME="${CATEGORY_NAME:-Toolchain}"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.38.0}"
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
BUSYBOX_SOURCE_NAME="busybox-1.38.0.tar.bz2"
BUSYBOX_SOURCE_SHA256="34f9ea6ff8636f2c9241153b9114eefa9e65674a45318ae1ef95bb5f31c53bb2"
BUSYBOX_SOURCE_SIZE=2695723
PERF_BUSYBOX_OFFLINE_DIR="${PERF_BUSYBOX_OFFLINE_DIR:-/home/runner/software/busybox}"
PERF_BUSYBOX_MIRROR="${PERF_BUSYBOX_MIRROR:-}"

BUSYBOX_SOURCE_URLS=(
    "${PERF_BUSYBOX_OFFLINE_DIR}/${BUSYBOX_SOURCE_NAME}"
    "https://busybox.net/downloads/${BUSYBOX_SOURCE_NAME}"
    "http://busybox.net/downloads/${BUSYBOX_SOURCE_NAME}"
    "https://www.busybox.net/downloads/${BUSYBOX_SOURCE_NAME}"
)

# Build configuration is the upstream default configuration for this release;
# defconfig is a static file in the source tree, so both architectures build the
# same applet set with the same code paths.
BUSYBOX_BUILD_JOBS="${PERF_BUSYBOX_BUILD_JOBS:-8}"
BUSYBOX_CFLAGS="-O2 -DNDEBUG"
BUSYBOX_REQUIRED_APPLETS=(sort sha256sum grep tar gzip sed awk cut)

# ------------------------------------------------------------- measurement ----
BUSYBOX_REPS="${PERF_REPS:-5}"
BUSYBOX_WARMUPS=1
BUSYBOX_CORPUS_SHA256SUM_ARGS=8

# ---------------------------------------------------------------- fixtures ----
BUSYBOX_FIXTURE_CORPUS_LINES=900000
BUSYBOX_FIXTURE_CORPUS_BYTES=53259531
BUSYBOX_FIXTURE_CORPUS_SHA256="bc19c8c081631054f1b9eeb00e7aaa216ca3f48464dd300adf19180f44d9ccc6"
BUSYBOX_FIXTURE_GZIP_LINES=400000
BUSYBOX_FIXTURE_GZIP_BYTES=23667205
BUSYBOX_FIXTURE_GZIP_SHA256="5f13276f7e51af288bb732bf84e1c5bd5f7d5279ba3b66716f5e9f709eb28280"
BUSYBOX_FIXTURE_SORT_LINES=1000000
BUSYBOX_FIXTURE_SORT_BYTES=14000000
BUSYBOX_FIXTURE_SORT_SHA256="8b1700b34099bc29eb860d4fc031bc4809d5518615da40ca12a4d0ec15e2ab3f"
BUSYBOX_FIXTURE_SORT_MAX_KEY=99999457
BUSYBOX_FIXTURE_TAR_FILES=16000
BUSYBOX_FIXTURE_TAR_ENTRIES=16001
BUSYBOX_FIXTURE_TAR_BYTES=56000000
BUSYBOX_FIXTURE_TAR_CONTENT_SHA256="db57e877c451b5c02265f5536b38605e47e80e76f6781d3adabbd4c18fd9997d"

# Expected workload results (pinned; the parser cross-checks every check line).
BUSYBOX_EXPECT_GREP_MATCHES=87913
BUSYBOX_EXPECT_SED_SHA256="f95546057b16fc3117f1405029399152b1616790db86ba38ce8f748cd3ccc09f"
BUSYBOX_EXPECT_CUT_SHA256="fc5000daaba27a9190e8ddd2379d5c0f5f6a57de75328ce03c32e35e4a0ec1ab"
BUSYBOX_EXPECT_AWK_SUM=52359531

# ---------------------------------------------------------------- scenarios ---
BUSYBOX_SCENARIOS=(
    sha256sum_hash
    sort_numeric
    grep_count
    sed_substitute
    awk_aggregate
    gzip_compress
    tar_gzip_create
    cut_fields
)

BUSYBOX_SCENARIO_GROUP=(
    "sha256sum_hash:hash"
    "sort_numeric:sort"
    "grep_count:text_scan"
    "sed_substitute:text_transform"
    "awk_aggregate:text_transform"
    "gzip_compress:compression"
    "tar_gzip_create:compression"
    "cut_fields:text_transform"
)

# ------------------------------------------------------------------ runtime ---
BUSYBOX_INSTALL_DIR=""
BUSYBOX_SRC_DIR=""
BUSYBOX_SOURCE_ARCHIVE=""
BUSYBOX_BIN=""
BUSYBOX_FIXTURES_DIR=""
BUSYBOX_FIXTURE_MANIFEST=""
BUSYBOX_RUNS_DIR=""
BUSYBOX_STATE_DIR=""
BUSYBOX_OUT_DIR=""

log_message() {
    printf '[busybox] [%s] %s\n' "$(date -u '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

fail_message() {
    printf '[busybox] [%s] ERROR: %s\n' "$(date -u '+%Y-%m-%d %H:%M:%S')" "$*" >&2
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
    if ! [[ "${BUSYBOX_REPS}" =~ ^[1-9][0-9]*$ ]]; then
        fail_message "PERF_REPS must be a positive integer, got ${BUSYBOX_REPS}"
        return 10
    fi
    if [[ "${BUSYBOX_REPS}" -lt 5 ]]; then
        log_message "WARNING: PERF_REPS=${BUSYBOX_REPS} is a local link-validation value; formal evidence requires >= 5"
    fi
}

validate_version() {
    if [[ -z "${SOFTWARE_VERSION}" ]]; then
        fail_message "software version is required"
        return 10
    fi
    if [[ "${SOFTWARE_VERSION}" != "1.38.0" ]]; then
        fail_message "unsupported BusyBox version: ${SOFTWARE_VERSION} (this case pins 1.38.0)"
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

    BUSYBOX_INSTALL_DIR="${PERF_WORK_DIR}/busybox-install"
    BUSYBOX_SRC_DIR="${PERF_WORK_DIR}/busybox-src"
    BUSYBOX_SOURCE_ARCHIVE="${PERF_WORK_DIR}/downloads/${BUSYBOX_SOURCE_NAME}"
    BUSYBOX_BIN="${BUSYBOX_INSTALL_DIR}/bin/busybox"
    BUSYBOX_FIXTURES_DIR="${PERF_WORK_DIR}/fixtures"
    BUSYBOX_FIXTURE_MANIFEST="${BUSYBOX_FIXTURES_DIR}/fixtures.json"
    BUSYBOX_RUNS_DIR="${RESULTS_DIR}/runs"
    BUSYBOX_STATE_DIR="${PERF_WORK_DIR}/state"
    BUSYBOX_OUT_DIR="${PERF_WORK_DIR}/out"
    BUSYBOX_OFFLINE_DIR_MODE_FILE="${BUSYBOX_STATE_DIR}/measurement-network-mode.txt"

    export SOFTWARE_NAME CATEGORY_NAME SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    export PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export BUSYBOX_INSTALL_DIR BUSYBOX_SRC_DIR BUSYBOX_SOURCE_ARCHIVE BUSYBOX_BIN
    export BUSYBOX_FIXTURES_DIR BUSYBOX_FIXTURE_MANIFEST BUSYBOX_RUNS_DIR
    export BUSYBOX_STATE_DIR BUSYBOX_OUT_DIR BUSYBOX_OFFLINE_DIR_MODE_FILE
    export BUSYBOX_REPS BUSYBOX_WARMUPS BUSYBOX_BUILD_JOBS BUSYBOX_CFLAGS
    export BUSYBOX_SOURCE_NAME BUSYBOX_SOURCE_SHA256 BUSYBOX_SOURCE_SIZE
    export BUSYBOX_FIXTURE_CORPUS_LINES BUSYBOX_FIXTURE_CORPUS_BYTES
    export BUSYBOX_FIXTURE_CORPUS_SHA256 BUSYBOX_FIXTURE_GZIP_LINES
    export BUSYBOX_FIXTURE_GZIP_BYTES BUSYBOX_FIXTURE_GZIP_SHA256
    export BUSYBOX_FIXTURE_SORT_LINES BUSYBOX_FIXTURE_SORT_BYTES
    export BUSYBOX_FIXTURE_SORT_SHA256 BUSYBOX_FIXTURE_SORT_MAX_KEY
    export BUSYBOX_FIXTURE_TAR_FILES BUSYBOX_FIXTURE_TAR_ENTRIES
    export BUSYBOX_FIXTURE_TAR_BYTES BUSYBOX_FIXTURE_TAR_CONTENT_SHA256
    export BUSYBOX_EXPECT_GREP_MATCHES BUSYBOX_EXPECT_SED_SHA256
    export BUSYBOX_EXPECT_CUT_SHA256 BUSYBOX_EXPECT_AWK_SUM
    export BUSYBOX_CORPUS_SHA256SUM_ARGS
    return 0
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${BUSYBOX_RUNS_DIR}" "${PERF_WORK_DIR}" \
        "${BUSYBOX_STATE_DIR}" "${BUSYBOX_FIXTURES_DIR}" "${BUSYBOX_OUT_DIR}" \
        "${TMPDIR}" || {
        fail_message "failed to create the work directories under ${PERF_WORK_DIR}"
        return 20
    }
    return 0
}

# -------------------------------------------------------------------- tools ---
require_commands() {
    local packages=()
    local package_manager=""
    command -v cc >/dev/null 2>&1 || packages+=(gcc)
    command -v make >/dev/null 2>&1 || packages+=(make)
    command -v tar >/dev/null 2>&1 || packages+=(tar)
    command -v bzip2 >/dev/null 2>&1 || packages+=(bzip2)
    command -v sha256sum >/dev/null 2>&1 || packages+=(coreutils)
    command -v python3 >/dev/null 2>&1 || packages+=(python3)
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        packages+=(curl)
    fi
    if (( ${#packages[@]} == 0 )); then
        return 0
    fi
    if command -v dnf >/dev/null 2>&1; then
        package_manager=dnf
        log_message "installing build dependencies with dnf: ${packages[*]}"
        dnf install -y "${packages[@]}" >"${BUSYBOX_STATE_DIR}/deps-install.log" 2>&1 || {
            fail_message "dnf install failed, see ${BUSYBOX_STATE_DIR}/deps-install.log"
            return 30
        }
    elif command -v apt-get >/dev/null 2>&1; then
        package_manager=apt-get
        log_message "installing build dependencies with apt-get: ${packages[*]}"
        DEBIAN_FRONTEND=noninteractive apt-get update -qq \
            >"${BUSYBOX_STATE_DIR}/deps-install.log" 2>&1 || true
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${packages[@]}" \
            >>"${BUSYBOX_STATE_DIR}/deps-install.log" 2>&1 || {
            fail_message "apt-get install failed, see ${BUSYBOX_STATE_DIR}/deps-install.log"
            return 30
        }
    else
        fail_message "no supported package manager (dnf/apt-get) found for: ${packages[*]}"
        return 30
    fi
    # Post-install self-check: a package manager that reports success but leaves
    # a required command missing must fail the build, not the later stages.
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

fetch_source_archive() {
    local candidate="" mirror_prefix=""
    local -a candidates=()
    if [[ -n "${PERF_BUSYBOX_MIRROR}" ]]; then
        mirror_prefix="${PERF_BUSYBOX_MIRROR%/}"
    fi
    mkdir -p "$(dirname "${BUSYBOX_SOURCE_ARCHIVE}")" || {
        fail_message "cannot create the download directory for ${BUSYBOX_SOURCE_ARCHIVE}"
        return 30
    }
    if [[ -s "${BUSYBOX_SOURCE_ARCHIVE}" ]] && \
        [[ "$(sha256sum "${BUSYBOX_SOURCE_ARCHIVE}" | awk '{print $1}')" == "${BUSYBOX_SOURCE_SHA256}" ]]; then
        log_message "reusing verified source archive: ${BUSYBOX_SOURCE_ARCHIVE}"
        return 0
    fi
    for candidate in "${BUSYBOX_SOURCE_URLS[@]}"; do
        if [[ -n "${mirror_prefix}" && "${candidate}" != "${PERF_BUSYBOX_OFFLINE_DIR}"* ]]; then
            candidates+=("${mirror_prefix%/}/${candidate#*://*/}")
        else
            candidates+=("${candidate}")
        fi
    done
    local index=0
    for candidate in "${candidates[@]}"; do
        index=$((index + 1))
        rm -f "${BUSYBOX_SOURCE_ARCHIVE}"
        if [[ -f "${candidate}" ]]; then
            log_message "using pre-placed offline archive (${index}): ${candidate}"
            cp -f "${candidate}" "${BUSYBOX_SOURCE_ARCHIVE}" || true
        else
            log_message "downloading BusyBox source (${index}): ${candidate}"
            download_file "${candidate}" "${BUSYBOX_SOURCE_ARCHIVE}" || {
                log_message "download failed (${index}): ${candidate}"
                rm -f "${BUSYBOX_SOURCE_ARCHIVE}"
                continue
            }
        fi
        local actual_size
        actual_size="$(stat -c '%s' "${BUSYBOX_SOURCE_ARCHIVE}" 2>/dev/null || echo 0)"
        if [[ "${actual_size}" != "${BUSYBOX_SOURCE_SIZE}" ]]; then
            fail_message "source size mismatch for ${candidate}: ${actual_size} != ${BUSYBOX_SOURCE_SIZE}"
            rm -f "${BUSYBOX_SOURCE_ARCHIVE}"
            continue
        fi
        local actual_sha
        actual_sha="$(sha256sum "${BUSYBOX_SOURCE_ARCHIVE}" | awk '{print $1}')"
        if [[ "${actual_sha}" != "${BUSYBOX_SOURCE_SHA256}" ]]; then
            fail_message "source SHA-256 mismatch for ${candidate}: ${actual_sha}"
            rm -f "${BUSYBOX_SOURCE_ARCHIVE}"
            continue
        fi
        log_message "verified ${BUSYBOX_SOURCE_NAME} (${actual_sha})"
        return 0
    done
    fail_message "unable to obtain ${BUSYBOX_SOURCE_NAME} from any candidate"
    fail_message "candidates tried:"
    for candidate in "${candidates[@]}"; do
        fail_message "  ${candidate}"
    done
    return 30
}

# ---------------------------------------------------------------- scenarios ---
scenario_group() {
    local mapping
    for mapping in "${BUSYBOX_SCENARIO_GROUP[@]}"; do
        if [[ "${mapping%%:*}" == "$1" ]]; then
            printf '%s\n' "${mapping##*:}"
            return 0
        fi
    done
    printf 'applet\n'
}

scenario_command_text() {
    case "$1" in
        sha256sum_hash)
            printf 'busybox sha256sum corpus_text.txt (x%d)\n' "${BUSYBOX_CORPUS_SHA256SUM_ARGS}"
            ;;
        sort_numeric)
            printf 'busybox sort -n sort_input.txt\n'
            ;;
        grep_count)
            printf 'busybox grep -c tag=alpha corpus_text.txt\n'
            ;;
        sed_substitute)
            printf "busybox sed 's/alpha/ALPHA/g;s/beta/BETA/g' corpus_text.txt\n"
            ;;
        awk_aggregate)
            printf "busybox awk '{s+=length($0)} END{print s}' corpus_text.txt\n"
            ;;
        gzip_compress)
            printf 'busybox gzip -6 -c gzip_input.txt\n'
            ;;
        tar_gzip_create)
            printf 'busybox tar -czf ARCHIVE -C tar_tree .\n'
            ;;
        cut_fields)
            printf 'busybox cut -d " " -f 1,3 corpus_text.txt\n'
            ;;
        *)
            printf 'unknown scenario: %s\n' "$1"
            return 1
            ;;
    esac
}

# Sets SCENARIO_CMD (array) and SCENARIO_STDOUT (optional file path suffix).
# BUSYBOX_OUT_DIR is outside the results directory: the large applet outputs are
# only needed for verification and are removed afterwards, while the compact
# verification report stays in runs/<scenario>/.
scenario_argv() {
    local scenario="$1"
    local corpus="${BUSYBOX_FIXTURES_DIR}/corpus_text.txt"
    SCENARIO_CMD=()
    SCENARIO_STDOUT=""
    case "${scenario}" in
        sha256sum_hash)
            SCENARIO_CMD=("${BUSYBOX_BIN}" sha256sum)
            local args=()
            local i
            for ((i = 0; i < BUSYBOX_CORPUS_SHA256SUM_ARGS; i++)); do
                args+=("${corpus}")
            done
            SCENARIO_CMD+=("${args[@]}")
            ;;
        sort_numeric)
            SCENARIO_CMD=("${BUSYBOX_BIN}" sort -n "${BUSYBOX_FIXTURES_DIR}/sort_input.txt")
            SCENARIO_STDOUT="sorted.txt"
            ;;
        grep_count)
            SCENARIO_CMD=("${BUSYBOX_BIN}" grep -c "tag=alpha" "${corpus}")
            ;;
        sed_substitute)
            SCENARIO_CMD=("${BUSYBOX_BIN}" sed "s/alpha/ALPHA/g;s/beta/BETA/g" "${corpus}")
            SCENARIO_STDOUT="sed.txt"
            ;;
        awk_aggregate)
            SCENARIO_CMD=("${BUSYBOX_BIN}" awk '{s+=length($0)} END{print s}' "${corpus}")
            ;;
        gzip_compress)
            SCENARIO_CMD=("${BUSYBOX_BIN}" gzip -6 -c "${BUSYBOX_FIXTURES_DIR}/gzip_input.txt")
            SCENARIO_STDOUT="gzip.gz"
            ;;
        tar_gzip_create)
            SCENARIO_CMD=("${BUSYBOX_BIN}" tar -czf "${BUSYBOX_OUT_DIR}/tar_gzip_create.tar.gz" \
                -C "${BUSYBOX_FIXTURES_DIR}/tar_tree" .)
            SCENARIO_STDOUT=""
            ;;
        cut_fields)
            SCENARIO_CMD=("${BUSYBOX_BIN}" cut -d " " -f 1,3 "${corpus}")
            SCENARIO_STDOUT="cut.txt"
            ;;
        *)
            fail_message "unknown scenario: ${scenario}"
            return 1
            ;;
    esac
    return 0
}

scenario_output_path() {
    local scenario="$1"
    if [[ -n "${SCENARIO_STDOUT}" ]]; then
        printf '%s/%s\n' "${BUSYBOX_OUT_DIR}" "${SCENARIO_STDOUT}"
    elif [[ "${scenario}" == "tar_gzip_create" ]]; then
        printf '%s/tar_gzip_create.tar.gz\n' "${BUSYBOX_OUT_DIR}"
    else
        printf '%s/%s.stdout\n' "${BUSYBOX_OUT_DIR}" "${scenario}"
    fi
}

compiler_identity() {
    # The compiler that actually built BusyBox lives inside the private
    # container; provenance must describe that toolchain.
    busybox_container_exec cc --version 2>/dev/null | head -1 || printf 'unknown\n'
}

fixture_sha256() {
    sha256sum "$1" | awk '{print $1}'
}

# The case directory is mounted read-only into the private container, so the
# generated container block needs its absolute path under the name SCRIPT_DIR.
SCRIPT_DIR="${SCRIPT_DIR:-${CASE_DIR}}"
export SCRIPT_DIR
# BusyBox's offline measurement runs every sample inside a fresh network
# namespace (`unshare -n`), which requires CAP_SYS_ADMIN inside the container.
declare -p BUSYBOX_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || \
    BUSYBOX_CONTAINER_EXTRA_ARGS=(--cap-add=SYS_ADMIN --cap-add=NET_ADMIN)

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
BUSYBOX_IMAGE_ARCHIVE_DIR="${BUSYBOX_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
BUSYBOX_CA_ANCHORS_DIR="${BUSYBOX_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
BUSYBOX_CONTAINER_IMAGE="${BUSYBOX_CONTAINER_IMAGE:-}"
BUSYBOX_CONTAINER_NAME="${BUSYBOX_CONTAINER_NAME:-}"
BUSYBOX_CONTAINER_HOME="${BUSYBOX_CONTAINER_HOME:-}"
declare -p BUSYBOX_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || BUSYBOX_CONTAINER_EXTRA_ARGS=()

busybox_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

busybox_configure_container() {
    local arch
    arch="$(busybox_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${BUSYBOX_CONTAINER_NAME}" ] || BUSYBOX_CONTAINER_NAME="boostkit-busybox-${arch}-${PERF_RUN_ID}"
    [ -n "${BUSYBOX_CONTAINER_HOME}" ] || BUSYBOX_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export BUSYBOX_CONTAINER_NAME BUSYBOX_CONTAINER_HOME
}

busybox_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_busybox_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_busybox_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${BUSYBOX_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_busybox_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(busybox_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${BUSYBOX_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${BUSYBOX_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        busybox_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        busybox_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    BUSYBOX_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${BUSYBOX_CONTAINER_IMAGE}" ] || ! docker image inspect "${BUSYBOX_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${BUSYBOX_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_busybox_container_image_release || return $?
    export BUSYBOX_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${BUSYBOX_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_busybox_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-busybox-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${BUSYBOX_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.busybox.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_busybox_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    busybox_configure_container
    require_busybox_docker || return $?
    if docker container inspect "${BUSYBOX_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${BUSYBOX_CONTAINER_NAME}"
        return 40
    fi
    sweep_busybox_stale_containers || true
    prepare_busybox_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${BUSYBOX_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${BUSYBOX_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${BUSYBOX_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${BUSYBOX_CONTAINER_HOME}" || return 40
    log_message "starting private container ${BUSYBOX_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${BUSYBOX_CONTAINER_NAME}" \
        --label "boostkit.busybox.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${BUSYBOX_CONTAINER_EXTRA_ARGS[@]}" \
        "${BUSYBOX_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${BUSYBOX_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${BUSYBOX_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${BUSYBOX_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${BUSYBOX_CONTAINER_NAME}"
}

check_busybox_container() {
    busybox_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${BUSYBOX_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${BUSYBOX_CONTAINER_NAME}"
        return 40
    }
}

busybox_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    busybox_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${BUSYBOX_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${BUSYBOX_CONTAINER_NAME}" "$@"
}

busybox_container_exec() { busybox_docker_exec '' '' "$@"; }

busybox_container_exec_at() {
    local workdir="$1"
    shift
    busybox_docker_exec "${workdir}" '' "$@"
}

busybox_container_exec_root() { busybox_docker_exec '' root "$@"; }

busybox_container_exec_root_at() {
    local workdir="$1"
    shift
    busybox_docker_exec "${workdir}" root "$@"
}

remove_busybox_container() {
    busybox_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${BUSYBOX_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.busybox.run-id"}}' "${BUSYBOX_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${BUSYBOX_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${BUSYBOX_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${BUSYBOX_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${BUSYBOX_CONTAINER_NAME}"
}
# >>> container-runtime:end
