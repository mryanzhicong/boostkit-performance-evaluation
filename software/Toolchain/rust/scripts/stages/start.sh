#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# List the Primary compile benchmarks and every runtime benchmark group that
# the formal run will execute, so their locked dependencies can be prefetched
# before any timing takes place.
list_benchmark_crate_dirs() {
    python3 - "${RUSTC_PERF_DIR}" <<'PY' || return 40
import json
import sys
from pathlib import Path

root = Path(sys.argv[1])


def crate_dirs(base: Path, primary_only: bool) -> list[str]:
    dirs = []
    for entry in sorted(base.iterdir()):
        config = entry / "perf-config.json"
        if not (entry / "Cargo.toml").is_file():
            continue
        if primary_only:
            payload = json.loads(config.read_text(encoding="utf-8"))
            if payload.get("category") != "primary":
                continue
        dirs.append(str(entry))
    return dirs


for path in crate_dirs(root / "collector" / "compile-benchmarks", True) + \
        crate_dirs(root / "collector" / "runtime-benchmarks", False):
    print(path)
PY
}

prefetch_benchmark_dependencies() {
    local crate_list="${PERF_WORK_DIR}/benchmark-crates.txt"
    local crate_dir relative
    log_message 'prefetching locked dependencies for every selected benchmark inside the container'
    list_benchmark_crate_dirs > "${crate_list}" || return 40
    [[ -s "${crate_list}" ]] || {
        log_message 'ERROR: no benchmark crates were selected for prefetching'
        return 40
    }
    while IFS= read -r crate_dir; do
        [[ -n "${crate_dir}" ]] || continue
        relative="${crate_dir#${PERF_WORK_DIR}/}"
        container_exec sh -c \
            "export PATH='${RUST_HOME}/bin:\$PATH' && cd '${PERF_WORK_DIR}/${relative}' && cargo fetch --locked --quiet" || {
            log_message "ERROR: cargo fetch failed for ${crate_dir}"
            return 40
        }
    done < "${crate_list}"
}

start_rust_runtime() {
    initialize_runtime || return $?
    check_rust_container || return $?
    container_exec test -x "${RUSTC_BIN}" || {
        log_message 'ERROR: Rust toolchain is missing; build stage did not complete'
        return 40
    }
    container_exec test -x "${COLLECTOR_BIN}" || {
        log_message 'ERROR: collector binary is missing; build stage did not complete'
        return 40
    }
    container_exec command -v perf >/dev/null 2>&1 || {
        log_message 'ERROR: perf is required by the upstream collector'
        return 40
    }
    container_exec perf stat -e instructions:u,cycles:u true >/dev/null 2>&1 || {
        log_message 'ERROR: perf cannot read user-space hardware counters in the container'
        return 40
    }
    local actual_version
    actual_version="$(< "${PERF_ACTUAL_VERSION_FILE}")"
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: installed toolchain version ${actual_version} differs from ${SOFTWARE_VERSION}"
        return 40
    }
    prefetch_benchmark_dependencies || return $?
    log_message "toolchain and benchmark suite are ready inside the container (id ${RUST_BENCH_ID})"
}
