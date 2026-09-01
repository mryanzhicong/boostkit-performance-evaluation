#!/usr/bin/env python3
"""Collect the original database_blue Sysbench summary files without aggregation."""

from __future__ import annotations

import json
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path


LOG_NAME = re.compile(r"normal_(?P<scenario>.+)\.log_")
FIELDS = (
    ("TPS", "transactions/s"),
    ("QPS", "queries/s"),
    ("transactions", "transactions"),
)
EXPECTED_SCENARIOS = (
    "distinct",
    "index",
    "nonindex",
    "order",
    "point",
    "simple",
    "sum",
    "delete",
    "mix",
)
EXPECTED_THREADS = (128, 256, 512, 1024)


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "usage: collect_database_blue_sysbench.py REPORT_DIR START_TIME OUTPUT",
            file=sys.stderr,
        )
        return 1

    report_dir = Path(sys.argv[1])
    start_time = float(sys.argv[2])
    output_path = Path(sys.argv[3])
    results: dict[str, dict[str, object]] = {}
    seen_runs: set[tuple[str, int]] = set()

    for path in sorted(report_dir.glob("normal_*.log_*")):
        if path.stat().st_mtime < start_time:
            continue
        match = LOG_NAME.match(path.name)
        if match is None:
            continue
        scenario = match.group("scenario")
        for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
            columns = line.split()
            if len(columns) != 5 or not columns[0].isdigit():
                continue
            threads = columns[0]
            seen_runs.add((scenario, int(threads)))
            for index, (field, unit) in enumerate(FIELDS, start=1):
                try:
                    value = float(columns[index])
                except ValueError as exc:
                    raise ValueError(f"invalid {field} in {path}: {line}") from exc
                source_name = f"sysbench {scenario} --threads={threads}: {field}"
                if source_name in results:
                    raise ValueError(f"duplicate database_blue metric: {source_name}")
                results[source_name] = {
                    "source_name": source_name,
                    "scenario": scenario,
                    "threads": int(threads),
                    "source_field": field,
                    "value": value,
                    "unit": unit,
                    "direction": "higher_is_better",
                    "source_file": path.name,
                }

    missing_runs = [
        f"{scenario} --threads={threads}"
        for scenario in EXPECTED_SCENARIOS
        for threads in EXPECTED_THREADS
        if (scenario, threads) not in seen_runs
    ]
    if missing_runs:
        raise ValueError(
            "database_blue is missing Sysbench results: " + ", ".join(missing_runs)
        )

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps(
            {
                "software": "mysql",
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
    print(f"[mysql] recorded {len(results)} database_blue Sysbench metrics")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError) as exc:
        print(f"[mysql] ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
