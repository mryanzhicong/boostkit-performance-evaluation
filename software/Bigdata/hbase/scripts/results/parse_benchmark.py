#!/usr/bin/env python3
"""Extract PerformanceEvaluation write/read metrics from the raw log."""

from __future__ import annotations

import argparse
import json
import math
import re
import statistics
from pathlib import Path

ROW_COUNT = re.compile(r"Row count=(\d+)")
ELAPSED_MS = re.compile(r"Elapsed time in milliseconds=(\d+)")
READ_TPS = re.compile(r"\[\s*Avg TPS/QPS\s*\]\s*([\d.]+)")
READ_LATENCY = re.compile(r"\[\s*Avg latency \(us\)\s*\]\s*([\d.]+)")
READ_SECTION = re.compile(r"^===== randomRead round (\d+) =====$", re.MULTILINE)


def positive(value: float, name: str) -> float:
    if not math.isfinite(value) or value <= 0:
        raise ValueError(f"{name} must be positive and finite")
    return value


def parse_write(text: str) -> float:
    section = text.split("===== randomWrite =====", 1)
    if len(section) != 2:
        raise ValueError("randomWrite section is missing")
    body = section[1].split("===== randomRead", 1)[0]
    rows = [int(value) for value in ROW_COUNT.findall(body)]
    elapsed = [int(value) for value in ELAPSED_MS.findall(body)]
    if not rows or not elapsed:
        raise ValueError("randomWrite reported no Row count or elapsed time")
    # HBase prints the driver summary last; the same lines can also appear in
    # map-task logs, so use the final pair instead of requiring exactly one.
    if rows[-1] <= 0 or elapsed[-1] <= 0:
        raise ValueError("randomWrite reported non-positive rows or elapsed time")
    return rows[-1] / (elapsed[-1] / 1000.0)


def parse_reads(text: str, rounds: int) -> list[tuple[float, float]]:
    matches = list(READ_SECTION.finditer(text))
    if len(matches) != rounds:
        raise ValueError(f"expected {rounds} randomRead rounds, found {len(matches)}")
    results = []
    for index, match in enumerate(matches):
        start = match.end()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        body = text[start:end]
        tps = READ_TPS.findall(body)
        latency = READ_LATENCY.findall(body)
        if len(tps) != 1 or len(latency) != 1:
            raise ValueError(f"round {match.group(1)} must report one TPS and one latency")
        results.append((positive(float(tps[0]), "read throughput"),
                        positive(float(latency[0]), "read latency")))
    return results


def build_result(text: str, rounds: int, size_gb: int, presplit: int,
                 read_threads: int, read_rows: int) -> dict:
    if rounds <= 0 or size_gb <= 0 or presplit <= 0 or read_threads <= 0 or read_rows <= 0:
        raise ValueError("workload parameters must be positive")
    write_throughput = parse_write(text)
    reads = parse_reads(text, rounds)
    read_tps = statistics.median(item[0] for item in reads)
    read_latency_us = statistics.median(item[1] for item in reads)
    return {
        "parameters": {
            "write_size_gb": size_gb,
            "presplit_regions": presplit,
            "read_threads": read_threads,
            "rows_per_thread": read_rows,
            "rounds": rounds,
            "write_mode": "mapreduce randomWrite",
            "read_mode": "client randomRead --nomapred",
        },
        "results": {
            "pe-randomWrite/throughput": {
                "value": round(write_throughput, 3), "unit": "rows/s",
                "direction": "higher_is_better", "group": "pe-randomWrite",
            },
            "pe-randomRead/throughput": {
                "value": round(read_tps, 3), "unit": "ops/s",
                "direction": "higher_is_better", "group": "pe-randomRead",
            },
            "pe-randomRead/avg_latency": {
                "value": round(read_latency_us / 1000.0, 4), "unit": "ms",
                "direction": "lower_is_better", "group": "pe-randomRead",
            },
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--raw", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--rounds", required=True, type=int)
    parser.add_argument("--size-gb", required=True, type=int)
    parser.add_argument("--presplit", required=True, type=int)
    parser.add_argument("--read-threads", required=True, type=int)
    parser.add_argument("--read-rows", required=True, type=int)
    args = parser.parse_args()
    result = build_result(args.raw.read_text(encoding="utf-8", errors="replace"),
                          args.rounds, args.size_gb, args.presplit,
                          args.read_threads, args.read_rows)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n",
                           encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
