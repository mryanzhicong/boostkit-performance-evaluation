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

# ------------------------------------------------- container process env ------
# ``docker exec`` does not inherit the caller's environment, so every value the
# build or the measurement needs is forwarded explicitly.  Absolute paths are
# identical inside and outside the container because the work directory, the
# result directory and the case directory are mounted at the same paths.
REACT_CONTAINER_ENV=()

react_build_env() {
    REACT_CONTAINER_ENV=(
        "PATH=${REACT_NODE_HOME}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        "TMPDIR=${PERF_WORK_DIR}/tmp"
        "NPM_CONFIG_CACHE=${NPM_CONFIG_CACHE:-${PERF_WORK_DIR}/npm-cache}"
        "npm_config_cache=${NPM_CONFIG_CACHE:-${PERF_WORK_DIR}/npm-cache}"
        "YARN_CACHE_FOLDER=${YARN_CACHE_FOLDER:-${PERF_WORK_DIR}/yarn-cache}"
        "REACT_REGISTRY=${REACT_REGISTRY}"
        "npm_config_registry=${REACT_REGISTRY}"
        "SOFTWARE_VERSION=${SOFTWARE_VERSION}"
        "REACT_RUNS_DIR=${REACT_RUNS_DIR}"
        "REACT_UPSTREAM_BUILD_OUTPUT=${REACT_UPSTREAM_BUILD_OUTPUT}"
        "REACT_UPSTREAM_BUILD_SCRIPT=${REACT_UPSTREAM_BUILD_SCRIPT}"
        "REACT_NODE_VERSION_REQUIRED=${NODE_VERSION}"
        "REACT_YARN_VERSION_REQUIRED=${YARN_VERSION}"
    )
}

# Measurement environment: no network (the SSR harness and the release build only
# touch local files and node_modules) and a deterministic C locale so the same
# workload runs on both architectures.
react_measure_env() {
    react_build_env
    REACT_CONTAINER_ENV+=(
        "NODE_ENV=production"
        "TZ=UTC"
        "LC_ALL=C"
        "LANG=C"
        "HTTP_PROXY=http://127.0.0.1:9"
        "HTTPS_PROXY=http://127.0.0.1:9"
        "http_proxy=http://127.0.0.1:9"
        "https_proxy=http://127.0.0.1:9"
        "NO_PROXY=127.0.0.1,localhost"
        "no_proxy=127.0.0.1,localhost"
    )
}

react_container_exec_env() {
    react_build_env
    react_container_exec env "${REACT_CONTAINER_ENV[@]}" "$@"
}

react_container_exec_env_at() {
    local workdir="$1"
    shift
    react_build_env
    react_container_exec_at "${workdir}" env "${REACT_CONTAINER_ENV[@]}" "$@"
}

react_container_measure_at() {
    local workdir="$1"
    shift
    react_measure_env
    react_container_exec_at "${workdir}" env "${REACT_CONTAINER_ENV[@]}" "$@"
}

node_version_string() {
    react_container_exec "${REACT_NODE_BIN}" --version 2>/dev/null
}

yarn_version_string() {
    react_container_exec test -x "${REACT_NODE_BIN}" || return 1
    react_container_exec test -f "${REACT_YARN_JS}" || return 1
    react_container_exec "${REACT_NODE_BIN}" "${REACT_YARN_JS}" --version 2>/dev/null
}

java_major_version() {
    local reported
    reported="$(react_container_exec java -version 2>&1 | sed -n '1{s/.*version "\([0-9]*\)\..*/\1/p}')"
    [[ -n "${reported}" ]] || return 1
    # Java 8 reports "1.8.x".
    [[ "${reported}" == "1" ]] && reported=8
    printf '%s\n' "${reported}"
}

# The build stage installs the pinned headless JRE with dnf, so the container's
# /usr/bin/java is already the right runtime; this function only reports it and
# fails loudly if the package installation did not produce a usable java.
activate_installed_java() {
    local current
    current="$(java_major_version 2>/dev/null || printf '0')"
    if (( current >= 11 )); then
        log_message "java runtime available inside the private container ($(java_version_string 2>/dev/null || true))"
        return 0
    fi
    log_message "ERROR: no Java 11+ runtime inside the private container; the build stage must install ${REACT_JAVA_PACKAGE}"
    return 30
}

java_version_string() {
    react_container_exec java -version 2>&1 | sed -n '1{s/^openjdk version "//;s/".*$//;p}'
}

react_version_string() {
    react_container_exec test -f "${REACT_APP_DIR}/node_modules/react/package.json" || return 1
    react_container_exec "${REACT_NODE_BIN}" -e 'process.stdout.write(require(process.argv[1]).version)' \
        "${REACT_APP_DIR}/node_modules/react/package.json" 2>/dev/null
}

react_dom_version_string() {
    react_container_exec test -f "${REACT_APP_DIR}/node_modules/react-dom/package.json" || return 1
    react_container_exec "${REACT_NODE_BIN}" -e 'process.stdout.write(require(process.argv[1]).version)' \
        "${REACT_APP_DIR}/node_modules/react-dom/package.json" 2>/dev/null
}

react_scheduler_version_string() {
    react_container_exec test -f "${REACT_APP_DIR}/node_modules/scheduler/package.json" || return 1
    react_container_exec "${REACT_NODE_BIN}" -e 'process.stdout.write(require(process.argv[1]).version)' \
        "${REACT_APP_DIR}/node_modules/scheduler/package.json" 2>/dev/null
}

react_source_version_string() {
    react_container_exec test -f "${REACT_SOURCE_DIR}/packages/react/package.json" || return 1
    react_container_exec "${REACT_NODE_BIN}" -e 'process.stdout.write(require(process.argv[1]).version)' \
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

# >>> container-runtime:begin
# ==============================================================================
# Private openEuler container runtime
# ==============================================================================
# Every stage of this case runs inside a per-run openEuler 24.03 LTS SP4
# container.  The host keeps only Docker, download/verification tooling, the
# framework and the strict result parser; package installation, source
# extraction, builds, the measured process tree and cleanup happen inside the
# container.  The contract mirrors software/Database/mysql,
# software/Bigdata/ray and software/Others/unixbench.
#
# Generated by adaptation/scripts/add-container-block.py -- do not hand edit the
# region between the markers; change the template instead.
REACT_IMAGE_ARCHIVE_DIR="${REACT_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
REACT_CA_ANCHORS_DIR="${REACT_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
REACT_CONTAINER_IMAGE="${REACT_CONTAINER_IMAGE:-}"
REACT_CONTAINER_NAME="${REACT_CONTAINER_NAME:-}"
REACT_CONTAINER_HOME="${REACT_CONTAINER_HOME:-}"
declare -p REACT_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || REACT_CONTAINER_EXTRA_ARGS=()

react_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

react_configure_container() {
    local arch
    arch="$(react_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${REACT_CONTAINER_NAME}" ] || REACT_CONTAINER_NAME="boostkit-react-${arch}-${PERF_RUN_ID}"
    [ -n "${REACT_CONTAINER_HOME}" ] || REACT_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export REACT_CONTAINER_NAME REACT_CONTAINER_HOME
}

react_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_react_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_react_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${REACT_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_react_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(react_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${REACT_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${REACT_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        react_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        react_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
    fi
    if [ -s "${checksum}" ]; then
        ( cd "$(dirname "${archive}")" && sha256sum -c "$(basename "${checksum}")" ) >/dev/null || {
            log_message "ERROR: container image checksum mismatch: ${archive}"
            return 30
        }
    else
        log_message "WARNING: no checksum file next to ${archive}; relying on the pinned path only"
    fi
    log_message "loading verified openEuler container image: ${archive}"
    load_output="$(docker load --input "${archive}")" || return 30
    REACT_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${REACT_CONTAINER_IMAGE}" ] || ! docker image inspect "${REACT_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${REACT_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_react_container_image_release || return $?
    export REACT_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${REACT_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_react_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-react-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${REACT_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.react.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_react_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    react_configure_container
    require_react_docker || return $?
    if docker container inspect "${REACT_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${REACT_CONTAINER_NAME}"
        return 40
    fi
    sweep_react_stale_containers || true
    prepare_react_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${REACT_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${REACT_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${REACT_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${REACT_CONTAINER_HOME}" || return 40
    log_message "starting private container ${REACT_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${REACT_CONTAINER_NAME}" \
        --label "boostkit.react.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${REACT_CONTAINER_EXTRA_ARGS[@]}" \
        "${REACT_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${REACT_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${REACT_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${REACT_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${REACT_CONTAINER_NAME}"
}

check_react_container() {
    react_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${REACT_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${REACT_CONTAINER_NAME}"
        return 40
    }
}

react_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    react_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${REACT_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${REACT_CONTAINER_NAME}" "$@"
}

react_container_exec() { react_docker_exec '' '' "$@"; }

react_container_exec_at() {
    local workdir="$1"
    shift
    react_docker_exec "${workdir}" '' "$@"
}

react_container_exec_root() { react_docker_exec '' root "$@"; }

react_container_exec_root_at() {
    local workdir="$1"
    shift
    react_docker_exec "${workdir}" root "$@"
}

remove_react_container() {
    react_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${REACT_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.react.run-id"}}' "${REACT_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${REACT_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${REACT_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${REACT_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${REACT_CONTAINER_NAME}"
}
# >>> container-runtime:end
