#!/usr/bin/env python3
"""Aggregate Doris end-to-end query timings into the TPC-H metric set."""

from __future__ import annotations

import argparse
import csv
import json
import math
import statistics
from pathlib import Path

QUERY_COUNT = 22


def read_rows(path: Path) -> dict[tuple[int, int], float]:
    rows: dict[tuple[int, int], float] = {}
    with path.open(newline="", encoding="utf-8", errors="replace") as handle:
        reader = csv.DictReader(handle)
        if tuple(reader.fieldnames or ()) != ("round", "query", "wall_ms"):
            raise ValueError("Doris CSV header must be round,query,wall_ms")
        for raw in reader:
            try:
                round_number = int(raw["round"])
                query_number = int(raw["query"])
                wall_ms = float(raw["wall_ms"])
            except (TypeError, ValueError) as exc:
                raise ValueError("Doris CSV contains a non-numeric field") from exc
            if not 1 <= query_number <= QUERY_COUNT:
                raise ValueError(f"query number out of range: {query_number}")
            if not math.isfinite(wall_ms) or wall_ms <= 0:
                raise ValueError(f"round {round_number} q{query_number} has an invalid wall time")
            key = (round_number, query_number)
            if key in rows:
                raise ValueError(f"duplicate row for round {round_number} q{query_number}")
            rows[key] = wall_ms
    return rows


def build_result(rows: dict[tuple[int, int], float], rounds: int, sf: int,
                 parallel_tasks: int, exec_mem_limit: int) -> dict:
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

    totals = [sum(rows[(round_number, query)] for query in range(1, QUERY_COUNT + 1))
              for round_number in range(1, rounds + 1)]
    results = {
        "tpch-22-total/total_time": {
            "value": round(statistics.median(totals) / 1000.0, 3),
            "unit": "s",
            "direction": "lower_is_better",
            "group": "tpch-22-total",
        }
    }
    for query in range(1, QUERY_COUNT + 1):
        median = statistics.median(rows[(round_number, query)]
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
            "parallel_pipeline_task_num": parallel_tasks,
            "exec_mem_limit_bytes": exec_mem_limit,
            "replication_num": 1,
            "timing": "client end-to-end time.perf_counter around execute+fetchall",
        },
        "results": results,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--rounds", required=True, type=int)
    parser.add_argument("--sf", required=True, type=int)
    parser.add_argument("--parallel-tasks", required=True, type=int)
    parser.add_argument("--exec-mem-limit", required=True, type=int)
    args = parser.parse_args()
    result = build_result(read_rows(args.csv), args.rounds, args.sf,
                          args.parallel_tasks, args.exec_mem_limit)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n",
                           encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
