#!/usr/bin/env python3
"""Collect the SQLite benchmark rounds from the raw log into results.json."""

from __future__ import annotations

import json
import os
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
    "speedtest1": (100000, 500000),
}
MIN_ROUNDS = 2


def workload_key(scenario: str, workload: str) -> str | int:
    if scenario == "speedtest1":
        return int(workload)
    return workload


def metric_prefix(scenario: str, workload: str) -> str:
    if scenario == "compile":
        return f"compile sqlite3.c --opt={workload}"
    return f"speedtest1 --size={workload}"


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "usage: collect_clang_benchmark.py RAW_LOG OUTPUT",
            file=sys.stderr,
        )
        return 1

    raw_log = Path(sys.argv[1])
    output_path = Path(sys.argv[2])
    rounds: dict[tuple[str, str], dict[str, list[float] | list[int]]] = {}

    for line in raw_log.read_text(encoding="utf-8", errors="replace").splitlines():
        match = RESULT_LINE.match(line)
        if match is None:
            continue
        scenario = match.group("scenario")
        workload = match.group("workload")
        if scenario not in EXPECTED_WORKLOADS:
            raise ValueError(f"unknown benchmark scenario in {raw_log}: {scenario}")
        if workload_key(scenario, workload) not in EXPECTED_WORKLOADS[scenario]:
            raise ValueError(f"unknown workload for {scenario} in {raw_log}: {workload}")
        entry = rounds.setdefault((scenario, workload), {"walls": [], "bytes": []})
        entry["walls"].append(float(match.group("wall")))
        entry["bytes"].append(int(match.group("bytes")))

    missing = [
        f"{scenario} --workload={workload}"
        for scenario, workloads in EXPECTED_WORKLOADS.items()
        for workload in workloads
        if (scenario, str(workload)) not in rounds
    ]
    if missing:
        raise ValueError("SQLite benchmark is missing results: " + ", ".join(missing))

    observed_counts = {
        len(entry["walls"]) for entry in rounds.values()
    }
    if len(observed_counts) != 1 or observed_counts.pop() < MIN_ROUNDS:
        raise ValueError(
            "every workload must record the same number of rounds "
            f"(at least {MIN_ROUNDS})"
        )

    results: dict[str, dict[str, object]] = {}
    for (scenario, workload), entry in sorted(rounds.items()):
        walls: list[float] = entry["walls"]  # type: ignore[assignment]
        bytes_readings: list[int] = entry["bytes"]  # type: ignore[assignment]
        prefix = metric_prefix(scenario, workload)
        values = {
            "median wall time": round(median(walls), 3),
            "fastest wall time": round(min(walls), 3),
            "artifact size": round(bytes_readings[-1] / 1024, 1),
        }
        for field, unit in FIELDS:
            source_name = f"{prefix}: {field}"
            if source_name in results:
                raise ValueError(f"duplicate SQLite benchmark metric: {source_name}")
            results[source_name] = {
                "source_name": source_name,
                "scenario": scenario,
                "workload": workload_key(scenario, workload),
                "source_field": field,
                "value": values[field],
                "unit": unit,
                "direction": "lower_is_better",
                "source_file": raw_log.name,
            }

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps(
            {
                "software": "clang",
                "version": os.environ["SOFTWARE_VERSION"],
                "architecture": os.environ["EXPECTED_ARCH"],
                "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
                "results": results,
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    print(f"[clang] recorded {len(results)} SQLite benchmark metrics")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError) as exc:
        print(f"[clang] ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
