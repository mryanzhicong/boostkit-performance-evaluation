#!/usr/bin/env python3
"""Run Zstd's official fullbench executable and preserve every reported scenario."""

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


CORE_SCENARIOS = {
    "compress": "compress",
    "decompress": "decompress",
    "compressStream": "compress_stream",
    "decompressStream": "decompress_stream",
}
RESULT_PATTERN = re.compile(
    r"(?:^|[\r\n])\s*(\d+)#([^:\r\n]+?)\s*:\s*"
    r"([0-9]+(?:\.[0-9]+)?)\s+MB/s\s+\(\s*(\d+)\s*\)"
)
WELCOME_PATTERN = re.compile(r"Zstandard speed analyzer\s+([0-9]+(?:\.[0-9]+){2})")
SAMPLE_PATTERN = re.compile(r"Sample\s+(\d+)\s+bytes")


def parse_output(output: str) -> tuple[str, int, dict[str, dict[str, Any]]]:
    version_match = WELCOME_PATTERN.search(output)
    sample_match = SAMPLE_PATTERN.search(output)
    if not version_match or not sample_match:
        raise RuntimeError("fullbench output is missing its version or sample size")

    latest: dict[tuple[int, str], tuple[float, int]] = {}
    for scenario_id, raw_name, raw_speed, raw_return_value in RESULT_PATTERN.findall(output):
        name = raw_name.strip()
        speed = float(raw_speed)
        return_value = int(raw_return_value)
        if not math.isfinite(speed) or speed <= 0:
            raise RuntimeError(f"fullbench scenario {name} returned an invalid speed")
        latest[(int(scenario_id), name)] = (speed, return_value)

    if not latest:
        raise RuntimeError("fullbench output contains no performance results")

    by_name = {name: values for (_scenario_id, name), values in latest.items()}
    missing = sorted(set(CORE_SCENARIOS) - set(by_name))
    if missing:
        raise RuntimeError(f"fullbench output is missing core scenarios: {', '.join(missing)}")

    results: dict[str, dict[str, Any]] = {}
    for (scenario_id, name), (speed, return_value) in sorted(latest.items()):
        result_name = CORE_SCENARIOS.get(name, f"scenario_{scenario_id}")
        if result_name in results:
            raise RuntimeError(f"fullbench produced duplicate result key: {result_name}")
        results[result_name] = {
            "scenario_id": scenario_id,
            "scenario": name,
            "speed_mbs": speed,
            "return_value": return_value,
        }
    return version_match.group(1), int(sample_match.group(1)), results


def run_fullbench(fullbench: Path) -> str:
    command = [str(fullbench)]
    print(f"[fullbench] {' '.join(command)}", flush=True)
    completed = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=1800,
        check=False,
    )
    print(completed.stdout, end="", flush=True)
    if completed.returncode:
        raise RuntimeError(f"fullbench exited with code {completed.returncode}")
    return completed.stdout


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: run_fullbench.py FULLBENCH OUTPUT", file=sys.stderr)
        return 1
    fullbench, output = map(Path, sys.argv[1:])
    if not fullbench.is_file() or not os.access(fullbench, os.X_OK):
        raise RuntimeError(f"fullbench executable is unavailable: {fullbench}")

    raw_output = run_fullbench(fullbench)
    actual_version, sample_size, results = parse_output(raw_output)
    requested_version = os.environ["SOFTWARE_VERSION"]
    if actual_version != requested_version:
        raise RuntimeError(
            f"fullbench version {actual_version} differs from requested {requested_version}"
        )
    payload = {
        "benchmark": "zstd_fullbench",
        "software": "zstd",
        "version": actual_version,
        "architecture": os.environ["EXPECTED_ARCH"],
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "command": [str(fullbench)],
            "sample_size_bytes": sample_size,
            "fullbench_defaults": True,
        },
        "results": results,
        "raw_output": raw_output,
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
