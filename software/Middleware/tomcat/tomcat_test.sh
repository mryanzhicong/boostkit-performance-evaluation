#!/usr/bin/env bash
# Apache Tomcat performance case (official prebuilt deployment with the
# official k6 load generator).
#
# The software under test is the official Apache Tomcat binary distribution
# (SHA-512 verified, architecture independent) unpacked into the task work
# directory — no system-level Tomcat packages are installed.  The JVM
# runtime is the fixed Eclipse Temurin GA JDK release (SHA-256 verified),
# provisioned the same way the openjdk case provisions its boot JDK.  The
# load generator is the official k6 release binary, provisioned the same
# way as in the envoy and nginx cases.
#
# The benchmark keeps the official out-of-the-box configuration and only
# injects per-task ports: the static scenarios serve deterministic files
# from the default ROOT webapp and the servlet scenario drives the official
# examples webapp's HelloWorldExample servlet that ships inside the
# distribution.  The mysql-style concurrency ladder (128/256/512/1024 VUs)
# runs each scenario for a fixed duration with HTTP keepalive.
#
# The four framework stages map to: fetch+verify Tomcat/JDK/k6 and verify
# versions (build), assemble a throwaway CATALINA_BASE and launch Tomcat
# (start), run the k6 scenarios (test), and shut that instance down (stop).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="tomcat"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-11.0.25}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
PERF_GITHUB_DOWNLOAD_PROXY="${PERF_GITHUB_DOWNLOAD_PROXY:-}"
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

# Official Apache Tomcat distribution (architecture independent).
TOMCAT_RELEASE_BASE="${TOMCAT_RELEASE_BASE:-https://dlcdn.apache.org/tomcat/tomcat-11}"
TOMCAT_OFFLINE_DIR="${TOMCAT_OFFLINE_DIR:-/home/runner/software/tomcat}"

# Fixed JVM runtime: Eclipse Temurin GA JDK (openjdk-case style boot JDK).
JDK_RELEASE_TAG="${JDK_RELEASE_TAG:-jdk-25.0.4.1+1}"
JDK_VERSION="25.0.4.1"
ADOPTIUM_RELEASE_BASE="${ADOPTIUM_RELEASE_BASE:-https://github.com/adoptium/temurin25-binaries/releases/download}"
JDK_X86_64_SHA256="${JDK_X86_64_SHA256:-dbb698396d478e7fa2b1e50f4103324b2a99b90569ee27c33f2261f9215cf41e}"
JDK_AARCH64_SHA256="${JDK_AARCH64_SHA256:-69df11a02cfa3ef7d7ca645e03edce6778ec090e100f6ae2b42097865730ac52}"

# Official k6 release used as the load generator (envoy/nginx-case style).
K6_VERSION="${K6_VERSION:-2.2.0}"
K6_X86_64_SHA256="${K6_X86_64_SHA256:-b5a8003c86f35f5cd5ceef1490312c48e587696c94d998cefc6d7b3b4cb1597d}"
K6_AARCH64_SHA256="${K6_AARCH64_SHA256:-4ecd64cadcc792402d16293836115480419c4447c032858f564852d98f1bf54c}"

# Static-file scenarios, the servlet scenario, and the concurrency ladder
# (mysql thread-ladder style).
TOMCAT_STATIC_FILES=(file-1k.bin:1024 file-100k.bin:102400)
TOMCAT_SERVLET_PATH="examples/servlets/servlet/HelloWorldExample"
TOMCAT_VUS_LADDER=(128 256 512 1024)
K6_DURATION_SECONDS="${K6_DURATION_SECONDS:-30}"

# Fixed JVM heap so both architectures run the same collector behaviour.
JVM_HEAP_SIZE="${JVM_HEAP_SIZE:-1g}"

# Connection settings for the throwaway server.
TOMCAT_HOST="${TOMCAT_HOST:-127.0.0.1}"
TOMCAT_PORT="${TOMCAT_PORT:-}"
TOMCAT_SHUTDOWN_PORT="${TOMCAT_SHUTDOWN_PORT:-}"

# Lifecycle paths (assigned in configure_runtime_paths).
TOMCAT_HOME=""
JDK_HOME=""
JAVA_BIN=""
K6_BIN=""
CATALINA_BASE=""
SERVER_XML=""
CATALINA_PID_FILE=""
CATALINA_LOG=""

log() {
    printf '[tomcat] %s\n' "$*"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/tomcat/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    TOMCAT_HOME="${PERF_WORK_DIR}/tomcat"
    JDK_HOME="${PERF_WORK_DIR}/jdk"
    JAVA_BIN="${JDK_HOME}/bin/java"
    K6_BIN="${PERF_WORK_DIR}/tools/k6"
    CATALINA_BASE="${PERF_WORK_DIR}/catalina-base"
    SERVER_XML="${CATALINA_BASE}/conf/server.xml"
    CATALINA_PID_FILE="${CATALINA_BASE}/tomcat.pid"
    CATALINA_LOG="${CATALINA_BASE}/logs/catalina.log"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    if [[ -z "${TOMCAT_PORT}" ]]; then
        local checksum
        checksum="$(printf '%s' "${PERF_RUN_ID}" | cksum)"
        TOMCAT_PORT="$((20000 + ${checksum%% *} % 20000))"
    fi
    if [[ -z "${TOMCAT_SHUTDOWN_PORT}" ]]; then
        TOMCAT_SHUTDOWN_PORT="$(( TOMCAT_PORT + 1 ))"
    fi
    local port
    for port in "${TOMCAT_PORT}" "${TOMCAT_SHUTDOWN_PORT}"; do
        if [[ ! "${port}" =~ ^[0-9]+$ ]] || \
           (( port < 1024 || port > 65535 )); then
            log "ERROR: ports must be unprivileged TCP ports: ${port}"
            return 10
        fi
    done
    if [[ "${TOMCAT_PORT}" == "${TOMCAT_SHUTDOWN_PORT}" ]]; then
        log "ERROR: HTTP and shutdown ports must differ"
        return 10
    fi
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}"
}

require_tomcat_tools() {
    local command_name package
    local packages=()

    for command_name in curl sha256sum sha512sum tar gzip sed awk tee cksum dd stat python3 sudo; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            curl) package="curl" ;;
            sha256sum|sha512sum|tee|cksum|dd|stat) package="coreutils" ;;
            tar) package="tar" ;;
            gzip) package="gzip" ;;
            sed) package="sed" ;;
            awk) package="gawk" ;;
            python3) package="python3" ;;
            sudo) package="sudo" ;;
        esac
        log "missing required Tomcat test command: ${command_name}"
        packages+=("${package}")
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log "ERROR: dnf is required to install Tomcat test prerequisites"
        return 30
    fi

    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log "installing missing Tomcat test packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log "ERROR: sudo is required to install Tomcat test prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log "ERROR: failed to install Tomcat test prerequisites"
        return 30
    fi

    for command_name in curl sha256sum sha512sum tar gzip sed awk tee cksum dd stat python3; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "ERROR: required Tomcat test command remains unavailable: ${command_name}"
            return 30
        fi
    done
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

fetch_tomcat_archive() {
    local archive_path
    local actual_sha512
    local archive_name
    local archive_sha512
    local local_archive_path
    local download_url

    # The official distribution is architecture independent.  Adding a
    # version means adding its entry here; the download, verification, and
    # lifecycle logic stays unchanged.
    case "${SOFTWARE_VERSION}" in
        11.0.25)
            archive_name="apache-tomcat-11.0.25.tar.gz"
            archive_sha512="81339c046dff1b363a80a3bccf80cb391660a6828dd8ae042180ceb11c8b1614317143e60b311b9e791dab585bb046b777234667acce7dca2203a74b37bf20f2"
            ;;
        *)
            log "ERROR: no verified Tomcat release is declared for ${SOFTWARE_VERSION}"
            return 10
            ;;
    esac

    local_archive_path="${TOMCAT_OFFLINE_DIR}/${archive_name}"
    if [[ -f "${local_archive_path}" ]]; then
        archive_path="${local_archive_path}"
        log "using local Tomcat archive ${archive_path}" >&2
    elif [[ -s "${PERF_WORK_DIR}/${archive_name}" ]]; then
        archive_path="${PERF_WORK_DIR}/${archive_name}"
        log "using cached Tomcat archive ${archive_path}" >&2
    else
        archive_path="${PERF_WORK_DIR}/${archive_name}"
        download_url="${TOMCAT_RELEASE_BASE}/v${SOFTWARE_VERSION}/bin/${archive_name}"
        download_archive "${archive_path}" "${download_url}" || return 30
    fi

    actual_sha512="$(sha512sum "${archive_path}")"
    actual_sha512="${actual_sha512%% *}"
    if [[ "${actual_sha512}" != "${archive_sha512}" ]]; then
        log "ERROR: Tomcat archive checksum mismatch: expected ${archive_sha512}, got ${actual_sha512}" >&2
        return 30
    fi
    printf '%s\n' "${archive_path}"
}

fetch_jdk() {
    local archive_name
    local archive_sha256
    local archive_path
    local local_archive_path
    local top_dir

    case "${EXPECTED_ARCH}" in
        x86_64)
            archive_name="OpenJDK25U-jdk_x64_linux_hotspot_${JDK_VERSION}_1.tar.gz"
            archive_sha256="${JDK_X86_64_SHA256}"
            ;;
        aarch64)
            archive_name="OpenJDK25U-jdk_aarch64_linux_hotspot_${JDK_VERSION}_1.tar.gz"
            archive_sha256="${JDK_AARCH64_SHA256}"
            ;;
        *)
            log "ERROR: no Temurin JDK release is declared for ${EXPECTED_ARCH}"
            return 10
            ;;
    esac

    if [[ -x "${JAVA_BIN}" ]]; then
        log "reusing cached Temurin JDK ${JDK_VERSION}"
        return 0
    fi
    archive_path="${PERF_WORK_DIR}/${archive_name}"
    local_archive_path="${TOMCAT_OFFLINE_DIR}/${archive_name}"
    if [[ -f "${local_archive_path}" ]]; then
        log "using local Temurin JDK archive ${local_archive_path}" >&2
        cp "${local_archive_path}" "${archive_path}" || return 30
    else
        local download_url="${ADOPTIUM_RELEASE_BASE}/${JDK_RELEASE_TAG/+/%2B}/${archive_name}"
        if [[ -n "${PERF_GITHUB_DOWNLOAD_PROXY}" ]]; then
            download_url="${PERF_GITHUB_DOWNLOAD_PROXY%/}/${download_url}"
        fi
        download_archive "${archive_path}" "${download_url}" || return 30
    fi
    verify_sha256 "${archive_path}" "${archive_sha256}" || return 30

    top_dir="$(tar -tzf "${archive_path}" | awk -F/ 'NR == 1 {print $1}')"
    if [[ -z "${top_dir}" || "${top_dir}" != "jdk-"* ]]; then
        log "ERROR: Temurin JDK archive has an unexpected root directory: ${top_dir}"
        return 40
    fi
    rm -rf "${JDK_HOME}"
    if ! tar -xzf "${archive_path}" -C "${PERF_WORK_DIR}"; then
        log "ERROR: failed to extract the Temurin JDK archive"
        return 40
    fi
    mv "${PERF_WORK_DIR}/${top_dir}" "${JDK_HOME}" || return 40
    rm -f "${archive_path}"
    log "Temurin JDK ${JDK_VERSION} provisioned"
}

fetch_k6() {
    local archive_name
    local archive_sha256
    local k6_archive
    local k6_dir

    case "${EXPECTED_ARCH}" in
        x86_64)
            archive_name="k6-v${K6_VERSION}-linux-amd64.tar.gz"
            archive_sha256="${K6_X86_64_SHA256}"
            ;;
        aarch64)
            archive_name="k6-v${K6_VERSION}-linux-arm64.tar.gz"
            archive_sha256="${K6_AARCH64_SHA256}"
            ;;
        *)
            log "ERROR: no k6 release is declared for ${EXPECTED_ARCH}"
            return 10
            ;;
    esac

    mkdir -p "${PERF_WORK_DIR}/tools"
    if [[ -x "${K6_BIN}" ]]; then
        log "reusing cached k6 ${K6_VERSION}"
        return 0
    fi
    k6_archive="${PERF_WORK_DIR}/tools/${archive_name}"
    if [[ -f "${TOMCAT_OFFLINE_DIR}/${archive_name}" ]]; then
        log "using local k6 archive ${TOMCAT_OFFLINE_DIR}/${archive_name}" >&2
        cp "${TOMCAT_OFFLINE_DIR}/${archive_name}" "${k6_archive}" || return 30
    else
        local download_url="https://github.com/grafana/k6/releases/download/v${K6_VERSION}/${archive_name}"
        if [[ -n "${PERF_GITHUB_DOWNLOAD_PROXY}" ]]; then
            download_url="${PERF_GITHUB_DOWNLOAD_PROXY%/}/${download_url}"
        fi
        download_archive "${k6_archive}" "${download_url}" || return 30
    fi
    verify_sha256 "${k6_archive}" "${archive_sha256}" || return 30
    tar -xzf "${k6_archive}" -C "${PERF_WORK_DIR}/tools" || return 30
    k6_dir="${PERF_WORK_DIR}/tools/${archive_name%.tar.gz}"
    install -m 0755 "${k6_dir}/k6" "${K6_BIN}" || return 30
    "${K6_BIN}" version >/dev/null || return 30
    log "k6 ${K6_VERSION} provisioned"
}

build_tomcat() {
    local archive_path
    local actual_version
    local runner_architecture
    local jdk_actual_version

    initialize_runtime || return $?
    runner_architecture="$(uname -m)"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    require_tomcat_tools || return $?
    if [[ -e "${TOMCAT_HOME}" ]]; then
        log "ERROR: build output is not clean under ${TOMCAT_HOME}"
        return 20
    fi

    archive_path="$(fetch_tomcat_archive)" || return $?
    fetch_jdk || return $?
    fetch_k6 || return $?

    log "extracting ${archive_path}"
    if ! tar -xzf "${archive_path}" -C "${PERF_WORK_DIR}"; then
        log "ERROR: failed to extract ${archive_path}"
        return 40
    fi
    if [[ ! -d "${PERF_WORK_DIR}/apache-tomcat-${SOFTWARE_VERSION}" ]]; then
        log "ERROR: cannot locate the unpacked Tomcat directory"
        return 40
    fi
    mv "${PERF_WORK_DIR}/apache-tomcat-${SOFTWARE_VERSION}" "${TOMCAT_HOME}"

    if [[ ! -x "${JAVA_BIN}" ]]; then
        log "ERROR: the provisioned JDK is missing bin/java"
        return 40
    fi
    jdk_actual_version="$("${JAVA_BIN}" -version 2>&1 | sed -nE 's/^openjdk version "([0-9]+\.[0-9]+)\.[0-9]+[^"]*".*/\1/p' | head -n 1)"
    if [[ "${jdk_actual_version}" != "${JDK_VERSION%%.*}" ]]; then
        log "ERROR: provisioned JDK is ${jdk_actual_version:-unknown}, expected the ${JDK_VERSION%%.*} feature release"
        return 40
    fi

    actual_version="$("${JAVA_BIN}" -cp "${TOMCAT_HOME}/lib/catalina.jar" \
        org.apache.catalina.util.ServerInfo 2>/dev/null | \
        sed -nE 's/^Server version: Apache Tomcat\/([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -n 1)"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: deployed Tomcat is ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    if [[ ! -f "${TOMCAT_HOME}/webapps/examples/WEB-INF/classes/HelloWorldExample.class" ]]; then
        log "ERROR: the official examples webapp is missing HelloWorldExample"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "Tomcat ${actual_version} deployed on Temurin JDK ${JDK_VERSION} from the official distribution"
}

generate_static_files() {
    local entry file_name file_bytes actual_bytes

    mkdir -p "${CATALINA_BASE}/webapps/ROOT"
    for entry in "${TOMCAT_STATIC_FILES[@]}"; do
        file_name="${entry%%:*}"
        file_bytes="${entry##*:}"
        if [[ ! -s "${CATALINA_BASE}/webapps/ROOT/${file_name}" ]]; then
            # Zero-filled files are fully deterministic across runs and
            # architectures; sizes are verified below.
            if ! dd if=/dev/zero of="${CATALINA_BASE}/webapps/ROOT/${file_name}" \
                    bs=1024 count=$(( file_bytes / 1024 )) status=none; then
                log "ERROR: failed to generate ${CATALINA_BASE}/webapps/ROOT/${file_name}"
                return 40
            fi
        fi
        actual_bytes="$(stat -c %s "${CATALINA_BASE}/webapps/ROOT/${file_name}")"
        if [[ "${actual_bytes}" != "${file_bytes}" ]]; then
            log "ERROR: static file ${file_name} is ${actual_bytes} bytes, expected ${file_bytes}"
            return 40
        fi
    done
}

assemble_catalina_base() {
    rm -rf "${CATALINA_BASE}"
    mkdir -p "${CATALINA_BASE}/logs" "${CATALINA_BASE}/temp" "${CATALINA_BASE}/conf" "${CATALINA_BASE}/webapps"
    cp -a "${TOMCAT_HOME}/conf/." "${CATALINA_BASE}/conf/" || return 40

    # Keep the official out-of-the-box configuration; only inject the
    # per-task ports into the shipped server.xml (mysql-style: inject the
    # instance address, keep the original scenario definitions).
    sed -i \
        -e "s|port=\"8080\"|port=\"${TOMCAT_PORT}\"|" \
        -e "s|port=\"8005\"|port=\"${TOMCAT_SHUTDOWN_PORT}\"|" \
        "${SERVER_XML}" || return 40

    # Deploy the official webapps (ROOT, docs, examples, managers) as they
    # ship in the distribution.
    cp -a "${TOMCAT_HOME}/webapps/." "${CATALINA_BASE}/webapps/" || return 40
    generate_static_files || return $?
    log "CATALINA_BASE assembled at ${CATALINA_BASE} (ports ${TOMCAT_PORT}/${TOMCAT_SHUTDOWN_PORT})"
}

tomcat_ready() {
    curl -sf -o /dev/null "http://${TOMCAT_HOST}:${TOMCAT_PORT}/file-1k.bin"
}

start_tomcat_service() {
    local attempt

    initialize_runtime || return $?
    if [[ ! -d "${TOMCAT_HOME}" || ! -x "${JAVA_BIN}" ]]; then
        log "ERROR: Tomcat is not deployed (run build first)"
        return 40
    fi
    if [[ ! -x "${K6_BIN}" ]]; then
        log "ERROR: k6 is not provisioned (run build first)"
        return 40
    fi
    if tomcat_ready; then
        log "ERROR: a service is already reachable on ${TOMCAT_HOST}:${TOMCAT_PORT}"
        log "ERROR: refusing to benchmark a pre-existing service"
        return 20
    fi
    if [[ -e "${CATALINA_BASE}" ]]; then
        log "ERROR: Tomcat runtime directory is not clean: ${CATALINA_BASE}"
        return 20
    fi

    assemble_catalina_base || return $?

    log "starting a throwaway Tomcat ${SOFTWARE_VERSION} instance on port ${TOMCAT_PORT}"
    if ! (export CATALINA_BASE CATALINA_HOME="${TOMCAT_HOME}" CATALINA_PID="${CATALINA_PID_FILE}" \
            CATALINA_OPTS="-Xms${JVM_HEAP_SIZE} -Xmx${JVM_HEAP_SIZE}" \
            JAVA_HOME="${JDK_HOME}" JRE_HOME="${JDK_HOME}" \
            PATH="${JDK_HOME}/bin:${PATH}" && \
        "${TOMCAT_HOME}/bin/startup.sh"); then
        log "ERROR: failed to launch Tomcat (see ${CATALINA_LOG})"
        return 40
    fi
    for attempt in $(seq 1 60); do
        if tomcat_ready; then
            break
        fi
        sleep 1
    done
    if ! tomcat_ready; then
        log "ERROR: Tomcat did not become ready (see ${CATALINA_LOG})"
        return 40
    fi

    # Smoke-verify every scenario target before benchmarking: both static
    # files byte-for-byte and the official servlet's 200 response.
    local entry file_name file_bytes fetched_bytes
    for entry in "${TOMCAT_STATIC_FILES[@]}"; do
        file_name="${entry%%:*}"
        file_bytes="${entry##*:}"
        fetched_bytes="$(curl -sf "http://${TOMCAT_HOST}:${TOMCAT_PORT}/${file_name}" | wc -c)"
        if [[ "${fetched_bytes}" != "${file_bytes}" ]]; then
            log "ERROR: smoke fetch of ${file_name} returned ${fetched_bytes} bytes, expected ${file_bytes}"
            return 40
        fi
    done
    if ! curl -sf -o /dev/null "http://${TOMCAT_HOST}:${TOMCAT_PORT}/${TOMCAT_SERVLET_PATH}"; then
        log "ERROR: smoke call of the official servlet failed: ${TOMCAT_SERVLET_PATH}"
        return 40
    fi
    log "Tomcat service is ready for benchmarking"
}

run_tomcat_benchmarks() {
    initialize_runtime || return $?
    require_tomcat_tools || return $?
    if [[ ! -x "${K6_BIN}" ]]; then
        log "ERROR: k6 is not provisioned (run build first)"
        return 50
    fi
    if ! tomcat_ready; then
        log "ERROR: Tomcat is not reachable on ${TOMCAT_HOST}:${TOMCAT_PORT}"
        return 50
    fi

    export K6_DURATION_SECONDS TOMCAT_HOST TOMCAT_PORT
    python3 "${SCRIPT_DIR}/scripts/run_tomcat_benchmark.py" \
        --k6 "${K6_BIN}" \
        --url-base "http://${TOMCAT_HOST}:${TOMCAT_PORT}" \
        --output "${RESULTS_DIR}/results.json" \
        --raw-output "${RESULTS_DIR}/tomcat_k6_raw.log" || return 50
    log "k6 static and servlet scenarios completed"
}

stop_tomcat_service() {
    local attempt pid

    initialize_runtime || return $?
    if [[ ! -f "${CATALINA_PID_FILE}" ]] && ! tomcat_ready; then
        log "no managed Tomcat instance; nothing to stop"
    else
        (export CATALINA_BASE CATALINA_HOME="${TOMCAT_HOME}" CATALINA_PID="${CATALINA_PID_FILE}" \
                JAVA_HOME="${JDK_HOME}" JRE_HOME="${JDK_HOME}" \
                PATH="${JDK_HOME}/bin:${PATH}" && \
            "${TOMCAT_HOME}/bin/shutdown.sh" 5) >/dev/null 2>&1 || true
        for attempt in $(seq 1 30); do
            if ! tomcat_ready; then
                break
            fi
            sleep 1
        done
        if tomcat_ready; then
            if [[ -f "${CATALINA_PID_FILE}" ]]; then
                pid="$(cat "${CATALINA_PID_FILE}" 2>/dev/null)"
                if [[ "${pid}" =~ ^[0-9]+$ ]]; then
                    kill "${pid}" 2>/dev/null || true
                fi
            fi
            sleep 3
        fi
        if tomcat_ready && [[ -f "${CATALINA_PID_FILE}" ]]; then
            pid="$(cat "${CATALINA_PID_FILE}" 2>/dev/null)"
            if [[ "${pid}" =~ ^[0-9]+$ ]]; then
                kill -9 "${pid}" 2>/dev/null || true
            fi
            sleep 1
        fi
        if tomcat_ready; then
            log "ERROR: Tomcat is still reachable on ${TOMCAT_HOST}:${TOMCAT_PORT}"
            return 50
        fi
        log "Tomcat service stopped"
    fi
    if [[ -d "${CATALINA_BASE}" ]]; then
        rm -rf "${CATALINA_BASE}"
        log "Tomcat runtime data removed from ${CATALINA_BASE}"
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
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/tomcat/local-* || \
          "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/tomcat" ]]; then
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
        stop_tomcat_service
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_tomcat_standalone() {
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
        if build_tomcat; then
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
        if start_tomcat_service; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_tomcat_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_tomcat_service; then
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

Deploy the official Apache Tomcat distribution on the fixed Temurin JDK and
benchmark static files plus the official examples servlet with the official
k6 load generator as a standalone performance evaluation. Results default
to results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       Tomcat version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR, TOMCAT_PORT,
  TOMCAT_SHUTDOWN_PORT, K6_DURATION_SECONDS, JVM_HEAP_SIZE
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
    run_tomcat_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
