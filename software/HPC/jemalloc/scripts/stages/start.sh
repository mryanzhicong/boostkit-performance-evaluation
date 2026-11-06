#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_jemalloc_runtime() {
    local arch="$(jemalloc_arch "${EXPECTED_ARCH:-$(uname -m)}")"
    local bin=/home/runner/software/jemalloc/malloc_benchmark
    jemalloc_existing_container "${arch}" "${PERF_RUN_ID}" || return $?
    jemalloc_container_exec test -s "${PERF_WORK_DIR}/jemalloc-install/lib/libjemalloc.so.2" || {
        jemalloc_log 'ERROR: private jemalloc library is unavailable inside the container'; return 40;
    }
    [[ -s "${PERF_WORK_DIR}/jemalloc-install/lib/libjemalloc.so.2" ]] || {
        jemalloc_log 'ERROR: private jemalloc library is missing'; return 40;
    }
    [[ -x "${bin}" ]] || { jemalloc_log "ERROR: preinstalled benchmark tool is missing: ${bin}"; return 40; }
    python3 - "${bin}" "${arch}" <<'PY'
import struct
import sys
from pathlib import Path
data = Path(sys.argv[1]).read_bytes()[:20]
machine = {"x86_64": 62, "aarch64": 183}[sys.argv[2]]
if len(data) < 20 or data[:5] != b"\x7fELF\x02" or data[5] != 1 or struct.unpack_from("<H", data, 18)[0] != machine:
    raise SystemExit("preinstalled malloc_benchmark ELF architecture mismatch")
PY
    jemalloc_log "private jemalloc library and ${arch} benchmark tool are ready"
}
