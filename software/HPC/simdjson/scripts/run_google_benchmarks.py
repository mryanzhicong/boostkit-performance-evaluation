#!/usr/bin/env python3
"""Run the official simdjson Google Benchmark suites and write structured results."""

from __future__ import annotations

import json
import math
import os
import re
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

RUN_TIMEOUT_SECONDS = 7200

# google-benchmark appends "/repeats:N" to run names when the CLI
# repetition count drives a benchmark that also sets ->Repetitions() in
# source; strip it so the official test name is preserved verbatim.
REPEATS_SUFFIX = re.compile(r"/repeats:\d+$")

# Google Benchmark reports cpu_time in a scaled unit; normalize to ns.
TIME_UNIT_TO_NS = {
    "ns": 1.0,
    "us": 1_000.0,
    "ms": 1_000_000.0,
    "s": 1_000_000_000.0,
}

# The two official suites: (binary basename, benchmark filter of none).
SUITES: tuple[tuple[str, str], ...] = (
    ("bench_parse_call", ""),
    ("bench_dom_api", ""),
)


def run_benchmark_binary(
    binary: Path, repetitions: int, output_file: Path
) -> dict[str, Any]:
    """Run one official suite with the google-benchmark CLI, return its JSON."""
    command = [
        str(binary),
        f"--benchmark_repetitions={repetitions}",
        "--benchmark_report_aggregates_only=true",
        "--benchmark_format=json",
        f"--benchmark_out={output_file}",
    ]
    print(f"[googlebench] {' '.join(command)}", flush=True)
    completed = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=RUN_TIMEOUT_SECONDS,
        check=False,
    )
    print(completed.stdout, end="", flush=True)
    if completed.returncode:
        raise RuntimeError(f"{binary.name} exited with code {completed.returncode}")
    try:
        payload = json.loads(output_file.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"{binary.name} produced unreadable JSON output: {exc}") from exc
    if not isinstance(payload, dict) or not isinstance(payload.get("benchmarks"), list):
        raise RuntimeError(f"{binary.name} produced no benchmark JSON")
    return payload


def list_tests(binary: Path) -> list[str]:
    """Return the official --benchmark_list_tests entries."""
    completed = subprocess.run(
        [str(binary), "--benchmark_list_tests=true"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=120,
        check=False,
    )
    if completed.returncode:
        raise RuntimeError(f"{binary.name} --benchmark_list_tests exited non-zero")
    tests = [line.strip() for line in completed.stdout.splitlines() if line.strip()]
    if not tests:
        raise RuntimeError(f"{binary.name} --benchmark_list_tests reported no tests")
    return tests


def strip_repeats(name: str) -> str:
    return REPEATS_SUFFIX.sub("", name)


def to_nanoseconds(raw_value: Any, raw_unit: Any, name: str) -> float:
    if isinstance(raw_value, bool) or not isinstance(raw_value, (int, float)):
        raise RuntimeError(f"test {name} has no numeric cpu_time")
    if raw_unit not in TIME_UNIT_TO_NS:
        raise RuntimeError(f"test {name} has unsupported time_unit: {raw_unit}")
    value = float(raw_value) * TIME_UNIT_TO_NS[raw_unit]
    if not math.isfinite(value) or value <= 0:
        raise RuntimeError(f"test {name} has an invalid cpu_time value")
    return value


def extract_suite_results(
    suite: str, payload: dict[str, Any], repetitions: int, roster: list[str]
) -> dict[str, dict[str, Any]]:
    """Extract the median aggregate row of every official test of one suite."""
    medians: dict[str, dict[str, Any]] = {}
    for entry in payload["benchmarks"]:
        if not isinstance(entry, dict) or entry.get("run_type") != "aggregate":
            continue
        if entry.get("aggregate_name") != "median":
            continue
        raw_name = entry.get("run_name") or strip_repeats(
            str(entry.get("name", "")).removesuffix("_median")
        )
        test_name = strip_repeats(str(raw_name))
        if test_name in medians:
            raise RuntimeError(f"suite {suite} produced duplicate test {test_name}")
        medians[test_name] = entry

    missing = [name for name in roster if name not in medians]
    if missing:
        raise RuntimeError(
            f"suite {suite} results are missing {len(missing)} official tests: {missing[:5]}"
        )

    results: dict[str, dict[str, Any]] = {}
    for test_name in roster:
        entry = medians[test_name]
        if int(entry.get("repetitions", 0)) != repetitions:
            raise RuntimeError(
                f"test {suite}/{test_name} ran {entry.get('repetitions')} repetitions, "
                f"expected {repetitions}"
            )
        raw_unit = entry.get("time_unit")
        value_ns = to_nanoseconds(entry.get("cpu_time"), raw_unit, f"{suite}/{test_name}")

        # The official rate counters (throughput tests only): google
        # benchmark emits them as top-level rate fields on aggregate
        # rows, in bytes/s and documents/s respectively.
        gigabytes = entry.get("Gigabytes")
        docs = entry.get("docs")
        result: dict[str, Any] = {
            "suite": suite,
            "test": test_name,
            "repetitions": repetitions,
            "iterations": entry.get("iterations"),
            "value": value_ns,
            "raw_value": entry.get("cpu_time"),
            "raw_unit": raw_unit,
            "command_display": suite,
        }
        if isinstance(gigabytes, (int, float)) and not isinstance(gigabytes, bool):
            result["gigabytes_per_s"] = float(gigabytes) / 1e9
        if isinstance(docs, (int, float)) and not isinstance(docs, bool):
            result["docs_per_s"] = float(docs)
        results[f"{suite}/{test_name}"] = result
    return results


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "usage: run_google_benchmarks.py BENCH_PARSE_CALL BENCH_DOM_API OUTPUT",
            file=sys.stderr,
        )
        return 1
    binaries = [Path(arg) for arg in sys.argv[1:3]]
    output = Path(sys.argv[3])
    for binary in binaries:
        if not binary.is_file() or not os.access(binary, os.X_OK):
            raise RuntimeError(f"official benchmark executable is unavailable: {binary}")

    repetitions = int(os.environ.get("SIMDJSON_REPETITIONS", "10"))
    if repetitions < 2:
        raise RuntimeError("SIMDJSON_REPETITIONS must be at least 2 for aggregate rows")

    all_results: dict[str, dict[str, Any]] = {}
    with tempfile.TemporaryDirectory(prefix="simdjson-bench-") as scratch:
        for (suite, _), binary in zip(SUITES, binaries):
            # The roster prints the same "/repeats:N" suffix the run
            # names carry for tests with source-level ->Repetitions();
            # strip it for the comparison.
            roster = [strip_repeats(name) for name in list_tests(binary)]
            payload = run_benchmark_binary(
                binary, repetitions, Path(scratch) / f"{suite}.json"
            )
            suite_results = extract_suite_results(suite, payload, repetitions, roster)
            all_results.update(suite_results)
            print(
                f"[googlebench] {suite}: {len(suite_results)} official tests, "
                f"median of {repetitions} repetitions",
                flush=True,
            )

    payload = {
        "benchmark": "simdjson_googlebench",
        "software": "simdjson",
        "version": os.environ["SOFTWARE_VERSION"],
        "architecture": os.environ["EXPECTED_ARCH"],
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "source_repository": os.environ.get("SIMDJSON_SOURCE_URL", ""),
            "source_tag": f"v{os.environ['SOFTWARE_VERSION']}",
            "suites": [
                "official benchmark/bench_parse_call.cpp (parse/minify/UTF-8 validate throughput + error paths)",
                "official benchmark/bench_dom_api.cpp (serialization, element access, numbers scans)",
            ],
            "framework": "google/benchmark v1.9.5 (official CPM-pinned dependency)",
            "data": "official simdjson-data corpus (twitter.json, gsoc-2018.json, numbers.json; CPM-pinned commit)",
            "repetitions": repetitions,
            "aggregation": "median",
            "command": [
                "--benchmark_repetitions=<N>",
                "--benchmark_report_aggregates_only=true",
                "--benchmark_format=json",
            ],
        },
        "metric_contract": {
            "scope": "median cpu_time of every official benchmark test",
            "source_field": "cpu_time",
            "normalized_unit": "ns",
            "direction": "lower_is_better",
            "aggregation": "median",
        },
        "results": all_results,
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(
        f"[googlebench] {len(all_results)} official tests across {len(SUITES)} suites",
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
