#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.26.9}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

GO_RELEASE_URL="${GO_RELEASE_URL:-https://go.dev/dl}"
GO_OFFLINE_DIR="${GO_OFFLINE_DIR:-/home/runner/software/golang}"
BENT_MODULE_CACHE_DIR="${BENT_MODULE_CACHE_DIR:-${GO_OFFLINE_DIR}/bent-modules}"
GO_RUNTIME_ROOT="${GO_RUNTIME_ROOT:-}"
BENT_MODULE_VERSION="v0.0.0-20261009192853-4a545adeb0d5"

GO_INSTALL_DIR=""
GO_BIN=""
GO_ARCH=""
GO_RUNTIME_DIR=""
GCC_VERSION_STRING=""
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

log() {
    printf '[golang] %s\n' "$*"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/golang/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    if [[ -z "${GO_RUNTIME_ROOT}" ]]; then
        GO_RUNTIME_ROOT="${PERF_WORK_DIR}/runtime"
    fi

    GO_RUNTIME_DIR="${GO_RUNTIME_ROOT}"
    if ! mkdir -p "${GO_RUNTIME_DIR}/tmp"; then
        log "ERROR: cannot create the Go runtime directory: ${GO_RUNTIME_DIR}"
        return 30
    fi

    export TMPDIR="${GO_RUNTIME_DIR}/tmp"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
    GO_INSTALL_DIR="${PERF_WORK_DIR}/go-install"
    GO_BIN="${GO_INSTALL_DIR}/bin/go"
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

run_as_root() {
    if [[ "$1" == dnf && -n "${PERF_PROXY:-}" ]]; then
        set -- "$1" "--setopt=proxy=${PERF_PROXY}" "${@:2}"
    fi
    if [[ "${EUID}" -eq 0 ]]; then
        "$@"
        return
    fi
    if ! command -v sudo >/dev/null 2>&1; then
        log "ERROR: root privileges are required to install missing dependencies"
        return 30
    fi
    sudo -n "$@"
}

install_dependencies() {
    local missing=0 command_name
    for command_name in git curl gcc tar gzip sha256sum awk python3 nproc; do
        command -v "${command_name}" >/dev/null 2>&1 || missing=1
    done
    if [[ "${missing}" -eq 0 ]]; then
        return
    fi

    log "installing missing Go runtime and official benchmark dependencies"
    if ! command -v dnf >/dev/null 2>&1; then
        log "ERROR: dnf is required to install Go dependencies"
        return 30
    fi
    run_as_root dnf install -y git curl gcc tar gzip coreutils gawk python3 || return 30

    for command_name in git curl gcc tar gzip sha256sum awk python3 nproc; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log "ERROR: required command is still missing after installation: ${command_name}"
            return 30
        fi
    done
}

configure_go_environment() {
    export GOROOT="${GO_INSTALL_DIR}"
    # Bent invokes the Go command by its basename while it prepares each
    # official benchmark module.  Make this task's Go installation available
    # to those child processes instead of relying on a runner-wide Go command.
    export PATH="${GO_INSTALL_DIR}/bin:${PATH}"
    export GOCACHE="${GO_RUNTIME_DIR}/go-cache"
    export GOMODCACHE="${GO_RUNTIME_DIR}/go-mod-cache"
    export GOPATH="${GO_RUNTIME_DIR}/gopath"
    export GOTOOLCHAIN=local
    export GOENV=off
    export GOWORK=off
    if [[ "${PERF_DIRECT_NETWORK:-}" == "true" ]]; then
        export GOPROXY=direct
    else
        export GOPROXY="https://repo.huaweicloud.com/repository/goproxy/|https://goproxy.cn"
    fi
    export GOSUMDB="${GOSUMDB:-sum.golang.org}"
    unset GOFLAGS GO111MODULE GOOS GOARCH GOARM GOARM64 GOAMD64 GOEXPERIMENT
}

copy_bent_module_cache() {
    local source="${BENT_MODULE_CACHE_DIR}/cache/download"
    local destination="${GO_RUNTIME_DIR}/go-mod-cache/cache/download"

    if [[ ! -e "${source}" ]]; then
        log "local Bent module cache is unavailable; missing modules will use GOPROXY"
        return 0
    fi
    if [[ ! -d "${source}" ]]; then
        log "ERROR: local Bent module cache is not a directory: ${source}"
        return 50
    fi
    mkdir -p "${destination}" || return 50
    if ! cp -a "${source}/." "${destination}/"; then
        log "ERROR: failed to copy local Bent module cache from ${source}"
        return 50
    fi
    log "copied local Bent module cache from ${source}; missing modules will use GOPROXY"
}

copy_or_download_go_archive() {
    local filename="$1" archive="$2" expected actual
    local offline_archive="${GO_OFFLINE_DIR}/${filename}"

    case "${SOFTWARE_VERSION}:${GO_ARCH}" in
        1.26.9:amd64)
            expected="42d158b4d8f7b61ac0a830567c940a86098fb7aac52e467a5ebec03ef5cc2f8d"
            ;;
        1.26.9:arm64)
            expected="4a97373d49fcacdcf3694fea368a500b00ee3e963974f3e7514132717632f052"
            ;;
        *)
            log "ERROR: no verified Go binary release is declared for ${SOFTWARE_VERSION} on ${GO_ARCH}"
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

verify_golang_binary() {
    local actual_version actual_arch
    if [[ ! -x "${GO_BIN}" ]]; then
        log "ERROR: installed Go binary is missing: ${GO_BIN}"
        return 40
    fi
    actual_version="$("${GO_BIN}" version | awk '{print $3}' | sed 's/^go//')" || return 40
    actual_arch="$("${GO_BIN}" env GOARCH)" || return 40
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" || "${actual_arch}" != "${GO_ARCH}" ]]; then
        log "ERROR: installed Go is ${actual_version}/${actual_arch}, expected ${SOFTWARE_VERSION}/${GO_ARCH}"
        return 40
    fi
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
}

install_golang_binary() {
    local archive

    initialize_runtime || return $?
    install_dependencies || return $?
    if [[ -e "${GO_INSTALL_DIR}" ]]; then
        log "ERROR: installation directories are not clean under ${PERF_WORK_DIR}"
        return 20
    fi
    archive="${PERF_WORK_DIR}/go${SOFTWARE_VERSION}.linux-${GO_ARCH}.tar.gz"
    copy_or_download_go_archive "$(basename "${archive}")" "${archive}" || return $?
    if ! mkdir -p "${GO_INSTALL_DIR}" || \
       ! tar -xzf "${archive}" -C "${GO_INSTALL_DIR}" --strip-components=1; then
        log "ERROR: failed to install official Go binary ${SOFTWARE_VERSION}"
        return 30
    fi
    rm -f "${archive}"
    GCC_VERSION_STRING="$(gcc --version | head -n 1)"
    log "installed official precompiled Go ${SOFTWARE_VERSION} for ${GO_ARCH}"
    configure_go_environment
    verify_golang_binary || return $?
}

start_golang_runtime() {
    initialize_runtime || return $?
    configure_go_environment
    verify_golang_binary || return $?
    mkdir -p "${PERF_WORK_DIR}/smoke"
    printf 'package main\nfunc main() {}\n' > "${PERF_WORK_DIR}/smoke/main.go"
    if ! (
        cd "${PERF_WORK_DIR}/smoke"
        "${GO_BIN}" build -o smoke main.go
        ./smoke
    ); then
        log "ERROR: installed Go binary failed its smoke build"
        return 40
    fi
}

run_official_bent_benchmarks() {
    local bent_dir bent_binary processor_count
    local -a stdout_files

    bent_dir="${GO_RUNTIME_DIR}/bent"
    rm -rf -- "${bent_dir}"
    mkdir -p "${bent_dir}" || return 50
    copy_bent_module_cache || return 50
    log "installing official Bent with go install"
    "${GO_BIN}" install "golang.org/x/benchmarks/cmd/bent@${BENT_MODULE_VERSION}" || return 50
    bent_binary="${GOPATH}/bin/bent"
    if [[ ! -x "${bent_binary}" ]]; then
        log "ERROR: go install did not create Bent: ${bent_binary}"
        return 50
    fi
    # Bent prepares its own scripts and Dockerfile with -I.  Replace its
    # default workload with the selected, version-pinned guide workload.
    if ! (
        cd "${bent_dir}"
        "${bent_binary}" -I
    ); then
        log "ERROR: Bent initialization failed"
        return 50
    fi
    if ! cp "${SCRIPT_DIR}/scripts/suites.toml" "${bent_dir}/suites.toml" || \
       ! cp "${SCRIPT_DIR}/scripts/benchmarks.toml" "${bent_dir}/benchmarks.toml"; then
        log "ERROR: cannot prepare the selected Bent benchmark configuration"
        return 50
    fi
    processor_count="$(nproc)"
    if [[ ! "${processor_count}" =~ ^[1-9][0-9]*$ ]]; then
        log "ERROR: nproc returned an invalid processor count: ${processor_count}"
        return 50
    fi
    if ! printf '[[Configurations]]\n  Name = "Baseline"\n  RunEnv = ["GOGC=100", "GOMAXPROCS=%s"]\n  Root = "%s"\n' \
        "${processor_count}" "${GO_INSTALL_DIR}" > "${bent_dir}/configurations.toml"; then
        log "ERROR: cannot write Bent Baseline configuration"
        return 50
    fi
    if ! cp "${bent_dir}/suites.toml" "${RESULTS_DIR}/suites.toml" || \
       ! cp "${bent_dir}/benchmarks.toml" "${RESULTS_DIR}/benchmarks.toml" || \
       ! cp "${bent_dir}/configurations.toml" "${RESULTS_DIR}/configurations.toml"; then
        log "ERROR: cannot preserve the selected Bent configurations"
        return 50
    fi
    if ! python3 "${SCRIPT_DIR}/scripts/prefetch_bent_modules.py" \
        --go "${GO_BIN}" --suites "${bent_dir}/suites.toml" --work-dir "${bent_dir}"; then
        log "ERROR: failed to prefetch Bent modules one at a time"
        return 50
    fi
    log "running selected upstream Bent benchmarks: bent -B benchmarks.toml -C configurations.toml -N 1"
    if ! (
        cd "${bent_dir}"
        "${bent_binary}" -B benchmarks.toml -C configurations.toml -N 1 -L .bent-stamps.log
    ); then
        return 50
    fi
    shopt -s nullglob
    stdout_files=("${bent_dir}"/bench/*.Baseline.stdout)
    shopt -u nullglob
    if [[ "${#stdout_files[@]}" -ne 1 || ! -s "${stdout_files[0]:-}" ]]; then
        log "ERROR: expected exactly one nonempty Baseline Bent stdout file, found ${#stdout_files[@]}"
        return 50
    fi
    if ! cp "${stdout_files[0]}" "${RESULTS_DIR}/benchmark_go_bench.txt"; then
        log "ERROR: cannot preserve Bent's original benchmark stdout"
        return 50
    fi
}

run_golang_benchmarks() {
    initialize_runtime || return $?
    configure_go_environment
    verify_golang_binary || return $?
    log "running 20 selected Bent benchmarks with upstream Go ${SOFTWARE_VERSION}"
    if ! (
        run_official_bent_benchmarks
    ) 2>&1 | tee "${RESULTS_DIR}/bent-run.log"; then
        log "ERROR: official Bent benchmark failed"
        return 50
    fi
    if [[ ! -s "${RESULTS_DIR}/benchmark_go_bench.txt" ]]; then
        log "ERROR: official Go benchmark output is empty"
        return 50
    fi
    python3 "${SCRIPT_DIR}/scripts/parse_benchmark.py" \
        "${RESULTS_DIR}/benchmark_go_bench.txt" \
        "${RESULTS_DIR}/benchmark_golang.json" || return 50
}

stop_golang_runtime() {
    initialize_runtime || return $?
    configure_go_environment
    if [[ ! -e "${GO_RUNTIME_DIR}" ]]; then
        log "Go benchmark suite has no background service to stop"
        return
    fi
    if [[ "${GO_RUNTIME_DIR}" != "${GO_RUNTIME_ROOT}" ]]; then
        log "ERROR: refusing to clean unexpected Go runtime directory: ${GO_RUNTIME_DIR}"
        return 50
    fi
    if ! chmod -R u+w "${GO_RUNTIME_DIR}"; then
        log "ERROR: failed to make the private Go runtime directory writable for cleanup"
        return 50
    fi
    if ! rm -rf -- "${GO_RUNTIME_DIR}"; then
        log "ERROR: failed to remove the private Go runtime directory"
        return 50
    fi
    log "removed private Go runtime directory: ${GO_RUNTIME_DIR}"
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
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/golang/local-* || "${PERF_WORK_DIR}" == /home/runner/boostkit-perf/golang ]]; then
        log "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    fi
    rm -rf -- "${PERF_WORK_DIR}"
}

run_golang_standalone() {
    local stage_status=0 failed_stage="" cleanup_status="passed"
    local command_status="passed" finalize_status=0

    initialize_runtime || return $?
    trap 'stop_golang_runtime || :; cleanup_standalone_workdir || :' EXIT

    if standalone_runtime system "${RESULTS_DIR}/system_info.json"; then
        :
    else
        stage_status=$?
        failed_stage="prepare"
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json"; then
            :
        else
            stage_status=$?
            failed_stage="prepare"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if install_golang_binary; then
            :
        else
            stage_status=$?
            failed_stage="build"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if standalone_runtime build-info "${RESULTS_DIR}/build_info.json" \
            "${SOFTWARE_VERSION}" "${PERF_ACTUAL_VERSION_FILE}" "${EXPECTED_ARCH}" \
            "${PERF_RUN_ID}" "${GCC_VERSION_STRING}" \
            --release-url="${GO_RELEASE_URL}"; then
            :
        else
            stage_status=$?
            failed_stage="build"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if start_golang_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_golang_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_golang_runtime; then
        cleanup_status="failed"
    fi
    if ! standalone_runtime runtime "${RESULTS_DIR}/runtime_after.json"; then
        cleanup_status="failed"
    fi
    if ! cleanup_standalone_workdir; then
        cleanup_status="failed"
    fi
    trap - EXIT

    if [[ "${stage_status}" -ne 0 ]]; then
        command_status="failed"
    fi
    if standalone_runtime finalize "${RESULTS_DIR}" "${SOFTWARE_VERSION}" "${EXPECTED_ARCH}" \
        "${PERF_RUN_ID}" "${command_status}" "${cleanup_status}" "${failed_stage}"; then
        finalize_status=0
    else
        finalize_status=$?
    fi

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

Install the official precompiled Go release and run the selected
golang.org/x/benchmarks/cmd/bent suite.

Options:
  --version VERSION       Go version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Offline archives take priority from ${GO_OFFLINE_DIR}:
  go<VERSION>.linux-<amd64|arm64>.tar.gz
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
            --keep-workdir) STANDALONE_KEEP_WORK_DIR=1; shift ;;
            -h|--help) usage; return 0 ;;
            *) log "ERROR: unsupported option: $1"; return 10 ;;
        esac
    done
    initialize_runtime || return $?
    : > "${RESULTS_DIR}/results.log"
    set +e
    run_golang_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    local result="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${result}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
