#!/usr/bin/env python3
"""Normalize folly's official benchmark JSON outputs into per-scenario metrics.

Every official BENCHMARK target declared in folly's CMakeLists.txt runs its
own binary (built with folly/Benchmark.cpp) with --bm_json_verbose, whose
schema is the official [file, name, timeInNs, counters?] array consumed by
folly's benchmark_ab.py. This script extracts one timeInNs value per official
benchmark and names it <official DIRECTORY>/<cmake target>/<benchmark name>
so names stay verbatim traceable to the official entries.
"""

from __future__ import annotations

import json
import math
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def load_manifest(path: Path) -> list[dict[str, Any]]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"cannot read benchmark manifest: {exc}") from exc
    if not isinstance(payload, list) or not payload:
        raise RuntimeError("benchmark manifest must be a non-empty list")
    for entry in payload:
        if (
            not isinstance(entry, dict)
            or not isinstance(entry.get("dir"), str)
            or not isinstance(entry.get("target"), str)
        ):
            raise TypeError("benchmark manifest entries need string dir/target")
    return payload


def load_target_results(path: Path, target: str) -> list[Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError(
            f"cannot read --bm_json_verbose output of {target}: {exc}"
        ) from exc
    if not isinstance(payload, list) or not payload:
        raise RuntimeError(f"benchmark target {target} produced no benchmark rows")
    return payload


def to_metric(entry: Any, target: str, directory: str) -> dict[str, Any]:
    # Official --bm_json_verbose row: [file, name, timeInNs, counters?]
    if not isinstance(entry, list) or len(entry) < 3:
        raise TypeError(
            f"benchmark target {target} produced a malformed row: {entry!r}"
        )
    name = entry[1]
    if not isinstance(name, str) or not name:
        raise RuntimeError(f"benchmark target {target} has a row without a name")
    raw_value = entry[2]
    if isinstance(raw_value, bool) or not isinstance(raw_value, (int, float)):
        raise TypeError(f"benchmark {target}/{name} has a non-numeric timeInNs value")
    value = float(raw_value)
    if not math.isfinite(value) or value <= 0:
        raise RuntimeError(f"benchmark {target}/{name} has an invalid timeInNs value")
    source_name = f"{directory}/{target}/{name}"
    return {
        "source_name": source_name,
        "source_field": "timeInNs",
        "raw_value": value,
        "raw_unit": "ns",
        "value": value,
        "unit": "ns",
    }


def normalize_results(
    manifest: list[dict[str, Any]], bench_json_dir: Path
) -> dict[str, dict[str, Any]]:
    results: dict[str, dict[str, Any]] = {}
    for entry in manifest:
        target, directory = entry["target"], entry["dir"]
        target_path = bench_json_dir / f"{target}.json"
        for row in load_target_results(target_path, target):
            metric = to_metric(row, target, directory)
            source_name = metric["source_name"]
            if source_name in results:
                raise RuntimeError(
                    f"official benchmarks produced duplicate scenario: {source_name}"
                )
            results[source_name] = metric
    if not results:
        raise RuntimeError("official benchmarks produced no scenarios")
    return results


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "usage: parse_benchmark.py MANIFEST_JSON BENCH_JSON_DIR NORMALIZED_OUTPUT",
            file=sys.stderr,
        )
        return 1
    manifest_path = Path(sys.argv[1])
    bench_json_dir = Path(sys.argv[2])
    normalized_output = Path(sys.argv[3])

    try:
        manifest = load_manifest(manifest_path)
        results = normalize_results(manifest, bench_json_dir)
    except (RuntimeError, TypeError, ValueError) as exc:
        print(f"[folly-parse] ERROR: {exc}", file=sys.stderr)
        return 1

    version = os.environ["SOFTWARE_VERSION"]
    architecture = os.environ["EXPECTED_ARCH"]
    normalized = {
        "benchmark": "folly_official_benchmarks",
        "software": "folly",
        "version": version,
        "architecture": architecture,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "official_entry": (
                "official BENCHMARK targets of CMakeLists.txt, each binary run "
                "with --bm_json_verbose (folly/Benchmark.cpp)"
            ),
            "command": ["<target>", "--bm_json_verbose=<output>"],
            "benchmark_targets": len(manifest),
            "metric_source": "timeInNs of every --bm_json_verbose row",
        },
        "metric_contract": {
            "scope": "timeInNs of every benchmark in every official target",
            "source_field": "timeInNs",
            "normalized_unit": "ns",
            "direction": "lower_is_better",
        },
        "results": results,
    }

    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(normalized, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"[folly-parse] normalized {len(results)} official scenarios")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
