#!/usr/bin/env python3
"""Extract comparable memcpy/memcmp timings from glibc 2.44 benchtests.

``memcpy`` and ``memcmp`` prefer their Kunpeng 950 implementation when the
benchtests output contains it, and otherwise fall back to the public entry.
"""

from __future__ import annotations

import json
import math
import os
import sys
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

TIMING_TYPE = "clock_gettime_ns"
LENGTHS = (2048, 4096)
PREFERRED_IMPLEMENTATIONS = {
    "memcpy": "__memcpy_kunpeng950",
    "memcmp": "__memcmp_kunpeng950",
}


def read_benchmark(directory: Path, function: str) -> tuple[dict[str, Any], str]:
    source_file = f"bench-{function}.out"
    path = directory / source_file
    if not path.is_file() or not path.stat().st_size:
        raise ValueError(f"missing or empty official output: {path}")
    payload = json.loads(path.read_text(encoding="utf-8"))
    if payload.get("timing_type") != TIMING_TYPE:
        raise ValueError(f"{source_file} does not use {TIMING_TYPE}")
    functions = payload.get("functions")
    if not isinstance(functions, dict) or list(functions) != [function]:
        raise ValueError(f"{source_file} has an unexpected function")
    benchmark = functions[function]
    implementations = benchmark.get("ifuncs")
    rows = benchmark.get("results")
    if not isinstance(implementations, list) or implementations.count(function) != 1:
        raise ValueError(f"{source_file} must include the public {function} entry")
    if not isinstance(rows, list) or not rows:
        raise ValueError(f"{source_file} has no benchmark results")
    return benchmark, source_file


def selected_implementation(
    benchmark: dict[str, Any], function: str, source_file: str
) -> tuple[str, int]:
    implementations = benchmark["ifuncs"]
    preferred = PREFERRED_IMPLEMENTATIONS[function]
    implementation = function
    if preferred in implementations:
        if implementations.count(preferred) != 1:
            raise ValueError(f"{source_file} has duplicate {preferred} entries")
        implementation = preferred
    return implementation, implementations.index(implementation)


def extract_metrics(directory: Path) -> dict[str, Any]:
    results: dict[str, Any] = {}
    for function in ("memcpy", "memcmp"):
        benchmark, source_file = read_benchmark(directory, function)
        implementation, implementation_index = selected_implementation(
            benchmark, function, source_file
        )
        for length in LENGTHS:
            scenario = {"length": length, "align1": 0, "align2": 0}
            if function == "memcpy":
                scenario["dst > src"] = 0
            else:
                scenario["result"] = 0
            matches = [
                (index, row)
                for index, row in enumerate(benchmark["results"])
                if isinstance(row, dict)
                and all(row.get(key) == value for key, value in scenario.items())
            ]
            if not matches:
                raise ValueError(
                    f"{source_file} has no {scenario} scenario"
                )
            # memcpy repeats the page-size case after its power-of-two sweep.
            # The first matching row always belongs to the common sweep on
            # both architectures, regardless of the host page size.
            row_index, row = matches[0]
            timings = row.get("timings")
            if not isinstance(timings, list) or len(timings) != len(benchmark["ifuncs"]):
                raise ValueError(f"{source_file} has malformed timing values")
            value = timings[implementation_index]
            if (
                isinstance(value, bool)
                or not isinstance(value, (int, float))
                or not math.isfinite(value)
                or value <= 0
            ):
                raise ValueError(f"{source_file} contains an invalid timing: {value!r}")
            name = f"{function}.length={length}.align1=0.align2=0"
            name += ".dst_gt_src=0" if function == "memcpy" else ".result=0"
            results[name] = {
                "source_name": name,
                "source_field": (
                    f"functions.{function}.results[{row_index}]."
                    f"timings[{implementation_index}]"
                ),
                "source_file": source_file,
                "implementation": implementation,
                "group": function,
                "raw_value": value,
                "raw_unit": "ns",
                "value": value,
                "unit": "ns",
            }
    return results


def extract_items(directory: Path) -> list[dict[str, Any]]:
    """Emit one raw item per official scenario and selected implementation."""
    items: list[dict[str, Any]] = []
    occurrences: dict[tuple[str, str], int] = defaultdict(int)
    for function in ("memcpy", "memcmp"):
        benchmark, source_file = read_benchmark(directory, function)
        implementation, implementation_index = selected_implementation(
            benchmark, function, source_file
        )
        for row_index, row in enumerate(benchmark["results"]):
            if not isinstance(row, dict):
                raise ValueError(f"{source_file} has malformed result row")
            scenario = {key: value for key, value in row.items() if key != "timings"}
            timings = row.get("timings")
            if not isinstance(timings, list) or implementation_index >= len(timings):
                raise ValueError(f"{source_file} has malformed timing values")
            value = timings[implementation_index]
            if (
                isinstance(value, bool)
                or not isinstance(value, (int, float))
                or not math.isfinite(value)
                or value <= 0
            ):
                raise ValueError(f"{source_file} contains an invalid timing: {value!r}")
            canonical = json.dumps(scenario, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
            occurrence = occurrences[(function, canonical)]
            occurrences[(function, canonical)] += 1
            items.append({
                "key": f"{function}|{canonical}|occurrence={occurrence}",
                "function": function,
                "group": function,
                "scenario": scenario,
                "unit": "ns",
                "direction": "lower_is_better",
                "value": value,
                "raw_value": value,
                "raw_unit": "ns",
                "implementation": implementation,
                "source_file": source_file,
                "source_field": (
                    f"functions.{function}.results[{row_index}]."
                    f"timings[{implementation_index}]"
                ),
            })
    return items


def write_items(items: list[dict[str, Any]], path: Path) -> None:
    path.write_text(
        "".join(json.dumps(item, ensure_ascii=False, separators=(",", ":")) + "\n" for item in items),
        encoding="utf-8",
    )


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: parse_benchmark.py BENCHTESTS_DIR OUTPUT_JSON", file=sys.stderr)
        return 1
    directory, output_path = Path(sys.argv[1]), Path(sys.argv[2])
    if os.environ.get("TIMING_TYPE_OUTPUT") != TIMING_TYPE:
        print("[glibc-parse] ERROR: bench-timing-type is not clock_gettime_ns", file=sys.stderr)
        return 1
    try:
        results = extract_metrics(directory)
    except (OSError, ValueError, TypeError, json.JSONDecodeError) as exc:
        print(f"[glibc-parse] ERROR: {exc}", file=sys.stderr)
        return 1
    payload = {
        "benchmark": "glibc_2.44_string_benchtests",
        "software": "glibc",
        "version": os.environ["SOFTWARE_VERSION"],
        "architecture": os.environ["EXPECTED_ARCH"],
        "variant": os.environ.get("PERF_VARIANT", "base"),
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "variant": os.environ.get("PERF_VARIANT", "base"),
            "build_targets": ["bench-timing-type", "bench-memcpy", "bench-memcmp"],
            "run_commands": ["bench-memcpy", "bench-memcmp"],
            "timing_backend": "clock_gettime(CLOCK_MONOTONIC)",
            "benchtest_patch": "scripts/glibc-2.44-benchtests.patch",
            "selected_lengths": list(LENGTHS),
            "implementation_selection": {
                function: [PREFERRED_IMPLEMENTATIONS[function], function]
                for function in ("memcpy", "memcmp")
            },
        },
        "results": results,
    }
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    items = extract_items(directory)
    write_items(items, output_path.parent / "items.jsonl")
    print(f"[glibc-parse] normalized {len(results)} public glibc timings")
    print(f"[glibc-parse] wrote {len(items)} raw scenario items")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
