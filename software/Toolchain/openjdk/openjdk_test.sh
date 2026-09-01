#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-26.0.2.1}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
OPENJDK_SOURCE_BASE="${OPENJDK_SOURCE_BASE:-https://github.com/openjdk}"
OPENJDK_BINARY_BASE="${OPENJDK_BINARY_BASE:-https://download.java.net/java/GA}"
MAVEN_MIRROR="${MAVEN_MIRROR:-https://repo.maven.apache.org/maven2}"
OPENJDK_OFFLINE_DIR="${OPENJDK_OFFLINE_DIR:-/home/runner/software/openjdk}"
# JMH dependency versions pinned to the official OpenJDK build infrastructure
# (make/jmh/createJMHBundle.sh in the jdk repository: jmh-core 1.37,
# jmh-generator-annprocess 1.37, commons-math3 3.6.1, jopt-simple 5.0.4).
JMH_VERSION="${OPENJDK_JMH_VERSION:-1.37}"
COMMONS_MATH3_VERSION=3.6.1
JOPT_SIMPLE_VERSION=5.0.4
# Official JMH micro benchmark selection from the OpenJDK test/micro suite
# (seven representative classes). Each class declares
# @BenchmarkMode(Mode.AverageTime) and its own @OutputTimeUnit: nanoseconds
# for ArrayCopy/ArrayClone/StringDecode/StringEncode/StringBuilders,
# microseconds for ArraysSort (declared in package
# org.openjdk.bench.java.lang even though the source lives under java/util)
# and milliseconds for HashMapBench. The parser normalizes every score to
# microseconds. "[.]" is an unanchored JMH regex suffix guard so the pattern
# matches the class prefix but not longer class names.
OPENJDK_BENCH_CLASSES="${OPENJDK_BENCH_CLASSES:-org.openjdk.bench.java.lang.ArrayCopy org.openjdk.bench.java.lang.ArrayClone org.openjdk.bench.java.lang.StringDecode org.openjdk.bench.java.lang.StringEncode org.openjdk.bench.java.lang.StringBuilders org.openjdk.bench.java.lang.ArraysSort org.openjdk.bench.java.util.HashMapBench}"
OPENJDK_BENCH_SOURCES="${OPENJDK_BENCH_SOURCES:-test/micro/org/openjdk/bench/java/lang/ArrayCopy.java test/micro/org/openjdk/bench/java/lang/ArrayClone.java test/micro/org/openjdk/bench/java/lang/StringDecode.java test/micro/org/openjdk/bench/java/lang/StringEncode.java test/micro/org/openjdk/bench/java/lang/StringBuilders.java test/micro/org/openjdk/bench/java/util/ArraysSort.java test/micro/org/openjdk/bench/java/util/HashMapBench.java}"
# Same JVM flag the official harness (RunTests.gmk SetupRunMicroTest) adds for
# every micro benchmark run.
OPENJDK_JAVA_OPTIONS="${OPENJDK_JAVA_OPTIONS:---add-opens=java.base/java.io=ALL-UNNAMED}"

JDK_HOME=""
SRC_DIR=""
JMH_DIR=""
BENCH_JAR=""
BENCH_CLASSES_DIR=""
JDK_VERSION_STRING=""
OPENJDK_SOURCE_REPO=""
OPENJDK_SOURCE_TAG=""
OPENJDK_SOURCE_COMMIT=""
OPENJDK_BINARY_URL=""
OPENJDK_BINARY_SHA256=""
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

log() {
    printf '[openjdk] %s\n' "$*"
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
            log "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    case "$(uname -m)" in
        x86_64|amd64)
            if [[ "${EXPECTED_ARCH}" != "x86_64" ]]; then
                log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is x86_64"
                return 20
            fi
            ;;
        aarch64|arm64)
            if [[ "${EXPECTED_ARCH}" != "aarch64" ]]; then
                log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is aarch64"
                return 20
            fi
            ;;
        *)
            log "ERROR: unsupported runner architecture: $(uname -m)"
            return 20
            ;;
    esac
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/tmp/openjdk-perf/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${TMPDIR:-${PERF_WORK_DIR}/tmp}"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    JDK_HOME="${PERF_WORK_DIR}/jdk"
    SRC_DIR="${PERF_WORK_DIR}/micro-src"
    JMH_DIR="${PERF_WORK_DIR}/jmh"
    BENCH_JAR="${PERF_WORK_DIR}/benchmarks.jar"
    BENCH_CLASSES_DIR="${PERF_WORK_DIR}/micro-classes"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
}

initialize_runtime() {
    if configure_runtime_paths; then
        :
    else
        return $?
    fi
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR:-${PERF_WORK_DIR}/tmp}"
}

install_dependencies() {
    local required missing=0
    for required in git curl tar sha256sum python3 awk sed grep tee; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            missing=1
        fi
    done
    if [[ "${missing}" -eq 0 ]]; then
        return 0
    fi
    log "installing missing OpenJDK test dependencies"
    if command -v dnf >/dev/null 2>&1; then
        if [[ "${EUID}" -eq 0 ]]; then
            if ! dnf install -y git curl tar gzip coreutils python3 gawk findutils sed grep; then
                log "ERROR: failed to install OpenJDK test dependencies"
                return 30
            fi
        elif command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
            if ! sudo -n dnf install -y git curl tar gzip coreutils python3 gawk findutils sed grep; then
                log "ERROR: failed to install OpenJDK test dependencies"
                return 30
            fi
        else
            log "ERROR: root privileges are required to install OpenJDK test dependencies"
            return 30
        fi
    elif command -v yum >/dev/null 2>&1; then
        if [[ "${EUID}" -eq 0 ]]; then
            if ! yum install -y git curl tar gzip coreutils python3 gawk findutils sed grep; then
                log "ERROR: failed to install OpenJDK test dependencies"
                return 30
            fi
        elif command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
            if ! sudo -n yum install -y git curl tar gzip coreutils python3 gawk findutils sed grep; then
                log "ERROR: failed to install OpenJDK test dependencies"
                return 30
            fi
        else
            log "ERROR: root privileges are required to install OpenJDK test dependencies"
            return 30
        fi
    elif command -v apt-get >/dev/null 2>&1; then
        if [[ "${EUID}" -eq 0 ]]; then
            if ! apt-get update; then
                log "ERROR: failed to update APT package metadata"
                return 30
            fi
            if ! apt-get install -y git curl tar gzip coreutils python3 gawk findutils sed grep; then
                log "ERROR: failed to install OpenJDK test dependencies"
                return 30
            fi
        elif command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
            if ! sudo -n apt-get update; then
                log "ERROR: failed to update APT package metadata"
                return 30
            fi
            if ! sudo -n apt-get install -y git curl tar gzip coreutils python3 gawk findutils sed grep; then
                log "ERROR: failed to install OpenJDK test dependencies"
                return 30
            fi
        else
            log "ERROR: root privileges are required to install OpenJDK test dependencies"
            return 30
        fi
    else
        log "ERROR: unsupported package manager; cannot install OpenJDK test dependencies"
        return 30
    fi
    for required in git curl tar sha256sum python3 awk sed grep tee; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            log "ERROR: required command is still missing after installation: ${required}"
            return 30
        fi
    done
}

install_openjdk_binary() {
    local archive_name archive_path local_archive_path top_dir version_line actual_version
    local actual_sha256

    case "${SOFTWARE_VERSION}:${EXPECTED_ARCH}" in
        25.0.2:x86_64)
            archive_name="openjdk-25.0.2_linux-x64_bin.tar.gz"
            OPENJDK_BINARY_URL="${OPENJDK_BINARY_BASE}/jdk25.0.2/b1e0dfa218384cb9959bdcb897162d4e/10/GPL/${archive_name}"
            OPENJDK_BINARY_SHA256="555ce0821e4fe175ea50d54518cd6fbece9663c1998de529bc6ce429534457df"
            OPENJDK_SOURCE_REPO="jdk25u"
            OPENJDK_SOURCE_TAG="jdk-25.0.2-ga"
            ;;
        25.0.2:aarch64)
            archive_name="openjdk-25.0.2_linux-aarch64_bin.tar.gz"
            OPENJDK_BINARY_URL="${OPENJDK_BINARY_BASE}/jdk25.0.2/b1e0dfa218384cb9959bdcb897162d4e/10/GPL/${archive_name}"
            OPENJDK_BINARY_SHA256="671208d205e70c9805da45a483f670d49dd64654990a7b7223ccffb2abb070dd"
            OPENJDK_SOURCE_REPO="jdk25u"
            OPENJDK_SOURCE_TAG="jdk-25.0.2-ga"
            ;;
        26.0.2.1:x86_64)
            archive_name="openjdk-26.0.2.1_linux-x64_bin.tar.gz"
            OPENJDK_BINARY_URL="${OPENJDK_BINARY_BASE}/jdk26.0.2.1/3b8e6c7ec6274148a7aa15e7e7dfb53c/1/GPL/${archive_name}"
            OPENJDK_BINARY_SHA256="a1489256029b389ce6ee52da0de1d01496c5df1776d6870241fe4823b998ea612"
            OPENJDK_SOURCE_REPO="jdk26u"
            OPENJDK_SOURCE_TAG="jdk-26.0.2.1-ga"
            ;;
        26.0.2.1:aarch64)
            archive_name="openjdk-26.0.2.1_linux-aarch64_bin.tar.gz"
            OPENJDK_BINARY_URL="${OPENJDK_BINARY_BASE}/jdk26.0.2.1/3b8e6c7ec6274148a7aa15e7e7dfb53c/1/GPL/${archive_name}"
            OPENJDK_BINARY_SHA256="b96b265a4a1a36c02454148891aa58ca63303cbc2d1b7979c33b4fe99e09117b"
            OPENJDK_SOURCE_REPO="jdk26u"
            OPENJDK_SOURCE_TAG="jdk-26.0.2.1-ga"
            ;;
        *)
            log "ERROR: no verified OpenJDK release is declared for ${SOFTWARE_VERSION} on ${EXPECTED_ARCH}"
            return 20
            ;;
    esac

    local_archive_path="${OPENJDK_OFFLINE_DIR}/${archive_name}"
    archive_path="${PERF_WORK_DIR}/${archive_name}"
    if [[ -f "${local_archive_path}" ]]; then
        log "using local OpenJDK archive ${local_archive_path}"
        if ! cp "${local_archive_path}" "${archive_path}"; then
            log "ERROR: failed to copy local OpenJDK archive"
            return 30
        fi
    else
        log "downloading official prebuilt OpenJDK ${SOFTWARE_VERSION} binary from jdk.java.net"
        if ! curl -fL --retry 3 --connect-timeout 30 \
            -o "${archive_path}" "${OPENJDK_BINARY_URL}"; then
            log "ERROR: failed to download the OpenJDK ${SOFTWARE_VERSION} binary tarball"
            return 30
        fi
    fi
    actual_sha256="$(sha256sum "${archive_path}" | awk '{print $1}')"
    if [[ "${actual_sha256}" != "${OPENJDK_BINARY_SHA256}" ]]; then
        log "ERROR: OpenJDK binary tarball checksum mismatch"
        log "expected: ${OPENJDK_BINARY_SHA256}"
        log "actual:   ${actual_sha256}"
        return 30
    fi
    log "extracting prebuilt JDK (checksum verified)"
    top_dir="$(tar -tzf "${archive_path}" | awk -F/ 'NR==1 {print $1}')"
    if [[ -z "${top_dir}" || "${top_dir}" != jdk-* ]]; then
        log "ERROR: tarball does not contain a jdk-* root directory: ${top_dir}"
        return 30
    fi
    if ! tar -xzf "${archive_path}" -C "${PERF_WORK_DIR}"; then
        log "ERROR: failed to extract the OpenJDK binary tarball"
        return 30
    fi
    if [[ ! -d "${PERF_WORK_DIR}/${top_dir}" ]]; then
        log "ERROR: extraction did not create ${top_dir}"
        return 30
    fi
    if ! mv "${PERF_WORK_DIR}/${top_dir}" "${JDK_HOME}"; then
        log "ERROR: failed to place the extracted OpenJDK directory"
        return 30
    fi
    rm -f "${archive_path}"
    if [[ ! -x "${JDK_HOME}/bin/java" || ! -x "${JDK_HOME}/bin/javac" ]]; then
        log "ERROR: prebuilt JDK is missing bin/java or bin/javac: ${JDK_HOME}"
        return 30
    fi
    version_line="$("${JDK_HOME}/bin/java" -version 2>&1 | head -n 1)"
    actual_version="$(printf '%s\n' "${version_line}" | sed -n 's/^openjdk version "\([^"]*\)".*/\1/p')"
    if [[ -z "${actual_version}" ]]; then
        log "ERROR: cannot parse the JDK version line: ${version_line}"
        return 30
    fi
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: prebuilt JDK reports ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 30
    fi
    JDK_VERSION_STRING="${version_line}"
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    if ! printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"; then
        log "ERROR: failed to record the actual OpenJDK version"
        return 30
    fi
    log "prebuilt JDK is ready: ${JDK_VERSION_STRING}"
}

prepare_benchmark_sources() {
    local source_file local_source_repo source_url

    if [[ -z "${OPENJDK_BENCH_CLASSES//[[:space:]]/}" || \
          -z "${OPENJDK_BENCH_SOURCES//[[:space:]]/}" ]]; then
        log "ERROR: OpenJDK benchmark classes and source files must be declared"
        return 30
    fi

    local_source_repo="${OPENJDK_OFFLINE_DIR}/${OPENJDK_SOURCE_REPO}.git"
    source_url="${OPENJDK_SOURCE_BASE}/${OPENJDK_SOURCE_REPO}"
    if [[ -d "${local_source_repo}" ]]; then
        source_url="${local_source_repo}"
        log "using local OpenJDK source mirror ${local_source_repo}"
    else
        log "fetching test/micro benchmark sources from ${source_url} (tag ${OPENJDK_SOURCE_TAG})"
    fi
    if ! git clone --depth 1 --branch "${OPENJDK_SOURCE_TAG}" --filter=blob:none --sparse \
        "${source_url}" "${SRC_DIR}"; then
        log "ERROR: git sparse clone of ${OPENJDK_SOURCE_REPO} failed"
        return 30
    fi
    if ! (
        cd "${SRC_DIR}"
        git sparse-checkout set \
            test/micro/org/openjdk/bench/java/lang \
            test/micro/org/openjdk/bench/java/util
    ); then
        log "ERROR: git sparse-checkout of test/micro failed"
        return 30
    fi
    for source_file in ${OPENJDK_BENCH_SOURCES}; do
        if [[ ! -f "${SRC_DIR}/${source_file}" ]]; then
            log "ERROR: benchmark source is missing: ${source_file}"
            return 30
        fi
    done
    OPENJDK_SOURCE_COMMIT="$(git -C "${SRC_DIR}" rev-parse HEAD)"
    log "benchmark sources are at commit ${OPENJDK_SOURCE_COMMIT}"
}

prepare_jmh_bundle() {
    local jar path expected_sha256 actual_sha256
    if [[ "${JMH_VERSION}" != "1.37" ]]; then
        log "ERROR: the declared JMH bundle only supports version 1.37, got ${JMH_VERSION}"
        return 30
    fi
    mkdir -p "${JMH_DIR}"
    for jar in \
        "jmh-core-${JMH_VERSION}.jar" \
        "jmh-generator-annprocess-${JMH_VERSION}.jar" \
        "commons-math3-${COMMONS_MATH3_VERSION}.jar" \
        "jopt-simple-${JOPT_SIMPLE_VERSION}.jar"; do
        case "${jar}" in
            jmh-core-1.37.jar)
                path="org/openjdk/jmh/jmh-core/${JMH_VERSION}"
                expected_sha256="dc0eaf2bbf0036a70b60798c785d6e03a9daf06b68b8edb0f1ba9eb3421baeb3"
                ;;
            jmh-generator-annprocess-1.37.jar)
                path="org/openjdk/jmh/jmh-generator-annprocess/${JMH_VERSION}"
                expected_sha256="6a5604b5b804e0daca1145df1077609321687734a8b49387e49f10557c186c77"
                ;;
            commons-math3-3.6.1.jar)
                path="org/apache/commons/commons-math3/${COMMONS_MATH3_VERSION}"
                expected_sha256="1e56d7b058d28b65abd256b8458e3885b674c1d588fa43cd7d1cbb9c7ef2b308"
                ;;
            jopt-simple-5.0.4.jar)
                path="net/sf/jopt-simple/jopt-simple/${JOPT_SIMPLE_VERSION}"
                expected_sha256="df26cc58f235f477db07f753ba5a3ab243ebe5789d9f89ecf68dd62ea9a66c28"
                ;;
            *)
                log "ERROR: unknown JMH bundle jar: ${jar}"
                return 30
                ;;
        esac
        if [[ -f "${OPENJDK_OFFLINE_DIR}/${jar}" ]]; then
            log "using local JMH dependency ${OPENJDK_OFFLINE_DIR}/${jar}"
            if ! cp "${OPENJDK_OFFLINE_DIR}/${jar}" "${JMH_DIR}/${jar}"; then
                log "ERROR: failed to copy local JMH dependency ${jar}"
                return 30
            fi
        else
            log "downloading ${jar} from ${MAVEN_MIRROR}"
            if ! curl -fsSL --retry 3 --connect-timeout 30 \
                -o "${JMH_DIR}/${jar}" "${MAVEN_MIRROR}/${path}/${jar}"; then
                log "ERROR: failed to download ${jar}"
                return 30
            fi
        fi
        actual_sha256="$(sha256sum "${JMH_DIR}/${jar}" | awk '{print $1}')"
        if [[ "${actual_sha256}" != "${expected_sha256}" ]]; then
            log "ERROR: checksum mismatch for ${jar}"
            log "expected: ${expected_sha256}"
            log "actual:   ${actual_sha256}"
            return 30
        fi
    done
    log "JMH ${JMH_VERSION} bundle is ready at ${JMH_DIR}"
}

compile_benchmarks() {
    local javac_cp
    javac_cp="${JMH_DIR}/jmh-core-${JMH_VERSION}.jar:${JMH_DIR}/jmh-generator-annprocess-${JMH_VERSION}.jar"
    log "compiling the selected test/micro benchmarks with ${JDK_HOME}/bin/javac"
    mkdir -p "${BENCH_CLASSES_DIR}"
    if ! (
        cd "${SRC_DIR}"
        "${JDK_HOME}/bin/javac" -cp "${javac_cp}" -d "${BENCH_CLASSES_DIR}" \
            ${OPENJDK_BENCH_SOURCES}
    ); then
        log "ERROR: javac failed to compile the benchmark sources"
        return 40
    fi
    if ! "${JDK_HOME}/bin/jar" cf "${BENCH_JAR}" -C "${BENCH_CLASSES_DIR}" .; then
        log "ERROR: failed to package ${BENCH_JAR}"
        return 40
    fi
    if ! "${JDK_HOME}/bin/jar" tf "${BENCH_JAR}" | grep -q "^META-INF/BenchmarkList$"; then
        log "ERROR: ${BENCH_JAR} is missing the JMH benchmark registry (META-INF/BenchmarkList)"
        return 40
    fi
    log "benchmarks.jar is ready: ${BENCH_JAR}"
}

build_openjdk() {
    if initialize_runtime; then
        :
    else
        return $?
    fi
    if install_dependencies; then
        :
    else
        return $?
    fi
    if [[ -e "${JDK_HOME}" || -e "${SRC_DIR}" || -e "${JMH_DIR}" || \
          -e "${BENCH_JAR}" || -e "${BENCH_CLASSES_DIR}" ]]; then
        log "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    fi
    if install_openjdk_binary; then
        :
    else
        return $?
    fi
    if prepare_benchmark_sources; then
        :
    else
        return $?
    fi
    if prepare_jmh_bundle; then
        :
    else
        return $?
    fi
    if compile_benchmarks; then
        :
    else
        return $?
    fi
    log "OpenJDK ${SOFTWARE_VERSION} benchmark runtime is built at ${PERF_WORK_DIR}"
}

start_openjdk_runtime() {
    local class jar jmh_cp

    if initialize_runtime; then
        :
    else
        return $?
    fi
    if [[ ! -x "${JDK_HOME}/bin/java" || ! -s "${BENCH_JAR}" ]]; then
        log "ERROR: OpenJDK runtime or compiled benchmark jar is missing"
        return 40
    fi
    for jar in "jmh-core-${JMH_VERSION}.jar" \
        "commons-math3-${COMMONS_MATH3_VERSION}.jar" \
        "jopt-simple-${JOPT_SIMPLE_VERSION}.jar"; do
        if [[ ! -s "${JMH_DIR}/${jar}" ]]; then
            log "ERROR: JMH dependency is missing: ${JMH_DIR}/${jar}"
            return 40
        fi
    done
    mkdir -p "${RESULTS_DIR}"
    local includes=()
    for class in ${OPENJDK_BENCH_CLASSES}; do
        includes+=("${class}[.]")
    done
    jmh_cp="${BENCH_JAR}:${JMH_DIR}/jmh-core-${JMH_VERSION}.jar:${JMH_DIR}/commons-math3-${COMMONS_MATH3_VERSION}.jar:${JMH_DIR}/jopt-simple-${JOPT_SIMPLE_VERSION}.jar"
    log "listing the selected JMH benchmarks (org.openjdk.jmh.Main -l)"
    if ! "${JDK_HOME}/bin/java" \
        ${OPENJDK_JAVA_OPTIONS} \
        -cp "${jmh_cp}" \
        org.openjdk.jmh.Main \
        "${includes[@]}" \
        -l > "${RESULTS_DIR}/benchmark_list.txt"; then
        log "ERROR: JMH benchmark listing failed"
        return 40
    fi
    if [[ ! -s "${RESULTS_DIR}/benchmark_list.txt" ]]; then
        log "ERROR: JMH benchmark list is empty: ${RESULTS_DIR}/benchmark_list.txt"
        return 40
    fi
    for class in ${OPENJDK_BENCH_CLASSES}; do
        if ! grep -q "^${class//./\\.}[.]" "${RESULTS_DIR}/benchmark_list.txt"; then
            log "ERROR: no benchmarks matched the class: ${class}"
            return 40
        fi
    done
    log "$(wc -l < "${RESULTS_DIR}/benchmark_list.txt") benchmarks matched the selection"
    log "OpenJDK JMH benchmark runtime is ready"
}

run_openjdk_benchmarks() {
    local class jar jmh_cp

    if initialize_runtime; then
        :
    else
        return $?
    fi
    if [[ ! -x "${JDK_HOME}/bin/java" || ! -s "${BENCH_JAR}" ]]; then
        log "ERROR: OpenJDK runtime or compiled benchmark jar is missing"
        return 40
    fi
    for jar in "jmh-core-${JMH_VERSION}.jar" \
        "commons-math3-${COMMONS_MATH3_VERSION}.jar" \
        "jopt-simple-${JOPT_SIMPLE_VERSION}.jar"; do
        if [[ ! -s "${JMH_DIR}/${jar}" ]]; then
            log "ERROR: JMH dependency is missing: ${JMH_DIR}/${jar}"
            return 40
        fi
    done
    mkdir -p "${RESULTS_DIR}"
    local includes=()
    for class in ${OPENJDK_BENCH_CLASSES}; do
        includes+=("${class}[.]")
    done
    jmh_cp="${BENCH_JAR}:${JMH_DIR}/jmh-core-${JMH_VERSION}.jar:${JMH_DIR}/commons-math3-${COMMONS_MATH3_VERSION}.jar:${JMH_DIR}/jopt-simple-${JOPT_SIMPLE_VERSION}.jar"
    log "running official JMH micro benchmarks (json results: ${RESULTS_DIR}/jmh-result.json)"
    if ! (
        "${JDK_HOME}/bin/java" \
            ${OPENJDK_JAVA_OPTIONS} \
            -cp "${jmh_cp}" \
            org.openjdk.jmh.Main \
            "${includes[@]}" \
            -rf json \
            -rff "${RESULTS_DIR}/jmh-result.json" \
            -jvmArgsPrepend "${OPENJDK_JAVA_OPTIONS}"
    ) 2>&1 | tee "${RESULTS_DIR}/benchmark_micro.txt"; then
        log "ERROR: JMH benchmark run failed"
        return 50
    fi
    if [[ ! -s "${RESULTS_DIR}/benchmark_micro.txt" ]]; then
        log "ERROR: JMH console output is empty: ${RESULTS_DIR}/benchmark_micro.txt"
        return 50
    fi
    if [[ ! -s "${RESULTS_DIR}/jmh-result.json" ]]; then
        log "ERROR: JMH result file is empty: ${RESULTS_DIR}/jmh-result.json"
        return 50
    fi
    if [[ -s "${RESULTS_DIR}/benchmark_list.txt" ]]; then
        local listed parsed
        listed="$(grep -c '^org\.openjdk\.bench\.' "${RESULTS_DIR}/benchmark_list.txt" || true)"
        parsed="$(python3 -c 'import json,sys; print(len({e["benchmark"] for e in json.load(open(sys.argv[1]))}))' "${RESULTS_DIR}/jmh-result.json")"
        if [[ "${listed}" -ne "${parsed}" ]]; then
            log "ERROR: JMH result set (${parsed} benchmarks) differs from the benchmark list (${listed})"
            return 50
        fi
    fi
    export SOFTWARE_VERSION EXPECTED_ARCH OPENJDK_BENCH_CLASSES
    export OPENJDK_BENCH_SOURCES OPENJDK_JAVA_OPTIONS
    export OPENJDK_JMH_VERSION="${JMH_VERSION}"
    if ! python3 "${SCRIPT_DIR}/scripts/parse_benchmark.py" \
        "${RESULTS_DIR}/jmh-result.json" \
        "${RESULTS_DIR}/benchmark_openjdk.json"; then
        log "ERROR: failed to normalize the JMH benchmark results"
        return 50
    fi
    log "benchmark results written to benchmark_micro.txt, jmh-result.json, and benchmark_openjdk.json"
}

stop_openjdk_runtime() {
    log "OpenJDK benchmark has no background service to stop"
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
    if [[ "${PERF_WORK_DIR}" != /tmp/openjdk-perf/local-* || \
          "${PERF_WORK_DIR}" == "/tmp/openjdk-perf" ]]; then
        log "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    fi
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        if ! rm -rf -- "${PERF_WORK_DIR}"; then
            log "ERROR: failed to clean standalone work directory: ${PERF_WORK_DIR}"
            return 70
        fi
    fi
    log "cleaned standalone work directory: ${PERF_WORK_DIR}"
}

emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then
        stop_openjdk_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_openjdk_standalone() {
    local stage_status=0 failed_stage="" cleanup_status="passed" finalize_status=0
    local command_status="passed"

    if configure_runtime_paths; then
        :
    else
        return $?
    fi
    STANDALONE_STOP_DONE=0
    STANDALONE_CLEANUP_DONE=0
    trap emergency_standalone_cleanup EXIT
    if initialize_runtime; then
        :
    else
        return $?
    fi

    if standalone_runtime system "${RESULTS_DIR}/system_info.json" && \
        standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json"; then
        :
    else
        stage_status=$?
        failed_stage="prepare"
    fi

    if [[ "${stage_status}" -eq 0 ]]; then
        if build_openjdk; then
            if standalone_runtime build-info \
                "${RESULTS_DIR}/build_info.json" \
                "${SOFTWARE_VERSION}" \
                "${PERF_ACTUAL_VERSION_FILE}" \
                "${EXPECTED_ARCH}" \
                "${PERF_RUN_ID}" \
                "${JDK_VERSION_STRING}" \
                --binary-url="${OPENJDK_BINARY_URL}" \
                --binary-sha256="${OPENJDK_BINARY_SHA256}" \
                --source-repo="${OPENJDK_SOURCE_REPO}" \
                --source-tag="${OPENJDK_SOURCE_TAG}" \
                --source-commit="${OPENJDK_SOURCE_COMMIT}" \
                --jmh-version="${JMH_VERSION}" \
                --bench-classes="${OPENJDK_BENCH_CLASSES}"; then
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
        if start_openjdk_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_openjdk_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_openjdk_runtime; then
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

Evaluate the official OpenJDK prebuilt GA binary (jdk.java.net) with the
official JMH micro benchmarks from test/micro of the matching jdkNNu
source repository. The benchmarks are compiled with the bundled JDK and
run through org.openjdk.jmh.Main, mirroring the OpenJDK harness
(RunTests.gmk SetupRunMicroTest). Results default to
results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       openjdk version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR,
  OPENJDK_SOURCE_BASE, OPENJDK_BINARY_BASE, MAVEN_MIRROR,
  OPENJDK_BENCH_CLASSES
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

    if configure_runtime_paths; then
        :
    else
        return $?
    fi
    if ! mkdir -p "${RESULTS_DIR}"; then
        log "ERROR: failed to create the standalone results directory: ${RESULTS_DIR}"
        return 10
    fi
    : > "${RESULTS_DIR}/results.log"
    local pipeline_status=0
    set +e
    run_openjdk_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
