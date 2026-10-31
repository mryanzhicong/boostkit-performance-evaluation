#!/usr/bin/env bash
set -euo pipefail

# Re-sourcing this file must not reset pinned values that configure_runtime_paths
# already computed (dispatch.sh, base.sh and the stage scripts each source it).
if [[ -n "${REACT_COMMON_SOURCED:-}" ]]; then
    return 0
fi
REACT_COMMON_SOURCED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SOFTWARE_NAME="react"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-19.3.1}"
CATEGORY="Toolchain"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# Pinned runtime toolchain. React 19.3.1's repository pins Node with .nvmrc = v20.19.0,
# so the interpreter, the package manager and every measured dependency are fixed.
NODE_VERSION="20.19.0"
NODE_X64_SHA256="b4e336584d62abefad31baecff7af167268be9bb7dd11f1297112e6eed3ca0d5"
NODE_ARM64_SHA256="dbe339e55eb393955a213e6b872066880bb9feceaa494f4d44c7aac205ec2ab9"
NODE_MIRROR_DEFAULT="https://mirrors.tuna.tsinghua.edu.cn/nodejs-release"
NODE_OFFICIAL_DIST="https://nodejs.org/dist"

YARN_VERSION="1.22.22"
YARN_ARCHIVE_NAME="yarn-1.22.22.tgz"
YARN_SHA256="c17d3797fb9a9115bf375e31bfd30058cac6bc9c3b8807a3d8cb2094794b51ca"

REACT_ARCHIVE_NAME="react-19.3.1.tgz"
REACT_SHA256="56936913918dcf1f7a6fe58784e79df54b18200a88655ce809cf5e9c4ef871aa"
REACT_DOM_ARCHIVE_NAME="react-dom-19.3.1.tgz"
REACT_DOM_SHA256="8b49975821eec6311e00d2b3f4b8337923253c876517388a33f9839c61ab262e"
SCHEDULER_ARCHIVE_NAME="scheduler-0.28.0.tgz"
SCHEDULER_SHA256="302995d590e3c0a11eeb40d1d0f299c1df1800135d599d85cdd5faeb614f32d6"

REACT_SOURCE_NAME="react-19.3.1-source.tar.gz"
REACT_SOURCE_SHA256="350d7bd46030667a3421422f7bae6e30dd1e0955c21e777bf467961fa56de650"
REACT_SOURCE_TAG="v19.3.1"

REGISTRY_DEFAULT="https://registry.npmmirror.com"
REGISTRY_OFFICIAL="https://registry.npmjs.org"

REACT_OFFLINE_DIR="${PERF_REACT_OFFLINE_DIR:-/home/runner/software/react}"
REACT_NODE_MIRROR="${PERF_REACT_NODE_MIRROR:-${NODE_MIRROR_DEFAULT}}"
REACT_REGISTRY="${PERF_REACT_REGISTRY:-${REGISTRY_DEFAULT}}"

REACT_TASKS=(render_to_string static_markup stream)
REACT_SCALES=(100 1000 10000)
# Fixed number of renders per tree size: large enough for a stable timer, small
# enough to keep one repetition in the sub-second to low-second range.
REACT_RENDERS_100="2000"
REACT_RENDERS_1000="1000"
REACT_RENDERS_10000="200"
REACT_WARMUP_RENDERS="10"
REACT_UPSTREAM_SCENARIOS=(upstream_build)
# Upstream workload: the release production bundle set of the server-side entry
# points (SSR + Flight) that the measured runtime family uses, built from the
# facebook/react v19.3.1 source tree with the repository's own rollup build script
# (the script `yarn build` drives). The TypeScript-only eslint plugin bundle and the
# browser UMD/devtool bundles are excluded: they belong to the devtooling build, not
# to the server runtime under test, and are documented in the README.
REACT_UPSTREAM_BUILD_SCRIPT="scripts/rollup/build.js"
REACT_UPSTREAM_BUILD_ENTRIES="react/index,react/jsx,react.react-server,react-dom/index,react-dom/client,react-dom/server,react-dom.react-server,react-dom-server.node,react-dom-server-legacy.node,scheduler,react-server-dom-webpack/,react-server-dom-unbundled/"
REACT_UPSTREAM_BUILD_TYPES="NODE_PROD,ESM_PROD,NODE_ES2015"
REACT_UPSTREAM_RELEASE_CHANNEL="stable"
REACT_UPSTREAM_BUILD_OUTPUT="build"
# The upstream release build runs google-closure-compiler for some bundles, which
# is a Java program. The JRE is a build-stage dependency only; its actual version
# is recorded in build_info.json.
REACT_JAVA_PACKAGE="java-17-openjdk-headless"

REACT_REPS="${PERF_REPS:-5}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"

REACT_NODE_HOME=""
REACT_NODE_BIN=""
REACT_NPM_CLI=""
REACT_YARN_JS=""
REACT_APP_DIR=""
REACT_APP_BENCH_SCRIPT=""
REACT_SOURCE_DIR=""
REACT_BENCH_DIR=""
REACT_BENCH_SCRIPT=""
REACT_RUNS_DIR=""
REACT_NODE_ARCHIVE_NAME=""
REACT_NODE_ARCHIVE_SHA256=""
REACT_NODE_ARCHIVE_URL=""
REACT_NODE_ARCHIVE_URL_FALLBACK=""

log_message() {
    local level="INFO"
    if [[ "${1:-}" == "WARN" || "${1:-}" == "ERROR" ]]; then
        level="$1"
        shift
    fi
    printf '[react] [%s] %s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "${level}" "$*"
}

normalize_architecture() {
    local architecture="${1:-}"
    case "${architecture}" in
        x86_64|amd64|x64)
            printf 'x86_64\n'
            ;;
        aarch64|arm64)
            printf 'aarch64\n'
            ;;
        *)
            return 1
            ;;
    esac
}

validate_variant() {
    local variant="${PERF_VARIANT:-base}"
    case "${variant}" in
        base|optimized)
            PERF_VARIANT="${variant}"
            ;;
        *)
            log_message "ERROR: unsupported variant: ${variant} (expected base or optimized)"
            return 10
            ;;
    esac
}

validate_architecture() {
    case "${EXPECTED_ARCH:-}" in
        x86_64|aarch64)
            ;;
        *)
            log_message "ERROR: unsupported architecture: ${EXPECTED_ARCH:-<unset>}"
            return 10
            ;;
    esac
}

validate_reps() {
    if [[ ! "${REACT_REPS}" =~ ^[1-9][0-9]*$ ]]; then
        log_message "ERROR: PERF_REPS must be a positive integer, got: ${REACT_REPS}"
        return 10
    fi
    if (( REACT_REPS < 5 )); then
        log_message "WARN: PERF_REPS=${REACT_REPS} is below the 5 independent repetitions used for official evidence"
    fi
}

react_renders_for_scale() {
    case "${1:-}" in
        100) printf '%s\n' "${REACT_RENDERS_100}" ;;
        1000) printf '%s\n' "${REACT_RENDERS_1000}" ;;
        10000) printf '%s\n' "${REACT_RENDERS_10000}" ;;
        *)
            return 1
            ;;
    esac
}

react_scenario_list() {
    local task scale
    for scale in "${REACT_SCALES[@]}"; do
        for task in "${REACT_TASKS[@]}"; do
            printf '%s_%s\n' "${task}" "${scale}"
        done
    done
    printf '%s\n' "${REACT_UPSTREAM_SCENARIOS[@]}"
}

# Scenario -> "<task>:<scale>" where scale is empty for the upstream workload.
react_scenario_parts() {
    local scenario="${1:-}"
    local task scale
    if [[ "${scenario}" == "upstream_build" ]]; then
        printf 'upstream_build:\n'
        return 0
    fi
    task="${scenario%_*}"
    scale="${scenario##*_}"
    case "${task}" in
        render_to_string|static_markup|stream)
            ;;
        *)
            return 1
            ;;
    esac
    case "${scale}" in
        100|1000|10000)
            ;;
        *)
            return 1
            ;;
    esac
    printf '%s:%s\n' "${task}" "${scale}"
}

select_node_archive() {
    local architecture="${1:-${EXPECTED_ARCH:-}}"
    case "${architecture}" in
        x86_64)
            REACT_NODE_ARCHIVE_NAME="node-v${NODE_VERSION}-linux-x64.tar.xz"
            REACT_NODE_ARCHIVE_SHA256="${NODE_X64_SHA256}"
            ;;
        aarch64)
            REACT_NODE_ARCHIVE_NAME="node-v${NODE_VERSION}-linux-arm64.tar.xz"
            REACT_NODE_ARCHIVE_SHA256="${NODE_ARM64_SHA256}"
            ;;
        *)
            log_message "ERROR: cannot select a Node archive for architecture: ${architecture}"
            return 10
            ;;
    esac
    REACT_NODE_ARCHIVE_URL="${REACT_NODE_MIRROR}/v${NODE_VERSION}/${REACT_NODE_ARCHIVE_NAME}"
    REACT_NODE_ARCHIVE_URL_FALLBACK="${NODE_OFFICIAL_DIST}/v${NODE_VERSION}/${REACT_NODE_ARCHIVE_NAME}"
}

configure_runtime_paths() {
    validate_variant || return $?
    validate_reps || return $?
    EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
    EXPECTED_ARCH="$(normalize_architecture "${EXPECTED_ARCH}")" || {
        log_message "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
        return 20
    }
    local runner_architecture
    runner_architecture="$(normalize_architecture "$(uname -m)")" || {
        log_message "ERROR: unsupported runner architecture: $(uname -m)"
        return 20
    }
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log_message "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    select_node_archive "${EXPECTED_ARCH}" || return $?
    if [[ -z "${PERF_RUN_ID:-}" ]]; then
        PERF_RUN_ID="$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    if [[ -z "${RESULTS_DIR:-}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${PERF_WORK_DIR:-}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/react/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    TMPDIR="${TMPDIR:-${PERF_WORK_DIR}/tmp}"
    REACT_NODE_HOME="${PERF_WORK_DIR}/node"
    REACT_NODE_BIN="${REACT_NODE_HOME}/bin/node"
    REACT_NPM_CLI="${REACT_NODE_HOME}/bin/npm"
    REACT_YARN_JS="${PERF_WORK_DIR}/yarn/bin/yarn.js"
    REACT_APP_DIR="${PERF_WORK_DIR}/app"
    REACT_APP_BENCH_SCRIPT="${REACT_APP_DIR}/bench_ssr.js"
    REACT_SOURCE_DIR="${PERF_WORK_DIR}/react-source"
    REACT_BENCH_DIR="${PERF_WORK_DIR}/bench"
    REACT_BENCH_SCRIPT="${SCRIPT_DIR}/scripts/bench_ssr.js"
    REACT_RUNS_DIR="${RESULTS_DIR}/runs"
    # The pinned Node.js launcher must be first on PATH: the bundled npm/yarn
    # entry points and the upstream build scripts spawn `node` by name.
    export PATH="${REACT_NODE_HOME}/bin:${PATH}"
    export SOFTWARE_NAME SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID
    export RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR STANDALONE_OWNS_WORK_DIR
    export REACT_NODE_HOME REACT_NODE_BIN REACT_NPM_CLI REACT_YARN_JS
    export REACT_APP_DIR REACT_APP_BENCH_SCRIPT REACT_SOURCE_DIR REACT_BENCH_DIR
    export REACT_BENCH_SCRIPT REACT_RUNS_DIR
    export REACT_NODE_ARCHIVE_NAME REACT_NODE_ARCHIVE_SHA256 REACT_NODE_ARCHIVE_URL
    export REACT_NODE_ARCHIVE_URL_FALLBACK REACT_REGISTRY REACT_OFFLINE_DIR
    export REACT_REPS REACT_WARMUP_RENDERS REACT_SCALES REACT_TASKS
    export REACT_UPSTREAM_BUILD_SCRIPT REACT_UPSTREAM_BUILD_OUTPUT
    export REACT_UPSTREAM_BUILD_ENTRIES REACT_UPSTREAM_BUILD_TYPES REACT_UPSTREAM_RELEASE_CHANNEL
    export REACT_NODE_VERSION_REQUIRED="${NODE_VERSION}" REACT_YARN_VERSION_REQUIRED="${YARN_VERSION}"
}

initialize_runtime() {
    if [[ -z "${REACT_NODE_BIN:-}" || -z "${REACT_RUNS_DIR:-}" ]]; then
        configure_runtime_paths || return $?
    fi
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
    NPM_CONFIG_CACHE="${NPM_CONFIG_CACHE:-${PERF_WORK_DIR}/npm-cache}"
    YARN_CACHE_FOLDER="${YARN_CACHE_FOLDER:-${PERF_WORK_DIR}/yarn-cache}"
    export TMPDIR NPM_CONFIG_CACHE YARN_CACHE_FOLDER
    mkdir -p "${NPM_CONFIG_CACHE}" "${YARN_CACHE_FOLDER}"
}

node_version_string() {
    "${REACT_NODE_BIN}" --version 2>/dev/null
}

yarn_version_string() {
    if [[ ! -x "${REACT_NODE_BIN}" || ! -f "${REACT_YARN_JS}" ]]; then
        return 1
    fi
    "${REACT_NODE_BIN}" "${REACT_YARN_JS}" --version 2>/dev/null
}

java_version_string() {
    if ! command -v java >/dev/null 2>&1; then
        return 1
    fi
    java -version 2>&1 | sed -n '1{s/^openjdk version "//;s/".*$//;p}'
}

react_version_string() {
    [[ -f "${REACT_APP_DIR}/node_modules/react/package.json" ]] || return 1
    "${REACT_NODE_BIN}" -e 'process.stdout.write(require(process.argv[1]).version)' \
        "${REACT_APP_DIR}/node_modules/react/package.json" 2>/dev/null
}

react_dom_version_string() {
    [[ -f "${REACT_APP_DIR}/node_modules/react-dom/package.json" ]] || return 1
    "${REACT_NODE_BIN}" -e 'process.stdout.write(require(process.argv[1]).version)' \
        "${REACT_APP_DIR}/node_modules/react-dom/package.json" 2>/dev/null
}

react_scheduler_version_string() {
    [[ -f "${REACT_APP_DIR}/node_modules/scheduler/package.json" ]] || return 1
    "${REACT_NODE_BIN}" -e 'process.stdout.write(require(process.argv[1]).version)' \
        "${REACT_APP_DIR}/node_modules/scheduler/package.json" 2>/dev/null
}

react_source_version_string() {
    [[ -f "${REACT_SOURCE_DIR}/packages/react/package.json" ]] || return 1
    "${REACT_NODE_BIN}" -e 'process.stdout.write(require(process.argv[1]).version)' \
        "${REACT_SOURCE_DIR}/packages/react/package.json" 2>/dev/null
}

react_record_actual_version() {
    local version
    if ! version="$(react_version_string)"; then
        log_message "ERROR: cannot read the installed React version from ${REACT_APP_DIR}"
        return 30
    fi
    if [[ "${version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: expected React ${SOFTWARE_VERSION}, installed ${version}"
        return 30
    fi
    printf '%s\n' "${version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "recorded actual React version: ${version}"
}
