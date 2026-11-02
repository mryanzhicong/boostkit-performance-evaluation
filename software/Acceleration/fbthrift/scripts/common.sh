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
        if command -v ninja >/dev/null 2>&1; then
            CMAKE_GENERATOR="Ninja"
        else
            CMAKE_GENERATOR="Unix Makefiles"
        fi
    fi
}

cmake_version_ok() {
    local bin="$1" version major minor rest
    version="$("${bin}" --version 2>/dev/null | head -n 1 | awk '{print $3}')"
    [[ -n "${version}" ]] || return 1
    major="${version%%.*}"
    rest="${version#*.}"
    minor="${rest%%.*}"
    [[ "${major}" =~ ^[0-9]+$ && "${minor}" =~ ^[0-9]+$ ]] || return 1
    (( major > 3 || (major == 3 && minor >= 24) ))
}

compiler_major_version() {
    local out
    out="$("${CXX:-c++}" -dumpversion 2>/dev/null || true)"
    out="${out%%.*}"
    [[ "${out}" =~ ^[0-9]+$ ]] || { printf '0\n'; return 0; }
    printf '%s\n' "${out}"
}

header_available() {
    local header="$1"
    printf '#include <%s>\nint main() { return 0; }\n' "${header}" | \
        "${CXX:-c++}" -x c++ -fsyntax-only - >/dev/null 2>&1
}

# The runner uses dnf while the local evidence machine uses apt; both branches
# are implemented and every required header is re-probed after installation.
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
    )
    local -a missing_headers=()
    local header
    for header in "${header_probes[@]}"; do
        header_available "${header}" || missing_headers+=("${header}")
    done
    local need_time=0
    [[ -x /usr/bin/time ]] || need_time=1
    local need_ninja=0
    command -v ninja >/dev/null 2>&1 || need_ninja=1

    if (( ${#missing_headers[@]} == 0 && need_time == 0 && need_ninja == 0 )); then
        log_message "all system build dependencies are already installed"
        return 0
    fi

    local package_manager=""
    if command -v dnf >/dev/null 2>&1; then
        package_manager="dnf"
    elif command -v apt-get >/dev/null 2>&1; then
        package_manager="apt-get"
    else
        log_message "ERROR: neither dnf nor apt-get is available to install build dependencies"
        return 30
    fi

    local -a packages=()
    local probes_packages_dnf=(
        "boost/version.hpp:boost-devel"
        "glog/logging.h:glog-devel"
        "gflags/gflags.h:gflags-devel"
        "event.h:libevent-devel"
        "openssl/ssl.h:openssl-devel"
        "zlib.h:zlib-devel"
        "zstd.h:libzstd-devel"
        "xxhash.h:xxhash-devel"
    )
    local probes_packages_apt=(
        "boost/version.hpp:libboost-all-dev"
        "glog/logging.h:libgoogle-glog-dev"
        "gflags/gflags.h:libgflags-dev"
        "event.h:libevent-dev"
        "openssl/ssl.h:libssl-dev"
        "zlib.h:zlib1g-dev"
        "zstd.h:libzstd-dev"
        "xxhash.h:libxxhash-dev"
    )
    local -a mapping=()
    if [[ "${package_manager}" == "dnf" ]]; then
        mapping=("${probes_packages_dnf[@]}")
    else
        mapping=("${probes_packages_apt[@]}")
    fi
    local entry entry_header entry_package missing
    for entry in "${mapping[@]}"; do
        entry_header="${entry%%:*}"
        entry_package="${entry##*:}"
        for missing in "${missing_headers[@]}"; do
            if [[ "${missing}" == "${entry_header}" ]]; then
                packages+=("${entry_package}")
            fi
        done
    done
    (( need_time == 0 )) || packages+=("time")
    (( need_ninja == 0 )) || packages+=("ninja-build")
    if (( ${#packages[@]} == 0 )); then
        log_message "ERROR: required headers are missing but no package mapping matched"
        return 30
    fi

    local -a dnf_options=() apt_options=()
    if [[ -n "${PERF_PROXY}" ]]; then
        dnf_options+=("--setopt=proxy=${PERF_PROXY}")
        apt_options+=("-o" "Acquire::http::Proxy=${PERF_PROXY}"
                      "-o" "Acquire::https::Proxy=${PERF_PROXY}")
    fi
    local -a runner=()
    if [[ "$(id -u)" -eq 0 ]]; then
        runner=()
    elif command -v sudo >/dev/null 2>&1; then
        runner=(sudo -n)
    else
        log_message "ERROR: root or passwordless sudo is required to install build dependencies"
        return 30
    fi
    log_message "installing build dependencies with ${package_manager}: ${packages[*]}"
    local rc=0
    if [[ "${package_manager}" == "dnf" ]]; then
        "${runner[@]}" dnf "${dnf_options[@]}" install -y "${packages[@]}" || rc=$?
    else
        DEBIAN_FRONTEND=noninteractive "${runner[@]}" apt-get update || rc=$?
        if (( rc == 0 )); then
            DEBIAN_FRONTEND=noninteractive "${runner[@]}" apt-get install -y \
                --no-install-recommends "${apt_options[@]}" "${packages[@]}" || rc=$?
        fi
    fi
    if (( rc != 0 )); then
        log_message "ERROR: package installation failed with exit code ${rc}"
        return 30
    fi

    local still_missing=()
    for header in "${header_probes[@]}"; do
        header_available "${header}" || still_missing+=("${header}")
    done
    [[ -x /usr/bin/time ]] || still_missing+=("/usr/bin/time")
    if (( ${#still_missing[@]} > 0 )); then
        log_message "ERROR: build dependencies still missing after installation: ${still_missing[*]}"
        return 30
    fi
    log_message "system build dependencies are ready"
}

resolve_cmake_binary() {
    cmake_version_ok "${PERF_CMAKE_BIN}" && return 0
    if [[ -n "${PERF_CMAKE_BIN_EXPLICIT}" ]]; then
        log_message "ERROR: PERF_CMAKE_BIN=${PERF_CMAKE_BIN} is missing or older than 3.24"
        return 30
    fi
    log_message "WARNING: ${PERF_CMAKE_BIN} is missing or older than 3.24; trying a private pip install"
    local -a pip_options=(--user --disable-pip-version-check --quiet)
    [[ -n "${PERF_PROXY}" ]] && pip_options+=(--proxy "${PERF_PROXY}")
    python3 -m pip install "${pip_options[@]}" "cmake>=3.24,<4" >/dev/null 2>&1 || true
    local candidate
    for candidate in "${HOME}/.local/bin/cmake" \
                     "$(dirname "$(command -v python3 2>/dev/null || printf '/usr/bin/python3')")/cmake" \
                     "$(command -v cmake 2>/dev/null || true)"; do
        [[ -n "${candidate}" && -x "${candidate}" ]] || continue
        if cmake_version_ok "${candidate}"; then
            PERF_CMAKE_BIN="${candidate}"
            log_message "using pip-installed cmake: ${PERF_CMAKE_BIN}"
            return 0
        fi
    done
    log_message "ERROR: cannot obtain cmake >= 3.24; install it or set PERF_CMAKE_BIN"
    return 30
}

require_build_tools() {
    local tool
    for tool in cc c++ python3 curl tar gzip sha256sum awk; do
        command -v "${tool}" >/dev/null 2>&1 || {
            log_message "ERROR: required build command is missing: ${tool}"
            return 30
        }
    done
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
    log_message "cmake $("${PERF_CMAKE_BIN}" --version | head -n 1 | awk '{print $3}'), $("${CXX:-c++}" --version | head -n 1)"
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
    tar -xzf "${archive}" -C "${stage_dir}" --no-same-owner || {
        log_message "ERROR: failed to extract ${label} archive ${archive}"
        return 30
    }
    local top=""
    top="$(find "${stage_dir}" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
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
    "${PERF_CMAKE_BIN}" "$@"
}
