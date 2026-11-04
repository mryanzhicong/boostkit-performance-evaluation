#!/usr/bin/env python3
"""Normalize the CMake configure/build matrix from the recorded samples.

Every scenario contributes two metrics: the wall-clock median of the measured
CMake invocation (seconds, lower is better) and the median peak resident set
size of that invocation's process tree (MiB, lower is better).  Raw
per-repetition logs and timing JSON files stay in ``runs/<scenario>/`` as the
primary evidence; this script only aggregates them and fails when a declared
scenario is incomplete, when a measurement exited non-zero, or when a sample is
not a positive finite number.  It never fills in, estimates or zero-pads a
missing measurement.
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

SCALES = (100, 1000, 10000)
TASKS = ("configure", "clean_build", "incremental_build", "noop_build")
UPSTREAM_SCENARIOS = (
    "upstream_configure",
    "upstream_build",
    "upstream_incremental_build",
    "upstream_noop_build",
)
UPSTREAM_TASKS = {
    "upstream_configure": "configure",
    "upstream_build": "clean_build",
    "upstream_incremental_build": "incremental_build",
    "upstream_noop_build": "noop_build",
}
UPSTREAM_WORKLOAD = "upstream Kitware/CMake release source tree (target: cmake)"


def fail(message: str) -> None:
    print(f"[cmake-parse] ERROR: {message}", file=sys.stderr)


def expected_scenarios() -> list[str]:
    scenarios: list[str] = []
    for scale in SCALES:
        for task in TASKS:
            scenarios.append(f"{task}_{scale}")
    scenarios.extend(UPSTREAM_SCENARIOS)
    return scenarios


def scenario_metadata(scenario: str) -> dict[str, Any]:
    if scenario in UPSTREAM_TASKS:
        return {
            "scenario": scenario,
            "task": UPSTREAM_TASKS[scenario],
            "scale_sources": None,
            "workload": UPSTREAM_WORKLOAD,
        }
    task, _, scale = scenario.rpartition("_")
    return {
        "scenario": scenario,
        "task": task,
        "scale_sources": int(scale),
        "workload": "generated deterministic C project",
    }


def load_samples(scenario_dir: Path, reps: int) -> list[dict[str, Any]]:
    samples: list[dict[str, Any]] = []
    for index in range(1, reps + 1):
        sample_path = scenario_dir / f"rep{index}.json"
        if not sample_path.is_file():
            raise RuntimeError(f"missing repetition sample: {sample_path}")
        try:
            payload = json.loads(sample_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            raise RuntimeError(f"invalid repetition sample {sample_path}: {exc}") from exc
        if not isinstance(payload, dict):
            raise RuntimeError(f"repetition sample is not an object: {sample_path}")
        exit_code = payload.get("exit_code")
        if exit_code != 0:
            raise RuntimeError(
                f"repetition {sample_path.name} for {scenario_dir.name} failed "
                f"with exit code {exit_code}"
            )
        if payload.get("timed_out") is True:
            raise RuntimeError(
                f"repetition {sample_path.name} for {scenario_dir.name} timed out"
            )
        wall = payload.get("wall_seconds")
        rss = payload.get("max_rss_mib")
        if isinstance(wall, bool) or not isinstance(wall, (int, float)):
            raise RuntimeError(f"repetition {sample_path.name} has no numeric wall time")
        if isinstance(rss, bool) or not isinstance(rss, (int, float)):
            raise RuntimeError(f"repetition {sample_path.name} has no numeric RSS")
        if not math.isfinite(float(wall)) or wall <= 0:
            raise RuntimeError(f"repetition {sample_path.name} wall time must be positive")
        if not math.isfinite(float(rss)) or rss <= 0:
            raise RuntimeError(f"repetition {sample_path.name} RSS must be positive")
        log_path = scenario_dir / f"rep{index}.log"
        if not log_path.is_file() or log_path.stat().st_size == 0:
            raise RuntimeError(f"missing raw log for repetition {sample_path.name}")
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
    metadata: dict[str, Any],
    value: float,
    unit: str,
    direction: str,
    statistics_payload: dict[str, float],
    samples: list[float],
) -> dict[str, Any]:
    return {
        "source_name": name,
        "scenario": metadata["scenario"],
        "task": metadata["task"],
        "scale_sources": metadata["scale_sources"],
        "workload": metadata["workload"],
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
        reps = int(os.environ.get("CMAKE_REPS", "5"))
        jobs = int(os.environ.get("CMAKE_JOBS", "4"))
    except ValueError:
        fail("CMAKE_REPS and CMAKE_JOBS must be integers")
        return 1
    if reps < 1:
        fail("CMAKE_REPS must be positive")
        return 1
    if jobs < 1:
        fail("CMAKE_JOBS must be positive")
        return 1
    if not runs_dir.is_dir():
        fail(f"runs directory does not exist: {runs_dir}")
        return 1

    results: dict[str, Any] = {}
    try:
        for scenario in expected_scenarios():
            scenario_dir = runs_dir / scenario
            if not scenario_dir.is_dir():
                raise RuntimeError(f"missing scenario directory: {scenario_dir}")
            samples = load_samples(scenario_dir, reps)
            metadata = scenario_metadata(scenario)
            wall_values = [sample["wall_seconds"] for sample in samples]
            rss_values = [sample["max_rss_mib"] for sample in samples]
            wall_stats = summarize(wall_values)
            rss_stats = summarize(rss_values)
            results[scenario] = build_metric(
                scenario,
                metadata,
                wall_stats["median"],
                "s",
                "lower_is_better",
                wall_stats,
                wall_values,
            )
            results[f"{scenario}_rss"] = build_metric(
                f"{scenario}_rss",
                metadata,
                rss_stats["median"],
                "MiB",
                "lower_is_better",
                rss_stats,
                rss_values,
            )
    except RuntimeError as exc:
        fail(str(exc))
        return 1

    normalized: dict[str, Any] = {
        "benchmark": "cmake_configure_build_matrix",
        "software": "cmake",
        "version": version,
        "architecture": architecture,
        "variant": variant,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "variant": variant,
            "repetitions": reps,
            "warmups": 1,
            "offline": True,
            "build_parallel_jobs": jobs,
            "build_tool": "Unix Makefiles (CMake default for this generator)",
            "build_type": "Release",
            "compile_flags": "-O2 -DNDEBUG",
            "c_compiler": os.environ.get("CMAKE_COMPILER", "unknown"),
            "cmake_version_string": os.environ.get("CMAKE_VERSION_STRING", ""),
            "distribution_sha256": os.environ.get("CMAKE_ARCHIVE_SHA256", ""),
            "source_sha256": os.environ.get("CMAKE_SOURCE_SHA256", ""),
            "scales_sources": list(SCALES),
            "tasks": list(TASKS),
            "upstream_scenarios": list(UPSTREAM_SCENARIOS),
            "upstream_build_target": "cmake",
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
        f"[cmake-parse] normalized {len(results)} metrics across "
        f"{len(expected_scenarios())} scenarios"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
