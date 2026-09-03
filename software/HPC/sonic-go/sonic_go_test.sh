#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.15.2}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
SONIC_GO_SOURCE_URL="${SONIC_GO_SOURCE_URL:-https://github.com/bytedance/sonic.git}"
SONIC_GO_PROXY="${SONIC_GO_PROXY:-https://goproxy.cn}"
GO_VERSION="${GO_VERSION:-1.26.7}"
GO_RELEASE_URL="${GO_RELEASE_URL:-https://go.dev/dl}"
GO_OFFLINE_DIR="${GO_OFFLINE_DIR:-/home/runner/software/golang}"
GO_RUNTIME_ROOT="${GO_RUNTIME_ROOT:-/home/runner/sonic-go-work}"

SOURCE_DIR=""
GO_RUNTIME_DIR=""
GO_INSTALL_DIR=""
GO_BIN=""
GO_ARCH=""
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

log() {
    printf '[sonic-go] %s\n' "$*"
}

initialize_runtime() {
    local actual_arch expected_arch

    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64)
            expected_arch="x86_64"
            GO_ARCH="amd64"
            ;;
        aarch64|arm64)
            expected_arch="aarch64"
            GO_ARCH="arm64"
            ;;
        *)
            log "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    case "$(uname -m)" in
        x86_64|amd64) actual_arch="x86_64" ;;
        aarch64|arm64) actual_arch="aarch64" ;;
        *) actual_arch="$(uname -m)" ;;
    esac
    if [[ "${actual_arch}" != "${expected_arch}" ]]; then
        log "ERROR: expected architecture ${expected_arch}, runner is ${actual_arch}"
        return 20
    fi
    EXPECTED_ARCH="${expected_arch}"

    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/tmp/sonic-go-perf/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi

    SOURCE_DIR="${PERF_WORK_DIR}/sonic-go-source"
    GO_RUNTIME_DIR="${GO_RUNTIME_ROOT}/${SOFTWARE_VERSION}/${EXPECTED_ARCH}/${PERF_RUN_ID}"
    GO_INSTALL_DIR="${PERF_WORK_DIR}/go-install"
    GO_BIN="${GO_INSTALL_DIR}/bin/go"
    export GOCACHE="${GO_RUNTIME_DIR}/cache"
    export GOMODCACHE="${GO_RUNTIME_DIR}/module-cache"
    export GOPATH="${GO_RUNTIME_DIR}/path"
    export GOPROXY="${SONIC_GO_PROXY}"
    export GOTOOLCHAIN=local
    export GOENV=off
    export GOWORK=off
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
    export SONIC_GO_BIN="${GO_BIN}" SONIC_GO_VERSION="${GO_VERSION}"
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${GOCACHE}" "${GOMODCACHE}" "${GOPATH}"
}

run_as_root() {
    if [[ "${EUID}" -eq 0 ]]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
        sudo -n "$@"
    else
        log "ERROR: root privileges are required to install missing dependencies"
        return 30
    fi
}

install_dependencies() {
    local required package
    local packages=()

    for required in git curl gcc tar gzip sha256sum awk python3 tee; do
        if command -v "${required}" >/dev/null 2>&1; then
            continue
        fi
        case "${required}" in
            git) package="git" ;;
            curl) package="curl" ;;
            gcc) package="gcc" ;;
            tar) package="tar" ;;
            gzip) package="gzip" ;;
            sha256sum|tee) package="coreutils" ;;
            awk) package="gawk" ;;
            python3) package="python3" ;;
        esac
        packages+=("${package}")
    done
    if [[ "${#packages[@]}" -gt 0 ]]; then
        log "installing missing Sonic Go dependencies: ${packages[*]}"
        if command -v dnf >/dev/null 2>&1; then
            run_as_root dnf install -y "${packages[@]}" || return 30
        elif command -v yum >/dev/null 2>&1; then
            run_as_root yum install -y "${packages[@]}" || return 30
        elif command -v apt-get >/dev/null 2>&1; then
            run_as_root env DEBIAN_FRONTEND=noninteractive apt-get update || return 30
            run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y \
                git curl gcc tar gzip coreutils gawk python3 || return 30
        else
            log "ERROR: no supported package manager is available"
            return 30
        fi
    fi
    for required in git curl gcc tar gzip sha256sum awk python3 tee; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            log "ERROR: required command remains unavailable: ${required}"
            return 30
        fi
    done
}

configure_go_environment() {
    export GOROOT="${GO_INSTALL_DIR}"
    export PATH="${GO_INSTALL_DIR}/bin:${PATH}"
    export GOTOOLCHAIN=local
    export GOENV=off
    export GOWORK=off
}

copy_or_download_go_archive() {
    local archive="$1" filename expected actual offline_archive

    filename="$(basename "${archive}")"
    offline_archive="${GO_OFFLINE_DIR}/${filename}"
    case "${GO_VERSION}:${GO_ARCH}" in
        1.26.7:amd64)
            expected="ffb5f8de10c62550dfddab66b36b57030721e0a44a3218e9e1181d7b59f121ca"
            ;;
        1.26.7:arm64)
            expected="5a4ec883379d51ee9ce1040d5e87f8d35e20387574dd8c947feb01eabc3c1b37"
            ;;
        1.27.0:amd64)
            expected="675c26c449cbb18fc24b74650de1eabbae6e16f64326fd85a283fb3b58280685"
            ;;
        1.27.0:arm64)
            expected="51798d2c42d0e1c6ed7fd9f48728b4193abac9e8aad6dbac2fe96a81f5909bda"
            ;;
        *)
            log "ERROR: no verified Go binary release is declared for ${GO_VERSION} on ${GO_ARCH}"
            return 10
            ;;
    esac
    if [[ -f "${offline_archive}" ]]; then
        log "using offline Go archive ${offline_archive}"
        cp "${offline_archive}" "${archive}"
    else
        log "downloading official Go archive ${filename}"
        if ! curl -fsSL --retry 3 --connect-timeout 30 -o "${archive}" \
            "${GO_RELEASE_URL}/${filename}"; then
            log "ERROR: failed to download ${filename}"
            return 30
        fi
    fi
    actual="$(sha256sum "${archive}" | awk '{print $1}')"
    if [[ "${actual}" != "${expected}" ]]; then
        log "ERROR: Go archive checksum mismatch: ${filename}"
        return 30
    fi
}

verify_go_binary() {
    local actual_version actual_arch

    if [[ ! -x "${GO_BIN}" ]]; then
        log "ERROR: private Go binary is unavailable: ${GO_BIN}"
        return 40
    fi
    actual_version="$("${GO_BIN}" version | awk '{print $3}' | sed 's/^go//')" || return 40
    actual_arch="$("${GO_BIN}" env GOARCH)" || return 40
    if [[ "${actual_version}" != "${GO_VERSION}" || "${actual_arch}" != "${GO_ARCH}" ]]; then
        log "ERROR: private Go is ${actual_version}/${actual_arch}, expected ${GO_VERSION}/${GO_ARCH}"
        return 40
    fi
}

install_go_binary() {
    local archive

    if [[ -e "${GO_INSTALL_DIR}" ]]; then
        log "ERROR: private Go installation directory already exists: ${GO_INSTALL_DIR}"
        return 20
    fi
    archive="${PERF_WORK_DIR}/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
    copy_or_download_go_archive "${archive}" || return $?
    if ! mkdir -p "${GO_INSTALL_DIR}" || \
       ! tar -xzf "${archive}" -C "${GO_INSTALL_DIR}" --strip-components=1; then
        log "ERROR: failed to install official Go ${GO_VERSION}"
        return 30
    fi
    rm -f "${archive}"
    configure_go_environment
    verify_go_binary || return $?
    log "installed private official Go ${GO_VERSION} for ${GO_ARCH}"
}

build_sonic_go() {
    local actual_version loader_version

    initialize_runtime || return $?
    install_dependencies || return $?
    install_go_binary || return $?
    if [[ -e "${SOURCE_DIR}" ]]; then
        log "ERROR: source directory already exists: ${SOURCE_DIR}"
        return 20
    fi
    export GIT_TERMINAL_PROMPT=0
    log "cloning Sonic ${SOFTWARE_VERSION} from ${SONIC_GO_SOURCE_URL}"
    if ! git clone --branch "v${SOFTWARE_VERSION}" --depth 1 \
        "${SONIC_GO_SOURCE_URL}" "${SOURCE_DIR}"; then
        log "ERROR: failed to clone Sonic v${SOFTWARE_VERSION}"
        return 30
    fi
    actual_version="$(git -C "${SOURCE_DIR}" describe --tags --exact-match 2>/dev/null || true)"
    if [[ "${actual_version}" != "v${SOFTWARE_VERSION}" ]]; then
        log "ERROR: checked-out Sonic tag ${actual_version:-unknown} does not match v${SOFTWARE_VERSION}"
        return 40
    fi
    log "downloading Sonic's declared Go module dependencies"
    if ! (
        cd "${SOURCE_DIR}"
        "${GO_BIN}" mod download
        for benchmark_dir in encoder decoder ast; do
            cd "${SOURCE_DIR}/${benchmark_dir}"
            "${GO_BIN}" mod download
            "${GO_BIN}" test -run='^$'
        done
        loader_version="$(awk '$1 == "github.com/bytedance/sonic/loader" {print $2; exit}' "${SOURCE_DIR}/go.mod")"
        if [[ -z "${loader_version}" ]]; then
            log "ERROR: Sonic source does not declare a loader module version"
            exit 1
        fi
        cd "${SOURCE_DIR}/external_jsonlib_test"
        "${GO_BIN}" mod download github.com/bytedance/sonic/loader
        "${GO_BIN}" mod download "github.com/bytedance/sonic/loader@${loader_version}"
        cd "${SOURCE_DIR}/external_jsonlib_test/benchmark_test"
        "${GO_BIN}" test -run='^$'
    ); then
        log "ERROR: failed to prepare the official Sonic benchmark packages"
        return 40
    fi
    printf '%s\n' "${SOFTWARE_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "Sonic ${SOFTWARE_VERSION} official benchmark packages are ready"
}

start_sonic_go_runtime() {
    initialize_runtime || return $?
    configure_go_environment
    verify_go_binary || return $?
    if [[ ! -f "${SOURCE_DIR}/scripts/bench.sh" ]]; then
        log "ERROR: official Sonic benchmark script is unavailable"
        return 40
    fi
    log "Sonic official benchmark runtime is ready"
}

run_sonic_go_benchmarks() {
    initialize_runtime || return $?
    configure_go_environment
    verify_go_binary || return $?
    if [[ ! -f "${SOURCE_DIR}/scripts/bench.sh" ]]; then
        log "ERROR: official Sonic benchmark script is unavailable"
        return 40
    fi
    log "running Sonic's official scripts/bench.sh workload"
    if ! (
        cd "${SOURCE_DIR}"
        export SONIC_ENCODER_USE_VM=""
        export SONIC_USE_SVE_WRAPGOC=1
        bash -e scripts/bench.sh
    ) 2>&1 | tee "${RESULTS_DIR}/benchmark_sonic_go.txt"; then
        log "ERROR: official Sonic benchmark failed"
        return 50
    fi
    if [[ ! -s "${RESULTS_DIR}/benchmark_sonic_go.txt" ]]; then
        log "ERROR: official Sonic benchmark output is empty"
        return 50
    fi
    export SOFTWARE_VERSION EXPECTED_ARCH
    if ! python3 "${SCRIPT_DIR}/scripts/parse_benchmark.py" \
        "${RESULTS_DIR}/benchmark_sonic_go.txt" \
        "${RESULTS_DIR}/benchmark_sonic_go.json"; then
        log "ERROR: failed to normalize official Sonic benchmark results"
        return 50
    fi
    log "Sonic benchmark results written to benchmark_sonic_go.txt and benchmark_sonic_go.json"
}

stop_sonic_go_runtime() {
    initialize_runtime || return $?
    if [[ ! -d "${GO_RUNTIME_DIR}" ]]; then
        log "Sonic benchmark has no background service to stop"
        return
    fi
    if [[ "${GO_RUNTIME_DIR}" != "${GO_RUNTIME_ROOT}/${SOFTWARE_VERSION}/${EXPECTED_ARCH}/${PERF_RUN_ID}" ]]; then
        log "ERROR: refusing to clean unexpected Sonic Go runtime directory: ${GO_RUNTIME_DIR}"
        return 70
    fi
    if ! chmod -R u+w "${GO_RUNTIME_DIR}" || ! rm -rf -- "${GO_RUNTIME_DIR}"; then
        log "ERROR: failed to remove private Sonic Go runtime directory"
        return 70
    fi
    log "removed private Sonic Go runtime directory: ${GO_RUNTIME_DIR}"
}

standalone_runtime() {
    python3 "${SCRIPT_DIR}/scripts/standalone_runtime.py" "$@"
}

cleanup_standalone_workdir() {
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 1 ]]; then
        log "keeping standalone work directory: ${PERF_WORK_DIR}"
        return
    fi
    if [[ "${STANDALONE_OWNS_WORK_DIR}" -ne 1 ]]; then
        log "external work directory was not removed: ${PERF_WORK_DIR}"
        return
    fi
    if [[ "${PERF_WORK_DIR}" != /tmp/sonic-go-perf/local-* || \
          "${PERF_WORK_DIR}" == /tmp/sonic-go-perf ]]; then
        log "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    fi
    rm -rf -- "${PERF_WORK_DIR}"
}

run_sonic_go_standalone() {
    local stage_status=0 failed_stage="" cleanup_status="passed"

    initialize_runtime || return $?
    trap 'stop_sonic_go_runtime || :; cleanup_standalone_workdir || :' EXIT
    standalone_runtime system "${RESULTS_DIR}/system_info.json" || {
        stage_status=$?
        failed_stage="prepare"
    }
    if [[ "${stage_status}" -eq 0 ]]; then
        standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json" || {
            stage_status=$?
            failed_stage="prepare"
        }
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if build_sonic_go; then
            :
        else
            stage_status=$?
            failed_stage="build"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if start_sonic_go_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_sonic_go_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi
    if stop_sonic_go_runtime; then
        :
    else
        cleanup_status="failed"
        [[ "${stage_status}" -ne 0 ]] || stage_status=$?
        [[ -n "${failed_stage}" ]] || failed_stage="stop"
    fi
    STANDALONE_STOP_DONE=1
    if standalone_runtime runtime "${RESULTS_DIR}/runtime_after.json"; then
        :
    else
        [[ "${stage_status}" -ne 0 ]] || stage_status=$?
        [[ -n "${failed_stage}" ]] || failed_stage="finalize"
    fi
    standalone_runtime finalize \
        "${RESULTS_DIR}" "${SOFTWARE_VERSION}" "${EXPECTED_ARCH}" \
        "${stage_status}" "${failed_stage}" "${cleanup_status}" || return $?
    return "${stage_status}"
}

usage() {
    cat <<'USAGE'
Usage: sonic_go_test.sh [OPTIONS]

Build and run Sonic's official Go benchmark script as a standalone evaluation.

Options:
  --version VERSION       Sonic version (default: 1.15.2)
  --results-dir DIRECTORY Persistent result directory
  --keep-workdir          Keep the standalone temporary work directory
  --help                  Show this help text
USAGE
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version) SOFTWARE_VERSION="$2"; shift 2 ;;
            --results-dir) RESULTS_DIR="$2"; shift 2 ;;
            --keep-workdir) STANDALONE_KEEP_WORK_DIR=1; shift ;;
            --help) usage; return 0 ;;
            *) log "ERROR: unknown option: $1"; usage >&2; return 10 ;;
        esac
    done
    run_sonic_go_standalone
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
