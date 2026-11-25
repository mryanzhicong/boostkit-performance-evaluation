#!/usr/bin/env python3
"""Strictly parse simdjson raw outputs into benchmark_simdjson.json.

Inputs (all produced by scripts/stages/test.sh):
  runs/dom_parse/rep<i>.log                 DOM `parse -t` tab separated rows
  runs/dom_parse_stream/rep<i>.log          DOM `parse_stream` batch table
  runs/<suite>/rep<i>.benchmark.json        Google Benchmark JSON for the suite
  runs/<suite>/rep<i>.log                   console output of the same run

The parser never re-measures and never fills gaps: a missing round, a duplicate
row, an unexpected row set or a non-positive number aborts the run.
"""

from __future__ import annotations

import argparse
import json
import math
import re
import statistics
import sys
from pathlib import Path

DOM_ROW = re.compile(r'^"(?P<name>[^"]+)"(?P<rest>.*)$')
NUMBER = re.compile(r"[+-]?(?:\d+\.\d*|\.\d+|\d+)(?:[eE][+-]?\d+)?")
BEST_SPEED = re.compile(r"Best speed:\s*([0-9]+(?:\.[0-9]+)?)")
OPTIMAL_BATCH = re.compile(r"Seemingly optimal batch_size:\s*([0-9]+)")
RUN_SUFFIX = re.compile(r"/(?:repeats:\d+|manual_time)$")

SUITES = ("bench_parse_call", "bench_dom_api", "bench_ondemand")
EXPECTED_METRIC_COUNT = 66
GB_UNIT = "GB/s"
NS_UNIT = "ns"
HIGHER = "higher_is_better"
LOWER = "lower_is_better"


def fail(message: str) -> None:
    raise SystemExit(f"ERROR: {message}")


def load_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except OSError as error:
        fail(f"cannot read {path}: {error}")
    except json.JSONDecodeError as error:
        fail(f"invalid JSON in {path}: {error}")


def load_fixtures(path: Path) -> dict:
    data = load_json(path)
    for key in ("dom_parse", "dom_parse_stream", "suites"):
        if key not in data:
            fail(f"{path}: missing key {key}")
    for suite in SUITES:
        rows = data["suites"].get(suite)
        if not isinstance(rows, list) or not rows:
            fail(f"{path}: suite {suite} has no expected benchmark rows")
        if len(set(rows)) != len(rows):
            fail(f"{path}: suite {suite} lists duplicate rows")
    return data


def normalize(name: str) -> str:
    return re.sub(r"_+", "_", re.sub(r"[^0-9A-Za-z]+", "_", name)).strip("_")


def stem(name: str) -> str:
    return Path(name).stem


def metric_meta(name: str) -> tuple[str, str, str]:
    if name.startswith("dom_parse_stream_"):
        return GB_UNIT, HIGHER, "dom_parse_stream"
    if name.startswith("dom_parse_"):
        return GB_UNIT, HIGHER, "dom_parse"
    for suite in SUITES:
        if name.startswith(f"{suite}_"):
            return NS_UNIT, LOWER, suite
    fail(f"no metric metadata rule for {name}")


def checked_value(where: str, value: float) -> float:
    if not isinstance(value, (int, float)) or not math.isfinite(value) or value <= 0:
        fail(f"{where}: expected a finite positive number, got {value!r}")
    return float(value)


def read_dom_output(path: Path) -> str:
    """DOM tools print the data rows on stdout and progress on stderr."""
    return path.read_text(encoding="utf-8", errors="replace").replace("\r", "\n")


def read_stream_output(path: Path) -> str:
    """parse_stream prints the batch table on stdout and the summary on stderr."""
    parts = [read_dom_output(path)]
    err = path.with_suffix(".err")
    if err.is_file():
        parts.append(read_dom_output(err))
    return "\n".join(parts)


def parse_dom_parse_output(path: Path, files: list[str]) -> dict[str, float]:
    text = read_dom_output(path)
    rows: dict[str, tuple[float, float]] = {}
    for line in text.splitlines():
        match = DOM_ROW.match(line.strip())
        if not match:
            continue
        name = match.group("name")
        numbers = [float(item) for item in NUMBER.findall(match.group("rest"))]
        if len(numbers) < 3:
            fail(f"{path}: row {name} has {len(numbers)} numeric columns, expected at least 3 GB/s columns")
        overall, stage1 = numbers[-3], numbers[-2]
        if name in rows:
            fail(f"{path}: duplicate row for {name}")
        rows[name] = (checked_value(f"{path}:{name} overall", overall),
                      checked_value(f"{path}:{name} stage1", stage1))
    expected = [stem(name) for name in files]
    if sorted(rows) != sorted(expected):
        fail(f"{path}: parsed rows {sorted(rows)} differ from expected {sorted(expected)}")
    metrics: dict[str, float] = {}
    for name in expected:
        metrics[f"dom_parse_{normalize(name)}_gb_per_s"] = rows[name][0]
        metrics[f"dom_parse_{normalize(name)}_stage1_gb_per_s"] = rows[name][1]
    return metrics


def parse_dom_parse_stream(path: Path) -> tuple[float, int | None]:
    text = read_stream_output(path)
    speeds = BEST_SPEED.findall(text)
    if len(speeds) != 1:
        fail(f"{path}: expected exactly one 'Best speed' line, found {len(speeds)}")
    value = checked_value(f"{path}:best speed", float(speeds[0]))
    batches = OPTIMAL_BATCH.findall(text)
    batch = int(batches[-1]) if batches else None
    if batch is not None and batch <= 0:
        fail(f"{path}: non-positive optimal batch size {batch}")
    return value, batch


def parse_google_suite(path: Path, suite: str, expected_rows: list[str]) -> dict[str, float]:
    data = load_json(path)
    rows = data.get("benchmarks")
    if not isinstance(rows, list) or not rows:
        fail(f"{path}: no 'benchmarks' array")
    grouped: dict[str, list[dict]] = {}
    for row in rows:
        if not isinstance(row, dict):
            fail(f"{path}: benchmark entry is not an object")
        if row.get("error_occurred"):
            fail(f"{path}: {row.get('name')} reported an error: {row.get('error_message')}")
        run_name = row.get("run_name") or row.get("name")
        if not run_name:
            fail(f"{path}: benchmark entry without a run name")
        base = RUN_SUFFIX.sub("", str(run_name))
        grouped.setdefault(base, []).append(row)
    missing = sorted(set(expected_rows) - set(grouped))
    unexpected = sorted(set(grouped) - set(expected_rows))
    if missing or unexpected:
        fail(f"{path}: benchmark rows differ from fixtures (missing={missing}, unexpected={unexpected})")
    values: dict[str, float] = {}
    for base in expected_rows:
        group = grouped[base]
        medians = [row for row in group
                   if row.get("run_type") == "aggregate" and row.get("aggregate_name") == "median"]
        if medians:
            if len(medians) != 1:
                fail(f"{path}: {base} has {len(medians)} median aggregates")
            value = checked_value(f"{path}:{base} median", float(medians[0]["cpu_time"]))
        else:
            times = [float(row["cpu_time"]) for row in group if row.get("run_type") != "aggregate"]
            if not times:
                fail(f"{path}: {base} has neither a median aggregate nor iteration rows")
            value = checked_value(f"{path}:{base} iterations", statistics.median(times))
        values[f"{suite}_{normalize(base)}_ns"] = value
    return values


def expected_metric_names(fixtures: dict) -> list[str]:
    names: list[str] = []
    for file_name in fixtures["dom_parse"]["files"]:
        names.append(f"dom_parse_{normalize(stem(file_name))}_gb_per_s")
        names.append(f"dom_parse_{normalize(stem(file_name))}_stage1_gb_per_s")
    for file_name in fixtures["dom_parse_stream"]["files"]:
        names.append(f"dom_parse_stream_{normalize(stem(file_name))}_gb_per_s")
    for suite in SUITES:
        for row in fixtures["suites"][suite]:
            names.append(f"{suite}_{normalize(row)}_ns")
    if len(names) != EXPECTED_METRIC_COUNT:
        fail(f"fixtures describe {len(names)} metrics, the case contract fixes {EXPECTED_METRIC_COUNT}")
    if len(set(names)) != len(names):
        fail("fixtures produce duplicate metric names")
    return names


def collect_reps(run_root: Path, total: int) -> None:
    for scenario in ("dom_parse", "dom_parse_stream", *SUITES):
        directory = run_root / scenario
        if not directory.is_dir():
            fail(f"missing sample directory: {directory}")
        found = {int(match.group(1)) for match in
                 (re.fullmatch(r"rep(\d+)\.log", item.name) for item in directory.iterdir())
                 if match}
        expected = set(range(total))
        if found != expected:
            fail(f"{directory}: sample rounds {sorted(found)} differ from expected {sorted(expected)}")
        if scenario in SUITES:
            json_rounds = {int(match.group(1)) for match in
                           (re.fullmatch(r"rep(\d+)\.benchmark\.json", item.name) for item in directory.iterdir())
                           if match}
            if json_rounds != expected:
                fail(f"{directory}: Google Benchmark JSON rounds {sorted(json_rounds)} differ from expected {sorted(expected)}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Strictly parse simdjson benchmark outputs")
    parser.add_argument("--runs-dir", type=Path, required=True)
    parser.add_argument("--results-dir", type=Path, required=True)
    parser.add_argument("--fixtures", type=Path, required=True)
    parser.add_argument("--warmups", type=int, required=True)
    parser.add_argument("--reps", type=int, required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--architecture", required=True)
    parser.add_argument("--bench-min-time", default="")
    parser.add_argument("--variant", default="base")
    parser.add_argument("--run-id", default="")
    args = parser.parse_args()
    if args.reps < 1:
        fail("--reps must be positive")
    if args.warmups < 0:
        fail("--warmups must not be negative")
    fixtures = load_fixtures(args.fixtures)
    args.results_dir.mkdir(parents=True, exist_ok=True)
    expected_names = expected_metric_names(fixtures)
    total = args.warmups + args.reps
    collect_reps(args.runs_dir, total)

    per_rep: dict[int, dict[str, float]] = {}
    evidence: dict[int, int | None] = {}
    for index in range(total):
        metrics: dict[str, float] = {}
        metrics.update(parse_dom_parse_output(args.runs_dir / "dom_parse" / f"rep{index}.log",
                                              fixtures["dom_parse"]["files"]))
        stream_value, batch = parse_dom_parse_stream(
            args.runs_dir / "dom_parse_stream" / f"rep{index}.log")
        for file_name in fixtures["dom_parse_stream"]["files"]:
            metrics[f"dom_parse_stream_{normalize(stem(file_name))}_gb_per_s"] = stream_value
        evidence[index] = batch
        for suite in SUITES:
            metrics.update(parse_google_suite(
                args.runs_dir / suite / f"rep{index}.benchmark.json",
                suite, fixtures["suites"][suite]))
        missing = sorted(set(expected_names) - set(metrics))
        extra = sorted(set(metrics) - set(expected_names))
        if missing or extra:
            fail(f"round {index} produced unexpected metrics (missing={missing}, extra={extra})")
        per_rep[index] = metrics

    measured = [index for index in range(total) if index >= args.warmups]
    if len(measured) != args.reps:
        fail("measured round count differs from --reps")
    results: dict[str, dict] = {}
    samples: dict[str, dict] = {}
    for name in expected_names:
        values = [per_rep[index][name] for index in measured]
        unit, direction, group = metric_meta(name)
        median = statistics.median(values)
        results[name] = {"value": round(median, 6), "unit": unit, "direction": direction, "group": group}
        samples[name] = {
            "values": [round(value, 6) for value in values],
            "median": round(median, 6),
            "min": round(min(values), 6),
            "max": round(max(values), 6),
            "samples": len(values),
        }
    if len(results) != EXPECTED_METRIC_COUNT:
        fail(f"produced {len(results)} metrics, expected {EXPECTED_METRIC_COUNT}")

    for index, metrics in per_rep.items():
        for scenario in ("dom_parse", "dom_parse_stream", *SUITES):
            selected = {name: round(value, 6) for name, value in metrics.items()
                        if metric_meta(name)[2] == scenario}
            payload = {
                "scenario": scenario,
                "round": index,
                "warmup": index < args.warmups,
                "metrics": selected,
            }
            (args.runs_dir / scenario / f"rep{index}.json").write_text(
                json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    google_raw = {"suites": {}}
    for suite in SUITES:
        google_raw["suites"][suite] = {
            f"rep{index}": load_json(args.runs_dir / suite / f"rep{index}.benchmark.json")
            for index in sorted(per_rep)
        }
    (args.results_dir / "benchmark_google.json").write_text(
        json.dumps(google_raw, ensure_ascii=False) + "\n", encoding="utf-8")

    output = {
        "software": "simdjson",
        "version": args.version,
        "architecture": args.architecture,
        "variant": args.variant,
        "run_id": args.run_id,
        "parameters": {
            "parse_iterations": fixtures["dom_parse"]["iterations"],
            "benchmark_min_time": args.bench_min_time,
            "warmups": args.warmups,
            "reps": args.reps,
        },
        "sampling": {
            "warmups": args.warmups,
            "reps": args.reps,
            "aggregation": "median",
            "samples_per_metric": len(measured),
            "metric_count": len(results),
        },
        "results": results,
        "samples": samples,
        "evidence": {
            "dom_parse_stream_optimal_batch_size": {
                f"rep{index}": value for index, value in evidence.items()
            }
        },
    }
    (args.results_dir / "benchmark_simdjson.json").write_text(
        json.dumps(output, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    groups: dict[str, int] = {}
    for item in results.values():
        groups[item["group"]] = groups.get(item["group"], 0) + 1
    print(f"parsed {len(results)} metrics from {len(measured)} measured round(s): "
          + ", ".join(f"{name}={count}" for name, count in sorted(groups.items())), file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
