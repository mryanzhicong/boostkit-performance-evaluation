#!/usr/bin/env python3
"""Normalize the pinned fbthrift ProtocolBench matrix.

Inputs are the raw per-repetition Google Benchmark JSON files, their stdout
logs and GNU time records produced by scripts/stages/test.sh.  Validation is
strict on purpose: a missing repetition, an unexpected benchmark case, a
non-finite timing or a missing RSS record fails the test stage instead of
producing a zero-filled metric.
"""

from __future__ import annotations

import argparse
import json
import math
import re
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path

TIME_TO_NS = {"ns": 1.0, "us": 1_000.0, "ms": 1_000_000.0, "s": 1_000_000_000.0}
RSS_PATTERN = re.compile(r"Maximum resident set size \(kbytes\):\s*(\d+)")
SCENARIO_PATTERN = re.compile(r"^[a-z][a-z0-9_]*$")
BENCHMARK_PATTERN = re.compile(r"^(Binary|Compact)Protocol_(write|read)_([A-Za-z0-9]+)$")

MIN_SCENARIOS = 6
MAX_SCENARIOS = 10
TARGET_REPETITIONS = 5

# Which ProtocolBench data shapes each upstream case covers.  ComplexStruct
# nests Empty/SmallInt/BigInt/SmallString/BigString/Mixed/lists/maps/union-free
# aggregates, so it is the aggregate coverage for scalar and container fields.
CASE_SHAPES = {
    "ComplexStruct": {"int", "string", "list", "map", "nested"},
    "BigBinary": {"binary"},
    "LargeMapInt": {"map"},
}
REQUIRED_SHAPES = {"int", "string", "binary", "list", "map", "nested"}


class ParseError(ValueError):
    """Raised when raw benchmark evidence violates the result contract."""


def load_json(path: Path) -> dict:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except OSError as exc:
        raise ParseError(f"cannot read {path}: {exc}") from exc
    except json.JSONDecodeError as exc:
        raise ParseError(f"{path} is not valid JSON: {exc}") from exc
    if not isinstance(payload, dict):
        raise ParseError(f"{path} must contain a JSON object")
    return payload


def read_scenarios(path: Path) -> list[tuple[str, str, str, str]]:
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except OSError as exc:
        raise ParseError(f"cannot read scenario matrix {path}: {exc}") from exc
    rows: list[tuple[str, str, str, str]] = []
    seen: set[str] = set()
    benchmarks: set[str] = set()
    for number, line in enumerate(lines, 1):
        if not line.strip():
            continue
        parts = line.split("\t")
        if len(parts) != 4:
            raise ParseError(
                f"{path}:{number}: expected 4 tab-separated columns, found {len(parts)}"
            )
        scenario, group, benchmark, filter_expression = (value.strip() for value in parts)
        if not SCENARIO_PATTERN.fullmatch(scenario):
            raise ParseError(f"{path}:{number}: invalid scenario id {scenario!r}")
        if not group:
            raise ParseError(f"{path}:{number}: scenario group must not be empty")
        match = BENCHMARK_PATTERN.fullmatch(benchmark)
        if not match:
            raise ParseError(
                f"{path}:{number}: unexpected ProtocolBench case {benchmark!r}"
            )
        expected_filter = f"^{benchmark}$"
        if filter_expression != expected_filter:
            raise ParseError(
                f"{path}:{number}: filter must be the anchored case name {expected_filter}"
            )
        if scenario in seen:
            raise ParseError(f"{path}:{number}: duplicate scenario {scenario}")
        if benchmark in benchmarks:
            raise ParseError(f"{path}:{number}: duplicate benchmark {benchmark}")
        seen.add(scenario)
        benchmarks.add(benchmark)
        rows.append((scenario, group, benchmark, filter_expression))
    if not MIN_SCENARIOS <= len(rows) <= MAX_SCENARIOS:
        raise ParseError(
            f"{path}: scenario matrix must declare {MIN_SCENARIOS}..{MAX_SCENARIOS} "
            f"scenarios, found {len(rows)}"
        )
    protocols = {BENCHMARK_PATTERN.fullmatch(row[2]).group(1) for row in rows}
    directions = {BENCHMARK_PATTERN.fullmatch(row[2]).group(2) for row in rows}
    if protocols != {"Binary", "Compact"}:
        raise ParseError(f"scenario matrix must cover Binary and Compact, found {sorted(protocols)}")
    if directions != {"write", "read"}:
        raise ParseError(f"scenario matrix must cover read and write, found {sorted(directions)}")
    covered_shapes: set[str] = set()
    for row in rows:
        case_shape = BENCHMARK_PATTERN.fullmatch(row[2]).group(3)
        if case_shape not in CASE_SHAPES:
            raise ParseError(f"case {case_shape} has no declared data shape coverage")
        covered_shapes |= CASE_SHAPES[case_shape]
    missing_shapes = REQUIRED_SHAPES - covered_shapes
    if missing_shapes:
        raise ParseError(
            "scenario matrix does not cover required data shapes: "
            + ", ".join(sorted(missing_shapes))
        )
    return rows


def load_dependencies(path: Path, actual_version: str) -> dict:
    payload = load_json(path)
    if payload.get("software") != "fbthrift":
        raise ParseError(f"{path}: dependencies.json has an invalid software identity")
    if payload.get("version") != actual_version:
        raise ParseError(
            f"{path}: dependency version {payload.get('version')!r} differs from "
            f"built version {actual_version!r}"
        )
    tag = payload.get("source_tag")
    if not isinstance(tag, str) or tag != f"v{actual_version}":
        raise ParseError(f"{path}: source tag {tag!r} does not match version {actual_version}")
    commit = payload.get("source_commit")
    if not isinstance(commit, str) or not re.fullmatch(r"[0-9a-f]{40}", commit):
        raise ParseError(f"{path}: source commit is not a 40-character SHA-1")
    dependencies = payload.get("dependencies")
    if not isinstance(dependencies, list) or len(dependencies) < 5:
        raise ParseError(f"{path}: expected the pinned dependency records")
    for dependency in dependencies:
        if not isinstance(dependency, dict):
            raise ParseError(f"{path}: dependency records must be objects")
        for field in ("name", "source", "sha256"):
            if not isinstance(dependency.get(field), str) or not dependency[field]:
                raise ParseError(f"{path}: dependency record is missing {field}")
        if not re.fullmatch(r"[0-9a-f]{64}", dependency["sha256"]):
            raise ParseError(
                f"{path}: dependency {dependency['name']} has an invalid SHA-256"
            )
    return payload


def parse_benchmark_json(path: Path, benchmark: str) -> float:
    payload = load_json(path)
    rows = payload.get("benchmarks")
    if not isinstance(rows, list) or not rows:
        raise ParseError(f"{path}: Google Benchmark JSON contains no benchmarks")
    iterations = [
        row
        for row in rows
        if isinstance(row, dict) and row.get("run_type", "iteration") == "iteration"
    ]
    if len(iterations) != 1:
        raise ParseError(
            f"{path}: expected exactly 1 measured iteration row, found {len(iterations)}"
        )
    row = iterations[0]
    name = row.get("name") or row.get("run_name")
    if name != benchmark:
        raise ParseError(f"{path}: benchmark name {name!r} differs from {benchmark!r}")
    if row.get("error_occurred"):
        raise ParseError(
            f"{path}: benchmark reported an error: {row.get('error_message')}"
        )
    unit = row.get("time_unit")
    if unit not in TIME_TO_NS:
        raise ParseError(f"{path}: unsupported time unit {unit!r}")
    value = row.get("cpu_time")
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise ParseError(f"{path}: cpu_time is missing or not numeric")
    nanoseconds = float(value) * TIME_TO_NS[unit]
    if not math.isfinite(nanoseconds) or nanoseconds <= 0:
        raise ParseError(f"{path}: cpu_time is not a positive finite number: {value!r}")
    iterations_count = row.get("iterations")
    if isinstance(iterations_count, bool) or not isinstance(iterations_count, int) or iterations_count <= 0:
        raise ParseError(f"{path}: iteration count is missing or invalid")
    return nanoseconds


def parse_peak_rss_mib(path: Path) -> float:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        raise ParseError(f"cannot read GNU time record {path}: {exc}") from exc
    match = RSS_PATTERN.search(text)
    if not match:
        raise ParseError(f"{path}: no 'Maximum resident set size' record")
    kibibytes = int(match.group(1))
    if kibibytes <= 0:
        raise ParseError(f"{path}: peak RSS is not positive: {kibibytes}")
    return kibibytes / 1024.0


def summarize(values: list[float]) -> dict[str, float]:
    if not values:
        raise ParseError("cannot summarize an empty sample list")
    if not all(math.isfinite(value) for value in values):
        raise ParseError("sample list contains a non-finite value")
    return {
        "median": statistics.median(values),
        "min": min(values),
        "max": max(values),
        "mean": statistics.fmean(values),
        "stdev": statistics.stdev(values) if len(values) > 1 else 0.0,
        "sample_count": len(values),
    }


def build_metric(
    name: str,
    group: str,
    value: float,
    unit: str,
    direction: str,
    benchmark: str,
    samples: list[float],
) -> dict:
    if not math.isfinite(value):
        raise ParseError(f"metric {name} is not finite")
    return {
        "name": name,
        "group": group,
        "value": value,
        "unit": unit,
        "direction": direction,
        "benchmark_case": benchmark,
        "samples": samples,
        "statistics": summarize(samples),
    }


def normalize(args: argparse.Namespace) -> dict:
    scenarios = read_scenarios(args.cases_file)
    if args.reps < 1:
        raise ParseError("at least one measured repetition is required")
    if args.warmups < 1:
        raise ParseError("at least one warmup run per scenario is required")
    dependencies = load_dependencies(args.dependencies, args.actual_version)

    results: dict[str, dict] = {}
    matrix: list[dict] = []
    for scenario, group, benchmark, _filter in scenarios:
        run_dir = args.runs_dir / scenario
        if not run_dir.is_dir():
            raise ParseError(f"missing raw run directory for scenario {scenario}: {run_dir}")
        for warmup in range(1, args.warmups + 1):
            for suffix in (".json", ".log", ".time"):
                path = run_dir / f"warmup{warmup}{suffix}"
                if not path.is_file() or path.stat().st_size == 0:
                    raise ParseError(f"missing warmup evidence: {path}")
            parse_benchmark_json(run_dir / f"warmup{warmup}.json", benchmark)
        ns_samples: list[float] = []
        rss_samples: list[float] = []
        for repetition in range(1, args.reps + 1):
            json_path = run_dir / f"rep{repetition}.json"
            log_path = run_dir / f"rep{repetition}.log"
            time_path = run_dir / f"rep{repetition}.time"
            for path in (json_path, log_path, time_path):
                if not path.is_file() or path.stat().st_size == 0:
                    raise ParseError(f"missing measurement evidence: {path}")
            ns_samples.append(parse_benchmark_json(json_path, benchmark))
            rss_samples.append(parse_peak_rss_mib(time_path))

        ns_statistics = summarize(ns_samples)
        ns_median = ns_statistics["median"]
        objects_per_second = [1_000_000_000.0 / value for value in ns_samples]
        results[f"{scenario}__ns_per_op"] = build_metric(
            f"{scenario}__ns_per_op", group, ns_median, "ns/op", "lower_is_better",
            benchmark, ns_samples,
        )
        results[f"{scenario}__objects_per_second"] = build_metric(
            f"{scenario}__objects_per_second", group,
            summarize(objects_per_second)["median"], "objects/s",
            "higher_is_better", benchmark, objects_per_second,
        )
        results[f"{scenario}__peak_rss_mb"] = build_metric(
            f"{scenario}__peak_rss_mb", group, summarize(rss_samples)["median"],
            "MiB", "lower_is_better", benchmark, rss_samples,
        )
        # Only the declared scenario identity belongs to "parameters"; the
        # measured values already live in "results" and would otherwise make
        # the resolved parameters differ between architectures.
        matrix.append(
            {
                "scenario": scenario,
                "group": group,
                "benchmark_case": benchmark,
            }
        )

    return {
        "software": "fbthrift",
        "category": "Acceleration",
        "version": args.actual_version,
        "architecture": args.architecture,
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "source": "thrift/lib/cpp2/test/ProtocolBench.cpp",
        "source_tag": dependencies["source_tag"],
        "source_commit": dependencies["source_commit"],
        "dependencies": dependencies["dependencies"],
        "parameters": {
            "benchmark_target": "ProtocolBench (Google Benchmark)",
            "scenario_count": len(scenarios),
            "scenarios": [row[0] for row in scenarios],
            "matrix": matrix,
            "warmup_runs_per_scenario": args.warmups,
            "measured_repetitions": args.reps,
            "repetition_target": TARGET_REPETITIONS,
            "repetition_target_met": args.reps >= TARGET_REPETITIONS,
            "benchmark_min_time": args.benchmark_min_time,
            "warmup_min_time": args.warmup_min_time,
            "serialized_bytes_per_object": None,
            "serialized_bytes_unavailable_reason": (
                "upstream ProtocolBench does not report bytes processed and was "
                "not patched, so serialized size is not derived"
            ),
        },
        "results": results,
    }


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runs-dir", required=True, type=Path)
    parser.add_argument("--cases-file", required=True, type=Path)
    parser.add_argument("--dependencies", required=True, type=Path)
    parser.add_argument("--reps", required=True, type=int)
    parser.add_argument("--warmups", required=True, type=int)
    parser.add_argument("--benchmark-min-time", required=True)
    parser.add_argument("--warmup-min-time", required=True)
    parser.add_argument("--actual-version", required=True)
    parser.add_argument("--architecture", required=True)
    parser.add_argument("--output", required=True, type=Path)
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    try:
        payload = normalize(args)
    except (ParseError, OSError, ValueError) as exc:
        print(f"[fbthrift-parse] ERROR: {exc}", file=sys.stderr)
        return 1
    args.output.parent.mkdir(parents=True, exist_ok=True)
    temporary = args.output.with_name(f".{args.output.name}.tmp")
    temporary.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
                         encoding="utf-8")
    temporary.replace(args.output)
    print(
        f"[fbthrift-parse] normalized {len(payload['results'])} metrics from "
        f"{len(payload['parameters']['scenarios'])} scenarios "
        f"({args.reps} repetitions, {args.warmups} warmup runs)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
