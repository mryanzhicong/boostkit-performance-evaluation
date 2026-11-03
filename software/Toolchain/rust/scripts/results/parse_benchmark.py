#!/usr/bin/env python3
"""Extract strict metrics from an official rustc-perf SQLite database."""

from __future__ import annotations

import argparse
import json
import math
import re
import sqlite3
import sys
from pathlib import Path

COMPILE_METRICS = ("wall-time", "instructions:u")
PROFILE_NAMES = ("check", "debug", "opt")
# The runtime log line is "Finished <group>/<benchmark> (<n>/<total>)"; the
# database stores only the benchmark name, not the group prefix.
RUNTIME_FINISHED_RE = re.compile(r"^Finished \S+/(\S+) \(\d+/\d+\)")
FRONTEND_THREADS_DEFAULT = (1,)


class ParseError(ValueError):
    pass


def load_compile_benchmarks(benchmarks_dir: Path) -> dict[str, tuple[int, ...]]:
    """Map every Primary compile benchmark to its frontend thread counts."""
    benchmarks: dict[str, tuple[int, ...]] = {}
    for entry in sorted(benchmarks_dir.iterdir()):
        if not (entry / "Cargo.toml").is_file():
            continue
        config_path = entry / "perf-config.json"
        payload = json.loads(config_path.read_text(encoding="utf-8"))
        if payload.get("category") != "primary":
            continue
        threads = payload.get("frontend_threads", FRONTEND_THREADS_DEFAULT)
        benchmarks[entry.name] = tuple(sorted(int(t) for t in threads))
    if not benchmarks:
        raise ParseError(f"no Primary compile benchmarks found under {benchmarks_dir}")
    return benchmarks


def load_runtime_benchmarks(runtime_log: Path) -> set[str]:
    """Collect the benchmark names the runtime run reported as finished."""
    names: set[str] = set()
    for line in runtime_log.read_text(encoding="utf-8", errors="replace").splitlines():
        match = RUNTIME_FINISHED_RE.match(line.strip())
        if match:
            names.add(match.group(1))
    if not names:
        raise ParseError("runtime log contains no finished benchmark rows")
    return names


def fetch_compile_rows(conn: sqlite3.Connection, artifact_id: str, target: str) -> dict[tuple, float]:
    rows: dict[tuple, float] = {}
    # The collector writes one row per measured iteration; the upstream site
    # reports the minimum value per series, so aggregate the same way.
    for crate, profile, scenario, threads, metric, value in conn.execute(
        """
        SELECT ps."crate", ps.profile, ps.scenario, ps.frontend_threads, ps.metric,
               MIN(p.value)
        FROM pstat AS p
        JOIN pstat_series AS ps ON ps.id = p.series
        JOIN artifact AS a ON a.id = p.aid
        WHERE a.name = ? AND ps.target = ? AND ps.backend = 'llvm'
          AND ps.metric IN ('wall-time', 'instructions:u')
        GROUP BY ps."crate", ps.profile, ps.scenario, ps.frontend_threads, ps.metric
        """,
        (artifact_id, target),
    ):
        key = (crate, profile, scenario, int(threads), metric)
        if key in rows:
            raise ParseError(f"duplicate compile measurement for {key}")
        rows[key] = float(value)
    return rows


def fetch_runtime_rows(conn: sqlite3.Connection, artifact_id: str, target: str) -> dict[tuple, float]:
    rows: dict[tuple, float] = {}
    # Same aggregation as the upstream site: minimum over all iterations.
    for benchmark, metric, value in conn.execute(
        """
        SELECT rs.benchmark, rs.metric, MIN(rp.value)
        FROM runtime_pstat AS rp
        JOIN runtime_pstat_series AS rs ON rs.id = rp.series
        JOIN artifact AS a ON a.id = rp.aid
        WHERE a.name = ? AND rs.target = ? AND rs.metric IN ('wall-time', 'instructions:u')
        GROUP BY rs.benchmark, rs.metric
        """,
        (artifact_id, target),
    ):
        key = (benchmark, metric)
        if key in rows:
            raise ParseError(f"duplicate runtime measurement for {key}")
        rows[key] = float(value)
    return rows


def expected_compile_keys(benchmarks: dict[str, tuple[int, ...]]) -> set[tuple]:
    keys: set[tuple] = set()
    for crate, thread_counts in benchmarks.items():
        for profile in PROFILE_NAMES:
            for threads in thread_counts:
                for metric in COMPILE_METRICS:
                    keys.add((crate, profile, "full", threads, metric))
    return keys


def build_results(
    compile_rows: dict[tuple, float],
    runtime_rows: dict[tuple, float],
) -> tuple[dict, list[dict], list[dict]]:
    results: dict[str, dict] = {}
    compile_measurements: list[dict] = []
    runtime_measurements: list[dict] = []

    def add(name: str, value: float, unit: str, group: str) -> None:
        if not math.isfinite(value) or value <= 0:
            raise ParseError(f"non-positive or non-finite measurement for {name}")
        results[name] = {
            "value": value, "unit": unit,
            "direction": "lower_is_better", "group": group,
        }

    for (crate, profile, _scenario, threads, metric), value in sorted(compile_rows.items()):
        label = "wall-time" if metric == "wall-time" else "instructions"
        unit = "s" if metric == "wall-time" else "instructions"
        name = f"compile/{crate}/{profile}/threads={threads}/{label}"
        add(name, value, unit, "compile")
        compile_measurements.append({
            "crate": crate, "profile": profile, "scenario": "full",
            "frontend_threads": threads, "metric": metric,
            "value": value, "unit": unit, "source_name": name,
        })
    for (benchmark, metric), value in sorted(runtime_rows.items()):
        # The upstream runtime suite records wall time in nanoseconds.
        if metric == "wall-time":
            value_ms = value / 1_000_000
            name = f"runtime/{benchmark}/wall-time"
            add(name, value_ms, "ms", "runtime")
            runtime_measurements.append({
                "benchmark": benchmark, "metric": metric,
                "value_ns": value, "value": value_ms, "unit": "ms",
                "source_name": name,
            })
        else:
            name = f"runtime/{benchmark}/instructions"
            add(name, value, "instructions", "runtime")
            runtime_measurements.append({
                "benchmark": benchmark, "metric": metric,
                "value": value, "unit": "instructions", "source_name": name,
            })
    return results, compile_measurements, runtime_measurements


def parse_benchmark(
    database: Path,
    benchmarks_dir: Path,
    runtime_log: Path,
    rustc_version_file: Path,
    target_triple: str,
    artifact_id: str,
) -> dict:
    compile_benchmarks = load_compile_benchmarks(benchmarks_dir)
    runtime_expected = load_runtime_benchmarks(runtime_log)
    connection = sqlite3.connect(f"file:{database}?mode=ro", uri=True)
    try:
        compile_rows = fetch_compile_rows(connection, artifact_id, target_triple)
        runtime_rows = fetch_runtime_rows(connection, artifact_id, target_triple)
    finally:
        connection.close()

    expected = expected_compile_keys(compile_benchmarks)
    actual = set(compile_rows)
    missing = expected - actual
    unexpected = actual - expected
    if missing:
        raise ParseError(
            f"missing {len(missing)} compile measurements, e.g. {sorted(missing)[:3]}"
        )
    if unexpected:
        raise ParseError(
            f"unexpected {len(unexpected)} compile measurements, e.g. {sorted(unexpected)[:3]}"
        )

    runtime_measured = {benchmark for (benchmark, _metric) in runtime_rows}
    if runtime_measured != runtime_expected:
        raise ParseError(
            "runtime benchmarks in the database do not match the executed run: "
            f"missing={sorted(runtime_expected - runtime_measured)[:3]} "
            f"unexpected={sorted(runtime_measured - runtime_expected)[:3]}"
        )
    runtime_metrics = {metric for (_b, metric) in runtime_rows}
    if "wall-time" not in runtime_metrics:
        raise ParseError("runtime measurements are missing wall-time")
    instructions_recorded = "instructions:u" in runtime_metrics
    if instructions_recorded and len(runtime_rows) != 2 * len(runtime_expected):
        raise ParseError("runtime instruction counts are only partially recorded")

    results, compile_measurements, runtime_measurements = build_results(
        compile_rows, runtime_rows
    )
    rustc_version = rustc_version_file.read_text(encoding="utf-8").strip()
    return {
        "parameters": {
            "suite": "rustc-perf",
            "rustc_perf_revision": "9fa958a70781ab8abe5ee9e0875f0a9a62ecb20c",
            "profiles": list(PROFILE_NAMES),
            "scenarios": ["full"],
            "category": "primary",
            "compile_iterations": 1,
            "runtime_iterations": 5,
            "benchmark_id": artifact_id,
        },
        "runtime_context": {
            "rustc_version": rustc_version,
            "target_triple": target_triple,
            "runtime_instructions_recorded": instructions_recorded,
        },
        "expected": {
            "compile_benchmarks": len(compile_benchmarks),
            "compile_series": len(expected),
            "runtime_benchmarks": len(runtime_expected),
        },
        "compile_measurements": compile_measurements,
        "runtime_measurements": runtime_measurements,
        "results": results,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--results-dir", type=Path, required=True)
    parser.add_argument("--database", type=Path, required=True)
    parser.add_argument("--compile-benchmarks", type=Path, required=True)
    parser.add_argument("--runtime-log", type=Path, required=True)
    parser.add_argument("--rustc-version-file", type=Path, required=True)
    parser.add_argument("--target-triple", required=True)
    parser.add_argument("--artifact-id", required=True)
    args = parser.parse_args()
    try:
        payload = parse_benchmark(
            args.database, args.compile_benchmarks, args.runtime_log,
            args.rustc_version_file, args.target_triple, args.artifact_id,
        )
        destination = args.results_dir / "benchmark_rust.json"
        destination.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    except (OSError, ValueError, sqlite3.Error, json.JSONDecodeError) as exc:
        print(f"[rust] ERROR: {exc}", file=sys.stderr)
        return 1
    print(
        f"[rust] parsed {len(payload['results'])} metrics from "
        f"{payload['expected']['compile_benchmarks']} compile benchmarks "
        f"and {payload['expected']['runtime_benchmarks']} runtime benchmarks"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
