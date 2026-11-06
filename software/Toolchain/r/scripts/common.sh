#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Case configuration for R 4.6.2 (sourced by every stage).

SOFTWARE_NAME="r"
BENCH_EXPECTED_VERSION="4.6.2"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-${BENCH_EXPECTED_VERSION}}"
BENCH_REPS="${PERF_REPS:-5}"
BENCH_RUN_TIMEOUT_SECONDS="${BENCH_RUN_TIMEOUT_SECONDS:-900}"

# Official release archive:
#   https://cran.r-project.org/src/base/R-4/R-4.6.2.tar.gz
# CRAN does not publish a detached SHA-256 next to each tarball; the pinned
# value below was computed from the official archive and is verified for every
# download / offline copy.
BENCH_SOURCE_NAME="R-4.6.2.tar.gz"
BENCH_SOURCE_SHA256="c297040f6392b1dac6e5c0eb398422cfdaedf540ae2205edb9ad0d10cb10ee00"
BENCH_SOURCE_URL="https://cran.r-project.org/src/base/R-4/${BENCH_SOURCE_NAME}"
BENCH_SOURCE_URLS=()
if [[ -n "${PERF_R_SOURCE_MIRROR:-}" ]]; then
    BENCH_SOURCE_URLS+=("${PERF_R_SOURCE_MIRROR%/}/${BENCH_SOURCE_NAME}")
fi
# Chinese CRAN mirrors are used before cran.r-project.org on slow links; every
# source is verified against the same pinned SHA-256.
BENCH_SOURCE_URLS+=(
    "https://mirrors.tuna.tsinghua.edu.cn/CRAN/src/base/R-4/${BENCH_SOURCE_NAME}"
    "https://mirrors.aliyun.com/CRAN/src/base/R-4/${BENCH_SOURCE_NAME}"
    "${BENCH_SOURCE_URL}"
)
BENCH_OFFLINE_DIR="${PERF_R_OFFLINE_DIR:-/home/runner/software/r}"
BENCH_BUILD_JOBS="${BENCH_BUILD_JOBS:-4}"

BENCH_BUILD_DEPS_DNF=(gcc gcc-c++ gcc-gfortran make tar curl bzip2 xz pcre2-devel zlib-devel bzip2-devel xz-devel libcurl-devel openssl-devel)
BENCH_BUILD_DEPS_APT=(gcc gfortran make tar curl bzip2 xz-utils libpcre2-dev zlib1g-dev libbz2-dev liblzma-dev libcurl4-openssl-dev libssl-dev)
BENCH_EXTRA_TOOLS=(gfortran)

BENCH_SCENARIOS_FILE="${SCRIPT_DIR}/benchmarks/scenarios.psv"
BENCH_BUILD_COMMAND="./configure --prefix=<install> --without-x --without-recommended-packages --disable-java --without-readline --without-libcurl && make -j${BENCH_BUILD_JOBS} && make install"
BENCH_BUILD_INFO_EXTRAS=(
    --extra "configure_command=./configure --prefix=<install> --without-x --without-recommended-packages --disable-java --without-readline --without-libcurl"
    --extra "build_jobs=${BENCH_BUILD_JOBS}"
    --extra "blas=internal reference BLAS/LAPACK shipped with the R source (no external BLAS is installed or linked)"
    --extra "upstream_benchmark=R base crossprod/matrix algebra (BLAS level 3) plus base R vector/string/sort loops; workload scripts print deterministic RESULT checksums"
)

bench_set_paths() {
    BENCH_SRC_PARENT="${PERF_WORK_DIR}/r-src"
    BENCH_SRC_DIR="${BENCH_SRC_PARENT}"
    BENCH_INSTALL_DIR="${PERF_WORK_DIR}/r-install"
    BENCH_BIN="${BENCH_INSTALL_DIR}/bin/Rscript"
    BENCH_R_BIN="${BENCH_INSTALL_DIR}/bin/R"
    BENCH_BUILD_DIR="${PERF_WORK_DIR}/build"
    BENCH_DOWNLOADS_DIR="${PERF_WORK_DIR}/downloads"
    RUNS_DIR="${RESULTS_DIR}/runs"
}

source "${SCRIPT_DIR}/scripts/common_core.sh"
source "${SCRIPT_DIR}/scripts/workloads.sh"

# ------------------------------------------------- container process env ------
# ``docker exec`` does not inherit the caller's environment, so the values the
# build and the measurement need are forwarded explicitly.  Absolute paths are
# identical inside and outside the container because the work directory, the
# result directory and the case directory are mounted at the same paths.
R_CONTAINER_ENV=()

r_build_env() {
    R_CONTAINER_ENV=(
        "HOME=${R_CONTAINER_HOME:-${PERF_WORK_DIR}/home}"
        "TMPDIR=${TMPDIR}"
        "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        "SOFTWARE_VERSION=${SOFTWARE_VERSION}"
        "BENCH_BUILD_JOBS=${BENCH_BUILD_JOBS}"
        "BENCH_INSTALL_DIR=${BENCH_INSTALL_DIR}"
        "BENCH_SRC_DIR=${BENCH_SRC_DIR}"
        "BENCH_BUILD_DIR=${BENCH_BUILD_DIR}"
        "BENCH_DOWNLOADS_DIR=${BENCH_DOWNLOADS_DIR}"
    )
}

# Measurement environment: fixed C locale and UTC so the same workload runs on
# both architectures, and closed proxies so a workload that tried to reach the
# network would fail immediately instead of silently measuring something else.
r_measure_env() {
    r_build_env
    R_CONTAINER_ENV+=(
        "TZ=UTC"
        "LC_ALL=C"
        "LANG=C"
        "HTTP_PROXY=http://127.0.0.1:9"
        "HTTPS_PROXY=http://127.0.0.1:9"
        "http_proxy=http://127.0.0.1:9"
        "https_proxy=http://127.0.0.1:9"
        "NO_PROXY=127.0.0.1,localhost"
        "no_proxy=127.0.0.1,localhost"
    )
}

r_container_exec_env() {
    r_build_env
    r_container_exec env "${R_CONTAINER_ENV[@]}" "$@"
}

r_container_exec_env_at() {
    local workdir="$1"
    shift
    r_build_env
    r_container_exec_at "${workdir}" env "${R_CONTAINER_ENV[@]}" "$@"
}

r_container_measure_at() {
    local workdir="$1"
    shift
    r_measure_env
    r_container_exec_at "${workdir}" env "${R_CONTAINER_ENV[@]}" "$@"
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
R_IMAGE_ARCHIVE_DIR="${R_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
R_CA_ANCHORS_DIR="${R_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
R_CONTAINER_IMAGE="${R_CONTAINER_IMAGE:-}"
R_CONTAINER_NAME="${R_CONTAINER_NAME:-}"
R_CONTAINER_HOME="${R_CONTAINER_HOME:-}"
declare -p R_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || R_CONTAINER_EXTRA_ARGS=()

r_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

r_configure_container() {
    local arch
    arch="$(r_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${R_CONTAINER_NAME}" ] || R_CONTAINER_NAME="boostkit-r-${arch}-${PERF_RUN_ID}"
    [ -n "${R_CONTAINER_HOME}" ] || R_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export R_CONTAINER_NAME R_CONTAINER_HOME
}

r_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_r_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_r_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${R_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_r_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(r_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${R_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${R_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        r_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        r_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    R_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${R_CONTAINER_IMAGE}" ] || ! docker image inspect "${R_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${R_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_r_container_image_release || return $?
    export R_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${R_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_r_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-r-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${R_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.r.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_r_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    r_configure_container
    require_r_docker || return $?
    if docker container inspect "${R_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${R_CONTAINER_NAME}"
        return 40
    fi
    sweep_r_stale_containers || true
    prepare_r_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${R_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${R_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${R_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${R_CONTAINER_HOME}" || return 40
    log_message "starting private container ${R_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${R_CONTAINER_NAME}" \
        --label "boostkit.r.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${R_CONTAINER_EXTRA_ARGS[@]}" \
        "${R_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${R_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${R_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${R_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${R_CONTAINER_NAME}"
}

check_r_container() {
    r_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${R_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${R_CONTAINER_NAME}"
        return 40
    }
}

r_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    r_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${R_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${R_CONTAINER_NAME}" "$@"
}

r_container_exec() { r_docker_exec '' '' "$@"; }

r_container_exec_at() {
    local workdir="$1"
    shift
    r_docker_exec "${workdir}" '' "$@"
}

r_container_exec_root() { r_docker_exec '' root "$@"; }

r_container_exec_root_at() {
    local workdir="$1"
    shift
    r_docker_exec "${workdir}" root "$@"
}

remove_r_container() {
    r_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${R_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.r.run-id"}}' "${R_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${R_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${R_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${R_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${R_CONTAINER_NAME}"
}
# >>> container-runtime:end
