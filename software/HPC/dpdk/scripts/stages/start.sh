#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_dpdk_runtime() {
    local bench_cpu status=0 tsc_hz
    initialize_runtime || return $?
    check_dpdk_container || return $?
    [[ -x "${DPDK_TEST_BIN}" ]] || {
        log "ERROR: dpdk-test executable is missing: ${DPDK_TEST_BIN}"
        return 40
    }
    container_exec python3 "${SCRIPT_DIR}/scripts/results/select_cpus.py" \
        --min-cores 2 --output "${DPDK_CPU_STATE_FILE}" || {
        log 'ERROR: failed to select 2 distinct physical cores on NUMA 0 inside container'
        return 40
    }
    cp -- "${DPDK_CPU_STATE_FILE}" "${RESULTS_DIR}/cpu-selection.json" || return 40
    bench_cpu="$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["bench_cpu"])' "${DPDK_CPU_STATE_FILE}")"

    log "running EAL smoke and TSC frequency check on NUMA 0 CPU ${bench_cpu}"
    set +e
    container_exec env -u DPDK_TEST -u DPDK_TEST_PARAMS -u DPDK_TEST_SKIP \
        "${DPDK_TEST_BIN}" \
        -l "${bench_cpu}" --main-lcore="${bench_cpu}" \
        --no-pci --no-huge -m "${DPDK_MEM_MB}" \
        --file-prefix="cpu-smoke-${PERF_RUN_ID}" --no-telemetry \
        --log-level=lib.eal:debug \
        -- version_autotest \
        2>&1 | tee "${RESULTS_DIR}/smoke.log"
    status="${PIPESTATUS[0]}"
    set -e
    [[ "${status}" -eq 0 ]] || { log "ERROR: DPDK EAL smoke check failed (rc=${status})"; return 40; }
    grep -q 'Test OK' "${RESULTS_DIR}/smoke.log" || {
        log 'ERROR: smoke.log did not report Test OK'
        return 40
    }
    grep -q "DPDK ${SOFTWARE_VERSION}" "${RESULTS_DIR}/smoke.log" || {
        log "ERROR: smoke.log did not confirm DPDK ${SOFTWARE_VERSION}"
        return 40
    }
    tsc_hz="$(python3 -c '
import re, sys
from pathlib import Path
text = Path(sys.argv[1]).read_text(encoding="utf-8", errors="replace")
m = re.search(r"TSC frequency is ~([0-9]+(?:\.[0-9]+)?)\s*(KHz|MHz|Hz)\b", text, re.IGNORECASE)
if not m:
    sys.exit("missing TSC frequency in smoke.log")
val = float(m.group(1))
unit = m.group(2).lower()
mult = {"hz": 1, "khz": 1000, "mhz": 1000000}[unit]
hz = int(round(val * mult))
if hz <= 0:
    sys.exit(f"invalid TSC frequency: {hz}")
print(hz)
' "${RESULTS_DIR}/smoke.log")" || {
        log 'ERROR: failed to parse EAL TSC frequency from smoke.log'
        return 40
    }
    printf '%s\n' "${tsc_hz}" > "${DPDK_TSC_STATE_FILE}"
    log "DPDK runtime ready inside container ${DPDK_CONTAINER_NAME} (tsc_hz=${tsc_hz})"
}
