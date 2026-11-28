#!/usr/bin/env python3
"""Aggregate ClickHouse system.query_log rows into the TPC-H metric set."""

from __future__ import annotations

import argparse
import json
import math
import re
import statistics
from pathlib import Path

QUERY_ID = re.compile(r"-r(?P<round>\d+)-q(?P<query>\d{2})$")
QUERY_COUNT = 22


def read_query_log(path: Path) -> dict[tuple[int, int], dict]:
    rows: dict[tuple[int, int], dict] = {}
    for number, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
        if not line.strip():
            continue
        fields = line.split("\t")
        if len(fields) < 2:
            raise ValueError(f"query log line {number} has fewer than two columns")
        match = QUERY_ID.search(fields[0])
        if not match:
            raise ValueError(f"query log line {number} has an unexpected query_id: {fields[0]}")
        round_number = int(match["round"])
        query_number = int(match["query"])
        if not 1 <= query_number <= QUERY_COUNT:
            raise ValueError(f"query number out of range: {query_number}")
        try:
            duration = float(fields[1])
        except ValueError as exc:
            raise ValueError(f"query log line {number} has a non-numeric duration") from exc
        if not math.isfinite(duration) or duration <= 0:
            raise ValueError(f"query log line {number} has a non-positive duration")
        key = (round_number, query_number)
        if key in rows:
            raise ValueError(f"duplicate QueryFinish row for round {round_number} q{query_number}")
        rows[key] = {
            "duration_ms": duration,
            "read_rows": int(float(fields[2])) if len(fields) > 2 and fields[2] else 0,
            "memory_usage": int(float(fields[3])) if len(fields) > 3 and fields[3] else 0,
        }
    return rows


def build_result(rows: dict[tuple[int, int], dict], rounds: int, sf: int,
                 max_threads: int, max_memory_usage: int, max_server_memory_usage: int) -> dict:
    if rounds <= 0 or sf <= 0:
        raise ValueError("rounds and sf must be positive")
    expected = {(round_number, query) for round_number in range(1, rounds + 1)
                for query in range(1, QUERY_COUNT + 1)}
    missing = expected - set(rows)
    extra = set(rows) - expected
    if missing:
        raise ValueError(f"missing {len(missing)} query results, e.g. {sorted(missing)[:3]}")
    if extra:
        raise ValueError(f"unexpected query results, e.g. {sorted(extra)[:3]}")

    results: dict[str, dict] = {}
    totals: list[float] = []
    for round_number in range(1, rounds + 1):
        totals.append(sum(rows[(round_number, query)]["duration_ms"]
                          for query in range(1, QUERY_COUNT + 1)))
    total_median = statistics.median(totals) / 1000.0
    results["tpch-22-total/total_time"] = {
        "value": round(total_median, 3),
        "unit": "s",
        "direction": "lower_is_better",
        "group": "tpch-22-total",
    }
    for query in range(1, QUERY_COUNT + 1):
        median = statistics.median(rows[(round_number, query)]["duration_ms"]
                                   for round_number in range(1, rounds + 1))
        group = f"tpch-q{query:02d}"
        results[f"{group}/duration_ms"] = {
            "value": round(median, 3),
            "unit": "ms",
            "direction": "lower_is_better",
            "group": group,
        }
    return {
        "parameters": {
            "sf": sf,
            "rounds": rounds,
            "queries": QUERY_COUNT,
            "max_threads": max_threads,
            "max_memory_usage_bytes": max_memory_usage,
            "max_server_memory_usage_bytes": max_server_memory_usage,
            "max_block_size": 65536,
            "log_queries": 1,
            "log_query_threads": 0,
            "timing": "server side system.query_log.query_duration_ms",
        },
        "results": results,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--query-log", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--rounds", required=True, type=int)
    parser.add_argument("--sf", required=True, type=int)
    parser.add_argument("--max-threads", required=True, type=int)
    parser.add_argument("--max-memory-usage", required=True, type=int)
    parser.add_argument("--max-server-memory-usage", required=True, type=int)
    args = parser.parse_args()
    result = build_result(
        read_query_log(args.query_log), args.rounds, args.sf,
        args.max_threads, args.max_memory_usage, args.max_server_memory_usage,
    )
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n",
                           encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
