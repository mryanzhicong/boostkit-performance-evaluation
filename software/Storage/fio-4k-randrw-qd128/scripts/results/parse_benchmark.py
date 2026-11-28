#!/usr/bin/env python3
"""Parse the fio console output of every repetition into normalized metrics.

Each repetition is one unmodified run of

    cd /root/fio && taskset -c 0 fio randrw_4k.fio

inside the reference virtual machine.  The parser is strict: it verifies the fio
version, the job layout (rw/bs/iodepth/numjobs), the run error count, the
effective run time and the presence of both the read and the write report, and it
aborts instead of emitting a partial result.
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

WARMUP_REPS = 1
MIN_MEASURED_REPS = 5
IO_SUFFIX = {"": 1.0, "k": 1e3, "K": 1e3, "M": 1e6, "G": 1e9}
BW_SUFFIX = {"": 1024 ** 0, "K": 1024 ** 1, "M": 1024 ** 2, "G": 1024 ** 3}

VERSION = re.compile(r"^fio-(\d+\.\d+)$")
STARTING = re.compile(r"^Starting (\d+) threads?$")
JOB_HEADER = re.compile(
    r"^(\S+): \(g=0\): rw=(\w+), bs=\(R\) (\d+)B-(\d+)B, \(W\) (\d+)B-\d+B, "
    r"\(T\) \d+B-\d+B, ioengine=(\w+), iodepth=(\d+)$"
)
RESULT = re.compile(r"^(\S+): \(groupid=(\d+), jobs=(\d+)\): err=\s*(\d+):")
IO_LINE = re.compile(
    r"^\s{2}(read|write): IOPS=([0-9.]+)([kKMG]?), BW=([0-9.]+)([kKMG]?)iB/s "
    r".*?\([0-9.]+[KMG]?iB/(\d+)msec\)"
)
# min/max carry an optional k/M suffix and fractional digits on slow devices:
#   clat (nsec): min=570, max=3554.9k, avg=27316.33, stdev=3012.76
CLAT_AVG = re.compile(
    r"^\s{4}clat \((nsec|usec|msec)\): "
    r"min=[0-9.]+[kKmMgG]?, max=[0-9.]+[kKmMgG]?, avg=([0-9.]+)"
)
# fio prints the percentile table in usec, but switches to nsec or msec when the
# latency distribution makes that more readable.
CLAT_PCT_HEADER = re.compile(r"^\s{4}clat percentiles \((nsec|usec|msec)\):$")
LATENCY_SCALE_US = {"nsec": 0.001, "usec": 1.0, "msec": 1000.0}
PCT = re.compile(r"([0-9.]+)th=\[\s*([0-9.]+)\]")


class ParseError(Exception):
    """A repetition does not contain a complete, valid fio result."""


def to_bytes_per_second(value: str, suffix: str) -> float:
    return float(value) * BW_SUFFIX[suffix]


def parse_clat_block(lines: list[str], start: int) -> tuple[float, dict[float, float]]:
    """Return (avg_usec, percentiles) for the direction block starting at ``start``."""
    average = None
    percentiles: dict[float, float] = {}
    index = start
    while index < len(lines) and index < start + 60:
        line = lines[index]
        if average is None:
            match = CLAT_AVG.match(line)
            if match:
                average = float(match.group(2)) * LATENCY_SCALE_US[match.group(1)]
        match = CLAT_PCT_HEADER.match(line)
        if match:
            scale = LATENCY_SCALE_US[match.group(1)]
            index += 1
            while index < len(lines) and lines[index].strip().startswith("|"):
                for pct, value in PCT.findall(lines[index]):
                    percentiles[float(pct)] = float(value) * scale
                index += 1
            continue
        if IO_LINE.match(line) and index != start:
            break
        index += 1
    if average is None:
        raise ParseError("the completion-latency line is missing")
    if 99.0 not in percentiles:
        raise ParseError(
            "the 99th completion-latency percentile is missing "
            f"(parsed percentiles: {sorted(percentiles)})"
        )
    return average, percentiles


def parse_repetition(path: Path, expected: dict) -> dict:
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()

    version = None
    for line in lines:
        match = VERSION.match(line.strip())
        if match:
            version = match.group(1)
            break
    if version is None:
        raise ParseError("the fio version banner is missing")
    if version != expected["version"]:
        raise ParseError(f"fio reports version {version}, expected {expected['version']}")

    threads = None
    for line in lines:
        match = STARTING.match(line.strip())
        if match:
            threads = int(match.group(1))
            break
    if threads != expected["numjobs"]:
        raise ParseError(f"fio started {threads} threads, expected {expected['numjobs']}")

    header = None
    for line in lines:
        match = JOB_HEADER.match(line.strip())
        if match:
            header = match
            break
    if header is None:
        raise ParseError("the job description line is missing")
    rw, bs_read, bs_write, engine, iodepth = (
        header.group(2),
        int(header.group(3)),
        int(header.group(5)),
        header.group(6),
        int(header.group(7)),
    )
    if rw != expected["rw"]:
        raise ParseError(f"the job uses rw={rw}, expected {expected['rw']}")
    if bs_read != expected["block_size_bytes"] or bs_write != expected["block_size_bytes"]:
        raise ParseError(f"the job uses bs={bs_read}/{bs_write}, expected {expected['block_size_bytes']}")
    if engine != "libaio":
        raise ParseError(f"the job uses ioengine={engine}, expected libaio")
    if iodepth != expected["iodepth"]:
        raise ParseError(f"the job uses iodepth={iodepth}, expected {expected['iodepth']}")

    result = None
    for line in lines:
        match = RESULT.match(line.strip())
        if match:
            result = match
            break
    if result is None:
        raise ParseError("the aggregated result line is missing")
    job_error = int(result.group(4))
    if job_error != 0:
        raise ParseError(f"fio reported {job_error} errors")
    if int(result.group(3)) != expected["numjobs"]:
        raise ParseError(f"the report covers {result.group(3)} jobs, expected {expected['numjobs']}")

    directions: dict[str, dict] = {}
    for index, line in enumerate(lines):
        match = IO_LINE.match(line)
        if not match:
            continue
        direction = match.group(1)
        duration_ms = int(match.group(6))
        average, percentiles = parse_clat_block(lines, index)
        directions[direction] = {
            "iops": float(match.group(2)) * IO_SUFFIX[match.group(3)],
            "bw_mib_s": to_bytes_per_second(match.group(4), match.group(5)) / (1024 ** 2),
            "clat_avg_us": average,
            "clat_p99_us": percentiles[99.0],
            "duration_ms": duration_ms,
        }
    if "read" not in directions or "write" not in directions:
        raise ParseError("the random read/write report is incomplete")

    for direction in ("read", "write"):
        sample = directions[direction]
        if sample["iops"] <= 0 or sample["bw_mib_s"] <= 0:
            raise ParseError(f"the {direction} throughput is not positive")
    runtime_ms = expected["runtime_seconds"] * 1000
    for direction in ("read", "write"):
        duration_ms = directions[direction]["duration_ms"]
        if duration_ms < runtime_ms * 0.98 or duration_ms > runtime_ms * 1.25:
            raise ParseError(
                f"the {direction} run lasted {duration_ms} msec, expected about {runtime_ms} msec"
            )
    return directions


def collect(runs_dir: Path, reps: int, expected: dict) -> list[dict]:
    samples = []
    for rep in range(1, reps + 1):
        log = runs_dir / f"rep{rep}.log"
        if not log.is_file():
            raise ParseError(f"repetition {rep} is missing ({log.name})")
        samples.append(parse_repetition(log, expected))
    if len(samples) < WARMUP_REPS + MIN_MEASURED_REPS:
        raise ParseError("not enough measured repetitions")
    return samples


def metric(value: float, unit: str, direction: str, group: str, digits: int) -> dict:
    if not math.isfinite(value) or value <= 0:
        raise ParseError("a measured value is not a finite positive number")
    return {
        "value": round(value, digits),
        "unit": unit,
        "direction": direction,
        "group": group,
    }


def median_metric(samples: list[float]) -> float:
    return statistics.median(samples)


def build_metrics(samples: list[dict]) -> tuple[dict, dict]:
    measured = samples[WARMUP_REPS:]
    per_rep = {}
    for offset, sample in enumerate(measured):
        per_rep[f"rep{offset + 2}"] = {
            direction: {
                "iops": round(values["iops"], 1),
                "bw_mib_s": round(values["bw_mib_s"], 1),
                "clat_avg_us": round(values["clat_avg_us"], 2),
                "clat_p99_us": round(values["clat_p99_us"], 2),
                "duration_ms": values["duration_ms"],
            }
            for direction, values in sample.items()
        }

    results = {}
    for direction in ("read", "write"):
        iops = [sample[direction]["iops"] for sample in measured]
        bw = [sample[direction]["bw_mib_s"] for sample in measured]
        avg = [sample[direction]["clat_avg_us"] for sample in measured]
        p99 = [sample[direction]["clat_p99_us"] for sample in measured]
        results[f"fio.{direction}.iops"] = metric(
            median_metric(iops), "IOPS", "higher_is_better", direction, 1
        )
        results[f"fio.{direction}.bw_mib"] = metric(
            median_metric(bw), "MiB/s", "higher_is_better", direction, 1
        )
        results[f"fio.{direction}.clat_avg_us"] = metric(
            median_metric(avg), "us", "lower_is_better", direction, 2
        )
        results[f"fio.{direction}.clat_p99_us"] = metric(
            median_metric(p99), "us", "lower_is_better", direction, 2
        )
    return results, per_rep


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runs-dir", required=True)
    parser.add_argument("--reps", required=True, type=int)
    parser.add_argument("--output", required=True)
    parser.add_argument("--raw-log", default="")
    args = parser.parse_args()

    version = os.environ["SOFTWARE_VERSION"]
    architecture = os.environ["EXPECTED_ARCH"]
    block_size = os.environ.get("FIO_BLOCK_SIZE", "4k")
    block_size_bytes = int(block_size[:-1]) * 1024 if block_size.lower().endswith("k") else int(block_size)
    expected = {
        "version": version,
        "numjobs": int(os.environ.get("FIO_NUMJOBS", "1")),
        "iodepth": int(os.environ.get("FIO_IODEPTH", "1")),
        "rw": os.environ.get("FIO_RW", "randrw"),
        "block_size_bytes": block_size_bytes,
        "runtime_seconds": int(os.environ.get("FIO_RUNTIME", "600")),
    }
    try:
        samples = collect(Path(args.runs_dir), args.reps, expected)
        results, per_rep = build_metrics(samples)
    except ParseError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 2

    raw_log = Path(args.raw_log) if args.raw_log else None
    accelerator = os.environ.get("FIO_VM_ACCEL_USED", "kvm")
    parameters = {
        "command": f"taskset -c 0 fio {os.environ.get('FIO_GUEST_JOB', 'randrw_4k.fio')}",
        "job_file": os.environ.get("FIO_GUEST_JOB", "randrw_4k.fio"),
        "workload": {
            "rw": expected["rw"],
            "block_size": block_size,
            "numjobs": expected["numjobs"],
            "iodepth": expected["iodepth"],
            "rwmixwrite": int(os.environ.get("FIO_RWMIXWRITE", "30")),
            "rwmixread": int(os.environ.get("FIO_RWMIXREAD", "70")),
            "ramp_time_seconds": int(os.environ.get("FIO_RAMP_TIME", "300")),
            "runtime_seconds": expected["runtime_seconds"],
            "time_based": True,
        },
        "execution_environment": "kvm-vm" if accelerator == "kvm" else f"{accelerator}-vm",
        "accelerator": accelerator,
        "repetitions_total": args.reps,
        "repetitions_warmup": WARMUP_REPS,
        "repetitions_measured": args.reps - WARMUP_REPS,
        "statistic": "median-of-repetitions",
    }
    for key, name in (
        ("FIO_LV_COUNT", "logical_volumes"),
        ("FIO_LV_SIZE_GIB", "logical_volume_size_gib"),
    ):
        value = os.environ.get(key)
        if value:
            parameters[name] = value

    results["fio.numjobs"] = {
        "value": expected["numjobs"], "unit": "jobs", "direction": "neutral", "group": "workload"
    }
    results["fio.iodepth"] = {
        "value": expected["iodepth"], "unit": "queue_depth", "direction": "neutral", "group": "workload"
    }
    results["fio.block_size_kib"] = {
        "value": block_size_bytes // 1024, "unit": "KiB", "direction": "neutral", "group": "workload"
    }
    results["fio.runtime_seconds"] = {
        "value": expected["runtime_seconds"], "unit": "s", "direction": "neutral", "group": "workload"
    }

    payload = {
        "benchmark": "fio_4k_random_read_write",
        "software": "fio",
        "version": version,
        "architecture": architecture,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": parameters,
        "samples": {
            "total": args.reps,
            "warmup": WARMUP_REPS,
            "measured": args.reps - WARMUP_REPS,
            "numjobs": expected["numjobs"],
            "iodepth": expected["iodepth"],
            "measured_reps": per_rep,
        },
        "results": results,
    }
    if raw_log is not None and raw_log.is_file():
        payload["raw_log"] = {
            "name": raw_log.name,
            "sha256": hashlib.sha256(raw_log.read_bytes()).hexdigest(),
            "bytes": raw_log.stat().st_size,
        }
    Path(args.output).write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"normalized {len(results)} metrics from {args.reps} repetitions")
    return 0


if __name__ == "__main__":
    sys.exit(main())
