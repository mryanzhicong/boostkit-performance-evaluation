#!/usr/bin/env python3
"""Aggregate the SQLite benchmark rounds from the raw log into benchmark_clang.json."""

from __future__ import annotations

import argparse
import json
import math
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from statistics import median

RESULT_LINE = re.compile(
    r"^result scenario=(?P<scenario>\S+) workload=(?P<workload>\S+) "
    r"round=(?P<round>\d+) wall_seconds=(?P<wall>[0-9]+(?:\.[0-9]+)?) "
    r"artifact_bytes=(?P<bytes>[0-9]+)$"
)
FIELDS = (
    ("median wall time", "s"),
    ("fastest wall time", "s"),
    ("artifact size", "KiB"),
)
EXPECTED_WORKLOADS = {
    "compile": ("-O0", "-O2", "-Os"),
    "speedtest1": ("100000", "500000"),
}
MIN_ROUNDS = 2


class ParseError(ValueError):
    pass


def metric_prefix(scenario: str, workload: str) -> str:
    if scenario == "compile":
        return f"compile sqlite3.c --opt={workload}"
    return f"speedtest1 --size={workload}"


def parse_log(raw_log: Path) -> dict[tuple[str, str], dict[str, list]]:
    rounds: dict[tuple[str, str], dict[str, list]] = {}
    for line in raw_log.read_text(encoding="utf-8", errors="replace").splitlines():
        match = RESULT_LINE.match(line.strip())
        if match is None:
            continue
        scenario = match.group("scenario")
        workload = match.group("workload")
        if scenario not in EXPECTED_WORKLOADS:
            raise ParseError(f"unknown benchmark scenario: {scenario}")
        if workload not in EXPECTED_WORKLOADS[scenario]:
            raise ParseError(f"unknown workload for {scenario}: {workload}")
        entry = rounds.setdefault((scenario, workload), {"walls": [], "bytes": []})
        entry["walls"].append(float(match.group("wall")))
        entry["bytes"].append(int(match.group("bytes")))
    missing = [
        f"{scenario} --workload={workload}"
        for scenario, workloads in EXPECTED_WORKLOADS.items()
        for workload in workloads
        if (scenario, workload) not in rounds
    ]
    if missing:
        raise ParseError("SQLite benchmark is missing results: " + ", ".join(missing))
    observed = {len(entry["walls"]) for entry in rounds.values()}
    if len(observed) != 1:
        raise ParseError("every workload must record the same number of rounds")
    count = observed.pop()
    if count < MIN_ROUNDS:
        raise ParseError(f"every workload must record at least {MIN_ROUNDS} rounds")
    return rounds


def collect(raw_log: Path, version: str, architecture: str, expected_rounds: int) -> dict:
    rounds = parse_log(raw_log)
    counts = {len(entry["walls"]) for entry in rounds.values()}
    if counts != {expected_rounds}:
        raise ParseError(
            f"expected {expected_rounds} rounds per workload, observed {sorted(counts)}"
        )
    results: dict[str, dict] = {}
    measurements: list[dict] = []
    for (scenario, workload), entry in sorted(rounds.items()):
        walls: list[float] = entry["walls"]
        bytes_readings: list[int] = entry["bytes"]
        if any(not math.isfinite(value) or value <= 0 for value in walls):
            raise ParseError(f"non-positive wall time for {scenario} {workload}")
        prefix = metric_prefix(scenario, workload)
        values = {
            "median wall time": round(median(walls), 3),
            "fastest wall time": round(min(walls), 3),
            "artifact size": round(bytes_readings[-1] / 1024, 1),
        }
        for field, unit in FIELDS:
            name = f"{prefix}: {field}"
            if name in results:
                raise ParseError(f"duplicate SQLite benchmark metric: {name}")
            if values[field] <= 0:
                raise ParseError(f"non-positive value for {name}")
            results[name] = {
                "value": values[field],
                "unit": unit,
                "direction": "lower_is_better",
                "group": scenario,
                "workload": workload,
                "source_field": field,
                "source_name": name,
                "source_file": raw_log.name,
            }
            measurements.append({
                "scenario": scenario, "workload": workload,
                "source_field": field, "value": values[field],
                "unit": unit, "source_name": name,
                "source_file": raw_log.name,
            })
    return {
        "parameters": {
            "workload": "SQLite speedtest1 and amalgamation",
            "sqlite_version": "3.54.1",
            "compile_options": list(EXPECTED_WORKLOADS["compile"]),
            "speedtest_sizes": [int(size) for size in EXPECTED_WORKLOADS["speedtest1"]],
            "rounds": expected_rounds,
            "compiler": "clang",
        },
        "runtime_context": {
            "clang_version": version,
            "architecture": architecture,
            "collected_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        },
        "measurements": measurements,
        "results": results,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("raw_log", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("version")
    parser.add_argument("architecture")
    parser.add_argument("rounds", type=int)
    args = parser.parse_args()
    try:
        payload = collect(args.raw_log, args.version, args.architecture, args.rounds)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    except (OSError, ValueError) as exc:
        print(f"[clang] ERROR: {exc}", file=sys.stderr)
        return 1
    print(f"[clang] collected {len(payload['results'])} metrics from {len(EXPECTED_WORKLOADS)} scenarios")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
