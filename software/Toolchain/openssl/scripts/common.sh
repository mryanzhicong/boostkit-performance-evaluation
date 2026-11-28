#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SOFTWARE_VERSION="${SOFTWARE_VERSION:-4.1.0}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

PERF_REPS="${PERF_REPS:-5}"
OPENSSL_WARMUPS="${OPENSSL_WARMUPS:-1}"
OPENSSL_OFFLINE_DIR="${OPENSSL_OFFLINE_DIR:-/home/runner/software/openssl}"

# The workload is fixed on purpose: -seconds and -bytes must stay identical on
# every architecture and every run, so they are constants and not environment
# variables.  Only the sample count may be overridden (>= 5 to keep the
# contract, lower values are for pipeline smoke runs only).
OPENSSL_SPEED_SECONDS=2
OPENSSL_BLOCK_BYTES=16384
OPENSSL_HARNESS_JOBS="${OPENSSL_HARNESS_JOBS:-8}"
OPENSSL_TEST_FILES=402
OPENSSL_TEST_TESTS=3619

OPENSSL_CONTAINER_IMAGE="${OPENSSL_CONTAINER_IMAGE:-}"
OPENSSL_CONTAINER_NAME="${OPENSSL_CONTAINER_NAME:-}"
OPENSSL_CONTAINER_HOME="${OPENSSL_CONTAINER_HOME:-}"
declare -a OPENSSL_CONTAINER_EXTRA_ARGS=()
# Escape hatch for restricted networks: extra docker run arguments, for example
# --add-host entries when a local package mirror has to be reached by IP.
if [[ -n "${OPENSSL_DOCKER_EXTRA_ARGS:-}" ]]; then
    read -r -a OPENSSL_CONTAINER_EXTRA_ARGS <<< "${OPENSSL_DOCKER_EXTRA_ARGS}"
fi

STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

# Pinned upstream input.  The release archive is verified before it is
# unpacked; a mismatch aborts the build instead of measuring other sources.
OPENSSL_SOURCE_ARCHIVE="openssl-openssl-4.1.0.tar.gz"
# GitHub's immutable per-tag source archive of the exact release commit.  The
# release-asset CDN (release-assets.githubusercontent.com) is unreachable from
# the Blue aarch64 runner (github.com:443 times out there), while
# codeload.github.com is reachable, so the pinned input is the tag archive
# rather than the release tarball; both are the same upstream commit, and the
# build uses upstream's own ./Configure, exactly like upstream CI does on a git
# checkout.  Every candidate below is verified against the same SHA-256, so a
# mirror can never change what gets measured.
OPENSSL_SOURCE_URL="https://codeload.github.com/openssl/openssl/tar.gz/refs/tags/openssl-4.1.0"
OPENSSL_SOURCE_URLS=(
    "${OPENSSL_SOURCE_URL}"
    "https://api.github.com/repos/openssl/openssl/tarball/refs/tags/openssl-4.1.0"
    "https://github.com/openssl/openssl/archive/refs/tags/openssl-4.1.0.tar.gz"
)
OPENSSL_SOURCE_SHA256="2a54158eb6861c07cefc92f1a1d68b12d5ecc0883d53c61a092995b221c7d5fe"
OPENSSL_SOURCE_BYTES=55917193
OPENSSL_SOURCE_ROOT="openssl-openssl-4.1.0"

# Eight measured scenarios; each one is a separate `openssl speed` process.
OPENSSL_SCENARIOS=(sha256 sha512 aes_128_gcm aes_256_gcm chacha20_poly1305 rsa2048 ecdsa_p256 ed25519)
declare -A OPENSSL_SCENARIO_ARGS=(
    [sha256]='sha256'
    [sha512]='sha512'
    [aes_128_gcm]='-evp aes-128-gcm'
    [aes_256_gcm]='-evp aes-256-gcm'
    [chacha20_poly1305]='-evp chacha20-poly1305'
    [rsa2048]='rsa2048'
    [ecdsa_p256]='ecdsap256'
    [ed25519]='ed25519'
)

log_message() { printf '[openssl] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

openssl_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) log_message "ERROR: unsupported architecture: $1" >&2; return 20 ;;
    esac
}

openssl_repo_root() {
    local root
    root="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel 2>/dev/null || true)"
    if [[ -n "${root}" ]]; then
        printf '%s\n' "${root}"
    else
        printf '%s\n' "$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
    fi
}

openssl_configure_paths() {
    local arch root
    arch="$(openssl_arch "${EXPECTED_ARCH}")"
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || { log_message "ERROR: unsafe run ID: ${PERF_RUN_ID}"; return 10; }
    root="$(openssl_repo_root)"
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        if [[ "${STANDALONE_OWNS_WORK_DIR}" -eq 1 ]]; then
            PERF_WORK_DIR="${root}/.perf-work/openssl/${SOFTWARE_VERSION}/${arch}/${PERF_RUN_ID}"
        else
            PERF_WORK_DIR="/home/runner/boostkit-perf/openssl/${SOFTWARE_VERSION}/${arch}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${root}/.perf-output/Toolchain/openssl/${SOFTWARE_VERSION}/${arch}/${PERF_RUN_ID}"
    fi
    [[ "${PERF_WORK_DIR}" == /* ]] || { log_message 'ERROR: work directory must be an absolute path'; return 10; }
    [[ "${RESULTS_DIR}" == /* ]] || { log_message 'ERROR: results directory must be absolute'; return 10; }
    [[ "${PERF_WORK_DIR}" != *'/../'* && "${RESULTS_DIR}" != *'/../'* ]] || { log_message 'ERROR: directories must not contain ..'; return 10; }
    [[ "${PERF_WORK_DIR}" != "${RESULTS_DIR}" ]] || { log_message 'ERROR: work and result directories must differ'; return 10; }
    export PERF_RUN_ID PERF_WORK_DIR RESULTS_DIR SOFTWARE_VERSION PERF_VARIANT EXPECTED_ARCH
}

openssl_initialize_runtime() {
    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}"
    log_message "runtime: arch=$(openssl_arch "${EXPECTED_ARCH}") variant=${PERF_VARIANT} run_id=${PERF_RUN_ID}"
    log_message "work directory: ${PERF_WORK_DIR}"
    log_message "results directory: ${RESULTS_DIR}"
}

openssl_downloads_dir() { printf '%s/downloads\n' "${PERF_WORK_DIR}"; }
openssl_source_dir() { printf '%s/%s\n' "${PERF_WORK_DIR}" "${OPENSSL_SOURCE_ROOT}"; }
openssl_install_dir() { printf '%s/install-base\n' "${PERF_WORK_DIR}"; }
openssl_bin() { printf '%s/bin/openssl\n' "$(openssl_install_dir)"; }

openssl_verify_archive() {
    local file="$1" expected="$2" actual
    [[ -s "${file}" ]] || { log_message "ERROR: missing archive: ${file}"; return 30; }
    actual="$(sha256sum "${file}")"
    actual="${actual%% *}"
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: sha256 mismatch for ${file}: expected ${expected}, got ${actual}"
        return 30
    fi
}

# fetch_archive <name> <url> <sha256> <target-dir>
#
# The Blue runners reach the GitHub release CDN over a flaky link: a 55 MB
# tarball once stalled for 35 minutes and then died with
# "HTTP/2 stream 1 was not closed cleanly: PROTOCOL_ERROR".  Downloading is
# therefore HTTP/1.1 only, resumable, bounded by a stall detector instead of an
# unbounded wait, and retried against the official mirrors.  Every candidate is
# checked against the same pinned SHA-256, so a mirror can not change what gets
# measured.
openssl_download_curl() {
    local url="$1" dest="$2"
    local args=(
        -fSL --http1.1 --continue-at - --retry 5 --retry-all-errors --retry-delay 5
        --connect-timeout 30 --speed-limit 1024 --speed-time 60 --max-time 3600
        -o "${dest}" "${url}"
    )
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" curl "${args[@]}"
    else
        curl "${args[@]}"
    fi
}

openssl_fetch_archive() {
    local name="$1" url="$2" expected="$3" target_dir="$4" source="${OPENSSL_OFFLINE_DIR}/${1}" dest candidate
    mkdir -p "${target_dir}"
    dest="${target_dir}/${name}"
    if [[ -s "${source}" ]]; then
        log_message "using offline archive ${source}"
        cp -- "${source}" "${dest}.part" || return 30
    else
        rm -f -- "${dest}.part"
        local -a candidates=("${url}")
        if [[ "${name}" == "${OPENSSL_SOURCE_ARCHIVE}" ]]; then
            candidates=("${OPENSSL_SOURCE_URLS[@]}")
        fi
        local downloaded=0
        for candidate in "${candidates[@]}"; do
            log_message "downloading ${candidate}"
            if openssl_download_curl "${candidate}" "${dest}.part"; then
                if openssl_verify_archive "${dest}.part" "${expected}"; then
                    downloaded=1
                    break
                fi
                log_message "WARNING: archived content from ${candidate} does not match the pinned SHA-256; trying the next mirror"
                rm -f -- "${dest}.part"
            else
                log_message "WARNING: download failed from ${candidate}; trying the next mirror"
            fi
        done
        if [[ "${downloaded}" -ne 1 ]]; then
            log_message 'ERROR: every download candidate failed; the archive could not be fetched'
            rm -f -- "${dest}.part"
            return 30
        fi
    fi
    openssl_verify_archive "${dest}.part" "${expected}" || { rm -f -- "${dest}.part"; return 30; }
    mv -f -- "${dest}.part" "${dest}"
    printf '%s  %s\n' "${expected}" "${name}" >> "${target_dir}/sha256sums.txt"
    log_message "verified ${name} ($(stat -c '%s' "${dest}") bytes, sha256 ${expected})"
}

openssl_write_build_variant() {
    local variant="$1" output="${RESULTS_DIR}/build_variant.json" arch
    arch="$(openssl_arch "${EXPECTED_ARCH}")"
    local compiler version_a cflags target bin_sha source_sha
    compiler="$(openssl_container_exec bash -c 'gcc --version | head -n 1')" || compiler=unknown
    version_a="$(openssl_container_exec "$(openssl_bin)" version -a)" || {
        log_message 'ERROR: cannot read the built openssl version'
        return 40
    }
    cflags="$(openssl_container_exec bash -c 'sed -n "s/^\s*\"CFLAGS\" => \[\(.*\)\],$/\1/p" "$1/configdata.pm" | head -n 1' _ "$(openssl_source_dir)")" || cflags=""
    target="$(openssl_container_exec bash -c 'sed -n "s/^\s*\"target\" => \"\([^\"]*\)\",$/\1/p" "$1/configdata.pm" | head -n 1' _ "$(openssl_source_dir)")" || target=""
    bin_sha="$(openssl_container_exec sha256sum "$(openssl_bin)")" || return 40
    bin_sha="${bin_sha%% *}"
    source_sha="${OPENSSL_SOURCE_SHA256}"
    mkdir -p "${RESULTS_DIR}"
    python3 - "${output}" "${variant}" "${arch}" "${SOFTWARE_VERSION}" "${PERF_RUN_ID}" \
        "${OPENSSL_CONTAINER_IMAGE:-unknown}" "${compiler}" "${bin_sha}" "${source_sha}" \
        "${OPENSSL_SOURCE_BYTES}" "${target}" "${cflags}" "${version_a}" \
        "${OPENSSL_SPEED_SECONDS}" "${OPENSSL_BLOCK_BYTES}" "${OPENSSL_WARMUPS}" "${PERF_REPS}" \
        "${OPENSSL_HARNESS_JOBS}" <<'PY'
import json
import sys

(output, variant, arch, version, run_id, image, compiler, bin_sha, source_sha,
 source_bytes, target, cflags, version_a, seconds, block_bytes, warmups, reps,
 harness_jobs) = sys.argv[1:]
payload = {
    "software": "openssl",
    "variant": variant,
    "version": version,
    "architecture": arch,
    "run_id": run_id,
    "container_image": image,
    "compiler": compiler,
    "build": {
        "target": target,
        "cflags": cflags,
        "version_a": [line for line in version_a.splitlines() if line.strip()],
    },
    "archives": {
        "openssl": {"name": "openssl-openssl-4.1.0.tar.gz", "sha256": source_sha, "bytes": int(source_bytes)},
    },
    "binaries": {"openssl": bin_sha},
    "parameters": {
        "version": version,
        "variant": variant,
        "seconds": int(seconds),
        "block_bytes": int(block_bytes),
        "warmups": int(warmups),
        "reps": int(reps),
        "harness_jobs": int(harness_jobs),
        "scenarios": [
            "sha256", "sha512", "aes_128_gcm", "aes_256_gcm", "chacha20_poly1305",
            "rsa2048", "ecdsa_p256", "ed25519",
        ],
    },
}
with open(output, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, ensure_ascii=False, indent=2)
    handle.write("\n")
PY
    log_message "wrote ${output}"
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
OPENSSL_IMAGE_ARCHIVE_DIR="${OPENSSL_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
OPENSSL_CA_ANCHORS_DIR="${OPENSSL_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
OPENSSL_CONTAINER_IMAGE="${OPENSSL_CONTAINER_IMAGE:-}"
OPENSSL_CONTAINER_NAME="${OPENSSL_CONTAINER_NAME:-}"
OPENSSL_CONTAINER_HOME="${OPENSSL_CONTAINER_HOME:-}"
declare -p OPENSSL_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || OPENSSL_CONTAINER_EXTRA_ARGS=()

openssl_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

openssl_configure_container() {
    local arch
    arch="$(openssl_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${OPENSSL_CONTAINER_NAME}" ] || OPENSSL_CONTAINER_NAME="boostkit-openssl-${arch}-${PERF_RUN_ID}"
    [ -n "${OPENSSL_CONTAINER_HOME}" ] || OPENSSL_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export OPENSSL_CONTAINER_NAME OPENSSL_CONTAINER_HOME
}

openssl_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_openssl_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_openssl_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${OPENSSL_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_openssl_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(openssl_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${OPENSSL_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${OPENSSL_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        openssl_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        openssl_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    OPENSSL_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${OPENSSL_CONTAINER_IMAGE}" ] || ! docker image inspect "${OPENSSL_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${OPENSSL_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_openssl_container_image_release || return $?
    export OPENSSL_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${OPENSSL_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_openssl_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-openssl-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${OPENSSL_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.openssl.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_openssl_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    openssl_configure_container
    require_openssl_docker || return $?
    if docker container inspect "${OPENSSL_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${OPENSSL_CONTAINER_NAME}"
        return 40
    fi
    sweep_openssl_stale_containers || true
    prepare_openssl_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${OPENSSL_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${OPENSSL_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${OPENSSL_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${OPENSSL_CONTAINER_HOME}" || return 40
    log_message "starting private container ${OPENSSL_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${OPENSSL_CONTAINER_NAME}" \
        --label "boostkit.openssl.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${OPENSSL_CONTAINER_EXTRA_ARGS[@]}" \
        "${OPENSSL_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${OPENSSL_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${OPENSSL_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${OPENSSL_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${OPENSSL_CONTAINER_NAME}"
}

check_openssl_container() {
    openssl_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${OPENSSL_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${OPENSSL_CONTAINER_NAME}"
        return 40
    }
}

openssl_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    openssl_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${OPENSSL_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${OPENSSL_CONTAINER_NAME}" "$@"
}

openssl_container_exec() { openssl_docker_exec '' '' "$@"; }

openssl_container_exec_at() {
    local workdir="$1"
    shift
    openssl_docker_exec "${workdir}" '' "$@"
}

openssl_container_exec_root() { openssl_docker_exec '' root "$@"; }

openssl_container_exec_root_at() {
    local workdir="$1"
    shift
    openssl_docker_exec "${workdir}" root "$@"
}

remove_openssl_container() {
    openssl_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${OPENSSL_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.openssl.run-id"}}' "${OPENSSL_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${OPENSSL_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${OPENSSL_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${OPENSSL_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${OPENSSL_CONTAINER_NAME}"
}
# >>> container-runtime:end
