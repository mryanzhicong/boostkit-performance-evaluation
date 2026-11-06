#!/usr/bin/env python3
"""Strictly validate the libavif encode result and emit benchmark_libavif.json.

The reference CSV alone cannot prove the sampling contract, so the parser also
reads the harness evidence: every one of the six scenarios must be present with
the requested number of positive samples, the published median must match those
samples, and the container must have measured without CPU or memory pinning.
Missing, extra or non-positive samples are hard failures -- nothing is zero-filled.
"""

from __future__ import annotations

import argparse
import csv
import json
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path

CSV_FIELDS = ["scenario", "iterations", "ms_per_image", "status"]
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
    if evidence.get("cpu_pinning") != "none" or evidence.get("memory_pinning") != "none":
        raise ValidationError("evidence reports CPU or memory pinning; this case forbids pinning")
    if int(evidence.get("cpus_allowed", 0)) < 1:
        raise ValidationError("evidence does not record the allowed CPU set")
    native_threads = int(manifest["native_threads"])
    if int(evidence.get("native_threads", 0)) != native_threads:
        raise ValidationError("evidence native thread count differs from the manifest")

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
        if csv_iterations != samples:
            raise ValidationError(f"{name}: CSV iterations is {csv_iterations}, expected {samples}")
        try:
            csv_value = float(row["ms_per_image"])
        except ValueError as error:
            raise ValidationError(f"{name}: CSV ms_per_image is not numeric: {row['ms_per_image']!r}") from error

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
        if int(item.get("observed_threads", 0)) != native_threads:
            raise ValidationError(
                f"{name}: observed {item.get('observed_threads')} encoder threads, "
                f"expected {native_threads}"
            )
        for field in ("encoded_sha256", "decoded_yuv_sha256"):
            value = item.get(field)
            if not isinstance(value, str) or len(value) != 64:
                raise ValidationError(f"{name}: evidence {field} is not a sha256 digest")

        video = manifest["videos"][scenario["video"]]
        results[name] = {
            "source_name": name,
            "group": scenario["group"],
            "subgroup": scenario["subgroup"],
            "value": computed_median,
            "unit": "ms",
            "direction": "lower_is_better",
            "codec": "aom",
            "qp": scenario["qp"],
            "mean_ms": statistics.mean(measured),
            "median_ms": computed_median,
            "samples": [float(value) for value in measured],
            "statistic": "median",
            "cpus_allowed": int(evidence["cpus_allowed"]),
            "cpu_pinning": "none",
            "png_sha256": video["png_sha256"],
            "encoded_sha256": item["encoded_sha256"],
            "decoded_yuv_sha256": item["decoded_yuv_sha256"],
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
        results = validate(csv_rows, evidence, manifest, args.warmups, args.samples)
    except ValidationError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1
    except KeyError as error:
        print(f"ERROR: result is missing a required field: {error}", file=sys.stderr)
        return 1

    payload = {
        "benchmark": manifest["benchmark"],
        "software": "libavif",
        "version": args.version,
        "codec_version": manifest["codec"],
        "architecture": args.architecture,
        "variant": args.variant,
        "generated_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "parameters": {
            "resolution": manifest["resolution"],
            "color_format": manifest["color_format"],
            "encoder_options": manifest["encoder_options"],
            "scenarios": len(manifest["scenarios"]),
            "warmups": args.warmups,
            "samples": args.samples,
            "statistic": "median",
            "cpu_pinning": "none",
            "memory_pinning": "none",
            "media_directory": manifest["media_directory"],
        },
        "results": results,
    }
    args.output.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2, allow_nan=False) + "\n",
        encoding="utf-8",
    )
    for name, item in results.items():
        print(f"[libavif] {name:<26} median={item['value']:.6f} ms/image", flush=True)
    print(
        f"[libavif] normalized {len(results)} scenarios over {args.samples} samples each (no pinning)",
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
