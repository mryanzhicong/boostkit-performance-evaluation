#!/usr/bin/env python3
"""Aggregate the official run_benchmark.sh results into benchmark_xla.json."""

from __future__ import annotations

import argparse
import json
import math
import sys
from datetime import datetime, timezone
from pathlib import Path

BENCHMARKS = (
    "gemma3_1b_flax_call",
    "gemma2_2b_keras_jax",
    "gemma4_2b_bf16",
)
FIELDS = ("CPU_TIME", "WALL_TIME")
HARDWARE_CATEGORIES = {
    "x86_64": "CPU_X86",
    "aarch64": "CPU_ARM64",
}
XLA_COMMIT = "1930995a8aabe45a13854f701b5b39ab732aef94"


def load_result(path: Path, benchmark: str, expected_category: str) -> dict:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except OSError as exc:
        raise ValueError(f"cannot read {path}: {exc}") from exc
    if payload.get("benchmark_name") != benchmark:
        raise ValueError(
            f"{path} reports {payload.get('benchmark_name')!r}, expected {benchmark!r}"
        )
    if payload.get("run_status") != "SUCCESS":
        raise ValueError(
            f"benchmark {benchmark} did not complete successfully: "
            f"{payload.get('run_status')} ({payload.get('error_message')})"
        )
    if payload.get("hardware_category") != expected_category:
        raise ValueError(
            f"benchmark {benchmark} ran on {payload.get('hardware_category')!r}, "
            f"expected {expected_category!r}"
        )
    metrics = payload.get("metrics")
    if not isinstance(metrics, dict):
        raise ValueError(f"benchmark {benchmark} has no metrics object")
    for field in FIELDS:
        metric = metrics.get(field)
        if not isinstance(metric, dict):
            raise ValueError(f"benchmark {benchmark} is missing the {field} metric")
        value = metric.get("value")
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            raise ValueError(f"benchmark {benchmark} {field} is not numeric")
        if not math.isfinite(float(value)) or value <= 0:
            raise ValueError(f"benchmark {benchmark} {field} is not positive")
        if metric.get("unit") != "ms":
            raise ValueError(
                f"benchmark {benchmark} {field} uses unit {metric.get('unit')!r}, expected 'ms'"
            )
    return payload


def collect(
    benchmark_runs_dir: Path,
    version: str,
    architecture: str,
    num_repeats: int,
) -> dict:
    expected_category = HARDWARE_CATEGORIES.get(architecture)
    if expected_category is None:
        raise ValueError(f"unsupported architecture: {architecture}")
    results: dict[str, dict] = {}
    measurements: list[dict] = []
    for benchmark in BENCHMARKS:
        payload = load_result(
            benchmark_runs_dir / benchmark / "results.json",
            benchmark,
            expected_category,
        )
        for field in FIELDS:
            metric = payload["metrics"][field]
            name = f"{benchmark}/{field}"
            results[name] = {
                "value": metric["value"],
                "unit": metric["unit"],
                "direction": "lower_is_better",
                "group": benchmark,
            }
            measurements.append({
                "benchmark": benchmark,
                "source_field": field,
                "value": metric["value"],
                "unit": metric["unit"],
                "source_name": name,
                "source_file": f"benchmark_runs/{benchmark}/results.json",
            })
    return {
        "parameters": {
            "suite": "XLA official benchmark registry (CPU entries)",
            "xla_commit": XLA_COMMIT,
            "device_type": "host",
            "num_repeats": num_repeats,
            "benchmark_count": len(BENCHMARKS),
            "metrics_per_benchmark": len(FIELDS),
        },
        "runtime_context": {
            "xla_version": version,
            "architecture": architecture,
            "hardware_category": expected_category,
            "config_id": "cpu_x86" if architecture == "x86_64" else "cpu_arm64",
            "collected_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        },
        "measurements": measurements,
        "results": results,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("benchmark_runs_dir", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("version")
    parser.add_argument("architecture")
    parser.add_argument("num_repeats", type=int)
    args = parser.parse_args()
    try:
        payload = collect(
            args.benchmark_runs_dir, args.version, args.architecture, args.num_repeats
        )
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"[xla] ERROR: {exc}", file=sys.stderr)
        return 1
    print(f"[xla] collected {len(payload['results'])} metrics from {len(BENCHMARKS)} benchmarks")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
