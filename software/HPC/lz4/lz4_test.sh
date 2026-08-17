#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.9.4}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
RESULTS_DIR="${RESULTS_DIR:-${SCRIPT_DIR}/results/${SOFTWARE_VERSION}}"
PERF_WORK_DIR="${PERF_WORK_DIR:-/tmp/boostkit-perf/local/HPC/lz4/${SOFTWARE_VERSION}}"
LZ4_SOURCE_URL="${LZ4_SOURCE_URL:-https://github.com/lz4/lz4.git}"
SOURCE_DIR="${PERF_WORK_DIR}/lz4-source"
FULLBENCH_BIN="${SOURCE_DIR}/tests/fullbench"
readonly SILESIA_REPOSITORY_URL="https://github.com/MiloszKrajewski/SilesiaCorpus.git"
readonly SILESIA_REPOSITORY_COMMIT="3f3fa2cdbbb3795c903b74e774acb309e1360337"
CORPUS_DIR="${PERF_WORK_DIR}/dataset"
CORPUS_SOURCE_DIR="${CORPUS_DIR}/SilesiaCorpus"
CORPUS_PATH="${CORPUS_DIR}/silesia.tar"

log() { printf '[lz4] %s\n' "$*"; }

initialize_runtime() {
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR:-${PERF_WORK_DIR}/tmp}"
}

normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

require_commands() {
    local command missing=0
    for command in git python3 make cc sed; do
        if ! command -v "${command}" >/dev/null 2>&1; then
            log "ERROR: required command is missing: ${command}"
            missing=1
        fi
    done
    [[ "${missing}" -eq 0 ]]
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

read_header_version() {
    local header="$1" major minor release
    major="$(sed -n 's/^#define LZ4_VERSION_MAJOR[[:space:]]\+\([0-9][0-9]*\).*/\1/p' "${header}")"
    minor="$(sed -n 's/^#define LZ4_VERSION_MINOR[[:space:]]\+\([0-9][0-9]*\).*/\1/p' "${header}")"
    release="$(sed -n 's/^#define LZ4_VERSION_RELEASE[[:space:]]\+\([0-9][0-9]*\).*/\1/p' "${header}")"
    [[ -n "${major}" && -n "${minor}" && -n "${release}" ]] || return 1
    printf '%s.%s.%s\n' "${major}" "${minor}" "${release}"
}

build_lz4() {
    local tag actual_version
    initialize_runtime
    check_architecture
    require_commands
    [[ ! -e "${SOURCE_DIR}" ]] || {
        log "ERROR: source directory is not clean under ${PERF_WORK_DIR}"
        return 20
    }

    tag="${SOFTWARE_VERSION}"
    [[ "${tag}" == v* ]] || tag="v${tag}"
    log "cloning LZ4 ${tag} from ${LZ4_SOURCE_URL}"
    git clone --branch "${tag}" --depth 1 "${LZ4_SOURCE_URL}" "${SOURCE_DIR}"
    log "building the official tests/fullbench target"
    (cd "${SOURCE_DIR}" && make -C tests fullbench)
    [[ -x "${FULLBENCH_BIN}" ]] || {
        log "ERROR: official fullbench executable was not created"
        return 40
    }

    actual_version="$(read_header_version "${SOURCE_DIR}/lib/lz4.h")" || {
        log "ERROR: cannot read the built LZ4 version"
        return 40
    }
    : "${PERF_ACTUAL_VERSION_FILE:?Framework did not provide PERF_ACTUAL_VERSION_FILE}"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
}

start_lz4_runtime() {
    local downloaded_commit
    initialize_runtime
    [[ -x "${FULLBENCH_BIN}" ]] || {
        log "ERROR: official fullbench executable is unavailable"
        return 40
    }
    [[ ! -e "${CORPUS_DIR}" ]] || {
        log "ERROR: corpus work directory is not clean: ${CORPUS_DIR}"
        return 20
    }
    mkdir -p "${CORPUS_SOURCE_DIR}"
    git -C "${CORPUS_SOURCE_DIR}" init --quiet
    git -C "${CORPUS_SOURCE_DIR}" remote add origin "${SILESIA_REPOSITORY_URL}"
    log "downloading Silesia Corpus commit ${SILESIA_REPOSITORY_COMMIT} from GitHub"
    git -C "${CORPUS_SOURCE_DIR}" fetch --quiet --depth 1 --no-tags \
        origin "${SILESIA_REPOSITORY_COMMIT}"
    git -C "${CORPUS_SOURCE_DIR}" checkout --quiet --detach FETCH_HEAD
    downloaded_commit="$(git -C "${CORPUS_SOURCE_DIR}" rev-parse HEAD)"
    [[ "${downloaded_commit}" == "${SILESIA_REPOSITORY_COMMIT}" ]] || {
        log "ERROR: downloaded Silesia commit ${downloaded_commit}, expected ${SILESIA_REPOSITORY_COMMIT}"
        return 20
    }
    python3 "${SCRIPT_DIR}/scripts/prepare_silesia.py" \
        "${CORPUS_SOURCE_DIR}" "${CORPUS_PATH}"
}

run_lz4_benchmarks() {
    initialize_runtime
    [[ -x "${FULLBENCH_BIN}" ]] || {
        log "ERROR: official fullbench executable is unavailable"
        return 40
    }
    [[ -f "${CORPUS_PATH}" && -s "${CORPUS_PATH}" ]] || {
        log "ERROR: isolated Silesia corpus is unavailable"
        return 50
    }
    export SOFTWARE_VERSION EXPECTED_ARCH
    export SILESIA_REPOSITORY_URL SILESIA_REPOSITORY_COMMIT
    python3 "${SCRIPT_DIR}/scripts/run_fullbench.py" \
        "${FULLBENCH_BIN}" "${CORPUS_PATH}" "${RESULTS_DIR}/benchmark_fullbench.json"
}

stop_lz4_runtime() {
    log "LZ4 fullbench has no background service to stop"
}
