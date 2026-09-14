#!/usr/bin/env bash
# gRPC-Java performance case (official Maven Central artifacts with an
# in-process unary-echo benchmark harness).
#
# gRPC-Java is a library whose official distribution channel is Maven
# Central, so the software under test is the official io.grpc artifact set
# plus its runtime dependency closure (SHA-256 verified; the jars are pure
# Java and therefore architecture independent).  The benchmark harness is
# compiled against those jars with javac — the same approach the Flink and
# Netty cases use — and follows the canonical gRPC "unary echo" shape: a
# hand-registered unary method (benchmark.Echo/Send) marshalled with a
# plain byte-array marshaller (no protobuf codegen involved) plus
# pipelined channels run in one JVM over loopback, mirroring the
# single-machine benchmark style of the envoy and Netty cases.
#
# Scenarios are message sizes (1 KiB / 16 KiB) crossed with the mysql-style
# channel ladder (128/256/512/1024).  Each run reports unary-call
# throughput and sampled round-trip latency percentiles from
# sequence-stamped frames.
#
# The four framework stages map to: fetch+verify the jars, provision the
# JDK, and compile the harness (build), smoke-run the harness end to end
# (start), run the full scenario matrix (test), and drop the benchmark
# data (stop).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="grpc-java"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.83.1}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

# Official Maven Central repository (the official gRPC-Java distribution).
GRPC_MAVEN_BASE="${GRPC_MAVEN_BASE:-https://repo1.maven.org/maven2}"
GRPC_OFFLINE_DIR="${GRPC_OFFLINE_DIR:-/home/runner/software/grpc-java}"

# Benchmark matrix: message sizes crossed with the channel ladder.
GRPC_MESSAGE_SCENARIOS=("1024:1KiB" "16384:16KiB")
GRPC_CHANNELS_LADDER=(128 256 512 1024)
GRPC_PIPELINE="${GRPC_PIPELINE:-8}"
GRPC_WARMUP_SECONDS="${GRPC_WARMUP_SECONDS:-5}"
GRPC_DURATION_SECONDS="${GRPC_DURATION_SECONDS:-30}"
JVM_HEAP_SIZE="${JVM_HEAP_SIZE:-2g}"

# Connection settings for the benchmark loopback listener.
GRPC_HOST="${GRPC_HOST:-127.0.0.1}"
GRPC_PORT="${GRPC_PORT:-}"

# Lifecycle paths (assigned in configure_runtime_paths).
GRPC_LIB_DIR=""
CLASSES_DIR=""
BENCHMARK_DIR=""
RUNS_DIR=""
BENCHMARK_CLASS="org.boostkit.performance.grpc.GrpcBenchmark"

log() {
    printf '[grpc-java] %s\n' "$*"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/grpc-java/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    GRPC_LIB_DIR="${PERF_WORK_DIR}/grpc-lib"
    CLASSES_DIR="${PERF_WORK_DIR}/classes"
    BENCHMARK_DIR="${PERF_WORK_DIR}/benchmark"
    RUNS_DIR="${BENCHMARK_DIR}/runs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    if [[ -z "${GRPC_PORT}" ]]; then
        local checksum
        checksum="$(printf '%s' "${PERF_RUN_ID}" | cksum)"
        GRPC_PORT="$((20000 + ${checksum%% *} % 20000))"
    fi
    if [[ ! "${GRPC_PORT}" =~ ^[0-9]+$ ]] || \
       (( GRPC_PORT < 1024 || GRPC_PORT > 65535 )); then
        log "ERROR: GRPC_PORT must be an unprivileged TCP port: ${GRPC_PORT}"
        return 10
    fi
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}"
}

require_grpc_tools() {
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
        log "missing required gRPC-Java test command: ${command_name}"
        packages+=("${package}")
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log "ERROR: dnf is required to install gRPC-Java test prerequisites"
        return 30
    fi

    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log "installing missing gRPC-Java test packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log "ERROR: sudo is required to install gRPC-Java test prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log "ERROR: failed to install gRPC-Java test prerequisites"
        return 30
    fi

    for command_name in curl sha256sum cksum grep sed tee python3 java javac; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "ERROR: required gRPC-Java test command remains unavailable: ${command_name}"
            return 30
        fi
    done
}

verify_java_runtime() {
    local major

    major="$(java -version 2>&1 | sed -nE '1{s/.*version "([0-9]+).*/\1/p;}')"
    case "${major}" in
        8|11|17|21|25) ;;
        *)
            log "ERROR: gRPC-Java ${SOFTWARE_VERSION} requires Java 8 or newer; found: $(java -version 2>&1 | head -n 1)"
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

# The grpc-netty-shaded transport plus its official runtime dependency
# closure (declared in the grpc-netty-shaded pom and the transitive guava /
# grpc-core / grpc-api dependencies) covers the complete out-of-the-box
# unary RPC runtime — 14 jars in total, all pure Java so both
# architectures share the same checksums.  Adding a version means adding
# its 14 entries here.
grpc_artifact_info() {
    # Outputs "<maven group path> <artifact version> <jar file name> <sha256>".
    case "${SOFTWARE_VERSION}:$1" in
        1.83.1:grpc-netty-shaded)
            printf '%s\n' "io/grpc/grpc-netty-shaded 1.83.1 grpc-netty-shaded-1.83.1.jar fc7a54cca004df57d8d416f335e851d53b188926b598151c5714498ff60dced5" ;;
        1.83.1:grpc-core)
            printf '%s\n' "io/grpc/grpc-core 1.83.1 grpc-core-1.83.1.jar e417d5fe3b273aba8e24c5bf8edaf400297ae88a2ede828a2b75c3403b3d13e3" ;;
        1.83.1:grpc-api)
            printf '%s\n' "io/grpc/grpc-api 1.83.1 grpc-api-1.83.1.jar 96a94b488a8a9a922e9e455ac4c87d9edcb37be4ed79ec1f14e98da267a6c505" ;;
        1.83.1:grpc-stub)
            printf '%s\n' "io/grpc/grpc-stub 1.83.1 grpc-stub-1.83.1.jar 431c1280d85dd34c93f2ede7cc192c591b660a1becb6053da1423b0a6526c86a" ;;
        1.83.1:grpc-context)
            printf '%s\n' "io/grpc/grpc-context 1.83.1 grpc-context-1.83.1.jar 8224f45eccae567d68e34e7e0d2fde2f4ed36afc56d6496470f5c156b886b768" ;;
        1.83.1:grpc-util)
            printf '%s\n' "io/grpc/grpc-util 1.83.1 grpc-util-1.83.1.jar 4e722bf41a8d305e0436f16e69f7787ce5a227dc0dac45be06e8c197f08275e4" ;;
        1.83.1:guava)
            printf '%s\n' "com/google/guava/guava 33.6.0-android guava-33.6.0-android.jar 9532ca9ba8aceb4cd2067171f981c799988b7f5844e3e274811a3bb757034bc4" ;;
        1.83.1:failureaccess)
            printf '%s\n' "com/google/guava/failureaccess 1.0.3 failureaccess-1.0.3.jar cbfc3906b19b8f55dd7cfd6dfe0aa4532e834250d7f080bd8d211a3e246b59cb" ;;
        1.83.1:error-prone-annotations)
            printf '%s\n' "com/google/errorprone/error_prone_annotations 2.50.0 error_prone_annotations-2.50.0.jar 4667724877f1d37a689202da191e23efa7657c62eef93ccdac406eccfe5cdd0a" ;;
        1.83.1:animal-sniffer-annotations)
            printf '%s\n' "org/codehaus/mojo/animal-sniffer-annotations 1.27 animal-sniffer-annotations-1.27.jar cfd7e51a828fe6b98bc0dbb99e34900c9e9012322cb9ddd57fd8dd0b02da5e27" ;;
        1.83.1:jsr305)
            printf '%s\n' "com/google/code/findbugs/jsr305 3.0.2 jsr305-3.0.2.jar 766ad2a0783f2687962c8ad74ceecc38a28b9f72a2d085ee438b7813e928d0c7" ;;
        1.83.1:perfmark-api)
            printf '%s\n' "io/perfmark/perfmark-api 0.27.0 perfmark-api-0.27.0.jar c7b478503ec524e55df19b424d46d27c8a68aeb801664fadd4f069b71f52d0f6" ;;
        1.83.1:gson)
            printf '%s\n' "com/google/code/gson/gson 2.14.0 gson-2.14.0.jar 2cbd119bf1961c28788310963dc80ba65f58cdeec1dd139c8bdb1240faa2c36f" ;;
        1.83.1:android-annotations)
            printf '%s\n' "com/google/android/annotations 4.1.1.4 annotations-4.1.1.4.jar ba734e1e84c09d615af6a09d33034b4f0442f8772dec120efb376d86a565ae15" ;;
        *)
            log "ERROR: no verified gRPC-Java release is declared for ${SOFTWARE_VERSION} ($1)"
            return 10
            ;;
    esac
}

# The complete out-of-the-box grpc-netty-shaded runtime closure.
GRPC_ARTIFACTS=(
    grpc-netty-shaded
    grpc-core
    grpc-api
    grpc-stub
    grpc-context
    grpc-util
    guava
    failureaccess
    error-prone-annotations
    animal-sniffer-annotations
    jsr305
    perfmark-api
    gson
    android-annotations
)

fetch_grpc_artifacts() {
    local artifact archive_name archive_path local_archive_path info
    local maven_path artifact_version jar_file expected_sha256

    mkdir -p "${GRPC_LIB_DIR}"
    for artifact in "${GRPC_ARTIFACTS[@]}"; do
        info="$(grpc_artifact_info "${artifact}")" || return $?
        read -r maven_path artifact_version jar_file expected_sha256 <<<"${info}"
        archive_name="${jar_file}"
        archive_path="${GRPC_LIB_DIR}/${archive_name}"
        if [[ -s "${archive_path}" ]]; then
            log "using cached ${archive_name}"
        elif [[ -f "${GRPC_OFFLINE_DIR}/${archive_name}" ]]; then
            log "using local gRPC-Java artifact ${GRPC_OFFLINE_DIR}/${archive_name}" >&2
            cp "${GRPC_OFFLINE_DIR}/${archive_name}" "${archive_path}" || return 30
        else
            download_archive "${archive_path}" \
                "${GRPC_MAVEN_BASE}/${maven_path}/${artifact_version}/${archive_name}" || return 30
        fi
        verify_sha256 "${archive_path}" "${expected_sha256}" || return 30
    done
    log "official gRPC-Java ${SOFTWARE_VERSION} artifacts are staged"
}

compile_benchmark() {
    local source="${SCRIPT_DIR}/src/main/java/org/boostkit/performance/grpc/GrpcBenchmark.java"

    if [[ ! -f "${source}" ]]; then
        log "ERROR: the benchmark source is missing: ${source}"
        return 40
    fi
    rm -rf "${CLASSES_DIR}"
    mkdir -p "${CLASSES_DIR}"
    if ! javac -encoding UTF-8 -cp "${GRPC_LIB_DIR}/*" -d "${CLASSES_DIR}" "${source}"; then
        log "ERROR: failed to compile the unary echo benchmark harness"
        return 40
    fi
    if [[ ! -f "${CLASSES_DIR}/org/boostkit/performance/grpc/GrpcBenchmark.class" ]]; then
        log "ERROR: the compiled benchmark class is missing"
        return 40
    fi
}

run_benchmark_jvm() {
    java -Xms"${JVM_HEAP_SIZE}" -Xmx"${JVM_HEAP_SIZE}" \
        -cp "${GRPC_LIB_DIR}/*:${CLASSES_DIR}" "${BENCHMARK_CLASS}" "$@"
}

build_grpc_java() {
    local actual_version
    local runner_architecture

    initialize_runtime || return $?
    runner_architecture="$(uname -m)"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    require_grpc_tools || return $?
    verify_java_runtime || return $?
    if [[ -e "${CLASSES_DIR}" ]]; then
        log "ERROR: build output is not clean under ${CLASSES_DIR}"
        return 20
    fi

    fetch_grpc_artifacts || return $?
    compile_benchmark || return $?

    actual_version="$(run_benchmark_jvm --version | sed -nE 's/^grpc-java-version=//p' | head -n 1)"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: staged gRPC-Java is ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "gRPC-Java ${actual_version} staged with the compiled unary echo benchmark harness"
}

grpc_port_in_use() {
    (exec 3<>"/dev/tcp/${GRPC_HOST}/${GRPC_PORT}") >/dev/null 2>&1
}

validate_run_report() {
    local report="$1"

    python3 - "${report}" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as report:
    payload = json.load(report)
for field in ("calls", "calls_per_second", "avg_rtt_ms", "p99_rtt_ms"):
    value = payload[field]
    assert isinstance(value, (int, float)) and value > 0, (field, value)
assert payload["duration_seconds"] > 0
PY
}

start_grpc_java_runtime() {
    initialize_runtime || return $?
    if [[ ! -f "${CLASSES_DIR}/org/boostkit/performance/grpc/GrpcBenchmark.class" ]]; then
        log "ERROR: the benchmark harness is not built (run build first)"
        return 40
    fi
    if grpc_port_in_use; then
        log "ERROR: a service is already reachable on ${GRPC_HOST}:${GRPC_PORT}"
        log "ERROR: refusing to benchmark against a pre-existing listener"
        return 20
    fi
    if [[ -e "${BENCHMARK_DIR}" ]]; then
        log "ERROR: benchmark directory is not clean: ${BENCHMARK_DIR}"
        return 20
    fi

    # Smoke-run the complete chain (server, channels, unary calls, JSON
    # report) once so the test stage only ever times a verified harness.
    mkdir -p "${BENCHMARK_DIR}"
    log "smoke-running the unary echo benchmark harness on port ${GRPC_PORT}"
    if ! run_benchmark_jvm \
            --port "${GRPC_PORT}" \
            --message-size 1024 \
            --channels 8 \
            --pipeline "${GRPC_PIPELINE}" \
            --warmup-seconds 1 \
            --duration-seconds 2 \
            --scenario "smoke" \
            --output "${BENCHMARK_DIR}/smoke.json"; then
        rm -rf "${BENCHMARK_DIR}"
        log "ERROR: the unary echo benchmark smoke run failed"
        return 40
    fi
    if ! validate_run_report "${BENCHMARK_DIR}/smoke.json"; then
        rm -rf "${BENCHMARK_DIR}"
        log "ERROR: the smoke run report is invalid"
        return 40
    fi
    rm -rf "${BENCHMARK_DIR}"
    log "gRPC-Java benchmark runtime is ready"
}

run_grpc_java_benchmarks() {
    local raw_output
    local scenario size label slug
    local channels run_file

    initialize_runtime || return $?
    require_grpc_tools || return $?
    if [[ ! -f "${CLASSES_DIR}/org/boostkit/performance/grpc/GrpcBenchmark.class" ]]; then
        log "ERROR: the benchmark harness is not built (run build first)"
        return 50
    fi

    raw_output="${RESULTS_DIR}/grpc_java_unary_raw.log"
    mkdir -p "${BENCHMARK_DIR}"
    rm -rf "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"
    log "running the unary echo scenario matrix on port ${GRPC_PORT} (pipeline=${GRPC_PIPELINE}, warmup=${GRPC_WARMUP_SECONDS}s, duration=${GRPC_DURATION_SECONDS}s)"

    if ! (
        for scenario in "${GRPC_MESSAGE_SCENARIOS[@]}"; do
            size="${scenario%%:*}"
            label="${scenario##*:}"
            slug="$(( size / 1024 ))k"
            for channels in "${GRPC_CHANNELS_LADDER[@]}"; do
                run_file="${RUNS_DIR}/unary-${slug}-c${channels}.json"
                run_benchmark_jvm \
                    --port "${GRPC_PORT}" \
                    --message-size "${size}" \
                    --channels "${channels}" \
                    --pipeline "${GRPC_PIPELINE}" \
                    --warmup-seconds "${GRPC_WARMUP_SECONDS}" \
                    --duration-seconds "${GRPC_DURATION_SECONDS}" \
                    --scenario "unary ${label}" \
                    --output "${run_file}" || exit 50
                validate_run_report "${run_file}" || exit 50
            done
        done
    ) 2>&1 | tee "${raw_output}"; then
        log "ERROR: the unary echo benchmark matrix failed (see ${raw_output})"
        return 50
    fi

    python3 "${SCRIPT_DIR}/scripts/collect_grpc_java_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" || return 50
    log "unary echo benchmark matrix completed"
}

stop_grpc_java_runtime() {
    initialize_runtime || return $?
    log "gRPC-Java benchmark has no background service to stop"
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
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/grpc-java/local-* || \
          "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/grpc-java" ]]; then
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
        stop_grpc_java_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_grpc_java_standalone() {
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
        if build_grpc_java; then
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
        if start_grpc_java_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_grpc_java_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_grpc_java_runtime; then
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

Stage the official gRPC-Java ${SOFTWARE_VERSION} Maven artifacts, compile
the unary echo benchmark harness, and run the message-size x channel-count
matrix as a standalone performance evaluation. Results default to
results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       gRPC-Java version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR, GRPC_PORT,
  GRPC_PIPELINE, GRPC_WARMUP_SECONDS, GRPC_DURATION_SECONDS, JVM_HEAP_SIZE
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
    run_grpc_java_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
