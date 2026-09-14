#!/usr/bin/env python3
"""Collect the allocation benchmark run reports into results.json."""

from __future__ import annotations

import json
import math
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


# Scenario matrix: workloads crossed with the thread ladder
# (mysql thread-ladder style).  The run-file slugs match
# jemalloc_test.sh.
WORKLOADS = ("small", "mixed")
THREADS_LADDER = (1, 4, 16, 64)

# Report fields kept per (workload, threads) combination.  All
# latencies are measured with clock_gettime(CLOCK_MONOTONIC) and are
# reported in nanoseconds on every architecture.
FIELDS = (
    ("ops/s", "operations_per_second", "ops/s", "higher_is_better"),
    ("avg op", "avg_op_ns", "ns", "lower_is_better"),
    ("p99 op", "p99_op_ns", "ns", "lower_is_better"),
)


def load_run(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ValueError(f"cannot read {path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise ValueError(f"{path} is not a JSON object")
    return payload


def validate_run(
    payload: dict[str, Any], workload: str, threads: int, path: Path
) -> None:
    if payload.get("workload") != workload:
        raise ValueError(
            f"{path} reports workload {payload.get('workload')!r}, "
            f"expected {workload!r}"
        )
    if payload.get("scenario") != workload:
        raise ValueError(
            f"{path} reports scenario {payload.get('scenario')!r}, "
            f"expected {workload!r}"
        )
    if payload.get("threads") != threads:
        raise ValueError(
            f"{path} reports threads {payload.get('threads')!r}, "
            f"expected {threads}"
        )
    if not payload.get("duration_seconds", 0) > 0:
        raise ValueError(f"{path} has a non-positive duration")
    for field, json_field, _unit, _direction in FIELDS:
        value = payload.get(json_field)
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            raise ValueError(f"{path} is missing a numeric {json_field}")
        if not math.isfinite(float(value)) or value <= 0:
            raise ValueError(f"{path} has a non-positive {json_field}: {value}")


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "usage: collect_jemalloc_benchmark.py RUNS_DIR OUTPUT",
            file=sys.stderr,
        )
        return 1

    runs_dir = Path(sys.argv[1])
    output_path = Path(sys.argv[2])
    results: dict[str, dict[str, Any]] = {}

    for workload in WORKLOADS:
        for threads in THREADS_LADDER:
            run_path = runs_dir / f"{workload}-t{threads}.json"
            payload = load_run(run_path)
            validate_run(payload, workload, threads, run_path)
            for field, json_field, unit, direction in FIELDS:
                source_name = (
                    f"jemalloc {workload} --threads={threads}: {field}"
                )
                if source_name in results:
                    raise ValueError(f"duplicate benchmark metric: {source_name}")
                results[source_name] = {
                    "source_name": source_name,
                    "workload": workload,
                    "threads": threads,
                    "source_field": field,
                    "value": payload[json_field],
                    "unit": unit,
                    "direction": direction,
                    "source_file": f"benchmark/runs/{run_path.name}",
                }

    expected = len(WORKLOADS) * len(THREADS_LADDER) * len(FIELDS)
    if len(results) != expected:
        raise ValueError(f"collected {len(results)} metrics, expected {expected}")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps(
            {
                "software": "jemalloc",
                "version": os.environ["SOFTWARE_VERSION"],
                "architecture": os.environ["EXPECTED_ARCH"],
                "timestamp": datetime.now(timezone.utc).strftime(
                    "%Y-%m-%dT%H:%M:%SZ"
                ),
                "parameters": {
                    "build": "official source tarball, default configure",
                    "clock": "CLOCK_MONOTONIC (unit=ns)",
                    "warmup_seconds": int(
                        os.environ.get("JEMALLOC_WARMUP_SECONDS", "5")
                    ),
                    "duration_seconds": int(
                        os.environ.get("JEMALLOC_DURATION_SECONDS", "30")
                    ),
                    "threads_ladder": list(THREADS_LADDER),
                    "scenarios": {
                        "small": "16-512 B short-lived objects, "
                        "per-thread slot ring (tcache fast path)",
                        "mixed": "log-uniform 16 B - 256 KiB objects, "
                        "random replacement (arena and fragmentation)",
                    },
                },
                "results": results,
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    print(f"[jemalloc] recorded {len(results)} allocation benchmark metrics")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError) as exc:
        print(f"[jemalloc] ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
