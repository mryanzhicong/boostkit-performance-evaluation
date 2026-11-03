#!/usr/bin/env bash
# Shared configuration and helpers for the SPDK bdevperf performance case.
#
# Every stage script loads this file through `source`.  It validates the
# variant, resolves the per-run private paths, and owns the pinned upstream
# source identities (SPDK, DPDK, ISA-L) plus the dependency bootstrap that is
# shared by the base build.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="spdk"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-26.09}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"

# Pinned upstream identities (verified on 2026-11-02 against the official
# GitHub source archive and the gitee mirror; both produce the same
# normalised-source-tree digest, see compute_tree_digest()).
SPDK_RELEASE_TAG="v${SOFTWARE_VERSION}"
SPDK_FULL_VERSION="26.09.0"
SPDK_TARBALL_NAME="spdk-${SPDK_RELEASE_TAG}.tar.gz"
SPDK_ARCHIVE_SHA256="b0206d47bf0859daf6b195a438d0433644bcdb0cf6dca5d143cdf285a21506dc"
SPDK_TREE_SHA256="8174a666e91dd7c3e98060346083e9eac6d3593f375520cd88c73e0d35fadaa9"
DPDK_FORK_COMMIT="37a1a9b926b4678141931f2f22e7a877b5b565c2"
DPDK_FULL_VERSION="26.03.0"
DPDK_TARBALL_NAME="dpdk-${DPDK_FORK_COMMIT}.tar.gz"
DPDK_ARCHIVE_SHA256="6b4ba309717c8ebcfb0c56922ce24ffb12227632decdd2c2f05a0279a6bf5b96"
DPDK_TREE_SHA256="e19de03312f467bd7603eb0a2fa91ae32bc71a3c270e59dfbb1334f6a3acb98d"
ISA_L_COMMIT="7c3479e0a9dac17f448603ec1ad64c7c625f530c"
ISA_L_TARBALL_NAME="isa-l-${ISA_L_COMMIT}.tar.gz"
ISA_L_ARCHIVE_SHA256="591b0d3e6a679286493fd01eaae7d6de922cbdcf6c02d4ebe6f1a8ef53600f6f"
ISA_L_TREE_SHA256="0ae8ad7907d5426f59871b697e121451855f38db36a30d75151287d7187a5bd5"

# Pre-provisioned offline package directory on the dedicated runner
# (read-only input for this case).
SPDK_OFFLINE_DIR="${PERF_SPDK_OFFLINE_DIR:-/home/runner/software/spdk}"

# Build parallelism: the local validation machine runs three independent
# builds, so the default stays at 6 and workflows can override it.
SPDK_BUILD_JOBS="${PERF_SPDK_BUILD_JOBS:-6}"

# Measurement contract.
SPDK_MEASUREMENT_REPS="${PERF_REPS:-5}"
SPDK_WARMUP_REPS="${PERF_SPDK_WARMUP_REPS:-1}"
SPDK_DURATION_SECONDS="${PERF_SPDK_DURATION:-5}"

# Default software build layout (assigned in configure_runtime_paths).
SOURCE_DIR=""
DPDK_DIR=""
ISA_L_DIR=""
BDEVPERF_BIN=""
BUILD_META_FILE=""
RUNTIME_PROFILE_FILE=""
LOG_DIR=""
SPDK_PYDEPS_DIR=""

# Diagnostics go to stderr so helper functions can still print paths on stdout.
log_message() { printf '[spdk] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*" >&2; }

# Print the tail of a helper log to the job log so failures are diagnosable
# without downloading artifacts.
flush_log_tail() {
    local file="$1" lines="${2:-40}"
    [[ -r "${file}" ]] || return 0
    log_message "---- last ${lines} lines of ${file} ----"
    tail -n "${lines}" "${file}" | sed 's/^/[spdk] [log] /' >&2 || true
    log_message "---- end of ${file} ----"
}

# Set by acquire_verified_source() for every accepted artifact.
ACQUIRED_SOURCE_ORIGIN=""
ACQUIRED_ARCHIVE_SHA256=""

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
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log_message "ERROR: PERF_RUN_ID contains unsafe characters"
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
        PERF_WORK_DIR="/home/runner/boostkit-perf/spdk/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    [[ -n "${PERF_ACTUAL_VERSION_FILE}" ]] || PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    SOURCE_DIR="${PERF_WORK_DIR}/src/spdk"
    DPDK_DIR="${SOURCE_DIR}/dpdk"
    ISA_L_DIR="${SOURCE_DIR}/isa-l"
    BDEVPERF_BIN="${SOURCE_DIR}/build/examples/bdevperf"
    BUILD_META_FILE="${PERF_WORK_DIR}/build-meta.json"
    RUNTIME_PROFILE_FILE="${PERF_WORK_DIR}/runtime.json"
    LOG_DIR="${PERF_WORK_DIR}/logs"
    SPDK_PYDEPS_DIR="${PERF_WORK_DIR}/pydeps"
    export TMPDIR="${PERF_WORK_DIR}/tmp"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}" "${TMPDIR}" "${LOG_DIR}"
}

# --- dependency bootstrap ----------------------------------------------------

# The host keeps only Docker plus the download/verification tools; every
# compiler, header and python module is installed and probed inside the private
# openEuler container, so the recorded toolchain is the one that builds SPDK.
require_host_transfer_commands() {
    local missing=() tool
    for tool in curl sha256sum awk; do
        command -v "${tool}" >/dev/null 2>&1 || missing+=("${tool}")
    done
    ((${#missing[@]} == 0)) && return 0
    log_message "WARNING: host download/verification tools are incomplete: ${missing[*]}; only the pre-provisioned offline archives are usable"
    return 0
}

detect_package_manager() {
    local os_id=""
    os_id="$(spdk_container_exec sed -n 's/^ID=//p' /etc/os-release 2>/dev/null | tr -d '"' | head -n 1)"
    case "${os_id}" in
        rhel|centos|fedora|rocky|almalinux|ol|openeuler|anolis|kylin|bclinux|uos|euleros)
            printf 'dnf\n'
            return 0
            ;;
    esac
    if spdk_container_exec command -v dnf >/dev/null 2>&1; then
        printf 'dnf\n'
    else
        printf 'unknown\n'
    fi
}

required_commands() {
    local commands=(cc gcc g++ make meson ninja pkg-config python3 tar sha256sum \
                    find sort xargs curl nproc autoconf automake libtoolize)
    if [[ "$(normalize_architecture "${EXPECTED_ARCH}")" == "x86_64" ]]; then
        # ISA-L assembles its x86 kernels with nasm; aarch64 uses gas.
        commands+=(nasm)
    fi
    printf '%s\n' "${commands[@]}"
}

missing_commands() {
    local command_name
    while IFS= read -r command_name; do
        spdk_container_exec command -v "${command_name}" >/dev/null 2>&1 || printf '%s\n' "${command_name}"
    done < <(required_commands)
}

verify_required_commands() {
    local missing=() command_name
    while IFS= read -r command_name; do
        missing+=("${command_name}")
        log_message "ERROR: required container command is missing: ${command_name}"
    done < <(missing_commands)
    (( ${#missing[@]} == 0 ))
}

# Package names that the SPDK build itself needs.  The unit tests and the apps
# are disabled for this case, so CUnit/ncurses/json-c/cmocka packages are
# intentionally not installed.
dependency_packages() {
    case "$1" in
        dnf)
            printf '%s\n' \
                gcc gcc-c++ make meson ninja-build pkgconf \
                python3 python3-devel python3-pip \
                python3-jinja2 python3-pyyaml python3-tabulate python3-pyelftools \
                autoconf automake libtool nasm \
                numactl-devel libuuid-devel libaio-devel openssl-devel \
                findutils coreutils curl tar gzip time util-linux
            ;;
        *)
            return 1
            ;;
    esac
}

# Run one package-manager transaction inside the container.  A failure is
# reported with the log tail but is not fatal: the command/module self-checks
# below decide the exit code.  Weak dependencies are disabled because their rpm
# scriptlets (groupadd/useradd of e.g. shadow/libutempter) cannot run against the
# read-only /etc/passwd the runtime block bind-mounts.
run_package_install() {
    local manager="$1"
    shift
    local log_file="${LOG_DIR}/distro-packages.log" status
    mkdir -p "${LOG_DIR}"
    set +e
    case "${manager}" in
        dnf)
            local dnf_options=(-y --skip-broken --setopt=install_weak_deps=False)
            [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
            spdk_container_exec_root dnf "${dnf_options[@]}" install "$@" > "${log_file}" 2>&1
            status=$?
            ;;
        *)
            status=1
            ;;
    esac
    set -e
    if [[ "${status}" -ne 0 ]]; then
        log_message "WARNING: ${manager} package installation exited ${status}; see ${log_file}"
        flush_log_tail "${log_file}" 20
        return "${status}"
    fi
    return 0
}

prepare_spdk_build_container() {
    require_host_transfer_commands
    require_spdk_docker || return 30
    start_spdk_container || return $?
}

install_build_dependencies() {
    local manager
    local packages=()
    manager="$(detect_package_manager)"
    if [[ "${manager}" == unknown ]]; then
        log_message 'WARNING: the container has neither dnf nor apt-get; assuming it is pre-provisioned'
    else
        mapfile -t packages < <(dependency_packages "${manager}")
        log_message "installing build dependencies inside the private container with ${manager}"
        if ! run_package_install "${manager}" "${packages[@]}"; then
            log_message 'WARNING: continuing after the failed package-manager run; the self-checks decide'
        fi
    fi
    verify_required_commands || return 30
}

# SPDK's RPC generator (scripts/genrpc.py) imports jinja2, yaml and tabulate;
# the in-tree DPDK meson build requires pyelftools
# (dpdk/buildtools/meson.build: python3_required_modules = ['elftools']).
SPDK_PYTHON_MODULES=(jinja2 yaml tabulate elftools)

python_module_package() {
    local module="$1" manager="$2"
    case "${module}" in
        jinja2)
            case "${manager}" in
                dnf) printf 'python3-jinja2\n' ;;
                pip) printf 'jinja2\n' ;;
            esac
            ;;
        yaml)
            case "${manager}" in
                dnf) printf 'python3-pyyaml\n' ;;
                pip) printf 'PyYAML\n' ;;
            esac
            ;;
        tabulate)
            case "${manager}" in
                dnf) printf 'python3-tabulate\n' ;;
                pip) printf 'tabulate\n' ;;
            esac
            ;;
        elftools)
            case "${manager}" in
                dnf) printf 'python3-pyelftools\n' ;;
                pip) printf 'pyelftools\n' ;;
            esac
            ;;
        *)
            return 1
            ;;
    esac
}

python_imports_modules() {
    local interpreter="$1"
    spdk_container_exec "${interpreter}" -c \
        "import $(printf '%s,' "${SPDK_PYTHON_MODULES[@]}" | sed 's/,$//')" \
        >/dev/null 2>&1
}

python_modules_missing() {
    local interpreter="$1" module
    for module in "${SPDK_PYTHON_MODULES[@]}"; do
        spdk_container_exec "${interpreter}" -c "import ${module}" >/dev/null 2>&1 || printf '%s\n' "${module}"
    done
}

pip_capable_interpreter() {
    spdk_container_exec python3 -m pip --version >/dev/null 2>&1 && {
        printf 'python3\n'
        return 0
    }
    return 1
}

pip_install_modules() {
    local interpreter="$1" index="$2"
    shift 2
    local -a pip_args=(install --disable-pip-version-check --no-cache-dir --retries 2 --timeout 30)
    # PEP 668 managed environments reject root installs; the flag only exists on
    # newer pip releases, so probe for it first.
    if spdk_container_exec "${interpreter}" -m pip --help 2>/dev/null | grep -q -- '--break-system-packages'; then
        pip_args+=(--break-system-packages)
    fi
    pip_args+=(--index-url "${index}" "$@")
    spdk_container_exec_root "${interpreter}" -m pip "${pip_args[@]}" \
        >> "${LOG_DIR}/pip-install.log" 2>&1
}

install_python_modules_with_pip() {
    local missing=("$@") interpreter index status module
    local pip_names=()
    mkdir -p "${LOG_DIR}"
    interpreter="$(pip_capable_interpreter)" || {
        log_message 'WARNING: the container python3 has no pip for the module fallback'
        return 1
    }
    for module in "${missing[@]}"; do
        pip_names+=("$(python_module_package "${module}" pip)")
    done
    : > "${LOG_DIR}/pip-install.log"
    for index in "https://pypi.tuna.tsinghua.edu.cn/simple" \
                 "https://mirrors.huaweicloud.com/repository/pypi/simple" \
                 "https://pypi.org/simple"; do
        log_message "installing python modules in the container from ${index}: ${pip_names[*]}"
        set +e
        pip_install_modules "${interpreter}" "${index}" "${pip_names[@]}"
        status=$?
        set -e
        if [[ "${status}" -eq 0 ]] && python_imports_modules "${interpreter}"; then
            log_message "python modules available via pip in the container (${index})"
            return 0
        fi
        if [[ "${status}" -ne 0 ]]; then
            flush_log_tail "${LOG_DIR}/pip-install.log" 20
        fi
    done
    flush_log_tail "${LOG_DIR}/pip-install.log" 40
    return 1
}

ensure_python_modules() {
    local missing=() manager package_names=() module package
    mapfile -t missing < <(python_modules_missing python3)
    if (( ${#missing[@]} == 0 )); then
        return 0
    fi
    log_message "the container python3 lacks: ${missing[*]}"
    manager="$(detect_package_manager)"
    if [[ "${manager}" != unknown ]]; then
        for module in "${missing[@]}"; do
            package="$(python_module_package "${module}" "${manager}")" || continue
            package_names+=("${package}")
        done
        if (( ${#package_names[@]} )); then
            log_message "installing container python packages with ${manager}: ${package_names[*]}"
            run_package_install "${manager}" "${package_names[@]}" || true
            mapfile -t missing < <(python_modules_missing python3)
            if (( ${#missing[@]} == 0 )); then
                return 0
            fi
        fi
    fi
    log_message "falling back to pip inside the container for: ${missing[*]}"
    if install_python_modules_with_pip "${missing[@]}"; then
        return 0
    fi
    log_message "ERROR: cannot provide the python modules required by the SPDK build: ${missing[*]}"
    log_message "ERROR:   required modules: ${SPDK_PYTHON_MODULES[*]}"
    log_message "ERROR:   container python3: $(spdk_container_exec python3 -V 2>&1 || true)"
    log_message "ERROR:   install python3-jinja2 python3-pyyaml python3-tabulate python3-pyelftools in the image"
    flush_log_tail "${LOG_DIR}/distro-packages.log" 20
    flush_log_tail "${LOG_DIR}/pip-install.log" 20
    return 30
}

# --- verified source acquisition --------------------------------------------

compute_tree_digest() {
    local root="$1"
    # The digest must describe the tree the container builds, and find/sort/xargs
    # live in the image, so both hashing passes run there.
    spdk_container_exec bash -c \
        "cd '${root}' && find . -type f -print0 | LC_ALL=C sort -z | xargs -0 -n 200 sha256sum | sha256sum | cut -d' ' -f1"
}

fetch_archive() {
    local url="$1" output="$2"
    local curl_options=(-fSL --retry 2 --connect-timeout 20 --max-time 900)
    if [[ -n "${PERF_PROXY:-}" ]]; then
        curl "${curl_options[@]}" --proxy "${PERF_PROXY}" -o "${output}" "${url}"
    else
        curl "${curl_options[@]}" -o "${output}" "${url}"
    fi
}

# verify_and_extract ARCHIVE EXPECTED_TREE_SHA WORK_ROOT
# Prints the single extracted source root on success.
verify_and_extract() {
    local archive="$1" expected_tree="$2" work_root="$3" digest entries=()
    rm -rf "${work_root}"
    mkdir -p "${work_root}"
    log_message "extracting $(basename "${archive}") inside the private container"
    spdk_container_exec tar -xzf "${archive}" -C "${work_root}" || {
        log_message "ERROR: cannot extract ${archive}"
        return 1
    }
    mapfile -t entries < <(spdk_container_exec find "${work_root}" -mindepth 1 -maxdepth 1)
    if (( ${#entries[@]} != 1 )) || [[ ! -d "${entries[0]}" ]]; then
        log_message "ERROR: archive ${archive} does not contain exactly one source directory"
        return 1
    fi
    digest="$(compute_tree_digest "${entries[0]}")" || return 1
    if [[ "${digest}" != "${expected_tree}" ]]; then
        log_message "ERROR: source tree sha256 ${digest} does not match the pinned ${expected_tree}"
        return 1
    fi
    printf '%s\n' "${entries[0]}"
}

# acquire_verified_source LABEL EXPECTED_TREE_SHA DEST WORK_ROOT CANDIDATES...
# Each candidate is "file:/path" or "url:https://...".  Every candidate is
# verified against the same pinned normalised-source-tree SHA-256 before it is
# accepted, so byte-level repacking by a mirror does not skip verification.
acquire_verified_source() {
    local label="$1" expected_tree="$2" destination="$3" work_root="$4"
    shift 4
    local candidate kind value archive downloaded extracted attempt_log=() record_archive_sha=""
    mkdir -p "${work_root}"
    archive="${work_root}/$(basename "${work_root}").tar.gz"
    for candidate in "$@"; do
        kind="${candidate%%:*}"
        value="${candidate#*:}"
        attempt_log+=("${candidate}")
        log_message "[${label}] trying ${candidate}"
        downloaded=0
        case "${kind}" in
            file)
                if [[ -f "${value}" ]]; then
                    cp -f -- "${value}" "${archive}" && downloaded=1
                else
                    log_message "[${label}] offline package not present: ${value}"
                fi
                ;;
            url)
                if fetch_archive "${value}" "${archive}"; then
                    downloaded=1
                else
                    log_message "[${label}] download failed: ${value}"
                fi
                ;;
            *)
                log_message "[${label}] unsupported candidate kind: ${kind}"
                ;;
        esac
        if [[ "${downloaded}" -ne 1 ]]; then
            continue
        fi
        record_archive_sha="$(sha256sum "${archive}" | cut -d' ' -f1)"
        if extracted="$(verify_and_extract "${archive}" "${expected_tree}" "${work_root}/extract")"; then
            log_message "[${label}] accepted ${value} (archive sha256 ${record_archive_sha})"
            rm -rf "${destination}"
            mkdir -p "$(dirname "${destination}")"
            if ! mv -- "${extracted}" "${destination}"; then
                log_message "[${label}] ERROR: cannot move the verified source tree to ${destination}"
                return 1
            fi
            ACQUIRED_SOURCE_ORIGIN="${value}"
            ACQUIRED_ARCHIVE_SHA256="${record_archive_sha}"
            return 0
        fi
        log_message "[${label}] rejected ${value}: content does not match the pinned tree sha256"
    done
    log_message "ERROR: no verified ${label} source available; every candidate failed:"
    local attempted
    for attempted in "${attempt_log[@]}"; do
        log_message "  attempted: ${attempted}"
    done
    return 30
}

# --- runtime environment inspection -----------------------------------------

memory_info_kib() {
    local key="$1"
    awk -v key="${key}" '$1 == key ":" { print $2 }' /proc/meminfo 2>/dev/null || printf '0\n'
}

hugepage_snapshot_json() {
    local total free hugepage_size
    total="$(memory_info_kib HugePages_Total)"
    free="$(memory_info_kib HugePages_Free)"
    hugepage_size="$(memory_info_kib Hugepagesize)"
    printf '{"total_pages":%s,"free_pages":%s,"hugepage_size_kib":%s}' \
        "${total:-0}" "${free:-0}" "${hugepage_size:-0}"
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
SPDK_IMAGE_ARCHIVE_DIR="${SPDK_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
SPDK_CA_ANCHORS_DIR="${SPDK_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
SPDK_CONTAINER_IMAGE="${SPDK_CONTAINER_IMAGE:-}"
SPDK_CONTAINER_NAME="${SPDK_CONTAINER_NAME:-}"
SPDK_CONTAINER_HOME="${SPDK_CONTAINER_HOME:-}"
declare -p SPDK_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || SPDK_CONTAINER_EXTRA_ARGS=()

spdk_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

spdk_configure_container() {
    local arch
    arch="$(spdk_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${SPDK_CONTAINER_NAME}" ] || SPDK_CONTAINER_NAME="boostkit-spdk-${arch}-${PERF_RUN_ID}"
    [ -n "${SPDK_CONTAINER_HOME}" ] || SPDK_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export SPDK_CONTAINER_NAME SPDK_CONTAINER_HOME
}

spdk_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_spdk_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_spdk_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${SPDK_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_spdk_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(spdk_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${SPDK_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${SPDK_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        spdk_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        spdk_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    SPDK_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${SPDK_CONTAINER_IMAGE}" ] || ! docker image inspect "${SPDK_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${SPDK_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_spdk_container_image_release || return $?
    export SPDK_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${SPDK_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_spdk_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-spdk-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${SPDK_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.spdk.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_spdk_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    spdk_configure_container
    require_spdk_docker || return $?
    if docker container inspect "${SPDK_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${SPDK_CONTAINER_NAME}"
        return 40
    fi
    sweep_spdk_stale_containers || true
    prepare_spdk_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${SPDK_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${SPDK_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${SPDK_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${SPDK_CONTAINER_HOME}" || return 40
    log_message "starting private container ${SPDK_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${SPDK_CONTAINER_NAME}" \
        --label "boostkit.spdk.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${SPDK_CONTAINER_EXTRA_ARGS[@]}" \
        "${SPDK_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${SPDK_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${SPDK_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${SPDK_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${SPDK_CONTAINER_NAME}"
}

check_spdk_container() {
    spdk_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${SPDK_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${SPDK_CONTAINER_NAME}"
        return 40
    }
}

spdk_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    spdk_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${SPDK_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${SPDK_CONTAINER_NAME}" "$@"
}

spdk_container_exec() { spdk_docker_exec '' '' "$@"; }

spdk_container_exec_at() {
    local workdir="$1"
    shift
    spdk_docker_exec "${workdir}" '' "$@"
}

spdk_container_exec_root() { spdk_docker_exec '' root "$@"; }

spdk_container_exec_root_at() {
    local workdir="$1"
    shift
    spdk_docker_exec "${workdir}" root "$@"
}

remove_spdk_container() {
    spdk_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${SPDK_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.spdk.run-id"}}' "${SPDK_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${SPDK_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${SPDK_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${SPDK_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${SPDK_CONTAINER_NAME}"
}
# >>> container-runtime:end
