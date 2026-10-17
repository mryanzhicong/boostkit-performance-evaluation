#!/usr/bin/env bash
# fbthrift performance case (official same-tag release-train sources with
# the upstream thrift/perf/cpp2 benchmark harness).
#
# fbthrift is Meta's C++ Apache Thrift implementation.  It is released in
# lockstep with its runtime dependencies — folly, fizz, wangle, mvfst —
# under identical vYYYY.MM.DD.00 tags, so the software under test is the
# five-repo combination cloned from the official repositories at the
# same dated tag and compiled entirely inside the isolated work
# directory (nothing is installed system-wide).
#
# The third-party libraries the five repos need (zlib, xxHash, zstd,
# gflags, glog, openssl, libevent, fmt, double-conversion, fast_float,
# boost) are also source-built into the same isolated prefix; boost
# comes from the official GitHub release tarball with SHA-256
# verification, everything else from its official git tag (git tag
# semantics being the equivalent of the tarball checksums other cases
# use).  The chain is built in dependency order: folly -> fizz ->
# wangle -> mvfst -> fbthrift, each one consuming the previously
# installed packages from the prefix.
#
# The benchmark itself is the upstream harness from thrift/perf/cpp2:
# the official LoadTest-family IDL (Api/ApiBase/StreamApi), the
# official server (ThriftServer + BenchmarkHandler) and the official
# client (one event base per client thread, weighted operation
# distribution, max 100 outstanding async ops).  The only upstream
# deviation is the http2 transport branch, which needs proxygen and is
# not part of the standalone fbthrift CMake build (header and rocket
# are); the scenarios use the rocket transport, fbthrift's flagship
# protocol stack.  On top of the upstream per-second QPS stats the
# harness adds a sampled round-trip latency recorder so each scenario
# reports avg/p50/p99/max latency in nanoseconds
# (std::chrono::steady_clock, the C++ equivalent of
# CLOCK_MONOTONIC — ns on every architecture).
#
# Scenarios are three workloads crossed with the mysql-style client
# ladder (1/4/16/64 client threads):
#
#   noop:      official async_eb noop — the empty request/response
#              round trip, the pure RPC overhead path.
#   sum:       official async_eb sum(TwoInts)->TwoInts — small-payload
#              serialization + deserialization on both ends.
#   download:  official sync download()->Chunk2 — 1 KiB payload
#              response (official chunk_size default) on the worker
#              path.
#
# The four framework stages map to: clone+verify+build the sources and
# the harness (build), smoke-run server+client end to end (start), run
# the full scenario matrix (test), and stop the server and drop the
# benchmark data (stop).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="fbthrift"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-2026.09.14.00}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

# The five lockstep repositories (official upstream).
FBTHRIFT_GIT_BASE="${FBTHRIFT_GIT_BASE:-https://github.com/facebook/fbthrift}"
FOLLY_GIT_BASE="${FOLLY_GIT_BASE:-https://github.com/facebook/folly}"
FIZZ_GIT_BASE="${FIZZ_GIT_BASE:-https://github.com/facebookincubator/fizz}"
WANGLE_GIT_BASE="${WANGLE_GIT_BASE:-https://github.com/facebook/wangle}"
MVFST_GIT_BASE="${MVFST_GIT_BASE:-https://github.com/facebook/mvfst}"

# Third-party dependency versions (official upstream tags; the boost
# tarball ships an official SHA-256 alongside the release asset).
DEP_ZLIB_TAG="v1.3.1"
DEP_XXHASH_TAG="v0.8.3"
DEP_ZSTD_TAG="v1.5.7"
DEP_GFLAGS_TAG="v2.2.2"
DEP_GLOG_TAG="v0.7.1"
DEP_LIBEVENT_TAG="release-2.1.12-stable"
DEP_FMT_TAG="11.2.0"
DEP_DOUBLE_CONVERSION_TAG="v3.3.1"
DEP_FAST_FLOAT_TAG="v8.2.9"
DEP_OPENSSL_TAG="openssl-3.6.4"
DEP_LIBSODIUM_VERSION="1.0.22"
DEP_LIBSODIUM_SHA256="adbdd8f16149e81ac6078a03aca6fc03b592b89ef7b5ed83841c086191be3349"
DEP_LIBSODIUM_URL="https://github.com/jedisct1/libsodium/releases/download/${DEP_LIBSODIUM_VERSION}-RELEASE/libsodium-${DEP_LIBSODIUM_VERSION}.tar.gz"
DEP_BOOST_VERSION="1.88.0"
DEP_BOOST_SHA256="f48b48390380cfb94a629872346e3a81370dc498896f16019ade727ab72eb1ec"
DEP_BOOST_SIZE="99990208"
DEP_BOOST_URL="https://github.com/boostorg/boost/releases/download/boost-${DEP_BOOST_VERSION}/boost-${DEP_BOOST_VERSION}-cmake.tar.xz"

# Benchmark matrix: workloads crossed with the client ladder.
FBTHRIFT_WORKLOADS=("noop" "sum" "download")
FBTHRIFT_CLIENTS_LADDER=(1 4 16 64)
FBTHRIFT_WARMUP_SECONDS="${FBTHRIFT_WARMUP_SECONDS:-5}"
FBTHRIFT_DURATION_SECONDS="${FBTHRIFT_DURATION_SECONDS:-30}"
FBTHRIFT_TRANSPORT="${FBTHRIFT_TRANSPORT:-rocket}"
FBTHRIFT_PORT="${FBTHRIFT_PORT:-7777}"
FBTHRIFT_SERVER_THREADS="${FBTHRIFT_SERVER_THREADS:-0}"
FBTHRIFT_CHUNK_SIZE="${FBTHRIFT_CHUNK_SIZE:-1024}"
FBTHRIFT_MAX_OUTSTANDING_OPS="${FBTHRIFT_MAX_OUTSTANDING_OPS:-100}"
FBTHRIFT_BUILD_JOBS="${FBTHRIFT_BUILD_JOBS:-$(nproc)}"

# Lifecycle paths (assigned in configure_runtime_paths).
SOURCE_ROOT=""
DEPS_SRC_DIR=""
PREFIX_DIR=""
HARNESS_BUILD_DIR=""
BENCHMARK_DIR=""
RUNS_DIR=""
SERVER_BIN=""
CLIENT_BIN=""
THRIFT1_BIN=""

log() {
    printf '[fbthrift] %s\n' "$*"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/fbthrift/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_ROOT="${PERF_WORK_DIR}/repos"
    DEPS_SRC_DIR="${PERF_WORK_DIR}/deps-src"
    PREFIX_DIR="${PERF_WORK_DIR}/prefix"
    HARNESS_BUILD_DIR="${PERF_WORK_DIR}/harness-build"
    BENCHMARK_DIR="${PERF_WORK_DIR}/benchmark"
    RUNS_DIR="${BENCHMARK_DIR}/runs"
    SERVER_BIN="${HARNESS_BUILD_DIR}/perf_server"
    CLIENT_BIN="${HARNESS_BUILD_DIR}/perf_client"
    THRIFT1_BIN="${PREFIX_DIR}/bin/thrift1"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}"
}

require_fbthrift_tools() {
    local command_name
    local packages=()

    for command_name in git curl cmake gcc g++ make python3 tee; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "missing required fbthrift test command: ${command_name}"
            packages+=("${command_name}")
        fi
    done
    if [[ "${#packages[@]}" -ne 0 ]]; then
        log "ERROR: install the required tools first: ${packages[*]}"
        return 30
    fi

    # The lockstep sources need C++20.
    local gxx_major
    gxx_major="$(g++ -dumpversion | cut -d. -f1)"
    if [[ -z "${gxx_major}" || "${gxx_major}" -lt 10 ]]; then
        log "ERROR: g++ ${gxx_major} is too old, the fbthrift sources need C++20 (g++ >= 10)"
        return 30
    fi
    local cmake_version cmake_major cmake_minor cmake_rest
    cmake_version="$(cmake --version | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)"
    cmake_major="${cmake_version%%.*}"
    cmake_rest="${cmake_version#*.}"
    cmake_minor="${cmake_rest%%.*}"
    if [[ -z "${cmake_major}" || "${cmake_major}" -lt 3 || \
          ( "${cmake_major}" -eq 3 && "${cmake_minor}" -lt 20 ) ]]; then
        log "ERROR: cmake ${cmake_version:-unknown} is too old, the harness build needs cmake >= 3.20"
        return 30
    fi
}

# The official distribution channel for every repository here is git,
# so the sources are verified by cloning the exact release tag and
# requiring an exact-match describe afterwards (git tag semantics, the
# equivalent of the tarball checksums other cases use).
fbthrift_tag() {
    printf 'v%s\n' "${SOFTWARE_VERSION}"
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

fetch_chain_sources() {
    local tag
    tag="$(fbthrift_tag)"
    mkdir -p "${SOURCE_ROOT}"
    clone_tagged_repo fbthrift "${FBTHRIFT_GIT_BASE}" "${tag}" "${SOURCE_ROOT}/fbthrift"
    clone_tagged_repo folly "${FOLLY_GIT_BASE}" "${tag}" "${SOURCE_ROOT}/folly"
    clone_tagged_repo fizz "${FIZZ_GIT_BASE}" "${tag}" "${SOURCE_ROOT}/fizz"
    clone_tagged_repo wangle "${WANGLE_GIT_BASE}" "${tag}" "${SOURCE_ROOT}/wangle"
    clone_tagged_repo mvfst "${MVFST_GIT_BASE}" "${tag}" "${SOURCE_ROOT}/mvfst"
}

fetch_dependency_sources() {
    mkdir -p "${DEPS_SRC_DIR}"
    clone_tagged_repo zlib "https://github.com/madler/zlib" "${DEP_ZLIB_TAG}" "${DEPS_SRC_DIR}/zlib"
    clone_tagged_repo xxHash "https://github.com/Cyan4973/xxHash" "${DEP_XXHASH_TAG}" "${DEPS_SRC_DIR}/xxhash"
    clone_tagged_repo zstd "https://github.com/facebook/zstd" "${DEP_ZSTD_TAG}" "${DEPS_SRC_DIR}/zstd"
    clone_tagged_repo gflags "https://github.com/gflags/gflags" "${DEP_GFLAGS_TAG}" "${DEPS_SRC_DIR}/gflags"
    clone_tagged_repo glog "https://github.com/google/glog" "${DEP_GLOG_TAG}" "${DEPS_SRC_DIR}/glog"
    clone_tagged_repo libevent "https://github.com/libevent/libevent" "${DEP_LIBEVENT_TAG}" "${DEPS_SRC_DIR}/libevent"
    clone_tagged_repo fmt "https://github.com/fmtlib/fmt" "${DEP_FMT_TAG}" "${DEPS_SRC_DIR}/fmt"
    clone_tagged_repo double-conversion "https://github.com/google/double-conversion" "${DEP_DOUBLE_CONVERSION_TAG}" "${DEPS_SRC_DIR}/double-conversion"
    clone_tagged_repo fast_float "https://github.com/fastfloat/fast_float" "${DEP_FAST_FLOAT_TAG}" "${DEPS_SRC_DIR}/fast_float"
    clone_tagged_repo openssl "https://github.com/openssl/openssl" "${DEP_OPENSSL_TAG}" "${DEPS_SRC_DIR}/openssl"
}

fetch_libsodium_source() {
    if [[ -d "${DEPS_SRC_DIR}/libsodium-${DEP_LIBSODIUM_VERSION}" ]]; then
        return 0
    fi
    log "downloading the official libsodium ${DEP_LIBSODIUM_VERSION} tarball"
    # Fresh file per attempt (no -C - resume: a retry that re-serves an
    # overlapping range would corrupt the tarball; at 2MiB a full
    # restart per retry is cheap).
    if ! curl -fL --retry 10 --retry-all-errors --retry-delay 5 \
            -o "${DEPS_SRC_DIR}/libsodium-${DEP_LIBSODIUM_VERSION}.tar.gz" \
            "${DEP_LIBSODIUM_URL}" \
            > "${PERF_WORK_DIR}/libsodium-download.log" 2>&1; then
        log "ERROR: the libsodium tarball download failed (see ${PERF_WORK_DIR}/libsodium-download.log)"
        return 30
    fi
    log "verifying the libsodium tarball SHA-256"
    if ! (cd "${DEPS_SRC_DIR}" && \
          echo "${DEP_LIBSODIUM_SHA256}  libsodium-${DEP_LIBSODIUM_VERSION}.tar.gz" | sha256sum -c -); then
        log "ERROR: the libsodium tarball SHA-256 mismatch"
        return 30
    fi
    if ! tar xf "${DEPS_SRC_DIR}/libsodium-${DEP_LIBSODIUM_VERSION}.tar.gz" \
            -C "${DEPS_SRC_DIR}"; then
        log "ERROR: failed to extract the libsodium tarball"
        return 30
    fi
}

fetch_boost_source() {
    local tarball="${DEPS_SRC_DIR}/boost-cmake.tar.xz"
    if [[ -d "${DEPS_SRC_DIR}/boost-${DEP_BOOST_VERSION}" ]]; then
        return 0
    fi
    log "downloading the official boost ${DEP_BOOST_VERSION} cmake tarball"
    # Chunked range download: the release CDN sometimes resets
    # mid-stream, and curl's retry+resume (-C -) can corrupt the file
    # when a retry re-serves an overlapping range.  Each 4MiB chunk is
    # fetched into a scratch file, size-verified, and only then
    # appended; the assembled tarball is verified by SHA-256.
    local chunk=4194304 start end expect got try
    : > "${tarball}"
    : > "${tarball}.chunk"
    start=0
    while [[ "${start}" -lt "${DEP_BOOST_SIZE}" ]]; do
        end=$((start + chunk - 1))
        if [[ "${end}" -ge "${DEP_BOOST_SIZE}" ]]; then
            end=$((DEP_BOOST_SIZE - 1))
        fi
        expect=$((end - start + 1))
        got=0
        for try in $(seq 1 15); do
            : > "${tarball}.chunk"
            curl -fsL --max-time 900 -r "${start}-${end}" \
                -o "${tarball}.chunk" "${DEP_BOOST_URL}" 2>/dev/null || true
            got="$(stat -c %s "${tarball}.chunk" 2>/dev/null || echo 0)"
            [[ "${got}" -eq "${expect}" ]] && break
        done
        if [[ "${got}" -ne "${expect}" ]]; then
            log "ERROR: the boost chunk at offset ${start} did not verify (got ${got}, expected ${expect})"
            return 30
        fi
        cat "${tarball}.chunk" >> "${tarball}"
        start=$((end + 1))
    done
    : > "${tarball}.chunk"
    log "verifying the boost tarball SHA-256"
    if ! (cd "${DEPS_SRC_DIR}" && \
          echo "${DEP_BOOST_SHA256}  boost-cmake.tar.xz" | sha256sum -c -); then
        log "ERROR: the boost tarball SHA-256 mismatch"
        return 30
    fi
    mkdir -p "${DEPS_SRC_DIR}/boost-${DEP_BOOST_VERSION}"
    if ! tar xf "${tarball}" \
            -C "${DEPS_SRC_DIR}/boost-${DEP_BOOST_VERSION}" --strip-components=1; then
        log "ERROR: failed to extract the boost tarball"
        return 30
    fi
}

# build_cmake_dep <name> <srcdir> [extra cmake args...]
build_cmake_dep() {
    local name="$1" srcdir="$2"
    shift 2
    if [[ -f "${PREFIX_DIR}/.dep-${name}-ok" ]]; then
        return 0
    fi
    log "building dependency ${name}"
    if ! cmake -S "${srcdir}" -B "${PERF_WORK_DIR}/build-${name}" \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_INSTALL_PREFIX="${PREFIX_DIR}" \
            -DCMAKE_PREFIX_PATH="${PREFIX_DIR}" \
            -DBUILD_SHARED_LIBS=ON -DBUILD_TESTING=OFF \
            "$@" > "${PERF_WORK_DIR}/${name}-conf.log" 2>&1; then
        log "ERROR: ${name} cmake configure failed (see ${PERF_WORK_DIR}/${name}-conf.log)"
        return 40
    fi
    if ! cmake --build "${PERF_WORK_DIR}/build-${name}" -j "${FBTHRIFT_BUILD_JOBS}" \
            > "${PERF_WORK_DIR}/${name}-build.log" 2>&1; then
        log "ERROR: ${name} build failed (see ${PERF_WORK_DIR}/${name}-build.log)"
        return 40
    fi
    if ! cmake --install "${PERF_WORK_DIR}/build-${name}" \
            > "${PERF_WORK_DIR}/${name}-install.log" 2>&1; then
        log "ERROR: ${name} install failed"
        return 40
    fi
    touch "${PREFIX_DIR}/.dep-${name}-ok"
    log "dependency ${name} installed"
}

build_dependencies() {
    fetch_dependency_sources || return $?
    fetch_boost_source || return $?
    mkdir -p "${PREFIX_DIR}"

    build_cmake_dep zlib "${DEPS_SRC_DIR}/zlib"
    build_cmake_dep xxhash "${DEPS_SRC_DIR}/xxhash/cmake_unofficial" -DXXH_BUILD_UTILITY=OFF
    build_cmake_dep zstd "${DEPS_SRC_DIR}/zstd/build/cmake" \
        -DZSTD_BUILD_SHARED=ON -DZSTD_BUILD_PROGRAMS=OFF -DZSTD_BUILD_TESTS=OFF -DZSTD_LEGACY_SUPPORT=OFF
    build_cmake_dep gflags "${DEPS_SRC_DIR}/gflags" -DGFLAGS_BUILD_TESTING=OFF
    build_cmake_dep glog "${DEPS_SRC_DIR}/glog" -DWITH_PKGCONFIG=ON

    # openssl precedes libevent, whose CMake build find_package()s it.
    if [[ ! -f "${PREFIX_DIR}/.dep-openssl-ok" ]]; then
        log "building dependency openssl (official Configure)"
        if ! (cd "${DEPS_SRC_DIR}/openssl" && \
              ./config --prefix="${PREFIX_DIR}" --openssldir="${PREFIX_DIR}/ssl" shared -fPIC \
              > "${PERF_WORK_DIR}/openssl-conf.log" 2>&1 && \
              make -j "${FBTHRIFT_BUILD_JOBS}" \
              > "${PERF_WORK_DIR}/openssl-build.log" 2>&1 && \
              make install_sw \
              > "${PERF_WORK_DIR}/openssl-install.log" 2>&1); then
            log "ERROR: openssl build failed (see ${PERF_WORK_DIR}/openssl-build.log)"
            return 40
        fi
        touch "${PREFIX_DIR}/.dep-openssl-ok"
        log "dependency openssl installed"
    fi

    build_cmake_dep libevent "${DEPS_SRC_DIR}/libevent" \
        -DEVENT__DISABLE_TESTS=ON -DEVENT__DISABLE_SAMPLES=ON \
        -DEVENT__LIBRARY_TYPE=SHARED -DOPENSSL_ROOT_DIR="${PREFIX_DIR}"
    build_cmake_dep fmt "${DEPS_SRC_DIR}/fmt" -DFMT_TEST=OFF -DFMT_DOC=OFF
    build_cmake_dep double-conversion "${DEPS_SRC_DIR}/double-conversion"
    build_cmake_dep fast_float "${DEPS_SRC_DIR}/fast_float" \
        -DFASTFLOAT_TEST=OFF -DFASTFLOAT_EXAMPLES=OFF

    # fizz hard-requires libsodium (find_package(Sodium REQUIRED)), and
    # the release tarball ships a pre-generated configure script, so no
    # autotools are needed on the host.
    fetch_libsodium_source || return $?
    if [[ ! -f "${PREFIX_DIR}/.dep-libsodium-ok" ]]; then
        log "building dependency libsodium (official configure)"
        if ! (cd "${DEPS_SRC_DIR}/libsodium-${DEP_LIBSODIUM_VERSION}" && \
              ./configure --prefix="${PREFIX_DIR}" \
              > "${PERF_WORK_DIR}/libsodium-conf.log" 2>&1 && \
              make -j "${FBTHRIFT_BUILD_JOBS}" \
              > "${PERF_WORK_DIR}/libsodium-build.log" 2>&1 && \
              make install \
              > "${PERF_WORK_DIR}/libsodium-install.log" 2>&1); then
            log "ERROR: libsodium build failed (see ${PERF_WORK_DIR}/libsodium-build.log)"
            return 40
        fi
        touch "${PREFIX_DIR}/.dep-libsodium-ok"
        log "dependency libsodium installed"
    fi

    # The boost cmake tarball is the exact variant fbthrift's own
    # FetchContent fallback requests.  The library list covers the
    # compiled components the chain links (folly's four + thread,
    # which folly's installed package config requires unconditionally)
    # plus every header-only library the folly/fbthrift sources
    # include (algorithm container functional function_types
    # interprocess intrusive iterator mpl multi_index preprocessor
    # range smart_ptr sort uuid random).
    build_cmake_dep boost "${DEPS_SRC_DIR}/boost-${DEP_BOOST_VERSION}" \
        -DBOOST_INCLUDE_LIBRARIES="context;filesystem;program_options;regex;thread;algorithm;container;functional;function_types;interprocess;intrusive;iterator;mpl;multi_index;preprocessor;range;smart_ptr;sort;uuid;random" \
        -DBOOST_ENABLE_PYTHON=OFF -DBOOST_ENABLE_MPI=OFF
}

# build_chain_repo <name> <srcdir> [extra cmake args...]
build_chain_repo() {
    local name="$1" srcdir="$2"
    shift 2
    if [[ -f "${PREFIX_DIR}/.chain-${name}-ok" ]]; then
        return 0
    fi
    log "building ${name} ${SOFTWARE_VERSION} into the isolated prefix"
    if ! cmake -S "${srcdir}" -B "${PERF_WORK_DIR}/build-${name}" \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_INSTALL_PREFIX="${PREFIX_DIR}" \
            -DCMAKE_PREFIX_PATH="${PREFIX_DIR}" \
            -DBUILD_SHARED_LIBS=ON -DBUILD_TESTING=OFF \
            "$@" > "${PERF_WORK_DIR}/${name}-conf.log" 2>&1; then
        log "ERROR: ${name} cmake configure failed (see ${PERF_WORK_DIR}/${name}-conf.log)"
        return 40
    fi
    if ! cmake --build "${PERF_WORK_DIR}/build-${name}" -j "${FBTHRIFT_BUILD_JOBS}" \
            > "${PERF_WORK_DIR}/${name}-build.log" 2>&1; then
        log "ERROR: ${name} build failed (see ${PERF_WORK_DIR}/${name}-build.log)"
        return 40
    fi
    if ! cmake --install "${PERF_WORK_DIR}/build-${name}" \
            > "${PERF_WORK_DIR}/${name}-install.log" 2>&1; then
        log "ERROR: ${name} install failed"
        return 40
    fi
    touch "${PREFIX_DIR}/.chain-${name}-ok"
    log "${name} installed into the isolated prefix"
}

build_chain() {
    build_chain_repo folly "${SOURCE_ROOT}/folly" \
        -DBUILD_TESTS=OFF -DBUILD_BENCHMARKS=OFF
    build_chain_repo fizz "${SOURCE_ROOT}/fizz/fizz" \
        -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF
    build_chain_repo wangle "${SOURCE_ROOT}/wangle/wangle" -DBUILD_TESTS=OFF
    build_chain_repo mvfst "${SOURCE_ROOT}/mvfst" \
        -DBUILD_TESTS=OFF -DBUILD_TOOLINGS=OFF
    build_chain_repo fbthrift "${SOURCE_ROOT}/fbthrift" \
        -DTHRIFT_BENCHMARKS=OFF -DTHRIFT_PY_DEPRECATED=OFF
}

build_harness() {
    if [[ -x "${SERVER_BIN}" && -x "${CLIENT_BIN}" ]]; then
        return 0
    fi
    log "configuring the upstream thrift/perf/cpp2 harness"
    if ! cmake -S "${SCRIPT_DIR}/src" -B "${HARNESS_BUILD_DIR}" \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_PREFIX_PATH="${PREFIX_DIR}" \
            -DFBTHRIFT_PREFIX="${PREFIX_DIR}" \
            -DCMAKE_INSTALL_RPATH="${PREFIX_DIR}/lib;${PREFIX_DIR}/lib64" \
            > "${PERF_WORK_DIR}/harness-conf.log" 2>&1; then
        log "ERROR: harness cmake configure failed (see ${PERF_WORK_DIR}/harness-conf.log)"
        return 40
    fi
    if ! cmake --build "${HARNESS_BUILD_DIR}" -j "${FBTHRIFT_BUILD_JOBS}" \
            > "${PERF_WORK_DIR}/harness-build.log" 2>&1; then
        log "ERROR: harness build failed (see ${PERF_WORK_DIR}/harness-build.log)"
        return 40
    fi
    if [[ ! -x "${SERVER_BIN}" || ! -x "${CLIENT_BIN}" ]]; then
        log "ERROR: the harness binaries are missing"
        return 40
    fi
    log "benchmark harness built (perf_server, perf_client)"
}

build_fbthrift() {
    local actual_version
    local runner_architecture

    initialize_runtime || return $?
    runner_architecture="$(uname -m)"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    require_fbthrift_tools || return $?
    if [[ -e "${HARNESS_BUILD_DIR}" ]]; then
        log "ERROR: build output is not clean under ${HARNESS_BUILD_DIR}"
        return 20
    fi

    fetch_chain_sources || return $?
    build_dependencies || return $?
    build_chain || return $?
    if [[ ! -x "${THRIFT1_BIN}" ]]; then
        log "ERROR: the fbthrift build did not install the thrift1 compiler"
        return 40
    fi
    build_harness || return $?

    # thrift1 has no --version; the exact-tag git describe performed at
    # clone time is the version record for the lockstep sources.
    actual_version="$(git -C "${SOURCE_ROOT}/fbthrift" describe --tags --exact-match)"
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version#v}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "fbthrift ${actual_version} staged with the upstream perf harness"
}

start_benchmark_server() { # logfile
    local logfile="$1"
    if [[ -e "${BENCHMARK_DIR}/server.pid" ]]; then
        log "ERROR: a benchmark server pid file already exists"
        return 1
    fi
    log "starting the benchmark server on port ${FBTHRIFT_PORT}"
    LD_LIBRARY_PATH="${PREFIX_DIR}/lib:${PREFIX_DIR}/lib64" \
        "${SERVER_BIN}" \
        --port="${FBTHRIFT_PORT}" \
        --io_threads="${FBTHRIFT_SERVER_THREADS}" \
        --cpu_threads="${FBTHRIFT_SERVER_THREADS}" \
        --stats_interval_sec=5 \
        --logtostderr=true \
        > "${logfile}" 2>&1 &
    local server_pid=$!
    printf '%s\n' "${server_pid}" > "${BENCHMARK_DIR}/server.pid"

    local attempt
    for attempt in $(seq 1 120); do
        if ! kill -0 "${server_pid}" 2>/dev/null; then
            log "ERROR: the benchmark server exited during startup (see ${logfile})"
            return 1
        fi
        if (exec 3<>"/dev/tcp/127.0.0.1/${FBTHRIFT_PORT}") 2>/dev/null; then
            log "benchmark server is ready (pid ${server_pid})"
            return 0
        fi
        sleep 0.5
    done
    log "ERROR: the benchmark server did not become ready (see ${logfile})"
    return 1
}

stop_benchmark_server() {
    local pidfile="${BENCHMARK_DIR}/server.pid"
    local pid

    if [[ ! -s "${pidfile}" ]]; then
        return 0
    fi
    pid="$(cat "${pidfile}")"
    if kill -0 "${pid}" 2>/dev/null; then
        log "stopping the benchmark server (pid ${pid})"
        kill -TERM "${pid}" 2>/dev/null || true
        local attempt
        for attempt in $(seq 1 20); do
            if ! kill -0 "${pid}" 2>/dev/null; then
                break
            fi
            sleep 0.5
        done
        if kill -0 "${pid}" 2>/dev/null; then
            log "benchmark server did not exit on SIGTERM, sending SIGKILL"
            kill -KILL "${pid}" 2>/dev/null || true
        fi
    fi
    # Reap the child if it is ours (an unreaped zombie would make every
    # later kill -0 check believe it is still running).
    wait "${pid}" 2>/dev/null || true
    rm -f "${pidfile}"
}

# run_client <workload> <clients> <terminate_sec> <warmup_sec> <logfile>
run_client() {
    local workload="$1" clients="$2" terminate_sec="$3" warmup_sec="$4" logfile="$5"

    LD_LIBRARY_PATH="${PREFIX_DIR}/lib:${PREFIX_DIR}/lib64" \
        "${CLIENT_BIN}" \
        --host=127.0.0.1 \
        --port="${FBTHRIFT_PORT}" \
        --transport="${FBTHRIFT_TRANSPORT}" \
        --num_clients="${clients}" \
        --"${workload}"_weight=1 \
        --max_outstanding_ops="${FBTHRIFT_MAX_OUTSTANDING_OPS}" \
        --chunk_size="${FBTHRIFT_CHUNK_SIZE}" \
        --warmup_sec="${warmup_sec}" \
        --stats_interval_sec=1 \
        --terminate_sec="${terminate_sec}" \
        --logtostderr=true \
        > "${logfile}" 2>&1
}

validate_client_log() { # logfile (needs live QPS stats and latency samples)
    local logfile="$1"
    if ! grep -q "TOTAL QPS:" "${logfile}"; then
        log "ERROR: the client log has no QPS stats: ${logfile}"
        return 1
    fi
    # The client exits 0 even when every call errors (errors are just
    # counters), so the summary line itself must prove progress: a
    # zero-sample latency summary or an all-zero QPS window means the
    # server never actually answered.
    if ! grep -q "LATENCY ns" "${logfile}"; then
        log "ERROR: the client log has no latency summary: ${logfile}"
        return 1
    fi
    if grep -q "LATENCY ns .*samples: 0" "${logfile}"; then
        log "ERROR: the client recorded no latency samples: ${logfile}"
        return 1
    fi
    if ! grep -Eq "TOTAL QPS: [1-9]" "${logfile}"; then
        log "ERROR: the client recorded only zero QPS windows: ${logfile}"
        return 1
    fi
}

start_fbthrift_runtime() {
    local workload
    local smoke_dir

    initialize_runtime || return $?
    if [[ ! -x "${SERVER_BIN}" || ! -x "${CLIENT_BIN}" ]]; then
        log "ERROR: the benchmark harness is not built (run build first)"
        return 40
    fi
    if [[ -e "${BENCHMARK_DIR}" ]]; then
        log "ERROR: benchmark directory is not clean: ${BENCHMARK_DIR}"
        return 20
    fi

    # Smoke-run every workload once (server + 1 client, 3 seconds) so
    # the test stage only ever times a verified harness.
    mkdir -p "${BENCHMARK_DIR}"
    if ! start_benchmark_server "${BENCHMARK_DIR}/smoke-server.log"; then
        rm -rf "${BENCHMARK_DIR}"
        return 40
    fi
    for workload in "${FBTHRIFT_WORKLOADS[@]}"; do
        log "smoke-running the ${workload} workload"
        if ! run_client "${workload}" 1 3 0 "${BENCHMARK_DIR}/smoke-${workload}.log"; then
            stop_benchmark_server
            rm -rf "${BENCHMARK_DIR}"
            log "ERROR: the ${workload} smoke run failed"
            return 40
        fi
        if ! validate_client_log "${BENCHMARK_DIR}/smoke-${workload}.log"; then
            stop_benchmark_server
            rm -rf "${BENCHMARK_DIR}"
            return 40
        fi
    done
    stop_benchmark_server
    rm -rf "${BENCHMARK_DIR}"
    log "fbthrift benchmark runtime is ready"
}

run_fbthrift_benchmarks() {
    local raw_output
    local workload clients run_file

    initialize_runtime || return $?
    require_fbthrift_tools || return $?
    if [[ ! -x "${SERVER_BIN}" || ! -x "${CLIENT_BIN}" ]]; then
        log "ERROR: the benchmark harness is not built (run build first)"
        return 50
    fi

    raw_output="${RESULTS_DIR}/fbthrift_perf_raw.log"
    mkdir -p "${BENCHMARK_DIR}"
    rm -rf "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"
    if ! start_benchmark_server "${BENCHMARK_DIR}/server.log"; then
        return 50
    fi

    log "running the perf scenario matrix (transport=${FBTHRIFT_TRANSPORT}, warmup=${FBTHRIFT_WARMUP_SECONDS}s, duration=${FBTHRIFT_DURATION_SECONDS}s)"
    if ! (
        for workload in "${FBTHRIFT_WORKLOADS[@]}"; do
            for clients in "${FBTHRIFT_CLIENTS_LADDER[@]}"; do
                run_file="${RUNS_DIR}/${workload}-c${clients}.log"
                log "scenario workload=${workload} clients=${clients}"
                run_client "${workload}" "${clients}" \
                    "$((FBTHRIFT_WARMUP_SECONDS + FBTHRIFT_DURATION_SECONDS))" \
                    "${FBTHRIFT_WARMUP_SECONDS}" "${run_file}" || exit 50
                validate_client_log "${run_file}" || exit 50
            done
        done
    ) 2>&1 | tee "${raw_output}"; then
        stop_benchmark_server
        log "ERROR: the perf benchmark matrix failed (see ${raw_output})"
        return 50
    fi
    stop_benchmark_server

    FBTHRIFT_TRANSPORT="${FBTHRIFT_TRANSPORT}" \
    FBTHRIFT_WARMUP_SECONDS="${FBTHRIFT_WARMUP_SECONDS}" \
    FBTHRIFT_DURATION_SECONDS="${FBTHRIFT_DURATION_SECONDS}" \
        python3 "${SCRIPT_DIR}/scripts/collect_fbthrift_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" || return 50
    log "perf benchmark matrix completed"
}

stop_fbthrift_runtime() {
    initialize_runtime || return $?
    if [[ -d "${BENCHMARK_DIR}" ]]; then
        stop_benchmark_server
        rm -rf "${BENCHMARK_DIR}"
        log "benchmark run data removed from ${BENCHMARK_DIR}"
    else
        log "fbthrift benchmark has no run data to remove"
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
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/fbthrift/local-* || \
          "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/fbthrift" ]]; then
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
        stop_fbthrift_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_fbthrift_standalone() {
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
        if build_fbthrift; then
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
        if start_fbthrift_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_fbthrift_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_fbthrift_runtime; then
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

Build the official fbthrift ${SOFTWARE_VERSION} lockstep sources
(folly/fizz/wangle/mvfst/fbthrift at the same dated tag, plus the
source-built third-party dependencies) inside an isolated work
directory, compile the upstream thrift/perf/cpp2 benchmark harness
against that build, and run the workload x client-count matrix as a
standalone performance evaluation. Results default to
results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       fbthrift version tag body (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR,
  FBTHRIFT_TRANSPORT, FBTHRIFT_PORT, FBTHRIFT_SERVER_THREADS,
  FBTHRIFT_WARMUP_SECONDS, FBTHRIFT_DURATION_SECONDS,
  FBTHRIFT_CHUNK_SIZE, FBTHRIFT_MAX_OUTSTANDING_OPS,
  FBTHRIFT_BUILD_JOBS
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
                log "ERROR: unknown option: $1"
                usage
                return 10
                ;;
        esac
    done

    run_fbthrift_standalone
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
