#!/usr/bin/env python3
"""Parse the pinned upstream STREAM 5.10 console output into normalized metrics.

Every measured repetition is one unmodified ``./stream_200M`` run inside the
reference virtual machine.  The parser is strict on purpose: a missing repetition,
a missing kernel row, a wrong array size or a failed array validation aborts the
run instead of producing a partial result.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
import re
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path

KERNELS = ("Copy", "Scale", "Add", "Triad")
WARMUP_REPS = 1
MIN_MEASURED_REPS = 5
NUMBER = r"(?:\d+(?:\.\d*)?|\.\d+)"
VERSION = re.compile(r"STREAM version \$Revision:\s*(\S+)\s*\$")
ARRAY = re.compile(rf"^Array size =\s*(\d+) \(elements\), Offset =\s*(\d+) \(elements\)$")
THREADS = re.compile(r"^Number of Threads counted =\s*(\d+)$")
ITERATIONS = re.compile(r"^Each kernel will be executed (\d+) times\.")
HEADER = re.compile(r"^Function\s+Best Rate MB/s\s+Avg time\s+Min time\s+Max time$")
KERNEL = re.compile(
    rf"^({'|'.join(KERNELS)}):\s+({NUMBER})\s+({NUMBER})\s+({NUMBER})\s+({NUMBER})\s*$"
)
VALIDATED = re.compile(rf"^Solution Validates: avg error less than ({NUMBER}(?:[eE][-+]?\d+)?)")
FAILED = re.compile(r"^Failed Validation on array")


class ParseError(Exception):
    """A repetition does not contain a complete, valid STREAM result."""


def read_build_info(output_path: Path) -> dict[str, str]:
    """Read the ``# key: value`` lines the build stage leaves next to the result."""
    fields: dict[str, str] = {}
    info = output_path.parent / "build-info.txt"
    if not info.is_file():
        return fields
    for line in info.read_text(encoding="utf-8").splitlines():
        if not line.startswith("# ") or ":" not in line:
            continue
        key, _, value = line[2:].partition(":")
        fields[key.strip()] = value.strip()
    return fields


def positive(text: str, what: str) -> float:
    value = float(text)
    if not math.isfinite(value) or value <= 0:
        raise ParseError(f"{what} is not a positive finite number: {text}")
    return value


def read_repetition(path: Path, expected_array: int, expected_ntimes: int) -> dict:
    if not path.is_file():
        raise ParseError(f"missing STREAM repetition log: {path}")
    text = path.read_text(encoding="utf-8", errors="replace")
    version = None
    array_size = None
    threads = None
    iterations = None
    validation = None
    header_seen = False
    kernels: dict[str, dict[str, float]] = {}
    for line in text.splitlines():
        stripped = line.strip()
        if match := VERSION.search(stripped):
            version = match.group(1)
        elif match := ARRAY.match(stripped):
            array_size = int(match.group(1))
        elif match := THREADS.match(stripped):
            threads = int(match.group(1))
        elif match := ITERATIONS.match(stripped):
            iterations = int(match.group(1))
        elif HEADER.match(stripped):
            header_seen = True
        elif match := KERNEL.match(stripped):
            label = match.group(1)
            if label in kernels:
                raise ParseError(f"{path}: duplicated kernel row for {label}")
            kernels[label] = {
                "best_rate_mb_s": positive(match.group(2), f"{label} best rate"),
                "avg_time_s": positive(match.group(3), f"{label} average time"),
                "min_time_s": positive(match.group(4), f"{label} minimum time"),
                "max_time_s": positive(match.group(5), f"{label} maximum time"),
            }
        elif match := VALIDATED.match(stripped):
            validation = positive(match.group(1), "STREAM array validation tolerance")
        elif FAILED.match(stripped):
            raise ParseError(f"{path}: the upstream array validation failed")
    if version is None:
        raise ParseError(f"{path}: no STREAM version banner")
    if array_size != expected_array:
        raise ParseError(f"{path}: array size {array_size} does not match the pinned {expected_array}")
    if iterations != expected_ntimes:
        raise ParseError(f"{path}: NTIMES {iterations} does not match the pinned {expected_ntimes}")
    if threads is None or threads <= 0:
        raise ParseError(f"{path}: the number of OpenMP threads is missing")
    if not header_seen:
        raise ParseError(f"{path}: the STREAM result table header is missing")
    if set(kernels) != set(KERNELS):
        raise ParseError(f"{path}: incomplete kernel table, found {sorted(kernels)}")
    if validation is None:
        raise ParseError(f"{path}: the STREAM array validation line is missing")
    return {
        "version": version,
        "array_size": array_size,
        "ntimes": iterations,
        "threads": threads,
        "validation_tolerance": validation,
        "kernels": kernels,
    }


def collect(runs_dir: Path, reps: int, expected_array: int, expected_ntimes: int) -> list[dict]:
    if reps <= WARMUP_REPS + MIN_MEASURED_REPS - 1:
        raise ParseError(
            f"at least {WARMUP_REPS + MIN_MEASURED_REPS} repetitions are required, got {reps}"
        )
    samples = []
    for rep in range(1, reps + 1):
        samples.append(read_repetition(runs_dir / f"rep{rep}.log", expected_array, expected_ntimes))
    threads = {sample["threads"] for sample in samples}
    if len(threads) != 1:
        raise ParseError(f"the OpenMP thread count changed between repetitions: {sorted(threads)}")
    return samples


def build_metrics(samples: list[dict], expected_vcpus: int | None) -> tuple[dict, dict]:
    measured = samples[WARMUP_REPS:]
    if len(measured) < MIN_MEASURED_REPS:
        raise ParseError(
            f"{len(measured)} measured repetitions found, at least {MIN_MEASURED_REPS} are required"
        )
    threads = measured[0]["threads"]
    if expected_vcpus is not None and threads != expected_vcpus:
        raise ParseError(
            f"STREAM used {threads} threads but the reference VM has {expected_vcpus} vCPU"
        )
    results: dict[str, dict] = {}
    for kernel in KERNELS:
        group = kernel.lower()
        best = statistics.median(sample["kernels"][kernel]["best_rate_mb_s"] for sample in measured)
        average = statistics.median(sample["kernels"][kernel]["avg_time_s"] for sample in measured)
        results[f"stream.{group}.best_rate"] = {
            "source_name": f"{kernel} best rate",
            "source_column": f"{kernel}: Best Rate MB/s",
            "value": round(best, 3),
            "unit": "MB/s",
            "direction": "higher_is_better",
            "group": group,
        }
        results[f"stream.{group}.avg_time"] = {
            "source_name": f"{kernel} average time",
            "source_column": f"{kernel}: Avg time",
            "value": round(average, 6),
            "unit": "s",
            "direction": "lower_is_better",
            "group": group,
        }
    results["stream.array.size"] = {
        "source_name": "Array size",
        "source_column": "Array size = N (elements)",
        "value": measured[0]["array_size"],
        "unit": "elements",
        "direction": "neutral",
        "group": "workload",
    }
    results["stream.kernel.iterations"] = {
        "source_name": "Iterations per kernel",
        "source_column": "Each kernel will be executed N times.",
        "value": measured[0]["ntimes"],
        "unit": "iterations",
        "direction": "neutral",
        "group": "workload",
    }
    results["stream.threads"] = {
        "source_name": "OpenMP threads",
        "source_column": "Number of Threads counted = N",
        "value": threads,
        "unit": "threads",
        "direction": "neutral",
        "group": "workload",
    }
    per_rep = {
        f"rep{index + WARMUP_REPS + 1}": {
            "kernels": sample["kernels"],
            "threads": sample["threads"],
        }
        for index, sample in enumerate(measured)
    }
    return results, per_rep


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runs-dir", required=True)
    parser.add_argument("--reps", required=True, type=int)
    parser.add_argument("--output", required=True)
    parser.add_argument("--raw-log", default="")
    parser.add_argument("--array-size", type=int, default=int(os.environ.get("STREAM_ARRAY_SIZE", 200000000)))
    parser.add_argument("--ntimes", type=int, default=int(os.environ.get("STREAM_NTIMES", 10)))
    args = parser.parse_args()

    version = os.environ["SOFTWARE_VERSION"]
    architecture = os.environ["EXPECTED_ARCH"]
    expected_vcpus = int(os.environ["STREAM_VM_VCPUS"]) if os.environ.get("STREAM_VM_VCPUS") else None
    try:
        samples = collect(Path(args.runs_dir), args.reps, args.array_size, args.ntimes)
        results, per_rep = build_metrics(samples, expected_vcpus)
    except ParseError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 2

    raw_log = Path(args.raw_log) if args.raw_log else None
    accelerator = os.environ.get("STREAM_VM_ACCEL_USED", "kvm")
    build_info = read_build_info(Path(args.output))
    parameters = {
        "command": "./stream_200M",
        "compile_flags": build_info.get(
            "compile_flags",
            f"-O3 -fopenmp -DSTREAM_ARRAY_SIZE={args.array_size}"
            f" -DNTIMES={args.ntimes} -mcmodel=large",
        ),
        "array_size": args.array_size,
        "ntimes": args.ntimes,
        "execution_environment": "kvm-vm" if accelerator == "kvm" else f"{accelerator}-vm",
        "accelerator": accelerator,
        "repetitions_total": args.reps,
        "repetitions_warmup": WARMUP_REPS,
        "repetitions_measured": args.reps - WARMUP_REPS,
        "statistic": "median-of-repetitions",
        "memory_unit": "1 MB = 10^6 bytes (upstream STREAM convention)",
    }
    for key, name in (
        ("compile_flags_upstream", "compile_flags_upstream"),
        ("compile_extra_flags", "compile_extra_flags"),
    ):
        value = build_info.get(key)
        if value and value != "none":
            parameters[name] = value
    for key, name in (
        ("STREAM_VM_CORES_USED", "cores"),
        ("STREAM_VM_THREADS_PER_CORE", "threads_per_core"),
        ("STREAM_VM_MEM_MIB", "memory_mib"),
        ("STREAM_VM_HUGEPAGES_ENABLED", "hugepages"),
        ("STREAM_VM_NUMA_NODE", "numa_node"),
    ):
        value = os.environ.get(key)
        if value:
            parameters[name] = value
    payload = {
        "benchmark": "stream_memory_bandwidth",
        "software": "stream",
        "version": version,
        "architecture": architecture,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": parameters,
        "samples": {
            "total": args.reps,
            "warmup": WARMUP_REPS,
            "measured": args.reps - WARMUP_REPS,
            "vcpus": samples[0]["threads"],
            "validation_tolerance": samples[0]["validation_tolerance"],
            "measured_reps": per_rep,
        },
        "results": results,
    }
    if raw_log is not None and raw_log.is_file():
        digest = hashlib.sha256(raw_log.read_bytes()).hexdigest()
        payload["raw_log"] = {"name": raw_log.name, "sha256": digest, "bytes": raw_log.stat().st_size}
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"[stream] normalized {len(results)} metrics from {args.reps} repetitions", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
