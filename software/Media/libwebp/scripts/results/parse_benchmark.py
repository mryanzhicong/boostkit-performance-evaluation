#!/usr/bin/env python3
"""Strictly validate the libwebp lossless encode results and emit the result.

The reference CSV (the same schema as the open-box material
``Test/libwebp/scripts/bench.py`` @ 21154155) has one row per generated
dashboard scenario and publishes the arithmetic mean of the timed iterations.
The CSV alone cannot prove the sampling contract, so the parser cross-checks the
harness evidence: scenario order, sample count, the finite positive samples, the
published statistic, the no-pinning declarations and the recorded input/output
digests.  Missing, extra or non-positive samples are hard failures -- nothing is
ever zero-filled.
"""

from __future__ import annotations

import argparse
import csv
import json
import math
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path

CSV_FIELDS = ["scenario", "iterations", "ms_per_image", "status"]
MIN_SAMPLES = 5
EXPECTED_SCENARIOS = 2
MEAN_TOLERANCE = 1e-6


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
        rows = list(reader)
    if len(rows) != EXPECTED_SCENARIOS:
        raise ValidationError(
            f"expected exactly {EXPECTED_SCENARIOS} CSV rows, found {len(rows)}"
        )
    return rows


def require_digest(case: dict, field: str, scenario: str) -> str:
    value = case.get(field)
    if not isinstance(value, str) or len(value) != 64 or any(
        character not in "0123456789abcdef" for character in value
    ):
        raise ValidationError(f"scenario {scenario!r} has an invalid {field}: {value!r}")
    return value


def validate(
    rows: list[dict[str, str]],
    evidence: dict,
    manifest: dict,
    warmups: int,
    samples: int,
) -> dict[str, dict]:
    scenarios = manifest.get("scenarios")
    if not isinstance(scenarios, list) or len(scenarios) != EXPECTED_SCENARIOS:
        raise ValidationError(
            f"manifest must declare exactly {EXPECTED_SCENARIOS} scenarios"
        )
    expected_names = [scenario["name"] for scenario in scenarios]

    order = evidence.get("scenario_order")
    if order != expected_names:
        raise ValidationError(
            f"evidence scenario order is {order!r}, expected {expected_names!r}"
        )
    if int(evidence.get("iterations", -1)) != samples:
        raise ValidationError("evidence iterations disagree with the requested samples")
    if int(evidence.get("warmups", -1)) != warmups:
        raise ValidationError("evidence warm-ups disagree with the requested warm-ups")
    if evidence.get("statistic") != "mean":
        raise ValidationError(
            f"evidence statistic is {evidence.get('statistic')!r}, expected 'mean'"
        )
    cases = evidence.get("cases")
    if not isinstance(cases, dict):
        raise ValidationError("evidence cases must be an object keyed by scenario")
    if list(cases) != expected_names:
        raise ValidationError(
            f"evidence cases are {list(cases)!r}, expected {expected_names!r}"
        )

    if evidence.get("cpu_pinning") != "none" or evidence.get("memory_pinning") != "none":
        raise ValidationError("evidence reports CPU or memory pinning; this case forbids pinning")
    try:
        cpus_allowed = int(evidence.get("cpus_allowed", 0))
    except (TypeError, ValueError) as error:
        raise ValidationError("evidence cpus_allowed is not an integer") from error
    if cpus_allowed < 1:
        raise ValidationError("evidence does not record the allowed CPU set")

    results: dict[str, dict] = {}
    for row, scenario in zip(rows, scenarios):
        name = scenario["name"]
        if row["scenario"] != name:
            raise ValidationError(f"CSV scenario is {row['scenario']!r}, expected {name!r}")
        if row["status"] != "OK":
            raise ValidationError(f"CSV status is {row['status']!r}, expected 'OK'")
        try:
            csv_iterations = int(row["iterations"])
        except ValueError as error:
            raise ValidationError(
                f"CSV iterations is not an integer: {row['iterations']!r}"
            ) from error
        if csv_iterations != samples:
            raise ValidationError(f"CSV iterations is {csv_iterations}, expected {samples}")
        try:
            csv_value = float(row["ms_per_image"])
        except ValueError as error:
            raise ValidationError(
                f"CSV ms_per_image is not numeric: {row['ms_per_image']!r}"
            ) from error

        case = cases[name]
        if not isinstance(case, dict):
            raise ValidationError(f"evidence case {name!r} must be an object")
        if case.get("status") != "OK":
            raise ValidationError(f"evidence case {name!r} status is not 'OK'")
        if case.get("statistic") != "mean":
            raise ValidationError(f"evidence case {name!r} statistic is not 'mean'")
        for field in ("group", "subgroup"):
            if case.get(field) != scenario[field]:
                raise ValidationError(
                    f"evidence case {name!r} {field} is {case.get(field)!r}, "
                    f"expected {scenario[field]!r}"
                )
        measured = case.get("samples_ms")
        if not isinstance(measured, list):
            raise ValidationError(f"evidence case {name!r} samples_ms must be a list")
        if len(measured) != samples:
            raise ValidationError(
                f"evidence case {name!r} holds {len(measured)} samples, expected {samples}"
            )
        if int(case.get("iterations", -1)) != samples:
            raise ValidationError(
                f"evidence case {name!r} iterations disagree with the requested samples"
            )
        for value in measured:
            if isinstance(value, bool) or not isinstance(value, (int, float)):
                raise ValidationError(f"sample is not numeric: {value!r}")
            if not math.isfinite(float(value)):
                raise ValidationError(f"sample must be finite: {value!r}")
            if not (value > 0):
                raise ValidationError(f"sample must be positive: {value!r}")

        computed_mean = statistics.mean(measured)
        if abs(computed_mean - csv_value) > MEAN_TOLERANCE:
            raise ValidationError(
                f"CSV value {csv_value} for {name!r} disagrees with the mean of the "
                f"samples ({computed_mean})"
            )

        unit = scenario.get("unit", "ms")
        direction = scenario.get("direction", "lower_is_better")
        if direction not in {"higher_is_better", "lower_is_better", "neutral"}:
            raise ValidationError(f"scenario {name!r} has an invalid direction: {direction!r}")
        results[name] = {
            "source_name": name,
            "group": scenario["group"],
            "subgroup": scenario["subgroup"],
            "value": computed_mean,
            "unit": unit,
            "direction": direction,
            "mean_ms": computed_mean,
            "samples": [float(value) for value in measured],
            "iterations": samples,
            "statistic": "mean",
            "width": int(scenario["width"]),
            "height": int(scenario["height"]),
            "input_sha256": require_digest(case, "input_sha256", name),
            "output_sha256": require_digest(case, "output_sha256", name),
            "cpus_allowed": cpus_allowed,
            "cpu_pinning": "none",
            "memory_pinning": "none",
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
        rows = read_reference_csv(args.csv)
        evidence = load_json(args.evidence)
        manifest = load_json(args.manifest)
        results = validate(rows, evidence, manifest, args.warmups, args.samples)
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
            "generator": manifest.get("generator", ""),
            "warmups": args.warmups,
            "samples": args.samples,
            "statistic": "mean",
            "cpu_pinning": "none",
            "memory_pinning": "none",
        },
        "results": results,
    }
    args.output.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2, allow_nan=False) + "\n",
        encoding="utf-8",
    )
    for name, item in results.items():
        print(
            f"[libwebp] normalized {name} "
            f"mean={item['value']:.6f} ms/image over {args.samples} samples (no pinning)",
            flush=True,
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
