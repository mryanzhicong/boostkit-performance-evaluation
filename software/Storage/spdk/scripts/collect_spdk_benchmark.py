#!/usr/bin/env python3
"""Collect the blobstore benchmark run reports into results.json."""

from __future__ import annotations

import json
import math
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


# Scenario matrix: workloads crossed with the thread ladder
# (mysql thread-ladder style).  The run-file slugs match spdk_test.sh.
WORKLOADS = ("create", "write", "read")
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
            "usage: collect_spdk_benchmark.py RUNS_DIR OUTPUT",
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
                source_name = f"spdk {workload} --threads={threads}: {field}"
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
                "software": "spdk",
                "version": os.environ["SOFTWARE_VERSION"],
                "architecture": os.environ["EXPECTED_ARCH"],
                "timestamp": datetime.now(timezone.utc).strftime(
                    "%Y-%m-%dT%H:%M:%SZ"
                ),
                "parameters": {
                    "build": "official git tag sources, configure defaults "
                    "(dpdk max_numa_nodes=1)",
                    "blobstore": "one blobstore instance per worker on an "
                    "anonymous-memory bs_dev (512B blocks, 256MiB)",
                    "env": "spdk env_dpdk, no-huge, no-pci, 1GiB, core_mask "
                    "0x1 (workers are plain pthreads)",
                    "clock": "CLOCK_MONOTONIC (unit=ns)",
                    "warmup_seconds": int(
                        os.environ.get("SPDK_WARMUP_SECONDS", "5")
                    ),
                    "duration_seconds": int(
                        os.environ.get("SPDK_DURATION_SECONDS", "30")
                    ),
                    "threads_ladder": list(THREADS_LADDER),
                    "scenarios": {
                        "create": "spdk_bs_create_blob + "
                        "spdk_bs_delete_blob lifecycles, one blobstore per "
                        "worker (1 op = blob created and deleted)",
                        "write": "4KiB spdk_blob_io_write, queue depth 8, "
                        "preallocated 4MiB blob per worker",
                        "read": "4KiB spdk_blob_io_read, queue depth 8, "
                        "preallocated 4MiB blob per worker",
                    },
                },
                "results": results,
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    print(f"[spdk] recorded {len(results)} blobstore benchmark metrics")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError) as exc:
        print(f"[spdk] ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
