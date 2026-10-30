#!/usr/bin/env python3
"""Extract only official Nexmark V1 result rows from the 23 formal query logs."""

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


def parse_rate(value: str) -> float:
    match = re.fullmatch(r"([0-9][0-9,]*(?:\.[0-9]+)?)\s*([KMG]?)/s", value.strip())
    if not match:
        raise ValueError(f"invalid upstream Nexmark throughput: {value!r}")
    return float(match.group(1).replace(",", "")) * {"": 1, "K": 1e3, "M": 1e6, "G": 1e9}[match.group(2)]


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
    except ValueError:
        cores = None
    if cores is not None and not math.isfinite(cores):
        cores = None
    seconds = float(cells[3].replace(",", ""))
    throughput = parse_rate(cells[5])
    try:
        throughput_per_core = parse_rate(cells[6])
    except ValueError:
        throughput_per_core = None
    if events != expected_events or not all(math.isfinite(x) and x > 0 for x in (seconds, throughput)):
        raise ValueError(f"{query}: incomplete or non-positive Nexmark measurement")
    return {
        "query": query, "events": events, "cores": cores, "cores_raw": cells[2],
        "time_seconds": seconds, "throughput_events_per_second": throughput,
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
        results[f"{query}/throughput"] = {
            "value": row["throughput_events_per_second"], "unit": "events/s",
            "direction": "higher_is_better", "group": query,
        }
        results[f"{query}/time"] = {
            "value": row["time_seconds"], "unit": "s",
            "direction": "lower_is_better", "group": query,
        }
    return {
        "parameters": {
            "suite": "Nexmark V1 OA", "nexmark_revision": "6b3646c3baec701f1fa74baf938d235f742e5d3c",
            "warmup_events": 500_000, "warmup_tps": 5_000,
            "benchmark_events": BENCH_EVENTS, "benchmark_tps": 1_000_000,
            "query_count": len(QUERIES), "parallelism": 8, "taskmanagers": 2,
            "slots_per_taskmanager": 8, "checkpoint_interval": 0,
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
    print(f"[flink] parsed {len(payload['results'])} metrics from 23 official Nexmark rows")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
