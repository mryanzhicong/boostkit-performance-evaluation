#!/usr/bin/env bash
# SPDK performance case (official git repository with an in-process
# blobstore benchmark harness).
#
# SPDK is a C library framework whose official distribution channel is
# the git repository (github.com/spdk/spdk) with its dpdk submodule, so
# the software under test is the library set built from the official
# v<version> tag (shallow clone plus the required dpdk/isa-l submodules,
# configured with the official configure defaults and compiled entirely
# inside the isolated work directory — nothing is installed
# system-wide).  The benchmark harness is linked against that build's
# static libraries and drives the blobstore — the local-storage object
# layer every SPDK blob application is built on:
#
#   create: spdk_bs_create_blob + spdk_bs_delete_blob lifecycles — the
#           metadata path every blob provision walks.  1 op = one blob
#           created and deleted.
#   write:  4KiB spdk_blob_io_write bursts (queue depth 8) against a
#           preallocated 4MiB blob — the blob data write path.
#   read:   4KiB spdk_blob_io_read bursts (queue depth 8) against the
#           same blob — the blob read path.
#
# Each worker owns a private blobstore instance on its own spdk_thread
# (blobstore metadata operations run on the initializing thread, so one
# instance per worker is the deployment shape real applications use to
# scale blob I/O across cores).  The backing spdk_bs_dev is anonymous
# memory, so no host storage, hugepages, or PCI devices are touched.
# DPDK EAL runs with no-huge/no-pci/1GiB via the spdk_env_dpdk layer.
#
# Scenarios are the three workloads crossed with the mysql-style thread
# ladder (1/4/16/64).  Every operation is timed with
# clock_gettime(CLOCK_MONOTONIC), so latencies are in nanoseconds on
# every architecture.  Each run reports operation throughput and
# sampled per-operation latency percentiles.
#
# The four framework stages map to: clone+verify the tagged sources
# (build), smoke-run the harness end to end (start), run the full
# scenario matrix (test), and drop the benchmark data (stop).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="spdk"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-26.05}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

# Official SPDK upstream (the official SPDK distribution channel).
SPDK_GIT_BASE="${SPDK_GIT_BASE:-https://github.com/spdk/spdk}"
SPDK_OFFLINE_DIR="${SPDK_OFFLINE_DIR:-/home/runner/software/spdk}"

# Benchmark matrix: workloads crossed with the thread ladder.
SPDK_WORKLOADS=("create" "write" "read")
SPDK_THREADS_LADDER=(1 4 16 64)
SPDK_WARMUP_SECONDS="${SPDK_WARMUP_SECONDS:-5}"
SPDK_DURATION_SECONDS="${SPDK_DURATION_SECONDS:-30}"
SPDK_BUILD_JOBS="${SPDK_BUILD_JOBS:-$(nproc)}"

# Lifecycle paths (assigned in configure_runtime_paths).
SOURCE_DIR=""
BUILD_DIR=""
BENCHMARK_BIN=""
BENCHMARK_DIR=""
RUNS_DIR=""

log() {
    printf '[spdk] %s\n' "$*"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/spdk/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/spdk-${SOFTWARE_VERSION}"
    BENCHMARK_BIN="${PERF_WORK_DIR}/spdk_benchmark"
    BENCHMARK_DIR="${PERF_WORK_DIR}/benchmark"
    RUNS_DIR="${BENCHMARK_DIR}/runs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}"
}

require_spdk_tools() {
    local command_name package
    local packages=()

    for command_name in curl git gcc make meson ninja pkg-config grep sed tee python3 stat; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            curl) package="curl" ;;
            git) package="git" ;;
            gcc) package="gcc" ;;
            make) package="make" ;;
            meson) package="meson" ;;
            ninja) package="ninja-build" ;;
            pkg-config) package="pkgconf" ;;
            grep) package="grep" ;;
            sed) package="sed" ;;
            tee|stat) package="coreutils" ;;
            python3) package="python3" ;;
        esac
        log "missing required spdk test command: ${command_name}"
        packages+=("${package}")
    done

    # The SPDK/dpdk build needs these python modules.
    if ! python3 -c "import elftools" >/dev/null 2>&1; then
        log "missing required spdk test python module: elftools"
        packages+=("python3-pyelftools")
    fi
    if ! python3 -c "import jinja2" >/dev/null 2>&1; then
        log "missing required spdk test python module: jinja2"
        packages+=("python3-jinja2")
    fi
    if ! python3 -c "import tabulate" >/dev/null 2>&1; then
        log "missing required spdk test python module: tabulate"
        packages+=("python3-tabulate")
    fi
    # SPDK's uuid/md5 helpers require the openssl and libuuid headers.
    if ! echo '#include <openssl/md5.h>' | cc -E - >/dev/null 2>&1; then
        log "missing required spdk test headers: openssl"
        packages+=("openssl-devel")
    fi
    if ! echo '#include <uuid/uuid.h>' | cc -E - >/dev/null 2>&1; then
        log "missing required spdk test headers: uuid"
        packages+=("libuuid-devel")
    fi

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log "ERROR: dnf is required to install spdk test prerequisites"
        return 30
    fi

    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log "installing missing spdk test packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log "ERROR: sudo is required to install spdk test prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log "ERROR: failed to install spdk test prerequisites"
        return 30
    fi

    for command_name in curl git gcc make meson ninja pkg-config python3; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "ERROR: required spdk test command remains unavailable: ${command_name}"
            return 30
        fi
    done
    if ! python3 -c "import elftools, jinja2, tabulate" >/dev/null 2>&1; then
        log "ERROR: required spdk test python modules remain unavailable"
        return 30
    fi
    if ! echo '#include <openssl/md5.h>' | cc -E - >/dev/null 2>&1; then
        log "ERROR: required spdk test openssl headers remain unavailable"
        return 30
    fi
    if ! echo '#include <uuid/uuid.h>' | cc -E - >/dev/null 2>&1; then
        log "ERROR: required spdk test uuid headers remain unavailable"
        return 30
    fi
}

# SPDK's official distribution channel is the git repository, so the
# sources are verified by cloning the exact release tag (git tag
# semantics, the equivalent of the tarball checksums other cases use).
# Adding a version means pointing the clone at its official tag.
spdk_tag() {
    printf 'v%s\n' "${SOFTWARE_VERSION}"
}

fetch_spdk_source() {
    local tag
    local described

    if [[ -s "${SOURCE_DIR}/configure" ]]; then
        log "using cached source tree ${SOURCE_DIR}"
        return 0
    fi
    tag="$(spdk_tag)"
    log "cloning the official spdk ${tag} sources"
    if [[ -d "${SPDK_OFFLINE_DIR}/spdk-${SOFTWARE_VERSION}" ]]; then
        log "using local spdk source ${SPDK_OFFLINE_DIR}/spdk-${SOFTWARE_VERSION}" >&2
        cp -a "${SPDK_OFFLINE_DIR}/spdk-${SOFTWARE_VERSION}" "${SOURCE_DIR}" || return 30
    else
        if ! git clone --depth 1 --branch "${tag}" "${SPDK_GIT_BASE}.git" \
                "${SOURCE_DIR}" > "${PERF_WORK_DIR}/git-clone.log" 2>&1; then
            rm -rf "${SOURCE_DIR}"
            log "ERROR: failed to clone ${SPDK_GIT_BASE} at ${tag} (see ${PERF_WORK_DIR}/git-clone.log)" >&2
            return 30
        fi
    fi
    if [[ ! -f "${SOURCE_DIR}/configure" ]]; then
        log "ERROR: the cloned source tree has no configure script"
        return 30
    fi
    described="$(git -C "${SOURCE_DIR}" describe --tags --exact-match 2>/dev/null || true)"
    if [[ "${described}" != "${tag}" ]]; then
        log "ERROR: the cloned source tree is ${described:-untagged}, expected ${tag}"
        return 30
    fi
    log "official spdk ${tag} source tree is ready (${SOURCE_DIR})"
}

build_spdk_libraries() {
    if [[ ! -f "${SOURCE_DIR}/build/lib/libspdk_blob.a" ]]; then
        log "configuring and building spdk (official configure defaults)"
        # The --without set trims every optional external dependency the
        # blobstore benchmark does not exercise, so the build needs only
        # gcc, python, meson/ninja, and the openssl/libuuid headers.
        # Tests, examples, and apps are disabled the same way.
        if ! (cd "${SOURCE_DIR}" && ./configure \
                --disable-tests --disable-unit-tests \
                --disable-examples --disable-apps \
                --without-vhost --without-virtio --without-vfio-user \
                --without-fsdev --without-crypto --without-uring \
                --without-rdma --without-iscsi-initiator --without-ocf \
                --without-xnvme --without-rbd --without-daos \
                --without-ublk --without-nvme-cuse --without-usdt \
                --without-sma --without-avahi --without-golang \
                --without-aio-fsdev --without-idxd --without-fio \
                --without-vtune --without-dpdk-compressdev \
                --without-dpdk-uadk --without-raid5f) \
                > "${PERF_WORK_DIR}/spdk-configure.log" 2>&1; then
            log "ERROR: spdk configure failed (see ${PERF_WORK_DIR}/spdk-configure.log)"
            return 40
        fi
        # Only the library layer is built: the benchmark links the blob
        # closure from build/lib, so the bdev/event module layer (and
        # its extra external dependencies, e.g. libaio) is never needed.
        # DPDKBUILD_FLAGS is the officially supported make variable for
        # extra dpdk meson options; max_numa_nodes=1 is the officially
        # documented single-NUMA-node build and removes the optional
        # libnuma dependency.
        if ! (cd "${SOURCE_DIR}" && make -C dpdkbuild \
                DPDKBUILD_FLAGS="-Dmax_numa_nodes=1" \
                -j"${SPDK_BUILD_JOBS}") \
                > "${PERF_WORK_DIR}/spdk-dpdkbuild.log" 2>&1; then
            log "ERROR: dpdk submodule build failed (see ${PERF_WORK_DIR}/spdk-dpdkbuild.log)"
            return 40
        fi
        if ! (cd "${SOURCE_DIR}" && make -C lib \
                -j"${SPDK_BUILD_JOBS}") \
                > "${PERF_WORK_DIR}/spdk-libbuild.log" 2>&1; then
            log "ERROR: spdk lib build failed (see ${PERF_WORK_DIR}/spdk-libbuild.log)"
            return 40
        fi
    fi
    if [[ ! -f "${SOURCE_DIR}/build/lib/libspdk_blob.a" ]]; then
        log "ERROR: the spdk build has no libspdk_blob.a"
        return 40
    fi
    log "spdk libraries are staged under ${SOURCE_DIR}/build"
}

compile_benchmark() {
    local source="${SCRIPT_DIR}/src/spdk_benchmark.c"
    local spdk_lib="${SOURCE_DIR}/build/lib"
    local pkgconfig_dir="${SOURCE_DIR}/dpdk/build/lib/pkgconfig"
    local dpdk_cflags
    local dpdk_libs

    if [[ ! -f "${source}" ]]; then
        log "ERROR: the benchmark source is missing: ${source}"
        return 40
    fi
    if [[ ! -f "${pkgconfig_dir}/libdpdk.pc" ]]; then
        log "ERROR: the spdk build has no dpdk libdpdk.pc"
        return 40
    fi
    export PKG_CONFIG_PATH="${pkgconfig_dir}"
    dpdk_cflags="$(pkg-config --cflags libdpdk)"
    dpdk_libs="$(pkg-config --libs --static libdpdk)"
    if [[ -z "${dpdk_libs}" ]]; then
        log "ERROR: pkg-config could not resolve the dpdk libraries"
        return 40
    fi
    # Static SPDK libs in dependency order (dependents first), then the
    # dpdk static set from the official libdpdk.pc metadata.
    if ! gcc -O2 -Wall -Wextra \
            -I"${SOURCE_DIR}/include" \
            ${dpdk_cflags} \
            -o "${BENCHMARK_BIN}" \
            "${source}" \
            -L"${spdk_lib}" \
            -Wl,--whole-archive -Wl,--no-as-needed \
            -lspdk_blob -lspdk_thread -lspdk_trace \
            -lspdk_rpc -lspdk_jsonrpc -lspdk_json \
            -lspdk_dma -lspdk_util -lspdk_log -lspdk_env_dpdk \
            -Wl,--no-whole-archive \
            ${dpdk_libs} \
            -lssl -lcrypto -luuid -lpthread -ldl -lrt -lm; then
        log "ERROR: failed to compile the blobstore benchmark harness"
        return 40
    fi
    if [[ ! -x "${BENCHMARK_BIN}" ]]; then
        log "ERROR: the compiled benchmark binary is missing"
        return 40
    fi
}

build_spdk() {
    local actual_version
    local version_major
    local version_minor
    local version_rest
    local runner_architecture

    initialize_runtime || return $?
    runner_architecture="$(uname -m)"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    require_spdk_tools || return $?
    if [[ -e "${BENCHMARK_BIN}" ]]; then
        log "ERROR: build output is not clean under ${BENCHMARK_BIN}"
        return 20
    fi

    fetch_spdk_source || return $?
    # The dpdk submodule is required by the spdk build (the isa-l and
    # other optional submodules are not: only the library layer is
    # built, which needs nothing beyond dpdk).
    if [[ ! -f "${SOURCE_DIR}/dpdk/meson.build" ]]; then
        log "initializing the dpdk submodule"
        if ! git -C "${SOURCE_DIR}" submodule update --init --depth 1 dpdk \
                >> "${PERF_WORK_DIR}/git-clone.log" 2>&1; then
            log "ERROR: failed to init the dpdk submodule (see ${PERF_WORK_DIR}/git-clone.log)"
            return 30
        fi
    fi
    build_spdk_libraries || return $?
    compile_benchmark || return $?

    # SPDK_VERSION_STRING reports "SPDK <major>.<minor>.<patch>"; the
    # major.minor part must match the requested version exactly.
    actual_version="$("${BENCHMARK_BIN}" --version | sed -nE 's/^spdk-version=SPDK v//p' | head -n 1)"
    version_major="${actual_version%%.*}"
    version_rest="${actual_version#*.}"
    version_minor="${version_rest%%.*}"
    if [[ -z "${actual_version}" || "${version_major}.${version_minor}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: staged spdk is ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "spdk ${actual_version} staged with the compiled blobstore benchmark harness"
}

validate_run_report() {
    local report="$1"

    python3 - "${report}" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as report:
    payload = json.load(report)
for field in ("operations", "operations_per_second", "avg_op_ns", "p99_op_ns"):
    value = payload[field]
    assert isinstance(value, (int, float)) and value > 0, (field, value)
assert payload["duration_seconds"] > 0
PY
}

start_spdk_runtime() {
    initialize_runtime || return $?
    if [[ ! -x "${BENCHMARK_BIN}" ]]; then
        log "ERROR: the benchmark harness is not built (run build first)"
        return 40
    fi
    if [[ -e "${BENCHMARK_DIR}" ]]; then
        log "ERROR: benchmark directory is not clean: ${BENCHMARK_DIR}"
        return 20
    fi

    # Smoke-run each workload once so the test stage only ever times a
    # verified harness.
    mkdir -p "${BENCHMARK_DIR}"
    local workload
    for workload in "${SPDK_WORKLOADS[@]}"; do
        log "smoke-running the ${workload} workload harness"
        if ! "${BENCHMARK_BIN}" \
                --workload "${workload}" \
                --threads 2 \
                --warmup-seconds 1 \
                --duration-seconds 2 \
                --scenario "smoke ${workload}" \
                --output "${BENCHMARK_DIR}/smoke-${workload}.json"; then
            rm -rf "${BENCHMARK_DIR}"
            log "ERROR: the ${workload} smoke run failed"
            return 40
        fi
        if ! validate_run_report "${BENCHMARK_DIR}/smoke-${workload}.json"; then
            rm -rf "${BENCHMARK_DIR}"
            log "ERROR: the ${workload} smoke run report is invalid"
            return 40
        fi
    done
    rm -rf "${BENCHMARK_DIR}"
    log "spdk benchmark runtime is ready"
}

run_spdk_benchmarks() {
    local raw_output
    local workload threads run_file

    initialize_runtime || return $?
    require_spdk_tools || return $?
    if [[ ! -x "${BENCHMARK_BIN}" ]]; then
        log "ERROR: the benchmark harness is not built (run build first)"
        return 50
    fi

    raw_output="${RESULTS_DIR}/spdk_blobstore_raw.log"
    mkdir -p "${BENCHMARK_DIR}"
    rm -rf "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"
    log "running the blobstore scenario matrix (warmup=${SPDK_WARMUP_SECONDS}s, duration=${SPDK_DURATION_SECONDS}s)"

    if ! (
        for workload in "${SPDK_WORKLOADS[@]}"; do
            for threads in "${SPDK_THREADS_LADDER[@]}"; do
                run_file="${RUNS_DIR}/${workload}-t${threads}.json"
                "${BENCHMARK_BIN}" \
                    --workload "${workload}" \
                    --threads "${threads}" \
                    --warmup-seconds "${SPDK_WARMUP_SECONDS}" \
                    --duration-seconds "${SPDK_DURATION_SECONDS}" \
                    --scenario "${workload}" \
                    --output "${run_file}" || exit 50
                validate_run_report "${run_file}" || exit 50
            done
        done
    ) 2>&1 | tee "${raw_output}"; then
        log "ERROR: the blobstore benchmark matrix failed (see ${raw_output})"
        return 50
    fi

    python3 "${SCRIPT_DIR}/scripts/collect_spdk_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" || return 50
    log "blobstore benchmark matrix completed"
}

stop_spdk_runtime() {
    initialize_runtime || return $?
    log "spdk benchmark has no background service to stop"
    if [[ -d "${BENCHMARK_DIR}" ]]; then
        rm -rf "${BENCHMARK_DIR}"
        log "benchmark run data removed from ${BENCHMARK_DIR}"
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
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/spdk/local-* || \
          "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/spdk" ]]; then
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
        stop_spdk_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_spdk_standalone() {
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
        if build_spdk; then
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
        if start_spdk_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_spdk_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_spdk_runtime; then
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

Build the official spdk ${SOFTWARE_VERSION} sources (git tag + dpdk
submodule) inside an isolated work directory, compile the blobstore
benchmark harness against that build, and run the workload x
thread-count matrix as a standalone performance evaluation. Results
default to results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       spdk version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR,
  SPDK_BUILD_JOBS, SPDK_WARMUP_SECONDS, SPDK_DURATION_SECONDS
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
    mkdir -p "${RESULTS_DIR}" || return 10
    : > "${RESULTS_DIR}/results.log"
    local pipeline_status=0
    set +e
    run_spdk_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
