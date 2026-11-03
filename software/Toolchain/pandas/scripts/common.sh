#!/usr/bin/env bash
#
# Shared configuration and helpers for the pandas case.
#
# The case measures the upstream pandas asv benchmark suite of the pinned
# release.  Every input that is compared across architectures is fixed here:
# the CPython patch release, the pinned runtime wheels, the upstream benchmark
# snapshot, the single-thread settings, the repetition count and the offline
# policy.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="pandas"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-3.1.0}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# ---------------------------------------------------------------------------
# Pinned Python runtime.  The exact patch release is built from the official
# source archive so both architectures execute the same interpreter.
# ---------------------------------------------------------------------------
PYTHON_VERSION="3.12.16"
PYTHON_SHA256="710c3e75dac8b2f258d9cd0f76e5c4c2e9175fac9e249c98901552f7cf33b7dd"
PYTHON_BYTES="27310261"
PYTHON_TARBALL="Python-${PYTHON_VERSION}.tgz"
# Mirror order: offline directory, then the mirrors that were verified to serve
# the identical archive (same SHA-256 from Huawei Cloud and Aliyun).
PYTHON_URLS=(
    "https://mirrors.huaweicloud.com/python/${PYTHON_VERSION}/${PYTHON_TARBALL}"
    "https://mirrors.aliyun.com/python-release/source/${PYTHON_VERSION}/${PYTHON_TARBALL}"
    "https://mirror.nju.edu.cn/python/${PYTHON_VERSION}/${PYTHON_TARBALL}"
)
PYTHON_CONFIGURE_OPTIONS=(--with-ensurepip=install)

# ---------------------------------------------------------------------------
# Pinned pandas release and runtime wheels.  pandas 3.1.0 requires
# numpy>=2.0.2, python-dateutil>=2.9.0 and six (dateutil dependency).
# ---------------------------------------------------------------------------
PANDAS_SDIST="pandas-${SOFTWARE_VERSION}.tar.gz"
PANDAS_SDIST_SHA256="ecb9b2d8a817b1e1ba1fdb90c0abe9eab31b4fdf2562b7a56b86ac66ace17e49"
PANDAS_SDIST_BYTES="5933421"
PANDAS_SDIST_URLS=(
    "https://files.pythonhosted.org/packages/source/p/pandas/${PANDAS_SDIST}"
)
PANDAS_WHEELS=(
    "numpy==2.0.2"
    "python-dateutil==2.9.0.post0"
    "six==1.17.0"
    "pandas==${SOFTWARE_VERSION}"
)
PANDAS_OFFLINE_DIR="${PERF_PANDAS_OFFLINE_DIR:-/home/runner/software/pandas}"
PANDAS_OFFLINE_WHEELS_SUBDIR="wheels"
PANDAS_REQUIREMENTS_LOCK="${SCRIPT_DIR}/requirements.lock"

# pip falls back through these indexes when the offline wheelhouse is absent.
# TUNA, Huawei Cloud and Aliyun were verified to serve every pinned wheel; the
# public index is kept as the last resort because it is not always reachable.
PANDAS_PIP_INDEXES=(
    "https://pypi.tuna.tsinghua.edu.cn/simple"
    "https://mirrors.huaweicloud.com/repository/pypi/simple"
    "https://mirrors.aliyun.com/pypi/simple"
    "https://pypi.org/simple"
)

# ---------------------------------------------------------------------------
# Upstream asv benchmark snapshot (vendored byte-identical copy).
# ---------------------------------------------------------------------------
ASV_TAG="v${SOFTWARE_VERSION}"
ASV_TAG_COMMIT="c6f46769b808eb60218189d089dd67841b44f1b9"
ASV_REPOSITORY="https://github.com/pandas-dev/pandas"
ASV_SUITE="asv_bench/benchmarks"
ASV_PROFILE="benchmark"
PANDAS_SCENARIOS=(
    groupby_sort_high_cardinality
    groupby_int64_overflow
    join_single_key
    merge_asof_int
    stat_ops_frame_skew
    rolling_mean_window
    drop_duplicates_int
    reshape_unstack
    strings_upper
)

BUILD_JOBS="${PERF_BUILD_JOBS:-$(nproc)}"
PANDAS_REPS="${PERF_REPS:-5}"
PANDAS_WARMUPS="${PERF_WARMUPS:-1}"
PANDAS_STATISTIC="median"
PANDAS_OFFLINE_MEASUREMENT="true"

SOURCE_DIR=""
PY_SRC_DIR=""
PY_BUILD_DIR=""
PY_INSTALL_DIR=""
PYTHON_BIN=""
VENV_DIR=""
VENV_PY=""
WHEELHOUSE=""
ASV_DIR=""
RUNS_DIR=""
SCENARIOS_FILE=""
MANIFEST_FILE=""
RUNTIME_VERSIONS_JSON=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[pandas] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    if [[ ! "${PANDAS_REPS}" =~ ^[0-9]+$ ]] || [[ "${PANDAS_REPS}" -lt 1 ]]; then
        log_message "ERROR: PERF_REPS must be a positive integer, got ${PANDAS_REPS}"
        return 20
    fi
    if [[ ! "${PANDAS_WARMUPS}" =~ ^[0-9]+$ ]]; then
        log_message "ERROR: PERF_WARMUPS must be a non-negative integer, got ${PANDAS_WARMUPS}"
        return 20
    fi
}

check_architecture() {
    local actual expected
    actual="$(normalize_architecture "$(uname -m)")"
    expected="$(normalize_architecture "${EXPECTED_ARCH}")"
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: expected architecture ${expected}, runner is ${actual}"
        return 20
    fi
}

configure_runtime_paths() {
    validate_variant || return $?
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/${SOFTWARE_NAME}/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi

    SOURCE_DIR="${PERF_WORK_DIR}/cpython-source"
    PY_SRC_DIR="${SOURCE_DIR}/Python-${PYTHON_VERSION}"
    PY_BUILD_DIR="${PERF_WORK_DIR}/cpython-build"
    PY_INSTALL_DIR="${PERF_WORK_DIR}/cpython-install"
    PYTHON_BIN="${PY_INSTALL_DIR}/bin/python3"
    VENV_DIR="${PERF_WORK_DIR}/pandas-venv"
    VENV_PY="${VENV_DIR}/bin/python"
    WHEELHOUSE="${PERF_WORK_DIR}/wheelhouse"
    ASV_DIR="${PERF_WORK_DIR}/asv_bench"
    RUNS_DIR="${RESULTS_DIR}/runs"
    SCENARIOS_FILE="${SCRIPT_DIR}/fixtures/scenarios.json"
    MANIFEST_FILE="${SCRIPT_DIR}/asv_bench/manifest.sha256"
    RUNTIME_VERSIONS_JSON="${PERF_WORK_DIR}/runtime-versions.json"

    export SOFTWARE_NAME SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    export PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export PYTHON_VERSION PYTHON_SHA256 PYTHON_BYTES PYTHON_TARBALL
    export PYTHON_BIN VENV_DIR VENV_PY WHEELHOUSE ASV_DIR RUNS_DIR
    export SCENARIOS_FILE MANIFEST_FILE RUNTIME_VERSIONS_JSON
    export PANDAS_REPS PANDAS_WARMUPS BUILD_JOBS
    export PANDAS_OFFLINE_DIR PANDAS_REQUIREMENTS_LOCK
    export ASV_TAG ASV_TAG_COMMIT ASV_REPOSITORY ASV_SUITE ASV_PROFILE
    export PANDAS_OFFLINE_MEASUREMENT
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${RUNS_DIR}"
}

# Environment shared by every timed scenario.  It pins the interpreter hash
# seed, the locale/timezone, all BLAS/OpenMP thread pools and the network
# policy, so the measurement window never depends on the runner defaults.
pandas_measurement_env() {
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    export MKL_NUM_THREADS=1
    export NUMEXPR_NUM_THREADS=1
    export VECLIB_MAXIMUM_THREADS=1
    export BLIS_NUM_THREADS=1
    export OMP_DYNAMIC=false
    export PYTHONHASHSEED=0
    export PYTHONDONTWRITEBYTECODE=1
    export LC_ALL=C
    export LANG=C
    export TZ=UTC
    export PANDASBENCH_SEED=1234
    export HOME="${PERF_WORK_DIR}/home"
    mkdir -p "${HOME}" "${TMPDIR}"
    export DEBUGINFOD_URLS=""
    export http_proxy="http://127.0.0.1:9"
    export https_proxy="http://127.0.0.1:9"
    export HTTP_PROXY="http://127.0.0.1:9"
    export HTTPS_PROXY="http://127.0.0.1:9"
    export no_proxy=""
    export NO_PROXY=""
}

# Environment that every containerised measurement process must inherit.  The
# `docker exec` wrapper only forwards HOME/TMPDIR/PERF_RUN_ID, so the BLAS and
# offline settings are passed explicitly through `env` when a measured command
# is started inside the private container.
PANDAS_MEASUREMENT_ENV=(
    "OMP_NUM_THREADS=1"
    "OPENBLAS_NUM_THREADS=1"
    "MKL_NUM_THREADS=1"
    "NUMEXPR_NUM_THREADS=1"
    "VECLIB_MAXIMUM_THREADS=1"
    "BLIS_NUM_THREADS=1"
    "OMP_DYNAMIC=false"
    "PYTHONHASHSEED=0"
    "PYTHONDONTWRITEBYTECODE=1"
    "LC_ALL=C"
    "LANG=C"
    "TZ=UTC"
    "PANDASBENCH_SEED=1234"
    "DEBUGINFOD_URLS="
    "http_proxy=http://127.0.0.1:9"
    "https_proxy=http://127.0.0.1:9"
    "no_proxy="
)

scenario_timeout() {
    case "$1" in
        groupby_sort_high_cardinality|groupby_int64_overflow|merge_asof_int) printf '300\n' ;;
        *) printf '240\n' ;;
    esac
}

count_scenario_entries() {
    python3 - "${SCENARIOS_FILE}" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    payload = json.load(handle)
print(len(payload["scenarios"]))
PY
}

known_scenarios_csv() {
    local name out=""
    for name in "${PANDAS_SCENARIOS[@]}"; do
        if [[ -n "${out}" ]]; then
            out+=","
        fi
        out+="${name}"
    done
    printf '%s\n' "${out}"
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
PANDAS_IMAGE_ARCHIVE_DIR="${PANDAS_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
PANDAS_CA_ANCHORS_DIR="${PANDAS_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
PANDAS_CONTAINER_IMAGE="${PANDAS_CONTAINER_IMAGE:-}"
PANDAS_CONTAINER_NAME="${PANDAS_CONTAINER_NAME:-}"
PANDAS_CONTAINER_HOME="${PANDAS_CONTAINER_HOME:-}"
declare -p PANDAS_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || PANDAS_CONTAINER_EXTRA_ARGS=()

pandas_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

pandas_configure_container() {
    local arch
    arch="$(pandas_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${PANDAS_CONTAINER_NAME}" ] || PANDAS_CONTAINER_NAME="boostkit-pandas-${arch}-${PERF_RUN_ID}"
    [ -n "${PANDAS_CONTAINER_HOME}" ] || PANDAS_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export PANDAS_CONTAINER_NAME PANDAS_CONTAINER_HOME
}

pandas_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_pandas_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_pandas_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${PANDAS_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_pandas_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(pandas_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${PANDAS_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${PANDAS_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        pandas_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        pandas_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    PANDAS_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${PANDAS_CONTAINER_IMAGE}" ] || ! docker image inspect "${PANDAS_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${PANDAS_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_pandas_container_image_release || return $?
    export PANDAS_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${PANDAS_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_pandas_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-pandas-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${PANDAS_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.pandas.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_pandas_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    pandas_configure_container
    require_pandas_docker || return $?
    if docker container inspect "${PANDAS_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${PANDAS_CONTAINER_NAME}"
        return 40
    fi
    sweep_pandas_stale_containers || true
    prepare_pandas_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${PANDAS_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${PANDAS_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${PANDAS_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${PANDAS_CONTAINER_HOME}" || return 40
    log_message "starting private container ${PANDAS_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${PANDAS_CONTAINER_NAME}" \
        --label "boostkit.pandas.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${PANDAS_CONTAINER_EXTRA_ARGS[@]}" \
        "${PANDAS_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${PANDAS_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${PANDAS_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${PANDAS_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${PANDAS_CONTAINER_NAME}"
}

check_pandas_container() {
    pandas_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${PANDAS_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${PANDAS_CONTAINER_NAME}"
        return 40
    }
}

pandas_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    pandas_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${PANDAS_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${PANDAS_CONTAINER_NAME}" "$@"
}

pandas_container_exec() { pandas_docker_exec '' '' "$@"; }

pandas_container_exec_at() {
    local workdir="$1"
    shift
    pandas_docker_exec "${workdir}" '' "$@"
}

pandas_container_exec_root() { pandas_docker_exec '' root "$@"; }

pandas_container_exec_root_at() {
    local workdir="$1"
    shift
    pandas_docker_exec "${workdir}" root "$@"
}

remove_pandas_container() {
    pandas_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${PANDAS_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.pandas.run-id"}}' "${PANDAS_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${PANDAS_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${PANDAS_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${PANDAS_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${PANDAS_CONTAINER_NAME}"
}
# >>> container-runtime:end
