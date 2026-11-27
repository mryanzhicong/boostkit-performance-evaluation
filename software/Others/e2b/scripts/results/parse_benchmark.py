#!/usr/bin/env python3
"""Parse sandbox-bench JSON reports into E2B sandbox-creation metrics.

Each measured sample is one ``sandbox-bench`` invocation with ``--output``, so it
writes a JSON report carrying ``summary`` (planned/success/failed, success_rate,
latency percentiles, throughput), ``delete_summary`` and the per-request
``rounds[].events[]``.  The parser only reads those fields; it never re-runs,
never zero-fills and never falls back to a partial matrix.  A sample that missed
a request or lost one to an HTTP error is a hard failure: the metric set would
otherwise describe a different workload than the one the README promises.
"""

from __future__ import annotations

import argparse
import json
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path

# key suffix,             source path in the report,      unit,           direction
METRICS = (
    ("success-rate", "summary.success_rate", "%", "higher_is_better"),
    ("latency-p50", "summary.p50_ms", "ms", "lower_is_better"),
    ("latency-p95", "summary.p95_ms", "ms", "lower_is_better"),
    ("latency-p99", "summary.p99_ms", "ms", "lower_is_better"),
    ("throughput", "summary.throughput_per_sec", "sandboxes/s", "higher_is_better"),
    ("delete-latency-p50", "delete_summary.p50_ms", "ms", "lower_is_better"),
)

DEFAULT_LEVELS = (1, 10, 20)
SUPPORTED_SCENARIOS = ("create", "snapshot")


class ParseError(RuntimeError):
    """Raised when a sample is missing, malformed, or numerically invalid."""


def _load_report(path: Path) -> dict:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except OSError as exc:
        raise ParseError(f"cannot read report {path}: {exc}") from exc
    except json.JSONDecodeError as exc:
        raise ParseError(f"invalid JSON in {path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise ParseError(f"report {path} is not a JSON object")
    return payload


def _dig(payload: dict, dotted: str, path: Path) -> float:
    node: object = payload
    for part in dotted.split("."):
        if not isinstance(node, dict) or part not in node:
            raise ParseError(f"report {path} is missing {dotted}")
        node = node[part]
    if isinstance(node, bool) or not isinstance(node, (int, float)):
        raise ParseError(f"report {path} field {dotted} is not numeric: {node!r}")
    value = float(node)
    if value != value or value in (float("inf"), float("-inf")):
        raise ParseError(f"report {path} field {dotted} is not finite: {value!r}")
    return value


def _validate_report(payload: dict, path: Path, expected_total: int) -> None:
    summary = payload.get("summary")
    delete_summary = payload.get("delete_summary")
    if not isinstance(summary, dict) or not isinstance(delete_summary, dict):
        raise ParseError(f"report {path} must carry both summary and delete_summary blocks")
    for key in ("planned", "success", "failed", "not_executed"):
        if not isinstance(summary.get(key), int):
            raise ParseError(f"report {path} must report an integer summary.{key}")
    if summary["planned"] != expected_total:
        raise ParseError(
            f"report {path} planned={summary['planned']} does not match total={expected_total}"
        )
    if summary["failed"] or summary["not_executed"]:
        raise ParseError(
            f"report {path} lost requests: failed={summary['failed']} "
            f"not_executed={summary['not_executed']}"
        )
    if summary["success"] != expected_total:
        raise ParseError(
            f"report {path} success={summary['success']} does not match total={expected_total}"
        )
    rate = _dig(payload, "summary.success_rate", path)
    if rate != 1.0:
        raise ParseError(f"report {path} success_rate is {rate}, expected 1.0")
    delete_rate = _dig(payload, "delete_summary.success_rate", path)
    if delete_rate != 1.0:
        raise ParseError(f"report {path} delete_summary.success_rate is {delete_rate}, expected 1.0")
    events = []
    for item in payload.get("rounds") or []:
        events.extend(item.get("events") or [])
    if len(events) != expected_total:
        raise ParseError(
            f"report {path} carries {len(events)} events, expected {expected_total}"
        )
    if any(event.get("timed_out") for event in events):
        raise ParseError(f"report {path} has timed-out requests")


def _sample_files(
    runs_dir: Path, scenario: str, level: int, warmups: int, samples: int
) -> list[Path]:
    directory = runs_dir / scenario / f"c{level}"
    if not directory.is_dir():
        raise ParseError(f"missing scenario directory: {directory}")
    for index in range(1, warmups + 1):
        path = directory / f"warmup{index}.log"
        if not path.is_file():
            raise ParseError(f"missing warmup log: {path}")
    reports = [directory / f"rep{index}.json" for index in range(1, samples + 1)]
    for path in reports:
        if not path.is_file():
            raise ParseError(f"missing sample report: {path}")
        log_path = path.with_suffix(".log")
        if not log_path.is_file():
            raise ParseError(f"missing sample log: {log_path}")
    expected = {path.name for path in reports}
    unexpected = sorted(
        path.name
        for path in directory.glob("rep*.json")
        if path.name not in expected
    )
    if unexpected:
        raise ParseError(f"unexpected sample reports in {directory}: {', '.join(unexpected)}")
    return reports


def collect(
    runs_dir: Path,
    warmups: int,
    samples: int,
    levels: tuple[int, ...] = DEFAULT_LEVELS,
    scenarios: tuple[str, ...] = ("create",),
    total: int = 60,
) -> tuple[dict, dict]:
    results: dict[str, dict] = {}
    samples_out: dict[str, list[float]] = {}
    for scenario in scenarios:
        for level in levels:
            reports = _sample_files(runs_dir, scenario, level, warmups, samples)
            values: dict[str, list[float]] = {name: [] for name, *_ in METRICS}
            for path in reports:
                payload = _load_report(path)
                _validate_report(payload, path, total)
                for name, source, _unit, _direction in METRICS:
                    value = _dig(payload, source, path)
                    if source == "summary.success_rate":
                        value *= 100.0
                    if value < 0:
                        raise ParseError(f"report {path} field {source} is negative")
                    values[name].append(value)
            group = f"concurrency_{level}"
            for name, source, unit, direction in METRICS:
                series = values[name]
                if len(series) != samples:
                    raise ParseError(
                        f"{scenario}/{group}/{name} has {len(series)} samples, expected {samples}"
                    )
                metric_id = f"sandbox-{scenario}-{name}-c{level}"
                samples_out[metric_id] = series
                results[metric_id] = {
                    "group": group,
                    "scenario": scenario,
                    "source": f"sandbox-bench {source}",
                    "value": statistics.median(series),
                    "unit": unit,
                    "direction": direction,
                    "samples": len(series),
                    "sample_values": series,
                }
    return results, samples_out


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runs-dir", required=True)
    parser.add_argument("--results-dir", required=True)
    parser.add_argument("--warmups", type=int, default=1)
    parser.add_argument("--samples", type=int, default=6)
    parser.add_argument("--levels", default="1,10,20")
    parser.add_argument("--scenarios", default="create")
    parser.add_argument("--total", type=int, default=60)
    parser.add_argument("--version", default="2026.09")
    parser.add_argument("--architecture", default="aarch64")
    parser.add_argument("--variant", default="base")
    args = parser.parse_args(argv)

    runs_dir = Path(args.runs_dir)
    results_dir = Path(args.results_dir)
    results_dir.mkdir(parents=True, exist_ok=True)
    levels = tuple(int(item) for item in args.levels.split(",") if item.strip())
    scenarios = tuple(item.strip() for item in args.scenarios.split(",") if item.strip())
    if args.samples < 5:
        print("ERROR: at least 5 measured samples are required", file=sys.stderr)
        return 40
    if args.warmups < 1:
        print("ERROR: at least 1 warmup round is required", file=sys.stderr)
        return 40
    for scenario in scenarios:
        if scenario not in SUPPORTED_SCENARIOS:
            print(f"ERROR: unsupported scenario: {scenario}", file=sys.stderr)
            return 10

    try:
        results, samples = collect(runs_dir, args.warmups, args.samples, levels, scenarios, args.total)
    except ParseError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 40

    payload = {
        "software": "e2b",
        "version": args.version,
        "architecture": args.architecture,
        "variant": args.variant,
        "warmups": args.warmups,
        "samples": args.samples,
        "levels": list(levels),
        "scenarios": list(scenarios),
        "total_per_sample": args.total,
        "metric_count": len(results),
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "results": results,
    }
    (results_dir / "benchmark_e2b.json").write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    (results_dir / "samples.json").write_text(
        json.dumps(samples, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    for key, item in results.items():
        print(f"{key}: {item['value']:.4f} {item['unit']} ({item['direction']})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
