#!/usr/bin/env python3
"""Normalize the Maven build matrix from the recorded per-repetition samples.

Every scenario contributes two metrics: the wall-clock median of the measured
build commands (seconds, lower is better) and the median peak resident set
size of the Maven JVM (MiB, lower is better). Raw per-repetition logs and
timing JSON files stay in ``runs/<scenario>/`` as the primary evidence; this
script only aggregates them and fails when a declared scenario is incomplete.
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
TASKS = ("clean_package", "incremental_package", "noop_package")
EXTRA_SCENARIOS = ("maven_self_build",)


def fail(message: str) -> None:
    print(f"[maven-parse] ERROR: {message}", file=sys.stderr)


def expected_scenarios() -> list[str]:
    scenarios: list[str] = []
    for scale in SCALES:
        for task in TASKS:
            scenarios.append(f"{task}_{scale}")
    scenarios.extend(EXTRA_SCENARIOS)
    return scenarios


def scenario_metadata(scenario: str) -> dict[str, Any]:
    if scenario == "maven_self_build":
        return {
            "scenario": scenario,
            "task": "clean_package",
            "scale_classes": None,
            "workload": "upstream apache/maven source tree",
        }
    task, _, scale = scenario.rpartition("_")
    return {
        "scenario": scenario,
        "task": task,
        "scale_classes": int(scale),
        "workload": "generated single-module java project",
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
        "scale_classes": metadata["scale_classes"],
        "workload": metadata["workload"],
        "value": value,
        "unit": unit,
        "direction": direction,
        **statistics_payload,
        "samples": samples,
    }


def jdk_release(jdk_home: str | None) -> str:
    if not jdk_home:
        return "unknown"
    release = Path(jdk_home) / "release"
    try:
        for line in release.read_text(encoding="utf-8").splitlines():
            if line.startswith("JAVA_VERSION="):
                return line.split("=", 1)[1].strip().strip('"')
    except OSError:
        return "unknown"
    return "unknown"


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
        reps = int(os.environ.get("MAVEN_REPS", "5"))
    except ValueError:
        fail("MAVEN_REPS must be an integer")
        return 1
    if reps < 1:
        fail("MAVEN_REPS must be positive")
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
                scenario, metadata, wall_stats["median"], "s", "lower_is_better",
                wall_stats, wall_values,
            )
            results[f"{scenario}_rss"] = build_metric(
                f"{scenario}_rss", metadata, rss_stats["median"], "MiB",
                "lower_is_better", rss_stats, rss_values,
            )
    except RuntimeError as exc:
        fail(str(exc))
        return 1

    normalized: dict[str, Any] = {
        "benchmark": "maven_build_matrix",
        "software": "maven",
        "version": version,
        "architecture": architecture,
        "variant": variant,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "variant": variant,
            "repetitions": reps,
            "warmups": 1,
            "offline": True,
            "command_flags": ["-B", "-o", "-ntp", "-Dstyle.color=never"],
            "scales_classes": list(SCALES),
            "tasks": list(TASKS),
            "extra_scenarios": list(EXTRA_SCENARIOS),
            "jdk_release": jdk_release(os.environ.get("JDK_HOME")),
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
    print(f"[maven-parse] normalized {len(results)} metrics across {len(expected_scenarios())} scenarios")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
