#!/usr/bin/env bash
#
# Shared configuration and helpers for the TypeScript case.
#
# The case measures the cost of real TypeScript work (full-project type
# checking, emit, incremental re-check and a project-references build) with the
# pinned native TypeScript 7 compiler.  Everything that is compared across
# architectures is fixed here: the Node.js runtime, the TypeScript release, the
# native backend package, the generated projects, the compiler flags and the
# repetition count.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="typescript"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-7.0.2}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# typescript 7.0.2 declares "engines": {"node": ">=16.20.0"} and ships a native
# compiler binary in a per-platform package.  The case pins the newest Node.js
# 22.x LTS used by the toolchain cases so both architectures run byte-identical
# JavaScript glue code on top of their own native binary.
NODE_VERSION="v22.23.4"
NODE_SEMVER="22.23.4"
TS_NODE_ENGINES=">=16.20.0"
NODE_X64_SHA256="1805bcd35e6815559bd2eb97db438d3fdb0eb3a5e6a977b7c1badca76337e9ce"
NODE_ARM64_SHA256="6287aa46b6c375d816e63ae66d024fbbfd70404825aabdfdf898a970871d2f4b"
NODE_DIST_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/nodejs-release"
NODE_DIST_OFFICIAL="https://nodejs.org/dist"

# TypeScript itself is installed from the tarballs published on the npm
# registry: the small JavaScript package plus exactly one native backend package
# chosen by the machine architecture.  The SHA-256 values below are the official
# artifact hashes and the SHA-512 values are the registry integrity values, so a
# mirror can be used without trusting it.  The native backend package carries
# the compiler binary and the standard library declaration files.
TS_REGISTRY="${PERF_TS_REGISTRY:-https://mirrors.huaweicloud.com/repository/npm}"
TS_OFFLINE_DIR="${TS_OFFLINE_DIR:-/home/runner/software/typescript}"
TS_TARBALL_NAME="typescript-${SOFTWARE_VERSION}.tgz"
TS_TARBALL_SHA256="da2513f4b95176d6dde8b51aab7afe8a927656c9d277369793f77f7e59371c08"
TS_TARBALL_SHA512_B64="8FYau96o3NKOhbjKi/qNvG/W5jhzxkbdm5sj9AbZ/5T5sWqn3hJgLfGx27sRKZWTvyzCP8dLRBTf5tBTSRVUNA=="
TS_PLATFORM_SHA256_X64="7ecad6f67377e831856367ab062ef394f21506a611405bf8ac0ff039348637d3"
TS_PLATFORM_SHA256_ARM64="c83d931ac9dd7549cde6e71246aa9d6a9812843023df3e277fe3b5dcf41dd0ea"
TS_PLATFORM_SHA512_X64="EYdf2cNg7rgCWJnxCdJ+F3V39O8ihb37eHAu1LK8oAFizgTQbPOK7zHHXbPt8rX24COqODXeI3sIf0fCXG7H/A=="
TS_PLATFORM_SHA512_ARM64="Qh4eU4/y3yDjnfjjyPYihMj5/ODIlmt+Bzu17OI+fiSRDW57QmU5SiN63exPRNJPKUzcc1INa1NXdrJ+MqHjUQ=="
TS_REPS="${PERF_REPS:-5}"

# Scale matrix of the type-check scenarios plus the specialised scenarios.  The
# project trees are generated deterministically by
# scripts/fixtures/generate_projects.py, and "upstream" is a real open-source
# project committed under fixtures/upstream.
TS_SCENARIOS=(
    check_small
    check_medium
    check_large
    check_upstream
    emit_medium
    incremental_warm_medium
    incremental_change_medium
    references_build
)
TS_PROJECTS=(small medium large emit incremental references)
TS_TIER_MODULES_SMALL=100
TS_TIER_MODULES_MEDIUM=1000
TS_TIER_MODULES_LARGE=5000
TS_REFERENCE_PACKAGES=2
TS_UPSTREAM_NAME="zod"
TS_UPSTREAM_VERSION="3.25.76"
TS_UPSTREAM_URL="https://mirrors.huaweicloud.com/repository/npm/zod/-/zod-3.25.76.tgz"
TS_UPSTREAM_TARBALL_SHA256="782872c88bcf5718946c80a59b1628bd30c5c67748e5f303600d8e0aac6f8e25"
TS_UPSTREAM_NODE_TYPES_VERSION="24.10.1"
# The incremental scenarios mutate exactly this module (index 500 of the
# 1000-module project) and then look for the compiler's re-check of the change.
TS_INCREMENTAL_MUTATION_FILE="src/mod0500.ts"
TS_INCREMENTAL_MUTATION_FROM='name: "entity-500"'
TS_INCREMENTAL_MUTATION_TO='name: "entity-500-mutated"'

NODE_HOME=""
TS_HOME=""
NODE_BIN=""
TSC_JS=""
TS_PLATFORM_PACKAGE=""
TS_PLATFORM_DIR=""
TSC_BIN_DIR=""
TSC_WRAPPER=""
TS_PRIVATE_HOME=""
PROJECTS_DIR=""
PROJECTS_SUMMARY=""
UPSTREAM_DIR=""
FIXTURE_METADATA=""
BUILD_LOGS_DIR=""
RUNS_DIR=""
TARBALL_NAME=""
TARBALL_SHA256=""
TARBALL_URLS=()
PLATFORM_NAME=""
PLATFORM_SHA256=""
PLATFORM_SHA512=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[typescript] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
}

normalize_architecture() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

validate_reps() {
    [[ "${TS_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${TS_REPS}"
        return 10
    }
    if (( TS_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${TS_REPS} is a local link-validation value; formal evidence requires >= 5"
    fi
}

select_node_artifact() {
    case "${EXPECTED_ARCH}" in
        x86_64)
            TARBALL_NAME="node-${NODE_VERSION}-linux-x64.tar.xz"
            TARBALL_SHA256="${NODE_X64_SHA256}"
            ;;
        aarch64)
            TARBALL_NAME="node-${NODE_VERSION}-linux-arm64.tar.xz"
            TARBALL_SHA256="${NODE_ARM64_SHA256}"
            ;;
        *)
            log_message "ERROR: no Node.js artifact for architecture ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    TARBALL_URLS=(
        "${NODE_DIST_MIRROR}/${NODE_VERSION}/${TARBALL_NAME}"
        "${NODE_DIST_OFFICIAL}/${NODE_VERSION}/${TARBALL_NAME}"
    )
}

select_platform_artifact() {
    case "${EXPECTED_ARCH}" in
        x86_64)
            PLATFORM_NAME="@typescript/typescript-linux-x64"
            PLATFORM_SHA256="${TS_PLATFORM_SHA256_X64}"
            PLATFORM_SHA512="${TS_PLATFORM_SHA512_X64}"
            ;;
        aarch64)
            PLATFORM_NAME="@typescript/typescript-linux-arm64"
            PLATFORM_SHA256="${TS_PLATFORM_SHA256_ARM64}"
            PLATFORM_SHA512="${TS_PLATFORM_SHA512_ARM64}"
            ;;
        *)
            log_message "ERROR: no TypeScript native backend for architecture ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    TS_PLATFORM_PACKAGE="${PLATFORM_NAME##*/}"
    PLATFORM_TARBALL_NAME="${TS_PLATFORM_PACKAGE}-${SOFTWARE_VERSION}.tgz"
    PLATFORM_TARBALL_URL="${TS_REGISTRY}/@typescript%2f${TS_PLATFORM_PACKAGE}/-/${PLATFORM_TARBALL_NAME}"
}

scenario_project() {
    case "$1" in
        check_small) printf 'small\n' ;;
        check_medium) printf 'medium\n' ;;
        check_large) printf 'large\n' ;;
        check_upstream) printf 'upstream\n' ;;
        emit_medium) printf 'emit\n' ;;
        incremental_warm_medium|incremental_change_medium) printf 'incremental\n' ;;
        references_build) printf 'references\n' ;;
        *) log_message "ERROR: unknown scenario: $1"; return 10 ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    validate_reps || return $?
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64) EXPECTED_ARCH="x86_64" ;;
        aarch64|arm64) EXPECTED_ARCH="aarch64" ;;
        *)
            log_message "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    local runner_architecture
    runner_architecture="$(normalize_architecture "$(uname -m)")"
    case "${runner_architecture}" in
        x86_64|aarch64) ;;
        *)
            log_message "ERROR: unsupported runner architecture: $(uname -m)"
            return 20
            ;;
    esac
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log_message "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/typescript/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    select_node_artifact || return $?
    select_platform_artifact || return $?
    NODE_HOME="${PERF_WORK_DIR}/node-install"
    NODE_BIN="${NODE_HOME}/bin/node"
    TS_HOME="${PERF_WORK_DIR}/typescript-install"
    TSC_JS="${TS_HOME}/node_modules/typescript/bin/tsc"
    TS_PLATFORM_DIR="${TS_HOME}/node_modules/@typescript/${TS_PLATFORM_PACKAGE}"
    TSC_BIN_DIR="${PERF_WORK_DIR}/bin"
    TSC_WRAPPER="${TSC_BIN_DIR}/tsc"
    TS_PRIVATE_HOME="${PERF_WORK_DIR}/home"
    PROJECTS_DIR="${PERF_WORK_DIR}/projects"
    PROJECTS_SUMMARY="${PERF_WORK_DIR}/projects-generated.json"
    UPSTREAM_DIR="${PROJECTS_DIR}/upstream"
    FIXTURE_METADATA="${PERF_WORK_DIR}/fixtures-metadata.json"
    BUILD_LOGS_DIR="${RESULTS_DIR}/build-logs"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR TS_REPS TS_REGISTRY NODE_VERSION NODE_SEMVER
    export NODE_HOME NODE_BIN TS_HOME TSC_JS TS_PLATFORM_DIR TSC_BIN_DIR TSC_WRAPPER
    export TS_PRIVATE_HOME PROJECTS_DIR PROJECTS_SUMMARY UPSTREAM_DIR
    export FIXTURE_METADATA BUILD_LOGS_DIR RUNS_DIR
    # Consumed by the metadata writer and by the standalone build-info command.
    export TS_NODE_ENGINES TARBALL_NAME TARBALL_SHA256 TS_TARBALL_NAME
    export TS_TARBALL_SHA256 TS_TARBALL_SHA512_B64 PLATFORM_NAME PLATFORM_SHA256
    export PLATFORM_SHA512 PLATFORM_TARBALL_NAME PLATFORM_TARBALL_URL
    export TS_UPSTREAM_NAME TS_UPSTREAM_VERSION TS_UPSTREAM_URL TS_UPSTREAM_TARBALL_SHA256
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${TS_PRIVATE_HOME}"
}

# Every measured command runs through this wrapper so that the environment of a
# measurement is identical for build-time validation, for the matrix and for a
# standalone run: a private HOME, UTC, the C locale and no way to reach the
# network (an accidental HTTP request would fail against the closed proxy
# below).  TypeScript itself never needs the network.
write_tsc_wrapper() {
    mkdir -p "${TSC_BIN_DIR}" "${TS_PRIVATE_HOME}"
    cat > "${TSC_WRAPPER}" <<WRAPPER
#!/usr/bin/env bash
set -euo pipefail
export HOME='${TS_PRIVATE_HOME}'
export TZ='UTC'
export LC_ALL='C'
export LANG='C'
export NO_COLOR='1'
export FORCE_COLOR='0'
export HTTP_PROXY='http://127.0.0.1:9'
export HTTPS_PROXY='http://127.0.0.1:9'
export ALL_PROXY='http://127.0.0.1:9'
export http_proxy='http://127.0.0.1:9'
export https_proxy='http://127.0.0.1:9'
export all_proxy='http://127.0.0.1:9'
unset NODE_OPTIONS NODE_PATH
exec '${NODE_BIN}' '${TSC_JS}' "\$@"
WRAPPER
    chmod 755 "${TSC_WRAPPER}"
}

# --- shared project helpers (used by the build stage and by measurement) ------

# A measured run is only valid if the compiler actually emitted the artifacts
# the scenario promises: an incremental run must have written its build info, an
# emit run must have produced JavaScript and declaration files, and the
# project-references build must have built both packages.
count_files() {
    local directory="$1" pattern="$2"
    if [[ ! -d "${directory}" ]]; then
        printf '0\n'
        return 0
    fi
    find "${directory}" -type f -name "${pattern}" 2>/dev/null | wc -l | tr -d '[:space:]'
}

copy_project_template() {
    # Reset a project to its generated template state: the tree is replaced
    # wholesale (never patched) so a previous repetition cannot leak build info
    # files, emitted output or a mutated source file into the next one.
    local project="$1"
    local target="${PROJECTS_DIR}/${project}"
    local source="${PERF_WORK_DIR}/project-templates/${project}"
    rm -rf -- "${target}"
    mkdir -p "${target}"
    cp -a -- "${source}/." "${target}/"
}
