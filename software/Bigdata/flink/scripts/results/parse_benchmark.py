#!/usr/bin/env python3
"""Extract every official Nexmark V1 result-table column from 23 formal query logs."""

from __future__ import annotations

import argparse
import json
import math
import re
import sys
from pathlib import Path


QUERIES = tuple(f"q{i}" for i in range(24) if i != 6)
BENCH_EVENTS = 10_000_000
RESULT_RE = re.compile(r"^\|q\d+\s*\|")
METRIC_SPECS = (
    ("events", "events", "neutral"),
    ("cores", "cores", "neutral"),
    ("time", "s", "lower_is_better"),
    ("core_seconds", "core*s", "lower_is_better"),
    ("throughput", "events/s", "higher_is_better"),
    ("throughput_per_core", "events/s/core", "higher_is_better"),
)


def parse_rate(value: str) -> float:
    match = re.fullmatch(r"([0-9][0-9,]*(?:\.[0-9]+)?)\s*([KMGTPE]?)/s", value.strip())
    if not match:
        raise ValueError(f"invalid upstream Nexmark throughput: {value!r}")
    return float(match.group(1).replace(",", "")) * {
        "": 1, "K": 1e3, "M": 1e6, "G": 1e9,
        "T": 1e12, "P": 1e15, "E": 1e18,
    }[match.group(2)]


def parse_result(output: str, query: str, expected_events: int) -> dict:
    rows = [line for line in output.splitlines() if RESULT_RE.match(line)]
    if len(rows) != 1:
        raise ValueError(f"{query}: expected one Nexmark Results row, got {len(rows)}")
    cells = [cell.strip() for cell in rows[0].strip().strip("|").split("|")]
    if len(cells) != 7 or cells[0] != query:
        raise ValueError(f"{query}: malformed or mismatched Nexmark row: {rows[0]}")
    events = int(cells[1].replace(",", ""))
    try:
        cores = float(cells[2].replace(",", ""))
    except ValueError as exc:
        raise ValueError(f"{query}: invalid Nexmark Cores field: {cells[2]}") from exc
    seconds = float(cells[3].replace(",", ""))
    core_seconds = float(cells[4].replace(",", ""))
    throughput = parse_rate(cells[5])
    throughput_per_core = parse_rate(cells[6])
    if not math.isfinite(cores) or cores <= 0:
        raise ValueError(f"{query}: Nexmark reported no TaskManager CPU metrics (Cores={cells[2]})")
    if events != expected_events or not all(
        math.isfinite(x) and x > 0
        for x in (seconds, core_seconds, throughput, throughput_per_core)
    ):
        raise ValueError(f"{query}: incomplete or non-positive Nexmark measurement")
    return {
        "query": query, "events": events, "cores": cores, "cores_raw": cells[2],
        "time_seconds": seconds, "core_seconds": core_seconds,
        "throughput_events_per_second": throughput,
        "throughput_per_core_events_per_second": throughput_per_core,
        "throughput_per_core_raw": cells[6], "original_row": rows[0],
    }


def parse_benchmark(result_dir: Path) -> dict:
    measurements = []
    for query in QUERIES:
        output = (result_dir / f"bench-{query}.log").read_text(encoding="utf-8", errors="replace")
        measurements.append(parse_result(output, query, BENCH_EVENTS))
    results = {}
    for row in measurements:
        query = row["query"]
        values = {
            "events": row["events"], "cores": row["cores"],
            "time": row["time_seconds"], "core_seconds": row["core_seconds"],
            "throughput": row["throughput_events_per_second"],
            "throughput_per_core": row["throughput_per_core_events_per_second"],
        }
        for name, unit, direction in METRIC_SPECS:
            results[f"{query}/{name}"] = {
                "value": values[name], "unit": unit,
                "direction": direction, "group": query,
            }
    return {
        "parameters": {
            "suite": "Nexmark V1 OA", "nexmark_revision": "6b3646c3baec701f1fa74baf938d235f742e5d3c",
            "warmup_events": 500_000, "warmup_tps": 5_000,
            "benchmark_events": BENCH_EVENTS, "benchmark_tps": 1_000_000,
            "query_count": len(QUERIES), "parallelism": 8, "taskmanagers": 2,
            "slots_per_taskmanager": 8, "checkpoint_interval": 180000,
            "state_backend": "rocksdb", "mini_batch": True,
        },
        "measurements": measurements, "results": results,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--results-dir", type=Path, required=True)
    args = parser.parse_args()
    try:
        payload = parse_benchmark(args.results_dir)
        destination = args.results_dir / "benchmark_flink.json"
        destination.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    except (OSError, ValueError) as exc:
        print(f"[flink] ERROR: {exc}", file=sys.stderr)
        return 1
    print(f"[flink] parsed {len(payload['results'])} fields from 23 official Nexmark rows")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
