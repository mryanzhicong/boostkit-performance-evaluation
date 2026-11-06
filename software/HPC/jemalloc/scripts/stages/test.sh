#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

usage() {
    printf 'Usage: %s --run-id ID [--architecture x86_64|aarch64] [--threads N] [--work-dir ABSOLUTE_PATH] [--results-dir ABSOLUTE_PATH]\n' "$0"
}

verify_binary_architecture() {
    python3 - "$1" "$2" <<'PY'
import struct
import sys
from pathlib import Path

data = Path(sys.argv[1]).read_bytes()[:20]
if len(data) < 20 or data[:5] != b"\x7fELF\x02" or data[5] != 1:
    raise SystemExit("benchmark tool must be a 64-bit little-endian ELF executable")
machine = struct.unpack_from("<H", data, 18)[0]
expected = {"x86_64": 62, "aarch64": 183}[sys.argv[2]]
if machine != expected:
    raise SystemExit(f"benchmark ELF machine {machine} differs from requested {sys.argv[2]}")
PY
}

main() {
    local arch="$(jemalloc_arch "${EXPECTED_ARCH:-$(uname -m)}")" run_id="${PERF_RUN_ID:-}"
    local work_dir="${PERF_WORK_DIR:-}" results_dir="${RESULTS_DIR:-}"
    local threads=384 source_bin=/home/runner/software/jemalloc/malloc_benchmark bin lib hash mode
    while (($#)); do
        case "$1" in
            --architecture) arch="$(jemalloc_arch "$2")"; shift 2 ;;
            --run-id) run_id="$2"; shift 2 ;;
            --threads) threads="$2"; shift 2 ;;
            --work-dir) work_dir="$2"; shift 2 ;;
            --results-dir) results_dir="$2"; shift 2 ;;
            -h|--help) usage; return 0 ;;
            *) usage >&2; return 10 ;;
        esac
    done
    [[ -n "${run_id}" && "${run_id}" =~ ^[A-Za-z0-9._-]+$ ]] || { jemalloc_log 'ERROR: --run-id is required and must be safe'; return 10; }
    [[ "${SOFTWARE_VERSION:-5.4.0}" == 5.4.0 ]] || { jemalloc_log 'ERROR: only jemalloc 5.4.0 is supported'; return 10; }
    [[ "${threads}" =~ ^[1-9][0-9]*$ ]] || { jemalloc_log 'ERROR: threads must be a positive integer'; return 10; }
    [[ "${arch}" == "$(jemalloc_arch "$(uname -m)")" ]] || { jemalloc_log 'ERROR: architecture differs from host'; return 20; }
    work_dir="${work_dir:-/home/runner/boostkit-perf/jemalloc/5.4.0/${arch}/${run_id}}"
    [[ "${work_dir}" == /home/runner/boostkit-perf/jemalloc/5.4.0/${arch}/* && "${work_dir}" != *'/../'* ]] || {
        jemalloc_log 'ERROR: work directory must be under the private jemalloc version/architecture directory'; return 10;
    }
    results_dir="${results_dir:-${work_dir}/results}"
    [[ "${results_dir}" == /* ]] || { jemalloc_log 'ERROR: results directory must be absolute'; return 10; }
    [[ -x "${source_bin}" ]] || { jemalloc_log "ERROR: preinstalled benchmark tool is missing: ${source_bin}"; return 30; }
    verify_binary_architecture "${source_bin}" "${arch}" || return 30
    lib="${work_dir}/jemalloc-install/lib/libjemalloc.so.2"
    [[ -s "${lib}" ]] || { jemalloc_log "ERROR: private jemalloc build is missing: ${lib}"; return 40; }
    mkdir -p "${results_dir}" "${work_dir}/benchmark-tool"
    bin="${work_dir}/benchmark-tool/malloc_benchmark"
    cp -- "${source_bin}" "${bin}"
    chmod u+x "${bin}"
    hash="$(sha256sum "${bin}")"
    hash="${hash%% *}"
    command -v docker >/dev/null && docker info >/dev/null || { jemalloc_log 'ERROR: Docker is unavailable'; return 30; }
    jemalloc_existing_container "${arch}" "${run_id}" || return $?
    JEMALLOC_CLEANUP_RUN_ID="${run_id}"
    trap 'jemalloc_stop_container "${JEMALLOC_CLEANUP_RUN_ID}"' EXIT
    jemalloc_container_exec env "LD_PRELOAD=${lib}" bash -c 'grep -F "$LD_PRELOAD" "/proc/$$/maps" >/dev/null' || {
        jemalloc_log 'ERROR: private jemalloc library is not loaded by LD_PRELOAD'; return 40;
    }
    jemalloc_container_exec test -x "${bin}"
    for mode in 0 1 2; do
        jemalloc_log "running mode ${mode}: ${threads} threads, affinity disabled"
        jemalloc_container_exec env "LD_PRELOAD=${lib}" "${bin}" \
            -mode "${mode}" -threads "${threads}" -affinity 0 \
            > "${results_dir}/benchmark_mode_${mode}.log" 2>&1 || {
            jemalloc_log "ERROR: benchmark mode ${mode} failed; inspect ${results_dir}/benchmark_mode_${mode}.log"
            return 50
        }
        tail -n 2 "${results_dir}/benchmark_mode_${mode}.log"
    done
    python3 "$(dirname "${BASH_SOURCE[0]}")/../results/parse_benchmark.py" \
        --results-dir "${results_dir}" --threads "${threads}" --binary-sha256 "${hash}" || return 50
    trap - EXIT
    jemalloc_log "three-mode result: ${results_dir}/benchmark_jemalloc.json"
}

main "$@"
