#!/usr/bin/env bash
# Hyperscan performance case (official v5.4.2.1 sources with the upstream
# tools/hsbench benchmark).
#
# Hyperscan is Intel's high-performance regular expression matching
# library (SIMD-accelerated, multi-pattern, Gbit/s-class).  The software
# under test is cloned from the official repository
# (github.com/intel/hyperscan) at the exact stable tag v5.4.2.1 (the
# final release of the project) and compiled entirely inside the
# isolated work directory (nothing is installed system-wide).
#
# The benchmark is the official hsbench tool shipped inside the
# Hyperscan source tree (tools/hsbench), the tool the Hyperscan
# documentation dedicates to "measur[ing] Hyperscan's performance for a
# particular set of patterns and corpus of data to be scanned".  It
# compiles a pattern set into a Hyperscan database, scans a corpus
# database over it with the official timing loop (default: the corpus
# is scanned twenty times and the overall throughput is computed from
# the total bytes scanned), and reports, per run:
#
#     Mean throughput (overall): 19,241.10 Mbit/sec
#
# The scenario matrix is the official scan modes crossed with a thread
# ladder expressed through hsbench's own -T option (one benchmark
# thread per listed CPU, throughput aggregated over all threads):
#
#   streaming (hsbench default) and block mode (-N), each with 1, 4
#   and 16 threads (-T 0, -T 0-3, -T 0-15) — 6 scenarios.
#
# The pattern set is a fixed 50-expression file covering the Hyperscan
# PCRE subset (literals, classes, quantifiers, alternation, anchors and
# the i/s/m flag combinations); the corpus is built from the fixed
# text file set of the v5.4.2.1 source tree itself (src sources, dev
# docs, examples, changelog — tag-pinned content, every file's SHA-256
# recorded) using the official hsbench corpus database schema (chunk
# table + stream index), with each input file becoming one stream cut
# into 16 KiB line-aligned chunks.  The official corpus constructor
# scripts are python2-only, so the delivered constructor is their
# python3 equivalent (same schema, same index/vacuum/analyze
# post-processing).
#
# The upstream build requires four dependencies the official CMake
# does not vendor; all of them are fetched from their official
# channels with fixed versions and checksums/tags and built into the
# isolated prefix (the same bootstrap discipline as the other cases):
#
#   ragel 6.10     official colm.net tarball, SHA-256 verified
#                  (the official git tree ships no configure; the
#                  tarball is the official distribution);
#   OpenSSL 3.6.4  official openssl/openssl git tag (clone tag
#                  verification), built shared — the official
#                  cmake/build_wrapper.sh fat-runtime symbol-rename
#                  step exempts the symbols of libcrypto.so only, so a
#                  shared build is the officially supported packaging;
#   Boost 1.88.0   official boostorg/boost GitHub release cmake
#                  tarball (SHA-256 verified, chunked range download),
#                  with the per-module headers aggregated into one
#                  include tree passed as BOOST_ROOT;
#   SQLite 3.53.4  official sqlite.org amalgamation zip, verified
#                  against the SHA3-256 published on the official
#                  download page, placed in the source tree at the
#                  in-tree location the official CMake looks for.
#
# The four framework stages map to: bootstrap the dependency chain +
# clone+verify+build hsbench (build), construct the corpus database and
# smoke-run one official scenario (start), run the full 6-scenario
# matrix (test), and drop the benchmark data (stop — hsbench runs no
# background service).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="hyperscan"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-5.4.2.1}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
HYPERSCAN_SOURCE_URL="${HYPERSCAN_SOURCE_URL:-https://github.com/intel/hyperscan.git}"
HYPERSCAN_BUILD_JOBS="${HYPERSCAN_BUILD_JOBS:-4}"
# The official hsbench repeat count (default 20; the docs' documented
# behaviour the overall throughput is computed over).
HYPERSCAN_REPETITIONS="${HYPERSCAN_REPETITIONS:-20}"
# The thread ladder expressed through hsbench -T (cores 0..N-1).
HYPERSCAN_THREADS_LADDER=(1 4 16)

# Dependency versions and checksums (official channels).
RAGEL_VERSION="6.10"
RAGEL_SHA256="5f156edb65d20b856d638dd9ee2dfb43285914d9aa2b6ec779dac0270cd56c3f"
RAGEL_URL="https://www.colm.net/files/ragel/ragel-${RAGEL_VERSION}.tar.gz"
OPENSSL_GIT_BASE="${OPENSSL_GIT_BASE:-https://github.com/openssl/openssl.git}"
OPENSSL_TAG="openssl-3.6.4"
BOOST_VERSION="1.88.0"
BOOST_SHA256="f48b48390380cfb94a629872346e3a81370dc498896f16019ade727ab72eb1ec"
BOOST_SIZE="99990208"
BOOST_URL="https://github.com/boostorg/boost/releases/download/boost-${BOOST_VERSION}/boost-${BOOST_VERSION}-cmake.tar.xz"
SQLITE_VERSION="3530400"
SQLITE_DISPLAY_VERSION="3.53.4"
SQLITE_SHA3_256="628a44cfe82c66aed1ccbbe85a562d2e33ebe64b3288981ed76285612227934e"
SQLITE_URL="https://sqlite.org/2026/sqlite-amalgamation-${SQLITE_VERSION}.zip"

STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

# Lifecycle paths (assigned in configure_runtime_paths).
SOURCE_DIR=""
PREFIX_DIR=""
DEPS_SRC_DIR=""
BOOST_TARBALL=""
BOOST_INCLUDE_DIR=""
SQLITE_DIR=""
BUILD_DIR=""
HSBENCH_BIN=""
CORPUS_DB=""
PATTERNS_FILE=""
RAGEL_BIN=""

log() {
    printf '[hyperscan] %s\n' "$*"
}

normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

configure_runtime_paths() {
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    }
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64) EXPECTED_ARCH="x86_64" ;;
        aarch64|arm64) EXPECTED_ARCH="aarch64" ;;
        *) EXPECTED_ARCH="${EXPECTED_ARCH,,}" ;;
    esac
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/hyperscan/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/hyperscan-source"
    PREFIX_DIR="${PERF_WORK_DIR}/prefix"
    DEPS_SRC_DIR="${PERF_WORK_DIR}/deps-src"
    BOOST_TARBALL="${DEPS_SRC_DIR}/boost-cmake.tar.xz"
    BOOST_INCLUDE_DIR="${PERF_WORK_DIR}/boost-include"
    SQLITE_DIR="${SOURCE_DIR}/sqlite3"
    BUILD_DIR="${PERF_WORK_DIR}/build"
    HSBENCH_BIN="${BUILD_DIR}/bin/hsbench"
    CORPUS_DB="${PERF_WORK_DIR}/corpus.db"
    PATTERNS_FILE="${PERF_WORK_DIR}/patterns"
    RAGEL_BIN="${PREFIX_DIR}/bin/ragel"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}"
}

require_hyperscan_tools() {
    local command_name
    local packages=()

    for command_name in git python3 cmake make g++ curl tar unzip tee; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "missing required Hyperscan test command: ${command_name}"
            packages+=("${command_name}")
        fi
    done
    if [[ "${#packages[@]}" -ne 0 ]]; then
        log "ERROR: install the required tools first: ${packages[*]}"
        return 30
    fi

    # The v5.4.2.1 sources need C++11; the upstream CMake needs >= 3.10.
    local gxx_major
    gxx_major="$(g++ -dumpversion 2>/dev/null | cut -d. -f1)"
    if [[ -z "${gxx_major}" || "${gxx_major}" -lt 5 ]]; then
        log "ERROR: g++ ${gxx_major:-unknown} is too old for the Hyperscan sources (g++ >= 5)"
        return 30
    fi
    local cmake_version cmake_major cmake_minor cmake_rest
    cmake_version="$(cmake --version | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)"
    cmake_major="${cmake_version%%.*}"
    cmake_rest="${cmake_version#*.}"
    cmake_minor="${cmake_rest%%.*}"
    if [[ -z "${cmake_major}" || "${cmake_major}" -lt 3 || \
          ( "${cmake_major}" -eq 3 && "${cmake_minor}" -lt 10 ) ]]; then
        log "ERROR: cmake ${cmake_version:-unknown} is too old for the Hyperscan CMake build (cmake >= 3.10)"
        return 30
    fi

    # The -T thread ladder needs enough cores for the largest step.
    local ncores
    ncores="$(nproc)"
    local max_threads="${HYPERSCAN_THREADS_LADDER[-1]}"
    if [[ "${ncores}" -lt "${max_threads}" ]]; then
        log "ERROR: the thread ladder needs ${max_threads} cores, runner has ${ncores}"
        return 30
    fi
}

check_architecture() {
    local actual expected
    actual="$(normalize_arch "$(uname -m)")"
    expected="$(normalize_arch "${EXPECTED_ARCH}")"
    [[ "${actual}" == "${expected}" ]] || {
        log "ERROR: expected architecture ${expected}, runner is ${actual}"
        return 20
    }
}

# ---------------------------------------------------------------------------
# Dependency chain (all into the isolated prefix).
# ---------------------------------------------------------------------------

build_ragel() {
    if [[ -x "${RAGEL_BIN}" ]]; then
        log "ragel ${RAGEL_VERSION} already available in the prefix"
        return 0
    fi
    mkdir -p "${DEPS_SRC_DIR}"
    local tarball="${DEPS_SRC_DIR}/ragel-${RAGEL_VERSION}.tar.gz"
    if [[ ! -f "${tarball}" ]]; then
        log "downloading the official ragel ${RAGEL_VERSION} tarball"
        if ! curl -fL --retry 5 --retry-delay 5 -o "${tarball}" "${RAGEL_URL}" \
                > "${PERF_WORK_DIR}/ragel-download.log" 2>&1; then
            log "ERROR: the ragel tarball download failed (see ${PERF_WORK_DIR}/ragel-download.log)"
            return 30
        fi
    fi
    log "verifying the ragel tarball SHA-256"
    if ! (cd "${DEPS_SRC_DIR}" && \
            echo "${RAGEL_SHA256}  ragel-${RAGEL_VERSION}.tar.gz" | sha256sum -c -); then
        log "ERROR: the ragel tarball SHA-256 mismatch"
        return 30
    fi
    if [[ ! -d "${DEPS_SRC_DIR}/ragel-${RAGEL_VERSION}" ]]; then
        tar xf "${tarball}" -C "${DEPS_SRC_DIR}" || return 30
    fi
    log "building ragel ${RAGEL_VERSION} into the prefix"
    (cd "${DEPS_SRC_DIR}/ragel-${RAGEL_VERSION}" && \
        ./configure --prefix="${PREFIX_DIR}" && \
        make -j"${HYPERSCAN_BUILD_JOBS}" && \
        make install) > "${PERF_WORK_DIR}/ragel-build.log" 2>&1 || {
        log "ERROR: failed to build ragel (see ${PERF_WORK_DIR}/ragel-build.log)"
        return 30
    }
    [[ -x "${RAGEL_BIN}" ]] || {
        log "ERROR: the ragel executable was not installed"
        return 30
    }
}

clone_tagged_repo() { # name base tag dir
    local name="$1" base="$2" tag="$3" dir="$4"
    local described

    if [[ -d "${dir}/.git" ]]; then
        log "using cached ${name} source tree ${dir}"
    else
        log "cloning the official ${name} ${tag} sources"
        if ! git clone --depth 1 --branch "${tag}" "${base}.git" "${dir}" \
                > "${PERF_WORK_DIR}/${name}-clone.log" 2>&1; then
            rm -rf "${dir}"
            log "ERROR: failed to clone ${base} at ${tag} (see ${PERF_WORK_DIR}/${name}-clone.log)"
            return 30
        fi
    fi
    described="$(git -C "${dir}" describe --tags --exact-match 2>/dev/null || true)"
    if [[ "${described}" != "${tag}" ]]; then
        log "ERROR: the ${name} source tree is ${described:-untagged}, expected ${tag}"
        return 30
    fi
}

build_openssl() {
    if [[ -f "${PREFIX_DIR}/lib/libcrypto.so" ]]; then
        log "openssl ${OPENSSL_TAG} already available in the prefix"
        return 0
    fi
    mkdir -p "${DEPS_SRC_DIR}"
    clone_tagged_repo openssl "${OPENSSL_GIT_BASE}" "${OPENSSL_TAG}" \
        "${DEPS_SRC_DIR}/openssl" || return $?

    # Shared build: the official fat-runtime build_wrapper.sh exempts
    # only libcrypto.so symbols from the per-microarchitecture symbol
    # rename, so the officially supported packaging of this dependency
    # is the shared library.
    local openssl_target="linux-x86_64"
    case "$(normalize_arch "$(uname -m)")" in
        aarch64) openssl_target="linux-aarch64" ;;
    esac
    log "building openssl ${OPENSSL_TAG} (shared, ${openssl_target}) into the prefix"
    (cd "${DEPS_SRC_DIR}/openssl" && \
        ./Configure "${openssl_target}" no-tests no-docs \
            --prefix="${PREFIX_DIR}" --libdir=lib && \
        make build_sw -j"${HYPERSCAN_BUILD_JOBS}" && \
        make install_sw) > "${PERF_WORK_DIR}/openssl-build.log" 2>&1 || {
        log "ERROR: failed to build openssl (see ${PERF_WORK_DIR}/openssl-build.log)"
        return 30
    }
    [[ -f "${PREFIX_DIR}/lib/libcrypto.so" ]] || {
        log "ERROR: the openssl shared library was not installed"
        return 30
    }
}

download_boost() {
    # Chunked range download (the release CDN sometimes resets
    # mid-stream and curl retry+resume can corrupt overlapping ranges):
    # each 4MiB chunk is fetched, size-verified, appended; the assembled
    # tarball is verified by SHA-256.
    if [[ -d "${BOOST_INCLUDE_DIR}/boost" ]]; then
        log "boost ${BOOST_VERSION} headers already aggregated"
        return 0
    fi
    mkdir -p "${DEPS_SRC_DIR}"
    if [[ ! -f "${BOOST_TARBALL}" ]]; then
        log "downloading the official boost ${BOOST_VERSION} cmake tarball (chunked)"
        local chunk=4194304 start end expect got try
        : > "${BOOST_TARBALL}"
        : > "${BOOST_TARBALL}.chunk"
        start=0
        while [[ "${start}" -lt "${BOOST_SIZE}" ]]; do
            end=$((start + chunk - 1))
            if [[ "${end}" -ge "${BOOST_SIZE}" ]]; then
                end=$((BOOST_SIZE - 1))
            fi
            expect=$((end - start + 1))
            got=0
            for try in $(seq 1 15); do
                : > "${BOOST_TARBALL}.chunk"
                curl -fsL --max-time 900 -r "${start}-${end}" \
                    -o "${BOOST_TARBALL}.chunk" "${BOOST_URL}" 2>/dev/null || true
                got="$(stat -c %s "${BOOST_TARBALL}.chunk" 2>/dev/null || echo 0)"
                [[ "${got}" -eq "${expect}" ]] && break
            done
            if [[ "${got}" -ne "${expect}" ]]; then
                log "ERROR: the boost chunk at offset ${start} failed (got ${got}, expected ${expect})"
                return 30
            fi
            cat "${BOOST_TARBALL}.chunk" >> "${BOOST_TARBALL}"
            start=$((start + chunk))
        done
        rm -f "${BOOST_TARBALL}.chunk"
    fi
    log "verifying the boost tarball SHA-256"
    if ! (cd "${DEPS_SRC_DIR}" && \
            echo "${BOOST_SHA256}  $(basename "${BOOST_TARBALL}")" | sha256sum -c -); then
        log "ERROR: the boost tarball SHA-256 mismatch"
        return 30
    fi
    local extracted="${DEPS_SRC_DIR}/boost-${BOOST_VERSION}"
    if [[ ! -d "${extracted}" ]]; then
        log "extracting the boost sources"
        tar xf "${BOOST_TARBALL}" -C "${DEPS_SRC_DIR}" || return 30
    fi
    # The cmake tarball is the git submodule layout: headers live in
    # libs/<module>/include/boost; aggregate them into one include tree.
    log "aggregating the boost headers"
    mkdir -p "${BOOST_INCLUDE_DIR}/boost"
    local part
    find "${extracted}/libs" -maxdepth 3 -type d -path '*/include/boost' | while read -r part; do
        cp -rn "${part}/." "${BOOST_INCLUDE_DIR}/boost/" 2>/dev/null || true
    done
    [[ -f "${BOOST_INCLUDE_DIR}/boost/version.hpp" ]] || {
        log "ERROR: the aggregated boost headers are incomplete"
        return 30
    }
}

install_sqlite() {
    if [[ -f "${SQLITE_DIR}/sqlite3.c" && -f "${SQLITE_DIR}/sqlite3.h" ]]; then
        log "sqlite amalgamation ${SQLITE_DISPLAY_VERSION} already in the source tree"
        return 0
    fi
    mkdir -p "${DEPS_SRC_DIR}"
    local zipball="${DEPS_SRC_DIR}/sqlite-amalgamation-${SQLITE_VERSION}.zip"
    if [[ ! -f "${zipball}" ]]; then
        log "downloading the official sqlite ${SQLITE_DISPLAY_VERSION} amalgamation"
        if ! curl -fL --retry 5 --retry-delay 5 -o "${zipball}" "${SQLITE_URL}" \
                > "${PERF_WORK_DIR}/sqlite-download.log" 2>&1; then
            log "ERROR: the sqlite amalgamation download failed (see ${PERF_WORK_DIR}/sqlite-download.log)"
            return 30
        fi
    fi
    # sqlite.org publishes SHA3-256 checksums on its official download
    # page; verify with python3's hashlib (the standard sha256sum tool
    # does not implement SHA-3).
    log "verifying the sqlite amalgamation SHA3-256"
    if ! python3 - "${zipball}" "${SQLITE_SHA3_256}" <<'PYEOF'
import hashlib
import sys

zipball, expected = sys.argv[1], sys.argv[2]
digest = hashlib.sha3_256(open(zipball, "rb").read()).hexdigest()
if digest != expected:
    raise SystemExit(f"sqlite amalgamation SHA3-256 mismatch: {digest}")
PYEOF
    then
        log "ERROR: the sqlite amalgamation SHA3-256 mismatch"
        return 30
    fi
    unzip -o -q "${zipball}" -d "${DEPS_SRC_DIR}" || return 30
    mkdir -p "${SQLITE_DIR}"
    cp "${DEPS_SRC_DIR}/sqlite-amalgamation-${SQLITE_VERSION}/sqlite3.c" \
       "${DEPS_SRC_DIR}/sqlite-amalgamation-${SQLITE_VERSION}/sqlite3.h" \
       "${SQLITE_DIR}/" || return 30
    log "sqlite amalgamation ${SQLITE_DISPLAY_VERSION} installed at the official in-tree path"
}

read_hyperscan_version() {
    # The upstream CMakeLists.txt declares the library version as three
    # set(HS_x_VERSION N) lines (the v5.4.2.1 tag carries the library
    # version 5.4.2; the fourth tag segment is the release revision).
    local major minor patch
    major="$(sed -n 's/^set *(HS_MAJOR_VERSION \([0-9]*\)).*/\1/p' "$1")"
    minor="$(sed -n 's/^set *(HS_MINOR_VERSION \([0-9]*\)).*/\1/p' "$1")"
    patch="$(sed -n 's/^set *(HS_PATCH_VERSION \([0-9]*\)).*/\1/p' "$1")"
    [[ -n "${major}" && -n "${minor}" && -n "${patch}" ]] || return 1
    printf '%s.%s.%s\n' "${major}" "${minor}" "${patch}"
}

# ---------------------------------------------------------------------------
# Framework stages.
# ---------------------------------------------------------------------------

build_hyperscan() {
    local tag described actual_version

    initialize_runtime || return $?
    check_architecture || return $?
    require_hyperscan_tools || return $?
    [[ ! -e "${SOURCE_DIR}" ]] || {
        log "ERROR: source directory is not clean under ${PERF_WORK_DIR}"
        return 20
    }

    tag="v${SOFTWARE_VERSION}"
    log "cloning the official Hyperscan ${tag} sources"
    if ! git clone --branch "${tag}" --depth 1 \
            "${HYPERSCAN_SOURCE_URL}" "${SOURCE_DIR}" \
            > "${PERF_WORK_DIR}/hyperscan-clone.log" 2>&1; then
        rm -rf "${SOURCE_DIR}"
        log "ERROR: failed to clone Hyperscan ${tag} (see ${PERF_WORK_DIR}/hyperscan-clone.log)"
        return 30
    fi
    described="$(git -C "${SOURCE_DIR}" describe --tags --exact-match 2>/dev/null || true)"
    if [[ "${described}" != "${tag}" ]]; then
        log "ERROR: the Hyperscan source tree is ${described:-untagged}, expected ${tag}"
        return 30
    fi
    actual_version="$(read_hyperscan_version "${SOURCE_DIR}/CMakeLists.txt")" || {
        log "ERROR: cannot read the Hyperscan version from the upstream CMakeLists"
        return 40
    }
    if [[ "v${actual_version}" != "${tag}" && "${tag}" != "v${actual_version}."* ]]; then
        log "ERROR: the Hyperscan sources report ${actual_version}, which does not match tag ${tag}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40

    build_ragel || return $?
    build_openssl || return $?
    download_boost || return $?
    install_sqlite || return $?

    # LIBRARY_PATH additionally exposes the prefix libcrypto.so to the
    # official build_wrapper.sh fat-runtime symbol-rename step, which
    # locates it through `gcc --print-file-name=libcrypto.so` (gcc
    # built-in paths + LIBRARY_PATH; -L flags are not considered
    # there) and exempts its symbols from the per-microarchitecture
    # renaming.
    log "configuring the official CMake build (Release)"
    if ! (export PATH="${PREFIX_DIR}/bin:${PATH}" && \
            export LIBRARY_PATH="${PREFIX_DIR}/lib${LIBRARY_PATH:+:${LIBRARY_PATH}}" && \
            cmake -S "${SOURCE_DIR}" -B "${BUILD_DIR}" \
                -DCMAKE_BUILD_TYPE=Release \
                -DCMAKE_PREFIX_PATH="${PREFIX_DIR}" \
                -DBOOST_ROOT="${BOOST_INCLUDE_DIR}" \
                -DBUILD_EXAMPLES=OFF \
                > "${PERF_WORK_DIR}/cmake-configure.log" 2>&1); then
        log "ERROR: the official CMake configuration failed (see ${PERF_WORK_DIR}/cmake-configure.log)"
        return 30
    fi

    log "building the official hsbench target (jobs: ${HYPERSCAN_BUILD_JOBS})"
    if ! (export PATH="${PREFIX_DIR}/bin:${PATH}" && \
            export LIBRARY_PATH="${PREFIX_DIR}/lib${LIBRARY_PATH:+:${LIBRARY_PATH}}" && \
            cmake --build "${BUILD_DIR}" --target hsbench \
                --parallel "${HYPERSCAN_BUILD_JOBS}" \
                > "${PERF_WORK_DIR}/hsbench-build.log" 2>&1); then
        log "ERROR: failed to build the official hsbench target (see ${PERF_WORK_DIR}/hsbench-build.log)"
        return 40
    fi
    [[ -x "${HSBENCH_BIN}" ]] || {
        log "ERROR: the official hsbench executable was not created"
        return 40
    }
}

start_hyperscan_runtime() {
    initialize_runtime || return $?
    [[ -x "${HSBENCH_BIN}" ]] || {
        log "ERROR: the official hsbench executable is unavailable"
        return 40
    }

    # Deploy the fixed 50-expression pattern set.
    if [[ ! -f "${SCRIPT_DIR}/src/patterns" ]]; then
        log "ERROR: the fixed pattern set is missing: ${SCRIPT_DIR}/src/patterns"
        return 40
    fi
    cp "${SCRIPT_DIR}/src/patterns" "${PATTERNS_FILE}" || return 40

    # Build the corpus database from the fixed source-tree text file
    # set (official hsbench corpus schema, python3 constructor).
    [[ ! -e "${CORPUS_DB}" ]] || {
        log "ERROR: corpus database is not clean: ${CORPUS_DB}"
        return 20
    }
    log "building the corpus database from the source-tree text set"
    if ! python3 "${SCRIPT_DIR}/scripts/build_corpus.py" \
            "${SOURCE_DIR}" "${CORPUS_DB}" \
            > "${PERF_WORK_DIR}/corpus-build.log" 2>&1; then
        log "ERROR: the corpus construction failed (see ${PERF_WORK_DIR}/corpus-build.log)"
        return 40
    fi

    # Smoke run: the streaming/1-thread scenario with a single repeat,
    # end to end through compile + corpus scan.
    log "smoke-running the official hsbench (streaming, 1 thread, 1 repeat)"
    if ! (export LD_LIBRARY_PATH="${PREFIX_DIR}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}" && \
            "${HSBENCH_BIN}" -e "${PATTERNS_FILE}" -c "${CORPUS_DB}" -T 0 -n 1) \
            > "${PERF_WORK_DIR}/smoke.log" 2>&1; then
        log "ERROR: the hsbench smoke run failed (see ${PERF_WORK_DIR}/smoke.log)"
        return 40
    fi
    if ! grep -q 'Mean throughput (overall)' "${PERF_WORK_DIR}/smoke.log"; then
        log "ERROR: the hsbench smoke run produced no throughput result"
        return 40
    fi
    log "hsbench smoke run passed"
}

run_hyperscan_benchmarks() {
    initialize_runtime || return $?
    [[ -x "${HSBENCH_BIN}" && -f "${CORPUS_DB}" && -f "${PATTERNS_FILE}" ]] || {
        log "ERROR: the official hsbench executable, corpus or patterns are unavailable"
        return 40
    }
    export SOFTWARE_VERSION EXPECTED_ARCH
    export HYPERSCAN_SOURCE_URL HYPERSCAN_REPETITIONS
    export HYPERSCAN_THREADS_LADDER
    export LD_LIBRARY_PATH="${PREFIX_DIR}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
    python3 "${SCRIPT_DIR}/scripts/run_hsbench.py" \
        "${HSBENCH_BIN}" "${PATTERNS_FILE}" "${CORPUS_DB}" \
        "${RESULTS_DIR}/benchmark_hsbench.json" || return 50
}

stop_hyperscan_runtime() {
    log "Hyperscan hsbench has no background service to stop"
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
    [[ "${PERF_WORK_DIR}" == /home/runner/boostkit-perf/hyperscan/local-* && "${PERF_WORK_DIR}" != "/home/runner/boostkit-perf/hyperscan" ]] || {
        log "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    }
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        rm -rf -- "${PERF_WORK_DIR}" || return 70
    fi
    log "cleaned standalone work directory: ${PERF_WORK_DIR}"
}

emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then
        stop_hyperscan_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_hyperscan_standalone() {
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
        if build_hyperscan; then
            if ! standalone_runtime build-info \
                "${RESULTS_DIR}/build_info.json" \
                "${SOFTWARE_VERSION}" \
                "${PERF_ACTUAL_VERSION_FILE}" \
                "$(normalize_arch "${EXPECTED_ARCH}")" \
                "${PERF_RUN_ID}"; then
                stage_status=40
                failed_stage="build"
            fi
        else
            stage_status=$?
            failed_stage="build"
        fi
    fi

    if [[ "${stage_status}" -eq 0 ]]; then
        if start_hyperscan_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi

    if [[ "${stage_status}" -eq 0 ]]; then
        if run_hyperscan_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_hyperscan_runtime; then
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
        "$(normalize_arch "${EXPECTED_ARCH}")" \
        "${PERF_RUN_ID}" \
        "${command_status}" \
        "${cleanup_status}" \
        "${failed_stage}"; then
        :
    else
        finalize_status=$?
    fi

    if [[ "${stage_status}" -ne 0 ]]; then
        trap - EXIT
        return "${stage_status}"
    fi
    if [[ "${cleanup_status}" != "passed" ]]; then
        trap - EXIT
        return 70
    fi
    trap - EXIT
    return "${finalize_status}"
}

usage() {
    cat <<USAGE
Usage: $(basename "$0") [OPTIONS]
Bootstrap the dependency chain, clone the official Hyperscan sources,
build the official hsbench tool, run the 6-scenario benchmark matrix
(2 scan modes x threads ${HYPERSCAN_THREADS_LADDER[*]}), collect the
environment, validate results, generate a report, and clean the
isolated work directory.

Options:
  --version VERSION       Hyperscan version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR,
  HYPERSCAN_SOURCE_URL, HYPERSCAN_BUILD_JOBS, HYPERSCAN_REPETITIONS,
  OPENSSL_GIT_BASE
USAGE
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version)
                [[ "$#" -ge 2 ]] || { log "ERROR: --version requires a value"; return 10; }
                SOFTWARE_VERSION="$2"
                shift 2
                ;;
            --results-dir)
                [[ "$#" -ge 2 ]] || { log "ERROR: --results-dir requires a value"; return 10; }
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
    run_hyperscan_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
