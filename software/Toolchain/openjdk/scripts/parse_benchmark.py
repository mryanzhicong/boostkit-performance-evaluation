#!/usr/bin/env python3
"""Normalize one official jtreg run into the framework metric schema."""

from __future__ import annotations

import json
import math
import os
import sys
from datetime import datetime, timezone
from pathlib import Path


def fail(message: str) -> None:
    print(f"[openjdk-parse] ERROR: {message}", file=sys.stderr)


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "usage: parse_benchmark.py JTREG_OUTPUT NORMALIZED_OUTPUT ELAPSED_SECONDS",
            file=sys.stderr,
        )
        return 1
    raw_output = Path(sys.argv[1])
    normalized_output = Path(sys.argv[2])
    try:
        elapsed_seconds = float(sys.argv[3])
    except ValueError:
        fail(f"jtreg elapsed time is not numeric: {sys.argv[3]!r}")
        return 1
    if not math.isfinite(elapsed_seconds) or elapsed_seconds <= 0:
        fail(f"jtreg elapsed time must be positive: {elapsed_seconds!r}")
        return 1
    try:
        version = os.environ["SOFTWARE_VERSION"]
        architecture = os.environ["EXPECTED_ARCH"]
        jtreg_version = os.environ["JTREG_VERSION"]
        test_roots = os.environ["JTREG_TEST_ROOTS"].split()
    except KeyError as exc:
        fail(f"missing environment variable: {exc}")
        return 1
    if not test_roots:
        fail("JTREG_TEST_ROOTS must declare at least one test root")
        return 1
    if not raw_output.is_file() or not raw_output.stat().st_size:
        fail(f"jtreg output is missing or empty: {raw_output}")
        return 1
    normalized = {
        "benchmark": "openjdk_official_jtreg",
        "software": "openjdk",
        "version": version,
        "architecture": architecture,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "command": [
                "jtreg",
                "-va",
                "-ignore:quiet",
                "-jit",
                "-conc:auto",
                "-timeout:5",
                "-tl:3590",
                *test_roots,
            ],
            "jtreg_version": jtreg_version,
            "test_roots": test_roots,
            "benchmark_suite": "OpenJDK jtreg regression test suite",
        },
        "metric_contract": {
            "scope": "one complete jtreg invocation",
            "source_field": "external wall-clock elapsed seconds",
            "unit": "s",
            "direction": "lower_is_better",
        },
        "results": {
            "jtreg elapsed time": {
                "source_name": "jtreg elapsed time",
                "source_field": "external wall-clock elapsed seconds",
                "value": elapsed_seconds,
                "unit": "s",
                "source_file": raw_output.name,
            }
        },
    }
    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(normalized, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"[openjdk-parse] normalized jtreg elapsed time: {elapsed_seconds:.0f}s")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
