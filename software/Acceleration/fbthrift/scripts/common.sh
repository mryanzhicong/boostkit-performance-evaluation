#!/usr/bin/env bash
# Shared variables and helpers for the fbthrift variant-aware stage split.
#
# fbthrift publishes weekly date tags, not LTS releases, so the pinned source
# archive is the only source of truth for the tested revision.  Every stage
# re-derives its paths and the pinned identity from here; see README.md for the
# exact provenance of each dependency.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="fbthrift"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-2026.10.26.00}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# Measurement parameters (overridable by the workflow or the standalone entry).
PERF_REPS="${PERF_REPS:-5}"
PERF_WARMUP_RUNS="${PERF_WARMUP_RUNS:-1}"
PERF_BENCHMARK_MIN_TIME="${PERF_BENCHMARK_MIN_TIME:-5s}"
PERF_WARMUP_MIN_TIME="${PERF_WARMUP_MIN_TIME:-1s}"

# Build parameters.
PERF_BUILD_JOBS="${PERF_BUILD_JOBS:-6}"
PERF_CMAKE_BIN_EXPLICIT="${PERF_CMAKE_BIN:-}"
PERF_CMAKE_BIN="${PERF_CMAKE_BIN:-cmake}"
PERF_PROXY="${PERF_PROXY:-}"
PERF_FBTHRIFT_OFFLINE_DIR="${PERF_FBTHRIFT_OFFLINE_DIR:-/home/runner/software/fbthrift}"
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"

# Upstream projects.  fizz/wangle/mvfst/fb303 are deliberately not part of this
# case: ProtocolBench is a codegen + (de)serialization benchmark and the build
# runs with THRIFT_RPC=OFF, so the RPC transport stack is not linked at all.
FBTHRIFT_REPO="facebook/fbthrift"
FOLLY_REPO="facebook/folly"
FMT_REPO="fmtlib/fmt"
FASTFLOAT_REPO="fastfloat/fast_float"
BENCHMARK_REPO="google/benchmark"

SUPPORTED_VERSIONS=("2026.10.26.00")

# Filled by resolve_pinned_sources().
FBTHRIFT_TAG=""
FBTHRIFT_COMMIT=""
FBTHRIFT_SHA256=""
FBTHRIFT_TOP_DIR=""
FBTHRIFT_PROTOCOLBENCH_SHA256=""
FBTHRIFT_PROTOCOLBENCH_DATA_SHA256=""
FOLLY_TAG=""
FOLLY_SHA256=""
FOLLY_TOP_DIR=""
FOLLY_CMAKELISTS_SHA256=""
FMT_TAG=""
FMT_SHA256=""
FMT_TOP_DIR=""
FASTFLOAT_TAG=""
FASTFLOAT_SHA256=""
FASTFLOAT_TOP_DIR=""
BENCHMARK_TAG=""
BENCHMARK_SHA256=""
BENCHMARK_TOP_DIR=""

# Assigned by configure_runtime_paths().
SOURCE_ROOT=""
DL_DIR=""
BUILD_ROOT=""
INSTALL_PREFIX=""
FBTHRIFT_SOURCE_DIR=""
FOLLY_SOURCE_DIR=""
FMT_SOURCE_DIR=""
FASTFLOAT_SOURCE_DIR=""
BENCHMARK_SOURCE_DIR=""
FMT_BUILD_DIR=""
FASTFLOAT_BUILD_DIR=""
FOLLY_BUILD_DIR=""
BENCHMARK_BUILD_DIR=""
FBTHRIFT_BUILD_DIR=""
PROTOCOL_BENCH_BIN=""
SCENARIOS_FILE=""
CMAKE_GENERATOR=""

log_message() {
    printf '[fbthrift] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

# The tested revision is identified by the archive SHA-256 plus a content
# fingerprint of the benchmark sources.  fbthrift's CMake project() reports a
# constant 1.0.0 and installs no version file, so the date tag cannot be read
# back from the build tree; these pins make a wrong archive fail the build.
resolve_pinned_sources() {
    case "${SOFTWARE_VERSION}" in
        2026.10.26.00)
            FBTHRIFT_TAG="v2026.10.26.00"
            FBTHRIFT_COMMIT="c7fdfc9a80aa162c3934bf325c8e6ba56d15e845"
            FBTHRIFT_SHA256="6ad18cfc24297120a536a0ef9c5a84f409c9aa4376057328e8dca9d45587d5a1"
            FBTHRIFT_TOP_DIR="fbthrift-2026.10.26.00"
            FBTHRIFT_PROTOCOLBENCH_SHA256="39ade0ce40faaec58f07fafea52b497b4d81d989f04a549201aedf2dadeb8044"
            FBTHRIFT_PROTOCOLBENCH_DATA_SHA256="170e66ce8e0f9e2c6db69bc548e45a9757dc1f5d72594b5744157d01253dabb0"
            FOLLY_TAG="v2026.10.26.00"
            FOLLY_SHA256="b47fe04b804adfb51c65cda6b171505e67b9d1d69621106e54697821d1bf7ebc"
            FOLLY_TOP_DIR="folly-2026.10.26.00"
            FOLLY_CMAKELISTS_SHA256="063bc67360f74460e81c43e389a60773befe5637eb40713f84eb4df310bbcd68"
            FMT_TAG="12.1.0"
            FMT_SHA256="ea7de4299689e12b6dddd392f9896f08fb0777ac7168897a244a6d6085043fea"
            FMT_TOP_DIR="fmt-12.1.0"
            FASTFLOAT_TAG="v8.0.0"
            FASTFLOAT_SHA256="f312f2dc34c61e665f4b132c0307d6f70ad9420185fa831911bc24408acf625d"
            FASTFLOAT_TOP_DIR="fast_float-8.0.0"
            BENCHMARK_TAG="v1.9.5"
            BENCHMARK_SHA256="9631341c82bac4a288bef951f8b26b41f69021794184ece969f8473977eaa340"
            BENCHMARK_TOP_DIR="benchmark-1.9.5"
            ;;
        *)
            log_message "ERROR: version ${SOFTWARE_VERSION} has no verified source pins"
            log_message "ERROR: supported versions: ${SUPPORTED_VERSIONS[*]}"
            return 30
            ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    resolve_pinned_sources || return $?
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log_message "ERROR: PERF_RUN_ID contains unsafe characters"
        return 10
    }
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/fbthrift/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    [[ -n "${PERF_ACTUAL_VERSION_FILE}" ]] || \
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    SOURCE_ROOT="${PERF_WORK_DIR}/sources"
    DL_DIR="${PERF_WORK_DIR}/downloads"
    BUILD_ROOT="${PERF_WORK_DIR}/build"
    INSTALL_PREFIX="${PERF_WORK_DIR}/install"
    FBTHRIFT_SOURCE_DIR="${SOURCE_ROOT}/fbthrift"
    FOLLY_SOURCE_DIR="${SOURCE_ROOT}/folly"
    FMT_SOURCE_DIR="${SOURCE_ROOT}/fmt"
    FASTFLOAT_SOURCE_DIR="${SOURCE_ROOT}/fast_float"
    BENCHMARK_SOURCE_DIR="${SOURCE_ROOT}/benchmark"
    FMT_BUILD_DIR="${BUILD_ROOT}/fmt"
    FASTFLOAT_BUILD_DIR="${BUILD_ROOT}/fast_float"
    FOLLY_BUILD_DIR="${BUILD_ROOT}/folly"
    BENCHMARK_BUILD_DIR="${BUILD_ROOT}/benchmark"
    FBTHRIFT_BUILD_DIR="${BUILD_ROOT}/fbthrift"
    PROTOCOL_BENCH_BIN="${INSTALL_PREFIX}/bin/ProtocolBench"
    SCENARIOS_FILE="${SCRIPT_DIR}/scripts/scenarios.tsv"
    export TMPDIR="${PERF_WORK_DIR}/tmp"
    export LD_LIBRARY_PATH="${INSTALL_PREFIX}/lib:${INSTALL_PREFIX}/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID
    export RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    if [[ "$(normalize_architecture "$(uname -m)")" != \
          "$(normalize_architecture "${EXPECTED_ARCH}")" ]]; then
        log_message "ERROR: runner architecture $(uname -m) differs from ${EXPECTED_ARCH}"
        return 20
    fi
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${SOURCE_ROOT}" \
        "${DL_DIR}" "${BUILD_ROOT}" "${INSTALL_PREFIX}"
}

# Architecture-specific baseline flags.  aarch64 uses the armv8-a baseline,
# x86_64 the x86-64-v2 baseline; nothing here is host-tuned, so both
# architectures keep a portable, reproducible baseline build.
resolve_arch_flags() {
    local arch
    arch="$(normalize_architecture "${EXPECTED_ARCH}")"
    case "${arch}" in
        aarch64) printf '%s\n' "-march=armv8-a" ;;
        x86_64) printf '%s\n' "-march=x86-64-v2" ;;
        *) printf '\n' ;;
    esac
}

resolve_cmake_generator() {
    if [[ -z "${CMAKE_GENERATOR}" ]]; then
        if fbthrift_container_exec command -v ninja >/dev/null 2>&1; then
            CMAKE_GENERATOR="Ninja"
        else
            CMAKE_GENERATOR="Unix Makefiles"
        fi
    fi
    log_message "cmake generator (container): ${CMAKE_GENERATOR}"
}

cmake_version_ok() {
    local bin="$1" version major minor rest
    version="$(fbthrift_container_exec "${bin}" --version 2>/dev/null | head -n 1 | awk '{print $3}')"
    [[ -n "${version}" ]] || return 1
    major="${version%%.*}"
    rest="${version#*.}"
    minor="${rest%%.*}"
    [[ "${major}" =~ ^[0-9]+$ && "${minor}" =~ ^[0-9]+$ ]] || return 1
    (( major > 3 || (major == 3 && minor >= 24) ))
}

compiler_major_version() {
    local out
    out="$(fbthrift_container_exec "${CXX:-c++}" -dumpversion 2>/dev/null || true)"
    out="${out%%.*}"
    [[ "${out}" =~ ^[0-9]+$ ]] || { printf '0\n'; return 0; }
    printf '%s\n' "${out}"
}

header_available() {
    local header="$1" probe
    probe="${PERF_WORK_DIR}/probe/header-$(printf '%s' "${header}" | tr '/' '_').cc"
    mkdir -p "$(dirname "${probe}")"
    printf '#include <%s>\nint main() { return 0; }\n' "${header}" > "${probe}"
    fbthrift_container_exec "${CXX:-c++}" -fsyntax-only "${probe}" >/dev/null 2>&1
}

# ICU is not referenced by folly/fbthrift CMake (there is no FindICU call), but
# openEuler's Boost CMake package re-exports ICU as raw -licuuc/-licui18n/
# -licudata flags through Boost::regex.  On the aarch64 runner only the ICU
# runtime package is installed, so the link fails with "cannot find -licudata".
# A header check is not enough: the unversioned .so development symlinks (which
# the -devel package provides) are exactly what the linker needs.
icu_link_available() {
    local probe="${PERF_WORK_DIR}/probe/icu-link.c"
    local binary="${PERF_WORK_DIR}/probe/icu-link"
    mkdir -p "$(dirname "${probe}")"
    printf 'int main(void){return 0;}\n' > "${probe}"
    fbthrift_container_exec "${CC:-cc}" "${probe}" \
        -licuuc -licui18n -licudata -o "${binary}" >/dev/null 2>&1
}

verify_icu_linkage() {
    local probe="${PERF_WORK_DIR}/probe/icu-verify.c"
    local binary="${PERF_WORK_DIR}/probe/icu-verify"
    local output
    mkdir -p "$(dirname "${probe}")"
    printf 'int main(void){return 0;}\n' > "${probe}"
    if output="$(fbthrift_container_exec "${CC:-cc}" "${probe}" \
            -licuuc -licui18n -licudata -o "${binary}" 2>&1)"; then
        log_message "ICU development libraries are usable (-licuuc -licui18n -licudata)"
        return 0
    fi
    log_message "ERROR: ICU development libraries are not usable (-licuuc/-licui18n/-licudata)"
    local line
    while IFS= read -r line; do
        [[ -n "${line}" ]] && log_message "ERROR: ld: ${line}"
    done <<< "${output}"
    log_message "ERROR: the container image must provide the ICU development package (dnf: libicu-devel)"
    return 30
}

log_inherited_build_environment() {
    local name value
    for name in CFLAGS CXXFLAGS CPPFLAGS LDFLAGS; do
        value="${!name:-}"
        [[ -n "${value}" ]] && log_message "inherited ${name}=${value}"
    done
}

# The host keeps only Docker plus the download/verification tools; every
# compiler, header and library is installed and probed inside the private
# openEuler container.
require_host_transfer_commands() {
    local missing=()
    local tool
    for tool in curl sha256sum awk; do
        command -v "${tool}" >/dev/null 2>&1 || missing+=("${tool}")
    done
    ((${#missing[@]} == 0)) && return 0
    log_message "WARNING: host download/verification tools are incomplete: ${missing[*]}; the preset offline directory is the only usable source"
    return 0
}

FBTHRIFT_BUILD_PACKAGES=(
    gcc gcc-c++ make cmake ninja-build python3 tar gzip coreutils findutils
    sed gawk grep diffutils which binutils glibc-devel time
    boost-devel glog-devel gflags-devel libevent-devel openssl-devel
    zlib-devel libzstd-devel xxhash-devel libicu-devel
)

prepare_fbthrift_build_container() {
    local -a dnf_options=(--setopt=install_weak_deps=False)
    require_host_transfer_commands
    require_fbthrift_docker || return 30
    start_fbthrift_container || return $?
    [[ -z "${PERF_PROXY}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing fbthrift build dependencies inside the private container"
    fbthrift_container_exec_root dnf "${dnf_options[@]}" install -y \
        "${FBTHRIFT_BUILD_PACKAGES[@]}" || {
        log_message "ERROR: container build dependencies failed to install"
        return 30
    }
}

# Every required header is re-probed inside the container after installation, so
# the check describes the toolchain that actually builds folly/fbthrift.
install_system_dependencies() {
    local -a header_probes=(
        "boost/version.hpp"
        "glog/logging.h"
        "gflags/gflags.h"
        "event.h"
        "openssl/ssl.h"
        "zlib.h"
        "zstd.h"
        "xxhash.h"
        "unicode/ucnv.h"
    )
    local header missing=()
    for header in "${header_probes[@]}"; do
        header_available "${header}" || missing+=("${header}")
    done
    if (( ${#missing[@]} > 0 )); then
        log_message "ERROR: container build dependencies are missing headers: ${missing[*]}"
        return 30
    fi
    fbthrift_container_exec test -x /usr/bin/time || {
        log_message "ERROR: GNU time (/usr/bin/time) is missing inside the container"
        return 30
    }
    verify_icu_linkage || return 30
    log_message "container build dependencies are ready"
}

resolve_cmake_binary() {
    cmake_version_ok "${PERF_CMAKE_BIN}" && return 0
    if [[ -n "${PERF_CMAKE_BIN_EXPLICIT}" ]]; then
        log_message "ERROR: PERF_CMAKE_BIN=${PERF_CMAKE_BIN} is missing or older than 3.24 inside the container"
        return 30
    fi
    log_message "WARNING: container cmake is missing or older than 3.24; trying a pip install inside the container"
    local -a pip_options=(--disable-pip-version-check --quiet)
    [[ -n "${PERF_PROXY}" ]] && pip_options+=(--proxy "${PERF_PROXY}")
    fbthrift_container_exec_root python3 -m pip install "${pip_options[@]}" "cmake>=3.24,<4" \
        >/dev/null 2>&1 || true
    local candidate
    for candidate in /usr/local/bin/cmake /usr/bin/cmake; do
        if cmake_version_ok "${candidate}"; then
            PERF_CMAKE_BIN="${candidate}"
            log_message "using pip-installed container cmake: ${PERF_CMAKE_BIN}"
            return 0
        fi
    done
    log_message "ERROR: cannot obtain cmake >= 3.24 inside the container; install it or set PERF_CMAKE_BIN"
    return 30
}

require_build_tools() {
    local tool
    for tool in cc c++ python3 curl tar gzip sha256sum awk; do
        fbthrift_container_exec command -v "${tool}" >/dev/null 2>&1 || {
            log_message "ERROR: required build command is missing inside the container: ${tool}"
            return 30
        }
    done
    log_inherited_build_environment
    resolve_cmake_binary || return 30
    if ! cmake_version_ok "${PERF_CMAKE_BIN}"; then
        log_message "ERROR: cmake >= 3.24 is required by fbthrift"
        return 30
    fi
    local compiler_version
    compiler_version="$(compiler_major_version)"
    if (( compiler_version < 11 )); then
        log_message "ERROR: GCC >= 11 is required for folly/fbthrift C++20 builds (found ${compiler_version})"
        return 30
    fi
    log_message "container cmake $(fbthrift_container_exec "${PERF_CMAKE_BIN}" --version | head -n 1 | awk '{print $3}'), $(fbthrift_container_exec "${CXX:-c++}" --version | head -n 1)"
}

sha256_of() {
    sha256sum -- "$1" | awk '{print $1}'
}

verify_sha256() {
    local path="$1" expected="$2" actual
    [[ -f "${path}" ]] || return 1
    actual="$(sha256_of "${path}")"
    [[ "${actual}" == "${expected}" ]]
}

github_archive_urls() {
    local owner="$1" repo="$2" tag="$3"
    printf '%s\n' \
        "https://codeload.github.com/${owner}/${repo}/tar.gz/refs/tags/${tag}" \
        "https://github.com/${owner}/${repo}/archive/refs/tags/${tag}.tar.gz" \
        "https://gh-proxy.com/https://github.com/${owner}/${repo}/archive/refs/tags/${tag}.tar.gz" \
        "https://ghfast.top/https://github.com/${owner}/${repo}/archive/refs/tags/${tag}.tar.gz" \
        "https://hub.gitmirror.com/https://github.com/${owner}/${repo}/archive/refs/tags/${tag}.tar.gz"
}

# Obtain one pinned archive: preset offline directory first, then GitHub
# codeload and the proxy mirrors, always checking the same SHA-256.  No
# candidate is trusted on HTTP status alone.
download_verified() {
    local label="$1" filename="$2" expected_sha="$3"
    shift 3
    local target="${DL_DIR}/${filename}"
    local -a attempted=()
    mkdir -p "${DL_DIR}"
    if [[ -n "${PERF_FBTHRIFT_OFFLINE_DIR}" && -f "${PERF_FBTHRIFT_OFFLINE_DIR}/${filename}" ]]; then
        attempted+=("offline ${PERF_FBTHRIFT_OFFLINE_DIR}/${filename}")
        if verify_sha256 "${PERF_FBTHRIFT_OFFLINE_DIR}/${filename}" "${expected_sha}"; then
            cp -f -- "${PERF_FBTHRIFT_OFFLINE_DIR}/${filename}" "${target}"
            log_message "using preset offline archive for ${label}: ${PERF_FBTHRIFT_OFFLINE_DIR}/${filename}"
            record_dependency_source "${label}" "offline" "${PERF_FBTHRIFT_OFFLINE_DIR}/${filename}" "${expected_sha}"
            return 0
        fi
        log_message "WARNING: preset offline archive for ${label} failed SHA-256 verification"
    fi
    local url
    for url in "$@"; do
        attempted+=("${url}")
        log_message "downloading ${label}: ${url}"
        rm -f -- "${target}.part"
        local -a proxy_option=()
        [[ -n "${PERF_PROXY}" ]] && proxy_option=("--proxy" "${PERF_PROXY}")
        if curl -fSL --retry 2 --retry-delay 2 \
                --connect-timeout 20 --max-time 900 \
                "${proxy_option[@]}" \
                -o "${target}.part" "${url}" 2>/dev/null; then
            if verify_sha256 "${target}.part" "${expected_sha}"; then
                mv -f -- "${target}.part" "${target}"
                record_dependency_source "${label}" "url" "${url}" "${expected_sha}"
                return 0
            fi
            log_message "WARNING: ${label} archive checksum mismatch from ${url}"
        else
            log_message "WARNING: ${label} download failed from ${url}"
        fi
        rm -f -- "${target}.part"
    done
    log_message "ERROR: every source for ${label} (${filename}) failed; tried:"
    local entry
    for entry in "${attempted[@]}"; do
        log_message "  - ${entry}"
    done
    return 30
}

# Records where a dependency archive came from for RESULTS_DIR/dependencies.json.
DEPENDENCY_RECORDS=()
record_dependency_source() {
    DEPENDENCY_RECORDS+=("$1|$2|$3|$4")
}

extract_verified_archive() {
    local label="$1" filename="$2" expected_top="$3" destination="$4"
    local archive="${DL_DIR}/${filename}"
    local stage_dir="${destination}.extract"
    if [[ -d "${destination}" && -f "${destination}/.fbthrift-source-top" ]]; then
        log_message "reusing extracted ${label} sources"
        return 0
    fi
    rm -rf -- "${stage_dir}" "${destination}"
    mkdir -p "${stage_dir}"
    log_message "extracting ${label} inside the private container"
    fbthrift_container_exec tar -xzf "${archive}" -C "${stage_dir}" --no-same-owner || {
        log_message "ERROR: failed to extract ${label} archive ${archive}"
        return 30
    }
    local top=""
    top="$(fbthrift_container_exec find "${stage_dir}" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
    if [[ -z "${top}" || "$(basename "${top}")" != "${expected_top}" ]]; then
        log_message "ERROR: ${label} archive top-level directory is $(basename "${top:-<none>}"), expected ${expected_top}"
        rm -rf -- "${stage_dir}"
        return 30
    fi
    mv -- "${top}" "${destination}"
    rm -rf -- "${stage_dir}"
    printf '%s\n' "${expected_top}" > "${destination}/.fbthrift-source-top"
    log_message "extracted ${label} ${expected_top}"
}

verify_file_fingerprint() {
    local label="$1" path="$2" expected="$3"
    local actual
    [[ -f "${path}" ]] || {
        log_message "ERROR: ${label} is missing: ${path}"
        return 30
    }
    actual="$(sha256_of "${path}")"
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: ${label} content fingerprint mismatch"
        log_message "ERROR: expected ${expected}, got ${actual} (${path})"
        return 30
    fi
    return 0
}

run_cmake() {
    log_message "cmake $*"
    fbthrift_container_exec "${PERF_CMAKE_BIN}" "$@"
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
FBTHRIFT_IMAGE_ARCHIVE_DIR="${FBTHRIFT_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
FBTHRIFT_CA_ANCHORS_DIR="${FBTHRIFT_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
FBTHRIFT_CONTAINER_IMAGE="${FBTHRIFT_CONTAINER_IMAGE:-}"
FBTHRIFT_CONTAINER_NAME="${FBTHRIFT_CONTAINER_NAME:-}"
FBTHRIFT_CONTAINER_HOME="${FBTHRIFT_CONTAINER_HOME:-}"
declare -p FBTHRIFT_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || FBTHRIFT_CONTAINER_EXTRA_ARGS=()

fbthrift_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

fbthrift_configure_container() {
    local arch
    arch="$(fbthrift_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${FBTHRIFT_CONTAINER_NAME}" ] || FBTHRIFT_CONTAINER_NAME="boostkit-fbthrift-${arch}-${PERF_RUN_ID}"
    [ -n "${FBTHRIFT_CONTAINER_HOME}" ] || FBTHRIFT_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export FBTHRIFT_CONTAINER_NAME FBTHRIFT_CONTAINER_HOME
}

fbthrift_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_fbthrift_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_fbthrift_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${FBTHRIFT_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_fbthrift_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(fbthrift_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${FBTHRIFT_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${FBTHRIFT_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        fbthrift_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        fbthrift_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    FBTHRIFT_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${FBTHRIFT_CONTAINER_IMAGE}" ] || ! docker image inspect "${FBTHRIFT_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${FBTHRIFT_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_fbthrift_container_image_release || return $?
    export FBTHRIFT_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${FBTHRIFT_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_fbthrift_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-fbthrift-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${FBTHRIFT_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.fbthrift.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_fbthrift_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    fbthrift_configure_container
    require_fbthrift_docker || return $?
    if docker container inspect "${FBTHRIFT_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${FBTHRIFT_CONTAINER_NAME}"
        return 40
    fi
    sweep_fbthrift_stale_containers || true
    prepare_fbthrift_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${FBTHRIFT_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${FBTHRIFT_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${FBTHRIFT_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${FBTHRIFT_CONTAINER_HOME}" || return 40
    log_message "starting private container ${FBTHRIFT_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${FBTHRIFT_CONTAINER_NAME}" \
        --label "boostkit.fbthrift.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${FBTHRIFT_CONTAINER_EXTRA_ARGS[@]}" \
        "${FBTHRIFT_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${FBTHRIFT_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${FBTHRIFT_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${FBTHRIFT_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${FBTHRIFT_CONTAINER_NAME}"
}

check_fbthrift_container() {
    fbthrift_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${FBTHRIFT_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${FBTHRIFT_CONTAINER_NAME}"
        return 40
    }
}

fbthrift_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    fbthrift_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${FBTHRIFT_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${FBTHRIFT_CONTAINER_NAME}" "$@"
}

fbthrift_container_exec() { fbthrift_docker_exec '' '' "$@"; }

fbthrift_container_exec_at() {
    local workdir="$1"
    shift
    fbthrift_docker_exec "${workdir}" '' "$@"
}

fbthrift_container_exec_root() { fbthrift_docker_exec '' root "$@"; }

fbthrift_container_exec_root_at() {
    local workdir="$1"
    shift
    fbthrift_docker_exec "${workdir}" root "$@"
}

remove_fbthrift_container() {
    fbthrift_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${FBTHRIFT_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.fbthrift.run-id"}}' "${FBTHRIFT_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${FBTHRIFT_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${FBTHRIFT_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${FBTHRIFT_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${FBTHRIFT_CONTAINER_NAME}"
}
# >>> container-runtime:end
