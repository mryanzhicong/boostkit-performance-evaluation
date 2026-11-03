#!/usr/bin/env python3
"""Aggregate the GMP tune/speed measurements into per-scenario metrics.

Each scenario runs the upstream ``tune/speed`` program once per repetition with a
single routine and a single operand size, which makes its output one data line:
``<size> <seconds-per-call>``.  The parser turns that value into ops/s and
ns/op, keeps every raw sample and fails when a declared scenario is incomplete,
when a repetition exited non-zero, or when a value is not a positive finite
number.  It never fills in, estimates or zero-pads a missing measurement.
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
    {"scenario": "mpn_mul_n_512", "routine": "mpn_mul_n", "size": 512, "size_unit": "limbs"},
    {"scenario": "mpn_mul_n_2048", "routine": "mpn_mul_n", "size": 2048, "size_unit": "limbs"},
    {"scenario": "mpn_mul_n_8192", "routine": "mpn_mul_n", "size": 8192, "size_unit": "limbs"},
    {"scenario": "mpn_sqr_4096", "routine": "mpn_sqr", "size": 4096, "size_unit": "limbs"},
    {"scenario": "mpn_add_n_8192", "routine": "mpn_add_n", "size": 8192, "size_unit": "limbs"},
    {"scenario": "mpn_div_qr_2n_2048", "routine": "mpn_div_qr_2n", "size": 2048, "size_unit": "limbs"},
    {"scenario": "mpn_div_qr_2n_8192", "routine": "mpn_div_qr_2n", "size": 8192, "size_unit": "limbs"},
    {"scenario": "mpz_add_2048", "routine": "mpz_add", "size": 2048, "size_unit": "bits"},
    {"scenario": "mpz_add_8192", "routine": "mpz_add", "size": 8192, "size_unit": "bits"},
)

DATA_LINE = re.compile(r"^\s*(\d+)\s+([0-9]*\.?[0-9]+(?:[eE][+-]?\d+)?)\s*$")
MAX_SECONDS = 60.0


def fail(message: str) -> None:
    print(f"[gmp-parse] ERROR: {message}", file=sys.stderr)


def parse_speed_log(path: Path, scenario: dict[str, Any]) -> float:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        raise RuntimeError(f"cannot read {path}: {exc}") from exc
    if scenario["routine"] not in text:
        raise RuntimeError(f"{path} does not mention routine {scenario['routine']}")
    values: list[tuple[int, float]] = []
    for line in text.splitlines():
        match = DATA_LINE.match(line)
        if match is None:
            continue
        values.append((int(match.group(1)), float(match.group(2))))
    if len(values) != 1:
        raise RuntimeError(
            f"{path} must contain exactly one '<size> <seconds>' data line, found {len(values)}"
        )
    size, seconds = values[0]
    if size != scenario["size"]:
        raise RuntimeError(f"{path} reports size {size}, expected {scenario['size']}")
    if not math.isfinite(seconds) or seconds <= 0.0 or seconds >= MAX_SECONDS:
        raise RuntimeError(f"{path} reports an implausible time per call: {seconds}")
    return seconds


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
    sample = {
        "label": label,
        "wall_seconds": round(float(wall), 6),
        "max_rss_mib": round(float(rss), 3),
    }
    if check_value:
        sample["seconds_per_call"] = parse_speed_log(log_path, SCENARIO_BY_NAME[run_dir.name])
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
        "group": "gmp",
        "routine": scenario["routine"],
        "operand_size": scenario["size"],
        "operand_size_unit": scenario["size_unit"],
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
        seconds = [sample["seconds_per_call"] for sample in samples]
        wall = [sample["wall_seconds"] for sample in samples]
        rss = [sample["max_rss_mib"] for sample in samples]
        ops_per_second = [1.0 / value for value in seconds]
        ns_per_op = [value * 1e9 for value in seconds]
        extra = {"raw_log": f"runs/{scenario['scenario']}/rep1.log"}
        for metric, unit, direction, values in (
            ("ops_per_second", "ops/s", "higher_is_better", ops_per_second),
            ("ns_per_op", "ns/op", "lower_is_better", ns_per_op),
            ("wall_seconds", "s", "lower_is_better", wall),
            ("peak_rss_mib", "MiB", "lower_is_better", rss),
        ):
            entry = build_result(scenario, metric, unit, direction, values, extra)
            results[entry["source_name"]] = entry

    payload = {
        "software": "gmp",
        "category": "Toolchain",
        "benchmark": "upstream tune/speed",
        "generated_at": None,
        "parameters": {
            "measurement_reps": args.reps,
            "warmup_reps": args.warmup_reps,
            "offline_measurement": True,
            "strict_parser": True,
            "invocation": "one tune/speed routine and size per process",
            "speed_argv": "./speed -s <size> <routine>",
        },
        "scenarios": [scenario["scenario"] for scenario in SCENARIOS],
        "results": results,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"[gmp-parse] wrote {len(results)} metrics to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
