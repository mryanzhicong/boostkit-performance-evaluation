#!/usr/bin/env python3
"""Validate and normalise the R workload samples.

The manifest is a pipe separated file with the columns

    scenario|dimension|runner|target|scale|check|expected|tolerance|workload

Every scenario directory must contain ``warmup.log`` and ``rep<i>.{log,json}``
for ``i`` in ``1..BENCH_REPS``.  The JSON files are written by
``scripts/run_timed.py``; the logs must contain exactly one
``RESULT scenario=<name> checksum=<value>`` line produced by the workload.
Any missing sample, non-zero exit code, timeout, non-positive wall/RSS value or
checksum mismatch aborts the normalisation with a non-zero status: no sample is
dropped and no missing value is interpolated.
"""

from __future__ import annotations

import json
import math
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

SOFTWARE = "r"
TAG = "r"
RESULT_PATTERN = re.compile(r"RESULT\s+scenario=(?P<scenario>[A-Za-z0-9_.-]+)\s+.*?checksum=(?P<checksum>[^\s]+)")


def fail(message: str) -> None:
    print(f"[{TAG}-parse] ERROR: {message}", flush=True)
    raise SystemExit(1)


def load_manifest(path: Path) -> list[dict[str, str]]:
    entries: list[dict[str, str]] = []
    keys = ["scenario", "dimension", "runner", "target", "scale", "check", "expected", "tolerance", "workload"]
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except OSError as exc:
        fail(f"cannot read the workload matrix manifest {path}: {exc}")
    for number, line in enumerate(lines, start=1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if number == 1 and stripped.startswith(keys[0] + "|"):
            continue
        fields = [field.strip() for field in stripped.split("|")]
        if len(fields) != len(keys):
            fail(f"manifest line {number} has {len(fields)} fields, expected {len(keys)}")
        entry = dict(zip(keys, fields))
        if not entry["scenario"]:
            fail(f"manifest line {number} has an empty scenario name")
        entries.append(entry)
    if not entries:
        fail("workload matrix manifest contains no scenarios")
    names = [entry["scenario"] for entry in entries]
    if len(names) != len(set(names)):
        fail("workload matrix manifest contains duplicate scenario names")
    return entries


def read_json(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"cannot read sample metadata {path}: {exc}")
    if not isinstance(payload, dict):
        fail(f"sample metadata {path} is not a JSON object")
    return payload


def validate_checksum(entry: dict[str, str], checksum: str, scenario: str) -> float | int:
    kind = entry["check"].strip().lower()
    expected = entry["expected"].strip()
    if kind == "marker":
        if expected and expected not in checksum:
            fail(f"scenario {scenario} output does not contain the expected marker {expected!r}")
        return 0
    if kind == "int":
        try:
            actual_int = int(checksum)
            expected_int = int(expected)
        except ValueError:
            fail(f"scenario {scenario} requires integer checksums, got {checksum!r} and {expected!r}")
        if actual_int != expected_int:
            fail(f"scenario {scenario} checksum {actual_int} differs from the committed value {expected_int}")
        return actual_int
    if kind == "float":
        try:
            actual_float = float(checksum)
            expected_float = float(expected)
        except ValueError:
            fail(f"scenario {scenario} requires float checksums, got {checksum!r} and {expected!r}")
        tolerance = float(entry["tolerance"]) if entry["tolerance"] else 1e-9
        if not math.isfinite(actual_float) or not math.isfinite(expected_float) or expected_float == 0:
            fail(f"scenario {scenario} has a non-finite or zero float checksum")
        relative = abs(actual_float - expected_float) / abs(expected_float)
        if relative > tolerance:
            fail(
                f"scenario {scenario} checksum {actual_float!r} differs from the committed value "
                f"{expected_float!r} beyond the {tolerance:g} relative tolerance"
            )
        return actual_float
    fail(f"scenario {scenario} uses an unsupported check type: {entry['check']!r}")


def load_label(runs_dir: Path, scenario: str, label: str, entry: dict[str, str]) -> dict[str, Any]:
    log_path = runs_dir / scenario / f"{label}.log"
    json_path = runs_dir / scenario / f"{label}.json"
    if not log_path.is_file():
        fail(f"missing sample log: {log_path}")
    if not json_path.is_file():
        fail(f"missing sample metadata: {json_path}")
    payload = read_json(json_path)
    if payload.get("exit_code") != 0:
        fail(f"{log_path} exited with code {payload.get('exit_code')!r}")
    if payload.get("timed_out") is not False:
        fail(f"{log_path} timed out")
    wall = payload.get("wall_seconds")
    rss = payload.get("max_rss_mib")
    for name, value in (("wall_seconds", wall), ("max_rss_mib", rss)):
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            fail(f"{json_path} has a non-numeric {name}")
        if not math.isfinite(float(value)) or float(value) <= 0:
            fail(f"{json_path} has a non-positive {name}: {value!r}")
    text = log_path.read_text(encoding="utf-8", errors="replace")
    matches = RESULT_PATTERN.findall(text)
    if len(matches) != 1:
        fail(f"scenario {scenario} produced {len(matches)} RESULT lines in {log_path.name}, expected exactly one")
    reported_scenario, checksum = matches[0]
    if reported_scenario != scenario:
        fail(f"scenario {scenario} logged a RESULT for a different scenario: {reported_scenario}")
    checksum_value = validate_checksum(entry, checksum, scenario)
    return {
        "wall_seconds": round(float(wall), 6),
        "max_rss_mib": round(float(rss), 3),
        "checksum": checksum_value,
        "log": log_path.name,
    }


def statistics(samples: list[float]) -> dict[str, float]:
    ordered = sorted(samples)
    count = len(ordered)
    mean = sum(ordered) / count
    if count % 2 == 1:
        median = ordered[count // 2]
    else:
        median = (ordered[count // 2 - 1] + ordered[count // 2]) / 2.0
    variance = sum((value - mean) ** 2 for value in ordered) / (count - 1) if count > 1 else 0.0
    return {
        "median": round(median, 6),
        "min": round(ordered[0], 6),
        "max": round(ordered[-1], 6),
        "mean": round(mean, 6),
        "stdev": round(math.sqrt(variance), 6),
    }


def main() -> int:
    if len(sys.argv) != 4:
        print(f"usage: {sys.argv[0]} RUNS_DIR OUTPUT_JSON MANIFEST", file=sys.stderr)
        return 2
    runs_dir = Path(sys.argv[1])
    output_path = Path(sys.argv[2])
    manifest_path = Path(sys.argv[3])
    reps = int(os.environ.get("BENCH_REPS", "5"))
    if reps < 1:
        fail(f"BENCH_REPS must be at least 1, got {reps}")
    entries = load_manifest(manifest_path)
    if not runs_dir.is_dir():
        fail(f"runs directory is missing: {runs_dir}")

    expected_dirs = {entry["scenario"] for entry in entries}
    actual_dirs = {path.name for path in runs_dir.iterdir() if path.is_dir()}
    unexpected = sorted(actual_dirs - expected_dirs)
    if unexpected:
        fail(f"runs directory contains scenarios that are not in the matrix: {', '.join(unexpected)}")

    scenarios: list[str] = []
    results: dict[str, Any] = {}
    matrix_meta: list[dict[str, Any]] = []
    for entry in entries:
        scenario = entry["scenario"]
        scenarios.append(scenario)
        repetitions = [load_label(runs_dir, scenario, f"rep{index}", entry) for index in range(1, reps + 1)]
        warmup = load_label(runs_dir, scenario, "warmup", entry)
        wall_samples = [sample["wall_seconds"] for sample in repetitions]
        rss_samples = [sample["max_rss_mib"] for sample in repetitions]
        results[scenario] = {
            "source_name": scenario,
            "scenario": scenario,
            "dimension": entry["dimension"],
            "runner": entry["runner"],
            "scale": entry["scale"] or None,
            "unit": "s",
            "direction": "lower_is_better",
            "value": statistics(wall_samples)["median"],
            "samples": wall_samples,
            **statistics(wall_samples),
            "warmup_wall_seconds": warmup["wall_seconds"],
            "checksum": repetitions[0]["checksum"],
        }
        results[f"{scenario}_rss"] = {
            "source_name": f"{scenario}_rss",
            "scenario": scenario,
            "dimension": entry["dimension"],
            "runner": entry["runner"],
            "scale": entry["scale"] or None,
            "unit": "MiB",
            "direction": "lower_is_better",
            "value": statistics(rss_samples)["median"],
            "samples": rss_samples,
            **statistics(rss_samples),
            "warmup_rss_mib": warmup["max_rss_mib"],
        }
        matrix_meta.append(
            {
                "scenario": scenario,
                "dimension": entry["dimension"],
                "runner": entry["runner"],
                "target": entry["target"],
                "scale": entry["scale"] or None,
                "check": entry["check"],
                "expected": entry["expected"],
                "tolerance": entry["tolerance"] or None,
                "workload": entry["workload"],
            }
        )

    payload = {
        "software": SOFTWARE,
        "version": os.environ.get("SOFTWARE_VERSION", ""),
        "architecture": os.environ.get("EXPECTED_ARCH", ""),
        "variant": os.environ.get("PERF_VARIANT", "base"),
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "scenarios": scenarios,
        "results": results,
        "parameters": {
            "repetitions": reps,
            "warmups": 1,
            "offline": True,
            "statistics": "median of independent repetitions; samples/min/max/mean/stdev retained",
            "matrix": scenarios,
            "dimensions": sorted({entry["dimension"] for entry in entries}),
            "scenario_details": matrix_meta,
        },
    }
    output_path.parent.mkdir(parents=True, exist_ok=True)
    temporary = output_path.with_name(f".{output_path.name}.tmp")
    temporary.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    temporary.replace(output_path)
    print(
        f"[{TAG}-parse] normalized {len(results)} metrics across {len(scenarios)} scenarios",
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
