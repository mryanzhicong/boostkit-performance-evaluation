#!/usr/bin/env python3
"""Parse cube-bench JSON reports into CubeSandbox sandbox-creation metrics.

Each measured sample is one `cube-bench` invocation that exports a JSON report
(`-o report.json`). The report carries a `summary` block (success_rate,
throughput_qps) and a `create` block (count, avg, p50, p95, p99, max) plus the
per-request `raw` list. This parser only reads those fields; it never re-runs,
never zero-fills, and never falls back to a partial matrix.
"""

from __future__ import annotations

import argparse
import json
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path

METRICS = (
    # key,          source,                  unit,            direction
    ("sandbox-create-success-rate", "summary.success_rate", "%", "higher_is_better"),
    ("sandbox-create-latency-mean", "create.avg", "ms", "lower_is_better"),
    ("sandbox-create-latency-p95", "create.p95", "ms", "lower_is_better"),
    ("sandbox-create-latency-p99", "create.p99", "ms", "lower_is_better"),
    ("sandbox-create-throughput", "summary.throughput_qps", "sandboxes/s", "higher_is_better"),
)

DEFAULT_LEVELS = (1, 20, 50)


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
    create = payload.get("create")
    if not isinstance(summary, dict) or not isinstance(create, dict):
        raise ParseError(f"report {path} must carry both summary and create blocks")
    rate = _dig(payload, "summary.success_rate", path)
    if not 0.0 < rate <= 1.0:
        raise ParseError(f"report {path} success_rate out of (0, 1]: {rate}")
    successful = summary.get("successful")
    errors = summary.get("errors")
    if not isinstance(successful, int) or not isinstance(errors, int):
        raise ParseError(f"report {path} must report integer successful/errors counts")
    if successful + errors != expected_total:
        raise ParseError(
            f"report {path} successful+errors={successful + errors} does not match total={expected_total}"
        )
    # cube-bench only records latency for successful creates, so create.count
    # tracks the success count, not the attempted total.
    if create.get("count") != successful:
        raise ParseError(f"report {path} create.count != summary.successful")
    raw = payload.get("raw")
    if not isinstance(raw, list) or len(raw) != expected_total:
        raise ParseError(f"report {path} raw entries do not match total={expected_total}")


def _sample_files(runs_dir: Path, level: int, warmups: int, samples: int) -> tuple[list[Path], list[Path]]:
    scenario = runs_dir / f"c{level}"
    if not scenario.is_dir():
        raise ParseError(f"missing scenario directory: {scenario}")
    warmup_logs = [scenario / f"warmup{i}.log" for i in range(1, warmups + 1)]
    for path in warmup_logs:
        if warmups and not path.is_file():
            raise ParseError(f"missing warmup log: {path}")
    reports = [scenario / f"rep{i}.json" for i in range(1, samples + 1)]
    logs = [scenario / f"rep{i}.log" for i in range(1, samples + 1)]
    for path in reports:
        if not path.is_file():
            raise ParseError(f"missing sample report: {path}")
    for path in logs:
        if not path.is_file():
            raise ParseError(f"missing sample log: {path}")
    extras = sorted(p.name for p in scenario.glob("rep*.json"))
    expected = {p.name for p in reports}
    unexpected = [name for name in extras if name not in expected]
    if unexpected:
        raise ParseError(f"unexpected sample reports in {scenario}: {', '.join(unexpected)}")
    return warmup_logs, reports


def collect(
    runs_dir: Path,
    warmups: int,
    samples: int,
    levels: tuple[int, ...] = DEFAULT_LEVELS,
    total: int = 300,
) -> tuple[dict, dict]:
    results: dict[str, dict] = {}
    samples_out: dict[str, list[float]] = {}
    for level in levels:
        _, reports = _sample_files(runs_dir, level, warmups, samples)
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
                raise ParseError(f"{group}/{name} has {len(series)} samples, expected {samples}")
            # The Framework keys metrics by item name, so the concurrency level
            # has to be part of the identifier; `group` keeps the readable axis.
            metric_id = f"{name}-c{level}"
            samples_out[metric_id] = series
            results[metric_id] = {
                "group": group,
                "source": f"cube-bench {source}",
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
    parser.add_argument("--levels", default="1,20,50")
    parser.add_argument("--total", type=int, default=300)
    parser.add_argument("--version", default="0.8.0")
    parser.add_argument("--architecture", default="aarch64")
    parser.add_argument("--variant", default="base")
    args = parser.parse_args(argv)

    runs_dir = Path(args.runs_dir)
    results_dir = Path(args.results_dir)
    results_dir.mkdir(parents=True, exist_ok=True)
    levels = tuple(int(item) for item in args.levels.split(",") if item.strip())
    if args.samples < 5:
        print("ERROR: at least 5 measured samples are required", file=sys.stderr)
        return 40
    if args.warmups < 1:
        print("ERROR: at least 1 warmup round is required", file=sys.stderr)
        return 40

    try:
        results, samples = collect(runs_dir, args.warmups, args.samples, levels, args.total)
    except ParseError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 40

    payload = {
        "software": "cubesandbox",
        "version": args.version,
        "architecture": args.architecture,
        "variant": args.variant,
        "warmups": args.warmups,
        "samples": args.samples,
        "levels": list(levels),
        "total_per_sample": args.total,
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "results": results,
    }
    (results_dir / "benchmark_cubesandbox.json").write_text(
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
