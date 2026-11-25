#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.1.0}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# Sampling contract: one warmup round plus at least five measured rounds.  The
# measured value is the median of the measured rounds; PERF_REPS may grow it but
# must never shrink it below five.
PERF_REPS="${PERF_REPS:-5}"
RAPIDJSON_WARMUPS="${RAPIDJSON_WARMUPS:-1}"
RAPIDJSON_GTEST_REPEAT="${RAPIDJSON_GTEST_REPEAT:-5}"
RAPIDJSON_OFFLINE_DIR="${RAPIDJSON_OFFLINE_DIR:-/home/runner/software/rapidjson}"

RAPIDJSON_CONTAINER_IMAGE="${RAPIDJSON_CONTAINER_IMAGE:-}"
RAPIDJSON_CONTAINER_NAME="${RAPIDJSON_CONTAINER_NAME:-}"
RAPIDJSON_CONTAINER_HOME="${RAPIDJSON_CONTAINER_HOME:-}"
declare -a RAPIDJSON_CONTAINER_EXTRA_ARGS=()
# Escape hatch for restricted networks: extra docker run arguments, for example
# --add-host entries when a local package mirror has to be reached by IP.
if [[ -n "${RAPIDJSON_DOCKER_EXTRA_ARGS:-}" ]]; then
    read -r -a RAPIDJSON_CONTAINER_EXTRA_ARGS <<< "${RAPIDJSON_DOCKER_EXTRA_ARGS}"
fi

STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

# Pinned upstream inputs.  Every archive is verified before it is unpacked and a
# mismatch aborts the build instead of producing numbers from other sources.
RAPIDJSON_SOURCE_ARCHIVE="rapidjson-1.1.0.tar.gz"
RAPIDJSON_SOURCE_URL="https://codeload.github.com/Tencent/rapidjson/tar.gz/24b5e7a8b27f42fa16b96fc70aade9106cf7102f"
RAPIDJSON_SOURCE_SHA256="2d2601a82d2d3b7e143a3c8d43ef616671391034bc46891a9816b79cf2d3e7a8"
RAPIDJSON_SOURCE_BYTES=1116703
# Top level directory inside the pinned codeload tarball.
RAPIDJSON_SOURCE_TAR_ROOT="rapidjson-24b5e7a8b27f42fa16b96fc70aade9106cf7102f"
RAPIDJSON_SOURCE_ROOT="rapidjson-1.1.0"
RAPIDJSON_OPTIMIZED_ROOT="rapidjson-1.1.0-opt"

RAPIDJSON_GTEST_ARCHIVE="googletest-release-1.12.1.tar.gz"
RAPIDJSON_GTEST_URL="https://codeload.github.com/google/googletest/tar.gz/refs/tags/release-1.12.1"
RAPIDJSON_GTEST_SHA256="81964fe578e9bd7c94dfdb09c8e4d6e6759e19967e397dbea48d1c10e45d0df2"
RAPIDJSON_GTEST_BYTES=854944

RAPIDJSON_PATCH_FILE="kunpeng_opti_v1.0.0.patch"
RAPIDJSON_PATCH_SHA256="748f35b0a78feaa2b80ae8dc6852796611d51528ca5082cf0d595cf2e347ddba"
RAPIDJSON_PATCH_BYTES=12053

RAPIDJSON_SAMPLE_BYTES=687491
RAPIDJSON_PARAGRAPHS_BYTES=33764

# The eight upstream test/perftest cases sampled by this case.  The suffixes are
# architecture specific and are resolved through --gtest_filter; the parser
# takes the canonical list from fixtures/scenarios.json.
RAPIDJSON_SCENARIOS=(
    dom_parse
    dom_parse_insitu
    dom_parse_encoded_stream
    sax_parse
    sax_parse_paragraphs
    writer_string_buffer
    writer_string_buffer_paragraphs
    pretty_writer_string_buffer
)
RAPIDJSON_SCENARIO_CASES=(
    DocumentParse_MemoryPoolAllocator
    DocumentParseInsitu_MemoryPoolAllocator
    DocumentParseEncodedInputStream_MemoryStream
    ReaderParse_DummyHandler
    ReaderParse_DummyHandler_Paragraphs
    Writer_StringBuffer
    Writer_StringBuffer_Paragraphs
    PrettyWriter_StringBuffer
)
RAPIDJSON_ARCH_SUFFIXES=(SSE2 SSE42 NEON)
RAPIDJSON_SMOKE_CASE="DocumentParse_MemoryPoolAllocator"
RAPIDJSON_ARCH_SUFFIX=""

log_message() { printf '[rapidjson] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

# Every scenario enumerates the three architecture suffixes explicitly: a `_*`
# wildcard would also match sibling cases such as Writer_StringBuffer_Booleans.
rapidjson_gtest_filter() {
    local case_name="$1" suffix out=""
    for suffix in "${RAPIDJSON_ARCH_SUFFIXES[@]}"; do
        [[ -z "${out}" ]] || out+=":"
        out+="RapidJson.${case_name}_${suffix}"
    done
    printf '%s\n' "${out}"
}

rapidjson_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) log_message "ERROR: unsupported architecture: $1" >&2; return 20 ;;
    esac
}

rapidjson_repo_root() {
    local root
    root="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel 2>/dev/null || true)"
    if [[ -n "${root}" ]]; then
        printf '%s\n' "${root}"
    else
        printf '%s\n' "$(cd "${SCRIPT_DIR}/../../.." && pwd)"
    fi
}

rapidjson_configure_paths() {
    local arch root
    arch="$(rapidjson_arch "${EXPECTED_ARCH}")"
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || { log_message "ERROR: unsafe run ID: ${PERF_RUN_ID}"; return 10; }
    root="$(rapidjson_repo_root)"
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        if [[ "${STANDALONE_OWNS_WORK_DIR}" -eq 1 ]]; then
            PERF_WORK_DIR="${root}/.perf-work/rapidjson/${SOFTWARE_VERSION}/${arch}/${PERF_RUN_ID}"
        else
            PERF_WORK_DIR="/home/runner/boostkit-perf/rapidjson/${SOFTWARE_VERSION}/${arch}/${PERF_RUN_ID}"
        fi
    fi
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${root}/.perf-output/HPC/rapidjson/${SOFTWARE_VERSION}/${arch}/${PERF_RUN_ID}"
    fi
    [[ "${PERF_WORK_DIR}" == /* && "${PERF_WORK_DIR}" != *'/../'* ]] || { log_message 'ERROR: work directory must be an absolute safe path'; return 10; }
    [[ "${RESULTS_DIR}" == /* ]] || { log_message 'ERROR: results directory must be absolute'; return 10; }
    [[ "${PERF_WORK_DIR}" != *'/../'* && "${RESULTS_DIR}" != *'/../'* ]] || { log_message 'ERROR: directories must not contain ..'; return 10; }
    [[ "${PERF_WORK_DIR}" != "${RESULTS_DIR}" ]] || { log_message 'ERROR: work and result directories must differ'; return 10; }
    export PERF_RUN_ID PERF_WORK_DIR RESULTS_DIR SOFTWARE_VERSION PERF_VARIANT EXPECTED_ARCH
}

rapidjson_initialize_runtime() {
    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}"
    log_message "runtime: arch=$(rapidjson_arch "${EXPECTED_ARCH}") variant=${PERF_VARIANT} run_id=${PERF_RUN_ID}"
    log_message "work directory: ${PERF_WORK_DIR}"
    log_message "results directory: ${RESULTS_DIR}"
}

rapidjson_downloads_dir() { printf '%s/downloads\n' "${PERF_WORK_DIR}"; }

rapidjson_source_dir() {
    case "${1:-${PERF_VARIANT}}" in
        base) printf '%s/%s\n' "${PERF_WORK_DIR}" "${RAPIDJSON_SOURCE_ROOT}" ;;
        optimized) printf '%s/%s\n' "${PERF_WORK_DIR}" "${RAPIDJSON_OPTIMIZED_ROOT}" ;;
        *) log_message "ERROR: unsupported build variant: ${1:-}" >&2; return 20 ;;
    esac
}

rapidjson_build_dir() {
    case "${1:-${PERF_VARIANT}}" in
        base|optimized) printf '%s/build-%s\n' "${PERF_WORK_DIR}" "${1:-${PERF_VARIANT}}" ;;
        *) log_message "ERROR: unsupported build variant: ${1:-}" >&2; return 20 ;;
    esac
}

rapidjson_verify_archive() {
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
rapidjson_fetch_archive() {
    local name="$1" url="$2" expected="$3" target_dir="$4" source="${RAPIDJSON_OFFLINE_DIR}/${1}" dest
    mkdir -p "${target_dir}"
    dest="${target_dir}/${name}"
    if [[ -s "${source}" ]]; then
        log_message "using offline archive ${source}"
        cp -- "${source}" "${dest}.part" || return 30
    else
        log_message "downloading ${url}"
        if [[ -n "${PERF_PROXY:-}" ]]; then
            http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" curl -fSL --retry 3 --connect-timeout 30 -o "${dest}.part" "${url}" || return 30
        else
            curl -fSL --retry 3 --connect-timeout 30 -o "${dest}.part" "${url}" || return 30
        fi
    fi
    rapidjson_verify_archive "${dest}.part" "${expected}" || { rm -f -- "${dest}.part"; return 30; }
    mv -f -- "${dest}.part" "${dest}"
    printf '%s  %s\n' "${expected}" "${name}" >> "${target_dir}/sha256sums.txt"
    log_message "verified ${name} ($(stat -c '%s' "${dest}") bytes, sha256 ${expected})"
}

rapidjson_fetch_inputs() {
    local downloads
    downloads="$(rapidjson_downloads_dir)"
    mkdir -p "${downloads}"
    : > "${downloads}/sha256sums.txt"
    rapidjson_fetch_archive "${RAPIDJSON_SOURCE_ARCHIVE}" "${RAPIDJSON_SOURCE_URL}" \
        "${RAPIDJSON_SOURCE_SHA256}" "${downloads}" || return $?
    rapidjson_fetch_archive "${RAPIDJSON_GTEST_ARCHIVE}" "${RAPIDJSON_GTEST_URL}" \
        "${RAPIDJSON_GTEST_SHA256}" "${downloads}" || return $?
    ( cd "${downloads}" && sha256sum -c sha256sums.txt >/dev/null ) || {
        log_message 'ERROR: archive manifest verification failed'
        return 30
    }
}

# The Kunpeng patch ships with the case.  A missing or modified copy must fail
# the optimized build; it never falls back to the unpatched base source tree.
rapidjson_verify_patch() {
    local patch="${SCRIPT_DIR}/fixtures/${RAPIDJSON_PATCH_FILE}" size actual
    if [[ ! -s "${patch}" ]]; then
        log_message "ERROR: the Kunpeng patch is missing: ${patch}"
        log_message 'ERROR: the optimized variant is not built without the pinned patch; refusing to fall back to base'
        return 30
    fi
    size="$(stat -c '%s' "${patch}")"
    if [[ "${size}" != "${RAPIDJSON_PATCH_BYTES}" ]]; then
        log_message "ERROR: ${RAPIDJSON_PATCH_FILE} is ${size} bytes, expected ${RAPIDJSON_PATCH_BYTES}"
        return 30
    fi
    actual="$(sha256sum "${patch}")"
    actual="${actual%% *}"
    if [[ "${actual}" != "${RAPIDJSON_PATCH_SHA256}" ]]; then
        log_message "ERROR: sha256 mismatch for ${RAPIDJSON_PATCH_FILE}: expected ${RAPIDJSON_PATCH_SHA256}, got ${actual}"
        log_message 'ERROR: the optimized variant is not built with an unverified patch; refusing to fall back to base'
        return 30
    fi
    log_message "verified ${RAPIDJSON_PATCH_FILE} (${size} bytes, sha256 ${actual})"
}

rapidjson_image_archive() {
    local arch
    arch="$(rapidjson_arch "${EXPECTED_ARCH}")"
    local archive="${RAPIDJSON_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}/openEuler-docker.${arch}.tar.xz"
    if [[ -s "${archive}" ]]; then
        printf '%s\n' "${archive}"
    elif [[ -s "${PERF_WORK_DIR}/openEuler-docker.${arch}.tar.xz" ]]; then
        printf '%s\n' "${PERF_WORK_DIR}/openEuler-docker.${arch}.tar.xz"
    fi
}

rapidjson_write_build_variant() {
    local variant="${PERF_VARIANT}" arch build output image archive meta
    local gcc_version perftest_sha unittest_sha cxx_flags release_flags arch_suffix
    local image_sha effective_flags
    arch="$(rapidjson_arch "${EXPECTED_ARCH}")"
    build="$(rapidjson_build_dir)"
    output="${RESULTS_DIR}/build_variant.json"
    meta="${RESULTS_DIR}/.build_variant_meta.tsv"
    image="${RAPIDJSON_CONTAINER_IMAGE:-unknown}"
    archive="$(rapidjson_image_archive || true)"
    gcc_version="$(rapidjson_container_exec bash -c 'gcc --version | head -n 1')" || gcc_version=unknown
    perftest_sha="$(rapidjson_container_exec sha256sum "${build}/bin/perftest")" || return 40
    perftest_sha="${perftest_sha%% *}"
    unittest_sha="$(rapidjson_container_exec sha256sum "${build}/bin/unittest")" || return 40
    unittest_sha="${unittest_sha%% *}"
    cxx_flags="$(rapidjson_container_exec bash -c 'sed -n "s/^CMAKE_CXX_FLAGS:STRING=//p" "$1/CMakeCache.txt" | head -n 1' _ "${build}")" || cxx_flags=unknown
    release_flags="$(rapidjson_container_exec bash -c 'sed -n "s/^CMAKE_CXX_FLAGS_RELEASE:STRING=//p" "$1/CMakeCache.txt" | head -n 1' _ "${build}")" || release_flags=unknown
    arch_suffix="${RAPIDJSON_ARCH_SUFFIX:-unknown}"
    image_sha="unknown"
    if [[ -n "${archive}" && -s "${archive}" ]]; then
        image_sha="$(sha256sum "${archive}")"
        image_sha="${image_sha%% *}"
    fi
    # The upstream project appends -march=native and -Werror to CMAKE_CXX_FLAGS,
    # so the cache values above understate the macros that actually take effect.
    effective_flags="$(rapidjson_container_exec bash -c '
        file="$1/test/perftest/CMakeFiles/perftest.dir/flags.make"
        if [ -f "${file}" ]; then
            sed -n "s/^CXX_FLAGS = //p" "${file}" | head -n 1
        fi' _ "${build}")" || effective_flags=unknown
    : > "${meta}"
    {
        printf 'variant\t%s\n' "${variant}"
        printf 'version\t%s\n' "${SOFTWARE_VERSION}"
        printf 'architecture\t%s\n' "${arch}"
        printf 'run_id\t%s\n' "${PERF_RUN_ID}"
        printf 'container_name\t%s\n' "${RAPIDJSON_CONTAINER_NAME:-unknown}"
        printf 'container_image\t%s\n' "${image}"
        printf 'image_archive\t%s\n' "${archive:-unknown}"
        printf 'image_archive_sha256\t%s\n' "${image_sha}"
        printf 'source_sha256\t%s\n' "${RAPIDJSON_SOURCE_SHA256}"
        printf 'source_bytes\t%s\n' "${RAPIDJSON_SOURCE_BYTES}"
        printf 'gtest_sha256\t%s\n' "${RAPIDJSON_GTEST_SHA256}"
        printf 'gtest_bytes\t%s\n' "${RAPIDJSON_GTEST_BYTES}"
        printf 'patch_sha256\t%s\n' "${RAPIDJSON_PATCH_SHA256}"
        printf 'patch_bytes\t%s\n' "${RAPIDJSON_PATCH_BYTES}"
        printf 'patch_file\t%s\n' "${RAPIDJSON_PATCH_FILE}"
        printf 'gcc_version\t%s\n' "${gcc_version}"
        printf 'cxx_flags\t%s\n' "${cxx_flags}"
        printf 'cxx_flags_release\t%s\n' "${release_flags}"
        printf 'effective_cxx_flags\t%s\n' "${effective_flags:-unknown}"
        printf 'arch_suffix\t%s\n' "${arch_suffix}"
        printf 'perftest_sha256\t%s\n' "${perftest_sha}"
        printf 'unittest_sha256\t%s\n' "${unittest_sha}"
        printf 'warmups\t%s\n' "${RAPIDJSON_WARMUPS}"
        printf 'reps\t%s\n' "${PERF_REPS}"
        printf 'gtest_repeat\t%s\n' "${RAPIDJSON_GTEST_REPEAT}"
    } >> "${meta}"
    python3 - "${meta}" "${output}" <<'PY'
import json
import sys

meta_path, output_path = sys.argv[1:]
fields = {}
with open(meta_path, encoding="utf-8") as handle:
    for line in handle:
        key, _tab, value = line.rstrip("\n").partition("\t")
        fields[key] = value
image = fields["container_image"]
image_archive = fields["image_archive"]
image_sha = fields["image_archive_sha256"]
macros = {
    "SSE2": ["RAPIDJSON_SSE2"],
    "SSE42": ["RAPIDJSON_SSE42"],
    "NEON": ["RAPIDJSON_NEON"],
}.get(fields["arch_suffix"], [])
payload = {
    "software": "rapidjson",
    "variant": fields["variant"],
    "version": fields["version"],
    "architecture": fields["architecture"],
    "run_id": fields["run_id"],
    "container": {
        "name": fields["container_name"],
        "image": image,
        "network": "host",
        "cpu_quota": "unlimited",
        "memory_quota": "unlimited",
        "numa_policy": "unlimited",
    },
    "sources": {
        "rapidjson_archive": {
            "name": "rapidjson-1.1.0.tar.gz",
            "url": "https://codeload.github.com/Tencent/rapidjson/tar.gz/24b5e7a8b27f42fa16b96fc70aade9106cf7102f",
            "bytes": int(fields["source_bytes"]),
            "sha256": fields["source_sha256"],
        },
        "googletest_archive": {
            "name": "googletest-release-1.12.1.tar.gz",
            "url": "https://codeload.github.com/google/googletest/tar.gz/refs/tags/release-1.12.1",
            "bytes": int(fields["gtest_bytes"]),
            "sha256": fields["gtest_sha256"],
        },
        "kunpeng_patch": {
            "name": fields["patch_file"],
            "bytes": int(fields["patch_bytes"]),
            "sha256": fields["patch_sha256"],
            "applied": fields["variant"] == "optimized",
        },
        "container_image": {
            "reference": image,
            "archive": image_archive,
            "sha256": image_sha,
        },
    },
    "binaries": {
        "perftest": fields["perftest_sha256"],
        "unittest": fields["unittest_sha256"],
    },
    "compiler": fields["gcc_version"],
    "compile": {
        "cmake_cxx_flags": fields["cxx_flags"],
        "cmake_cxx_flags_release": fields["cxx_flags_release"],
        "effective_cxx_flags": fields["effective_cxx_flags"],
        "gtest_architecture_suffix": fields["arch_suffix"],
        "architecture_macros": macros,
    },
    "parameters": {
        "variant": fields["variant"],
        "warmups": int(fields["warmups"]),
        "reps": int(fields["reps"]),
        "gtest_repeat": int(fields["gtest_repeat"]),
    },
}
with open(output_path, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, ensure_ascii=False, indent=2)
    handle.write("\n")
PY
    rm -f -- "${meta}"
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
RAPIDJSON_IMAGE_ARCHIVE_DIR="${RAPIDJSON_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}"
RAPIDJSON_CA_ANCHORS_DIR="${RAPIDJSON_CA_ANCHORS_DIR:-/home/runner/software/anchors}"
RAPIDJSON_CONTAINER_IMAGE="${RAPIDJSON_CONTAINER_IMAGE:-}"
RAPIDJSON_CONTAINER_NAME="${RAPIDJSON_CONTAINER_NAME:-}"
RAPIDJSON_CONTAINER_HOME="${RAPIDJSON_CONTAINER_HOME:-}"
declare -p RAPIDJSON_CONTAINER_EXTRA_ARGS >/dev/null 2>&1 || RAPIDJSON_CONTAINER_EXTRA_ARGS=()

rapidjson_normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

rapidjson_configure_container() {
    local arch
    arch="$(rapidjson_normalize_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    [ -n "${RAPIDJSON_CONTAINER_NAME}" ] || RAPIDJSON_CONTAINER_NAME="boostkit-rapidjson-${arch}-${PERF_RUN_ID}"
    [ -n "${RAPIDJSON_CONTAINER_HOME}" ] || RAPIDJSON_CONTAINER_HOME="${PERF_WORK_DIR}/home"
    export RAPIDJSON_CONTAINER_NAME RAPIDJSON_CONTAINER_HOME
}

rapidjson_with_proxy() {
    if [ -n "${PERF_PROXY:-}" ]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" no_proxy="localhost,127.0.0.1,::1" "$@"
    else
        "$@"
    fi
}

require_rapidjson_docker() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        log_message 'ERROR: an accessible Docker daemon is required for the private container'
        return 30
    fi
}

verify_rapidjson_container_image_release() {
    local release
    release="$(docker run --rm --network=none "${RAPIDJSON_CONTAINER_IMAGE}" cat /etc/os-release 2>/dev/null)" || {
        log_message 'ERROR: cannot read the loaded openEuler image release'
        return 30
    }
    case "${release}" in
        *'24.03'*) ;;
        *) log_message 'ERROR: loaded container image is not openEuler 24.03 LTS SP4'; return 30 ;;
    esac
}

prepare_rapidjson_container_image() {
    local arch archive_name archive checksum image_url load_output image_architecture
    arch="$(rapidjson_normalize_arch "${EXPECTED_ARCH}")"
    archive_name="openEuler-docker.${arch}.tar.xz"
    image_url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${arch}/${archive_name}"
    mkdir -p "${RAPIDJSON_IMAGE_ARCHIVE_DIR}" "${PERF_WORK_DIR}" || return 30
    archive="${RAPIDJSON_IMAGE_ARCHIVE_DIR}/${archive_name}"
    checksum="${archive}.sha256sum"
    if [ ! -s "${archive}" ]; then
        log_message "downloading openEuler container image archive: ${image_url}"
        archive="${PERF_WORK_DIR}/${archive_name}"
        rapidjson_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${archive}.part" "${image_url}" || return 30
        mv -f "${archive}.part" "${archive}" || return 30
        rapidjson_with_proxy curl -fSL --retry 3 --connect-timeout 30 -o "${checksum}" "${image_url}.sha256sum" || return 30
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
    RAPIDJSON_CONTAINER_IMAGE="$(printf '%s\n' "${load_output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
    if [ -z "${RAPIDJSON_CONTAINER_IMAGE}" ] || ! docker image inspect "${RAPIDJSON_CONTAINER_IMAGE}" >/dev/null 2>&1; then
        log_message "ERROR: docker load did not report an inspectable image: ${load_output}"
        return 30
    fi
    image_architecture="$(docker image inspect --format '{{.Architecture}}' "${RAPIDJSON_CONTAINER_IMAGE}")"
    case "${arch}:${image_architecture}" in
        x86_64:amd64|aarch64:arm64) ;;
        *)
            log_message "ERROR: loaded image architecture is ${image_architecture}, expected ${arch}"
            return 30
            ;;
    esac
    verify_rapidjson_container_image_release || return $?
    export RAPIDJSON_CONTAINER_IMAGE
    log_message "openEuler container image is ready: ${RAPIDJSON_CONTAINER_IMAGE} (${image_architecture})"
}

sweep_rapidjson_stale_containers() {
    local name label names
    command -v docker >/dev/null 2>&1 || return 0
    names="$(docker ps -a --filter "name=^boostkit-rapidjson-" --format '{{.Names}}' 2>/dev/null || true)"
    [ -n "${names}" ] || return 0
    while IFS= read -r name; do
        [ -n "${name}" ] || continue
        [ "${name}" = "${RAPIDJSON_CONTAINER_NAME}" ] && continue
        label="$(docker inspect --format '{{index .Config.Labels "boostkit.rapidjson.run-id"}}' "${name}" 2>/dev/null || true)"
        [ -n "${label}" ] || continue
        [ "${label}" = "${PERF_RUN_ID}" ] && continue
        docker rm --force "${name}" >/dev/null 2>&1 || true
        log_message "removed stale container from an earlier run: ${name}"
    done <<< "${names}"
}

start_rapidjson_container() {
    local -a cert_mount=()
    local case_dir_mount_suffix=""
    rapidjson_configure_container
    require_rapidjson_docker || return $?
    if docker container inspect "${RAPIDJSON_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing container: ${RAPIDJSON_CONTAINER_NAME}"
        return 40
    fi
    sweep_rapidjson_stale_containers || true
    prepare_rapidjson_container_image || return $?
    # The case directory carries the benchmark sources and the timing harness, so
    # it is mounted read-only unless the standalone entry point keeps its results
    # inside the case directory.
    case "${RESULTS_DIR}" in
        "${SCRIPT_DIR}"/*) ;;
        *) case_dir_mount_suffix=",readonly" ;;
    esac
    if [ -n "${PERF_PROXY:-}" ]; then
        [ -d "${RAPIDJSON_CA_ANCHORS_DIR}" ] || {
            log_message "ERROR: proxy CA directory is missing: ${RAPIDJSON_CA_ANCHORS_DIR}"
            return 30
        }
        cert_mount+=(--mount "type=bind,source=${RAPIDJSON_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    mkdir -p "${RAPIDJSON_CONTAINER_HOME}" || return 40
    log_message "starting private container ${RAPIDJSON_CONTAINER_NAME} (host network, shared work and result directories)"
    docker run --detach --name "${RAPIDJSON_CONTAINER_NAME}" \
        --label "boostkit.rapidjson.run-id=${PERF_RUN_ID}" \
        --network=host \
        --user "$(id -u):$(id -g)" \
        --ulimit nofile=1048576:1048576 \
        --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
        --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
        --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR}${case_dir_mount_suffix}" \
        --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
        --mount type=bind,source=/etc/group,target=/etc/group,readonly \
        "${cert_mount[@]}" "${RAPIDJSON_CONTAINER_EXTRA_ARGS[@]}" \
        "${RAPIDJSON_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40
    if [ -n "${PERF_PROXY:-}" ]; then
        docker exec --user 0 "${RAPIDJSON_CONTAINER_NAME}" update-ca-trust extract || {
            log_message 'ERROR: failed to update CA trust in the container'
            return 30
        }
    fi
    if docker exec --user 0 "${RAPIDJSON_CONTAINER_NAME}" test -f /etc/yum.repos.d/openEuler.repo; then
        log_message 'switching private container repositories to the Huawei openEuler mirror'
        docker exec --user 0 "${RAPIDJSON_CONTAINER_NAME}" sed -i \
            -e '/^meta/ s/^\(.*\)$/#\1/g' \
            -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
            /etc/yum.repos.d/openEuler.repo || {
            log_message 'ERROR: failed to switch the container repositories to the Huawei mirror'
            return 30
        }
    fi
    log_message "private container is running: ${RAPIDJSON_CONTAINER_NAME}"
}

check_rapidjson_container() {
    rapidjson_configure_container
    [ "$(docker inspect --format '{{.State.Running}}' "${RAPIDJSON_CONTAINER_NAME}" 2>/dev/null)" = "true" ] || {
        log_message "ERROR: managed container is not running: ${RAPIDJSON_CONTAINER_NAME}"
        return 40
    }
}

rapidjson_docker_exec() {
    local workdir="$1" user="$2"
    shift 2
    rapidjson_configure_container
    local -a options=()
    local -a proxy=()
    [ -z "${PERF_PROXY:-}" ] || proxy=(-e "http_proxy=${PERF_PROXY}" -e "https_proxy=${PERF_PROXY}" -e 'no_proxy=localhost,127.0.0.1,::1')
    options+=("${proxy[@]}")
    options+=(-e "HOME=${RAPIDJSON_CONTAINER_HOME}" -e "TMPDIR=${TMPDIR:-/tmp}" -e "PERF_RUN_ID=${PERF_RUN_ID}")
    [ -z "${workdir}" ] || options+=(--workdir "${workdir}")
    [ "${user}" != "root" ] || options+=(--user 0)
    docker exec "${options[@]}" "${RAPIDJSON_CONTAINER_NAME}" "$@"
}

rapidjson_container_exec() { rapidjson_docker_exec '' '' "$@"; }

rapidjson_container_exec_at() {
    local workdir="$1"
    shift
    rapidjson_docker_exec "${workdir}" '' "$@"
}

rapidjson_container_exec_root() { rapidjson_docker_exec '' root "$@"; }

rapidjson_container_exec_root_at() {
    local workdir="$1"
    shift
    rapidjson_docker_exec "${workdir}" root "$@"
}

remove_rapidjson_container() {
    rapidjson_configure_container
    command -v docker >/dev/null 2>&1 || return 0
    docker container inspect "${RAPIDJSON_CONTAINER_NAME}" >/dev/null 2>&1 || return 0
    if [ "$(docker inspect --format '{{index .Config.Labels "boostkit.rapidjson.run-id"}}' "${RAPIDJSON_CONTAINER_NAME}" 2>/dev/null)" != "${PERF_RUN_ID}" ]; then
        log_message "ERROR: refusing to remove a container without this task's run-id label: ${RAPIDJSON_CONTAINER_NAME}"
        return 60
    fi
    docker stop --time 30 "${RAPIDJSON_CONTAINER_NAME}" >/dev/null || return 60
    docker rm "${RAPIDJSON_CONTAINER_NAME}" >/dev/null || return 60
    log_message "removed managed container ${RAPIDJSON_CONTAINER_NAME}"
}
# >>> container-runtime:end
