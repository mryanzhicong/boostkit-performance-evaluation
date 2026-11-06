#!/usr/bin/env python3
"""Strictly validate the OpenCV norm result and emit benchmark_opencv.json.

The reference CSV alone cannot prove the sampling contract, so the parser also
reads the harness evidence: the three scenarios must be present with the
requested number of positive samples, the published median must match those
samples, no sample may be zero-filled, and the container must have measured
without CPU or memory pinning.
"""

from __future__ import annotations

import argparse
import csv
import json
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path

CSV_FIELDS = ["scenario", "iterations", "ms_per_call", "status"]
MIN_SAMPLES = 5


class ValidationError(ValueError):
    pass


def load_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ValidationError(f"cannot read {path}: {error}") from error


def read_reference_csv(path: Path) -> list[dict[str, str]]:
    if not path.is_file():
        raise ValidationError(f"reference CSV is missing: {path}")
    with path.open(newline="", encoding="utf-8") as stream:
        reader = csv.DictReader(stream)
        if reader.fieldnames != CSV_FIELDS:
            raise ValidationError(f"unexpected CSV header: {reader.fieldnames}")
        return list(reader)


def validate(
    csv_rows: list[dict[str, str]],
    evidence: dict,
    manifest: dict,
    warmups: int,
    samples: int,
    calls: int,
) -> dict:
    expected = [scenario["name"] for scenario in manifest["scenarios"]]
    names = [row["scenario"] for row in csv_rows]
    if names != expected:
        raise ValidationError(f"CSV scenarios are {names}, expected {expected}")

    if evidence.get("statistic") != "median":
        raise ValidationError(f"evidence statistic is {evidence.get('statistic')!r}, expected 'median'")
    if int(evidence.get("warmups", -1)) != warmups:
        raise ValidationError("evidence warm-ups disagree with the requested warm-ups")
    if int(evidence.get("samples", -1)) != samples:
        raise ValidationError("evidence samples disagree with the requested samples")
    if int(evidence.get("calls_per_sample", -1)) != calls:
        raise ValidationError("evidence calls per sample disagree with the requested count")
    if evidence.get("cpu_pinning") != "none" or evidence.get("memory_pinning") != "none":
        raise ValidationError("evidence reports CPU or memory pinning; this case forbids pinning")
    if int(evidence.get("cpus_allowed", 0)) < 1:
        raise ValidationError("evidence does not record the allowed CPU set")
    native_threads = int(manifest["native_threads"])
    if int(evidence.get("native_threads", 0)) != native_threads:
        raise ValidationError("evidence native thread count differs from the manifest")
    if evidence.get("source_mode") != "unpatched":
        raise ValidationError("evidence does not declare an unpatched source tree")
    build = evidence.get("build")
    if not isinstance(build, str) or "Parallel framework:" not in build:
        raise ValidationError("evidence is missing the OpenCV build information")
    if "-fopenmp" in build:
        raise ValidationError("the OpenCV build reports OpenMP")
    parallel = [line for line in build.splitlines() if "Parallel framework:" in line]
    if "none" not in parallel[0].lower():
        raise ValidationError(f"OpenCV parallel framework is not none: {parallel[0]!r}")

    cases = evidence.get("cases")
    if not isinstance(cases, dict):
        raise ValidationError("evidence cases must be an object")
    if set(cases) != set(expected):
        raise ValidationError(
            f"evidence scenarios are {sorted(cases)}, expected {sorted(expected)}"
        )

    results: dict[str, dict] = {}
    for row, scenario in zip(csv_rows, manifest["scenarios"], strict=True):
        name = scenario["name"]
        if row["status"] != "OK":
            raise ValidationError(f"{name}: CSV status is {row['status']!r}, expected 'OK'")
        try:
            csv_iterations = int(row["iterations"])
        except ValueError as error:
            raise ValidationError(f"{name}: CSV iterations is not an integer: {row['iterations']!r}") from error
        if csv_iterations != calls * samples:
            raise ValidationError(
                f"{name}: CSV iterations is {csv_iterations}, expected {calls * samples}"
            )
        try:
            csv_value = float(row["ms_per_call"])
        except ValueError as error:
            raise ValidationError(f"{name}: CSV ms_per_call is not numeric: {row['ms_per_call']!r}") from error

        item = cases[name]
        if not isinstance(item, dict) or item.get("status") == "FAIL":
            raise ValidationError(f"{name}: evidence reports a failed scenario")
        measured = item.get("samples_ms")
        if not isinstance(measured, list):
            raise ValidationError(f"{name}: evidence samples_ms must be a list")
        if len(measured) != samples:
            raise ValidationError(f"{name}: evidence holds {len(measured)} samples, expected {samples}")
        for value in measured:
            if isinstance(value, bool) or not isinstance(value, (int, float)):
                raise ValidationError(f"{name}: sample is not numeric: {value!r}")
            if not (value > 0):
                raise ValidationError(f"{name}: sample must be positive: {value!r}")
        computed_median = statistics.median(measured)
        if abs(computed_median - csv_value) > 1e-6:
            raise ValidationError(
                f"{name}: CSV median {csv_value} disagrees with the samples ({computed_median})"
            )
        video = manifest["videos"][scenario["video"]]
        if item.get("frame0_sha256") != video["frame0_sha256"]:
            raise ValidationError(f"{name}: evidence frame 0 digest differs from the pinned frame")
        if item.get("rgb_sha256") != video["rgb_sha256"]:
            raise ValidationError(f"{name}: evidence RGB digest differs from the pinned conversion")
        if not isinstance(item.get("input_sha256"), str) or len(item["input_sha256"]) != 64:
            raise ValidationError(f"{name}: evidence is missing the measured luma digest")
        if not isinstance(item.get("output"), (int, float)) or item["output"] <= 0:
            raise ValidationError(f"{name}: evidence is missing the norm output")

        results[name] = {
            "source_name": name,
            "group": scenario["group"],
            "subgroup": scenario["subgroup"],
            "value": computed_median,
            "unit": "ms",
            "direction": "lower_is_better",
            "operation": scenario["operation"],
            "api": scenario["api"],
            "mean_ms": statistics.mean(measured),
            "median_ms": computed_median,
            "samples": [float(value) for value in measured],
            "statistic": "median",
            "calls_per_sample": calls,
            "cpus_allowed": int(evidence["cpus_allowed"]),
            "cpu_pinning": "none",
            "native_threads": native_threads,
            "input_sha256": item["input_sha256"],
            "rgb_sha256": item["rgb_sha256"],
            "norm_output": item["output"],
        }
    return results


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--csv", required=True, type=Path)
    parser.add_argument("--evidence", required=True, type=Path)
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--warmups", required=True, type=int)
    parser.add_argument("--samples", required=True, type=int)
    parser.add_argument("--calls", required=True, type=int)
    parser.add_argument("--version", required=True)
    parser.add_argument("--architecture", required=True)
    parser.add_argument("--variant", default="base")
    args = parser.parse_args(argv)

    if args.samples < MIN_SAMPLES:
        print(f"ERROR: samples must be >= {MIN_SAMPLES}, got {args.samples}", file=sys.stderr)
        return 1

    try:
        csv_rows = read_reference_csv(args.csv)
        evidence = load_json(args.evidence)
        manifest = load_json(args.manifest)
        results = validate(csv_rows, evidence, manifest, args.warmups, args.samples, args.calls)
    except ValidationError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1
    except KeyError as error:
        print(f"ERROR: result is missing a required field: {error}", file=sys.stderr)
        return 1

    payload = {
        "benchmark": manifest["benchmark"],
        "software": "opencv",
        "version": args.version,
        "architecture": args.architecture,
        "variant": args.variant,
        "generated_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "parameters": {
            "resolution": manifest["resolution"],
            "color_format": manifest["color_format"],
            "scenarios": len(manifest["scenarios"]),
            "warmups": args.warmups,
            "samples": args.samples,
            "calls_per_sample": args.calls,
            "statistic": "median",
            "cpu_pinning": "none",
            "memory_pinning": "none",
            "native_threads": int(manifest["native_threads"]),
            "media_directory": manifest["media_directory"],
        },
        "results": results,
    }
    args.output.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2, allow_nan=False) + "\n",
        encoding="utf-8",
    )
    for name, item in results.items():
        print(f"[opencv] {name:<30} median={item['value']:.6f} ms/call", flush=True)
    print(
        f"[opencv] normalized {len(results)} scenarios over {args.samples} samples x {args.calls} calls (no pinning)",
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
