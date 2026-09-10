#!/usr/bin/env python3
"""Collect the official run_benchmark.sh results into results.json."""

from __future__ import annotations

import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path


# The CPU entries of the official benchmark registry
# (xla/tools/benchmarks/benchmark_registry.pbtxt) and the two metrics the
# official run_benchmark.sh derives from each XSpace profile.
EXPECTED_BENCHMARKS = (
    "gemma3_1b_flax_call",
    "gemma2_2b_keras_jax",
    "gemma4_2b_bf16",
)
FIELDS = ("CPU_TIME", "WALL_TIME")
HARDWARE_CATEGORIES = {
    "x86_64": "CPU_X86",
    "aarch64": "CPU_ARM64",
}


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "usage: collect_xla_benchmark.py BENCHMARK_RUNS_DIR OUTPUT",
            file=sys.stderr,
        )
        return 1

    benchmark_runs_dir = Path(sys.argv[1])
    output_path = Path(sys.argv[2])
    architecture = os.environ["EXPECTED_ARCH"]
    expected_category = HARDWARE_CATEGORIES.get(architecture)
    if expected_category is None:
        print(
            f"[xla] ERROR: unsupported architecture: {architecture}",
            file=sys.stderr,
        )
        return 1

    results: dict[str, dict[str, object]] = {}
    for benchmark_name in EXPECTED_BENCHMARKS:
        results_json = benchmark_runs_dir / benchmark_name / "results.json"
        try:
            payload = json.loads(results_json.read_text(encoding="utf-8"))
        except OSError as exc:
            raise ValueError(f"cannot read {results_json}: {exc}") from exc
        if payload.get("benchmark_name") != benchmark_name:
            raise ValueError(
                f"{results_json} reports {payload.get('benchmark_name')!r}, "
                f"expected {benchmark_name!r}"
            )
        if payload.get("run_status") != "SUCCESS":
            raise ValueError(
                f"benchmark {benchmark_name} did not complete successfully: "
                f"{payload.get('run_status')} ({payload.get('error_message')})"
            )
        if payload.get("hardware_category") != expected_category:
            raise ValueError(
                f"benchmark {benchmark_name} ran on "
                f"{payload.get('hardware_category')!r}, expected {expected_category!r}"
            )
        metrics = payload.get("metrics")
        if not isinstance(metrics, dict):
            raise ValueError(f"benchmark {benchmark_name} has no metrics object")
        for field in FIELDS:
            metric = metrics.get(field)
            if not isinstance(metric, dict):
                raise ValueError(
                    f"benchmark {benchmark_name} is missing the {field} metric"
                )
            value = metric.get("value")
            if isinstance(value, bool) or not isinstance(value, (int, float)):
                raise ValueError(
                    f"benchmark {benchmark_name} metric {field} is not numeric"
                )
            if not value > 0:
                raise ValueError(
                    f"benchmark {benchmark_name} metric {field} must be positive"
                )
            if metric.get("unit") != "ms":
                raise ValueError(
                    f"benchmark {benchmark_name} metric {field} has unit "
                    f"{metric.get('unit')!r}, expected 'ms'"
                )
            source_name = f"{benchmark_name}: {field}"
            if source_name in results:
                raise ValueError(f"duplicate benchmark metric: {source_name}")
            results[source_name] = {
                "source_name": source_name,
                "scenario": benchmark_name,
                "source_field": field,
                "value": value,
                "unit": "ms",
                "direction": "lower_is_better",
                "source_file": f"benchmark_runs/{benchmark_name}/results.json",
            }

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps(
            {
                "software": "xla",
                "version": os.environ["SOFTWARE_VERSION"],
                "architecture": architecture,
                "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
                "results": results,
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    print(f"[xla] recorded {len(results)} official benchmark metrics")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError) as exc:
        print(f"[xla] ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
