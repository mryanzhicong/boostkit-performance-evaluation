#!/usr/bin/env python3
"""Aggregate MySQL primary and micro benchmark outputs into a common shape."""

from __future__ import annotations

import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def load(path: Path) -> dict[str, Any]:
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError(f"JSON root must be an object: {path}")
    return data


def safe_float(value: Any, default: float = 0.0) -> float:
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def compute_summary(primary: dict[str, Any], micro: dict[str, Any]) -> dict[str, float]:
    summary: dict[str, float] = {}
    all_tps: list[float] = []
    all_qps: list[float] = []
    results_summary = primary.get("results_summary", {})
    for workload in results_summary.values():
        if not isinstance(workload, dict):
            continue
        for sample in workload.values():
            if not isinstance(sample, dict):
                continue
            if sample.get("tps"):
                all_tps.append(safe_float(sample["tps"]))
            if sample.get("qps"):
                all_qps.append(safe_float(sample["qps"]))

    if all_tps:
        summary["avg_tps"] = round(sum(all_tps) / len(all_tps), 4)
        summary["max_tps"] = round(max(all_tps), 4)
    if all_qps:
        summary["avg_qps"] = round(sum(all_qps) / len(all_qps), 4)
        summary["max_qps"] = round(max(all_qps), 4)

    read_write = results_summary.get("oltp_read_write", {}).get("threads_16", {})
    if isinstance(read_write, dict) and read_write.get("tps"):
        summary["read_write_tps_t16"] = safe_float(read_write["tps"])
    point_select = results_summary.get("oltp_point_select", {}).get("threads_16", {})
    if isinstance(point_select, dict) and point_select.get("qps"):
        summary["point_select_qps_t16"] = safe_float(point_select["qps"])

    thread_scaling = micro.get("results", {}).get("thread_scaling", {})
    t1 = safe_float(thread_scaling.get("threads_1", {}).get("qps"))
    t64 = safe_float(thread_scaling.get("threads_64", {}).get("qps"))
    if t1 > 0 and t64 > 0:
        summary["thread_scaling_ratio"] = round(t64 / t1, 4)

    return summary


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: aggregate_results.py RESULTS_DIR OUTPUT", file=sys.stderr)
        return 1
    results_dir = Path(sys.argv[1])
    output = Path(sys.argv[2])
    primary = load(results_dir / "benchmark_mysql.json")
    micro = load(results_dir / "micro_benchmark.json")
    summary = compute_summary(primary, micro)

    payload = {
        "test_time": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "software": "mysql",
        "version": os.environ.get("SOFTWARE_VERSION", "8.0"),
        "architecture": os.environ.get("EXPECTED_ARCH", ""),
        "benchmarks": {"primary": primary, "micro": micro},
        "summary": summary,
    }
    output.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())