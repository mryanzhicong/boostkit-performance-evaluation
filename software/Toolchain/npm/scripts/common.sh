#!/usr/bin/env bash
#
# Shared configuration and helpers for the npm case.
#
# The case measures the cost of real npm operations (clean install, offline
# reinstall, incremental install, read-only tree traversal) over committed,
# checksum-pinned lockfiles.  Everything that is compared across architectures
# is fixed here: the Node.js runtime, the npm release, the registry used to warm
# the cache, the cache location, the offline flags and the repetition count.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="npm"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-12.2.1}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# npm 12.2.1 declares "engines": {"node": "^22.22.2 || ^24.15.0 || >=26.0.0"}.
# The case pins the newest 22.x LTS release so that the measurement is identical
# on both architectures and never depends on the runner's pre-installed Node.
NODE_VERSION="v22.23.4"
NODE_SEMVER="22.23.4"
NPM_NODE_ENGINES="^22.22.2 || ^24.15.0 || >=26.0.0"
NODE_X64_SHA256="1805bcd35e6815559bd2eb97db438d3fdb0eb3a5e6a977b7c1badca76337e9ce"
NODE_ARM64_SHA256="6287aa46b6c375d816e63ae66d024fbbfd70404825aabdfdf898a970871d2f4b"
NODE_DIST_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/nodejs-release"
NODE_DIST_OFFICIAL="https://nodejs.org/dist"

# npm is installed from its own published tarball and runs on the pinned Node
# binary; the runner's system npm is never used or modified.  The SHA-256 is the
# official artifact hash and the SHA-512 is the integrity value published by the
# registry, so a mirror can be used without trusting it.
NPM_TARBALL_NAME="npm-${SOFTWARE_VERSION}.tgz"
NPM_TARBALL_SHA256="228bd64aaef23270dbdbd2cf3d5ef5c467602ef38c4066246cef1984adab9a67"
NPM_TARBALL_SHA512_B64="bKCmFRVT/BB+YPEYbZwQ1XUI3N5t4xKSpU1MxOjo7z3iWzKBJ0ZXRC1xFdEN+TC7N5TdywaBzf2dMXGJq/e2PQ=="
NPM_TARBALL_MIRROR_URL="https://registry.npmmirror.com/npm/-/${NPM_TARBALL_NAME}"
NPM_TARBALL_OFFICIAL_URL="https://registry.npmjs.org/npm/-/${NPM_TARBALL_NAME}"

# Registry used to warm the private cache during the build stage.  Measurements
# never touch the network, so this only affects the (untimed) prefetch.
#
# The default is the Huawei Cloud npm mirror because it serves tarballs directly
# at their registry path.  A mirror that answers tarball requests with a redirect
# (registry.npmmirror.com redirects to cdn.npmmirror.com) cannot be used for the
# offline matrix: npm caches the redirected URL, so the offline install then
# misses the cache and refuses to continue.  The lockfiles of every fixture are
# rewritten to this registry origin when they are materialised.
NPM_REGISTRY="${PERF_NPM_REGISTRY:-https://mirrors.huaweicloud.com/repository/npm}"
NPM_OFFLINE_DIR="${NPM_OFFLINE_DIR:-/home/runner/software/npm}"
NPM_REPS="${PERF_REPS:-5}"

# Committed lockfile fixtures.  "small"/"medium"/"large" form the dependency
# scale matrix, "upstream" is a real open-source project pinned by commit.
NPM_FIXTURES=(small medium large upstream)
NPM_SCENARIOS=(
    ci_clean_small
    ci_clean_medium
    ci_clean_large
    ci_upstream
    install_resolve_small
    install_noop_medium
    install_add_dep_medium
    query_prod_medium
)
NPM_EXTRA_DEP_NAME="is-odd"
NPM_EXTRA_DEP_VERSION="3.0.1"
NPM_EXTRA_DEP="${NPM_EXTRA_DEP_NAME}@${NPM_EXTRA_DEP_VERSION}"

NODE_HOME=""
NPM_HOME=""
NODE_BIN=""
NPM_CLI_JS=""
NPM_BIN_DIR=""
NPM_WRAPPER=""
NPM_CACHE=""
NPM_PRIVATE_HOME=""
FIXTURES_DIR=""
SCRATCH_DIR=""
INSTALLED_TEMPLATE=""
FIXTURE_METADATA=""
BUILD_LOGS_DIR=""
RUNS_DIR=""
TARBALL_NAME=""
TARBALL_SHA256=""
TARBALL_URLS=()
NODE_VERSION_STRING=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[npm] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    [[ "${NPM_REPS}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: PERF_REPS must be a positive integer, got ${NPM_REPS}"
        return 10
    }
    if (( NPM_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${NPM_REPS} is a local link-validation value; formal evidence requires >= 5"
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

scenario_fixture() {
    case "$1" in
        ci_clean_small|install_resolve_small) printf 'small\n' ;;
        ci_clean_medium|install_noop_medium|install_add_dep_medium|query_prod_medium) printf 'medium\n' ;;
        ci_clean_large) printf 'large\n' ;;
        ci_upstream) printf 'upstream\n' ;;
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/npm/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    select_node_artifact || return $?
    NODE_HOME="${PERF_WORK_DIR}/node-install"
    NPM_HOME="${PERF_WORK_DIR}/npm-install"
    NODE_BIN="${NODE_HOME}/bin/node"
    NPM_CLI_JS="${NPM_HOME}/bin/npm-cli.js"
    NPM_BIN_DIR="${PERF_WORK_DIR}/bin"
    NPM_WRAPPER="${NPM_BIN_DIR}/npm"
    NPM_CACHE="${PERF_WORK_DIR}/npm-cache"
    NPM_PRIVATE_HOME="${PERF_WORK_DIR}/home"
    FIXTURES_DIR="${PERF_WORK_DIR}/fixtures"
    SCRATCH_DIR="${PERF_WORK_DIR}/scratch"
    INSTALLED_TEMPLATE="${PERF_WORK_DIR}/installed-template/medium"
    FIXTURE_METADATA="${PERF_WORK_DIR}/fixtures-metadata.json"
    BUILD_LOGS_DIR="${RESULTS_DIR}/build-logs"
    RUNS_DIR="${RESULTS_DIR}/runs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR NPM_REPS NPM_REGISTRY NODE_VERSION
    export NODE_HOME NPM_HOME NODE_BIN NPM_CLI_JS NPM_BIN_DIR NPM_WRAPPER NPM_CACHE
    export NPM_PRIVATE_HOME FIXTURES_DIR SCRATCH_DIR INSTALLED_TEMPLATE
    export FIXTURE_METADATA BUILD_LOGS_DIR RUNS_DIR NODE_VERSION_STRING
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${NPM_PRIVATE_HOME}"
}

# Every measured command runs through this wrapper so that the isolated HOME,
# the private cache directory and the offline-friendly npm configuration are
# identical for build-time validation, measurement and standalone runs.
write_npm_wrapper() {
    mkdir -p "${NPM_BIN_DIR}" "${NPM_PRIVATE_HOME}" "${NPM_CACHE}"
    cat > "${NPM_WRAPPER}" <<WRAPPER
#!/usr/bin/env bash
set -euo pipefail
export HOME='${NPM_PRIVATE_HOME}'
export npm_config_cache='${NPM_CACHE}'
export npm_config_registry='${NPM_REGISTRY}'
export npm_config_audit='false'
export npm_config_fund='false'
export npm_config_update_notifier='false'
export npm_config_ignore_scripts='true'
export npm_config_loglevel='notice'
export CI='1'
exec '${NODE_BIN}' '${NPM_CLI_JS}' "\$@"
WRAPPER
    chmod 755 "${NPM_WRAPPER}"
}

# --- shared fixture helpers (used by the build stage and by measurement) ------

count_installed_packages() {
    # npm records the installed tree in node_modules/.package-lock.json; the
    # number of entries is the authoritative "how many packages are installed"
    # value and is comparable with the lockfile, unlike counting every
    # package.json file (some packages ship nested manifests of their own).
    local node_modules="$1"
    if [[ ! -d "${node_modules}" ]]; then
        printf '0\n'
        return 0
    fi
    python3 - "${node_modules}" <<'PY'
import json
import sys
from pathlib import Path

node_modules = Path(sys.argv[1])
hidden = node_modules / ".package-lock.json"
count = 0
if hidden.is_file():
    try:
        payload = json.loads(hidden.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        payload = {}
    packages = payload.get("packages")
    if isinstance(packages, dict):
        count = len([key for key in packages if key])
if count <= 0:
    # Fallback for trees that do not carry a hidden lockfile: count the
    # top-level package directories the way npm lays them out.
    for entry in node_modules.iterdir():
        if entry.name.startswith("."):
            continue
        if entry.name.startswith("@") and entry.is_dir():
            for scoped in entry.iterdir():
                if (scoped / "package.json").is_file():
                    count += 1
        elif (entry / "package.json").is_file():
            count += 1
print(count)
PY
}

prepare_fixture_clean() {
    # Every measurement starts from the committed fixture tree: the target is
    # replaced wholesale (never patched) so a previous repetition cannot leak
    # node_modules, a modified package.json or a stale lockfile into the next
    # one.  The whole tree is copied because the upstream fixture links a
    # directory of its own repository; the lockfile origin is then pointed at
    # the registry that warmed the cache so that offline installs hit the cache.
    local fixture="$1"
    local target="${FIXTURES_DIR}/${fixture}"
    local source="${SCRIPT_DIR}/fixtures/${fixture}"
    rm -rf -- "${target}"
    mkdir -p "${target}"
    cp -a -- "${source}/." "${target}/"
    rm -rf -- "${target}/node_modules"
    normalize_fixture_lockfile "${target}/package-lock.json"
}

normalize_fixture_lockfile() {
    local lockfile="$1"
    if [[ ! -f "${lockfile}" ]]; then
        return 0
    fi
    python3 "${SCRIPT_DIR}/scripts/normalize_lockfile.py" "${lockfile}" "${NPM_REGISTRY}" || {
        log_message "ERROR: could not normalize the lockfile origin of ${lockfile}"
        return 30
    }
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
NPM_IMAGE_ARCHIVE_DIR="${NPM_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
NPM_CA_ANCHORS_DIR="${NPM_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
NPM_CONTAINER_IMAGE="${NPM_CONTAINER_IMAGE:-}"
NPM_CONTAINER_NAME="${NPM_CONTAINER_NAME:-}"
NPM_CONTAINER_HOME="${NPM_CONTAINER_HOME:-}"
declare -p NPM_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || NPM_CONTAINER_EXTRA_ARGS=()

npm_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

npm_configure_container() {
    local arch
    arch="$(npm_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${NPM_CONTAINER_NAME}" ] || NPM_CONTAINER_NAME="boostkit-npm-${arch}-${PERF_RUN_ID}"
    [ -n "${NPM_CONTAINER_HOME}" ] || NPM_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export NPM_CONTAINER_NAME NPM_CONTAINER_HOME
}

npm_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_npm_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_npm_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${NPM_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_npm_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(npm_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${NPM_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${NPM_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        npm_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        npm_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    NPM_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${NPM_CONTAINER_IMAGE}" ] || ! docker image inspect "${NPM_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${NPM_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_npm_container_image_release || return $?
    export NPM_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${NPM_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_npm_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-npm-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${NPM_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.npm.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_npm_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    npm_configure_container
    require_npm_docker || return $?
    if docker container inspect "${NPM_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${NPM_CONTAINER_NAME}"
        return 40
    fi
    sweep_npm_stale_containers || true
    prepare_npm_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${NPM_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${NPM_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${NPM_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${NPM_CONTAINER_HOME}" || return 40
    log_message "starting private container ${NPM_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${NPM_CONTAINER_NAME}" \
        --label "boostkit.npm.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${NPM_CONTAINER_EXTRA_ARGS[@]}" \
        "${NPM_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${NPM_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${NPM_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${NPM_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${NPM_CONTAINER_NAME}"
}

check_npm_container() {
    npm_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${NPM_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${NPM_CONTAINER_NAME}"
        return 40
    }
}

npm_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    npm_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${NPM_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${NPM_CONTAINER_NAME}" "$@"
}

npm_container_exec() { npm_docker_exec '' '' "$@"; }

npm_container_exec_at() {
    local workdir="$1"
    shift
    npm_docker_exec "${workdir}" '' "$@"
}

npm_container_exec_root() { npm_docker_exec '' root "$@"; }

npm_container_exec_root_at() {
    local workdir="$1"
    shift
    npm_docker_exec "${workdir}" root "$@"
}

remove_npm_container() {
    npm_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${NPM_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.npm.run-id"}}' "${NPM_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${NPM_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${NPM_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${NPM_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${NPM_CONTAINER_NAME}"
}
# >>> container-runtime:end
