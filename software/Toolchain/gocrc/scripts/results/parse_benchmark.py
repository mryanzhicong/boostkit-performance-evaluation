#!/usr/bin/env python3
"""Validate and normalize the gocrc 1.24.6 CRC32 Castagnoli microbenchmark results.

The test stage runs the pinned benchmark inside the private container with the
openEuler golang go1.24.6 toolchain built at /home/local/golang, then summarises
the samples with benchstat:

    go test hash/crc32 -run='^$' \\
        -bench='CRC32/poly=Castagnoli/size=(4|32)kB' -cpu=1 -count=6
    benchstat benchmark_go1.24.6.txt

Go 1.24 emits four leaf benchmarks (4 kB / 32 kB x align=0 / align=1); older
releases without the align dimension emit two.  This parser requires exactly one
complete set with exactly ``--reps`` samples per entry and refuses anything else:
missing samples, extra samples, unexpected benchmark names, non-positive values
and a missing/empty benchstat report all fail the case instead of being
zero-padded or silently skipped.

Metrics: per scenario the measured median ns/op (lower is better).
"""

from __future__ import annotations

import argparse
import json
import math
import re
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import NoReturn

BENCH_LINE = re.compile(
    r"^BenchmarkCRC32/poly=Castagnoli/size=(?P<size>\d+)kB"
    r"(?:/align=(?P<align>\d+))?\s+"
    r"(?P<iterations>\d+)\s+"
    r"(?P<value>[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?)\s+ns/op"
    r"(?:\s+[0-9.]+ MB/s)?$"
)
SIZES = (4, 32)
ALIGNS = (0, 1)
SCENARIO = "crc32-castagnoli"
GROUP = "crc32/castagnoli"
PATTERN = "CRC32/poly=Castagnoli/size=(4|32)kB"
MEASURED_TOOLCHAIN = "measured"


def metric_name(size_kb: int, align: int | None) -> str:
    if align is None:
        return f"crc32_castagnoli_{size_kb}kb"
    return f"crc32_castagnoli_{size_kb}kb_align{align}"


def scenario_label(size: int, align: int | None) -> str:
    if align is None:
        return f"{size}kB"
    return f"{size}kB/align={align}"


def fail(message: str) -> NoReturn:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def read_raw(path: Path) -> list[str]:
    try:
        return path.read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError as error:
        fail(f"cannot read the benchmark output {path}: {error}")


def parse_samples(
    lines: list[str], reps: int
) -> tuple[
    list[tuple[int, int | None]],
    dict[tuple[int, int | None], list[float]],
    dict[tuple[int, int | None], list[str]],
]:
    samples: dict[tuple[int, int | None], list[float]] = {}
    raw_lines: dict[tuple[int, int | None], list[str]] = {}
    for line in lines:
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith(("PASS", "ok ", "FAIL", "panic:")):
            continue
        if stripped.startswith("Benchmark"):
            match = BENCH_LINE.match(stripped)
            if not match:
                fail(f"unexpected benchmark line: {stripped!r}")
            size = int(match.group("size"))
            align = int(match.group("align")) if match.group("align") is not None else None
            if size not in SIZES:
                fail(f"unexpected benchmark size {size}kB: {stripped!r}")
            value = float(match.group("value"))
            if not math.isfinite(value) or value <= 0:
                fail(f"benchmark {size}kB/align={align} has a non-positive ns/op value: {stripped!r}")
            key = (size, align)
            samples.setdefault(key, []).append(value)
            raw_lines.setdefault(key, []).append(stripped)
            continue
        if stripped.startswith("go: ") or stripped.startswith("go test:"):
            fail(f"Go command error in the benchmark output: {stripped!r}")
        # Any other line (toolchain banner, build metadata) is ignored on purpose;
        # measurement integrity is checked on the benchmark lines themselves.

    observed = set(samples)
    aligned = {(size, align) for size in SIZES for align in ALIGNS}
    plain = {(size, None) for size in SIZES}
    if observed == aligned:
        keys = [(size, align) for size in SIZES for align in ALIGNS]
    elif observed == plain:
        keys = [(size, None) for size in SIZES]
    else:
        missing = sorted((aligned if observed & aligned else plain) - observed)
        extra = sorted(observed - aligned - plain)
        fail(
            "the raw output does not contain one complete CRC32 Castagnoli set; "
            f"missing={missing} unexpected={extra}"
        )
    for key in keys:
        if len(samples[key]) != reps:
            fail(
                f"expected {reps} ns/op samples for {key[0]}kB/align={key[1]}, "
                f"found {len(samples[key])}; the raw output is incomplete or was "
                "not produced with the pinned -count"
            )
    return keys, samples, raw_lines


def build_results(
    keys: list[tuple[int, int | None]],
    samples: dict[tuple[int, int | None], list[float]],
) -> dict[str, object]:
    results: dict[str, object] = {}
    for size, align in keys:
        name = metric_name(size, align)
        benchmark = f"BenchmarkCRC32/poly=Castagnoli/size={size}kB"
        if align is not None:
            benchmark += f"/align={align}"
        results[name] = {
            "source_name": name,
            "source_benchmark": benchmark,
            "source_field": "ns/op",
            "toolchain": MEASURED_TOOLCHAIN,
            "value": statistics.median(samples[(size, align)]),
            "unit": "ns/op",
            "direction": "lower_is_better",
            "samples": len(samples[(size, align)]),
            "sample_values": samples[(size, align)],
            "group": GROUP,
        }
    return results


def write_run_samples(
    runs_dir: Path,
    keys: list[tuple[int, int | None]],
    samples: dict[tuple[int, int | None], list[float]],
    raw_lines: dict[tuple[int, int | None], list[str]],
    reps: int,
) -> None:
    scenario_dir = runs_dir / SCENARIO
    scenario_dir.mkdir(parents=True, exist_ok=True)
    for index in range(reps):
        record = {
            "scenario": SCENARIO,
            "toolchain": MEASURED_TOOLCHAIN,
            "rep": index + 1,
            "samples": {
                scenario_label(size, align): samples[(size, align)][index]
                for size, align in keys
            },
        }
        (scenario_dir / f"rep{index + 1}.json").write_text(
            json.dumps(record, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        rep_lines = [
            raw_lines[key][index] for key in keys if index < len(raw_lines[key])
        ]
        (scenario_dir / f"rep{index + 1}.log").write_text(
            "\n".join(rep_lines) + "\n", encoding="utf-8"
        )


def check_benchstat(path: Path) -> None:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError as error:
        fail(f"cannot read the benchstat report {path}: {error}")
    if not text.strip():
        fail(f"the benchstat report is empty: {path}")
    if "CRC32/poly=Castagnoli" not in text:
        fail(f"the benchstat report does not contain the pinned benchmark: {path}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--raw", required=True, type=Path)
    parser.add_argument("--benchstat", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--runs", required=True, type=Path)
    parser.add_argument("--reps", required=True, type=int)
    parser.add_argument("--warmup-reps", type=int, default=1)
    parser.add_argument("--software-version", required=True)
    parser.add_argument("--measured-version", required=True)
    parser.add_argument("--bootstrap-version", default="")
    parser.add_argument("--source-commit", default="")
    parser.add_argument("--arch", required=True)
    parser.add_argument("--run-id", required=True)
    parser.add_argument("--variant", required=True)
    args = parser.parse_args()

    if args.reps < 5:
        fail(f"at least 5 measured repetitions are required, got {args.reps}")
    if args.variant not in ("base", "optimized"):
        fail(f"invalid variant in the benchmark results: {args.variant!r}")
    if args.measured_version != args.software_version:
        fail(
            f"the measured toolchain is {args.measured_version} but the case version is "
            f"{args.software_version}; they must match"
        )
    check_benchstat(args.benchstat)

    keys, samples, raw_lines = parse_samples(read_raw(args.raw), args.reps)

    payload = {
        "software": "gocrc",
        "version": args.software_version,
        "variant": args.variant,
        "architecture": args.arch,
        "run_id": args.run_id,
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "toolchains": {
            "bootstrap": {
                "version": args.bootstrap_version,
                "goroot": "/usr/local/go",
                "measured": False,
            },
            "measured": {
                "version": args.measured_version,
                "goroot": "/home/local/golang",
                "source_commit": args.source_commit,
            },
        },
        "benchmark": {
            "package": "hash/crc32",
            "pattern": PATTERN,
            "cpu": 1,
            "warmup_reps": args.warmup_reps,
            "measure_reps": args.reps,
            "time_basis": "ns/op",
            "scenarios": [
                {
                    "size_kb": size,
                    "align": align,
                    "metric": metric_name(size, align),
                }
                for size, align in keys
            ],
        },
        "benchstat_path": str(args.benchstat),
        "results": build_results(keys, samples),
    }

    args.output.parent.mkdir(parents=True, exist_ok=True)
    temporary = args.output.with_name(f".{args.output.name}.tmp")
    temporary.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    temporary.replace(args.output)
    write_run_samples(args.runs, keys, samples, raw_lines, args.reps)

    results = payload["results"]
    for size, align in keys:
        name = metric_name(size, align)
        print(
            f"{scenario_label(size, align)}: "
            f"{results[name]['value']:.3f} ns/op ({args.reps} samples)"
        )
    print(f"wrote {args.output} and {args.runs}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
