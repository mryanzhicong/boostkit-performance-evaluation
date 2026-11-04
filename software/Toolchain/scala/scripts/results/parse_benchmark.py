#!/usr/bin/env python3
"""Normalize the recorded per-repetition samples into the results document.

Every scenario contributes two mandatory metrics: the wall-clock median of the
measured commands (seconds, lower is better) and the median peak resident set
size (MiB, lower is better).  Scenarios that process a countable amount of work
additionally report a throughput metric derived from the same samples.  Raw
per-repetition logs and timing JSON files stay in ``runs/<scenario>/`` as the
primary evidence; this script only aggregates them and fails hard when a
declared scenario is incomplete, so a partial run can never look like a pass.
"""

from __future__ import annotations

import json
import math
import os
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

SOFTWARE = "scala"
BENCHMARK = "scala_compile_and_run"


def fail(message: str) -> None:
    print(f"[{SOFTWARE}-parse] ERROR: {message}", file=sys.stderr)


def load_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"invalid JSON in {path}: {exc}") from exc


def load_samples(scenario_dir: Path, reps: int) -> list[dict[str, Any]]:
    samples: list[dict[str, Any]] = []
    for index in range(1, reps + 1):
        sample_path = scenario_dir / f"rep{index}.json"
        if not sample_path.is_file():
            raise RuntimeError(f"missing repetition sample: {sample_path}")
        payload = load_json(sample_path)
        if not isinstance(payload, dict):
            raise RuntimeError(f"repetition sample is not an object: {sample_path}")
        exit_code = payload.get("exit_code")
        if exit_code != 0:
            raise RuntimeError(
                f"repetition {sample_path.name} for {scenario_dir.name} failed "
                f"with exit code {exit_code}"
            )
        wall = payload.get("wall_seconds")
        rss = payload.get("max_rss_mib")
        if isinstance(wall, bool) or not isinstance(wall, (int, float)):
            raise RuntimeError(f"repetition {sample_path.name} has no numeric wall time")
        if isinstance(rss, bool) or not isinstance(rss, (int, float)):
            raise RuntimeError(f"repetition {sample_path.name} has no numeric RSS")
        if not math.isfinite(float(wall)) or float(wall) <= 0:
            raise RuntimeError(f"repetition {sample_path.name} wall time must be positive")
        if not math.isfinite(float(rss)) or float(rss) <= 0:
            raise RuntimeError(f"repetition {sample_path.name} RSS must be positive")
        samples.append(
            {
                "repetition": index,
                "wall_seconds": round(float(wall), 6),
                "max_rss_mib": round(float(rss), 3),
                "log": f"rep{index}.log",
            }
        )
    return samples


def summarize(values: list[float]) -> dict[str, float]:
    return {
        "median": round(float(statistics.median(values)), 6),
        "mean": round(float(statistics.fmean(values)), 6),
        "min": round(float(min(values)), 6),
        "max": round(float(max(values)), 6),
        "stdev": round(float(statistics.stdev(values)), 6) if len(values) > 1 else 0.0,
    }


def build_metric(
    name: str,
    spec: dict[str, Any],
    value: float,
    unit: str,
    direction: str,
    statistics_payload: dict[str, float],
    samples: list[float],
) -> dict[str, Any]:
    return {
        "source_name": name,
        "scenario": spec["scenario"],
        "description": spec.get("description", ""),
        "workload": spec.get("workload", ""),
        "value": value,
        "unit": unit,
        "direction": direction,
        **statistics_payload,
        "samples": samples,
    }


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: parse_benchmark.py RUNS_DIRECTORY NORMALIZED_OUTPUT", file=sys.stderr)
        return 1
    runs_dir = Path(sys.argv[1])
    normalized_output = Path(sys.argv[2])
    try:
        version = os.environ["SOFTWARE_VERSION"]
        architecture = os.environ["EXPECTED_ARCH"]
        variant = os.environ.get("PERF_VARIANT", "base")
    except KeyError as exc:
        fail(f"missing environment variable: {exc}")
        return 1
    try:
        reps = int(os.environ.get("PERF_REPS", "5"))
    except ValueError:
        fail("PERF_REPS must be an integer")
        return 1
    if reps < 1:
        fail("PERF_REPS must be positive")
        return 1
    meta_path = runs_dir / "scenario_meta.json"
    if not meta_path.is_file():
        fail(f"scenario metadata is missing: {meta_path}")
        return 1
    try:
        meta = load_json(meta_path)
        specs = meta.get("scenarios")
        if not isinstance(specs, list) or not specs:
            raise RuntimeError("scenario metadata contains no scenarios")
        declared_reps = int(meta.get("reps", reps))
        if declared_reps != reps:
            raise RuntimeError(
                f"scenario metadata was written for {declared_reps} repetitions, "
                f"but PERF_REPS={reps}"
            )

        results: dict[str, Any] = {}
        for spec in specs:
            if not isinstance(spec, dict) or not isinstance(spec.get("scenario"), str):
                raise RuntimeError("scenario metadata entry is malformed")
            scenario = spec["scenario"]
            scenario_dir = runs_dir / scenario
            if not scenario_dir.is_dir():
                raise RuntimeError(f"missing scenario directory: {scenario_dir}")
            samples = load_samples(scenario_dir, reps)
            wall_values = [sample["wall_seconds"] for sample in samples]
            rss_values = [sample["max_rss_mib"] for sample in samples]
            wall_stats = summarize(wall_values)
            rss_stats = summarize(rss_values)
            results[f"{scenario}__wall_seconds"] = build_metric(
                f"{scenario}__wall_seconds",
                spec,
                wall_stats["median"],
                "s",
                "lower_is_better",
                wall_stats,
                wall_values,
            )
            results[f"{scenario}__peak_rss_mib"] = build_metric(
                f"{scenario}__peak_rss_mib",
                spec,
                rss_stats["median"],
                "MiB",
                "lower_is_better",
                rss_stats,
                rss_values,
            )
            throughput = spec.get("throughput")
            if isinstance(throughput, dict):
                items = throughput.get("items")
                if isinstance(items, bool) or not isinstance(items, (int, float)) or items <= 0:
                    raise RuntimeError(f"scenario {scenario} has an invalid throughput item count")
                throughput_values = [
                    round(float(items) / sample["wall_seconds"], 6) for sample in samples
                ]
                throughput_stats = summarize(throughput_values)
                results[f"{scenario}__{throughput['name']}"] = build_metric(
                    f"{scenario}__{throughput['name']}",
                    spec,
                    throughput_stats["median"],
                    str(throughput["unit"]),
                    str(throughput.get("direction", "higher_is_better")),
                    throughput_stats,
                    throughput_values,
                )
    except (RuntimeError, KeyError, TypeError, ValueError) as exc:
        fail(str(exc))
        return 1

    normalized: dict[str, Any] = {
        "benchmark": BENCHMARK,
        "software": SOFTWARE,
        "version": version,
        "architecture": architecture,
        "variant": variant,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "variant": variant,
            "repetitions": reps,
            "warmups": 1,
            "scenarios": [spec["scenario"] for spec in specs],
            **({"extra_parameters": meta["parameters"]} if isinstance(meta.get("parameters"), dict) else {}),
        },
        "metric_contract": {
            "wall_time": {"unit": "s", "direction": "lower_is_better"},
            "peak_rss": {"unit": "MiB", "direction": "lower_is_better"},
            "statistic": "median of independent repetitions",
        },
        "results": results,
    }
    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(normalized, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(
        f"[{SOFTWARE}-parse] normalized {len(results)} metrics across {len(specs)} scenarios"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
