#!/usr/bin/env python3
"""Collect the benchmark driver output without aggregation."""

from __future__ import annotations

import json
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

# AVIFBENCH|encode|1920x1080_yuv420_8bpc|1|<median_ns>|<min_ns>|<max_ns>|<samples>
RESULT_LINE = re.compile(
    r"^AVIFBENCH\|(?P<op>encode|decode)\|(?P<load>\S+)\|(?P<threads>\d+)"
    r"\|(?P<median_ns>\d+)\|(?P<min_ns>\d+)\|(?P<max_ns>\d+)\|(?P<samples>\d+)$"
)
VERSION_LINE = re.compile(r"^AVIFBENCH version libavif (?P<version>\S+)$")

EXPECTED_OPS = ("encode", "decode")
EXPECTED_LOADS = (
    "1920x1080_yuv420_8bpc",
    "3840x2160_yuv420_8bpc",
    "1920x1080_yuv444_10bpc",
)
EXPECTED_THREADS = (1, 4, 16)


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "usage: collect_avif_benchmark.py RAW_OUTPUT RESULTS_JSON",
            file=sys.stderr,
        )
        return 1

    raw_path = Path(sys.argv[1])
    output_path = Path(sys.argv[2])
    version = os.environ["SOFTWARE_VERSION"]

    try:
        lines = raw_path.read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError as exc:
        print(f"[libavif] ERROR: {exc}", file=sys.stderr)
        return 1

    reported_version = ""
    results: dict[str, dict[str, object]] = {}
    seen_scenarios: set[tuple[str, str, int]] = set()
    for line in lines:
        version_match = VERSION_LINE.match(line)
        if version_match:
            reported_version = version_match.group("version")
            continue
        match = RESULT_LINE.match(line)
        if match is None:
            continue
        op = match.group("op")
        load = match.group("load")
        threads = int(match.group("threads"))
        median_ms = int(match.group("median_ns")) / 1e6
        samples = int(match.group("samples"))
        if op not in EXPECTED_OPS:
            raise ValueError(f"unknown benchmark operation: {op}")
        if samples < 1:
            raise ValueError(f"scenario {op} {load} threads={threads} has no samples")
        if median_ms <= 0:
            raise ValueError(
                f"scenario {op} {load} threads={threads} reported a non-positive median"
            )
        scenario = (op, load, threads)
        if scenario in seen_scenarios:
            raise ValueError(f"duplicate benchmark scenario: {op} {load} threads={threads}")
        seen_scenarios.add(scenario)
        source_name = f"avif {op} {load} --threads={threads}: median"
        results[source_name] = {
            "source_name": source_name,
            "scenario": f"{op} {load}",
            "threads": threads,
            "source_field": "median",
            "value": median_ms,
            "unit": "ms",
            "direction": "lower_is_better",
            "source_file": raw_path.name,
        }

    if reported_version != version:
        raise ValueError(
            f"benchmark driver reports libavif {reported_version or 'unknown'}, expected {version}"
        )
    missing_scenarios = [
        f"{op} {load} --threads={threads}"
        for op in EXPECTED_OPS
        for load in EXPECTED_LOADS
        for threads in EXPECTED_THREADS
        if (op, load, threads) not in seen_scenarios
    ]
    if missing_scenarios:
        raise ValueError(
            "benchmark output is missing scenarios: " + ", ".join(missing_scenarios)
        )

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps(
            {
                "software": "libavif",
                "version": version,
                "architecture": os.environ["EXPECTED_ARCH"],
                "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
                "results": results,
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    print(f"[libavif] recorded {len(results)} libavif benchmark metrics")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError) as exc:
        print(f"[libavif] ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
