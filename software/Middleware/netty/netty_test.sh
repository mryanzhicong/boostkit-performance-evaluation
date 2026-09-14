#!/usr/bin/env bash
# Netty performance case (official Maven artifacts with an in-process echo
# benchmark harness).
#
# Netty is a library whose official distribution channel is Maven Central,
# so the software under test is the set of official io.netty artifacts
# (SHA-256 verified; the core jars are pure Java and therefore architecture
# independent).  The benchmark harness is compiled against those jars with
# javac — the same approach the Flink case uses for its pass-through job —
# and follows the official Netty echo-server pattern: an NIO (the default
# out-of-the-box transport) echo server plus pipelined framed clients run
# in one JVM over loopback, mirroring the single-machine benchmark style of
# the envoy case.
#
# Scenarios are message sizes (1 KiB / 16 KiB) crossed with the mysql-style
# connection ladder (128/256/512/1024).  Each run reports echo throughput
# and sampled round-trip latency percentiles from sequence-stamped frames.
#
# The four framework stages map to: fetch+verify the jars, provision the
# JDK, and compile the harness (build), smoke-run the harness end to end
# (start), run the full scenario matrix (test), and drop the benchmark
# data (stop).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="netty"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-4.2.18.Final}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

# Official Maven Central repository (the official Netty distribution).
NETTY_MAVEN_BASE="${NETTY_MAVEN_BASE:-https://repo1.maven.org/maven2/io/netty}"
NETTY_OFFLINE_DIR="${NETTY_OFFLINE_DIR:-/home/runner/software/netty}"

# Benchmark matrix: message sizes crossed with the connection ladder.
NETTY_MESSAGE_SCENARIOS=("1024:1KiB" "16384:16KiB")
NETTY_CONNECTIONS_LADDER=(128 256 512 1024)
NETTY_PIPELINE="${NETTY_PIPELINE:-8}"
NETTY_WARMUP_SECONDS="${NETTY_WARMUP_SECONDS:-5}"
NETTY_DURATION_SECONDS="${NETTY_DURATION_SECONDS:-30}"
JVM_HEAP_SIZE="${JVM_HEAP_SIZE:-2g}"

# Connection settings for the benchmark loopback listener.
NETTY_HOST="${NETTY_HOST:-127.0.0.1}"
NETTY_PORT="${NETTY_PORT:-}"

# Lifecycle paths (assigned in configure_runtime_paths).
NETTY_LIB_DIR=""
CLASSES_DIR=""
BENCHMARK_DIR=""
RUNS_DIR=""
BENCHMARK_CLASS="org.boostkit.performance.netty.EchoBenchmark"

log() {
    printf '[netty] %s\n' "$*"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/netty/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    NETTY_LIB_DIR="${PERF_WORK_DIR}/netty-lib"
    CLASSES_DIR="${PERF_WORK_DIR}/classes"
    BENCHMARK_DIR="${PERF_WORK_DIR}/benchmark"
    RUNS_DIR="${BENCHMARK_DIR}/runs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    if [[ -z "${NETTY_PORT}" ]]; then
        local checksum
        checksum="$(printf '%s' "${PERF_RUN_ID}" | cksum)"
        NETTY_PORT="$((20000 + ${checksum%% *} % 20000))"
    fi
    if [[ ! "${NETTY_PORT}" =~ ^[0-9]+$ ]] || \
       (( NETTY_PORT < 1024 || NETTY_PORT > 65535 )); then
        log "ERROR: NETTY_PORT must be an unprivileged TCP port: ${NETTY_PORT}"
        return 10
    fi
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}"
}

require_netty_tools() {
    local command_name package
    local packages=()

    for command_name in curl sha256sum cksum grep sed tee python3 java javac sudo; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            curl) package="curl" ;;
            sha256sum|cksum|tee) package="coreutils" ;;
            grep) package="grep" ;;
            sed) package="sed" ;;
            python3) package="python3" ;;
            java|javac) package="java-17-openjdk-devel" ;;
            sudo) package="sudo" ;;
        esac
        log "missing required Netty test command: ${command_name}"
        packages+=("${package}")
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log "ERROR: dnf is required to install Netty test prerequisites"
        return 30
    fi

    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log "installing missing Netty test packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log "ERROR: sudo is required to install Netty test prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log "ERROR: failed to install Netty test prerequisites"
        return 30
    fi

    for command_name in curl sha256sum cksum grep sed tee python3 java javac; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "ERROR: required Netty test command remains unavailable: ${command_name}"
            return 30
        fi
    done
}

verify_java_runtime() {
    local major

    major="$(java -version 2>&1 | sed -nE '1{s/.*version "([0-9]+).*/\1/p;}')"
    case "${major}" in
        11|17|21|25) ;;
        *)
            log "ERROR: Netty ${SOFTWARE_VERSION} requires Java 11 or newer; found: $(java -version 2>&1 | head -n 1)"
            return 30
            ;;
    esac
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

verify_sha256() {
    local archive_path="$1"
    local expected_sha256="$2"
    local actual_sha256

    actual_sha256="$(sha256sum "${archive_path}")"
    actual_sha256="${actual_sha256%% *}"
    if [[ "${actual_sha256}" != "${expected_sha256}" ]]; then
        log "ERROR: checksum mismatch for ${archive_path}: expected ${expected_sha256}, got ${actual_sha256}" >&2
        return 30
    fi
}

# The three core artifacts cover the default NIO transport with zero
# external dependencies (netty.io: "Netty has no mandatory external
# dependencies").  They are pure-Java jars, so both architectures share the
# same checksums.  Adding a version means adding its three entries here.
netty_artifact_sha256() {
    case "${SOFTWARE_VERSION}:$1" in
        4.2.18.Final:netty-common) printf '%s\n' "5d97cae5669685872339698efe13f74fe3cdb2dccdb36963b2352bd95acf7070" ;;
        4.2.18.Final:netty-buffer) printf '%s\n' "fdf236d2b76aa9710684401fdad7dff9dec56e43da5d39172c9a55ba5f14b360" ;;
        4.2.18.Final:netty-transport) printf '%s\n' "eac4f12068db4489e60c6520fad663e5d872f0436a7c641aa8e08db649947863" ;;
        *)
            log "ERROR: no verified Netty release is declared for ${SOFTWARE_VERSION} ($1)"
            return 10
            ;;
    esac
}

fetch_netty_artifacts() {
    local artifact archive_name archive_path local_archive_path expected_sha256

    mkdir -p "${NETTY_LIB_DIR}"
    for artifact in netty-common netty-buffer netty-transport; do
        expected_sha256="$(netty_artifact_sha256 "${artifact}")" || return $?
        archive_name="${artifact}-${SOFTWARE_VERSION}.jar"
        archive_path="${NETTY_LIB_DIR}/${archive_name}"
        if [[ -s "${archive_path}" ]]; then
            log "using cached ${archive_name}"
        elif [[ -f "${NETTY_OFFLINE_DIR}/${archive_name}" ]]; then
            log "using local Netty artifact ${NETTY_OFFLINE_DIR}/${archive_name}" >&2
            cp "${NETTY_OFFLINE_DIR}/${archive_name}" "${archive_path}" || return 30
        else
            download_archive "${archive_path}" \
                "${NETTY_MAVEN_BASE}/${artifact}/${SOFTWARE_VERSION}/${archive_name}" || return 30
        fi
        verify_sha256 "${archive_path}" "${expected_sha256}" || return 30
    done
    log "official Netty ${SOFTWARE_VERSION} artifacts are staged"
}

compile_benchmark() {
    local source="${SCRIPT_DIR}/src/main/java/org/boostkit/performance/netty/EchoBenchmark.java"

    if [[ ! -f "${source}" ]]; then
        log "ERROR: the benchmark source is missing: ${source}"
        return 40
    fi
    rm -rf "${CLASSES_DIR}"
    mkdir -p "${CLASSES_DIR}"
    if ! javac -cp "${NETTY_LIB_DIR}/*" -d "${CLASSES_DIR}" "${source}"; then
        log "ERROR: failed to compile the echo benchmark harness"
        return 40
    fi
    if [[ ! -f "${CLASSES_DIR}/org/boostkit/performance/netty/EchoBenchmark.class" ]]; then
        log "ERROR: the compiled benchmark class is missing"
        return 40
    fi
}

run_benchmark_jvm() {
    java -Xms"${JVM_HEAP_SIZE}" -Xmx"${JVM_HEAP_SIZE}" \
        -cp "${NETTY_LIB_DIR}/*:${CLASSES_DIR}" "${BENCHMARK_CLASS}" "$@"
}

build_netty() {
    local actual_version
    local runner_architecture

    initialize_runtime || return $?
    runner_architecture="$(uname -m)"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    require_netty_tools || return $?
    verify_java_runtime || return $?
    if [[ -e "${CLASSES_DIR}" ]]; then
        log "ERROR: build output is not clean under ${CLASSES_DIR}"
        return 20
    fi

    fetch_netty_artifacts || return $?
    compile_benchmark || return $?

    actual_version="$(run_benchmark_jvm --version | sed -nE 's/^netty-common=//p' | head -n 1)"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: staged Netty is ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "Netty ${actual_version} staged with the compiled echo benchmark harness"
}

netty_port_in_use() {
    (exec 3<>"/dev/tcp/${NETTY_HOST}/${NETTY_PORT}") >/dev/null 2>&1
}

validate_run_report() {
    local report="$1"

    python3 - "${report}" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as report:
    payload = json.load(report)
for field in ("messages", "messages_per_second", "avg_rtt_ms", "p99_rtt_ms"):
    value = payload[field]
    assert isinstance(value, (int, float)) and value > 0, (field, value)
assert payload["duration_seconds"] > 0
PY
}

start_netty_runtime() {
    initialize_runtime || return $?
    if [[ ! -f "${CLASSES_DIR}/org/boostkit/performance/netty/EchoBenchmark.class" ]]; then
        log "ERROR: the benchmark harness is not built (run build first)"
        return 40
    fi
    if netty_port_in_use; then
        log "ERROR: a service is already reachable on ${NETTY_HOST}:${NETTY_PORT}"
        log "ERROR: refusing to benchmark against a pre-existing listener"
        return 20
    fi
    if [[ -e "${BENCHMARK_DIR}" ]]; then
        log "ERROR: benchmark directory is not clean: ${BENCHMARK_DIR}"
        return 20
    fi

    # Smoke-run the complete chain (server, clients, framing, JSON report)
    # once so the test stage only ever times a verified harness.
    mkdir -p "${BENCHMARK_DIR}"
    log "smoke-running the echo benchmark harness on port ${NETTY_PORT}"
    if ! run_benchmark_jvm \
            --port "${NETTY_PORT}" \
            --message-size 1024 \
            --connections 8 \
            --pipeline "${NETTY_PIPELINE}" \
            --warmup-seconds 1 \
            --duration-seconds 2 \
            --scenario "smoke" \
            --output "${BENCHMARK_DIR}/smoke.json"; then
        rm -rf "${BENCHMARK_DIR}"
        log "ERROR: the echo benchmark smoke run failed"
        return 40
    fi
    if ! validate_run_report "${BENCHMARK_DIR}/smoke.json"; then
        rm -rf "${BENCHMARK_DIR}"
        log "ERROR: the smoke run report is invalid"
        return 40
    fi
    rm -rf "${BENCHMARK_DIR}"
    log "Netty benchmark runtime is ready"
}

run_netty_benchmarks() {
    local raw_output
    local scenario size label slug
    local connections run_file

    initialize_runtime || return $?
    require_netty_tools || return $?
    if [[ ! -f "${CLASSES_DIR}/org/boostkit/performance/netty/EchoBenchmark.class" ]]; then
        log "ERROR: the benchmark harness is not built (run build first)"
        return 50
    fi

    raw_output="${RESULTS_DIR}/netty_echo_raw.log"
    mkdir -p "${BENCHMARK_DIR}"
    rm -rf "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"
    log "running the echo scenario matrix on port ${NETTY_PORT} (pipeline=${NETTY_PIPELINE}, warmup=${NETTY_WARMUP_SECONDS}s, duration=${NETTY_DURATION_SECONDS}s)"

    if ! (
        for scenario in "${NETTY_MESSAGE_SCENARIOS[@]}"; do
            size="${scenario%%:*}"
            label="${scenario##*:}"
            slug="$(( size / 1024 ))k"
            for connections in "${NETTY_CONNECTIONS_LADDER[@]}"; do
                run_file="${RUNS_DIR}/echo-${slug}-c${connections}.json"
                run_benchmark_jvm \
                    --port "${NETTY_PORT}" \
                    --message-size "${size}" \
                    --connections "${connections}" \
                    --pipeline "${NETTY_PIPELINE}" \
                    --warmup-seconds "${NETTY_WARMUP_SECONDS}" \
                    --duration-seconds "${NETTY_DURATION_SECONDS}" \
                    --scenario "echo ${label}" \
                    --output "${run_file}" || exit 50
                validate_run_report "${run_file}" || exit 50
            done
        done
    ) 2>&1 | tee "${raw_output}"; then
        log "ERROR: the echo benchmark matrix failed (see ${raw_output})"
        return 50
    fi

    python3 "${SCRIPT_DIR}/scripts/collect_netty_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" || return 50
    log "echo benchmark matrix completed"
}

stop_netty_runtime() {
    initialize_runtime || return $?
    log "Netty benchmark has no background service to stop"
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
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/netty/local-* || \
          "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/netty" ]]; then
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
        stop_netty_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_netty_standalone() {
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
        if build_netty; then
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
        if start_netty_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_netty_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_netty_runtime; then
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

Stage the official Netty ${SOFTWARE_VERSION} Maven artifacts, compile the
echo benchmark harness, and run the message-size x connection-count matrix
as a standalone performance evaluation. Results default to
results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       Netty version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR, NETTY_PORT,
  NETTY_PIPELINE, NETTY_WARMUP_SECONDS, NETTY_DURATION_SECONDS,
  JVM_HEAP_SIZE
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
    run_netty_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
