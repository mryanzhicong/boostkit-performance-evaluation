#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

usage() {
    printf 'Usage: %s [--architecture x86_64|aarch64] [--run-id ID] [--work-dir ABSOLUTE_PATH]\n' "$0"
}

main() {
    local arch="$(jemalloc_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    local run_id="${PERF_RUN_ID:-local-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
    local work_dir="${PERF_WORK_DIR:-}" archive local_archive source_dir prefix version sha
    local -a dnf_options=()
    while (($#)); do
        case "$1" in
            --architecture) arch="$(jemalloc_arch "$2")"; shift 2 ;;
            --run-id) run_id="$2"; shift 2 ;;
            --work-dir) work_dir="$2"; shift 2 ;;
            -h|--help) usage; return 0 ;;
            *) usage >&2; return 10 ;;
        esac
    done
    [[ "${arch}" == "$(jemalloc_arch "$(uname -m)")" ]] || { jemalloc_log 'ERROR: requested architecture differs from host'; return 20; }
    [[ "${SOFTWARE_VERSION:-5.4.0}" == 5.4.0 ]] || { jemalloc_log 'ERROR: only jemalloc 5.4.0 is supported'; return 10; }
    [[ "${run_id}" =~ ^[A-Za-z0-9._-]+$ ]] || { jemalloc_log 'ERROR: unsafe run ID'; return 10; }
    work_dir="${work_dir:-/home/runner/boostkit-perf/jemalloc/5.4.0/${arch}/${run_id}}"
    [[ "${work_dir}" == /home/runner/boostkit-perf/jemalloc/5.4.0/${arch}/* && "${work_dir}" != *'/../'* ]] || {
        jemalloc_log 'ERROR: work directory must be under the private jemalloc version/architecture directory'; return 10;
    }
    command -v docker >/dev/null && docker info >/dev/null || { jemalloc_log 'ERROR: Docker is unavailable'; return 30; }
    mkdir -p "${work_dir}"
    jemalloc_load_image "${arch}" "${work_dir}" || return $?
    jemalloc_start_container "${work_dir}" "${run_id}" || return $?
    JEMALLOC_CLEANUP_RUN_ID="${run_id}"
    trap 'jemalloc_stop_container "${JEMALLOC_CLEANUP_RUN_ID}"' EXIT
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    jemalloc_log 'installing build dependencies inside the private container'
    docker exec --user 0 "${JEMALLOC_CONTAINER}" dnf "${dnf_options[@]}" install -y gcc make tar bzip2 coreutils

    archive="${work_dir}/jemalloc-5.4.0.tar.bz2"
    local_archive="${JEMALLOC_SOURCE_DIR}/jemalloc-5.4.0.tar.bz2"
    if [[ -s "${local_archive}" ]]; then
        jemalloc_log "using local upstream release archive ${local_archive}"
        cp -- "${local_archive}" "${archive}"
    else
        jemalloc_log 'downloading official jemalloc 5.4.0 release archive'
        jemalloc_proxy_curl -fSL --retry 3 --connect-timeout 30 \
            -o "${archive}.part" \
            https://github.com/jemalloc/jemalloc/releases/download/5.4.0/jemalloc-5.4.0.tar.bz2
        mv -- "${archive}.part" "${archive}"
    fi
    sha="$(sha256sum "${archive}")"
    jemalloc_log "source archive SHA-256: ${sha%% *}"
    source_dir="${work_dir}/jemalloc-5.4.0"
    [[ ! -e "${source_dir}" ]] || { jemalloc_log 'ERROR: source directory already exists'; return 20; }
    jemalloc_container_exec tar -xjf "${archive}" -C "${work_dir}"
    jemalloc_container_exec test -x "${source_dir}/configure"
    prefix="${work_dir}/jemalloc-install"
    jemalloc_log 'configuring and building unmodified upstream jemalloc in the container'
    jemalloc_container_exec bash -c 'cd "$1" && ./configure --prefix="$2" && make -j "$(nproc)" && make install' _ "${source_dir}" "${prefix}"
    version="$(jemalloc_container_exec "${prefix}/bin/jemalloc-config" --version)"
    [[ "${version%%-*}" == 5.4.0 ]] || { jemalloc_log "ERROR: built version is ${version}"; return 40; }
    jemalloc_container_exec test -s "${prefix}/lib/libjemalloc.so.2"
    if [[ -n "${PERF_ACTUAL_VERSION_FILE:-}" ]]; then
        mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
        printf '%s\n' "${version%%-*}" > "${PERF_ACTUAL_VERSION_FILE}"
    fi
    if [[ -n "${RESULTS_DIR:-}" ]]; then
        mkdir -p "${RESULTS_DIR}"
        printf '{"variant":"base","parameters":{"variant":"base"}}\n' > "${RESULTS_DIR}/build_variant.json"
    fi
    jemalloc_log "verified jemalloc ${version}: ${prefix}/lib/libjemalloc.so.2"
    trap - EXIT
    jemalloc_log "private build and container retained for start/test: ${work_dir}"
}

main "$@"
