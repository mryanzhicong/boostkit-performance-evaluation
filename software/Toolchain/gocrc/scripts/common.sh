#!/usr/bin/env bash
# Shared configuration for the gocrc 1.24.6 CRC32 performance case.
#
# Every environment (AMD EPYC 9654 / x86_64 and Kunpeng 950 / aarch64) runs the
# exact same procedure in one private openEuler container:
#
#   1. install the official Go ${GO_BOOTSTRAP_VERSION} release at /usr/local/go
#      and prove it with `go version` (bootstrap toolchain only, never measured);
#   2. clone openEuler golang at ${GO_OPTIMIZED_BRANCH} and build it inside the
#      container with `GOOS=linux GOARCH=<amd64|arm64>
#      GOROOT_BOOTSTRAP=/usr/local/go ./make.bash`;
#   3. install benchstat with the freshly built go ${SOFTWARE_VERSION} toolchain
#      and measure the CRC32 Castagnoli microbenchmark with it.
#
# The host keeps only Docker, asset transfer/verification, git clone (git is not
# installable in the container: its dnf transaction needs a writable /etc/passwd)
# and the strict result parser.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.24.6}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

GO_OFFLINE_DIR="${GO_OFFLINE_DIR:-/home/runner/software/golang}"
GO_DOWNLOAD_MIRRORS=(
    "https://mirrors.aliyun.com/golang"
    "https://go.dev/dl"
)
# Bootstrap toolchain: official release used only to run make.bash, never measured.
GO_BOOTSTRAP_VERSION="${GO_BOOTSTRAP_VERSION:-1.23.0}"
GO_OPTIMIZED_REPO="${GO_OPTIMIZED_REPO:-https://gitcode.com/openeuler/golang.git}"
GO_OPTIMIZED_BRANCH="${GO_OPTIMIZED_BRANCH:-go1.24.6}"
GO_OPTIMIZED_VERSION="${GO_OPTIMIZED_VERSION:-1.24.6}"
GO_GOPROXY="${GO_GOPROXY:-https://repo.huaweicloud.com/repository/goproxy/|https://goproxy.cn}"

# Fixed in-container locations required by the case procedure.
GO_BOOTSTRAP_GOROOT="/usr/local/go"
GO_BOOTSTRAP_BIN="${GO_BOOTSTRAP_GOROOT}/bin/go"
GO_BOOTSTRAP_DIR="${GO_BOOTSTRAP_GOROOT}"
GO_OPTIMIZED_GOROOT="/home/local/golang"
GO_OPTIMIZED_BIN="${GO_OPTIMIZED_GOROOT}/bin/go"
GO_BENCH_FILE="benchmark_go${SOFTWARE_VERSION}.txt"

BENCH_PACKAGE="hash/crc32"
BENCH_PATTERN='CRC32/poly=Castagnoli/size=(4|32)kB'
BENCH_CPU=1
BENCH_SIZE_NAMES=("4kB" "32kB")
WARMUP_REPS="${WARMUP_REPS:-1}"
MEASURE_REPS="${MEASURE_REPS:-6}"

GO_ARCH=""
GO_SRC_DIR=""
GO_SRC_HOST_DIR=""
GO_GOPATH=""
GO_BENCHSTAT=""
GO_RUNTIME_ROOT="${GO_RUNTIME_ROOT:-}"
GO_RUNTIME_DIR=""
GCC_VERSION_STRING=""
GO_SRC_COMMIT=""
GO_BOOTSTRAP_ACTUAL_VERSION=""
GO_OPTIMIZED_ACTUAL_VERSION=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"

log_message() {
    printf '[gocrc] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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

configure_runtime_paths() {
    validate_variant || return $?
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64)
            EXPECTED_ARCH="x86_64"
            GO_ARCH="amd64"
            ;;
        aarch64|arm64)
            EXPECTED_ARCH="aarch64"
            GO_ARCH="arm64"
            ;;
        *)
            log_message "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    local runner_architecture
    runner_architecture="$(normalize_architecture "$(uname -m)")"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log_message "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi

    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="/home/runner/boostkit-perf/gocrc/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/gocrc/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    if [[ -z "${GO_RUNTIME_ROOT}" ]]; then
        GO_RUNTIME_ROOT="${PERF_WORK_DIR}/runtime"
    fi
    GO_RUNTIME_DIR="${GO_RUNTIME_ROOT}"
    # The openEuler golang source tree is cloned on the host (git is not
    # installable inside the container) and bind-mounted at /home/local/golang so
    # that `make.bash` and `go version` see the exact path from the procedure.
    GO_SRC_HOST_DIR="${PERF_WORK_DIR}/golang-src"
    GO_SRC_DIR="${GO_OPTIMIZED_GOROOT}"
    GO_GOPATH="${PERF_WORK_DIR}/home/go"
    GO_BENCHSTAT="${GO_GOPATH}/bin/benchstat"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE GO_ARCH GO_BOOTSTRAP_GOROOT GO_BOOTSTRAP_BIN GO_BOOTSTRAP_DIR
    export GO_OPTIMIZED_GOROOT GO_OPTIMIZED_BIN GO_BENCH_FILE
    export GO_SRC_DIR GO_SRC_HOST_DIR GO_GOPATH GO_BENCHSTAT
    export GO_RUNTIME_ROOT GO_RUNTIME_DIR GO_GOPROXY
}

# The private container gets the cloned openEuler golang tree at the path that
# the case procedure uses; the source directory has to exist before `docker run`
# so the bind mount can succeed.
configure_gocrc_container_mounts() {
    local existing
    if [[ -z "${GO_SRC_HOST_DIR}" ]]; then
        return 0
    fi
    if ! mkdir -p "${GO_SRC_HOST_DIR}"; then
        log_message "ERROR: cannot create the golang source directory: ${GO_SRC_HOST_DIR}"
        return 30
    fi
    for existing in "${GOCRC_CONTAINER_EXTRA_ARGS[@]}"; do
        if [[ "${existing}" == *"target=${GO_SRC_DIR}"* ]]; then
            return 0
        fi
    done
    GOCRC_CONTAINER_EXTRA_ARGS+=("--mount" "type=bind,source=${GO_SRC_HOST_DIR},target=${GO_SRC_DIR}")
}

initialize_runtime() {
    configure_runtime_paths || return $?
    if ! mkdir -p "${GO_RUNTIME_DIR}/tmp"; then
        log_message "ERROR: cannot create the Go runtime directory: ${GO_RUNTIME_DIR}"
        return 30
    fi
    export TMPDIR="${GO_RUNTIME_DIR}/tmp"
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${GO_GOPATH}" || return 30
    configure_gocrc_container_mounts || return $?
}

configure_go_environment() {
    export GOROOT="${GO_OPTIMIZED_GOROOT}"
    export PATH="${GO_OPTIMIZED_GOROOT}/bin:${GO_BOOTSTRAP_GOROOT}/bin:${GO_GOPATH}/bin:${PATH}"
    export GOCACHE="${GO_RUNTIME_DIR}/go-cache"
    export GOMODCACHE="${GO_RUNTIME_DIR}/go-mod-cache"
    export GOPATH="${GO_GOPATH}"
    export GOTOOLCHAIN=local
    export GOENV=off
    export GOWORK=off
    export GOPROXY="${GO_GOPROXY}"
    unset GOFLAGS GO111MODULE GOOS GOARCH GOAMD64 GOARM64 GOEXPERIMENT
}

# Print the exact list of commands the host needs for download/verification.
require_host_transfer_commands() {
    local command_name
    for command_name in curl tar gzip sha256sum awk python3; do
        command -v "${command_name}" >/dev/null 2>&1 || {
            log_message "WARNING: host command is missing: ${command_name}; relying on the pre-placed offline assets"
        }
    done
    return 0
}

go_release_sha256() {
    case "${GO_BOOTSTRAP_VERSION}:${GO_ARCH}" in
        1.23.0:amd64) printf '%s\n' '905a297f19ead44780548933e0ff1a1b86e8327bb459e92f9c0012569f76f5e3' ;;
        1.23.0:arm64) printf '%s\n' '62788056693009bcf7020eedc778cdd1781941c6145eab7688bd087bce0f8659' ;;
        *)
            log_message "ERROR: no verified Go release is declared for ${GO_BOOTSTRAP_VERSION} on ${GO_ARCH}"
            return 10
            ;;
    esac
}

# Host-side transfer: the offline directory wins, then the pinned mirrors; every
# candidate must match the official SHA-256 before it is used.
materialize_go_release() {
    local archive="$1" filename expected offline url downloaded=0
    filename="$(basename "${archive}")"
    offline="${GO_OFFLINE_DIR}/${filename}"
    expected="$(go_release_sha256)" || return $?

    if [[ -f "${archive}" ]]; then
        if [[ "$(sha256sum "${archive}" | awk '{print $1}')" == "${expected}" ]]; then
            log_message "reusing verified Go release archive: ${archive}"
            return 0
        fi
        log_message "discarding corrupted cached Go release archive: ${archive}"
        rm -f -- "${archive}"
    fi
    mkdir -p "$(dirname "${archive}")"
    if [[ -f "${offline}" ]]; then
        log_message "using pre-placed offline Go release archive: ${offline}"
        cp -- "${offline}" "${archive}"
        if [[ "$(sha256sum "${archive}" | awk '{print $1}')" == "${expected}" ]]; then
            return 0
        fi
        log_message "ERROR: offline Go release archive checksum mismatch: ${offline}"
        return 30
    fi
    for url in "${GO_DOWNLOAD_MIRRORS[@]}"; do
        log_message "downloading Go release archive: ${url}/${filename}"
        if ! curl -fL --retry 3 --retry-delay 2 --connect-timeout 20 --max-time 1800 \
            -o "${archive}.part" "${url}/${filename}"; then
            log_message "WARNING: download failed, trying the next mirror: ${url}"
            rm -f -- "${archive}.part"
            continue
        fi
        if [[ "$(sha256sum "${archive}.part" | awk '{print $1}')" == "${expected}" ]]; then
            mv -- "${archive}.part" "${archive}"
            downloaded=1
            break
        fi
        log_message "WARNING: checksum mismatch from ${url}, trying the next mirror"
        rm -f -- "${archive}.part"
    done
    if (( downloaded == 0 )); then
        log_message "ERROR: every Go release download source failed for ${filename}"
        return 30
    fi
    log_message "verified Go release archive $(basename "${archive}")"
}

# Install the official bootstrap Go release at /usr/local/go inside the
# container: the archive is materialized and SHA-256 verified on the host, then
# extracted as root exactly like `tar -C /usr/local -xzf go<version>.linux-<arch>.tar.gz`.
# The bootstrap toolchain only compiles the measured toolchain; it is never
# benchmarked and never reported as the case version.
install_bootstrap_go() {
    local archive expected_version version_output actual_arch actual_version
    expected_version="${GO_BOOTSTRAP_VERSION}"
    archive="${PERF_WORK_DIR}/go${GO_BOOTSTRAP_VERSION}.linux-${GO_ARCH}.tar.gz"

    materialize_go_release "${archive}" || return $?
    if ! gocrc_container_exec_root tar -C /usr/local -xzf "${archive}"; then
        log_message "ERROR: cannot extract the bootstrap Go release into /usr/local"
        return 30
    fi
    rm -f -- "${archive}"
    if ! version_output="$(gocrc_container_exec "${GO_BOOTSTRAP_BIN}" version)"; then
        log_message "ERROR: cannot execute the bootstrap Go binary: ${GO_BOOTSTRAP_BIN}"
        return 40
    fi
    if ! actual_arch="$(gocrc_container_exec "${GO_BOOTSTRAP_BIN}" env GOARCH)"; then
        log_message "ERROR: cannot read GOARCH from the bootstrap Go binary"
        return 40
    fi
    actual_arch="$(printf '%s\n' "${actual_arch}" | tr -d '[:space:]')"
    actual_version="$(printf '%s\n' "${version_output}" | awk '{print $3}' | sed 's/^go//')"
    if [[ "${actual_version}" != "${expected_version}" || "${actual_arch}" != "${GO_ARCH}" ]]; then
        log_message "ERROR: bootstrap Go is ${actual_version}/${actual_arch}, expected ${expected_version}/${GO_ARCH}"
        return 40
    fi
    GO_BOOTSTRAP_ACTUAL_VERSION="${actual_version}"
    mkdir -p "${RESULTS_DIR}" || return 40
    printf '%s\n' "${version_output}" > "${RESULTS_DIR}/bootstrap-go-version.txt" || return 40
    log_message "installed and verified bootstrap Go ${actual_version} (${GO_ARCH}) at ${GO_BOOTSTRAP_GOROOT}"
}

# Verify the measured toolchain built from the openEuler golang source at
# /home/local/golang and publish the case-version contract files.
verify_optimized_go() {
    local version_output actual_arch actual_version
    if ! version_output="$(gocrc_container_exec "${GO_OPTIMIZED_BIN}" version)"; then
        log_message "ERROR: cannot execute the openEuler golang binary: ${GO_OPTIMIZED_BIN}"
        return 40
    fi
    if ! actual_arch="$(gocrc_container_exec "${GO_OPTIMIZED_BIN}" env GOARCH)"; then
        log_message "ERROR: cannot read GOARCH from the openEuler golang binary"
        return 40
    fi
    actual_arch="$(printf '%s\n' "${actual_arch}" | tr -d '[:space:]')"
    actual_version="$(printf '%s\n' "${version_output}" | awk '{print $3}' | sed 's/^go//')"
    if [[ "${actual_version}" != "${GO_OPTIMIZED_VERSION}" || "${actual_arch}" != "${GO_ARCH}" ]]; then
        log_message "ERROR: openEuler golang is ${actual_version}/${actual_arch}, expected ${GO_OPTIMIZED_VERSION}/${GO_ARCH}"
        return 40
    fi
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: measured toolchain is ${actual_version}, case version is ${SOFTWARE_VERSION}"
        return 40
    fi
    GO_OPTIMIZED_ACTUAL_VERSION="${actual_version}"
    mkdir -p "${RESULTS_DIR}" || return 40
    printf '%s\n' "${version_output}" > "${RESULTS_DIR}/measured-go-version.txt" || return 40
    printf '%s\n' "${actual_version}" > "${RESULTS_DIR}/toolchain-version.txt" || return 40
    # The Framework owns build_info.json and requires actual-version.txt to equal
    # the requested case version (1.24.6); the bootstrap 1.23.0 identity lives in
    # bootstrap-go-version.txt and is never reported as the measured version.
    printf '%s\n' "${SOFTWARE_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40
    log_message "verified openEuler golang ${actual_version} and GOARCH ${actual_arch}"
}

# Run a Go toolchain inside the container with the exact environment of this
# run; the container does not inherit the host environment, so every variable
# that keeps caches and toolchain resolution private is passed here.
container_gocrc_exec_at() {
    local workdir="$1" go_bin="$2" goroot="$3"
    shift 3
    gocrc_container_exec_at "${workdir}" env \
        "GOROOT=${goroot}" \
        "GOCACHE=${GO_RUNTIME_DIR}/go-cache" \
        "GOMODCACHE=${GO_RUNTIME_DIR}/go-mod-cache" \
        "GOPATH=${GO_GOPATH}" \
        "GOTOOLCHAIN=local" "GOENV=off" "GOWORK=off" \
        "GOPROXY=${GO_GOPROXY:-off}" "GOSUMDB=off" \
        "${go_bin}" "$@"
}

bootstrap_go_at() {
    local workdir="$1"
    shift
    container_gocrc_exec_at "${workdir}" "${GO_BOOTSTRAP_BIN}" "${GO_BOOTSTRAP_GOROOT}" "$@"
}

optimized_go_at() {
    local workdir="$1"
    shift
    container_gocrc_exec_at "${workdir}" "${GO_OPTIMIZED_BIN}" "${GO_OPTIMIZED_GOROOT}" "$@"
}

record_gcc_identity() {
    local version_line
    version_line="$(gocrc_container_exec gcc --version 2>/dev/null | head -n 1)" || version_line=""
    if [[ -n "${version_line}" ]]; then
        GCC_VERSION_STRING="${version_line}"
        printf '%s\n' "${version_line}" > "${RESULTS_DIR}/compiler-identity.txt"
        log_message "container compiler: ${version_line}"
    fi
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
GOCRC_IMAGE_ARCHIVE_DIR="${GOCRC_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
GOCRC_CA_ANCHORS_DIR="${GOCRC_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
GOCRC_CONTAINER_IMAGE="${GOCRC_CONTAINER_IMAGE:-}"
GOCRC_CONTAINER_NAME="${GOCRC_CONTAINER_NAME:-}"
GOCRC_CONTAINER_HOME="${GOCRC_CONTAINER_HOME:-}"
declare -p GOCRC_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || GOCRC_CONTAINER_EXTRA_ARGS=()

gocrc_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

gocrc_configure_container() {
    local arch
    arch="$(gocrc_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${GOCRC_CONTAINER_NAME}" ] || GOCRC_CONTAINER_NAME="boostkit-gocrc-${arch}-${PERF_RUN_ID}"
    [ -n "${GOCRC_CONTAINER_HOME}" ] || GOCRC_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export GOCRC_CONTAINER_NAME GOCRC_CONTAINER_HOME
}

gocrc_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_gocrc_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_gocrc_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${GOCRC_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_gocrc_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(gocrc_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${GOCRC_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${GOCRC_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        gocrc_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        gocrc_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    GOCRC_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${GOCRC_CONTAINER_IMAGE}" ] || ! docker image inspect "${GOCRC_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${GOCRC_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_gocrc_container_image_release || return $?
    export GOCRC_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${GOCRC_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_gocrc_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-gocrc-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${GOCRC_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.gocrc.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_gocrc_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    gocrc_configure_container
    require_gocrc_docker || return $?
    if docker container inspect "${GOCRC_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${GOCRC_CONTAINER_NAME}"
        return 40
    fi
    sweep_gocrc_stale_containers || true
    prepare_gocrc_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${GOCRC_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${GOCRC_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${GOCRC_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${GOCRC_CONTAINER_HOME}" || return 40
    log_message "starting private container ${GOCRC_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${GOCRC_CONTAINER_NAME}" \
        --label "boostkit.gocrc.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${GOCRC_CONTAINER_EXTRA_ARGS[@]}" \
        "${GOCRC_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${GOCRC_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${GOCRC_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${GOCRC_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${GOCRC_CONTAINER_NAME}"
}

check_gocrc_container() {
    gocrc_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${GOCRC_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${GOCRC_CONTAINER_NAME}"
        return 40
    }
}

gocrc_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    gocrc_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${GOCRC_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${GOCRC_CONTAINER_NAME}" "$@"
}

gocrc_container_exec() { gocrc_docker_exec '' '' "$@"; }

gocrc_container_exec_at() {
    local workdir="$1"
    shift
    gocrc_docker_exec "${workdir}" '' "$@"
}

gocrc_container_exec_root() { gocrc_docker_exec '' root "$@"; }

gocrc_container_exec_root_at() {
    local workdir="$1"
    shift
    gocrc_docker_exec "${workdir}" root "$@"
}

remove_gocrc_container() {
    gocrc_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${GOCRC_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.gocrc.run-id"}}' "${GOCRC_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${GOCRC_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${GOCRC_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${GOCRC_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${GOCRC_CONTAINER_NAME}"
}
# >>> container-runtime:end
