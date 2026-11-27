#!/usr/bin/env python3
"""Strict result parser for the Celeborn single-node TPC-DS case.

The parser never invents a number: a missing sample, a missing statement, a
duplicated statement, a non-positive or non-finite duration and a statement set
that differs from the pinned manifest all fail the run.
"""

from __future__ import annotations

import argparse
import json
import math
import statistics
import sys
from pathlib import Path

WARMUP_SAMPLES = 1
MIN_MEASURED_SAMPLES = 5


class ParseError(RuntimeError):
    pass


def load_manifest(path: Path) -> list[str]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    statements = [entry["name"] for entry in payload.get("statements", [])]
    if not statements:
        raise ParseError(f"manifest lists no statements: {path}")
    return statements


def read_sample(path: Path, sample: int, statements: list[str]) -> dict:
    if not path.is_file():
        raise ParseError(f"missing sample file: {path}")
    application = None
    results: list[dict] = []
    summary = None
    shuffle_usage = None
    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        if not line.strip():
            continue
        try:
            record = json.loads(line)
        except json.JSONDecodeError as error:
            raise ParseError(f"{path}:{line_number}: invalid JSON ({error})") from error
        kind = record.get("record")
        if kind == "application":
            application = record
        elif kind == "statement":
            results.append(record)
        elif kind == "summary":
            summary = record
        elif kind == "shuffle_usage":
            # Measured inside the application, see scripts/workload/run_queries.py.
            shuffle_usage = record
        else:
            raise ParseError(f"{path}:{line_number}: unknown record type {kind!r}")
    if application is None:
        raise ParseError(f"{path}: no application record")
    if summary is None:
        raise ParseError(f"{path}: no summary record")
    if not results:
        raise ParseError(f"{path}: no statement results")
    if shuffle_usage is not None:
        stored = shuffle_usage.get("bytes")
        if not isinstance(stored, int) or stored <= 0:
            raise ParseError(
                f"{path}: the application reported an invalid Celeborn storage size {stored!r}"
            )
    if len(results) != len(statements):
        raise ParseError(f"{path}: expected {len(statements)} statement results, found {len(results)}")
    seen: dict[str, float] = {}
    for result in results:
        name = result.get("name")
        seconds = result.get("seconds")
        if name not in statements:
            raise ParseError(f"{path}: unexpected statement {name!r}")
        if name in seen:
            raise ParseError(f"{path}: duplicated statement {name!r}")
        if not isinstance(seconds, (int, float)) or not math.isfinite(seconds) or seconds <= 0:
            raise ParseError(f"{path}: statement {name!r} has an invalid duration {seconds!r}")
        seen[name] = float(seconds)
    missing = [name for name in statements if name not in seen]
    if missing:
        raise ParseError(f"{path}: missing statement results: {', '.join(missing)}")
    ordered = [seen[name] for name in statements]
    return {
        "sample": sample,
        "application_id": application.get("application_id"),
        "durations": ordered,
        "total_seconds": sum(ordered),
        "reported_total_seconds": summary.get("seconds"),
        "app_shuffle_bytes": (shuffle_usage or {}).get("bytes"),
    }


def percentile(values: list[float], fraction: float) -> float:
    if not values:
        raise ParseError("cannot compute a percentile of an empty series")
    ordered = sorted(values)
    if len(ordered) == 1:
        return ordered[0]
    position = (len(ordered) - 1) * fraction
    lower = math.floor(position)
    upper = math.ceil(position)
    if lower == upper:
        return ordered[int(position)]
    weight = position - lower
    return ordered[lower] * (1 - weight) + ordered[upper] * weight


def build_metrics(args: argparse.Namespace, statements: list[str], samples: list[dict]) -> list[dict]:
    measured = samples[WARMUP_SAMPLES:]
    if len(measured) < MIN_MEASURED_SAMPLES:
        raise ParseError(
            f"need at least {MIN_MEASURED_SAMPLES} measured samples after the warm-up run, got {len(measured)}"
        )
    per_statement = []
    for index, name in enumerate(statements):
        values = [sample["durations"][index] for sample in measured]
        per_statement.append((name, statistics.median(values)))
    medians = [value for _, value in per_statement]
    suite_seconds = statistics.median([sample["total_seconds"] for sample in measured])
    shuffle_bytes = args.shuffle_bytes
    if shuffle_bytes is not None and shuffle_bytes <= 0:
        raise ParseError(f"Celeborn reported no shuffle bytes for this run: {shuffle_bytes}")
    metrics = [
        {
            "key": "celeborn.tpcds.suite.elapsed",
            "value": round(suite_seconds, 3),
            "unit": "s",
            "direction": "lower_is_better",
            "group": "suite",
        },
        {
            "key": "celeborn.tpcds.statement.median.mean",
            "value": round(statistics.fmean(medians), 3),
            "unit": "s",
            "direction": "lower_is_better",
            "group": "statements",
        },
        {
            "key": "celeborn.tpcds.statement.median.p95",
            "value": round(percentile(medians, 0.95), 3),
            "unit": "s",
            "direction": "lower_is_better",
            "group": "statements",
        },
        {
            "key": "celeborn.tpcds.statements.executed",
            "value": len(statements),
            "unit": "statements",
            "direction": "higher_is_better",
            "group": "workload",
        },
        {
            "key": "celeborn.tpcds.scale_factor",
            "value": float(args.scale_factor),
            "unit": "factor",
            "direction": "higher_is_better",
            "group": "workload",
        },
    ]
    if shuffle_bytes is not None:
        metrics.extend(
            [
                {
                    "key": "celeborn.shuffle.bytes.written",
                    "value": shuffle_bytes,
                    "unit": "bytes",
                    "direction": "lower_is_better",
                    "group": "shuffle",
                },
                {
                    "key": "celeborn.shuffle.throughput",
                    "value": round(shuffle_bytes / suite_seconds / (1024 * 1024), 3),
                    "unit": "MB/s",
                    "direction": "higher_is_better",
                    "group": "shuffle",
                },
            ]
        )
    for name, median in per_statement:
        metrics.append(
            {
                "key": f"celeborn.tpcds.{name.removesuffix('.sql')}.median",
                "value": round(median, 3),
                "unit": "s",
                "direction": "lower_is_better",
                "group": name.removesuffix(".sql"),
            }
        )
    return metrics


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--results-dir", required=True)
    parser.add_argument("--manifest", required=True)
    parser.add_argument("--samples", required=True, type=int)
    parser.add_argument("--scale-factor", required=True)
    parser.add_argument("--shuffle-bytes", type=int)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    results_dir = Path(args.results_dir)
    try:
        statements = load_manifest(Path(args.manifest))
        samples = []
        for sample in range(1, args.samples + 1):
            sample_dir = results_dir / "runs" / f"sample{sample}"
            samples.append(read_sample(sample_dir / "queries.jsonl", sample, statements))
        metrics = build_metrics(args, statements, samples)
    except ParseError as error:
        print(f"[celeborn] ERROR: {error}", file=sys.stderr)
        return 2

    payload = {
        "software": "celeborn",
        "version": "0.5.3",
        "scale_factor": float(args.scale_factor),
        "statements": len(statements),
        "samples": {
            "total": args.samples,
            "warmup": WARMUP_SAMPLES,
            "measured": args.samples - WARMUP_SAMPLES,
        },
        "suite_seconds": {f"sample{sample['sample']}": round(sample["total_seconds"], 3) for sample in samples},
        "shuffle_bytes": args.shuffle_bytes,
        # The Framework reads ``results`` as a mapping of metric name to an object
        # carrying value/unit/direction/group.
        "results": {
            metric["key"]: {key: value for key, value in metric.items() if key != "key"}
            for metric in metrics
        },
    }
    Path(args.output).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"[celeborn] parsed {len(metrics)} metrics from {args.samples} samples", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
