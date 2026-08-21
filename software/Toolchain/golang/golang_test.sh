#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.27.0}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
GO_SOURCE_URL="${GO_SOURCE_URL:-https://github.com/golang/go.git}"
# Bootstrap release pinned so both architectures build the source tree with
# the same official binary toolchain; it is used only as GOROOT_BOOTSTRAP.
GO_BOOTSTRAP_VERSION="${GO_BOOTSTRAP_VERSION:-1.27.0}"
# Official benchmark selection: the go test benchmarks shipped in the Go
# standard library source tree (golang/go), covering parsing, encoding,
# hashing, compression, regular expression and sorting workloads.
GO_BENCH_PACKAGES="strconv encoding/json encoding/base64 crypto/sha256 compress/flate regexp sort math"
# Fixed benchmark knobs shared by both architectures: -cpu=1 keeps benchmark
# names free of a GOMAXPROCS suffix so metric names are identical on every
# runner, three samples per benchmark are aggregated to the median by the
# parser, and benchtime stays at the official default.
GO_BENCH_CPU="1"
GO_BENCH_COUNT="3"
GO_BENCHTIME="1s"

BOOTSTRAP_DIR=""
GO_TREE_DIR=""
BENCH_WORK_DIR=""
GO_BIN=""
GO_ARCH=""
GCC_VERSION_STRING=""
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

log_message() { printf '[golang] %s\n' "$*"; }

normalize_architecture() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

# Print the Go architecture name for EXPECTED_ARCH; errors go to stderr so the
# caller can capture the result with a command substitution.
go_architecture() {
    case "$(normalize_architecture "${EXPECTED_ARCH}")" in
        x86_64) printf 'amd64\n' ;;
        aarch64) printf 'arm64\n' ;;
        *)
            printf '[golang] ERROR: unsupported architecture for Go builds: %s\n' \
                "${EXPECTED_ARCH}" >&2
            return 20
            ;;
    esac
}

configure_runtime_paths() {
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    }
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/tmp/golang-perf/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
        TMPDIR="${PERF_WORK_DIR}/tmp"
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    BOOTSTRAP_DIR="${PERF_WORK_DIR}/go-bootstrap"
    GO_TREE_DIR="${PERF_WORK_DIR}/go-tree"
    BENCH_WORK_DIR="${PERF_WORK_DIR}/go-bench-work"
    GO_BIN="${GO_TREE_DIR}/bin/go"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
}

initialize_runtime() {
    configure_runtime_paths
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR:-${PERF_WORK_DIR}/tmp}"
}

require_commands() {
    local required missing=0
    for required in git curl gcc sha256sum awk tar python3 nproc; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            log_message "ERROR: required command is missing: ${required}"
            missing=1
        fi
    done
    [[ "${missing}" -eq 0 ]]
}

check_architecture() {
    local actual expected
    actual="$(normalize_architecture "$(uname -m)")"
    expected="$(normalize_architecture "${EXPECTED_ARCH}")"
    [[ "${actual}" == "${expected}" ]] || {
        log_message "ERROR: expected architecture ${expected}, runner is ${actual}"
        return 20
    }
}

# Export a hermetic environment for the built toolchain so no host Go
# configuration leaks into the smoke build or the benchmark runs.
apply_go_environment() {
    export GOROOT="${GO_TREE_DIR}"
    export GOCACHE="${PERF_WORK_DIR}/go-cache"
    export GOMODCACHE="${PERF_WORK_DIR}/go-mod-cache"
    export GOPATH="${PERF_WORK_DIR}/gopath"
    export GOTOOLCHAIN=local
    export GOPROXY=off
    export GOENV=off
    export GOWORK=off
    unset GOFLAGS GO111MODULE GOOS GOARCH GOARM GOAMD64
}

# Print the official SHA-256 checksum of the bootstrap tarball from go.dev/dl
# metadata; must stay free of stdout noise for command substitution.
fetch_bootstrap_sha256() {
    local go_arch="$1"
    local filename="go${GO_BOOTSTRAP_VERSION}.linux-${go_arch}.tar.gz"
    curl -fsSL "https://go.dev/dl/?mode=json&include=all" | \
        python3 "${SCRIPT_DIR}/scripts/bootstrap_sha256.py" "${filename}"
}

prepare_go_bootstrap() {
    local tarball expected_sha256 actual_sha256
    [[ ! -e "${BOOTSTRAP_DIR}" ]] || {
        log_message "ERROR: bootstrap directory already exists: ${BOOTSTRAP_DIR}"
        return 30
    }
    tarball="${PERF_WORK_DIR}/go${GO_BOOTSTRAP_VERSION}.linux-${GO_ARCH}.tar.gz"
    export GIT_TERMINAL_PROMPT=0
    log_message "downloading official Go bootstrap go${GO_BOOTSTRAP_VERSION} (linux/${GO_ARCH})"
    curl -fsSL --retry 3 --connect-timeout 30 \
        -o "${tarball}" \
        "https://go.dev/dl/go${GO_BOOTSTRAP_VERSION}.linux-${GO_ARCH}.tar.gz" || {
        log_message "ERROR: failed to download go${GO_BOOTSTRAP_VERSION}.linux-${GO_ARCH}.tar.gz"
        return 30
    }
    expected_sha256="$(fetch_bootstrap_sha256 "${GO_ARCH}")" || {
        log_message "ERROR: failed to fetch the official checksum of the bootstrap tarball"
        return 30
    }
    actual_sha256="$(sha256sum "${tarball}" | awk '{print $1}')"
    [[ "${actual_sha256}" == "${expected_sha256}" ]] || {
        log_message "ERROR: bootstrap tarball checksum mismatch"
        log_message "expected: ${expected_sha256}"
        log_message "actual:   ${actual_sha256}"
        return 30
    }
    tar -xzf "${tarball}" -C "${PERF_WORK_DIR}" || {
        log_message "ERROR: failed to extract the bootstrap tarball"
        return 30
    }
    [[ -d "${PERF_WORK_DIR}/go" ]] || {
        log_message "ERROR: bootstrap tarball did not create a go directory"
        return 30
    }
    mv "${PERF_WORK_DIR}/go" "${BOOTSTRAP_DIR}" || return 30
    rm -f "${tarball}"
    [[ -x "${BOOTSTRAP_DIR}/bin/go" ]] || {
        log_message "ERROR: bootstrap toolchain is incomplete: ${BOOTSTRAP_DIR}/bin/go"
        return 30
    }
    "${BOOTSTRAP_DIR}/bin/go" version || {
        log_message "ERROR: bootstrap toolchain is not runnable"
        return 30
    }
}

prepare_go_source() {
    [[ ! -e "${GO_TREE_DIR}" ]] || {
        log_message "ERROR: source directory already exists: ${GO_TREE_DIR}"
        return 30
    }
    export GIT_TERMINAL_PROMPT=0
    log_message "cloning Go source (tag go${SOFTWARE_VERSION}) from ${GO_SOURCE_URL}"
    git clone --branch "go${SOFTWARE_VERSION}" --depth 1 \
        "${GO_SOURCE_URL}" "${GO_TREE_DIR}" || {
        log_message "ERROR: failed to clone Go source tag go${SOFTWARE_VERSION}"
        return 30
    }
}

verify_go_build() {
    local version_output version_field actual_version actual_goarch
    [[ -x "${GO_BIN}" ]] || {
        log_message "ERROR: built Go toolchain is missing: ${GO_BIN}"
        return 40
    }
    version_output="$("${GO_BIN}" version)" || {
        log_message "ERROR: built Go toolchain cannot report its version"
        return 40
    }
    version_field="$(printf '%s\n' "${version_output}" | awk '{print $3}')"
    actual_version="${version_field#go}"
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: built Go reports ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 40
    }
    actual_goarch="$("${GO_BIN}" env GOARCH)" || return 40
    [[ "${actual_goarch}" == "${GO_ARCH}" ]] || {
        log_message "ERROR: built Go targets ${actual_goarch}, expected ${GO_ARCH}"
        return 40
    }
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40
}

build_golang() {
    initialize_runtime || return $?
    check_architecture || return $?
    require_commands || return $?
    [[ ! -e "${BOOTSTRAP_DIR}" && ! -e "${GO_TREE_DIR}" && ! -e "${BENCH_WORK_DIR}" ]] || {
        log_message "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    }
    GO_ARCH="$(go_architecture)" || return $?
    prepare_go_bootstrap || return $?
    prepare_go_source || return $?
    GCC_VERSION_STRING="$(gcc --version | head -n 1)"

    log_message "building Go ${SOFTWARE_VERSION} from source with bootstrap go${GO_BOOTSTRAP_VERSION}"
    (
        cd "${GO_TREE_DIR}/src"
        unset GOROOT GOFLAGS GO111MODULE GOOS GOARCH
        GOROOT_BOOTSTRAP="${BOOTSTRAP_DIR}" ./make.bash
    ) || {
        log_message "ERROR: Go make.bash build failed"
        return 40
    }
    apply_go_environment
    verify_go_build || return $?
    log_message "Go ${SOFTWARE_VERSION} toolchain is ready at ${GO_BIN}"
}

start_golang_runtime() {
    initialize_runtime || return $?
    [[ -x "${GO_BIN}" ]] || {
        log_message "ERROR: built Go toolchain is unavailable: ${GO_BIN}"
        return 40
    }
    GO_ARCH="$(go_architecture)" || return $?
    apply_go_environment
    "${GO_BIN}" version
    "${GO_BIN}" env GOOS GOARCH GOROOT
    verify_go_build || return $?
    mkdir -p "${BENCH_WORK_DIR}"
    cat > "${BENCH_WORK_DIR}/smoke.go" <<'EOF'
package main

import "fmt"

func main() {
    fmt.Println("go toolchain smoke test ok")
}
EOF
    (
        cd "${BENCH_WORK_DIR}"
        "${GO_BIN}" build -o smoke.bin smoke.go
        ./smoke.bin
    ) || {
        log_message "ERROR: built Go toolchain failed the smoke build"
        return 40
    }
    log_message "Go official benchmark runtime is ready"
}

run_golang_benchmarks() {
    initialize_runtime || return $?
    [[ -x "${GO_BIN}" ]] || {
        log_message "ERROR: built Go toolchain is unavailable: ${GO_BIN}"
        return 40
    }
    GO_ARCH="$(go_architecture)" || return $?
    apply_go_environment
    verify_go_build || return $?
    mkdir -p "${RESULTS_DIR}"
    local bench_packages=()
    read -r -a bench_packages <<< "${GO_BENCH_PACKAGES}"
    [[ "${#bench_packages[@]}" -gt 0 ]] || {
        log_message "ERROR: benchmark package selection is empty"
        return 50
    }
    log_message "running official go test benchmarks in: ${GO_BENCH_PACKAGES}"
    log_message "flags: -cpu=${GO_BENCH_CPU} -count=${GO_BENCH_COUNT} -benchtime=${GO_BENCHTIME}"
    (
        cd "${GO_TREE_DIR}/src"
        "${GO_BIN}" test \
            -run='^$' -bench='.' \
            -cpu="${GO_BENCH_CPU}" \
            -count="${GO_BENCH_COUNT}" \
            -benchtime="${GO_BENCHTIME}" \
            "${bench_packages[@]}" \
            2>&1 | tee "${RESULTS_DIR}/benchmark_gotest.txt"
    ) || {
        log_message "ERROR: official go test benchmark run failed"
        return 50
    }
    [[ -s "${RESULTS_DIR}/benchmark_gotest.txt" ]] || {
        log_message "ERROR: official go test output is empty: ${RESULTS_DIR}/benchmark_gotest.txt"
        return 50
    }
    export SOFTWARE_VERSION EXPECTED_ARCH GO_BENCH_PACKAGES GO_BENCH_COUNT \
        GO_BENCH_CPU GO_BENCHTIME GO_BOOTSTRAP_VERSION
    python3 "${SCRIPT_DIR}/scripts/parse_benchmark.py" \
        "${RESULTS_DIR}/benchmark_gotest.txt" \
        "${RESULTS_DIR}/benchmark_golang.json" || {
        log_message "ERROR: failed to normalize official go test results"
        return 50
    }
    log_message "go test results written to benchmark_gotest.txt and benchmark_golang.json"
}

stop_golang_runtime() {
    log_message "golang benchmark has no background service to stop"
}

standalone_runtime() {
    python3 "${SCRIPT_DIR}/scripts/standalone_runtime.py" "$@"
}

cleanup_standalone_workdir() {
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 1 ]]; then
        log_message "keeping standalone work directory: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${STANDALONE_OWNS_WORK_DIR}" -ne 1 ]]; then
        log_message "external work directory was not removed: ${PERF_WORK_DIR}"
        return 0
    fi
    [[ "${PERF_WORK_DIR}" == /tmp/golang-perf/local-* && \
       "${PERF_WORK_DIR}" != "/tmp/golang-perf" ]] || {
        log_message "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    }
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        rm -rf -- "${PERF_WORK_DIR}" || return 70
    fi
    log_message "cleaned standalone work directory: ${PERF_WORK_DIR}"
}

emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then
        stop_golang_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_golang_standalone() {
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
        if build_golang; then
            if standalone_runtime build-info \
                "${RESULTS_DIR}/build_info.json" \
                "${SOFTWARE_VERSION}" \
                "${PERF_ACTUAL_VERSION_FILE}" \
                "$(normalize_architecture "${EXPECTED_ARCH}")" \
                "${PERF_RUN_ID}" \
                "${GCC_VERSION_STRING}" \
                --bootstrap-version="${GO_BOOTSTRAP_VERSION}" \
                --source-url="${GO_SOURCE_URL}"; then
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
        "$(normalize_architecture "${EXPECTED_ARCH}")" \
        "${PERF_RUN_ID}" \
        "${command_status}" \
        "${cleanup_status}" \
        "${failed_stage}"; then
        finalize_status=0
    else
        finalize_status=$?
    fi
    trap - EXIT
    [[ "${stage_status}" -eq 0 ]] || return "${stage_status}"
    [[ "${cleanup_status}" == "passed" ]] || return 70
    return "${finalize_status}"
}

usage() {
    cat <<USAGE
Usage: $(basename "$0") [OPTIONS]

Build Go from the official source repository and run the official go test
standard-library benchmarks as a standalone performance evaluation. Results
default to results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       Go version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR,
  GO_SOURCE_URL, GO_BOOTSTRAP_VERSION
USAGE
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --version requires a value"; return 10; }
                SOFTWARE_VERSION="$2"
                shift 2
                ;;
            --results-dir)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --results-dir requires a value"; return 10; }
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
                log_message "ERROR: unsupported option: $1"
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
    run_golang_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log_message "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
