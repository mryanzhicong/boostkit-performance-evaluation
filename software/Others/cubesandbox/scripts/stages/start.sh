#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_cubesandbox_runtime() {
    initialize_runtime || return $?
    host_preflight || return $?
    ensure_cubesandbox_runtime || return $?
    ensure_template || return $?
    [[ -x "${CUBESANDBOX_CUBE_BENCH}" ]] || {
        log 'ERROR: cube-bench is missing; run the build stage first'; return 40
    }
    log "validating one real sandbox creation against ${CUBESANDBOX_API_URL} (template ${CUBESANDBOX_TEMPLATE_ID})"
    "${CUBESANDBOX_CUBE_BENCH}" -c 1 -n 1 -w 0 -m create-only --no-tui \
        --api-url "${CUBESANDBOX_API_URL}" --api-key "${CUBESANDBOX_API_KEY}" \
        -t "${CUBESANDBOX_TEMPLATE_ID}" -o "${PERF_WORK_DIR}/cube-bench-smoke.json" \
        >"${PERF_WORK_DIR}/cube-bench-smoke.log" 2>&1 || {
        log 'ERROR: the CubeSandbox smoke run failed'
        tail -20 "${PERF_WORK_DIR}/cube-bench-smoke.log" || true
        cleanup_sandboxes || true
        return 40
    }
    python3 - "${PERF_WORK_DIR}/cube-bench-smoke.json" <<'PY' || { cleanup_sandboxes || true; return 40; }
import json, sys
report = json.load(open(sys.argv[1], encoding="utf-8"))
summary = report.get("summary") or {}
if summary.get("successful") != 1 or summary.get("success_rate") != 1.0:
    print(f"smoke run did not create a sandbox: {summary}")
    raise SystemExit(1)
print("smoke run created one sandbox successfully")
PY
    cleanup_sandboxes || return $?
    printf '%s\n' "${CUBESANDBOX_TEMPLATE_ID}" >"${RESULTS_DIR}/template_id"
    log "runtime ready: concurrency levels ${CUBESANDBOX_LEVELS}, ${CUBESANDBOX_TOTAL} sandboxes per sample"
}
