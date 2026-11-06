#!/usr/bin/env python3
"""Aggregate the fixed-workload MPFR measurements into per-scenario metrics.

Every repetition runs the harness once with one routine and one precision, which
prints exactly one ``RESULT`` line carrying the iteration count, the measured
CPU window and the resulting operations per second.  The parser keeps all raw
samples, derives ns/op, wall clock and peak RSS metrics, reports medians and
fails when a declared scenario is incomplete, when a repetition exited
non-zero, or when a value is missing or not a positive finite number.
"""

from __future__ import annotations

import argparse
import json
import math
import re
import statistics
import sys
from pathlib import Path
from typing import Any

SCENARIOS: tuple[dict[str, Any], ...] = (
    {"scenario": "mpfr_mul_256", "routine": "mpfr_mul", "precision": 256},
    {"scenario": "mpfr_mul_1024", "routine": "mpfr_mul", "precision": 1024},
    {"scenario": "mpfr_mul_4096", "routine": "mpfr_mul", "precision": 4096},
    {"scenario": "mpfr_div_1024", "routine": "mpfr_div", "precision": 1024},
    {"scenario": "mpfr_sqrt_256", "routine": "mpfr_sqrt", "precision": 256},
    {"scenario": "mpfr_sqrt_1024", "routine": "mpfr_sqrt", "precision": 1024},
    {"scenario": "mpfr_exp_256", "routine": "mpfr_exp", "precision": 256},
    {"scenario": "mpfr_exp_1024", "routine": "mpfr_exp", "precision": 1024},
)

RESULT_LINE = re.compile(
    r"^RESULT routine=(?P<routine>\S+) precision=(?P<precision>\d+) "
    r"iterations=(?P<iterations>\d+) cpu_seconds=(?P<cpu>[0-9.eE+-]+) "
    r"ops_per_second=(?P<ops>[0-9.eE+-]+) checksum=(?P<checksum>\S+)\s*$"
)
MAX_OPS = 1e12


def fail(message: str) -> None:
    print(f"[mpfr-parse] ERROR: {message}", file=sys.stderr)


def parse_harness_log(path: Path, scenario: dict[str, Any]) -> dict[str, float]:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        raise RuntimeError(f"cannot read {path}: {exc}") from exc
    matches = [RESULT_LINE.match(line) for line in text.splitlines()]
    results = [match for match in matches if match is not None]
    if len(results) != 1:
        raise RuntimeError(
            f"{path} must contain exactly one RESULT line, found {len(results)}"
        )
    match = results[0]
    if match.group("routine") != scenario["routine"]:
        raise RuntimeError(
            f"{path} measured {match.group('routine')}, expected {scenario['routine']}"
        )
    if int(match.group("precision")) != scenario["precision"]:
        raise RuntimeError(
            f"{path} measured precision {match.group('precision')}, "
            f"expected {scenario['precision']}"
        )
    iterations = int(match.group("iterations"))
    cpu_seconds = float(match.group("cpu"))
    ops_per_second = float(match.group("ops"))
    if iterations < 1:
        raise RuntimeError(f"{path} ran no iterations")
    for label, value in (("cpu_seconds", cpu_seconds), ("ops_per_second", ops_per_second)):
        if not math.isfinite(value) or value <= 0.0:
            raise RuntimeError(f"{path} reports an invalid {label}: {value}")
    if ops_per_second >= MAX_OPS:
        raise RuntimeError(f"{path} reports an implausible ops_per_second: {ops_per_second}")
    return {
        "iterations": iterations,
        "cpu_seconds": cpu_seconds,
        "ops_per_second": ops_per_second,
    }


def load_sample(run_dir: Path, label: str, check_value: bool) -> dict[str, Any]:
    sample_path = run_dir / f"{label}.json"
    if not sample_path.is_file():
        raise RuntimeError(f"missing sample: {sample_path}")
    try:
        payload = json.loads(sample_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"invalid sample {sample_path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise RuntimeError(f"sample is not an object: {sample_path}")
    if payload.get("exit_code") != 0:
        raise RuntimeError(f"{sample_path} failed with exit code {payload.get('exit_code')}")
    if payload.get("timed_out") is True:
        raise RuntimeError(f"{sample_path} timed out")
    wall = payload.get("wall_seconds")
    rss = payload.get("max_rss_mib")
    if isinstance(wall, bool) or not isinstance(wall, (int, float)):
        raise RuntimeError(f"{sample_path} has no numeric wall time")
    if isinstance(rss, bool) or not isinstance(rss, (int, float)):
        raise RuntimeError(f"{sample_path} has no numeric RSS")
    if not math.isfinite(float(wall)) or wall <= 0.0:
        raise RuntimeError(f"{sample_path} wall time must be positive")
    if not math.isfinite(float(rss)) or rss <= 0.0:
        raise RuntimeError(f"{sample_path} RSS must be positive")
    log_path = run_dir / f"{label}.log"
    if not log_path.is_file() or log_path.stat().st_size == 0:
        raise RuntimeError(f"missing raw log: {log_path}")
    sample: dict[str, Any] = {
        "label": label,
        "wall_seconds": round(float(wall), 6),
        "max_rss_mib": round(float(rss), 3),
    }
    if check_value:
        sample.update(parse_harness_log(log_path, SCENARIO_BY_NAME[run_dir.name]))
    return sample


def summarize(values: list[float]) -> dict[str, float]:
    return {
        "min": round(float(min(values)), 9),
        "max": round(float(max(values)), 9),
        "mean": round(float(statistics.fmean(values)), 9),
        "median": round(float(statistics.median(values)), 9),
        "stdev": round(float(statistics.stdev(values)), 9) if len(values) > 1 else 0.0,
    }


def build_result(
    scenario: dict[str, Any],
    metric: str,
    unit: str,
    direction: str,
    values: list[float],
    extra: dict[str, Any],
) -> dict[str, Any]:
    return {
        "source_name": f"{scenario['scenario']}.{metric}",
        "scenario": scenario["scenario"],
        "group": "mpfr",
        "routine": scenario["routine"],
        "precision_bits": scenario["precision"],
        "unit": unit,
        "direction": direction,
        "value": round(float(statistics.median(values)), 9),
        "samples": [round(float(value), 9) for value in values],
        "statistics": summarize(values),
        "repetitions": len(values),
        **extra,
    }


SCENARIO_BY_NAME: dict[str, dict[str, Any]] = {item["scenario"]: item for item in SCENARIOS}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runs", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--reps", required=True, type=int)
    parser.add_argument("--warmup-reps", type=int, default=1)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.reps < 1:
        fail("--reps must be at least 1")
        return 1
    results: dict[str, Any] = {}
    for scenario in SCENARIOS:
        run_dir = args.runs / scenario["scenario"]
        try:
            for index in range(1, args.warmup_reps + 1):
                load_sample(run_dir, f"warmup{index}", check_value=False)
            samples = [
                load_sample(run_dir, f"rep{index}", check_value=True)
                for index in range(1, args.reps + 1)
            ]
        except RuntimeError as exc:
            fail(f"scenario {scenario['scenario']}: {exc}")
            return 1
        ops = [sample["ops_per_second"] for sample in samples]
        cpu = [sample["cpu_seconds"] for sample in samples]
        wall = [sample["wall_seconds"] for sample in samples]
        rss = [sample["max_rss_mib"] for sample in samples]
        ns_per_op = [1e9 / value for value in ops]
        iterations = [sample["iterations"] for sample in samples]
        extra = {
            "raw_log": f"runs/{scenario['scenario']}/rep1.log",
            "iterations": iterations,
            "cpu_seconds_samples": [round(value, 9) for value in cpu],
        }
        for metric, unit, direction, values in (
            ("ops_per_second", "ops/s", "higher_is_better", ops),
            ("ns_per_op", "ns/op", "lower_is_better", ns_per_op),
            ("wall_seconds", "s", "lower_is_better", wall),
            ("peak_rss_mib", "MiB", "lower_is_better", rss),
        ):
            entry = build_result(scenario, metric, unit, direction, values, extra)
            results[entry["source_name"]] = entry

    payload = {
        "software": "mpfr",
        "category": "Toolchain",
        "benchmark": "fixed-workload MPFR harness (upstream tools/bench methodology)",
        "parameters": {
            "measurement_reps": args.reps,
            "warmup_reps": args.warmup_reps,
            "offline_measurement": True,
            "strict_parser": True,
            "invocation": "one routine and precision per process",
            "operation_selection": "mpfr_mul, mpfr_div, mpfr_sqrt, mpfr_exp",
            "clock": "CLOCK_PROCESS_CPUTIME_ID",
            "operands": "8 random values in [0,1) per process, fixed seed",
        },
        "scenarios": [scenario["scenario"] for scenario in SCENARIOS],
        "results": results,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"[mpfr-parse] wrote {len(results)} metrics to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
