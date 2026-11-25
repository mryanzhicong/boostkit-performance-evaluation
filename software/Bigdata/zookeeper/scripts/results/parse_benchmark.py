#!/usr/bin/env python3
"""Turn ZkBench CSV rows into the fixed metric set declared by case.yaml."""

from __future__ import annotations

import argparse
import csv
import json
import math
import statistics
from pathlib import Path

COLUMNS = (
    "label", "arch", "threads", "mode", "value_size", "keyspace", "ops_ok",
    "ops_err", "elapsed_s", "throughput_ops", "avg_us", "p50_us", "p95_us",
    "p99_us", "max_us",
)
ALLOWED_MODES = {"read", "update", "mixed", "create"}
ALLOWED_THREADS = {1, 8, 32, 64}
LATENCY_COLUMNS = ("p50_us", "p95_us", "p99_us", "max_us")


def finite_number(value: str, name: str) -> float:
    try:
        number = float(value)
    except (TypeError, ValueError) as exc:
        raise ValueError(f"{name} is not numeric: {value!r}") from exc
    if not math.isfinite(number):
        raise ValueError(f"{name} is not finite")
    return number


def read_rows(path: Path) -> list[dict]:
    with path.open(newline="", encoding="utf-8", errors="replace") as handle:
        reader = csv.DictReader(handle)
        if tuple(reader.fieldnames or ()) != COLUMNS:
            raise ValueError("ZkBench CSV header does not match the expected columns")
        rows = []
        for raw in reader:
            mode = (raw.get("mode") or "").strip()
            if mode not in ALLOWED_MODES:
                raise ValueError(f"unknown benchmark mode: {mode!r}")
            try:
                threads = int(raw["threads"])
            except (TypeError, ValueError) as exc:
                raise ValueError("threads column is not an integer") from exc
            if threads not in ALLOWED_THREADS:
                raise ValueError(f"unexpected thread count: {threads}")
            ops_ok = int(finite_number(raw["ops_ok"], "ops_ok"))
            ops_err = int(finite_number(raw["ops_err"], "ops_err"))
            elapsed = finite_number(raw["elapsed_s"], "elapsed_s")
            throughput = finite_number(raw["throughput_ops"], "throughput_ops")
            if ops_err != 0:
                raise ValueError(f"{mode}-t{threads} reported {ops_err} failed operations")
            if ops_ok <= 0 or elapsed <= 0 or throughput <= 0:
                raise ValueError(f"{mode}-t{threads} has a non-positive measurement")
            expected = ops_ok / elapsed
            if abs(throughput - expected) > max(1.0, expected * 0.01):
                raise ValueError(f"{mode}-t{threads} throughput does not match ops_ok/elapsed")
            latencies = {
                "avg": finite_number(raw["avg_us"], "avg_us"),
                **{name: finite_number(raw[name], name) for name in LATENCY_COLUMNS},
            }
            if min(latencies.values()) < 0:
                raise ValueError(f"{mode}-t{threads} has a negative latency")
            if not (latencies["p50_us"] <= latencies["p95_us"] <= latencies["p99_us"] <= latencies["max_us"]):
                raise ValueError(f"{mode}-t{threads} latency percentiles are not ordered")
            if latencies["avg"] > latencies["max_us"]:
                raise ValueError(f"{mode}-t{threads} average latency exceeds max")
            rows.append(
                {
                    "mode": mode,
                    "threads": threads,
                    "ops_ok": ops_ok,
                    "throughput": throughput,
                    "latencies_us": latencies,
                }
            )
    return rows


def group_rounds(rows: list[dict], modes: list[str], threads: list[int], rounds: int) -> dict:
    grouped: dict[tuple[str, int], list[dict]] = {
        (mode, thread): [] for mode in modes for thread in threads
    }
    for row in rows:
        key = (row["mode"], row["threads"])
        if key not in grouped:
            raise ValueError(f"unexpected case in CSV: {row['mode']}-t{row['threads']}")
        grouped[key].append(row)
    for key, values in grouped.items():
        if len(values) != rounds:
            raise ValueError(f"{key[0]}-t{key[1]} has {len(values)} rounds, expected {rounds}")
    return grouped


def build_result(
    rows: list[dict],
    modes: list[str],
    threads: list[int],
    rounds: int,
    keyspace: int,
    value_size: int,
    warmup_ops: int,
    cpus: int = 32,
    jvm_flags: str = "",
) -> dict:
    if not modes or not threads or rounds <= 0 or keyspace <= 0 or value_size <= 0:
        raise ValueError("workload parameters must be positive")
    if cpus <= 0:
        raise ValueError("cpus must be positive")
    grouped = group_rounds(rows, modes, threads, rounds)
    results = {}
    for mode in modes:
        for thread in threads:
            values = grouped[(mode, thread)]
            throughput = statistics.median(row["throughput"] for row in values)
            group = f"{mode}-t{thread}"
            results[f"{group}/throughput"] = {
                "value": round(throughput, 3),
                "unit": "ops/s",
                "direction": "higher_is_better",
                "group": group,
            }
            results[f"{group}/single_core_throughput"] = {
                "value": round(throughput / cpus, 3),
                "unit": "ops/s",
                "direction": "higher_is_better",
                "group": group,
            }
            for name, short in (("p50_us", "p50_ms"), ("p95_us", "p95_ms"),
                                ("p99_us", "p99_ms"), ("max_us", "max_ms")):
                micros = statistics.median(row["latencies_us"][name] for row in values)
                results[f"{group}/{short}"] = {
                    "value": round(micros / 1000.0, 4),
                    "unit": "ms",
                    "direction": "lower_is_better",
                    "group": group,
                }
    per_thread_ops = {}
    for thread in threads:
        total_ops = {1: 20000, 8: 40000, 32: 200000, 64: 400000}[thread]
        per_thread_ops[str(thread)] = total_ops // thread
    return {
        "parameters": {
            "keyspace": keyspace,
            "value_size_bytes": value_size,
            "warmup_ops_per_thread": warmup_ops,
            "rounds": rounds,
            "modes": modes,
            "threads": threads,
            "ops_per_thread": per_thread_ops,
            "container_cpus": cpus,
            "jvm_flags": jvm_flags,
        },
        "results": results,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--modes", required=True)
    parser.add_argument("--threads", required=True)
    parser.add_argument("--rounds", required=True, type=int)
    parser.add_argument("--keyspace", required=True, type=int)
    parser.add_argument("--value-size", required=True, type=int)
    parser.add_argument("--warmup-ops", required=True, type=int)
    parser.add_argument("--jvm-flags", default="")
    parser.add_argument("--cpus", type=int, default=32)
    args = parser.parse_args()

    modes = args.modes.split()
    threads = sorted({int(value) for value in args.threads.split()})
    result = build_result(
        read_rows(args.csv),
        modes,
        threads,
        args.rounds,
        args.keyspace,
        args.value_size,
        args.warmup_ops,
        cpus=args.cpus,
        jvm_flags=args.jvm_flags,
    )
    args.output.write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
