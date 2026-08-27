#!/usr/bin/env python3
"""Aggregate db_bench outputs into the machine-readable results.json.

Each exposed metric copies the workload name and the field label directly from
db_bench's stdout (fillseq/readrandom/overwrite/readwhilewriting combined with
micros/op, ops/sec and MB/s), so every reported name is traceable to the
official benchmark output.
"""

from __future__ import annotations

import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

WORKLOADS = ("fillseq", "readrandom", "overwrite", "readwhilewriting")

# (source field label, JSON key in benchmark_kv.json, optimization direction)
FIELDS = (
    ("micros/op", "micros_per_op", "lower_is_better"),
    ("ops/sec", "ops_per_sec", "higher_is_better"),
    ("MB/s", "mb_per_sec", "higher_is_better"),
)


def load_json(path: Path) -> dict:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"cannot read {path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise RuntimeError(f"{path} must contain a JSON object")
    return payload


def main():
    if len(sys.argv) != 3:
        print("Usage: aggregate_results.py RESULTS_DIR OUTPUT_JSON", file=sys.stderr)
        return 2
    results_dir = Path(sys.argv[1])
    output_file = Path(sys.argv[2])

    primary = load_json(results_dir / "benchmark_kv.json")
    summary = primary.get("results_summary")
    if not isinstance(summary, dict):
        raise RuntimeError("benchmark_kv.json is missing results_summary")

    results = {}
    for workload in WORKLOADS:
        entry = summary.get(workload)
        if not isinstance(entry, dict):
            raise RuntimeError(f"benchmark_kv.json is missing workload {workload}")
        for label, json_key, direction in FIELDS:
            value = entry.get(json_key)
            if isinstance(value, bool) or not isinstance(value, (int, float)):
                raise RuntimeError(f"workload {workload} is missing {json_key}")
            source_name = f"{workload} {label}"
            results[source_name] = {
                "source_name": source_name,
                "source_field": json_key,
                "source_file": "benchmark_kv.json",
                "value": float(value),
                "unit": label,
                "direction": direction,
            }

    payload = {
        "software": "rocksdb",
        "version": os.environ.get("SOFTWARE_VERSION", "11.8.1"),
        "architecture": os.environ.get("EXPECTED_ARCH", "unknown"),
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "results": results,
    }
    output_file.parent.mkdir(parents=True, exist_ok=True)
    output_file.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(f"[AGGREGATE] output written to {output_file} ({len(results)} metrics)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())