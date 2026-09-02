#!/usr/bin/env python3
"""Normalize the official SPEC CPU2017 integer-rate result.

The GCC entry script preserves every file emitted by ``runcpu`` in the
``spec-results`` directory.  This parser reads the official text report and
extracts its suite-level ``SPECrate2017_int_base`` value.  That metric is the
SPEC-defined integer throughput ratio: higher values mean higher throughput.
"""

from __future__ import annotations

import json
import math
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


SCORE_RE = re.compile(r"SPECrate2017_int_base\s*=\s*([0-9]+(?:\.[0-9]+)?)")


def fail(message: str) -> None:
    print(f"[gcc-parse] ERROR: {message}", file=sys.stderr)


def find_score(result_directory: Path) -> tuple[float, Path]:
    reports = sorted(result_directory.glob("*intrate*.txt"))
    if not reports:
        raise RuntimeError("SPEC CPU2017 text result for intrate is missing")

    matches: list[tuple[float, Path]] = []
    for report in reports:
        text = report.read_text(encoding="utf-8", errors="replace")
        for value in SCORE_RE.findall(text):
            matches.append((float(value), report))
    if not matches:
        raise RuntimeError("SPEC text result has no SPECrate2017_int_base value")
    scores = {score for score, _ in matches}
    if len(scores) != 1:
        raise RuntimeError("SPEC text results contain conflicting SPECrate2017_int_base values")
    score, report = matches[0]
    if not math.isfinite(score) or score <= 0:
        raise RuntimeError("SPECrate2017_int_base must be positive and finite")
    return score, report


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "usage: parse_benchmark.py SPEC_RESULT_DIRECTORY NORMALIZED_OUTPUT",
            file=sys.stderr,
        )
        return 1

    result_directory = Path(sys.argv[1])
    normalized_output = Path(sys.argv[2])
    try:
        version = os.environ["SOFTWARE_VERSION"]
        architecture = os.environ["EXPECTED_ARCH"]
    except KeyError as exc:
        fail(f"missing environment variable: {exc}")
        return 1
    try:
        copies = int(os.environ["SPEC_COPIES"])
    except (KeyError, ValueError):
        fail("SPEC_COPIES must be a positive integer")
        return 1
    if copies <= 0:
        fail("SPEC_COPIES must be a positive integer")
        return 1
    if not result_directory.is_dir():
        fail(f"SPEC result directory does not exist: {result_directory}")
        return 1

    try:
        score, source_file = find_score(result_directory)
    except RuntimeError as exc:
        fail(str(exc))
        return 1

    result_name = "SPECrate2017_int_base"
    normalized: dict[str, Any] = {
        "benchmark": "spec_cpu2017_intrate",
        "software": "gcc",
        "version": version,
        "architecture": architecture,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "command": [
                "runcpu",
                "--config=gcc.cfg",
                "--rebuild",
                f"--copies={copies}",
                "-n",
                "1",
                "-S",
                "fastmath=0",
                "-S",
                "jemalloc=2mb",
                "-S",
                "hugepages=0",
                "intrate",
            ],
            "suite": "SPEC CPU2017 intrate",
            "copies": copies,
            "iterations": 1,
        },
        "metric_contract": {
            "scope": "official SPEC CPU2017 integer-rate suite score",
            "source_field": result_name,
            "unit": "ratio",
            "direction": "higher_is_better",
        },
        "runtime_context": {
            "gcc_version_string": os.environ.get("GCC_VERSION_STRING", ""),
        },
        "results": {
            result_name: {
                "source_name": result_name,
                "source_field": result_name,
                "raw_value": score,
                "raw_unit": "ratio",
                "value": score,
                "unit": "ratio",
                "source_file": str(source_file.relative_to(result_directory)),
            }
        },
    }
    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(normalized, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"[gcc-parse] normalized {result_name}={score}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
