#!/usr/bin/env bash
# Shared configuration and helpers for the GDB performance case.
#
# Everything here is architecture neutral: the parameter signature of a run only
# depends on the values recorded by scripts/results/parse_benchmark.py, and those
# must be identical on x86_64 and aarch64.  The GDB source archive checksum, the
# compiler used to build the fixtures and the built binary sizes are evidence, not
# workload parameters.
set -uo pipefail

# SCRIPT_DIR is the case root (software/Toolchain/gdb); the shell libraries live in
# scripts/.  Every entry point therefore sources scripts/common.sh relatively.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASE_DIR="${SCRIPT_DIR}"

SOFTWARE_NAME="gdb"
CATEGORY_NAME="Toolchain"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-18.1}"
EXPECTED_ARCH="${EXPECTED_ARCH:-x86_64}"
PERF_VARIANT="${PERF_VARIANT:-base}"

# ---------------------------------------------------------------- source -------
# Official GNU release archive; SHA-256 computed from the mirror download (GNU
# publishes only a detached GPG signature) and pinned here.  The signature file is
# kept next to the archive so the origin can be re-audited.
GDB_SOURCE_SHA256="cd9fc3fe2b47743840e42c1592d3d87f8302eb18639c0b8b4ba0898002e2348f"
GDB_SOURCE_SIZE=22158720
# Pre-placed offline asset directory: when it contains the pinned archive it is
# used (and verified) before any mirror is tried.
GDB_OFFLINE_DIR="${GDB_OFFLINE_DIR:-/home/runner/software/gdb}"
GDB_SOURCE_URLS=(
    "${GDB_OFFLINE_DIR}/gdb-${SOFTWARE_VERSION}.tar.xz"
    "https://mirrors.tuna.tsinghua.edu.cn/gnu/gdb/gdb-${SOFTWARE_VERSION}.tar.xz"
    "https://mirrors.ustc.edu.cn/gnu/gdb/gdb-${SOFTWARE_VERSION}.tar.xz"
    "https://ftp.gnu.org/gnu/gdb/gdb-${SOFTWARE_VERSION}.tar.xz"
)

# Build prerequisites.  The case builds GDB from source with its bundled readline
# and with the system GMP/MPFR (both are available from the distribution), and it
# disables the components that are not needed for the measured workload.
GDB_CONFIGURE_OPTIONS=(
    --disable-binutils
    --disable-gas
    --disable-ld
    --disable-gprof
    --disable-gold
    --disable-sim
    --disable-tui
    --without-guile
    --without-intel-pt
    --with-system-gmp
    --with-system-mpfr
    --disable-nls
)
GDB_BUILD_JOBS="${GDB_BUILD_JOBS:-$(nproc 2>/dev/null || echo 2)}"
GDB_MAKE_TARGETS=(all install)

# The measured `gdb` traces its own children and generates the core file, so the
# private container needs SYS_PTRACE (the default seccomp profile blocks ptrace
# without it).  The variable must exist before the container-runtime block below
# is rendered.
GDB_CONTAINER_EXTRA_ARGS=(--cap-add=SYS_PTRACE)

# Environment every in-container measurement inherits: `docker exec` only
# forwards HOME/TMPDIR/PERF_RUN_ID, so the offline/locale settings are passed
# explicitly through `env` when a measured command is started.  The array is
# built after initialize_runtime because HOME points at the private home.
GDB_MEASUREMENT_ENV=()
gdb_measurement_env_array() {
    GDB_MEASUREMENT_ENV=(
        "HOME=${GDB_PRIVATE_HOME}"
        "LC_ALL=C"
        "LANG=C"
        "TZ=UTC"
        "DEBUGINFOD_URLS="
        "DEBUGINFOD_PROGRESS=0"
        "http_proxy=http://127.0.0.1:9"
        "https_proxy=http://127.0.0.1:9"
        "HTTP_PROXY=http://127.0.0.1:9"
        "HTTPS_PROXY=http://127.0.0.1:9"
        "NO_PROXY="
        "no_proxy="
    )
}

# --------------------------------------------------------------- measurement ---
GDB_REPS="${PERF_REPS:-5}"
GDB_WARMUPS=1
# Fixture size of the deterministic workload.  The delivery load is a fixed small
# -g -O0 C program with a function breakpoint; the matrix adds larger symbol tables
# so the measurement is not an artefact of one tiny program.
GDB_SYMBOLS_SMALL=1000
GDB_SYMBOLS_MEDIUM=10000
GDB_SYMBOLS_LARGE=50000
GDB_BREAKPOINTS=200
GDB_STEPS=500
GDB_LOOKUPS=5000
GDB_DEEP_FRAMES=2000
# Fixed upstream testsuite subset (correctness + timing of the real GDB tests).
GDB_TESTSUITE_TESTS=(
    "gdb.python/py-symbol.exp"
    "gdb.python/py-value.exp"
    "gdb.base/break.exp"
)
# Minimum number of expected passes the fixed subset must report.  The exact count
# depends on the target triplet and on optional GDB features, so the parser
# requires a lower bound plus zero unexpected failures instead of an exact number.
GDB_TESTSUITE_MIN_PASSES=12

# Scenario execution order.  The authoritative description of every scenario
# (fixture, command, expected evidence) lives in the metadata file written by the
# build stage and is read by the parser; this list only drives execution.
GDB_SCENARIOS=(
    startup_version
    symbol_load_1000
    symbol_load_50000
    breakpoint_set_200
    step_500
    info_functions_10000
    python_eval_5000
    backtrace_deep_2000
    core_backtrace_2000
    upstream_testsuite_python
)

log_message() {
    printf '[gdb] [%s] %s\n' "$(date -u '+%Y-%m-%d %H:%M:%S')" "$*"
}

fail_message() {
    printf '[gdb] [%s] ERROR: %s\n' "$(date -u '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

normalize_architecture() {
    case "${EXPECTED_ARCH}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) return 1 ;;
    esac
}

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) return 0 ;;
        *)
            fail_message "unsupported variant: ${PERF_VARIANT} (expected base or optimized)"
            return 10
            ;;
    esac
}

validate_reps() {
    if ! [[ "${GDB_REPS}" =~ ^[0-9]+$ ]] || [[ "${GDB_REPS}" -lt 1 ]]; then
        fail_message "PERF_REPS must be a positive integer, got: ${GDB_REPS}"
        return 10
    fi
    if [[ "${GDB_REPS}" -gt 50 ]]; then
        fail_message "PERF_REPS is unreasonably large: ${GDB_REPS}"
        return 10
    fi
    return 0
}


scenario_kind() {
    case "$1" in
        upstream_testsuite_python) printf 'testsuite\n' ;;
        *) printf 'fixture\n' ;;
    esac
}

scenario_project() {
    case "$1" in
        startup_version) printf 'gdb\n' ;;
        symbol_load_1000) printf 'symbols_1000\n' ;;
        symbol_load_50000) printf 'symbols_50000\n' ;;
        breakpoint_set_200) printf 'symbols_50000\n' ;;
        step_500) printf 'steps_500\n' ;;
        info_functions_10000) printf 'symbols_10000\n' ;;
        python_eval_5000) printf 'symbols_50000\n' ;;
        backtrace_deep_2000) printf 'deep_2000\n' ;;
        core_backtrace_2000) printf 'deep_2000\n' ;;
        upstream_testsuite_python) printf 'testsuite\n' ;;
        *) return 1 ;;
    esac
}

# The recorded command is a description of the workload (relative, reproducible on
# both architectures); the absolute work-directory paths only exist in the raw
# per-repetition logs.
scenario_command_text() {
    case "$1" in
        startup_version) printf 'gdb --version\n' ;;
        symbol_load_1000) printf "gdb -batch -ex 'info functions fn_00042' -ex quit symbols_1000\n" ;;
        symbol_load_50000) printf "gdb -batch -ex 'info functions fn_49975' -ex quit symbols_50000\n" ;;
        breakpoint_set_200) printf 'gdb -batch -x breakpoints.cmd symbols_50000\n' ;;
        step_500) printf 'gdb -batch -x steps.cmd steps_500\n' ;;
        info_functions_10000) printf "gdb -batch -ex 'info functions' symbols_10000 | wc -l\n" ;;
        python_eval_5000) printf 'gdb -batch -x python_eval.py symbols_50000\n' ;;
        backtrace_deep_2000) printf "gdb -batch -ex 'break crash_here' -ex run -ex bt deep_2000 | wc -l\n" ;;
        core_backtrace_2000) printf 'gdb -batch -ex bt deep_2000 deep_2000.core | wc -l\n' ;;
        upstream_testsuite_python) printf 'make check-gdb RUNTESTFLAGS="gdb.python/py-symbol.exp gdb.python/py-value.exp gdb.python/py-breakpoint.exp"\n' ;;
        *) return 1 ;;
    esac
}

# Interactive scenarios that need a command file rather than -ex options.
scenario_script() {
    case "$1" in
        breakpoint_set_200) printf 'breakpoints.cmd\n' ;;
        step_500) printf 'steps.cmd\n' ;;
        python_eval_5000) printf 'python_eval.py\n' ;;
        *) return 1 ;;
    esac
}

scenario_binary() {
    case "$1" in
        symbol_load_1000) printf 'symbols_1000\n' ;;
        symbol_load_50000) printf 'symbols_50000\n' ;;
        breakpoint_set_200) printf 'symbols_50000\n' ;;
        step_500) printf 'steps_500\n' ;;
        info_functions_10000) printf 'symbols_10000\n' ;;
        python_eval_5000) printf 'symbols_50000\n' ;;
        backtrace_deep_2000) printf 'deep_2000\n' ;;
        core_backtrace_2000) printf 'deep_2000\n' ;;
        *) return 1 ;;
    esac
}

configure_runtime_paths() {
    local arch
    arch="$(normalize_architecture)" || {
        fail_message "unsupported architecture: ${EXPECTED_ARCH}"
        return 10
    }
    EXPECTED_ARCH="${arch}"
    RESULTS_DIR="${RESULTS_DIR:-${CASE_DIR}/results}"
    PERF_RUN_ID="${PERF_RUN_ID:-local-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
    if [[ -z "${PERF_WORK_DIR:-}" ]]; then
        # Standalone entry point: keep the work directory clearly marked as local so
        # that a copy of the case outside the repository cleans up only its own
        # directory.  The framework always provides PERF_WORK_DIR.
        PERF_WORK_DIR="/home/runner/boostkit-perf/${SOFTWARE_NAME}/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"

    RUNS_DIR="${RESULTS_DIR}/runs"
    GDB_SRC_DIR="${PERF_WORK_DIR}/gdb-src"
    GDB_BUILD_DIR="${PERF_WORK_DIR}/gdb-build"
    GDB_INSTALL_DIR="${PERF_WORK_DIR}/gdb-install"
    GDB_BIN="${GDB_INSTALL_DIR}/bin/gdb"
    GDB_PRIVATE_HOME="${PERF_WORK_DIR}/home"
    FIXTURES_DIR="${PERF_WORK_DIR}/fixtures"
    FIXTURE_METADATA="${PERF_WORK_DIR}/fixtures-metadata.json"
    GDB_SOURCE_ARCHIVE="${PERF_WORK_DIR}/assets/gdb-${SOFTWARE_VERSION}.tar.xz"
    GDB_SOURCE_SIGNATURE="${PERF_WORK_DIR}/assets/gdb-${SOFTWARE_VERSION}.tar.xz.sig"
    GDB_TESTS_SUM="${GDB_BUILD_DIR}/gdb/testsuite/gdb.sum"
    GDB_WORK_ASSETS="${PERF_WORK_DIR}/assets"

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR RUNS_DIR
    export PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE STANDALONE_OWNS_WORK_DIR
    export GDB_SRC_DIR GDB_BUILD_DIR GDB_INSTALL_DIR GDB_BIN GDB_PRIVATE_HOME
    export FIXTURES_DIR FIXTURE_METADATA GDB_SOURCE_ARCHIVE GDB_SOURCE_SIGNATURE
    export GDB_TESTS_SUM GDB_SOURCE_SHA256 GDB_SOURCE_SIZE GDB_OFFLINE_DIR
    GDB_FIXTURE_METADATA=${FIXTURE_METADATA}
    export GDB_FIXTURE_METADATA
    export GDB_REPS GDB_WARMUPS GDB_SYMBOLS_SMALL GDB_SYMBOLS_MEDIUM GDB_SYMBOLS_LARGE
    export GDB_BREAKPOINTS GDB_STEPS GDB_LOOKUPS GDB_DEEP_FRAMES
    export GDB_TESTSUITE_MIN_PASSES GDB_BUILD_JOBS
    return 0
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${RUNS_DIR}" "${PERF_WORK_DIR}" "${GDB_PRIVATE_HOME}" \
        "${GDB_WORK_ASSETS}" "${FIXTURES_DIR}" || {
        fail_message "failed to create the work directories under ${PERF_WORK_DIR}"
        return 20
    }
    return 0
}

# Count the committed fixture inputs (C sources, command files, Python script).  The
# measured runs must see exactly this many inputs, so a run against an incomplete
# fixture tree is rejected.
count_fixture_sources() {
    local directory="$1"
    find "${directory}" -maxdepth 1 -type f \
        \( -name '*.c' -o -name '*.h' -o -name '*.cmd' -o -name '*.py' \) \
        2>/dev/null | wc -l
}

fixture_deep_frames() {
    printf '%s\n' "${GDB_DEEP_FRAMES}"
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
GDB_IMAGE_ARCHIVE_DIR="${GDB_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
GDB_CA_ANCHORS_DIR="${GDB_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
GDB_CONTAINER_IMAGE="${GDB_CONTAINER_IMAGE:-}"
GDB_CONTAINER_NAME="${GDB_CONTAINER_NAME:-}"
GDB_CONTAINER_HOME="${GDB_CONTAINER_HOME:-}"
declare -p GDB_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || GDB_CONTAINER_EXTRA_ARGS=()

gdb_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

gdb_configure_container() {
    local arch
    arch="$(gdb_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${GDB_CONTAINER_NAME}" ] || GDB_CONTAINER_NAME="boostkit-gdb-${arch}-${PERF_RUN_ID}"
    [ -n "${GDB_CONTAINER_HOME}" ] || GDB_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export GDB_CONTAINER_NAME GDB_CONTAINER_HOME
}

gdb_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_gdb_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_gdb_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${GDB_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_gdb_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(gdb_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${GDB_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${GDB_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        gdb_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        gdb_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    GDB_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${GDB_CONTAINER_IMAGE}" ] || ! docker image inspect "${GDB_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${GDB_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_gdb_container_image_release || return $?
    export GDB_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${GDB_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_gdb_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-gdb-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${GDB_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.gdb.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_gdb_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    gdb_configure_container
    require_gdb_docker || return $?
    if docker container inspect "${GDB_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${GDB_CONTAINER_NAME}"
        return 40
    fi
    sweep_gdb_stale_containers || true
    prepare_gdb_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${GDB_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${GDB_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${GDB_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${GDB_CONTAINER_HOME}" || return 40
    log_message "starting private container ${GDB_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${GDB_CONTAINER_NAME}" \
        --label "boostkit.gdb.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${GDB_CONTAINER_EXTRA_ARGS[@]}" \
        "${GDB_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${GDB_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${GDB_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${GDB_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${GDB_CONTAINER_NAME}"
}

check_gdb_container() {
    gdb_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${GDB_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${GDB_CONTAINER_NAME}"
        return 40
    }
}

gdb_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    gdb_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${GDB_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${GDB_CONTAINER_NAME}" "$@"
}

gdb_container_exec() { gdb_docker_exec '' '' "$@"; }

gdb_container_exec_at() {
    local workdir="$1"
    shift
    gdb_docker_exec "${workdir}" '' "$@"
}

gdb_container_exec_root() { gdb_docker_exec '' root "$@"; }

gdb_container_exec_root_at() {
    local workdir="$1"
    shift
    gdb_docker_exec "${workdir}" root "$@"
}

remove_gdb_container() {
    gdb_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${GDB_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.gdb.run-id"}}' "${GDB_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${GDB_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${GDB_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${GDB_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${GDB_CONTAINER_NAME}"
}
# >>> container-runtime:end
