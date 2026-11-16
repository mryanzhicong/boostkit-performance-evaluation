#!/usr/bin/env python3
"""Normalize the measured Eigen GEMM matrix into ``results.json``.

The measured workload is the unmodified upstream ``bench/bench_gemm.cpp`` of the
pinned Eigen release: one single-thread float matrix-matrix product per matrix
point.  For every (m, k, n) point of the pinned matrix the test stage runs one
warm-up plus every declared independent repetition of

    gemm_bench -s <m> <n> <k> -t 5 -p 10

inside the private container (the upstream ``-s`` option takes rows, columns and
depth in that order, so the depth k is passed third).  The wrapper records wall
time and peak RSS in ``runs/<slug>/<label>.json`` and the complete stdout in
``runs/<slug>/<label>.log``.

The only metric per matrix point is the throughput upstream prints on its
``eigen cpu`` line (GFLOPS from the best of the pinned tries, CPU-time based):

    eigen cpu         5.65e-07s  	22.2018 GFLOPS 	(3.989e-06s)

The parser requires the warm-up plus every declared repetition for every matrix
point, exactly one throughput line per run, the exact upstream matrix header
(``Matrix sizes = m x k * k x n``) and a strictly positive finite GFLOPS value.
It never fills in, estimates or zero-pads a value, and fails on a missing
sample, a non-zero exit, a timeout, a NaN/inf value or an unexpected output
shape.
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

CPU_LINE = re.compile(
    r"^eigen cpu\s+(?P<seconds>[0-9.eE+-]+)s\s+(?P<gflops>[0-9.]+)\s+GFLOPS"
    r"\s+\((?P<total>[0-9.eE+-]+)s\)$"
)
REAL_LINE = re.compile(
    r"^eigen real\s+(?P<seconds>[0-9.eE+-]+)s\s+(?P<gflops>[0-9.]+)\s+GFLOPS"
    r"\s+\((?P<total>[0-9.eE+-]+)s\)$"
)
BAD_MARKERS = (
    "Warning, your product is crap",
    "Warning, your parallel product is crap",
    "TIMEOUT after",
    "ERROR:",
)
GROUP = "gemm"
METRIC_PREFIX = "gemm_gflops"


def fail(message: str) -> None:
    print(f"[eigen-parse] ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def parse_matrix(value: str) -> list[tuple[int, int, int]]:
    points: list[tuple[int, int, int]] = []
    seen: set[tuple[int, int, int]] = set()
    for raw in value.split(";"):
        raw = raw.strip()
        if not raw:
            continue
        fields = [field.strip() for field in raw.split(",")]
        if len(fields) != 3:
            fail(f"invalid matrix point {raw!r}: expected m,k,n")
        try:
            m, k, n = (int(field) for field in fields)
        except ValueError:
            fail(f"invalid matrix point {raw!r}: dimensions must be integers")
        if min(m, k, n) < 1:
            fail(f"invalid matrix point {raw!r}: dimensions must be positive")
        point = (m, k, n)
        if point in seen:
            fail(f"duplicate matrix point {raw!r}")
        seen.add(point)
        points.append(point)
    if not points:
        fail("the pinned matrix is empty")
    return points


def slug(m: int, k: int, n: int) -> str:
    return f"m{m}_k{k}_n{n}"


def load_evidence(path: Path) -> dict[str, object]:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except OSError as error:
        fail(f"cannot read the repetition evidence {path}: {error}")
    except json.JSONDecodeError as error:
        fail(f"invalid repetition evidence {path}: {error}")


def read_log(path: Path) -> list[str]:
    try:
        return path.read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError as error:
        fail(f"cannot read the measurement log {path}: {error}")


def check_labels(
    point: tuple[int, int, int],
    runs_dir: Path,
    reps: int,
    tries: int,
    repeats: int,
) -> list[tuple[float, float, float, float, float]]:
    """Validate one matrix point and return (gflops, cpu_s, real_gflops, wall_s, rss) per rep."""
    m, k, n = point
    name = slug(m, k, n)
    directory = runs_dir / name
    if not directory.is_dir():
        fail(f"missing matrix-point directory: {directory}")
    expected_command = f"-s {m} {n} {k} -t {tries} -p {repeats}"
    header = f"Matrix sizes = {m}x{k} * {k}x{n}"
    rows: list[tuple[float, float, float, float, float]] = []
    for label in ["warmup"] + [f"rep{index}" for index in range(1, reps + 1)]:
        evidence_path = directory / f"{label}.json"
        log_path = directory / f"{label}.log"
        evidence = load_evidence(evidence_path)
        exit_code = evidence.get("exit_code")
        if exit_code != 0:
            fail(f"{name}/{label}: the measured process exited with {exit_code!r}")
        if evidence.get("timed_out"):
            fail(f"{name}/{label}: the measured process timed out")
        wall = evidence.get("wall_seconds")
        rss = evidence.get("max_rss_mib")
        if not isinstance(wall, (int, float)) or not math.isfinite(float(wall)) or float(wall) <= 0:
            fail(f"{name}/{label}: invalid wall time {wall!r}")
        if not isinstance(rss, (int, float)) or not math.isfinite(float(rss)) or float(rss) < 0:
            fail(f"{name}/{label}: invalid peak RSS {rss!r}")

        lines = read_log(log_path)
        commands = [line for line in lines if line.startswith("# command:")]
        if len(commands) != 1 or expected_command not in commands[0]:
            fail(f"{name}/{label}: unexpected command line {commands or 'missing'!r}")
        for marker in BAD_MARKERS:
            if any(marker in line for line in lines):
                fail(f"{name}/{label}: the run reported {marker!r}")
        headers = [line for line in lines if line.strip() == header]
        if len(headers) != 1:
            fail(
                f"{name}/{label}: expected exactly one {header!r} line, "
                f"found {len(headers)}"
            )
        cpu_lines = [CPU_LINE.match(line) for line in lines]
        cpu_lines = [match for match in cpu_lines if match]
        if len(cpu_lines) != 1:
            fail(
                f"{name}/{label}: expected exactly one 'eigen cpu ... GFLOPS' line, "
                f"found {len(cpu_lines)}"
            )
        gflops = float(cpu_lines[0].group("gflops"))
        seconds = float(cpu_lines[0].group("seconds"))
        if not math.isfinite(gflops) or gflops <= 0:
            fail(f"{name}/{label}: non-positive or non-finite GFLOPS {gflops!r}")
        if not math.isfinite(seconds) or seconds <= 0:
            fail(f"{name}/{label}: non-positive or non-finite CPU time {seconds!r}")
        real_lines = [REAL_LINE.match(line) for line in lines]
        real_lines = [match for match in real_lines if match]
        if len(real_lines) != 1:
            fail(
                f"{name}/{label}: expected exactly one 'eigen real ... GFLOPS' line, "
                f"found {len(real_lines)}"
            )
        real_gflops = float(real_lines[0].group("gflops"))
        if not math.isfinite(real_gflops) or real_gflops <= 0:
            fail(f"{name}/{label}: non-positive or non-finite real GFLOPS {real_gflops!r}")
        if label != "warmup":
            rows.append((gflops, seconds, real_gflops, float(wall), float(rss)))
    return rows


def summarize(values: list[float]) -> dict[str, float]:
    return {
        "median": round(float(statistics.median(values)), 6),
        "mean": round(float(statistics.fmean(values)), 6),
        "min": round(float(min(values)), 6),
        "max": round(float(max(values)), 6),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("runs_dir", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--matrix", required=True)
    parser.add_argument("--reps", required=True, type=int)
    parser.add_argument("--tries", required=True, type=int)
    parser.add_argument("--repeats", required=True, type=int)
    parser.add_argument("--software-version", required=True)
    parser.add_argument("--architecture", required=True)
    parser.add_argument("--variant", required=True)
    parser.add_argument("--run-id", required=True)
    parser.add_argument("--compiler", default="unknown")
    args = parser.parse_args()

    if args.reps < 1:
        fail(f"at least one measured repetition is required, got {args.reps}")
    if args.tries < 1 or args.repeats < 1:
        fail("the pinned tries/repeats must be positive")
    if args.variant not in ("base", "optimized"):
        fail(f"invalid variant: {args.variant!r}")
    points = parse_matrix(args.matrix)

    results: dict[str, object] = {}
    for (m, k, n) in points:
        name = f"{METRIC_PREFIX}_m{m}_k{k}_n{n}"
        rows = check_labels((m, k, n), args.runs_dir, args.reps, args.tries, args.repeats)
        gflops_values = [row[0] for row in rows]
        seconds = [row[1] for row in rows]
        real_gflops = [row[2] for row in rows]
        wall = [row[3] for row in rows]
        rss = [row[4] for row in rows]
        summary = summarize(gflops_values)
        results[name] = {
            "source_name": name,
            "source_benchmark": f"Matrix sizes = {m}x{k} * {k}x{n}",
            "source_field": "eigen cpu GFLOPS",
            "matrix": {"m": m, "k": k, "n": n},
            "value": summary["median"],
            "unit": "GFLOP/s",
            "direction": "higher_is_better",
            "samples": len(gflops_values),
            "sample_values": gflops_values,
            "sample_summary": summary,
            "cpu_seconds_sample_values": seconds,
            "real_gflops_sample_values": real_gflops,
            "wall_seconds_sample_values": wall,
            "max_rss_mib_sample_values": rss,
            "group": GROUP,
        }

    payload = {
        "software": "eigen",
        "version": args.software_version,
        "variant": args.variant,
        "architecture": args.architecture,
        "run_id": args.run_id,
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "toolchain": {"compiler": args.compiler},
        "benchmark": {
            "workload": "upstream Eigen bench_gemm dense float matrix-matrix product",
            "matrix": "m k n",
            "matrix_points": len(points),
            "tries": args.tries,
            "repeats_per_try": args.repeats,
            "warmup_reps": 1,
            "measure_reps": args.reps,
        },
        "results": results,
        "runs_dir": "runs",
    }

    args.output.parent.mkdir(parents=True, exist_ok=True)
    temporary = args.output.with_name(f".{args.output.name}.tmp")
    temporary.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    temporary.replace(args.output)
    for (m, k, n) in points:
        name = f"{METRIC_PREFIX}_m{m}_k{k}_n{n}"
        item = results[name]
        print(
            f"{slug(m, k, n)}: {item['value']:.3f} GFLOP/s "
            f"(m={m}, k={k}, n={n}, {item['samples']} samples)"
        )
    print(f"wrote {args.output}: {len(points)} matrix points")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
