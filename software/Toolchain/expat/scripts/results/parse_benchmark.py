#!/usr/bin/env python3
"""Normalize the expat parse/validation/upstream-test matrix.

Every measured scenario contributes a wall-clock median (seconds, lower is
better) and a median peak resident set size (MiB, lower is better).  Scenarios
that parse a known corpus additionally contribute a derived throughput
(MiB/s, higher is better); the upstream test suite contributes a derived test
rate (tests/s, higher is better); the upstream benchmark contributes the
average parse time it reports itself (seconds per loop, lower is better).

Raw per-repetition logs and timing JSON files stay in ``runs/<scenario>/`` as
the primary evidence; this script only aggregates them and fails when a declared
scenario is incomplete, when a measurement exited non-zero, when a sample is not
a positive finite number, when a repetition log lacks the pinned correctness
marker, or when the corpus manifest is missing.  It never fills in, estimates or
zero-pads a missing measurement.
"""

from __future__ import annotations

import json
import math
import os
import re
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

# scenario -> task, corpus file (optional), upstream driver (optional)
SCENARIOS: list[dict[str, Any]] = [
    {"scenario": "xmlwf_parse_wide", "task": "parse", "corpus": "wide.xml"},
    {"scenario": "xmlwf_parse_huge", "task": "parse", "corpus": "huge.xml"},
    {"scenario": "xmlwf_parse_namespaced", "task": "parse", "corpus": "namespaced.xml"},
    {"scenario": "xmlwf_parse_entities", "task": "parse", "corpus": "entities.xml"},
    {"scenario": "xmlwf_parse_external_dtd", "task": "parse", "corpus": "dtd_ext.xml"},
    {"scenario": "upstream_runtests", "task": "upstream_suite", "driver": "runtests"},
    {
        "scenario": "upstream_benchmark_wide",
        "task": "upstream_benchmark",
        "corpus": "wide.xml",
    },
    {
        "scenario": "upstream_benchmark_namespaced",
        "task": "upstream_benchmark",
        "corpus": "namespaced.xml",
    },
]

MIB = 1024 * 1024
AVERAGE_TIME_PATTERN = re.compile(r"Average time per loop:\s*([0-9]+(?:\.[0-9]+)?)")


def fail(message: str) -> None:
    print(f"[expat-parse] ERROR: {message}", file=sys.stderr)


def load_manifest(path: Path) -> dict[str, dict[str, Any]]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"cannot read corpus manifest {path}: {exc}") from exc
    files = payload.get("files")
    if not isinstance(files, dict) or not files:
        raise RuntimeError(f"corpus manifest {path} has no files section")
    return files


def expected_log_pattern(
    scenario: dict[str, Any], checks: int, iterations: int, buffer_size: int
) -> tuple[str, str]:
    name = scenario["scenario"]
    if name == "upstream_runtests":
        return (rf"Checks: {checks}, Failed: 0", "pinned upstream summary")
    if name.startswith("upstream_benchmark_"):
        return (
            rf"{iterations} loops, with buffer size {buffer_size}",
            "pinned benchmark summary",
        )
    return (r"^# command: ", "measurement command header")


def load_samples(
    scenario: dict[str, Any],
    scenario_dir: Path,
    reps: int,
    expected_pattern: str,
    expected_label: str,
) -> list[dict[str, Any]]:
    samples: list[dict[str, Any]] = []
    pattern = re.compile(expected_pattern)
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
            raise RuntimeError(f"repetition {sample_path.name} for {scenario_dir.name} timed out")
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
        log_text = log_path.read_text(encoding="utf-8", errors="replace")
        if not any(pattern.search(line) for line in log_text.splitlines()):
            raise RuntimeError(
                f"repetition {sample_path.name} for {scenario_dir.name} does not show the "
                f"expected {expected_label}"
            )
        if scenario["task"] == "parse" and re.search(r"(?i)\berror\b", log_text):
            raise RuntimeError(
                f"repetition {sample_path.name} for {scenario_dir.name} reported an error"
            )
        average_seconds: float | None = None
        if scenario["task"] == "upstream_benchmark":
            matches = AVERAGE_TIME_PATTERN.findall(log_text)
            if len(matches) != 1:
                raise RuntimeError(
                    f"repetition {sample_path.name} for {scenario_dir.name} has "
                    f"{len(matches)} benchmark average-time lines, expected exactly 1"
                )
            average_seconds = float(matches[0])
            if not math.isfinite(average_seconds) or average_seconds <= 0:
                raise RuntimeError(
                    f"repetition {sample_path.name} benchmark average time must be positive"
                )
        samples.append(
            {
                "repetition": index,
                "wall_seconds": round(float(wall), 6),
                "max_rss_mib": round(float(rss), 3),
                "log": f"rep{index}.log",
                "average_parse_seconds": (
                    round(average_seconds, 6) if average_seconds is not None else None
                ),
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
    scenario: dict[str, Any],
    value: float,
    unit: str,
    direction: str,
    stats_payload: dict[str, float],
    samples: list[float],
) -> dict[str, Any]:
    return {
        "source_name": name,
        "scenario": scenario["scenario"],
        "task": scenario["task"],
        "value": value,
        "unit": unit,
        "direction": direction,
        **stats_payload,
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
    except KeyError as exc:
        fail(f"missing environment variable: {exc}")
        return 1
    variant = os.environ.get("PERF_VARIANT", "base")
    try:
        reps = int(os.environ.get("EXPAT_REPS", "5"))
        jobs = int(os.environ.get("EXPAT_JOBS", "4"))
        checks = int(os.environ.get("EXPAT_RUNTESTS_CHECKS", "5196"))
        iterations = int(os.environ.get("EXPAT_BENCH_ITERATIONS", "20"))
        buffer_size = int(os.environ.get("EXPAT_BENCH_BUFFER", "8192"))
    except ValueError:
        fail("EXPAT_REPS/EXPAT_JOBS/counters must be integers")
        return 1
    if reps < 1 or jobs < 1 or checks < 1 or iterations < 1 or buffer_size < 1:
        fail("EXPAT_REPS/EXPAT_JOBS/counters must be positive")
        return 1
    manifest_path = Path(os.environ.get("EXPAT_CORPUS_MANIFEST", ""))
    if not manifest_path.is_file():
        fail(f"corpus manifest is missing: {manifest_path}")
        return 1
    if not runs_dir.is_dir():
        fail(f"runs directory does not exist: {runs_dir}")
        return 1

    try:
        manifest = load_manifest(manifest_path)
        results: dict[str, Any] = {}
        for scenario in SCENARIOS:
            name = scenario["scenario"]
            scenario_dir = runs_dir / name
            if not scenario_dir.is_dir():
                raise RuntimeError(f"missing scenario directory: {scenario_dir}")
            pattern, label = expected_log_pattern(scenario, checks, iterations, buffer_size)
            samples = load_samples(scenario, scenario_dir, reps, pattern, label)
            wall_values = [sample["wall_seconds"] for sample in samples]
            rss_values = [sample["max_rss_mib"] for sample in samples]
            wall_stats = summarize(wall_values)
            rss_stats = summarize(rss_values)
            results[name] = build_metric(
                name, scenario, wall_stats["median"], "s", "lower_is_better", wall_stats, wall_values
            )
            results[f"{name}_rss"] = build_metric(
                f"{name}_rss",
                scenario,
                rss_stats["median"],
                "MiB",
                "lower_is_better",
                rss_stats,
                rss_values,
            )
            if "corpus" in scenario:
                corpus = scenario["corpus"]
                if corpus not in manifest:
                    raise RuntimeError(f"corpus {corpus} is missing from {manifest_path}")
                byte_count = int(manifest[corpus]["bytes"])
                if byte_count <= 0:
                    raise RuntimeError(f"corpus {corpus} has a non-positive size in the manifest")
                if scenario["task"] == "upstream_benchmark":
                    byte_count *= iterations
                rate_values = [
                    (byte_count / MIB) / sample["wall_seconds"] for sample in samples
                ]
                rate_stats = summarize(rate_values)
                results[f"{name}_mbs"] = build_metric(
                    f"{name}_mbs",
                    scenario,
                    rate_stats["median"],
                    "MiB/s",
                    "higher_is_better",
                    rate_stats,
                    [round(value, 6) for value in rate_values],
                )
            if scenario["task"] == "upstream_suite":
                rate_values = [checks / sample["wall_seconds"] for sample in samples]
                rate_stats = summarize(rate_values)
                results[f"{name}_tps"] = build_metric(
                    f"{name}_tps",
                    scenario,
                    rate_stats["median"],
                    "tests/s",
                    "higher_is_better",
                    rate_stats,
                    [round(value, 6) for value in rate_values],
                )
            if scenario["task"] == "upstream_benchmark":
                average_values = [
                    float(sample["average_parse_seconds"]) for sample in samples
                ]
                average_stats = summarize(average_values)
                results[f"{name}_avg_s"] = build_metric(
                    f"{name}_avg_s",
                    scenario,
                    average_stats["median"],
                    "s",
                    "lower_is_better",
                    average_stats,
                    [round(value, 6) for value in average_values],
                )
    except RuntimeError as exc:
        fail(str(exc))
        return 1

    normalized: dict[str, Any] = {
        "benchmark": "expat_xml_parse_matrix",
        "software": "expat",
        "version": version,
        "architecture": architecture,
        "variant": variant,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "variant": variant,
            "repetitions": reps,
            "warmups": 1,
            "offline": True,
            "parse_network": "disabled (all corpora are local; only the external-DTD corpus is read from disk)",
            "build_parallel_jobs": jobs,
            "build_system": "autotools (in-tree ./configure + make)",
            "compile_flags": "-O2",
            "configure_flags": (
                "--disable-shared --enable-static --without-docbook --without-examples"
            ),
            "source_name": os.environ.get("EXPAT_SOURCE_NAME", ""),
            "source_sha256": os.environ.get("EXPAT_SOURCE_SHA256", ""),
            "source_url": os.environ.get("EXPAT_SOURCE_URL", ""),
            "expat_version_string": os.environ.get("EXPAT_VERSION_STRING", ""),
            "runtests_checks": checks,
            "benchmark_iterations": iterations,
            "benchmark_buffer": buffer_size,
            "corpora": {name: int(entry["bytes"]) for name, entry in sorted(manifest.items())},
            "scenarios": [scenario["scenario"] for scenario in SCENARIOS],
        },
        "metric_contract": {
            "wall_time": {"unit": "s", "direction": "lower_is_better"},
            "peak_rss": {"unit": "MiB", "direction": "lower_is_better"},
            "parse_throughput": {"unit": "MiB/s", "direction": "higher_is_better"},
            "test_rate": {"unit": "tests/s", "direction": "higher_is_better"},
            "benchmark_average_parse_time": {"unit": "s", "direction": "lower_is_better"},
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
        f"[expat-parse] normalized {len(results)} metrics across "
        f"{len(SCENARIOS)} scenarios"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
