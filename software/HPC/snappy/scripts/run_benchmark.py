#!/usr/bin/env python3
"""Run Snappy's documented benchmark command and normalize every throughput."""

from __future__ import annotations

import json
import math
import os
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


RESULT_PATTERN = re.compile(
    r"^\s*(BM_\S+).*?\bbytes_per_second="
    r"([0-9]+(?:\.[0-9]+)?(?:[eE][+-]?[0-9]+)?)"
    r"(Ki|Mi|Gi|Ti|k|M|G|T|)/s"
    r"(?:\s+(.*?))?\s*$"
)
UNIT_TO_MIB_PER_SECOND = {
    "": 1 / (1024 * 1024),
    "k": 1_000 / (1024 * 1024),
    "M": 1_000_000 / (1024 * 1024),
    "G": 1_000_000_000 / (1024 * 1024),
    "T": 1_000_000_000_000 / (1024 * 1024),
    "Ki": 1 / 1024,
    "Mi": 1.0,
    "Gi": 1024.0,
    "Ti": 1024.0 * 1024.0,
}


def normalize_results(output: str) -> dict[str, dict[str, Any]]:
    results: dict[str, dict[str, Any]] = {}
    for line in output.splitlines():
        match = RESULT_PATTERN.match(line)
        if not match:
            continue
        run_name, raw_value, unit_prefix, raw_label = match.groups()
        if any(result["run_name"] == run_name for result in results.values()):
            raise RuntimeError(f"official benchmark produced duplicate result: {run_name}")
        value = float(raw_value) * UNIT_TO_MIB_PER_SECOND[unit_prefix]
        if not math.isfinite(value) or value <= 0:
            raise RuntimeError(f"benchmark {run_name} has invalid throughput")
        label = (raw_label or "").strip()
        scenario = run_name
        if label:
            scenario = f"{run_name} [{label}]"
        result_key = f"scenario_{len(results):03d}"
        results[result_key] = {
            "scenario": scenario,
            "run_name": run_name,
            "label": label,
            "source_metric": "bytes_per_second",
            "throughput_mib_per_second": round(value, 6),
        }

    if not results:
        raise RuntimeError("official benchmark output contains no throughput results")
    return results


def run_benchmark(source_dir: Path, raw_output: Path) -> str:
    command = ["./build/snappy_benchmark"]
    print("[snappy-benchmark] cd SOURCE_DIR && ./build/snappy_benchmark", flush=True)
    completed = subprocess.run(
        command,
        cwd=source_dir,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=3600,
        check=False,
    )
    print(completed.stdout, end="", flush=True)
    if completed.returncode:
        raise RuntimeError(f"snappy_benchmark exited with code {completed.returncode}")
    if not completed.stdout.strip():
        raise RuntimeError("snappy_benchmark produced no output")
    raw_output.parent.mkdir(parents=True, exist_ok=True)
    raw_output.write_text(completed.stdout, encoding="utf-8")
    return completed.stdout


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "usage: run_benchmark.py SOURCE_DIR RAW_OUTPUT NORMALIZED_OUTPUT",
            file=sys.stderr,
        )
        return 1
    source_dir, raw_output, normalized_output = map(Path, sys.argv[1:])
    binary = source_dir / "build" / "snappy_benchmark"
    if not binary.is_file() or not os.access(binary, os.X_OK):
        raise RuntimeError(f"official snappy_benchmark is unavailable: {binary}")
    if not source_dir.is_dir():
        raise RuntimeError(f"Snappy source directory is unavailable: {source_dir}")

    official_output = run_benchmark(source_dir, raw_output)
    results = normalize_results(official_output)

    version = os.environ["SOFTWARE_VERSION"]
    architecture = os.environ["EXPECTED_ARCH"]
    normalized = {
        "benchmark": "snappy_official_benchmark",
        "software": "snappy",
        "version": version,
        "architecture": architecture,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "command": ["./build/snappy_benchmark"],
            "build_type": "Release",
            "official_defaults": True,
            "official_testdata": True,
        },
        "metric_contract": {
            "scope": "every official benchmark scenario",
            "source_field": "bytes_per_second",
            "normalized_unit": "MiB/s",
            "direction": "higher_is_better",
        },
        "runtime_context": {
            "scenario_count": len(results),
        },
        "results": results,
    }
    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(normalized, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"[snappy-benchmark] normalized {len(results)} official scenarios")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
