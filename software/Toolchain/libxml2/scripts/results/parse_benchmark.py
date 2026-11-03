#!/usr/bin/env python3
"""Normalize the libxml2 parse/validation/upstream-test matrix.

Every measured scenario contributes a wall-clock median (seconds, lower is
better) and a median peak resident set size (MiB, lower is better).  Scenarios
that parse a known corpus additionally contribute a derived throughput
(MiB/s, higher is better) and the two upstream test drivers contribute a
derived test rate (tests/s, higher is better).

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
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

# scenario -> (task, corpus file or None, upstream driver or None)
SCENARIOS: list[dict[str, Any]] = [
    {"scenario": "xmllint_parse_wide", "task": "parse", "corpus": "wide.xml"},
    {"scenario": "xmllint_parse_huge", "task": "parse", "corpus": "huge.xml"},
    {"scenario": "xmllint_parse_deep", "task": "parse", "corpus": "deep.xml"},
    {"scenario": "xmllint_parse_namespaced", "task": "parse", "corpus": "namespaced.xml"},
    {"scenario": "xmllint_dtd_validate", "task": "dtd_validate", "corpus": "dtd.xml"},
    {"scenario": "xmllint_sax_namespaced", "task": "sax", "corpus": "namespaced.xml"},
    {"scenario": "xmllint_repeat_wide", "task": "repeat", "corpus": "repeat.xml"},
    {"scenario": "xmllint_xpath_wide", "task": "xpath", "corpus": "wide.xml"},
    {"scenario": "upstream_runtest", "task": "upstream_suite", "driver": "runtest"},
    {"scenario": "upstream_runsuite", "task": "upstream_suite", "driver": "runsuite"},
]

MIB = 1024 * 1024


def fail(message: str) -> None:
    print(f"[libxml2-parse] ERROR: {message}", file=sys.stderr)


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
    scenario: dict[str, Any], item_total: int, runtest_total: int, runsuite_total: int
) -> tuple[str, str]:
    name = scenario["scenario"]
    if name == "xmllint_xpath_wide":
        return (rf"^{item_total}\s*$", f"pinned XPath count {item_total}")
    if name == "upstream_runtest":
        return (rf"Total {runtest_total} tests, no errors", "pinned runtest summary")
    if name == "upstream_runsuite":
        return (rf"Total {runsuite_total} tests, no errors", "pinned runsuite summary")
    return (r"^# command: ", "measurement command header")


def load_samples(
    scenario: dict[str, Any],
    scenario_dir: Path,
    reps: int,
    expected_pattern: str,
    expected_label: str,
) -> list[dict[str, Any]]:
    import re

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
        log_lines = log_path.read_text(encoding="utf-8", errors="replace").splitlines()
        if not any(pattern.search(line) for line in log_lines):
            raise RuntimeError(
                f"repetition {sample_path.name} for {scenario_dir.name} does not show the "
                f"expected {expected_label}"
            )
        # Only the xmllint parse-style scenarios must be free of parser/validity
        # diagnostics: the upstream drivers deliberately contain negative tests
        # that print expected "parser error" lines, and --sax writes events only.
        if scenario["task"] in {"parse", "dtd_validate", "repeat", "xpath"}:
            for line in log_lines:
                lowered = line.lower()
                if "parser error" in lowered or "validity error" in lowered or "i/o error" in lowered:
                    raise RuntimeError(
                        f"repetition {sample_path.name} for {scenario_dir.name} reported a "
                        f"parser/validation error: {line.strip()[:160]}"
                    )
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
        "workload": scenario.get("workload", ""),
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
        reps = int(os.environ.get("LIBXML2_REPS", "5"))
        jobs = int(os.environ.get("LIBXML2_JOBS", "4"))
        repeat_iterations = int(os.environ.get("LIBXML2_REPEAT_ITERATIONS", "100"))
        runtest_total = int(os.environ.get("LIBXML2_RUNTEST_TOTAL", "3886"))
        runsuite_total = int(os.environ.get("LIBXML2_RUNSUITE_TOTAL", "1471"))
        item_total = int(os.environ.get("LIBXML2_XPATH_ITEM_TOTAL", "100000"))
    except ValueError:
        fail("LIBXML2_REPS/Jobs/counters must be integers")
        return 1
    if reps < 1 or jobs < 1:
        fail("LIBXML2_REPS and LIBXML2_JOBS must be positive")
        return 1
    manifest_path = Path(os.environ.get("LIBXML2_CORPUS_MANIFEST", ""))
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
            pattern, label = expected_log_pattern(scenario, item_total, runtest_total, runsuite_total)
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
                if scenario["task"] == "repeat":
                    byte_count *= repeat_iterations
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
            elif scenario["task"] == "upstream_suite":
                total = runtest_total if scenario["driver"] == "runtest" else runsuite_total
                rate_values = [total / sample["wall_seconds"] for sample in samples]
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
    except RuntimeError as exc:
        fail(str(exc))
        return 1

    normalized: dict[str, Any] = {
        "benchmark": "libxml2_parse_validation_matrix",
        "software": "libxml2",
        "version": version,
        "architecture": architecture,
        "variant": variant,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "variant": variant,
            "repetitions": reps,
            "warmups": 1,
            "offline": True,
            "parse_network": "disabled (xmllint --nonet, no external DTD/entities)",
            "build_parallel_jobs": jobs,
            "build_system": "autotools (in-tree ./configure + make)",
            "compile_flags": "-O2",
            "configure_flags": (
                "--disable-shared --enable-static --without-python --without-zlib "
                "--without-iconv --without-icu --disable-dependency-tracking"
            ),
            "source_name": os.environ.get("LIBXML2_SOURCE_NAME", ""),
            "source_sha256": os.environ.get("LIBXML2_SOURCE_SHA256", ""),
            "source_url": os.environ.get("LIBXML2_SOURCE_URL", ""),
            "libxml2_version_string": os.environ.get("LIBXML2_VERSION_STRING", ""),
            "repeat_iterations": repeat_iterations,
            "runtest_total": runtest_total,
            "runsuite_total": runsuite_total,
            "xpath_item_total": item_total,
            "corpora": {name: int(entry["bytes"]) for name, entry in sorted(manifest.items())},
            "scenarios": [scenario["scenario"] for scenario in SCENARIOS],
        },
        "metric_contract": {
            "wall_time": {"unit": "s", "direction": "lower_is_better"},
            "peak_rss": {"unit": "MiB", "direction": "lower_is_better"},
            "parse_throughput": {"unit": "MiB/s", "direction": "higher_is_better"},
            "test_rate": {"unit": "tests/s", "direction": "higher_is_better"},
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
        f"[libxml2-parse] normalized {len(results)} metrics across "
        f"{len(SCENARIOS)} scenarios"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
