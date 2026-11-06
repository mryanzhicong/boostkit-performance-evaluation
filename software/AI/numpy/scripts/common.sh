#!/usr/bin/env bash
# ==============================================================================
# numpy 2.4.3 open-box performance case -- shared configuration and helpers.
# ==============================================================================
# The case measures the *unmodified* NumPy 2.4.3 baseline that boostkit imports
# at commit 289c872f with the platform aggregate ASV suite that lives on the
# boostkit main branch (commit 95422b2).  Everything -- the pinned CPython
# interpreter, the pinned wheels, the NumPy build, the ASV run and the publish
# step -- executes inside a private openEuler 24.03 LTS SP4 container; the host
# only orchestrates Docker and runs the strict result parser.
#
# Layout inside the per-run work directory (${PERF_WORK_DIR}):
#   src/numpy                       git checkout of the pinned NumPy baseline
#   cpython-source/Python-3.14.10   verified CPython source archive
#   cpython-build                   out-of-tree CPython build tree
#   cpython-install                 installed CPython 3.14.10 runtime
#   numpy-venv                      measurement virtual environment
#   wheelhouse                      downloaded, pinned wheels
#   asv_bench                       vendored ASV suite (asv.conf.json + benchmarks)
#   asv_bench/results|html|env      ASV results, published html, virtualenv dir
#   home                            container HOME (.asv-machine.json)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SOFTWARE_NAME="numpy"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-2.4.3}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
PERF_REPS="${PERF_REPS:-5}"
PERF_WARMUPS="${PERF_WARMUPS:-1}"

# ------------------------------------------------------------------------------
# Pinned inputs
# ------------------------------------------------------------------------------
# CPython interpreter: official 3.14.10 source archive (the NumPy 2.4.3 release
# notes only guarantee support for the CPython versions that were current at
# release time; the boostkit benchmark guide pins 3.14).
PYTHON_VERSION="3.14.10"
PYTHON_VERSION_SHORT="3.14"
# Environment name the result parser reads: the interpreter minor version the
# measurement must have been produced with.
NUMPY_PYTHON_SHORT="${PYTHON_VERSION_SHORT}"
PYTHON_SHA256="9e4996c19ae5a3df31f10c37723661f71d3455d73bd005f79df7098e5cc13192"
PYTHON_BYTES="31671453"
PYTHON_TARBALL="Python-${PYTHON_VERSION}.tgz"
PYTHON_URLS=(
    "https://mirrors.huaweicloud.com/python/${PYTHON_VERSION}/${PYTHON_TARBALL}"
    "https://mirrors.aliyun.com/python-release/source/${PYTHON_VERSION}/${PYTHON_TARBALL}"
    "https://www.python.org/ftp/python/${PYTHON_VERSION}/${PYTHON_TARBALL}"
)
# --enable-optimizations turns on PGO, matching the profile the upstream
# python.org binaries use; --with-ensurepip keeps the private venv self-hosting.
PYTHON_CONFIGURE_OPTIONS=(--with-ensurepip=install --enable-optimizations)

# NumPy source = the boostkit import of the unmodified 2.4.3 baseline.  The
# commit and its tree hash are pinned; both are verified after the clone so a
# rewritten tag cannot silently change what is measured.
NUMPY_REPOSITORY="https://gitcode.com/boostkit/numpy.git"
NUMPY_BASELINE_COMMIT="289c872fc2cc3a82a63a66b4c1a32e8ef6e80fb6"
NUMPY_BASELINE_TREE="4011714d5de68c10c60cf6f083c3a49c1de0dfc4"
NUMPY_VERSION_FILE="numpy/version.py"
# Every submodule, on every architecture.  The two x86-only ones are *not*
# compiled on aarch64 (numpy gates the meson targets on the host machine), but
# numpy's pyproject.toml lists their LICENSE files in `license-files`, and
# meson-python refuses to build when a license pattern matches no file:
#   "Every pattern in project.license-files must match at least one file:
#    'numpy/_core/src/npysort/x86-simd-sort/LICENSE.md' did not match any"
# `vendored-meson/meson` is mandatory too: pyproject.toml points meson-python at
# `vendored-meson/meson/meson.py`.
NUMPY_SUBMODULES=(
    "numpy/_core/src/common/pythoncapi-compat"
    "numpy/_core/src/highway"
    "numpy/fft/pocketfft"
    "vendored-meson/meson"
    "numpy/_core/src/npysort/x86-simd-sort"
    "numpy/_core/src/umath/svml"
)
# The upstream URLs live on github.com, which some runners cannot reach; the
# build stage probes the direct route first (short timeout) and then rewrites the
# URLs through the first mirror that works.
NUMPY_SUBMODULE_MIRRORS=(
    ""
    "https://gh-proxy.com/https://github.com/"
    "https://ghfast.top/https://github.com/"
)
# A direct github.com attempt without connectivity wastes two ~135 s connect
# timeouts per submodule; the probe caps that at NUMPY_SUBMODULE_PROBE_SECONDS.
NUMPY_SUBMODULE_PROBE_URL="https://github.com/numpy/meson.git"
NUMPY_SUBMODULE_PROBE_SECONDS="25"

# ASV suite = the platform aggregate benchmarks from the boostkit main branch,
# vendored byte-for-byte under <case>/asv_bench.
ASV_SUITE_REPOSITORY="https://gitcode.com/boostkit/numpy.git"
ASV_SUITE_COMMIT="95422b21eb5b43a2453e45b8531a3dd09c9b61ab"
ASV_SUITE_COMMIT_SHORT="95422b2"
ASV_SUITE_BENCH_TREE="b76e6b454f70b2ceb13b7cfe8a22bce57717ac3f"
ASV_VERSION="0.6.4"

# The 1256 aggregate benchmark ids shipped with the case (one exact ASV
# benchmark id per line, verbatim from the boostkit benchmark guide).
ASV_LIST_NAME="1200+juhe_benches.txt"

# Pinned measurement environment.  The wheels are installed with
# --no-deps from the wheelhouse so the interpreter cannot drift between runs.
NUMPY_REQUIREMENTS_LOCK="${SCRIPT_DIR}/requirements.lock"
NUMPY_PIP_INDEXES=(
    "https://mirrors.aliyun.com/pypi/simple/"
    "https://repo.huaweicloud.com/repository/pypi/simple/"
    "https://pypi.tuna.tsinghua.edu.cn/simple"
)

BUILD_JOBS="${PERF_BUILD_JOBS:-$(nproc)}"
NUMPY_REPS="${PERF_REPS}"
NUMPY_WARMUPS="${PERF_WARMUPS}"
NUMPY_STATISTIC="median"

# Environment shared by every timed measurement.  It pins the interpreter hash
# seed, the locale/timezone, every BLAS/OpenMP thread pool and the network
# policy, so the measurement window never depends on runner defaults.
NUMPY_MEASUREMENT_ENV=(
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
    "DEBUGINFOD_URLS="
    "http_proxy=http://127.0.0.1:9"
    "https_proxy=http://127.0.0.1:9"
    "HTTP_PROXY=http://127.0.0.1:9"
    "HTTPS_PROXY=http://127.0.0.1:9"
    "no_proxy="
    "NO_PROXY="
)

SOURCE_DIR=""
NUMPY_REPO_DIR=""
PY_SRC_DIR=""
PY_BUILD_DIR=""
PY_INSTALL_DIR=""
PYTHON_BIN=""
VENV_DIR=""
VENV_PY=""
ASV_BIN=""
WHEELHOUSE=""
ASV_DIR=""
RUNS_DIR=""
MANIFEST_FILE=""
ASV_CONF=""
ASV_LIST=""
ASV_RESULTS_DIR=""
ASV_HTML_DIR=""
RUNTIME_VERSIONS_JSON=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[numpy] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
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
    if [[ ! "${NUMPY_REPS}" =~ ^[0-9]+$ ]] || [[ "${NUMPY_REPS}" -lt 1 ]]; then
        log_message "ERROR: PERF_REPS must be a positive integer, got ${NUMPY_REPS}"
        return 20
    fi
    if [[ ! "${NUMPY_WARMUPS}" =~ ^[0-9]+$ ]]; then
        log_message "ERROR: PERF_WARMUPS must be a non-negative integer, got ${NUMPY_WARMUPS}"
        return 20
    fi
    if [[ "${NUMPY_WARMUPS}" -lt 1 ]]; then
        log_message "ERROR: PERF_WARMUPS must be at least 1: the first ASV sample is always discarded as warm-up"
        return 20
    fi
    if [[ "${NUMPY_REPS}" -lt 5 ]]; then
        log_message "WARNING: PERF_REPS=${NUMPY_REPS} is below the 5-sample minimum used for published numbers (local smoke runs only)"
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

    SOURCE_DIR="${PERF_WORK_DIR}/src"
    NUMPY_REPO_DIR="${SOURCE_DIR}/numpy"
    PY_SRC_DIR="${PERF_WORK_DIR}/cpython-source/Python-${PYTHON_VERSION}"
    PY_BUILD_DIR="${PERF_WORK_DIR}/cpython-build"
    PY_INSTALL_DIR="${PERF_WORK_DIR}/cpython-install"
    PYTHON_BIN="${PY_INSTALL_DIR}/bin/python3"
    VENV_DIR="${PERF_WORK_DIR}/numpy-venv"
    VENV_PY="${VENV_DIR}/bin/python"
    ASV_BIN="${VENV_DIR}/bin/asv"
    WHEELHOUSE="${PERF_WORK_DIR}/wheelhouse"
    ASV_DIR="${PERF_WORK_DIR}/asv_bench"
    RUNS_DIR="${RESULTS_DIR}/runs"
    MANIFEST_FILE="${SCRIPT_DIR}/asv_bench/manifest.sha256"
    ASV_CONF="${ASV_DIR}/asv.conf.json"
    ASV_LIST="${SCRIPT_DIR}/fixtures/${ASV_LIST_NAME}"
    ASV_RESULTS_DIR="${ASV_DIR}/results"
    ASV_HTML_DIR="${ASV_DIR}/html"
    RUNTIME_VERSIONS_JSON="${PERF_WORK_DIR}/runtime-versions.json"

    export SOFTWARE_NAME SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    export PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE TMPDIR
    export PYTHON_VERSION PYTHON_VERSION_SHORT PYTHON_SHA256 PYTHON_BYTES PYTHON_TARBALL
    export PYTHON_BIN VENV_DIR VENV_PY ASV_BIN WHEELHOUSE ASV_DIR RUNS_DIR
    export MANIFEST_FILE ASV_CONF ASV_LIST ASV_RESULTS_DIR ASV_HTML_DIR
    export RUNTIME_VERSIONS_JSON BUILD_JOBS
    export NUMPY_REPS NUMPY_WARMUPS NUMPY_STATISTIC
    export NUMPY_BASELINE_COMMIT ASV_SUITE_COMMIT ASV_VERSION NUMPY_REQUIREMENTS_LOCK
    export NUMPY_PYTHON_SHORT
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${RUNS_DIR}" "${WHEELHOUSE}"
}

# Everything a measured process must inherit.  The exec wrapper only forwards
# HOME/TMPDIR/PERF_RUN_ID, so callers pass this array explicitly via `env`.
numpy_measurement_env() {
    local dir="${1:-${PERF_WORK_DIR}/home}"
    mkdir -p "${dir}" "${TMPDIR}"
    printf '%s\n' \
        "${NUMPY_MEASUREMENT_ENV[@]}" \
        "HOME=${dir}"
}

# ------------------------------------------------------------------------------
# Small guards shared by the stages
# ------------------------------------------------------------------------------
numpy_require_host_tools() {
    local missing=() tool
    for tool in docker curl sha256sum tar git; do
        command -v "${tool}" >/dev/null 2>&1 || missing+=("${tool}")
    done
    if [ "${#missing[@]}" -ne 0 ]; then
        log_message "ERROR: missing host tools: ${missing[*]}"
        return 30
    fi
}

numpy_container_python_version() {
    numpy_container_exec "${PYTHON_BIN}" -c 'import sys; print("%d.%d.%d" % sys.version_info[:3])'
}

numpy_container_numpy_version() {
    numpy_container_exec "${VENV_PY}" -c 'import numpy; print(numpy.__version__)'
}

numpy_repo_commit() {
    numpy_container_exec git -C "${NUMPY_REPO_DIR}" rev-parse HEAD
}

numpy_repo_tree() {
    numpy_container_exec git -C "${NUMPY_REPO_DIR}" rev-parse 'HEAD^{tree}'
}

# Verify the vendored ASV suite against its sha256 manifest.  The suite is the
# only mutable input that is not pinned by a git hash, so it is checked on every
# single stage instead of only at build time.
numpy_verify_asv_suite() {
    local dir="$1"
    [ -f "${dir}/manifest.sha256" ] || {
        log_message "ERROR: ASV suite manifest is missing in ${dir}"
        return 30
    }
    if ! numpy_container_exec_at "${dir}" sha256sum -c manifest.sha256 --quiet >/dev/null 2>&1; then
        log_message "ERROR: vendored ASV suite does not match manifest.sha256 (${dir})"
        return 30
    fi
}

numpy_count_benchmarks() {
    local list="$1"
    [ -f "${list}" ] || {
        log_message "ERROR: benchmark id list is missing: ${list}"
        return 30
    }
    grep -cve '^[[:space:]]*$' "${list}" || true
}

write_actual_version() {
    local version="${1:-${SOFTWARE_VERSION}}"
    printf '%s\n' "${version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 30
    log_message "recorded actual software version: $(cat "${PERF_ACTUAL_VERSION_FILE}")"
}

# Prove that the container really carries the pinned interpreter, NumPy baseline,
# vendored ASV suite (manifest-checked) and the shipped benchmark list.  Both the
# start stage (before discovery) and the test stage (before the expensive run)
# call this so neither can start from a half-built environment.
numpy_verify_runtime_payload() {
    local python_version numpy_version commit tree machine_file count
    python_version="$(numpy_container_python_version)" || return 30
    if [ "${python_version}" != "${PYTHON_VERSION}" ]; then
        log_message "ERROR: container CPython is ${python_version}, expected ${PYTHON_VERSION}"
        return 30
    fi
    numpy_version="$(numpy_container_numpy_version)" || return 30
    if [ "${numpy_version}" != "${SOFTWARE_VERSION}" ]; then
        log_message "ERROR: container NumPy is ${numpy_version}, expected ${SOFTWARE_VERSION}"
        return 30
    fi
    commit="$(numpy_repo_commit)" || return 30
    tree="$(numpy_repo_tree)" || return 30
    if [ "${commit}" != "${NUMPY_BASELINE_COMMIT}" ] || [ "${tree}" != "${NUMPY_BASELINE_TREE}" ]; then
        log_message "ERROR: NumPy checkout is ${commit}/${tree}, expected ${NUMPY_BASELINE_COMMIT}/${NUMPY_BASELINE_TREE}"
        return 30
    fi
    numpy_verify_asv_suite "${ASV_DIR}" || return $?
    machine_file="${PERF_WORK_DIR}/home/.asv-machine.json"
    numpy_container_exec test -s "${machine_file}" || {
        log_message "ERROR: asv machine file is missing: ${machine_file}"
        return 30
    }
    count="$(numpy_count_benchmarks "${ASV_LIST}")"
    if [ "${count}" -lt 1200 ]; then
        log_message "ERROR: the benchmark id list unexpectedly shrank to ${count} entries"
        return 30
    fi
    log_message "payload verified: CPython ${python_version}, NumPy ${numpy_version}, commit ${commit:0:8}, ${count} benchmark ids"
}

# The private openEuler container runtime (generated block) follows below.  Do
# not hand edit it: regenerate with adaptation/scripts/add-container-block.py.

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
NUMPY_IMAGE_ARCHIVE_DIR="${NUMPY_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
NUMPY_CA_ANCHORS_DIR="${NUMPY_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
NUMPY_CONTAINER_IMAGE="${NUMPY_CONTAINER_IMAGE:-}"
NUMPY_CONTAINER_NAME="${NUMPY_CONTAINER_NAME:-}"
NUMPY_CONTAINER_HOME="${NUMPY_CONTAINER_HOME:-}"
declare -p NUMPY_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || NUMPY_CONTAINER_EXTRA_ARGS=()

numpy_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

numpy_configure_container() {
    local arch
    arch="$(numpy_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${NUMPY_CONTAINER_NAME}" ] || NUMPY_CONTAINER_NAME="boostkit-numpy-${arch}-${PERF_RUN_ID}"
    [ -n "${NUMPY_CONTAINER_HOME}" ] || NUMPY_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export NUMPY_CONTAINER_NAME NUMPY_CONTAINER_HOME
}

numpy_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_numpy_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_numpy_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${NUMPY_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_numpy_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(numpy_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${NUMPY_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${NUMPY_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        numpy_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        numpy_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    NUMPY_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${NUMPY_CONTAINER_IMAGE}" ] || ! docker image inspect "${NUMPY_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${NUMPY_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_numpy_container_image_release || return $?
    export NUMPY_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${NUMPY_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_numpy_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-numpy-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${NUMPY_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.numpy.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_numpy_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    numpy_configure_container
    require_numpy_docker || return $?
    if docker container inspect "${NUMPY_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${NUMPY_CONTAINER_NAME}"
        return 40
    fi
    sweep_numpy_stale_containers || true
    prepare_numpy_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${NUMPY_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${NUMPY_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${NUMPY_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${NUMPY_CONTAINER_HOME}" || return 40
    log_message "starting private container ${NUMPY_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${NUMPY_CONTAINER_NAME}" \
        --label "boostkit.numpy.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${NUMPY_CONTAINER_EXTRA_ARGS[@]}" \
        "${NUMPY_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${NUMPY_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${NUMPY_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${NUMPY_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${NUMPY_CONTAINER_NAME}"
}

check_numpy_container() {
    numpy_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${NUMPY_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${NUMPY_CONTAINER_NAME}"
        return 40
    }
}

numpy_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    numpy_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${NUMPY_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${NUMPY_CONTAINER_NAME}" "$@"
}

numpy_container_exec() { numpy_docker_exec '' '' "$@"; }

numpy_container_exec_at() {
    local workdir="$1"
    shift
    numpy_docker_exec "${workdir}" '' "$@"
}

numpy_container_exec_root() { numpy_docker_exec '' root "$@"; }

numpy_container_exec_root_at() {
    local workdir="$1"
    shift
    numpy_docker_exec "${workdir}" root "$@"
}

remove_numpy_container() {
    numpy_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${NUMPY_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.numpy.run-id"}}' "${NUMPY_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${NUMPY_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${NUMPY_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${NUMPY_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${NUMPY_CONTAINER_NAME}"
}
# >>> container-runtime:end
