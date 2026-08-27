#!/usr/bin/env python3
"""Normalize official ``go test -bench`` output into the framework schema.

The raw output is produced by running the Go standard library benchmarks from
the official golang/go source tree with a fixed set of flags. Every metric is
the median ns/op of the per-benchmark samples; benchmark names are preserved
verbatim from the official output.
"""

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

# Benchmark result line: name, iterations, ns/op value, then optional extra
# metric columns (B/op, allocs/op, custom report metrics) that are ignored.
BENCHMARK_PATTERN = re.compile(
    r"^(?P<name>Benchmark\S+)\s+(?P<iterations>\d+)\s+(?P<value>[0-9.]+)\s+ns/op(?:\s.*)?$"
)
# Output header lines such as "goos: linux" / "pkg: strconv" / "cpu: ...".
HEADER_PATTERN = re.compile(r"^(?P<key>goos|goarch|pkg|cpu):\s+(?P<value>.+)$")
# A trailing "-N" is the GOMAXPROCS suffix appended when -cpu is not 1.
GOMAXPROCS_SUFFIX_PATTERN = re.compile(r"-\d+$")

ARCH_TO_GOARCH = {"x86_64": "amd64", "aarch64": "arm64"}


def fail(message: str) -> None:
    print(f"[golang-parse] ERROR: {message}", file=sys.stderr)


def parse_raw_output(
    lines: list[str],
    expected_packages: list[str],
    expected_count: int,
    expected_goarch: str,
) -> tuple[dict[str, dict[str, Any]], dict[str, Any]]:
    samples: dict[str, list[float]] = {}
    package_of: dict[str, str] = {}
    header_values: dict[str, list[str]] = {}
    packages_seen: set[str] = set()
    current_package = ""

    for line in lines:
        header = HEADER_PATTERN.match(line)
        if header is not None:
            key = header.group("key")
            value = header.group("value").strip()
            header_values.setdefault(key, []).append(value)
            if key == "pkg":
                current_package = value
                packages_seen.add(value)
            continue
        match = BENCHMARK_PATTERN.match(line)
        if match is None:
            continue
        name = match.group("name")
        if GOMAXPROCS_SUFFIX_PATTERN.search(name):
            raise RuntimeError(
                f"benchmark {name} carries a GOMAXPROCS suffix; "
                "output does not come from a -cpu=1 run"
            )
        value = float(match.group("value"))
        if not math.isfinite(value) or value <= 0:
            raise RuntimeError(f"benchmark {name} has an invalid ns/op value")
        if name in samples and package_of[name] != current_package:
            raise RuntimeError(
                f"duplicate benchmark {name} in packages "
                f"{package_of[name]} and {current_package}"
            )
        samples.setdefault(name, []).append(value)
        package_of.setdefault(name, current_package)

    if not samples:
        raise RuntimeError("official go test output contains no benchmark results")

    goos_values = set(header_values.get("goos", []))
    if goos_values != {"linux"}:
        raise RuntimeError(f"unexpected goos in go test output: {sorted(goos_values)}")
    goarch_values = set(header_values.get("goarch", []))
    if goarch_values != {expected_goarch}:
        raise RuntimeError(
            f"unexpected goarch in go test output: {sorted(goarch_values)}, "
            f"expected {expected_goarch}"
        )
    cpu_models = set(header_values.get("cpu", []))
    if len(cpu_models) > 1:
        raise RuntimeError(f"inconsistent cpu models in go test output: {sorted(cpu_models)}")

    missing_packages = [p for p in expected_packages if p not in packages_seen]
    if missing_packages:
        raise RuntimeError(
            "official go test output is missing packages: " + ",".join(missing_packages)
        )
    empty_packages = [
        p for p in expected_packages if not any(origin == p for origin in package_of.values())
    ]
    if empty_packages:
        raise RuntimeError(
            "packages without benchmark results: " + ",".join(empty_packages)
        )

    for name, values in samples.items():
        if len(values) != expected_count:
            raise RuntimeError(
                f"benchmark {name} has {len(values)} samples, expected {expected_count}"
            )

    results: dict[str, dict[str, Any]] = {}
    for name, values in samples.items():
        median = statistics.median(values)
        if not math.isfinite(median) or median <= 0:
            raise RuntimeError(f"benchmark {name} has an invalid median ns/op")
        results[name] = {
            "source_name": name,
            "source_field": "ns/op",
            "raw_value": median,
            "raw_unit": "ns/op",
            "value": median,
            "unit": "ns/op",
            "samples": len(values),
            "package": package_of[name],
        }

    runtime_context: dict[str, Any] = {"goos": "linux", "goarch": expected_goarch}
    if cpu_models:
        runtime_context["cpu"] = sorted(cpu_models)[0]
    return results, runtime_context


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "usage: parse_benchmark.py GO_TEST_OUTPUT NORMALIZED_OUTPUT",
            file=sys.stderr,
        )
        return 1
    raw_path, normalized_output = Path(sys.argv[1]), Path(sys.argv[2])

    try:
        version = os.environ["SOFTWARE_VERSION"]
        architecture = os.environ["EXPECTED_ARCH"]
    except KeyError as exc:
        fail(f"missing environment variable: {exc}")
        return 1
    expected_goarch = ARCH_TO_GOARCH.get(architecture)
    if expected_goarch is None:
        fail(f"unsupported architecture: {architecture}")
        return 1
    packages = [item for item in os.environ.get("GO_BENCH_PACKAGES", "").split() if item]
    if not packages:
        fail("GO_BENCH_PACKAGES is empty")
        return 1
    try:
        expected_count = int(os.environ.get("GO_BENCH_COUNT", "3"))
    except ValueError:
        fail("GO_BENCH_COUNT is not an integer")
        return 1
    if expected_count < 1:
        fail("GO_BENCH_COUNT must be positive")
        return 1
    benchtime = os.environ.get("GO_BENCHTIME", "1s")
    bench_cpu = os.environ.get("GO_BENCH_CPU", "1")
    bootstrap_version = os.environ.get("GO_BOOTSTRAP_VERSION", "")

    try:
        lines = raw_path.read_text(encoding="utf-8", errors="replace").splitlines()
        results, runtime_context = parse_raw_output(
            lines, packages, expected_count, expected_goarch
        )
    except (RuntimeError, OSError) as exc:
        fail(str(exc))
        return 1

    normalized = {
        "benchmark": "golang_official_go_test_stdlib",
        "software": "golang",
        "version": version,
        "architecture": architecture,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "command": [
                "go",
                "test",
                "-run=^$",
                "-bench=.",
                f"-cpu={bench_cpu}",
                f"-count={expected_count}",
                f"-benchtime={benchtime}",
                *packages,
            ],
            "packages": packages,
            "benchtime": benchtime,
            "cpu": bench_cpu,
            "count": expected_count,
            "bootstrap_version": bootstrap_version,
            "aggregation": "median",
            "official_suite": "go test -bench (Go standard library benchmarks)",
        },
        "metric_contract": {
            "scope": "median ns/op of every official go test benchmark in the selected packages",
            "source_field": "ns/op",
            "normalized_unit": "ns/op",
            "direction": "lower_is_better",
            "aggregation": "median",
        },
        "runtime_context": runtime_context,
        "results": results,
    }

    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(normalized, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"[golang-parse] normalized {len(results)} official go test benchmarks")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
