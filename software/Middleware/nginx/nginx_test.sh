#!/usr/bin/env bash
# nginx performance case (official source build with the official k6 load
# generator).
#
# nginx is officially distributed as source only, so the software under test
# is fetched from nginx.org as the official release tarball (SHA-256
# verified), compiled with its default configure options, and installed into
# a per-task prefix — the same source-build style the gcc and glibc cases
# use.  The load generator is the official k6 release binary, provisioned
# the same way as in the envoy case.
#
# The benchmark serves deterministic static files over plain HTTP with
# keepalive and measures the official k6 summary fields (request rate,
# average and 95th-percentile latency) across a fixed concurrency ladder,
# mirroring the mysql case's thread ladder.
#
# The four framework stages map to: fetch+verify+compile nginx (build),
# configure and launch a throwaway nginx instance with generated static
# files (start), run the k6 scenarios (test), and shut that instance down
# (stop).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_NAME="nginx"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.30.4}"
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

# Official nginx source distribution.
NGINX_RELEASE_BASE="${NGINX_RELEASE_BASE:-https://nginx.org/download}"
NGINX_OFFLINE_DIR="${NGINX_OFFLINE_DIR:-/home/runner/software/nginx}"

# Official k6 release used as the load generator (envoy-case style).
K6_VERSION="${K6_VERSION:-2.2.0}"
K6_X86_64_SHA256="${K6_X86_64_SHA256:-b5a8003c86f35f5cd5ceef1490312c48e587696c94d998cefc6d7b3b4cb1597d}"
K6_AARCH64_SHA256="${K6_AARCH64_SHA256:-4ecd64cadcc792402d16293836115480419c4447c032858f564852d98f1bf54c}"

# Static-file scenarios and the concurrency ladder (mysql thread-ladder
# style).  Each scenario runs once per VU level with HTTP keepalive.
NGINX_STATIC_FILES=(file-1k.bin:1024 file-100k.bin:102400)
NGINX_VUS_LADDER=(128 256 512 1024)
K6_DURATION_SECONDS="${K6_DURATION_SECONDS:-30}"

# Connection settings for the throwaway server.
NGINX_HOST="${NGINX_HOST:-127.0.0.1}"
NGINX_PORT="${NGINX_PORT:-}"

# Lifecycle paths (assigned in configure_runtime_paths).
NGINX_SRC_DIR=""
NGINX_PREFIX=""
NGINX_BIN=""
K6_BIN=""
RUNTIME_DIR=""
DOCROOT=""
CONF_PATH=""
PID_FILE=""
ERROR_LOG=""

log() {
    printf '[nginx] %s\n' "$*"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/nginx/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    NGINX_SRC_DIR="${PERF_WORK_DIR}/nginx-src"
    NGINX_PREFIX="${PERF_WORK_DIR}/nginx-install"
    NGINX_BIN="${NGINX_PREFIX}/sbin/nginx"
    K6_BIN="${PERF_WORK_DIR}/tools/k6"
    RUNTIME_DIR="${PERF_WORK_DIR}/runtime"
    DOCROOT="${RUNTIME_DIR}/html"
    CONF_PATH="${RUNTIME_DIR}/nginx.conf"
    PID_FILE="${RUNTIME_DIR}/nginx.pid"
    ERROR_LOG="${RUNTIME_DIR}/error.log"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    if [[ -z "${NGINX_PORT}" ]]; then
        local checksum
        checksum="$(printf '%s' "${PERF_RUN_ID}" | cksum)"
        NGINX_PORT="$((20000 + ${checksum%% *} % 20000))"
    fi
    if [[ ! "${NGINX_PORT}" =~ ^[0-9]+$ ]] || \
       (( NGINX_PORT < 1024 || NGINX_PORT > 65535 )); then
        log "ERROR: NGINX_PORT must be an unprivileged TCP port: ${NGINX_PORT}"
        return 10
    fi
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}"
}

require_nginx_tools() {
    local command_name package
    local packages=()

    for command_name in curl sha256sum tar gzip make gcc sed awk tee cksum dd stat python3 sudo; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            curl) package="curl" ;;
            sha256sum|tee|cksum|dd|stat) package="coreutils" ;;
            tar) package="tar" ;;
            gzip) package="gzip" ;;
            make) package="make" ;;
            gcc) package="gcc" ;;
            sed) package="sed" ;;
            awk) package="gawk" ;;
            python3) package="python3" ;;
            sudo) package="sudo" ;;
        esac
        log "missing required nginx test command: ${command_name}"
        packages+=("${package}")
    done

    for package in pcre2-devel zlib-devel; do
        if ! rpm -q "${package}" >/dev/null 2>&1; then
            log "missing required nginx test package: ${package}"
            packages+=("${package}")
        fi
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log "ERROR: dnf is required to install nginx test prerequisites"
        return 30
    fi

    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log "installing missing nginx test packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log "ERROR: sudo is required to install nginx test prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log "ERROR: failed to install nginx test prerequisites"
        return 30
    fi

    for command_name in curl sha256sum tar gzip make gcc sed awk tee cksum dd stat python3; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "ERROR: required nginx test command remains unavailable: ${command_name}"
            return 30
        fi
    done
    for package in pcre2-devel zlib-devel; do
        if ! rpm -q "${package}" >/dev/null 2>&1; then
            log "ERROR: required nginx test package remains unavailable: ${package}"
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

fetch_nginx_archive() {
    local archive_path
    local actual_sha256
    local archive_name
    local archive_sha256
    local local_archive_path
    local download_url

    # The official source tarball is architecture independent.  Adding a
    # version means adding its entry here; the download, verification, and
    # lifecycle logic stays unchanged.
    case "${SOFTWARE_VERSION}" in
        1.30.4)
            archive_name="nginx-1.30.4.tar.gz"
            archive_sha256="4261dc90e9e47c1c4041276e9aaa3d48ebe2e664f728e14fa95ae6c67d57a08b"
            ;;
        *)
            log "ERROR: no verified nginx release is declared for ${SOFTWARE_VERSION}"
            return 10
            ;;
    esac

    local_archive_path="${NGINX_OFFLINE_DIR}/${archive_name}"
    if [[ -f "${local_archive_path}" ]]; then
        archive_path="${local_archive_path}"
        log "using local nginx archive ${archive_path}" >&2
    elif [[ -s "${PERF_WORK_DIR}/${archive_name}" ]]; then
        archive_path="${PERF_WORK_DIR}/${archive_name}"
        log "using cached nginx archive ${archive_path}" >&2
    else
        archive_path="${PERF_WORK_DIR}/${archive_name}"
        download_url="${NGINX_RELEASE_BASE}/${archive_name}"
        download_archive "${archive_path}" "${download_url}" || return 30
    fi

    verify_sha256 "${archive_path}" "${archive_sha256}" || return 30
    printf '%s\n' "${archive_path}"
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
    if [[ -f "${NGINX_OFFLINE_DIR}/${archive_name}" ]]; then
        log "using local k6 archive ${NGINX_OFFLINE_DIR}/${archive_name}" >&2
        cp "${NGINX_OFFLINE_DIR}/${archive_name}" "${k6_archive}" || return 30
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

build_nginx() {
    local archive_path
    local actual_version
    local runner_architecture

    initialize_runtime || return $?
    runner_architecture="$(uname -m)"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    require_nginx_tools || return $?
    if [[ -e "${NGINX_PREFIX}" ]]; then
        log "ERROR: build output is not clean under ${NGINX_PREFIX}"
        return 20
    fi

    archive_path="$(fetch_nginx_archive)" || return $?
    fetch_k6 || return $?

    rm -rf "${NGINX_SRC_DIR}" "${PERF_WORK_DIR}/nginx-${SOFTWARE_VERSION}"
    log "extracting ${archive_path}"
    if ! tar -xzf "${archive_path}" -C "${PERF_WORK_DIR}"; then
        log "ERROR: failed to extract ${archive_path}"
        return 40
    fi
    if [[ ! -d "${PERF_WORK_DIR}/nginx-${SOFTWARE_VERSION}" ]]; then
        log "ERROR: cannot locate the unpacked nginx directory"
        return 40
    fi
    mv "${PERF_WORK_DIR}/nginx-${SOFTWARE_VERSION}" "${NGINX_SRC_DIR}"

    log "configuring nginx with its default options"
    if ! (cd "${NGINX_SRC_DIR}" && ./configure --prefix="${NGINX_PREFIX}" \
            --http-log-path="${RUNTIME_DIR}/access.log" \
            --error-log-path="${RUNTIME_DIR}/error.log" \
            --pid-path="${RUNTIME_DIR}/nginx.pid"); then
        log "ERROR: nginx configure failed"
        return 40
    fi
    log "compiling nginx with make -j$(getconf _NPROCESSORS_ONLN)"
    if ! (cd "${NGINX_SRC_DIR}" && make -j"$(getconf _NPROCESSORS_ONLN)" install); then
        log "ERROR: nginx compilation failed"
        return 40
    fi

    if [[ ! -x "${NGINX_BIN}" ]]; then
        log "ERROR: nginx binary is missing after installation"
        return 40
    fi
    actual_version="$("${NGINX_BIN}" -v 2>&1 | sed -nE 's|^nginx version: nginx/([0-9]+\.[0-9]+\.[0-9]+).*$|\1|p' | head -n 1)"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: built nginx is ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "nginx ${actual_version} built from the official source tarball"
}

generate_static_files() {
    local entry file_name file_bytes actual_bytes

    mkdir -p "${DOCROOT}"
    for entry in "${NGINX_STATIC_FILES[@]}"; do
        file_name="${entry%%:*}"
        file_bytes="${entry##*:}"
        if [[ ! -s "${DOCROOT}/${file_name}" ]]; then
            # Zero-filled files are fully deterministic across runs and
            # architectures; sizes are verified below.
            if ! dd if=/dev/zero of="${DOCROOT}/${file_name}" \
                    bs=1024 count=$(( file_bytes / 1024 )) status=none; then
                log "ERROR: failed to generate ${DOCROOT}/${file_name}"
                return 40
            fi
        fi
        actual_bytes="$(stat -c %s "${DOCROOT}/${file_name}")"
        if [[ "${actual_bytes}" != "${file_bytes}" ]]; then
            log "ERROR: static file ${file_name} is ${actual_bytes} bytes, expected ${file_bytes}"
            return 40
        fi
    done
}

write_nginx_configuration() {
    cat > "${CONF_PATH}" <<EOF
worker_processes auto;
worker_rlimit_nofile 65535;
pid ${PID_FILE};
error_log ${ERROR_LOG} warn;

events {
    worker_connections 4096;
}

http {
    access_log off;
    default_type application/octet-stream;
    sendfile on;
    tcp_nopush on;
    keepalive_timeout 65s;

    server {
        listen ${NGINX_HOST}:${NGINX_PORT};
        server_name localhost;
        root ${DOCROOT};

        location / {
        }
    }
}
EOF
}

nginx_ready() {
    curl -sf -o /dev/null "http://${NGINX_HOST}:${NGINX_PORT}/file-1k.bin"
}

start_nginx_service() {
    local attempt

    initialize_runtime || return $?
    if [[ ! -x "${NGINX_BIN}" ]]; then
        log "ERROR: nginx is not built (run build first)"
        return 40
    fi
    if [[ ! -x "${K6_BIN}" ]]; then
        log "ERROR: k6 is not provisioned (run build first)"
        return 40
    fi
    if nginx_ready; then
        log "ERROR: a service is already reachable on ${NGINX_HOST}:${NGINX_PORT}"
        log "ERROR: refusing to benchmark a pre-existing service"
        return 20
    fi
    if [[ -e "${RUNTIME_DIR}" ]]; then
        log "ERROR: nginx runtime directory is not clean: ${RUNTIME_DIR}"
        return 20
    fi

    generate_static_files || return $?
    write_nginx_configuration || return $?

    log "starting a throwaway nginx ${SOFTWARE_VERSION} instance on port ${NGINX_PORT}"
    if ! "${NGINX_BIN}" -p "${RUNTIME_DIR}" -c "${CONF_PATH}"; then
        log "ERROR: failed to launch nginx (see ${ERROR_LOG})"
        return 40
    fi
    for attempt in $(seq 1 30); do
        if nginx_ready; then
            break
        fi
        sleep 1
    done
    if ! nginx_ready; then
        log "ERROR: nginx did not become ready (see ${ERROR_LOG})"
        return 40
    fi

    # Smoke-verify every scenario file byte-for-byte before benchmarking.
    local entry file_name file_bytes fetched_bytes
    for entry in "${NGINX_STATIC_FILES[@]}"; do
        file_name="${entry%%:*}"
        file_bytes="${entry##*:}"
        fetched_bytes="$(curl -sf "http://${NGINX_HOST}:${NGINX_PORT}/${file_name}" | wc -c)"
        if [[ "${fetched_bytes}" != "${file_bytes}" ]]; then
            log "ERROR: smoke fetch of ${file_name} returned ${fetched_bytes} bytes, expected ${file_bytes}"
            return 40
        fi
    done
    log "nginx service is ready for benchmarking"
}

run_nginx_benchmarks() {
    initialize_runtime || return $?
    require_nginx_tools || return $?
    if [[ ! -x "${K6_BIN}" ]]; then
        log "ERROR: k6 is not provisioned (run build first)"
        return 50
    fi
    if ! nginx_ready; then
        log "ERROR: nginx is not reachable on ${NGINX_HOST}:${NGINX_PORT}"
        return 50
    fi

    export K6_DURATION_SECONDS NGINX_HOST NGINX_PORT
    python3 "${SCRIPT_DIR}/scripts/run_nginx_benchmark.py" \
        --k6 "${K6_BIN}" \
        --url-base "http://${NGINX_HOST}:${NGINX_PORT}" \
        --output "${RESULTS_DIR}/results.json" \
        --raw-output "${RESULTS_DIR}/nginx_k6_raw.log" || return 50
    log "k6 static-file scenarios completed"
}

stop_nginx_service() {
    local attempt pid

    initialize_runtime || return $?
    if [[ ! -f "${PID_FILE}" ]] && ! nginx_ready; then
        log "no managed nginx instance; nothing to stop"
    else
        if ! "${NGINX_BIN}" -p "${RUNTIME_DIR}" -c "${CONF_PATH}" -s quit >/dev/null 2>&1; then
            if [[ -f "${PID_FILE}" ]]; then
                pid="$(cat "${PID_FILE}" 2>/dev/null)"
                if [[ "${pid}" =~ ^[0-9]+$ ]]; then
                    kill "${pid}" 2>/dev/null || true
                fi
            fi
        fi
        for attempt in $(seq 1 20); do
            if ! nginx_ready; then
                break
            fi
            sleep 0.5
        done
        if nginx_ready; then
            if [[ -f "${PID_FILE}" ]]; then
                pid="$(cat "${PID_FILE}" 2>/dev/null)"
                if [[ "${pid}" =~ ^[0-9+$ ]]; then
                    kill -9 "${pid}" 2>/dev/null || true
                fi
            fi
            sleep 1
        fi
        if nginx_ready; then
            log "ERROR: nginx is still reachable on ${NGINX_HOST}:${NGINX_PORT}"
            return 50
        fi
        log "nginx service stopped"
    fi
    if [[ -d "${RUNTIME_DIR}" ]]; then
        rm -rf "${RUNTIME_DIR}"
        log "nginx runtime data removed from ${RUNTIME_DIR}"
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
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/nginx/local-* || \
          "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/nginx" ]]; then
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
        stop_nginx_service
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_nginx_standalone() {
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
        if build_nginx; then
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
        if start_nginx_service; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_nginx_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_nginx_service; then
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

Build the official nginx source release and benchmark static-file serving
with the official k6 load generator as a standalone performance evaluation.
Results default to results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       nginx version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR, NGINX_PORT,
  K6_DURATION_SECONDS
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
    run_nginx_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
