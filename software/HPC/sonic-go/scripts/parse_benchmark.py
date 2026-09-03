#!/usr/bin/env python3
"""Normalize the official Sonic Go benchmark output without renaming fields."""

from __future__ import annotations

import json
import math
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

PACKAGE = re.compile(r"^pkg:\s+(?P<package>\S+)\s*$")
BENCHMARK = re.compile(r"^(?P<name>Benchmark\S+)\s+\d+\s+(?P<measurements>.+)$")
MEASUREMENT = re.compile(r"(?P<value>[0-9]+(?:\.[0-9]+)?)\s+(?P<unit>\S+)")


def direction(unit: str) -> str:
    if unit in {"ns/op", "B/op", "allocs/op"}:
        return "lower_is_better"
    if unit.endswith("/s"):
        return "higher_is_better"
    raise RuntimeError(f"unsupported official Go benchmark unit: {unit}")


def metric_name(package: str, benchmark: str, unit: str) -> str:
    return f"{package} :: {benchmark} :: {unit}"


def parse(path: Path) -> list[dict[str, Any]]:
    package = ""
    results: dict[str, dict[str, Any]] = {}
    try:
        lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError as exc:
        raise RuntimeError(f"cannot read official Sonic benchmark output: {exc}") from exc

    for line in lines:
        package_match = PACKAGE.match(line)
        if package_match:
            package = package_match.group("package")
            continue
        benchmark_match = BENCHMARK.match(line)
        if not benchmark_match:
            continue
        if not package:
            raise RuntimeError(
                f"official benchmark {benchmark_match.group('name')} has no package heading"
            )
        benchmark = benchmark_match.group("name")
        measurements = list(MEASUREMENT.finditer(benchmark_match.group("measurements")))
        if not measurements:
            raise RuntimeError(f"official benchmark {benchmark} has no measurements")
        for measurement in measurements:
            value = float(measurement.group("value"))
            unit = measurement.group("unit")
            if not math.isfinite(value) or value <= 0:
                raise RuntimeError(f"official benchmark {benchmark} has invalid {unit}: {value}")
            source_name = metric_name(package, benchmark, unit)
            if source_name in results:
                raise RuntimeError(f"duplicate official Sonic benchmark measurement: {source_name}")
            results[source_name] = {
                "source_name": source_name,
                "source_package": package,
                "source_benchmark": benchmark,
                "source_field": unit,
                "group": package,
                "value": value,
                "unit": unit,
                "direction": direction(unit),
            }
    if not results:
        raise RuntimeError("official Sonic benchmark output contains no measurements")
    return [results[key] for key in sorted(results)]


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: parse_benchmark.py RAW_OUTPUT NORMALIZED_OUTPUT", file=sys.stderr)
        return 1
    raw_path = Path(sys.argv[1])
    output_path = Path(sys.argv[2])
    try:
        results = parse(raw_path)
        payload = {
            "software": "sonic-go",
            "version": os.environ.get("SOFTWARE_VERSION", ""),
            "architecture": os.environ.get("EXPECTED_ARCH", ""),
            "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "benchmark": "bytedance_sonic_scripts_bench_sh",
            "command": "bash -e scripts/bench.sh",
            "environment": {
                "SONIC_ENCODER_USE_VM": "",
                "SONIC_USE_SVE_WRAPGOC": "1",
            },
            "results": results,
        }
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    except (OSError, RuntimeError, TypeError, ValueError) as exc:
        print(f"[sonic-go-parse] ERROR: {exc}", file=sys.stderr)
        return 1
    print(f"[sonic-go-parse] normalized {len(results)} official Sonic benchmark measurements")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
