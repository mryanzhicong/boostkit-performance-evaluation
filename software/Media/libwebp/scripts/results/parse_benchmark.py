#!/usr/bin/env python3
"""Strictly validate the libwebp decode result and emit benchmark_libwebp.json.

The reference CSV alone cannot prove the sampling contract, so the parser also
reads the harness evidence: the number of measured samples, their values, the
published statistic and the pinned input digests must all agree.  Missing,
extra or non-positive samples are hard failures -- nothing is ever zero-filled.
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


def read_reference_csv(path: Path) -> dict[str, str]:
    if not path.is_file():
        raise ValidationError(f"reference CSV is missing: {path}")
    with path.open(newline="", encoding="utf-8") as stream:
        reader = csv.DictReader(stream)
        if reader.fieldnames != CSV_FIELDS:
            raise ValidationError(f"unexpected CSV header: {reader.fieldnames}")
        rows = list(reader)
    if len(rows) != 1:
        raise ValidationError(f"expected exactly one CSV row, found {len(rows)}")
    return rows[0]


def validate(
    csv_row: dict[str, str],
    evidence: dict,
    manifest: dict,
    warmups: int,
    samples: int,
) -> dict:
    scenario = manifest["scenarios"][0]
    name = scenario["name"]
    if csv_row["scenario"] != name:
        raise ValidationError(f"CSV scenario is {csv_row['scenario']!r}, expected {name!r}")
    if csv_row["status"] != "OK":
        raise ValidationError(f"CSV status is {csv_row['status']!r}, expected 'OK'")
    try:
        csv_iterations = int(csv_row["iterations"])
    except ValueError as error:
        raise ValidationError(f"CSV iterations is not an integer: {csv_row['iterations']!r}") from error
    if csv_iterations != samples:
        raise ValidationError(f"CSV iterations is {csv_iterations}, expected {samples}")
    try:
        csv_value = float(csv_row["ms_per_image"])
    except ValueError as error:
        raise ValidationError(f"CSV ms_per_image is not numeric: {csv_row['ms_per_image']!r}") from error

    if evidence.get("scenario") != name:
        raise ValidationError(f"evidence scenario is {evidence.get('scenario')!r}, expected {name!r}")
    measured = evidence.get("samples_ms")
    if not isinstance(measured, list):
        raise ValidationError("evidence samples_ms must be a list")
    if len(measured) != samples:
        raise ValidationError(f"evidence holds {len(measured)} samples, expected {samples}")
    if int(evidence.get("iterations", -1)) != samples:
        raise ValidationError("evidence iterations disagree with the requested samples")
    if int(evidence.get("warmups", -1)) != warmups:
        raise ValidationError("evidence warm-ups disagree with the requested warm-ups")
    if evidence.get("statistic") != "median":
        raise ValidationError(f"evidence statistic is {evidence.get('statistic')!r}, expected 'median'")
    for value in measured:
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            raise ValidationError(f"sample is not numeric: {value!r}")
        if not (value > 0):
            raise ValidationError(f"sample must be positive: {value!r}")

    computed_median = statistics.median(measured)
    if abs(computed_median - csv_value) > 1e-6:
        raise ValidationError(
            f"CSV median {csv_value} disagrees with the samples ({computed_median})"
        )

    if evidence.get("cpu_pinning") != "none" or evidence.get("memory_pinning") != "none":
        raise ValidationError("evidence reports CPU or memory pinning; this case forbids pinning")
    if int(evidence.get("cpus_allowed", 0)) < 1:
        raise ValidationError("evidence does not record the allowed CPU set")
    if int(evidence.get("observed_threads", 0)) != int(scenario["native_threads"]):
        raise ValidationError(
            f"observed {evidence.get('observed_threads')} dwebp threads, "
            f"expected {scenario['native_threads']}"
        )

    video = manifest["videos"][scenario["video"]]
    if evidence["source"]["sha256"] != video["sha256"]:
        raise ValidationError("source sha256 differs from the manifest")
    if evidence["source"]["bytes"] != video["bytes"]:
        raise ValidationError("source size differs from the manifest")
    if evidence["webp_sha256"] != video["webp_sha256"]:
        raise ValidationError("generated WebP differs from the pinned digest")
    if evidence["decoded_pam_sha256"] != video["decoded_pam_sha256"]:
        raise ValidationError("decoded PAM differs from the pinned digest")
    if evidence["png_sha256"] != video["png_sha256"]:
        raise ValidationError("generated PNG differs from the pinned digest")

    return {
        "source_name": name,
        "group": scenario["group"],
        "subgroup": scenario["subgroup"],
        "value": computed_median,
        "unit": "ms",
        "direction": "lower_is_better",
        "mean_ms": statistics.mean(measured),
        "median_ms": computed_median,
        "samples": [float(value) for value in measured],
        "statistic": "median",
        "cpus_allowed": int(evidence["cpus_allowed"]),
        "cpu_pinning": "none",
    }


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
        csv_row = read_reference_csv(args.csv)
        evidence = load_json(args.evidence)
        manifest = load_json(args.manifest)
        item = validate(csv_row, evidence, manifest, args.warmups, args.samples)
    except ValidationError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1
    except KeyError as error:
        print(f"ERROR: result is missing a required field: {error}", file=sys.stderr)
        return 1

    payload = {
        "benchmark": manifest["benchmark"],
        "software": "libwebp",
        "version": args.version,
        "architecture": args.architecture,
        "variant": args.variant,
        "generated_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "parameters": {
            "scenario": item["source_name"],
            "resolution": manifest["resolution"],
            "color_format": manifest["color_format"],
            "warmups": args.warmups,
            "samples": args.samples,
            "statistic": "median",
            "cpu_pinning": "none",
            "memory_pinning": "none",
            "media_directory": manifest["media_directory"],
            "source_sha256": evidence["source"]["sha256"],
            "webp_sha256": evidence["webp_sha256"],
        },
        "results": {item["source_name"]: item},
    }
    args.output.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2, allow_nan=False) + "\n",
        encoding="utf-8",
    )
    print(
        f"[libwebp] normalized {item['source_name']} "
        f"median={item['value']:.6f} ms/image over {args.samples} samples (no pinning)",
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
