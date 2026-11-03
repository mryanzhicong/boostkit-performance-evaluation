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
TYPESCRIPT_IMAGE_ARCHIVE_DIR="${TYPESCRIPT_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
TYPESCRIPT_CA_ANCHORS_DIR="${TYPESCRIPT_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
TYPESCRIPT_CONTAINER_IMAGE="${TYPESCRIPT_CONTAINER_IMAGE:-}"
TYPESCRIPT_CONTAINER_NAME="${TYPESCRIPT_CONTAINER_NAME:-}"
TYPESCRIPT_CONTAINER_HOME="${TYPESCRIPT_CONTAINER_HOME:-}"
declare -p TYPESCRIPT_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || TYPESCRIPT_CONTAINER_EXTRA_ARGS=()

typescript_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

typescript_configure_container() {
    local arch
    arch="$(typescript_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${TYPESCRIPT_CONTAINER_NAME}" ] || TYPESCRIPT_CONTAINER_NAME="boostkit-typescript-${arch}-${PERF_RUN_ID}"
    [ -n "${TYPESCRIPT_CONTAINER_HOME}" ] || TYPESCRIPT_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export TYPESCRIPT_CONTAINER_NAME TYPESCRIPT_CONTAINER_HOME
}

typescript_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_typescript_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_typescript_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${TYPESCRIPT_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_typescript_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(typescript_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${TYPESCRIPT_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${TYPESCRIPT_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        typescript_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        typescript_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    TYPESCRIPT_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${TYPESCRIPT_CONTAINER_IMAGE}" ] || ! docker image inspect "${TYPESCRIPT_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${TYPESCRIPT_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_typescript_container_image_release || return $?
    export TYPESCRIPT_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${TYPESCRIPT_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_typescript_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-typescript-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${TYPESCRIPT_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.typescript.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_typescript_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    typescript_configure_container
    require_typescript_docker || return $?
    if docker container inspect "${TYPESCRIPT_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${TYPESCRIPT_CONTAINER_NAME}"
        return 40
    fi
    sweep_typescript_stale_containers || true
    prepare_typescript_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${TYPESCRIPT_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${TYPESCRIPT_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${TYPESCRIPT_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${TYPESCRIPT_CONTAINER_HOME}" || return 40
    log_message "starting private container ${TYPESCRIPT_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${TYPESCRIPT_CONTAINER_NAME}" \
        --label "boostkit.typescript.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${TYPESCRIPT_CONTAINER_EXTRA_ARGS[@]}" \
        "${TYPESCRIPT_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${TYPESCRIPT_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${TYPESCRIPT_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${TYPESCRIPT_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${TYPESCRIPT_CONTAINER_NAME}"
}

check_typescript_container() {
    typescript_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${TYPESCRIPT_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${TYPESCRIPT_CONTAINER_NAME}"
        return 40
    }
}

typescript_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    typescript_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${TYPESCRIPT_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${TYPESCRIPT_CONTAINER_NAME}" "$@"
}

typescript_container_exec() { typescript_docker_exec '' '' "$@"; }

typescript_container_exec_at() {
    local workdir="$1"
    shift
    typescript_docker_exec "${workdir}" '' "$@"
}

typescript_container_exec_root() { typescript_docker_exec '' root "$@"; }

typescript_container_exec_root_at() {
    local workdir="$1"
    shift
    typescript_docker_exec "${workdir}" root "$@"
}

remove_typescript_container() {
    typescript_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${TYPESCRIPT_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.typescript.run-id"}}' "${TYPESCRIPT_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${TYPESCRIPT_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${TYPESCRIPT_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${TYPESCRIPT_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${TYPESCRIPT_CONTAINER_NAME}"
}
# >>> container-runtime:end
