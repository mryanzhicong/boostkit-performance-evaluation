#!/usr/bin/env python3
"""Parse the complete, unmodified UnixBench 6.0.1 system-index report."""

from __future__ import annotations

import json
import math
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path


TESTS = (
    "Dhrystone 2 using register variables",
    "Double-Precision Whetstone",
    "Execl Throughput",
    "File Copy 1024 bufsize 2000 maxblocks",
    "File Copy 256 bufsize 500 maxblocks",
    "File Copy 4096 bufsize 8000 maxblocks",
    "Pipe Throughput",
    "Pipe-based Context Switching",
    "Process Creation",
    "System Call Overhead",
    "Shell Scripts (1 concurrent)",
    "Shell Scripts (8 concurrent)",
)
NUMBER = r"(?:\d+(?:\.\d*)?|\.\d+)"
PASS = re.compile(r"^\s*(\d+) CPUs? in system; running (\d+) parallel cop(?:y|ies) of tests$")
RAW = re.compile(rf"^(.+?)\s+({NUMBER})\s+(\S+)\s+\(({NUMBER}) s, (\d+) samples\)$")
INDEX = re.compile(rf"^(.+?)\s+({NUMBER})\s+({NUMBER})\s+({NUMBER})$")
SCORE = re.compile(rf"^System Benchmarks Index Score\s+({NUMBER})$")


def positive(text: str) -> float:
    value = float(text)
    if not math.isfinite(value) or value <= 0:
        raise ValueError(f"non-positive or non-finite UnixBench measurement: {text}")
    return value


REFERENCE_VCPUS = 32


def parse_report(report: str, version: str, architecture: str, expected_copies: int | None = None) -> dict:
    if not re.search(r"BYTE UNIX Benchmarks \(Version 6\.0\.1\)", report):
        raise ValueError("not an official UnixBench 6.0.1 report")
    segments = re.split(r"(?=^Benchmark Run: )", report, flags=re.MULTILINE)
    passes = [part for part in segments if part.startswith("Benchmark Run: ")]
    if len(passes) != 2:
        raise ValueError(f"official ./Run must have two complete passes; found {len(passes)}")
    results: dict[str, dict] = {}
    copy_counts = []
    system_cpu_counts = []
    for part in passes:
        lines = part.splitlines()
        pass_matches = [match for line in lines if (match := PASS.match(line.strip()))]
        if len(pass_matches) != 1:
            raise ValueError("pass does not identify exactly one CPU and copy count")
        system_cpus, copies = (int(value) for value in pass_matches[0].groups())
        if system_cpus < 1 or copies < 1 or copies in copy_counts:
            raise ValueError("invalid or repeated UnixBench copy count")
        copy_counts.append(copies)
        system_cpu_counts.append(system_cpus)
        group = f"{copies} copy" if copies == 1 else f"{copies} copies"
        if "System Benchmarks Partial Index" in part or "(Partial Only)" in part:
            raise ValueError("UnixBench produced only a partial index")
        if "System Benchmarks Index Values" not in part:
            raise ValueError("complete system-index table is missing")
        raw: dict[str, float] = {}
        indexed: dict[str, tuple[float, float]] = {}
        in_index = False
        for line in lines:
            if line.startswith("System Benchmarks Index Values"):
                in_index = True
                continue
            if not in_index:
                match = RAW.match(line.strip())
                if match and match.group(1) in TESTS:
                    label, value, _, _, _ = match.groups()
                    if label in raw:
                        raise ValueError(f"duplicate raw result: {label}")
                    raw[label] = positive(value)
            else:
                match = INDEX.match(line.strip())
                if match and match.group(1) in TESTS:
                    label, baseline, value, index = match.groups()
                    if label in indexed:
                        raise ValueError(f"duplicate index result: {label}")
                    indexed[label] = (positive(value), positive(index))
                    positive(baseline)
        if set(raw) != set(TESTS) or set(indexed) != set(TESTS):
            raise ValueError(f"incomplete UnixBench index for {group}: raw={len(raw)}, index={len(indexed)}")
        scores = [positive(match.group(1)) for line in lines if (match := SCORE.match(line.strip()))]
        if len(scores) != 1:
            raise ValueError(f"complete UnixBench index score is missing for {group}")
        for label in TESTS:
            raw_value = raw[label]
            indexed_value, index_value = indexed[label]
            if abs(raw_value - indexed_value) > max(0.11, raw_value * 0.000001):
                raise ValueError(f"raw and indexed scores disagree for {label}")
            key = f"{group}/{label}"
            results[f"{key}/index"] = {
                "source_name": f"{label} — index", "source_metric": label,
                "value": index_value, "unit": "index", "direction": "higher_is_better", "group": group,
            }
        results[f"{group}/System Benchmarks Index Score"] = {
            "source_name": "System Benchmarks Index Score", "source_metric": "System Benchmarks Index Score",
            "value": scores[0], "unit": "index", "direction": "higher_is_better", "group": group,
        }
    if copy_counts[0] != 1 or copy_counts[1] != system_cpu_counts[1] or system_cpu_counts[0] != system_cpu_counts[1]:
        raise ValueError("./Run did not use one copy followed by the detected CPU count")
    required_copies = REFERENCE_VCPUS if expected_copies is None else expected_copies
    if system_cpu_counts[1] != required_copies:
        raise ValueError(
            f"reference VM must run {required_copies} parallel copies, found {system_cpu_counts[1]}"
        )
    return {
        "benchmark": "unixbench_system_index", "software": "unixbench",
        "version": version, "architecture": architecture,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {"command": "./Run", "suite": "index", "copy_selection": "automatic",
                       "iteration_policy": "upstream-default", "execution_environment": "kvm-vm",
                       "vm_vcpus": REFERENCE_VCPUS, "vm_memory_gib": 64,
                       "huge_page_size_kb": 2048, "cpu_pinning": "1:1-host-numa-node"},
        "runtime_context": {"system_cpus": system_cpu_counts[0], "copy_counts": copy_counts},
        "results": results,
    }


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: parse_benchmark.py OFFICIAL_REPORT OUTPUT_JSON", file=sys.stderr)
        return 2
    report_path, output_path = (Path(value) for value in sys.argv[1:])
    report = report_path.read_text(encoding="utf-8", errors="replace")
    payload = parse_report(report, os.environ["SOFTWARE_VERSION"], os.environ["EXPECTED_ARCH"])
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"[unixbench] normalized {len(payload['results'])} official metrics", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
