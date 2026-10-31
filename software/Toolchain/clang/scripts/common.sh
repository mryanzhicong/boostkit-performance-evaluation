#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASE_DIR="${SCRIPT_DIR}"
SOFTWARE_NAME="clang"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-23.1.4}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"

# LLVM download endpoint. Proxy runners use the official GitHub release;
# direct-network runners (Blue) use the TUNA github-release mirror. An
# explicit LLVM_ARCHIVE_URL or LLVM_RELEASE_BASE overrides the selection.
LLVM_RELEASE_BASE="${LLVM_RELEASE_BASE:-}"
LLVM_ARCHIVE_URL="${LLVM_ARCHIVE_URL:-}"

# Fixed benchmark workload from the official SQLite release area. SQLite
# publishes SHA3-256 checksums (not SHA-256), verified through python3.
# There is no verified domestic SQLite mirror, so direct-network runners must
# provide the two archives offline unless SQLITE_BENCHMARK_BASE is set.
if [[ -n "${SQLITE_BENCHMARK_BASE:-}" ]]; then
    :
elif [[ -n "${PERF_PROXY:-}" ]]; then
    SQLITE_BENCHMARK_BASE="https://www.sqlite.org/2026"
else
    SQLITE_BENCHMARK_BASE=""
fi
SQLITE_AMALGAMATION_PACKAGE="${SQLITE_AMALGAMATION_PACKAGE:-sqlite-amalgamation-3540100.zip}"
SQLITE_AMALGAMATION_SHA3_256="${SQLITE_AMALGAMATION_SHA3_256:-92281c86e2957f9b9305890f9ac04204caa7b677cc868dc326d942689df28e30}"
SQLITE_SOURCE_PACKAGE="${SQLITE_SOURCE_PACKAGE:-sqlite-src-3540100.zip}"
SQLITE_SOURCE_SHA3_256="${SQLITE_SOURCE_SHA3_256:-877c6f4996ce7adb368686bce21638de9e3d91534832ad3d9d119037d1bc22ad}"
SQLITE_BENCHMARK_VERSION="${SQLITE_BENCHMARK_VERSION:-3.54.1}"
CLANG_ARCHIVE_DIR="${CLANG_ARCHIVE_DIR:-/home/runner/software/clang}"

# openEuler container runtime (same base image and loading method as MySQL).
CLANG_IMAGE_ARCHIVE_DIR="${CLANG_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
CLANG_CA_ANCHORS_DIR="${CLANG_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
CLANG_CONTAINER_IMAGE=""
CLANG_CONTAINER_NAME=""

# Formal workload: three compile options over the SQLite amalgamation and
# two speedtest1 database sizes, five rounds each.
CLANG_ROUNDS="${CLANG_ROUNDS:-5}"
CLANG_COMPILE_OPTIONS=("-O0" "-O2" "-Os")
CLANG_SPEEDTEST_SIZES=(100000 500000)

# Lifecycle paths (assigned in configure_runtime_paths).
LLVM_ROOT=""
CLANG_BIN=""
CLANGXX_BIN=""
BENCHMARK_DIR=""
AMALGAMATION_DIR=""
SQLITE_SOURCE_DIR=""
SQLITE3_C=""
SQLITE3_H=""
SPEEDTEST1_C=""
SPEEDTEST1_BIN=""

# Logs go to stderr so helper functions can return file paths on stdout.
log_message() { printf '[clang] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*" >&2; }

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

llvm_archive_for_version() {
    case "${SOFTWARE_VERSION}:${EXPECTED_ARCH}" in
        23.1.4:x86_64)
            LLVM_ARCHIVE_NAME="LLVM-23.1.4-Linux-X64.tar.xz"
            LLVM_ARCHIVE_SHA256="25d814fda50d5fb0084b42be09605d8b1595d49d5e2e03a3345d7e112ff6f9f3"
            ;;
        23.1.4:aarch64)
            LLVM_ARCHIVE_NAME="LLVM-23.1.4-Linux-ARM64.tar.xz"
            LLVM_ARCHIVE_SHA256="9b27cf263d711aa6ebfd4045ab241d947bd09b3cd19ffa5728f48a80c9eb3a91"
            ;;
        *)
            log_message "ERROR: no verified LLVM release is declared for ${SOFTWARE_VERSION} on ${EXPECTED_ARCH}"
            return 10
            ;;
    esac
    if [[ -n "${LLVM_ARCHIVE_URL}" ]]; then
        return 0
    fi
    if [[ -n "${PERF_PROXY:-}" || -n "${LLVM_RELEASE_BASE}" ]]; then
        LLVM_ARCHIVE_URL="${LLVM_RELEASE_BASE:-https://github.com/llvm/llvm-project/releases/download}/llvmorg-${SOFTWARE_VERSION}/${LLVM_ARCHIVE_NAME}"
    else
        LLVM_ARCHIVE_URL="https://mirrors.tuna.tsinghua.edu.cn/github-release/llvm/llvm-project/LLVM%20${SOFTWARE_VERSION}/${LLVM_ARCHIVE_NAME}"
    fi
}

configure_runtime_paths() {
    validate_variant || return $?
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64) EXPECTED_ARCH="x86_64" ;;
        aarch64|arm64) EXPECTED_ARCH="aarch64" ;;
        *) log_message "ERROR: unsupported architecture: ${EXPECTED_ARCH}"; return 10 ;;
    esac
    [[ "${EXPECTED_ARCH}" == "$(uname -m)" ]] || {
        log_message "ERROR: runner architecture differs from ${EXPECTED_ARCH}"
        return 20
    }
    llvm_archive_for_version || return $?
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log_message 'ERROR: unsafe run ID'
        return 10
    }
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/clang/local-${PERF_RUN_ID}"
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
    LLVM_ROOT="${PERF_WORK_DIR}/llvm"
    CLANG_BIN="${LLVM_ROOT}/bin/clang"
    CLANGXX_BIN="${LLVM_ROOT}/bin/clang++"
    BENCHMARK_DIR="${PERF_WORK_DIR}/benchmark"
    AMALGAMATION_DIR="${BENCHMARK_DIR}/amalgamation"
    SQLITE_SOURCE_DIR="${BENCHMARK_DIR}/sqlite-src"
    SPEEDTEST1_BIN="${BENCHMARK_DIR}/speedtest1"
    SQLITE3_C="${AMALGAMATION_DIR}/sqlite3.c"
    SQLITE3_H="${AMALGAMATION_DIR}/sqlite3.h"
    SPEEDTEST1_C="${SQLITE_SOURCE_DIR}/speedtest1.c"
    export SOFTWARE_VERSION PERF_VARIANT EXPECTED_ARCH PERF_RUN_ID PERF_WORK_DIR RESULTS_DIR
    CLANG_CONTAINER_NAME="boostkit-clang-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    export PERF_ACTUAL_VERSION_FILE TMPDIR CLANG_CONTAINER_NAME
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}" "${TMPDIR}"
}

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else
        "$@"
    fi
}

verify_sha256() {
    local file_path="$1" expected="$2" actual
    actual="$(sha256sum "${file_path}" | cut -d' ' -f1)"
    [[ "${actual}" == "${expected}" ]] || {
        log_message "ERROR: checksum mismatch for ${file_path}: expected ${expected}, got ${actual}"
        return 30
    }
}

verify_sha3_256() {
    local file_path="$1" expected="$2" actual
    actual="$(python3 - "${file_path}" <<'PY'
import hashlib
import sys

with open(sys.argv[1], "rb") as archive:
    print(hashlib.sha3_256(archive.read()).hexdigest())
PY
)"
    [[ "${actual}" == "${expected}" ]] || {
        log_message "ERROR: SHA3-256 mismatch for ${file_path}: expected ${expected}, got ${actual}"
        return 30
    }
}

require_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the Clang container'
        return 30
    fi
}

verify_clang_image_release() {
    local release
    release="$(docker run --rm --network=none "${CLANG_CONTAINER_IMAGE}" cat /etc/os-release)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    if ! grep -Eq '^ID="?openEuler"?$' <<< "${release}" || \
       ! grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "${release}"; then
        log_message 'ERROR: loaded Clang container image is not openEuler 24.03 LTS SP4'
        return 30
    fi
}

prepare_clang_container_image() {
    local archive_name="openEuler-docker.${EXPECTED_ARCH}.tar.xz"
    local archive checksum expected actual load_output image_architecture
    local image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/${archive_name}"

    if [[ -s "${CLANG_IMAGE_ARCHIVE_DIR}/${archive_name}" ]]; then
        archive="${CLANG_IMAGE_ARCHIVE_DIR}/${archive_name}"
        log_message "using local openEuler container image archive: ${archive}"
    else
        archive="${PERF_WORK_DIR}/${archive_name}"
        log_message "downloading openEuler container image archive: ${image_url}"
        with_network_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}" "${image_url}" || return 30
    fi

    if [[ -s "${CLANG_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum" ]]; then
        checksum="${CLANG_IMAGE_ARCHIVE_DIR}/${archive_name}.sha256sum"
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
    CLANG_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [[ -z "${CLANG_CONTAINER_IMAGE}" ]] || ! docker image inspect "${CLANG_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${CLANG_CONTAINER_IMAGE}")"
    case "${EXPECTED_ARCH}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *) log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${EXPECTED_ARCH}"; return 30 ;;
    esac
    verify_clang_image_release || return $?
    export CLANG_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${CLANG_CONTAINER_IMAGE} (${image_architecture})"
}

# One private container per run: host network, no CPU/NUMA pinning, work and
# result directories bind-mounted at their host paths.
require_clang_container() {
    local -a cert_mount=()
    require_docker || return $?
    if docker container inspect "${CLANG_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${CLANG_CONTAINER_NAME}"
        return 40
    fi
    if [[ -z "${CLANG_CONTAINER_IMAGE}" ]]; then
        prepare_clang_container_image || return $?
    fi
    if [[ -n "${PERF_PROXY:-}" ]]; then
        if [[ ! -d "${CLANG_CA_ANCHORS_DIR}" ]]; then
            log_message "ERROR: proxy CA certificate directory is missing: ${CLANG_CA_ANCHORS_DIR}"
            return 30
        fi
        cert_mount+=(--mount "type=bind,source=${CLANG_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    log_message "starting Clang container ${CLANG_CONTAINER_NAME} (host network, no CPU/NUMA pinning)"
    docker run --detach --name "${CLANG_CONTAINER_NAME}" \
        --label "boostkit.clang.run-id=${PERF_RUN_ID}" \
        --network=host --user "$(id -u):$(id -g)" \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" \
        "${CLANG_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [[ -n "${PERF_PROXY:-}" ]]; then
        log_message 'updating CA trust in the private Clang container'
        docker exec --user 0 "${CLANG_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the Clang container'
            return 30
        }
    fi
    log_message 'switching private Clang container repositories to the Huawei openEuler mirror'
    if docker exec --user 0 "${CLANG_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        docker exec --user 0 "${CLANG_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to update repositories in the Clang container'
            return 30
        }
    fi
}

check_clang_container() {
    [[ "$(docker inspect --format '{{.State.Running}}' "${CLANG_CONTAINER_NAME}" 2>/dev/null)" == true ]] || {
        log_message "ERROR: managed Clang container is not running: ${CLANG_CONTAINER_NAME}"
        return 40
    }
}

container_exec() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec -e http_proxy="${PERF_PROXY}" -e https_proxy="${PERF_PROXY}" \
            -e TMPDIR="${TMPDIR}" "${CLANG_CONTAINER_NAME}" "$@"
    else
        docker exec -e TMPDIR="${TMPDIR}" "${CLANG_CONTAINER_NAME}" "$@"
    fi
}

container_exec_root() {
    docker exec --user 0 -e TMPDIR="${TMPDIR}" "${CLANG_CONTAINER_NAME}" "$@"
}

remove_clang_container() {
    if ! docker container inspect "${CLANG_CONTAINER_NAME}" >/dev/null 2>&1; then
        return 0
    fi
    if [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.clang.run-id"}}' "${CLANG_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]]; then
        log_message "ERROR: refusing to remove container without this task's ownership label: ${CLANG_CONTAINER_NAME}"
        return 50
    fi
    docker stop --time 30 "${CLANG_CONTAINER_NAME}" >/dev/null || return 50
    docker rm "${CLANG_CONTAINER_NAME}" >/dev/null || return 50
    log_message "removed managed Clang container ${CLANG_CONTAINER_NAME}"
}
