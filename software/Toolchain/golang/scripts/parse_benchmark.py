#!/usr/bin/env python3
"""Validate and normalize the 20 selected Bent ns/op benchmarks."""

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

BENCHMARK_LINE = re.compile(r"^(Benchmark\S+)\s+(\d+)\s+(.+)$")
MEASUREMENT = re.compile(r"([+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?)\s+(\S+)")
TAG_LINE = re.compile(r"^(pkg|shortname|toolchain):\s*(.+)$")
CONFIG_NAME = re.compile(r'^\s*Name = "([^"]+)"\s*$', re.MULTILINE)
REPEATS = 15


def expected_shortnames() -> list[str]:
    names = CONFIG_NAME.findall(Path(__file__).with_name("benchmarks.toml").read_text(encoding="utf-8"))
    if len(names) != 20 or len(set(names)) != 20:
        raise RuntimeError("selected Bent configuration must contain 20 unique benchmarks")
    return names


def parse_output(lines: list[str]) -> tuple[dict[str, dict[str, Any]], dict[str, Any]]:
    expected = set(expected_shortnames())
    samples: dict[str, list[float]] = {name: [] for name in expected}
    identities: dict[str, tuple[str, str]] = {}
    tags: dict[str, str] = {}

    for line in lines:
        tag = TAG_LINE.match(line)
        if tag:
            tags[tag.group(1)] = tag.group(2).strip()
            continue
        match = BENCHMARK_LINE.match(line)
        if not match:
            continue
        shortname = tags.get("shortname")
        package = tags.get("pkg")
        if shortname not in expected:
            raise RuntimeError(f"unexpected Bent benchmark shortname: {shortname!r}")
        if not package:
            raise RuntimeError(f"benchmark {shortname} has no official pkg tag")
        if tags.get("toolchain") != "Baseline":
            raise RuntimeError(f"benchmark {shortname} was not run with Baseline")
        benchmark = match.group(1)
        ns_values = [
            float(value) for value, unit in MEASUREMENT.findall(match.group(3)) if unit == "ns/op"
        ]
        if len(ns_values) != 1 or not math.isfinite(ns_values[0]) or ns_values[0] <= 0:
            raise RuntimeError(f"benchmark {shortname} has no single positive ns/op value")
        identity = (package, benchmark)
        if shortname in identities and identities[shortname] != identity:
            raise RuntimeError(f"benchmark {shortname} produced multiple source identities")
        identities[shortname] = identity
        samples[shortname].append(ns_values[0])

    wrong_counts = {name: len(values) for name, values in samples.items() if len(values) != REPEATS}
    if wrong_counts:
        raise RuntimeError(f"Bent benchmarks must each produce {REPEATS} ns/op samples: {wrong_counts}")

    results: dict[str, dict[str, Any]] = {}
    for shortname in sorted(expected):
        package, benchmark = identities[shortname]
        name = f"{shortname} :: {benchmark} :: ns/op"
        value = statistics.median(samples[shortname])
        results[name] = {
            "source_name": name,
            "source_shortname": shortname,
            "source_benchmark": benchmark,
            "source_package": package,
            "source_field": "ns/op",
            "raw_value": value,
            "raw_unit": "ns/op",
            "value": value,
            "unit": "ns/op",
            "direction": "lower_is_better",
            "samples": REPEATS,
            "group": shortname.split("-", 1)[0],
        }

    concurrency = sorted({
        match.group(1)
        for _, benchmark in identities.values()
        if (match := re.search(r"-(\d+)$", benchmark))
    })
    return results, {
        "packages": sorted({package for package, _ in identities.values()}),
        "benchmarks": sorted(expected),
        "bent_measurements": sum(map(len, samples.values())),
        "source_gomaxprocs": concurrency,
    }


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: parse_benchmark.py RAW_STDOUT NORMALIZED_OUTPUT", file=sys.stderr)
        return 1
    raw_path, output_path = Path(sys.argv[1]), Path(sys.argv[2])
    try:
        version = os.environ["SOFTWARE_VERSION"]
        architecture = os.environ["EXPECTED_ARCH"]
        results, context = parse_output(
            raw_path.read_text(encoding="utf-8", errors="replace").splitlines()
        )
    except (KeyError, OSError, RuntimeError, ValueError) as exc:
        print(f"[golang-parse] ERROR: {exc}", file=sys.stderr)
        return 1

    payload = {
        "benchmark": "golang_selected_bent_20",
        "software": "golang",
        "version": version,
        "architecture": architecture,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "components": {
                "install": ["go", "install", "golang.org/x/benchmarks/cmd/bent@latest"],
                "run": ["bent", "-B", "benchmarks.toml", "-C", "configurations.toml", "-N", "15", "-L", ".bent-stamps.log", "-v"],
            },
            "suite": "golang.org/x/benchmarks/cmd/bent",
            "configuration_files": ["suites.toml", "benchmarks.toml", "configurations.toml"],
            "configuration": {
                "name": "Baseline",
                "run_environment": ["GOGC=100", "GOMAXPROCS=$(nproc)"],
                "cpu_affinity": "none",
            },
            "benchmark_count": 20,
            "repetitions": REPEATS,
            "aggregation": "median",
        },
        "metric_contract": {
            "scope": "the 20 selected Bent benchmark ns/op measurements",
            "identity": "official Bent shortname + original benchmark name (including concurrency suffix) + ns/op",
            "aggregation": "median of 15 original ns/op measurements",
        },
        "runtime_context": context,
        "results": results,
    }
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"[golang-parse] normalized {len(results)} selected Bent ns/op metrics")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
