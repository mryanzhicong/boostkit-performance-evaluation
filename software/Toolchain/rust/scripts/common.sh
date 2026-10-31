#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASE_DIR="${SCRIPT_DIR}"
SOFTWARE_NAME="rust"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.99.1}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"

# Official Rust distribution endpoint and the pinned upstream benchmark suite.
# Direct-network runners (no PERF_PROXY) can reach domestic mirrors but not
# overseas hosts, so the Rust distribution and crates registry fall back to
# the USTC mirror; the proxy path keeps the official endpoints.
if [[ -n "${RUST_RELEASE_BASE:-}" ]]; then
    :
elif [[ -n "${PERF_PROXY:-}" ]]; then
    RUST_RELEASE_BASE="https://static.rust-lang.org/dist"
else
    RUST_RELEASE_BASE="https://mirrors.ustc.edu.cn/rust-static/dist"
fi
RUST_CARGO_MIRROR_INDEX="${RUST_CARGO_MIRROR_INDEX:-sparse+https://mirrors.ustc.edu.cn/crates.io-index/}"
RUSTC_PERF_REPOSITORY="${RUSTC_PERF_REPOSITORY:-https://github.com/rust-lang/rustc-perf.git}"
RUSTC_PERF_REVISION="${RUSTC_PERF_REVISION:-9fa958a70781ab8abe5ee9e0875f0a9a62ecb20c}"
RUST_ARCHIVE_DIR="${RUST_ARCHIVE_DIR:-/home/runner/software/rust}"

# openEuler container runtime (same base image and loading method as MySQL).
RUST_IMAGE_ARCHIVE_DIR="${RUST_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
RUST_CA_ANCHORS_DIR="${RUST_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
RUST_CONTAINER_IMAGE=""
RUST_CONTAINER_NAME=""

# Formal workload: official rustc-perf defaults restricted to the Primary
# (real-world) benchmark category, the three default build profiles, and the
# Full (non-incremental) scenario for compile-time measurements; the runtime
# suite keeps its default iteration count.
RUST_COMPILE_PROFILES="${RUST_COMPILE_PROFILES:-Check,Debug,Opt}"
RUST_COMPILE_SCENARIOS="${RUST_COMPILE_SCENARIOS:-Full}"
RUST_COMPILE_CATEGORY="${RUST_COMPILE_CATEGORY:-Primary}"
RUST_COMPILE_ITERATIONS="${RUST_COMPILE_ITERATIONS:-1}"
RUST_RUNTIME_ITERATIONS="${RUST_RUNTIME_ITERATIONS:-5}"
RUST_BENCH_ID="${RUST_BENCH_ID:-boostkit-${SOFTWARE_VERSION}-base}"

# Per-architecture official tarballs with SHA-256 values taken from the
# official channel manifest (channel-rust-stable.toml, xz_hash).
RUST_TARGET_TRIPLE=""
RUST_ARCHIVE=""
RUST_ARCHIVE_SHA256=""
RUST_HOME=""
RUSTC_BIN=""
CARGO_BIN=""
RUSTC_PERF_DIR=""
RUST_DB=""
COLLECTOR_BIN=""

log_message() { printf '[rust] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    [[ "${SOFTWARE_VERSION}" == 1.99.1 ]] || { log_message "ERROR: unsupported Rust version: ${SOFTWARE_VERSION}"; return 10; }
    [[ "${EXPECTED_ARCH}" == "$(uname -m)" ]] || { log_message "ERROR: runner architecture differs from ${EXPECTED_ARCH}"; return 20; }
    case "${EXPECTED_ARCH}" in
        x86_64)
            RUST_TARGET_TRIPLE="x86_64-unknown-linux-gnu"
            RUST_ARCHIVE_SHA256="231fcae47ee950621374725b5fc3b5441d2fbda2955ac45dd7dc816d8876cfe7"
            ;;
        aarch64)
            RUST_TARGET_TRIPLE="aarch64-unknown-linux-gnu"
            RUST_ARCHIVE_SHA256="a48fb1e853be56ce9b8e2751f5464dbd5e16440cd81e237920f3a5e7e806333e"
            ;;
        *)
            log_message "ERROR: unsupported architecture: ${EXPECTED_ARCH}"; return 10 ;;
    esac
    RUST_ARCHIVE="rust-${SOFTWARE_VERSION}-${RUST_TARGET_TRIPLE}.tar.xz"
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || { log_message 'ERROR: unsafe run ID'; return 10; }
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/rust/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${CASE_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${CASE_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    TMPDIR="${PERF_WORK_DIR}/tmp"
    RUST_HOME="${PERF_WORK_DIR}/rust-install"
    RUSTC_BIN="${RUST_HOME}/bin/rustc"
    CARGO_BIN="${RUST_HOME}/bin/cargo"
    RUSTC_PERF_DIR="${PERF_WORK_DIR}/rustc-perf"
    RUST_DB="${PERF_WORK_DIR}/rustc-perf-results.db"
    COLLECTOR_BIN="${RUSTC_PERF_DIR}/target/release/collector"
    RUST_CONTAINER_NAME="boostkit-rust-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    export CARGO_HOME="${CARGO_HOME:-${PERF_WORK_DIR}/cargo}"
    export SOFTWARE_VERSION PERF_VARIANT EXPECTED_ARCH PERF_RUN_ID PERF_WORK_DIR RESULTS_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR RUST_HOME RUSTC_PERF_DIR CARGO_HOME
    export RUST_CONTAINER_NAME
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}" "${TMPDIR}" "${CARGO_HOME}"
}

load_rust_toolchain() {
    [[ -x "${RUSTC_BIN}" && -x "${CARGO_BIN}" ]] || {
        log_message "ERROR: private Rust toolchain is missing in ${RUST_HOME}"
        return 40
    }
    PATH="${RUST_HOME}/bin:${PATH}"
    export PATH
}

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else
        "$@"
    fi
}

# Direct-network runners cannot reach the overseas crates registry; point the
# task-private CARGO_HOME at a domestic sparse mirror when no proxy is set.
configure_cargo_mirror() {
    [[ -n "${PERF_PROXY:-}" ]] && return 0
    [[ -n "${RUST_CARGO_MIRROR_INDEX:-}" ]] || return 0
    local config="${CARGO_HOME}/config.toml"
    mkdir -p "${CARGO_HOME}"
    if [[ -f "${config}" ]] && grep -q 'crates.io-index' "${config}"; then
        return 0
    fi
    cat > "${config}" <<EOF
[source.crates-io]
replace-with = "ustc"

[source.ustc]
registry = "${RUST_CARGO_MIRROR_INDEX}"
EOF
    log_message "configured the container cargo registry mirror: ${RUST_CARGO_MIRROR_INDEX}"
}

require_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the Rust container'
        return 30
    fi
}

verify_rust_image_release() {
    local release
    release="$(docker run --rm --network=none "${RUST_CONTAINER_IMAGE}" cat /etc/os-release)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    if ! grep -Eq '^ID="?openEuler"?$' <<< "${release}" || \
       ! grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}"; then
        log_message 'ERROR: loaded Rust container image is not openEuler 24.03 LTS SP4'
        return 30
    fi
}

prepare_rust_container_image() {
    local archive_name="openEuler-docker.${EXPECTED_ARCH}.tar.xz"
    local archive checksum expected actual load_output image_architecture
    local image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${archive_name}"

    if [[ -s "${RUST_IMAGE_ARCHIVE_DIR}/${archive_name}" ]]; then
        archive="${RUST_IMAGE_ARCHIVE_DIR}/${archive_name}"
        log_message "using local openEuler container image archive: ${archive}"
    else
        archive="${PERF_WORK_DIR}/${archive_name}"
        log_message "downloading openEuler container image archive: ${image_url}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}" "${image_url}" || return 30
    fi

    if [[ -s "${RUST_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum" ]]; then
        checksum="${RUST_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum"
    else
        checksum="${PERF_WORK_DIR}/${archive_name}.sha256sum"
        log_message "downloading official image checksum: ${image_url}.sha256sum"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
    fi
    expected="$(awk 'NR == 1 {print $1}' "${checksum}")"
    if [[ ! "${expected}" =~ ^[[:xdigit:]]{64}$ ]]; then
        log_message "ERROR: invalid official image checksum: ${checksum}"
        return 30
    fi
    actual="$(sha256sum "${archive}")"
    if [[ "${actual%% *}" != "${expected,,}" ]]; then
        log_message "ERROR: openEuler container image checksum mismatch: ${archive}"
        return 30
    fi

    log_message "loading verified openEuler container image: ${archive}"
    load_output="$(docker load --input "${archive}")" || return 30
    RUST_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [[ -z "${RUST_CONTAINER_IMAGE}" ]] || ! docker image inspect "${RUST_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${RUST_CONTAINER_IMAGE}")"
    case "${EXPECTED_ARCH}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${EXPECTED_ARCH}"; return 30 ;;
    esac
    verify_rust_image_release || return $?
    export RUST_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${RUST_CONTAINER_IMAGE} (${image_architecture})"
}

# Create the private container. It runs until the stop stage removes it, is
# not CPU- or NUMA-pinned, uses the host network, and bind-mounts this task's
# work and result directories so every artifact stays on the host. PERFMON is
# granted because the upstream collector reads hardware performance counters
# (instructions:u/cycles:u) inside the container.
require_rust_container() {
    local -a cert_mount=()
    require_docker || return $?
    if docker container inspect "${RUST_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${RUST_CONTAINER_NAME}"
        return 40
    fi
    if [[ -z "${RUST_CONTAINER_IMAGE}" ]]; then
        prepare_rust_container_image || return $?
    fi
    if [[ -n "${PERF_PROXY:-}" ]]; then
        if [[ ! -d "${RUST_CA_ANCHORS_DIR}" ]]; then
            log_message "ERROR: proxy CA certificate directory is missing: ${RUST_CA_ANCHORS_DIR}"
            return 30
        fi
        cert_mount+=(--mount "type=bind,source=${RUST_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    log_message "starting Rust container ${RUST_CONTAINER_NAME} (host network, no CPU/NUMA pinning)"
    docker run --detach --name "${RUST_CONTAINER_NAME}" \
        --label "boostkit.rust.run-id=${PERF_RUN_ID}" \
        --network=host --cap-add=PERFMON --user "$(id -u):$(id -g)" \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" \
        "${RUST_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [[ -n "${PERF_PROXY:-}" ]]; then
        log_message 'updating CA trust in the private Rust container'
        docker exec --user 0 "${RUST_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the Rust container'
            return 30
        }
    fi
    log_message 'switching private Rust container repositories to the Huawei openEuler mirror'
    if docker exec --user 0 "${RUST_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        docker exec --user 0 "${RUST_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to update repositories in the Rust container'
            return 30
        }
    fi
}

check_rust_container() {
    [[ "$(docker inspect --format '{{.State.Running}}' "${RUST_CONTAINER_NAME}" 2>/dev/null)" == true ]] || {
        log_message "ERROR: managed Rust container is not running: ${RUST_CONTAINER_NAME}"
        return 40
    }
}

# Run a command inside the container with the host proxy forwarded when one is
# configured (git clone, cargo fetch and downloads need it).
container_exec() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec -e http_proxy="${PERF_PROXY}" -e https_proxy="${PERF_PROXY}" \
            -e TMPDIR="${TMPDIR}" -e CARGO_HOME="${CARGO_HOME}" \
            "${RUST_CONTAINER_NAME}" "$@"
    else
        docker exec -e TMPDIR="${TMPDIR}" -e CARGO_HOME="${CARGO_HOME}" \
            "${RUST_CONTAINER_NAME}" "$@"
    fi
}

container_exec_root() {
    docker exec --user 0 -e TMPDIR="${TMPDIR}" "${RUST_CONTAINER_NAME}" "$@"
}

remove_rust_container() {
    if ! docker container inspect "${RUST_CONTAINER_NAME}" >/dev/null 2>&1; then
        return 0
    fi
    if [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.rust.run-id"}}' "${RUST_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]]; then
        log_message "ERROR: refusing to remove container without this task's ownership label: ${RUST_CONTAINER_NAME}"
        return 50
    fi
    docker stop --time 30 "${RUST_CONTAINER_NAME}" >/dev/null || return 50
    docker rm "${RUST_CONTAINER_NAME}" >/dev/null || return 50
    log_message "removed managed Rust container ${RUST_CONTAINER_NAME}"
}

# Record the version reported by the installed rustc and cargo binaries; the
# full "rustc <version> (<hash> <date>)" line keeps the commit hash traceable.
record_actual_version() {
    local rustc_output cargo_output actual_version
    rustc_output="$(container_exec "${RUSTC_BIN}" --version)" || return 30
    cargo_output="$(container_exec "${CARGO_BIN}" --version)" || return 30
    actual_version="$(sed -nE 's/^rustc ([0-9]+\.[0-9]+\.[0-9]+) .*/\1/p' <<< "${rustc_output}")"
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: installed rustc reports ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 30
    }
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    printf '%s\n' "${rustc_output}" > "${PERF_WORK_DIR}/rustc-version.txt"
    printf '%s\n' "${cargo_output}" > "${PERF_WORK_DIR}/cargo-version.txt"
}
