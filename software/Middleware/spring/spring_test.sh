#!/usr/bin/env bash
# Spring Framework performance case (official Maven Central artifacts with
# an in-process WebFlux functional echo benchmark harness).
#
# Spring Framework is a library whose official distribution channel is
# Maven Central, so the software under test is the official
# org.springframework artifacts plus their runtime dependency closure
# (SHA-256 verified; the jars are pure Java and therefore architecture
# independent).  The benchmark harness is compiled against those jars
# with javac — the same approach the Flink, Netty and gRPC-Java cases
# use — and follows the canonical "WebFlux Fn" endpoint shape from the
# official Spring Framework documentation: a functional router endpoint
# ("POST /echo") that echoes every request payload back unchanged,
# driven through the official MockServerWebExchange from the spring-test
# artifact (the same facility Spring itself uses for framework testing).
# This exercises the complete framework pipeline — router matching,
# ServerRequest construction, request-body decoding, handler invocation,
# response serialization and reactive scheduling — without any network
# transport, so the software under test stays the Spring Framework
# pipeline itself rather than a third-party HTTP server stack.
#
# Scenarios are message sizes (1 KiB / 16 KiB) crossed with the
# mysql-style concurrency ladder (128/256/512/1024 outstanding
# exchanges).  Each run reports exchange throughput and sampled
# round-trip latency percentiles from sequence-stamped frames.
#
# The four framework stages map to: fetch+verify the jars, provision the
# JDK, and compile the harness (build), smoke-run the harness end to end
# (start), run the full scenario matrix (test), and drop the benchmark
# data (stop).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="spring"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-7.0.9}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

# Official Maven Central repository (the official Spring distribution).
SPRING_MAVEN_BASE="${SPRING_MAVEN_BASE:-https://repo1.maven.org/maven2}"
SPRING_OFFLINE_DIR="${SPRING_OFFLINE_DIR:-/home/runner/software/spring}"

# Benchmark matrix: message sizes crossed with the concurrency ladder.
SPRING_MESSAGE_SCENARIOS=("1024:1KiB" "16384:16KiB")
SPRING_CONCURRENCY_LADDER=(128 256 512 1024)
SPRING_DRIVERS="${SPRING_DRIVERS:-16}"
SPRING_WARMUP_SECONDS="${SPRING_WARMUP_SECONDS:-5}"
SPRING_DURATION_SECONDS="${SPRING_DURATION_SECONDS:-30}"
JVM_HEAP_SIZE="${JVM_HEAP_SIZE:-2g}"

# Lifecycle paths (assigned in configure_runtime_paths).
SPRING_LIB_DIR=""
CLASSES_DIR=""
BENCHMARK_DIR=""
RUNS_DIR=""
BENCHMARK_CLASS="org.boostkit.performance.spring.SpringEchoBenchmark"

log() {
    printf '[spring] %s\n' "$*"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/spring/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SPRING_LIB_DIR="${PERF_WORK_DIR}/spring-lib"
    CLASSES_DIR="${PERF_WORK_DIR}/classes"
    BENCHMARK_DIR="${PERF_WORK_DIR}/benchmark"
    RUNS_DIR="${BENCHMARK_DIR}/runs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}"
}

require_spring_tools() {
    local command_name package
    local packages=()

    for command_name in curl sha256sum grep tee python3 java javac sudo; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            curl) package="curl" ;;
            sha256sum|tee) package="coreutils" ;;
            python3) package="python3" ;;
            java|javac) package="java-21-openjdk-devel" ;;
            sudo) package="sudo" ;;
        esac
        log "missing required Spring test command: ${command_name}"
        packages+=("${package}")
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log "ERROR: dnf is required to install Spring test prerequisites"
        return 30
    fi

    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log "installing missing Spring test packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log "ERROR: sudo is required to install Spring test prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log "ERROR: failed to install Spring test prerequisites"
        return 30
    fi

    for command_name in curl sha256sum grep tee python3 java javac; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "ERROR: required Spring test command remains unavailable: ${command_name}"
            return 30
        fi
    done
}

# Spring Framework 7.0 requires Java 17 as the minimum baseline.
verify_java_runtime() {
    local major

    major="$(java -version 2>&1 | sed -nE '1{s/.*version "([0-9]+).*/\1/p;}')"
    case "${major}" in
        17|21|25) ;;
        *)
            log "ERROR: Spring Framework ${SOFTWARE_VERSION} requires Java 17 or newer; found: $(java -version 2>&1 | head -n 1)"
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

# The spring-webflux functional pipeline plus its official runtime
# dependency closure (declared in the spring-webflux / spring-web /
# spring-context poms and verified by running the benchmark locally)
# covers the complete out-of-the-box WebFlux Fn runtime — 14 jars in
# total, all pure Java so both architectures share the same checksums.
# spring-context is declared optional in spring-webflux but is required
# at runtime by HandlerStrategies (LocaleContextHolder); spring-test
# carries the official MockServerWebExchange driver API.  Adding a
# version means adding its 14 entries here.
spring_artifact_info() {
    # Outputs "<maven group path> <artifact version> <sha256>".
    case "${SOFTWARE_VERSION}:$1" in
        7.0.9:spring-webflux)
            printf '%s\n' "org/springframework/spring-webflux 7.0.9 70ce35b3b507c2b5711daf78afccdb5d78142fdd3fc1ad0790257655bd6794da" ;;
        7.0.9:spring-web)
            printf '%s\n' "org/springframework/spring-web 7.0.9 941ced476427bde2533872f293da535fd0258de3f3a650a7f1bfe01ed2927302" ;;
        7.0.9:spring-test)
            printf '%s\n' "org/springframework/spring-test 7.0.9 6ce8fc116f5d309b9ac50a6738bd1b15ea4012a4a5563c0ee89b795bfc9af0dc" ;;
        7.0.9:spring-context)
            printf '%s\n' "org/springframework/spring-context 7.0.9 7552a2fcfa30cea53eb14d7a65a7a8e1b1dd82e832a7164fb7e6fb105f438858" ;;
        7.0.9:spring-aop)
            printf '%s\n' "org/springframework/spring-aop 7.0.9 b8c5d6bfcb1f4993f2cc124f7ab7fac40edf5256b9e43c2f7250a733cb5510e9" ;;
        7.0.9:spring-expression)
            printf '%s\n' "org/springframework/spring-expression 7.0.9 046434c40f43819729b9b1db0e6c659dfa68184c1c2c2efa5f7b3a5b27c4e2e2" ;;
        7.0.9:spring-beans)
            printf '%s\n' "org/springframework/spring-beans 7.0.9 ff218b827a25c9e8929b0cd56dfb56916cea9d5b669ed97dc7cb262508ff548b" ;;
        7.0.9:spring-core)
            printf '%s\n' "org/springframework/spring-core 7.0.9 5195f4722699b39878d99a832549fe65df2890b159d063b88fff31b1ca65ae36" ;;
        7.0.9:reactor-core)
            printf '%s\n' "io/projectreactor/reactor-core 3.8.7 9a5f1bfc5ad0416a410ff63beaa279cc30c2da3ae9b111a678c83c99298a1551" ;;
        7.0.9:micrometer-observation)
            printf '%s\n' "io/micrometer/micrometer-observation 1.16.7 74f9e4d51ef30c141de8a2409879282e572eef98665e033e8922c2fbee16862d" ;;
        7.0.9:micrometer-commons)
            printf '%s\n' "io/micrometer/micrometer-commons 1.16.7 cd1ad64a94650a2ed3988a4ab48c9a7fad40c4986a81e328194dd757b5170273" ;;
        7.0.9:reactive-streams)
            printf '%s\n' "org/reactivestreams/reactive-streams 1.0.4 f75ca597789b3dac58f61857b9ac2e1034a68fa672db35055a8fb4509e325f28" ;;
        7.0.9:jspecify)
            printf '%s\n' "org/jspecify/jspecify 1.0.0 1fad6e6be7557781e4d33729d49ae1cdc8fdda6fe477bb0cc68ce351eafdfbab" ;;
        7.0.9:commons-logging)
            printf '%s\n' "commons-logging/commons-logging 1.3.5 6d7a744e4027649fbb50895df9497d109f98c766a637062fe8d2eabbb3140ba4" ;;
        *)
            log "ERROR: no verified Spring release is declared for ${SOFTWARE_VERSION} ($1)"
            return 10
            ;;
    esac
}

# The complete out-of-the-box WebFlux Fn runtime closure.
SPRING_ARTIFACTS=(
    spring-webflux
    spring-web
    spring-test
    spring-context
    spring-aop
    spring-expression
    spring-beans
    spring-core
    reactor-core
    micrometer-observation
    micrometer-commons
    reactive-streams
    jspecify
    commons-logging
)

fetch_spring_artifacts() {
    local artifact archive_name archive_path info
    local maven_path artifact_version expected_sha256

    mkdir -p "${SPRING_LIB_DIR}"
    for artifact in "${SPRING_ARTIFACTS[@]}"; do
        info="$(spring_artifact_info "${artifact}")" || return $?
        read -r maven_path artifact_version expected_sha256 <<<"${info}"
        archive_name="${artifact}-${artifact_version}.jar"
        archive_path="${SPRING_LIB_DIR}/${archive_name}"
        if [[ -s "${archive_path}" ]]; then
            log "using cached ${archive_name}"
        elif [[ -f "${SPRING_OFFLINE_DIR}/${archive_name}" ]]; then
            log "using local Spring artifact ${SPRING_OFFLINE_DIR}/${archive_name}" >&2
            cp "${SPRING_OFFLINE_DIR}/${archive_name}" "${archive_path}" || return 30
        else
            download_archive "${archive_path}" \
                "${SPRING_MAVEN_BASE}/${maven_path}/${artifact_version}/${archive_name}" || return 30
        fi
        verify_sha256 "${archive_path}" "${expected_sha256}" || return 30
    done
    log "official Spring Framework ${SOFTWARE_VERSION} artifacts are staged"
}

compile_benchmark() {
    local source="${SCRIPT_DIR}/src/main/java/org/boostkit/performance/spring/SpringEchoBenchmark.java"

    if [[ ! -f "${source}" ]]; then
        log "ERROR: the benchmark source is missing: ${source}"
        return 40
    fi
    rm -rf "${CLASSES_DIR}"
    mkdir -p "${CLASSES_DIR}"
    if ! javac -encoding UTF-8 -cp "${SPRING_LIB_DIR}/*" -d "${CLASSES_DIR}" "${source}"; then
        log "ERROR: failed to compile the WebFlux echo benchmark harness"
        return 40
    fi
    if [[ ! -f "${CLASSES_DIR}/org/boostkit/performance/spring/SpringEchoBenchmark.class" ]]; then
        log "ERROR: the compiled benchmark class is missing"
        return 40
    fi
}

run_benchmark_jvm() {
    java -Xms"${JVM_HEAP_SIZE}" -Xmx"${JVM_HEAP_SIZE}" \
        -cp "${SPRING_LIB_DIR}/*:${CLASSES_DIR}" "${BENCHMARK_CLASS}" "$@"
}

build_spring() {
    local actual_version
    local runner_architecture

    initialize_runtime || return $?
    runner_architecture="$(uname -m)"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    require_spring_tools || return $?
    verify_java_runtime || return $?
    if [[ -e "${CLASSES_DIR}" ]]; then
        log "ERROR: build output is not clean under ${CLASSES_DIR}"
        return 20
    fi

    fetch_spring_artifacts || return $?
    compile_benchmark || return $?

    actual_version="$(run_benchmark_jvm --version | sed -nE 's/^spring-version=//p' | head -n 1)"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: staged Spring Framework is ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "Spring Framework ${actual_version} staged with the compiled WebFlux echo benchmark harness"
}

validate_run_report() {
    local report="$1"

    python3 - "${report}" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as report:
    payload = json.load(report)
for field in ("calls", "exchanges_per_second", "avg_rtt_ms", "p99_rtt_ms"):
    value = payload[field]
    assert isinstance(value, (int, float)) and value > 0, (field, value)
assert payload["duration_seconds"] > 0
PY
}

start_spring_runtime() {
    initialize_runtime || return $?
    if [[ ! -f "${CLASSES_DIR}/org/boostkit/performance/spring/SpringEchoBenchmark.class" ]]; then
        log "ERROR: the benchmark harness is not built (run build first)"
        return 40
    fi
    if [[ -e "${BENCHMARK_DIR}" ]]; then
        log "ERROR: benchmark directory is not clean: ${BENCHMARK_DIR}"
        return 20
    fi

    # Smoke-run the complete chain (functional router, exchange driving,
    # echo validation, JSON report) once so the test stage only ever
    # times a verified harness.
    mkdir -p "${BENCHMARK_DIR}"
    log "smoke-running the WebFlux echo benchmark harness (drivers=${SPRING_DRIVERS})"
    if ! run_benchmark_jvm \
            --message-size 1024 \
            --concurrency 64 \
            --drivers 8 \
            --warmup-seconds 1 \
            --duration-seconds 2 \
            --scenario "smoke" \
            --output "${BENCHMARK_DIR}/smoke.json"; then
        rm -rf "${BENCHMARK_DIR}"
        log "ERROR: the WebFlux echo benchmark smoke run failed"
        return 40
    fi
    if ! validate_run_report "${BENCHMARK_DIR}/smoke.json"; then
        rm -rf "${BENCHMARK_DIR}"
        log "ERROR: the smoke run report is invalid"
        return 40
    fi
    rm -rf "${BENCHMARK_DIR}"
    log "Spring benchmark runtime is ready"
}

run_spring_benchmarks() {
    local raw_output
    local scenario size label slug
    local concurrency run_file

    initialize_runtime || return $?
    require_spring_tools || return $?
    if [[ ! -f "${CLASSES_DIR}/org/boostkit/performance/spring/SpringEchoBenchmark.class" ]]; then
        log "ERROR: the benchmark harness is not built (run build first)"
        return 50
    fi

    raw_output="${RESULTS_DIR}/spring_echo_raw.log"
    mkdir -p "${BENCHMARK_DIR}"
    rm -rf "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"
    log "running the WebFlux echo scenario matrix (drivers=${SPRING_DRIVERS}, warmup=${SPRING_WARMUP_SECONDS}s, duration=${SPRING_DURATION_SECONDS}s)"

    if ! (
        for scenario in "${SPRING_MESSAGE_SCENARIOS[@]}"; do
            size="${scenario%%:*}"
            label="${scenario##*:}"
            slug="$(( size / 1024 ))k"
            for concurrency in "${SPRING_CONCURRENCY_LADDER[@]}"; do
                run_file="${RUNS_DIR}/echo-${slug}-c${concurrency}.json"
                run_benchmark_jvm \
                    --message-size "${size}" \
                    --concurrency "${concurrency}" \
                    --drivers "${SPRING_DRIVERS}" \
                    --warmup-seconds "${SPRING_WARMUP_SECONDS}" \
                    --duration-seconds "${SPRING_DURATION_SECONDS}" \
                    --scenario "echo ${label}" \
                    --output "${run_file}" || exit 50
                validate_run_report "${run_file}" || exit 50
            done
        done
    ) 2>&1 | tee "${raw_output}"; then
        log "ERROR: the WebFlux echo benchmark matrix failed (see ${raw_output})"
        return 50
    fi

    python3 "${SCRIPT_DIR}/scripts/collect_spring_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" || return 50
    log "WebFlux echo benchmark matrix completed"
}

stop_spring_runtime() {
    initialize_runtime || return $?
    log "Spring benchmark has no background service to stop"
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
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/spring/local-* || \
          "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/spring" ]]; then
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
        stop_spring_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_spring_standalone() {
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
        if build_spring; then
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
        if start_spring_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_spring_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_spring_runtime; then
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

Stage the official Spring Framework ${SOFTWARE_VERSION} Maven artifacts,
compile the WebFlux echo benchmark harness, and run the message-size x
concurrency matrix as a standalone performance evaluation. Results
default to results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       Spring Framework version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR,
  SPRING_DRIVERS, SPRING_WARMUP_SECONDS, SPRING_DURATION_SECONDS,
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
    mkdir -p "${RESULTS_DIR}" || return 10
    : > "${RESULTS_DIR}/results.log"
    local pipeline_status=0
    set +e
    run_spring_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
