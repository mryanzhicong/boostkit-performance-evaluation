#!/usr/bin/env python3
"""Normalize the official JMH JSON result into the framework schema.

The raw output is produced by ``org.openjdk.jmh.Main ... -rf json -rff
jmh-result.json`` (JMH 1.37, the version pinned by the OpenJDK build
infrastructure in make/jmh/createJMHBundle.sh). The selected test/micro
benchmark classes all declare ``@BenchmarkMode(Mode.AverageTime)`` and report
one entry per (benchmark method, parameter combination) with the class's own
``@OutputTimeUnit`` in ``primaryMetric.scoreUnit`` (ns/op, us/op or ms/op).

Every metric name is the verbatim JMH benchmark name, made unique by
appending the verbatim ``params`` values as ``(key=value)`` pairs, e.g.::

    org.openjdk.bench.java.lang.ArrayCopy.copy(size=10)

All scores are average per-operation times and are normalized to
microseconds (``unit: us``, ``lower_is_better``).
"""

from __future__ import annotations

import json
import math
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

# Multiply a raw JMH score by this factor to convert it to microseconds.
UNIT_TO_US = {
    "ns/op": 1.0 / 1000.0,
    "us/op": 1.0,
    "ms/op": 1000.0,
    "s/op": 1000.0 * 1000.0,
}
RAW_UNIT_RE = r"^(ns|us|ms|s)/op$"


def fail(message: str) -> None:
    print(f"[openjdk-parse] ERROR: {message}", file=sys.stderr)


def require_number(value: Any, name: str) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise RuntimeError(f"metric {name} is not numeric: {value!r}")
    if not math.isfinite(float(value)):
        raise RuntimeError(f"metric {name} is not finite: {value!r}")
    return float(value)


def require_positive(value: Any, name: str) -> float:
    number = require_number(value, name)
    if number <= 0:
        raise RuntimeError(f"metric {name} must be positive, got {number!r}")
    return number


def metric_name(benchmark: str, params: dict[str, Any]) -> str:
    """Build the unique metric name from verbatim JMH fields."""
    if not params:
        return benchmark
    rendered = ", ".join(f"{key}={params[key]}" for key in sorted(params))
    return f"{benchmark}({rendered})"


def benchmark_allowed(benchmark: str, bench_classes: list[str]) -> bool:
    if not bench_classes:
        return True
    return any(
        benchmark.startswith(f"{cls}.") or benchmark == cls for cls in bench_classes
    )


def parse_entry(entry: Any, index: int, results: dict[str, Any]) -> dict[str, str]:
    """Normalize one JMH result entry; returns its runtime identity fields."""
    where = f"entry {index}"
    if not isinstance(entry, dict):
        raise RuntimeError(f"{where} is not a JSON object")
    benchmark = entry.get("benchmark")
    if not isinstance(benchmark, str) or not benchmark:
        raise RuntimeError(f"{where} has no benchmark name")
    mode = entry.get("mode")
    if mode != "avgt":
        raise RuntimeError(
            f"{where} ({benchmark}) reports mode {mode!r}, expected 'avgt' "
            "(all selected classes declare @BenchmarkMode(Mode.AverageTime))"
        )
    params = entry.get("params", {})
    if not isinstance(params, dict) or not all(
        isinstance(key, str) and isinstance(value, str) for key, value in params.items()
    ):
        raise RuntimeError(f"{where} ({benchmark}) has malformed params")
    primary = entry.get("primaryMetric")
    if not isinstance(primary, dict):
        raise RuntimeError(f"{where} ({benchmark}) has no primaryMetric object")
    score = primary.get("score")
    score_unit = primary.get("scoreUnit")
    if not isinstance(score_unit, str) or score_unit not in UNIT_TO_US:
        raise RuntimeError(
            f"{where} ({benchmark}) has unsupported scoreUnit: {score_unit!r}"
        )
    name = metric_name(benchmark, params)
    if name in results:
        raise RuntimeError(f"duplicate metric: {name}")
    raw_value = require_positive(score, name)
    results[name] = {
        "source_name": name,
        "source_field": "primaryMetric.score",
        "raw_value": raw_value,
        "raw_unit": score_unit,
        "value": raw_value * UNIT_TO_US[score_unit],
        "unit": "us",
        "source_file": "jmh-result.json",
    }
    return {
        "jmhVersion": str(entry.get("jmhVersion", "")),
        "jdkVersion": str(entry.get("jdkVersion", "")),
        "vmName": str(entry.get("vmName", "")),
        "vmVersion": str(entry.get("vmVersion", "")),
    }


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "usage: parse_benchmark.py JMH_RESULT_JSON NORMALIZED_OUTPUT",
            file=sys.stderr,
        )
        return 1
    jmh_result, normalized_output = Path(sys.argv[1]), Path(sys.argv[2])

    try:
        version = os.environ["SOFTWARE_VERSION"]
        architecture = os.environ["EXPECTED_ARCH"]
    except KeyError as exc:
        fail(f"missing environment variable: {exc}")
        return 1
    bench_classes = [
        item for item in os.environ.get("OPENJDK_BENCH_CLASSES", "").split() if item
    ]
    bench_sources = [
        item for item in os.environ.get("OPENJDK_BENCH_SOURCES", "").split() if item
    ]
    jmh_version = os.environ.get("OPENJDK_JMH_VERSION", "1.37")
    java_options = os.environ.get("OPENJDK_JAVA_OPTIONS", "")
    if not bench_classes or not bench_sources or not java_options:
        fail("OpenJDK benchmark classes, source files, and JVM options must be declared")
        return 1

    if not jmh_result.is_file():
        fail(f"JMH result file does not exist: {jmh_result}")
        return 1
    try:
        entries = json.loads(jmh_result.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, UnicodeDecodeError) as exc:
        fail(f"JMH result file is not valid JSON: {jmh_result} ({exc})")
        return 1
    if not isinstance(entries, list) or not entries:
        fail(f"JMH result file has no benchmark entries: {jmh_result}")
        return 1

    results: dict[str, Any] = {}
    runtime_identity: dict[str, str] | None = None
    try:
        for index, entry in enumerate(entries):
            identity = parse_entry(entry, index, results)
            if runtime_identity is None:
                runtime_identity = identity
            elif runtime_identity != identity:
                raise RuntimeError(
                    "JMH entries report different runtimes: "
                    f"{runtime_identity} vs {identity}"
                )
            entry_benchmark = entry.get("benchmark", "")
            if not benchmark_allowed(entry_benchmark, bench_classes):
                raise RuntimeError(
                    "unexpected benchmark outside OPENJDK_BENCH_CLASSES: "
                    f"{entry_benchmark}"
                )
    except (RuntimeError, TypeError) as exc:
        fail(str(exc))
        return 1

    identity = runtime_identity or {}
    actual_jmh_version = identity.get("jmhVersion") or jmh_version
    if identity.get("jmhVersion") and identity["jmhVersion"] != jmh_version:
        fail(
            f"JMH runtime version {identity['jmhVersion']} differs from the "
            f"pinned bundle version {jmh_version}"
        )
        return 1

    runtime_context: dict[str, Any] = {
        "jmh_version": actual_jmh_version,
        "jdk_version": identity.get("jdkVersion", ""),
        "vm_name": identity.get("vmName", ""),
        "vm_version": identity.get("vmVersion", ""),
    }
    normalized = {
        "benchmark": "openjdk_official_jmh_microbenchmarks",
        "software": "openjdk",
        "version": version,
        "architecture": architecture,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "command": [
                "java",
                "org.openjdk.jmh.Main",
                "<bench-class>[.] ...",
                "-rf",
                "json",
                "-rff",
                "jmh-result.json",
            ],
            "jmh_version": actual_jmh_version,
            "bench_classes": bench_classes,
            "bench_sources": bench_sources,
            "java_options": java_options,
            "benchmark_suite": "OpenJDK test/micro (JMH micro benchmarks)",
            "mode": "avgt (@BenchmarkMode(Mode.AverageTime))",
        },
        "metric_contract": {
            "scope": "JMH benchmark names with verbatim params from jmh-result.json",
            "source_fields": [
                "benchmark",
                "params",
                "primaryMetric.score",
                "primaryMetric.scoreUnit",
            ],
            "name_rule": "benchmark(key=value, ...) with params sorted by key",
            "raw_unit_pattern": RAW_UNIT_RE,
            "normalized_unit": "us",
            "direction": "lower_is_better",
        },
        "runtime_context": runtime_context,
        "results": results,
    }

    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(normalized, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(
        f"[openjdk-parse] normalized {len(results)} official JMH metrics "
        f"from {len(entries)} result entries"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
