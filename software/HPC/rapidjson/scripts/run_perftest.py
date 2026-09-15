#!/usr/bin/env python3
"""Run the official RapidJSON perftest suite and write structured results."""

from __future__ import annotations

import json
import math
import os
import re
import statistics
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

RUN_TIMEOUT_SECONDS = 3600

# gtest per-test result line: "[       OK ] Suite.Test (123 ms)".
OK_LINE = re.compile(r"^\[\s+OK\s+\]\s+(\S+)\s+\((\d+)\s+ms\)$", re.MULTILINE)
FAILED_LINE = re.compile(r"^\[\s+FAILED\s+\]", re.MULTILINE)

# The SIMD suffix the suite appends to test names on x86 (perftest.h
# SIMD_SUFFIX under -march=native); aarch64 has no SIMD path in v1.1.0
# and uses the bare names.  Normalized away for cross-architecture
# metric stability, preserved per-result for context.
SIMD_SUFFIX = re.compile(r"_(SSE42|SSE2)$")


def normalize_test(raw_name: str) -> tuple[str, str]:
    """Return (metric name, simd suffix or empty)."""
    match = SIMD_SUFFIX.search(raw_name)
    if match:
        return raw_name[: -len(match.group(0))], match.group(1)
    return raw_name, ""


def list_tests(perftest: Path) -> list[str]:
    """Return the official --gtest_list_tests entries (raw names)."""
    completed = subprocess.run(
        [str(perftest), "--gtest_list_tests"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=120,
        check=False,
    )
    if completed.returncode:
        raise RuntimeError("perftest --gtest_list_tests exited with a non-zero code")
    tests: list[str] = []
    suite = ""
    for line in completed.stdout.splitlines():
        if not line.strip() or line.startswith(("Running main", "[")):
            continue
        if not line.startswith(" "):
            # gtest prints the suite line with a trailing dot.
            suite = line.strip().rstrip(".")
        elif suite:
            tests.append(f"{suite}.{line.strip().split()[0]}")
    if not tests:
        raise RuntimeError("perftest --gtest_list_tests reported no tests")
    return tests


def run_suite(perftest: Path, data_dir: Path, repetitions: int) -> str:
    """Run the official full suite `repetitions` times, return the output."""
    command = [str(perftest), f"--gtest_repeat={repetitions}"]
    print(f"[perftest] (cwd={data_dir}) {' '.join(command)}", flush=True)
    completed = subprocess.run(
        command,
        cwd=str(data_dir),
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
        raise RuntimeError(f"perftest exited with code {completed.returncode}")
    return completed.stdout


def collect_durations(output: str) -> dict[str, list[tuple[str, int]]]:
    """Group gtest OK durations by normalized test name."""
    durations: dict[str, list[tuple[str, int]]] = {}
    for raw_name, milliseconds in OK_LINE.findall(output):
        metric, suffix = normalize_test(raw_name)
        durations.setdefault(metric, []).append((suffix, int(milliseconds)))
    return durations


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "usage: run_perftest.py PERFTEST_BIN DATA_DIR OUTPUT",
            file=sys.stderr,
        )
        return 1
    perftest, data_dir, output = map(Path, sys.argv[1:4])
    if not perftest.is_file() or not os.access(perftest, os.X_OK):
        raise RuntimeError(f"official perftest executable is unavailable: {perftest}")
    if not data_dir.is_dir():
        raise RuntimeError(f"official bin data directory is unavailable: {data_dir}")

    repetitions = int(os.environ.get("RAPIDJSON_REPETITIONS", "5"))
    if repetitions < 1:
        raise RuntimeError("RAPIDJSON_REPETITIONS must be a positive integer")

    # The official test roster, for cross-validation of the run.
    listed = list_tests(perftest)
    listed_metrics = sorted({normalize_test(name)[0] for name in listed})

    output_text = run_suite(perftest, data_dir, repetitions)
    if FAILED_LINE.search(output_text):
        raise RuntimeError("perftest reported at least one FAILED test")

    durations = collect_durations(output_text)
    if not durations:
        raise RuntimeError("perftest produced no passing test results")

    missing = [name for name in listed_metrics if name not in durations]
    if missing:
        raise RuntimeError(
            f"perftest results are missing {len(missing)} official tests: {missing[:5]}"
        )

    results: dict[str, dict[str, Any]] = {}
    for metric_name in listed_metrics:
        samples = durations[metric_name]
        if len(samples) != repetitions:
            raise RuntimeError(
                f"test {metric_name} produced {len(samples)} samples, expected {repetitions}"
            )
        values = [value for _, value in samples]
        for value in values:
            if not math.isfinite(value) or value <= 0:
                raise RuntimeError(
                    f"test {metric_name} reported a non-positive duration: {value}"
                )
        suffixes = sorted({suffix for suffix, _ in samples})
        suite, _, test = metric_name.partition(".")
        results[metric_name] = {
            "suite": suite,
            "test": test,
            "simd_suffix": suffixes[0] if len(suffixes) == 1 else "",
            "repetitions": repetitions,
            "samples_ms": values,
            "median_ms": statistics.median(values),
            "min_ms": min(values),
            "command_display": suite,
        }

    payload = {
        "benchmark": "rapidjson_perftest",
        "software": "rapidjson",
        "version": os.environ["SOFTWARE_VERSION"],
        "architecture": os.environ["EXPECTED_ARCH"],
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "source_repository": os.environ.get("RAPIDJSON_SOURCE_URL", ""),
            "source_tag": f"v{os.environ['SOFTWARE_VERSION']}",
            "framework": "official test/perftest (googletest, thirdparty/gtest submodule)",
            "workloads": "official rapidjsontest.cpp (parse/DOM/traverse/writer/whitespace/UTF-8/streams) + schematest.cpp (JSON Schema draft-4)",
            "data": "official bin/data/sample.json (687 KiB), bin/types/*, bin/jsonschema/tests/draft4/*",
            "repetitions": repetitions,
            "timer": "googletest per-test wall-clock duration (ms)",
            "simd_name_normalization": "_SSE42/_SSE2 suffixes stripped (x86); aarch64 has no SIMD path in v1.1.0",
        },
        "results": results,
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(
        json.dumps(payload, indent=2) + "\n",
        encoding="utf-8",
    )
    print(
        f"[perftest] {len(results)} official tests, median of {repetitions} runs each",
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
