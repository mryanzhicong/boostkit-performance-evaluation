#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="ultrascan"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-5.8.0}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# Verified upstream identity (gitcode.com/boostkit/Ultrascan, tag Ultrascan-v5.8.0).
ULTRASCAN_GIT_URL="${PERF_ULTRASCAN_GIT_URL:-https://gitcode.com/boostkit/Ultrascan.git}"
ULTRASCAN_GIT_MIRRORS="${PERF_ULTRASCAN_GIT_URLS:-https://gitee.com/boostkit/Ultrascan.git}"
ULTRASCAN_GIT_TAG="Ultrascan-v5.8.0"
ULTRASCAN_GIT_COMMIT="2a2ab98890e878b6ff297f2ffe4cd2e14330b498"
ULTRASCAN_SOURCE_ARCHIVE="Ultrascan-v5.8.0-2a2ab98.tar.gz"
ULTRASCAN_SOURCE_ARCHIVE_SHA256="b0ad7d0126585581e93f621d1295066e7becf6d59c2179916c74e84e67f29b9b"
ULTRASCAN_OFFLINE_DIR="${PERF_ULTRASCAN_OFFLINE_DIR:-/home/runner/software/ultrascan}"

# Intel "Hyperscan hsbench samples" package used by the documented benchmark:
# rules pcre/snort_literals and corpus corpora/gutenberg.db.  The package is
# prepared by the user (the docs extract it to /opt/Ultrascan/hsbench-samples);
# it is not an Ultrascan build product.
ULTRASCAN_SAMPLE_URL="https://cdrdv2.intel.com/v1/dl/getContent/739375"
ULTRASCAN_SAMPLE_ZIP_NAME="hsbench-samples.zip"
ULTRASCAN_SAMPLE_ZIP_SHA256="1f356096e138dda0b5e7798b028b5da5a9b4d1f15d7ec88a91a764f45b1120e6"
ULTRASCAN_SAMPLE_LITERALS_SHA256="ac54e9982237fdf81912b00e4bb182fb859b7b406d109f0593e5709eadac44ee"
ULTRASCAN_SAMPLE_GUTENBERG_SHA256="b1d621f8280cbbf0783e03af2ff21296628ca7c7c85f5ec67c6c92e8620318a6"
ULTRASCAN_SAMPLES_DIRNAME="hsbench-samples"
ULTRASCAN_DOC_SAMPLES_ROOT="/opt/Ultrascan/hsbench-samples"

ULTRASCAN_REPS="${PERF_REPS:-5}"
ULTRASCAN_WARMUPS="${PERF_ULTRASCAN_WARMUPS:-1}"
ULTRASCAN_ITERATIONS=1
ULTRASCAN_BUILD_JOBS="${PERF_ULTRASCAN_BUILD_JOBS:-}"

SOURCE_DIR=""
BUILD_DIR=""
DUMP_BUILD_DIR=""
HSBENCH_BIN=""
HSDUMP_BIN=""
DUMP_OUTPUT_ROOT=""
DUMP_DB=""
SAMPLES_ZIP_LOCAL=""
SAMPLES_ROOT=""
SAMPLES_RULES=""
SAMPLES_CORPUS=""
BUILD_STATE_FILE=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log() {
    printf '[ultrascan] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
}

# The canonical container runtime block logs through log_message; this case has
# always logged through log(), so both names share one implementation.
log_message() {
    log "$@"
}

normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    }
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/${SOFTWARE_NAME}/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    SOURCE_DIR="${PERF_WORK_DIR}/ultrascan-source"
    BUILD_DIR="${PERF_WORK_DIR}/build"
    DUMP_BUILD_DIR="${PERF_WORK_DIR}/build-debug"
    HSBENCH_BIN="${BUILD_DIR}/bin/hsbench"
    HSDUMP_BIN="${DUMP_BUILD_DIR}/bin/hsdump"
    DUMP_OUTPUT_ROOT="${PERF_WORK_DIR}/dump_output"
    DUMP_DB="${DUMP_OUTPUT_ROOT}/dump/db.raw"
    SAMPLES_ZIP_LOCAL="${PERF_WORK_DIR}/downloads/${ULTRASCAN_SAMPLE_ZIP_NAME}"
    SAMPLES_ROOT="${PERF_WORK_DIR}/${ULTRASCAN_SAMPLES_DIRNAME}"
    SAMPLES_RULES="${SAMPLES_ROOT}/pcre/snort_literals"
    SAMPLES_CORPUS="${SAMPLES_ROOT}/corpora/gutenberg.db"
    BUILD_STATE_FILE="${PERF_WORK_DIR}/build-state.json"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR
    export PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

resolve_build_jobs() {
    local jobs="${ULTRASCAN_BUILD_JOBS:-$(nproc)}"
    [[ "${jobs}" =~ ^[1-9][0-9]*$ ]] || {
        log "ERROR: build jobs must be a positive integer: ${jobs}"
        return 10
    }
    if (( jobs > 16 )); then
        jobs=16
    fi
    printf '%s\n' "${jobs}"
}

sha256_of() {
    sha256sum "$1" | awk '{print $1}'
}

check_sha256() {
    local expected="$1" path="$2" label="$3"
    [[ -f "${path}" ]] || {
        log "ERROR: ${label} is missing: ${path}"
        return 40
    }
    local actual
    actual="$(sha256_of "${path}")"
    [[ "${actual}" == "${expected}" ]] || {
        log "ERROR: ${label} SHA-256 mismatch: ${actual} != ${expected}"
        return 40
    }
}

verify_directory_is_clean() {
    local path
    for path in "$@"; do
        [[ ! -e "${path}" ]] || {
            log "ERROR: build directory is not clean under ${PERF_WORK_DIR}: ${path}"
            return 20
        }
    done
}

# ---------------------------------------------------------------------------
# Container-side build environment
# ---------------------------------------------------------------------------
# Every compiler, package and library lives inside the private openEuler
# container.  The host keeps only Docker plus the download/verification tools,
# so nothing below installs packages on the runner.
require_host_transfer_commands() {
    local missing=()
    local tool
    for tool in curl sha256sum awk; do
        command -v "${tool}" >/dev/null 2>&1 || missing+=("${tool}")
    done
    ((${#missing[@]} == 0)) && return 0
    log "WARNING: host download/verification tools are incomplete: ${missing[*]}; the pre-placed offline inputs are the only usable source"
    return 0
}

# git is intentionally absent: the container only unpacks the archive staged by
# the host, and installing git pulls dbus-daemon whose scriptlets cannot run in a
# container without systemd.  The clone fallback runs on the host instead.
ULTRASCAN_BUILD_PACKAGES=(
    cmake make gcc gcc-c++ ragel python3 boost-devel sqlite-devel
    pkgconf-pkg-config unzip tar curl coreutils diffutils findutils
    time glibc-devel glibc-common binutils which gzip util-linux
)

prepare_ultrascan_build_container() {
    local -a dnf_options=(--setopt=install_weak_deps=False)
    local tool
    require_host_transfer_commands
    require_ultrascan_docker || return 30
    start_ultrascan_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log "installing Ultrascan build dependencies inside the private container"
    ultrascan_container_exec_root dnf "${dnf_options[@]}" install -y \
        "${ULTRASCAN_BUILD_PACKAGES[@]}" || {
        log "ERROR: container build dependencies failed to install"
        return 30
    }
    for tool in cmake make c++ ragel python3 sha256sum tee sed grep awk ldd \
        tar curl unzip pkg-config diff nproc; do
        ultrascan_container_exec command -v "${tool}" >/dev/null 2>&1 || {
            log "ERROR: required build command is missing inside the container: ${tool}"
            return 30
        }
    done
    ultrascan_container_exec test -x /usr/bin/time || {
        log "ERROR: /usr/bin/time is missing inside the container"
        return 30
    }
}

# Header/library probes run as container compilations, so they describe the
# toolchain that actually builds hsbench instead of the host.
require_container_boost_headers() {
    local probe="${PERF_WORK_DIR}/probe/boost-headers.cc"
    mkdir -p "$(dirname "${probe}")"
    printf '#include <boost/version.hpp>\nint main() { return 0; }\n' > "${probe}"
    ultrascan_container_exec c++ -fsyntax-only "${probe}" >/dev/null 2>&1 || {
        log "ERROR: Boost headers are unavailable inside the private container"
        return 30
    }
}

require_container_sqlite3_dev() {
    local probe="${PERF_WORK_DIR}/probe/sqlite3-headers.c"
    mkdir -p "$(dirname "${probe}")"
    printf '#include <sqlite3.h>\nint main(void) { return sqlite3_libversion_number() > 0 ? 0 : 1; }\n' > "${probe}"
    ultrascan_container_exec c++ -fsyntax-only "${probe}" >/dev/null 2>&1 || {
        log "ERROR: SQLite 3 development files are unavailable inside the private container"
        return 30
    }
}

require_commands() {
    prepare_ultrascan_build_container || return $?
    require_container_boost_headers || return $?
    require_container_sqlite3_dev || return $?
}

check_architecture() {
    local actual expected
    actual="$(normalize_arch "$(uname -m)")"
    expected="$(normalize_arch "${EXPECTED_ARCH}")"
    [[ "${actual}" == "${expected}" ]] || {
        log "ERROR: expected architecture ${expected}, runner is ${actual}"
        return 20
    }
}

# ---------------------------------------------------------------------------
# Intel hsbench samples (user-prepared benchmark input)
# ---------------------------------------------------------------------------
prepare_samples_inputs() {
    log "staging the Intel hsbench samples package (offline copy first, then download)"
    python3 "${SCRIPT_DIR}/scripts/prepare_samples.py" download \
        --offline-dir "${ULTRASCAN_OFFLINE_DIR}" \
        --url "${ULTRASCAN_SAMPLE_URL}" \
        --sha256 "${ULTRASCAN_SAMPLE_ZIP_SHA256}" \
        --name "${ULTRASCAN_SAMPLE_ZIP_NAME}" \
        --target "${SAMPLES_ZIP_LOCAL}" || {
        log "ERROR: failed to stage the Intel hsbench samples package"
        return 30
    }
    rm -rf "${SAMPLES_ROOT}"
    log "extracting the hsbench samples inside the private container (documented path ${ULTRASCAN_DOC_SAMPLES_ROOT})"
    ultrascan_container_exec python3 "${SCRIPT_DIR}/scripts/prepare_samples.py" extract \
        --zip "${SAMPLES_ZIP_LOCAL}" \
        --dest "${SAMPLES_ROOT}" \
        --rules-sha256 "${ULTRASCAN_SAMPLE_LITERALS_SHA256}" \
        --corpus-sha256 "${ULTRASCAN_SAMPLE_GUTENBERG_SHA256}" \
        --manifest "${PERF_WORK_DIR}/samples-manifest.json" || {
        log "ERROR: failed to extract the Intel hsbench samples inside the container"
        return 30
    }
}

verify_samples_integrity() {
    ultrascan_container_exec python3 "${SCRIPT_DIR}/scripts/prepare_samples.py" verify \
        --dest "${SAMPLES_ROOT}" \
        --rules-sha256 "${ULTRASCAN_SAMPLE_LITERALS_SHA256}" \
        --corpus-sha256 "${ULTRASCAN_SAMPLE_GUTENBERG_SHA256}" || {
        log "ERROR: the hsbench samples do not match the pinned SHA-256 values"
        return 40
    }
}

# The universal bytecode database is produced by hsdump inside the container and
# its SHA-256 is recorded in build-state.json, so the measured hsbench -U run can
# only load the database this run generated.
verify_universal_db() {
    ultrascan_container_exec test -f "${DUMP_DB}" || {
        log "ERROR: the universal bytecode database is missing: ${DUMP_DB}"
        return 40
    }
    local recorded actual
    recorded="$(python3 -c \
        'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8"))["universal_bytecode"]["sha256"])' \
        "${BUILD_STATE_FILE}")" || {
        log "ERROR: build state does not record the universal bytecode SHA-256"
        return 40
    }
    actual="$(ultrascan_container_exec sha256sum "${DUMP_DB}" | awk '{print $1}')" || {
        log "ERROR: cannot read the universal bytecode database inside the container"
        return 40
    }
    [[ "${actual}" == "${recorded}" ]] || {
        log "ERROR: universal bytecode database SHA-256 mismatch: ${actual} != ${recorded}"
        return 40
    }
}

verify_measurement_inputs() {
    ultrascan_container_exec test -x "${HSBENCH_BIN}" || {
        log "ERROR: hsbench executable is unavailable: ${HSBENCH_BIN}"
        return 40
    }
    [[ -f "${BUILD_STATE_FILE}" ]] || {
        log "ERROR: build state is missing: ${BUILD_STATE_FILE}"
        return 40
    }
    verify_samples_integrity || return $?
    verify_universal_db || return $?
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
ULTRASCAN_IMAGE_ARCHIVE_DIR="${ULTRASCAN_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
ULTRASCAN_CA_ANCHORS_DIR="${ULTRASCAN_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
ULTRASCAN_CONTAINER_IMAGE="${ULTRASCAN_CONTAINER_IMAGE:-}"
ULTRASCAN_CONTAINER_NAME="${ULTRASCAN_CONTAINER_NAME:-}"
ULTRASCAN_CONTAINER_HOME="${ULTRASCAN_CONTAINER_HOME:-}"
declare -p ULTRASCAN_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || ULTRASCAN_CONTAINER_EXTRA_ARGS=()

ultrascan_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

ultrascan_configure_container() {
    local arch
    arch="$(ultrascan_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${ULTRASCAN_CONTAINER_NAME}" ] || ULTRASCAN_CONTAINER_NAME="boostkit-ultrascan-${arch}-${PERF_RUN_ID}"
    [ -n "${ULTRASCAN_CONTAINER_HOME}" ] || ULTRASCAN_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export ULTRASCAN_CONTAINER_NAME ULTRASCAN_CONTAINER_HOME
}

ultrascan_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_ultrascan_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_ultrascan_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${ULTRASCAN_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_ultrascan_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(ultrascan_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${ULTRASCAN_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${ULTRASCAN_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        ultrascan_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        ultrascan_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    ULTRASCAN_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${ULTRASCAN_CONTAINER_IMAGE}" ] || ! docker image inspect "${ULTRASCAN_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${ULTRASCAN_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_ultrascan_container_image_release || return $?
    export ULTRASCAN_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${ULTRASCAN_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_ultrascan_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-ultrascan-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${ULTRASCAN_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.ultrascan.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_ultrascan_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    ultrascan_configure_container
    require_ultrascan_docker || return $?
    if docker container inspect "${ULTRASCAN_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${ULTRASCAN_CONTAINER_NAME}"
        return 40
    fi
    sweep_ultrascan_stale_containers || true
    prepare_ultrascan_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${ULTRASCAN_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${ULTRASCAN_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${ULTRASCAN_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${ULTRASCAN_CONTAINER_HOME}" || return 40
    log_message "starting private container ${ULTRASCAN_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${ULTRASCAN_CONTAINER_NAME}" \
        --label "boostkit.ultrascan.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${ULTRASCAN_CONTAINER_EXTRA_ARGS[@]}" \
        "${ULTRASCAN_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${ULTRASCAN_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${ULTRASCAN_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${ULTRASCAN_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${ULTRASCAN_CONTAINER_NAME}"
}

check_ultrascan_container() {
    ultrascan_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${ULTRASCAN_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${ULTRASCAN_CONTAINER_NAME}"
        return 40
    }
}

ultrascan_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    ultrascan_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${ULTRASCAN_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${ULTRASCAN_CONTAINER_NAME}" "$@"
}

ultrascan_container_exec() { ultrascan_docker_exec '' '' "$@"; }

ultrascan_container_exec_at() {
    local workdir="$1"
    shift
    ultrascan_docker_exec "${workdir}" '' "$@"
}

ultrascan_container_exec_root() { ultrascan_docker_exec '' root "$@"; }

ultrascan_container_exec_root_at() {
    local workdir="$1"
    shift
    ultrascan_docker_exec "${workdir}" root "$@"
}

remove_ultrascan_container() {
    ultrascan_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${ULTRASCAN_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.ultrascan.run-id"}}' "${ULTRASCAN_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${ULTRASCAN_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${ULTRASCAN_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${ULTRASCAN_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${ULTRASCAN_CONTAINER_NAME}"
}
# >>> container-runtime:end
