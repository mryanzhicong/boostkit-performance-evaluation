#!/usr/bin/env bash
# Container-side driver for the OpenViking v0.5.0 benchmark kit.
#
# This reproduces the kit's own runner steps [3/7]..[7/7] (write LoCoMo sample 0
# with telemetry, replay the 152 search questions, run the 152 QA questions,
# record instrumentation coverage, generate the report suite) against an
# already-running OpenViking server.  Unlike the kit's container_run.sh it does
# not re-exec itself under numactl and never touches cpusets: the adaptation
# deliberately measures the out-of-the-box configuration.
#
# Usage: run_protocol.sh full|warmup
#   full   -- all seven protocol steps (measured pass)
#   warmup -- first LoCoMo session write plus the search replay (warm-up pass)
set -Eeuo pipefail

MODE="${1:-full}"
: "${KIT_ROOT:?KIT_ROOT is required}"
: "${RUN_ROOT:?RUN_ROOT is required}"
: "${OPENVIKING_URL:?OPENVIKING_URL is required}"
PYTHON="${PYTHON:-python3}"
QA_THREADS="${QA_CONCURRENCY:-8}"

log() { printf '[protocol] [%s] %s\n' "$(date '+%T')" "$*"; }

# The kit harness resolves some of its own bookkeeping paths (for example
# ./result/.ingest_record.json) relative to the current directory, so every
# protocol step runs from the run root exactly like the kit's own runner does.
mkdir -p "${RUN_ROOT}/result" "${RUN_ROOT}/metrics" "${RUN_ROOT}/logs"
cd "${RUN_ROOT}"

validate_search_rows() {
    local path="${RUN_ROOT}/metrics/search_telemetry_raw.jsonl" rows
    [[ -s "${path}" ]] || {
        log "ERROR: the search telemetry file is missing: ${path}"
        return 50
    }
    rows="$(wc -l < "${path}")"
    log "search telemetry rows: ${rows}"
    if (( rows < 120 )); then
        log "ERROR: only ${rows} search records were captured, the kit protocol replays 152 questions"
        return 50
    fi
}

import_locomo() {
    local -a extra=()
    if [[ "${MODE}" == "warmup" ]]; then
        extra=(--sessions 1)
        log "[1/5] warm-up write: importing the first LoCoMo session"
    else
        log "[1/5] write: importing LoCoMo sample 0 (61 commits with per-stage telemetry)"
    fi
    if ! "${PYTHON}" "${KIT_ROOT}/harness/import_to_ov.py" \
        --input "${RUN_ROOT}/raw/locomo10.json" \
        --success-csv "${RUN_ROOT}/metrics/import_success.csv" \
        --error-log "${RUN_ROOT}/metrics/import_errors.log" \
        --openviking-url "${OPENVIKING_URL}" \
        --sample 0 --force-ingest --clear-ingest-record "${extra[@]}" \
        > "${RUN_ROOT}/logs/import.log" 2>&1; then
        tail -40 "${RUN_ROOT}/logs/import.log" || true
        log "ERROR: the kit write protocol failed"
        return 50
    fi
    tail -3 "${RUN_ROOT}/logs/import.log" || true
}

capture_search() {
    log "[2/5] search: replaying the 152 LoCoMo search questions"
    if ! "${PYTHON}" "${KIT_ROOT}/harness/capture_search_telemetry.py" \
        > "${RUN_ROOT}/logs/search.log" 2>&1; then
        tail -30 "${RUN_ROOT}/logs/search.log" || true
        log "ERROR: the kit search replay failed"
        return 50
    fi
    validate_search_rows || return 50
}

run_qa() {
    log "[3/5] QA: answering the 152 LoCoMo questions through the service"
    if ! "${PYTHON}" "${KIT_ROOT}/benchmark/locomo/openviking/run_eval.py" \
        "${RUN_ROOT}/raw/locomo10.json" \
        --output "${RUN_ROOT}/metrics/qa_results.csv" \
        --sample 0 --threads "${QA_THREADS}" \
        --openviking-url "${OPENVIKING_URL}" \
        --single-search-context-limit 50 \
        --single-search-rerank-limit 0 \
        --single-search-max-context-chars 30000 \
        > "${RUN_ROOT}/logs/qa.log" 2>&1; then
        log "WARNING: the primary QA pass reported failures; repairing missing rows"
        tail -20 "${RUN_ROOT}/logs/qa.log" || true
    fi
    if ! "${PYTHON}" "${KIT_ROOT}/harness/complete_missing_qa.py" \
        > "${RUN_ROOT}/logs/qa_repair.log" 2>&1; then
        log "WARNING: the QA repair pass reported failures"
    fi
    if ! "${PYTHON}" "${KIT_ROOT}/harness/token_savings.py" \
        > "${RUN_ROOT}/logs/token.log" 2>&1; then
        log "WARNING: the token-savings analysis reported failures"
    fi
}

record_coverage() {
    log "[4/5] coverage: recording instrumentation coverage"
    "${PYTHON}" - "${RUN_ROOT}" <<'PY'
import csv
import json
import sys
from pathlib import Path

run = Path(sys.argv[1])
found = set()
csv_path = run / "metrics" / "import_success.csv"
if csv_path.exists():
    with csv_path.open(encoding="utf-8-sig", newline="") as handle:
        for row in csv.DictReader(handle):
            for item in json.loads(row.get("telemetry_json") or "[]"):
                found.update(item.get("summary", {}).get("write", {}).get("stages", {}))
sfound, rows = set(), 0
jsonl = run / "metrics" / "search_telemetry_raw.jsonl"
if jsonl.exists():
    for line in jsonl.open(encoding="utf-8"):
        if not line.strip():
            continue
        rows += 1
        sfound.update(json.loads(line).get("telemetry", {}).get("summary", {}).get("search", {}))
out = {
    "write_stage_count": len(found),
    "write_stages": sorted(found),
    "search_rows": rows,
    "search_stages": sorted(sfound),
}
(run / "metrics" / "instrumentation_coverage.json").write_text(
    json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8"
)
print(f"write stages={len(found)} search rows={rows} search stages={len(sfound)}")
PY
}

build_reports() {
    log "[5/5] reports: generating the kit report suite"
    ( cd "${KIT_ROOT}/harness" && "${PYTHON}" agfs_report.py > "${RUN_ROOT}/logs/agfs_report.log" 2>&1 ) \
        || log "WARNING: the AGFS report step reported failures"
    if ! "${PYTHON}" "${KIT_ROOT}/harness/build_reports.py" \
        > "${RUN_ROOT}/logs/build_reports.log" 2>&1; then
        log "WARNING: the kit report suite reported failures"
        tail -20 "${RUN_ROOT}/logs/build_reports.log" || true
    fi
    mkdir -p "${RUN_ROOT}/reports"
    if ! find "${RUN_ROOT}/reports" -type f | grep -q .; then
        {
            printf '# OpenViking v0.5.0 benchmark-kit protocol summary\n\n'
            printf 'The kit report generator produced no report for this run; the raw evidence is kept in `metrics/`.\n\n'
            printf '```\n'
            cat "${RUN_ROOT}/metrics/instrumentation_coverage.json" 2>/dev/null || true
            printf '\n```\n'
        } > "${RUN_ROOT}/reports/protocol-summary.md"
    fi
}

import_locomo || exit 50
capture_search || exit 50
if [[ "${MODE}" == "full" ]]; then
    run_qa
    record_coverage || exit 50
    build_reports
else
    log "warm-up pass complete (QA and reports are only executed in the measured pass)"
fi
log "protocol mode=${MODE} completed for ${RUN_ROOT}"
