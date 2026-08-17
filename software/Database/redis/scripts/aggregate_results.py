#!/usr/bin/env python3
"""Aggregate Redis primary and microbenchmark outputs into the existing result shape."""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def load(path: Path) -> dict[str, Any]:
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError(f"JSON root must be an object: {path}")
    return data


def metric_values(primary: dict[str, Any], field: str) -> list[float]:
    values: list[float] = []
    for command in primary.get("results_summary", {}).values():
        if not isinstance(command, dict):
            continue
        for sample in command.values():
            if isinstance(sample, dict) and sample.get(field) is not None:
                values.append(float(sample[field]))
    return values


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: aggregate_results.py RESULTS_DIR OUTPUT", file=sys.stderr)
        return 1
    results_dir = Path(sys.argv[1])
    output = Path(sys.argv[2])
    primary = load(results_dir / "benchmark_redis.json")
    micro = load(results_dir / "micro_benchmark.json")
    version_info = load(results_dir / "version_info.json")

    qps_values = metric_values(primary, "qps")
    latency_values = metric_values(primary, "avg_latency_ms")
    p99_values = metric_values(primary, "p99_latency_ms")
    summary: dict[str, float] = {
        "avg_qps": round(sum(qps_values) / len(qps_values), 4),
        "max_qps": round(max(qps_values), 4),
        "avg_latency_ms": round(sum(latency_values) / len(latency_values), 4),
        "max_p99_latency_ms": round(max(p99_values), 4),
        "set_qps_c50": float(primary["results_summary"]["SET"]["concurrency_50"]["qps"]),
        "get_qps_c50": float(primary["results_summary"]["GET"]["concurrency_50"]["qps"]),
    }

    client_results = micro["results"]["client_scaling"]
    one_client = float(client_results["clients_1"]["qps"])
    max_clients = int(micro["runtime_context"]["max_clients"])
    all_clients = float(client_results[f"clients_{max_clients}"]["qps"])
    summary["client_scaling_ratio"] = round(all_clients / one_client, 4)

    payload = {
        "test_time": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "software": "redis",
        "version": version_info["software_version"],
        "environment": version_info,
        "benchmarks": {"primary": primary, "micro": micro},
        "summary": summary,
    }
    output.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
