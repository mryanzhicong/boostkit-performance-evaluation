#!/usr/bin/env python3
"""Validate and normalize the Go CRC32 Castagnoli microbenchmark results.

The test stage runs the pinned benchmark twice inside the private container:
once with the official Go release at /usr/local/go and once with the openEuler
golang go1.24.6 toolchain built at /home/local/golang, then compares the two
result sets with benchstat:

    go test hash/crc32 -run='^$' \\
        -bench='CRC32/poly=Castagnoli/size=(4|32)kB' -cpu=1 -count=6

Go 1.23 emits four leaf benchmarks (4 kB / 32 kB x align=0 / align=1); older
releases without the align dimension emit two.  This parser requires exactly one
complete set with exactly ``--reps`` samples per entry in *each* toolchain output
and refuses anything else: missing samples, extra samples, unknown benchmark
names, non-positive values and a missing/failed benchstat report all fail the
case instead of being zero-padded or silently skipped.

Metrics: per scenario the official median, the optimized median and the speedup
(official / optimized, higher is better).
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
TOOLCHAINS = ("official", "optimized")


def metric_suffix(size_kb: int, align: int | None) -> str:
    if align is None:
        return f"crc32_castagnoli_{size_kb}kb"
    return f"crc32_castagnoli_{size_kb}kb_align{align}"


def metric_names(size_kb: int, align: int | None) -> dict[str, str]:
    suffix = metric_suffix(size_kb, align)
    return {
        "official": f"official_{suffix}",
        "optimized": f"optimized_{suffix}",
        "speedup": f"speedup_{suffix}",
    }


def scenario_label(size: int, align: int | None) -> str:
    if align is None:
        return f"{size}kB"
    return f"{size}kB/align={align}"


def fail(message: str) -> NoReturn:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def read_raw(path: Path, toolchain: str) -> list[str]:
    try:
        return path.read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError as error:
        fail(f"cannot read the {toolchain} benchmark output {path}: {error}")


def parse_samples(
    lines: list[str], reps: int, toolchain: str
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
                fail(f"{toolchain}: unexpected benchmark line: {stripped!r}")
            size = int(match.group("size"))
            align = int(match.group("align")) if match.group("align") is not None else None
            if size not in SIZES:
                fail(f"{toolchain}: unexpected benchmark size {size}kB: {stripped!r}")
            value = float(match.group("value"))
            if not math.isfinite(value) or value <= 0:
                fail(
                    f"{toolchain}: benchmark {size}kB/align={align} has a non-positive ns/op value: {stripped!r}"
                )
            key = (size, align)
            samples.setdefault(key, []).append(value)
            raw_lines.setdefault(key, []).append(stripped)
            continue
        if stripped.startswith("go: ") or stripped.startswith("go test:"):
            fail(f"{toolchain}: Go command error in the benchmark output: {stripped!r}")
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
            f"{toolchain}: the raw output does not contain one complete CRC32 Castagnoli set; "
            f"missing={missing} unexpected={extra}"
        )
    for key in keys:
        if len(samples[key]) != reps:
            fail(
                f"{toolchain}: expected {reps} ns/op samples for {key[0]}kB/align={key[1]}, "
                f"found {len(samples[key])}; the raw output is incomplete or was "
                "not produced with the pinned -count"
            )
    return keys, samples, raw_lines


def build_results(
    keys: list[tuple[int, int | None]],
    official: dict[tuple[int, int | None], list[float]],
    optimized: dict[tuple[int, int | None], list[float]],
) -> dict[str, object]:
    results: dict[str, object] = {}
    for size, align in keys:
        names = metric_names(size, align)
        benchmark = f"BenchmarkCRC32/poly=Castagnoli/size={size}kB"
        if align is not None:
            benchmark += f"/align={align}"
        official_median = statistics.median(official[(size, align)])
        optimized_median = statistics.median(optimized[(size, align)])
        results[names["official"]] = {
            "source_name": names["official"],
            "source_benchmark": benchmark,
            "source_field": "ns/op",
            "toolchain": "official",
            "value": official_median,
            "unit": "ns/op",
            "direction": "lower_is_better",
            "samples": len(official[(size, align)]),
            "sample_values": official[(size, align)],
            "group": GROUP,
        }
        results[names["optimized"]] = {
            "source_name": names["optimized"],
            "source_benchmark": benchmark,
            "source_field": "ns/op",
            "toolchain": "optimized",
            "value": optimized_median,
            "unit": "ns/op",
            "direction": "lower_is_better",
            "samples": len(optimized[(size, align)]),
            "sample_values": optimized[(size, align)],
            "group": GROUP,
        }
        results[names["speedup"]] = {
            "source_name": names["speedup"],
            "source_benchmark": benchmark,
            "source_field": "official/optimized",
            "toolchain": "comparison",
            "value": official_median / optimized_median,
            "unit": "x",
            "direction": "higher_is_better",
            "samples": len(official[(size, align)]) + len(optimized[(size, align)]),
            "group": GROUP,
        }
    return results


def write_run_samples(
    runs_dir: Path,
    toolchain: str,
    keys: list[tuple[int, int | None]],
    samples: dict[tuple[int, int | None], list[float]],
    raw_lines: dict[tuple[int, int | None], list[str]],
    reps: int,
) -> None:
    scenario_dir = runs_dir / f"{SCENARIO}-{toolchain}"
    scenario_dir.mkdir(parents=True, exist_ok=True)
    for index in range(reps):
        record = {
            "scenario": f"{SCENARIO}-{toolchain}",
            "toolchain": toolchain,
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
    parser.add_argument("--official-raw", required=True, type=Path)
    parser.add_argument("--optimized-raw", required=True, type=Path)
    parser.add_argument("--benchstat", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--runs", required=True, type=Path)
    parser.add_argument("--reps", required=True, type=int)
    parser.add_argument("--warmup-reps", type=int, default=1)
    parser.add_argument("--software-version", required=True)
    parser.add_argument("--official-version", required=True)
    parser.add_argument("--optimized-version", required=True)
    parser.add_argument("--source-commit", default="")
    parser.add_argument("--arch", required=True)
    parser.add_argument("--run-id", required=True)
    parser.add_argument("--variant", required=True)
    args = parser.parse_args()

    if args.reps < 5:
        fail(f"at least 5 measured repetitions are required, got {args.reps}")
    if args.variant not in ("base", "optimized"):
        fail(f"invalid variant in the benchmark results: {args.variant!r}")
    check_benchstat(args.benchstat)

    official_lines = read_raw(args.official_raw, "official")
    optimized_lines = read_raw(args.optimized_raw, "optimized")
    official_keys, official_samples, official_lines_map = parse_samples(
        official_lines, args.reps, "official"
    )
    optimized_keys, optimized_samples, optimized_lines_map = parse_samples(
        optimized_lines, args.reps, "optimized"
    )
    if official_keys != optimized_keys:
        fail(
            "the official and optimized toolchains produced different benchmark sets: "
            f"{official_keys} vs {optimized_keys}"
        )

    payload = {
        "software": "go",
        "version": args.software_version,
        "variant": args.variant,
        "architecture": args.arch,
        "run_id": args.run_id,
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "toolchains": {
            "official": {
                "version": args.official_version,
                "goroot": "/usr/local/go",
            },
            "optimized": {
                "version": args.optimized_version,
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
                    "metrics": metric_names(size, align),
                }
                for size, align in official_keys
            ],
        },
        "benchstat_path": str(args.benchstat),
        "results": build_results(official_keys, official_samples, optimized_samples),
    }

    args.output.parent.mkdir(parents=True, exist_ok=True)
    temporary = args.output.with_name(f".{args.output.name}.tmp")
    temporary.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    temporary.replace(args.output)
    for toolchain, keys, samples, raw_lines in (
        ("official", official_keys, official_samples, official_lines_map),
        ("optimized", optimized_keys, optimized_samples, optimized_lines_map),
    ):
        write_run_samples(args.runs, toolchain, keys, samples, raw_lines, args.reps)

    results = payload["results"]
    for size, align in official_keys:
        names = metric_names(size, align)
        print(
            f"{scenario_label(size, align)}: official "
            f"{results[names['official']]['value']:.3f} ns/op, optimized "
            f"{results[names['optimized']]['value']:.3f} ns/op, speedup "
            f"{results[names['speedup']]['value']:.3f}x ({args.reps} samples each)"
        )
    print(f"wrote {args.output} and {args.runs}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
