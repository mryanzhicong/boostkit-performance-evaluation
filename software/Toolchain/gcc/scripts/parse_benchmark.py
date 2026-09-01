#!/usr/bin/env python3
"""Normalize the official gcc.c-torture/compile compile-time output.

The raw output is produced by ``gcc_test.sh``: one line per official corpus
file and measurement iteration, ``<iteration> <source-file-name>
<elapsed-nanoseconds>``.
Every source file name is the verbatim name of an official corpus file from
``gcc/testsuite/gcc.c-torture/compile`` shipped inside the release tarball,
so each metric name is directly traceable to the official GCC source tree.

All timings are monotonic-clock durations in nanoseconds (from
``time.monotonic_ns``)
and are normalized to seconds (``unit: s``, ``lower_is_better``).
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

# A corpus file name must be a plain "<name>.c" C source name.
SOURCE_NAME_RE = re.compile(r"^[A-Za-z0-9._+-]+\.c$")
# One line: "<iteration> <source-file> <elapsed-ns>".
LINE_RE = re.compile(r"^(?P<iteration>[1-9]\d*)\s+(?P<name>\S+\.c)\s+(?P<ns>\d+)$")


def fail(message: str) -> None:
    print(f"[gcc-parse] ERROR: {message}", file=sys.stderr)


def parse_line(
    line: str, line_number: int, samples: dict[str, list[int]]
) -> None:
    match = LINE_RE.match(line)
    if not match:
        raise RuntimeError(f"malformed line {line_number}: {line!r}")
    name = match.group("name")
    if not SOURCE_NAME_RE.match(name):
        raise RuntimeError(f"line {line_number} has an invalid source name: {name}")
    elapsed_ns = int(match.group("ns"))
    if elapsed_ns <= 0:
        raise RuntimeError(f"metric {name} has a non-positive duration: {elapsed_ns}")
    samples.setdefault(name, []).append(elapsed_ns)


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "usage: parse_benchmark.py BENCHMARK_COMPILE_TXT NORMALIZED_OUTPUT",
            file=sys.stderr,
        )
        return 1
    raw_output, normalized_output = Path(sys.argv[1]), Path(sys.argv[2])

    try:
        version = os.environ["SOFTWARE_VERSION"]
        architecture = os.environ["EXPECTED_ARCH"]
    except KeyError as exc:
        fail(f"missing environment variable: {exc}")
        return 1
    opt_level = os.environ.get("GCC_OPT_LEVEL", "O2")
    gcc_version_string = os.environ.get("GCC_VERSION_STRING", "")
    try:
        compiled = int(os.environ.get("GCC_CORPUS_COMPILED", "0"))
    except ValueError:
        fail("GCC_CORPUS_COMPILED is not an integer")
        return 1
    try:
        corpus_files = int(os.environ.get("GCC_CORPUS_FILES", "0"))
    except ValueError:
        fail("GCC_CORPUS_FILES is not an integer")
        return 1
    try:
        iterations = int(os.environ.get("GCC_BENCHMARK_ITERATIONS", "0"))
    except ValueError:
        fail("GCC_BENCHMARK_ITERATIONS is not an integer")
        return 1
    if corpus_files <= 0 or iterations <= 0:
        fail("GCC corpus size and benchmark iterations must be positive")
        return 1

    if not raw_output.is_file():
        fail(f"benchmark output does not exist: {raw_output}")
        return 1
    text = raw_output.read_text(encoding="utf-8", errors="replace")
    if not text.strip():
        fail(f"benchmark output is empty: {raw_output}")
        return 1

    samples: dict[str, list[int]] = {}
    try:
        for line_number, line in enumerate(text.splitlines(), start=1):
            stripped = line.strip()
            if not stripped:
                continue
            parse_line(stripped, line_number, samples)
    except RuntimeError as exc:
        fail(str(exc))
        return 1
    if not samples:
        fail(f"benchmark output has no metrics: {raw_output}")
        return 1
    if len(samples) != corpus_files:
        fail(
            f"metric count {len(samples)} differs from corpus file count {corpus_files}"
        )
        return 1
    if compiled != corpus_files * iterations:
        fail(
            f"compiled count {compiled} differs from expected "
            f"{corpus_files * iterations}"
        )
        return 1

    results: dict[str, Any] = {}
    for name, values in sorted(samples.items()):
        if len(values) != iterations:
            fail(
                f"metric {name} has {len(values)} samples, expected {iterations}"
            )
            return 1
        median_ns = statistics.median(values)
        results[name] = {
            "source_name": name,
            "source_field": "elapsed_ns",
            "raw_value": median_ns,
            "raw_unit": "ns",
            "value": median_ns / 1.0e9,
            "unit": "s",
            "samples": len(values),
            "source_file": "benchmark_compile.txt",
        }

    runtime_context: dict[str, Any] = {
        "gcc_version_string": gcc_version_string,
        "compiled": compiled,
        "corpus_files": corpus_files,
        "iterations": iterations,
    }
    normalized = {
        "benchmark": "gcc_official_c_torture_compile_time",
        "software": "gcc",
        "version": version,
        "architecture": architecture,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "command": ["gcc", f"-{opt_level}", "-c", "<corpus-file>.c"],
            "corpus": "gcc/testsuite/gcc.c-torture/compile (official GCC source tree)",
            "opt_level": opt_level,
            "timing_backend": "time.monotonic_ns",
            "iterations": iterations,
            "compiled": compiled,
            "corpus_files": corpus_files,
        },
        "metric_contract": {
            "scope": "verbatim corpus file names from the official gcc c-torture suite",
            "source_fields": ["source-file-name", "elapsed_ns"],
            "raw_unit": "ns",
            "normalized_unit": "s",
            "direction": "lower_is_better",
            "aggregation": "median of repeated monotonic-clock measurements",
        },
        "runtime_context": runtime_context,
        "results": results,
    }

    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(normalized, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"[gcc-parse] normalized {len(results)} official corpus compile-time metrics")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
