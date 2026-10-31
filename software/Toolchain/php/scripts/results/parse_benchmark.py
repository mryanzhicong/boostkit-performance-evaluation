#!/usr/bin/env python3
"""Normalize the PHP 8.5.12 workload matrix from the recorded repetitions.

Every scenario contributes two metrics: the wall-clock median of the measured
PHP process (seconds, lower is better) and the median peak resident set size of
the measured process (MiB, lower is better).  Raw per-repetition logs and
timing JSON files stay in ``runs/<scenario>/`` as the primary evidence; this
script only aggregates them and fails loudly when a declared scenario is
incomplete, a repetition failed, a sample is missing or non-finite, the
workload checksum differs from the committed expectation, or the matrix
directory contains an unexpected scenario.
"""

from __future__ import annotations

import json
import math
import os
import re
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

RESULT_PATTERN = re.compile(
    r"RESULT\s+scenario=([A-Za-z0-9_]+)\s+.*?checksum=(-?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?)"
)
INT_PATTERN = re.compile(r"^-?\d+$")
FLOAT_PATTERN = re.compile(r"^-?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?$")
DEFAULT_MANIFEST = Path(__file__).resolve().parents[2] / "benchmarks" / "scenarios.psv"


def fail(message: str) -> None:
    print(f"[php-parse] ERROR: {message}", file=sys.stderr)


class MatrixError(RuntimeError):
    """A matrix, sample or workload validation failure."""


def load_manifest(path: Path) -> list[dict[str, Any]]:
    if not path.is_file():
        raise MatrixError(f"workload matrix manifest does not exist: {path}")
    rows: list[dict[str, Any]] = []
    seen: set[str] = set()
    for lineno, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        line = raw.rstrip()
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        fields = line.split("|")
        if len(fields) != 9:
            raise MatrixError(
                f"manifest line {lineno} must have 9 pipe-separated fields, got {len(fields)}"
            )
        scenario, dimension, runner, target, scale, check, expected, tolerance, workload = (
            field.strip() for field in fields
        )
        if not scenario or scenario in seen:
            raise MatrixError(f"manifest line {lineno} has an empty or duplicate scenario name")
        seen.add(scenario)
        if runner not in {"php_script", "php_upstream_bench"}:
            raise MatrixError(f"manifest line {lineno} has an unsupported runner: {runner}")
        if check not in {"int", "float", "marker"}:
            raise MatrixError(f"manifest line {lineno} has an unsupported check: {check}")
        if check in {"int", "float"}:
            if not scale:
                raise MatrixError(f"manifest line {lineno} needs a scale for a {check} check")
            if check == "int" and not INT_PATTERN.match(expected):
                raise MatrixError(f"manifest line {lineno} needs an integer expectation")
            if check == "float" and not FLOAT_PATTERN.match(expected):
                raise MatrixError(f"manifest line {lineno} needs a float expectation")
            if check == "float" and not tolerance:
                raise MatrixError(f"manifest line {lineno} needs a tolerance for a float check")
            if tolerance:
                float(tolerance)
        if check == "marker" and not expected:
            raise MatrixError(f"manifest line {lineno} needs a marker expectation")
        rows.append(
            {
                "scenario": scenario,
                "dimension": dimension,
                "runner": runner,
                "target": target,
                "scale": int(scale) if scale else None,
                "check": check,
                "expected": expected,
                "tolerance": float(tolerance) if tolerance else None,
                "workload": workload,
            }
        )
    if not rows:
        raise MatrixError(f"workload matrix manifest is empty: {path}")
    return rows


def load_samples(scenario_dir: Path, reps: int, row: dict[str, Any]) -> list[dict[str, Any]]:
    samples: list[dict[str, Any]] = []
    for index in range(1, reps + 1):
        sample_path = scenario_dir / f"rep{index}.json"
        log_path = scenario_dir / f"rep{index}.log"
        if not sample_path.is_file():
            raise MatrixError(f"missing repetition sample: {sample_path}")
        if not log_path.is_file():
            raise MatrixError(f"missing raw repetition log: {log_path}")
        try:
            payload = json.loads(sample_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            raise MatrixError(f"invalid repetition sample {sample_path}: {exc}") from exc
        if not isinstance(payload, dict):
            raise MatrixError(f"repetition sample is not an object: {sample_path}")
        exit_code = payload.get("exit_code")
        if exit_code != 0:
            raise MatrixError(
                f"repetition {sample_path.name} for {scenario_dir.name} failed "
                f"with exit code {exit_code} (timed_out={payload.get('timed_out')})"
            )
        if payload.get("timed_out") is not False:
            raise MatrixError(
                f"repetition {sample_path.name} for {scenario_dir.name} was not a completed run"
            )
        wall = payload.get("wall_seconds")
        rss = payload.get("max_rss_mib")
        if isinstance(wall, bool) or not isinstance(wall, (int, float)):
            raise MatrixError(f"repetition {sample_path.name} has no numeric wall time")
        if isinstance(rss, bool) or not isinstance(rss, (int, float)):
            raise MatrixError(f"repetition {sample_path.name} has no numeric RSS")
        if not math.isfinite(float(wall)) or wall <= 0:
            raise MatrixError(
                f"repetition {sample_path.name} wall time must be a positive finite number"
            )
        if not math.isfinite(float(rss)) or rss <= 0:
            raise MatrixError(f"repetition {sample_path.name} RSS must be a positive finite number")
        if log_path.stat().st_size == 0:
            raise MatrixError(f"raw repetition log is empty: {log_path}")
        checksum = validate_log(log_path.read_text(encoding="utf-8", errors="replace"), row)
        samples.append(
            {
                "repetition": index,
                "wall_seconds": round(float(wall), 6),
                "max_rss_mib": round(float(rss), 3),
                "checksum": checksum,
                "log": f"rep{index}.log",
            }
        )
    return samples


def validate_log(text: str, row: dict[str, Any]) -> str:
    scenario = row["scenario"]
    check = row["check"]
    if check == "marker":
        if row["expected"] not in text:
            raise MatrixError(
                f"scenario {scenario} log is missing the required marker {row['expected']!r}"
            )
        return row["expected"]
    matches = RESULT_PATTERN.findall(text)
    if len(matches) != 1:
        raise MatrixError(
            f"scenario {scenario} log must contain exactly one RESULT line, found {len(matches)}"
        )
    result_scenario, checksum_text = matches[0]
    if result_scenario != scenario:
        raise MatrixError(f"scenario {scenario} log reports RESULT scenario={result_scenario}")
    if check == "int":
        if not INT_PATTERN.match(checksum_text):
            raise MatrixError(f"scenario {scenario} checksum is not an integer: {checksum_text}")
        value = int(checksum_text)
        expected = int(row["expected"])
        if value != expected:
            raise MatrixError(
                f"scenario {scenario} checksum {value} differs from the committed value {expected}"
            )
        if value == 0:
            raise MatrixError(f"scenario {scenario} checksum must not be zero")
        return str(value)
    value = float(checksum_text)
    if not math.isfinite(value) or value == 0.0:
        raise MatrixError(f"scenario {scenario} checksum must be finite and non-zero")
    expected = float(row["expected"])
    tolerance = row["tolerance"] or 0.0
    if abs(value - expected) > tolerance * max(1.0, abs(expected)):
        raise MatrixError(
            f"scenario {scenario} checksum {value!r} differs from the committed value "
            f"{expected!r} beyond the {tolerance:g} relative tolerance"
        )
    return f"{value!r}"


def summarize(values: list[float]) -> dict[str, float]:
    return {
        "median": round(float(statistics.median(values)), 6),
        "mean": round(float(statistics.fmean(values)), 6),
        "min": round(float(min(values)), 6),
        "max": round(float(max(values)), 6),
        "stdev": round(float(statistics.stdev(values)), 6) if len(values) > 1 else 0.0,
    }


def build_metric(
    source_name: str,
    row: dict[str, Any],
    value: float,
    unit: str,
    direction: str,
    statistics_payload: dict[str, float],
    samples: list[float],
) -> dict[str, Any]:
    return {
        "source_name": source_name,
        "scenario": row["scenario"],
        "dimension": row["dimension"],
        "runner": row["runner"],
        "scale": row["scale"],
        "workload": row["workload"],
        "value": value,
        "unit": unit,
        "direction": direction,
        **statistics_payload,
        "samples": samples,
    }


def main() -> int:
    if len(sys.argv) not in (3, 4):
        print(
            "usage: parse_benchmark.py RUNS_DIRECTORY NORMALIZED_OUTPUT [SCENARIOS_MANIFEST]",
            file=sys.stderr,
        )
        return 1
    runs_dir = Path(sys.argv[1])
    normalized_output = Path(sys.argv[2])
    manifest_path = Path(sys.argv[3]) if len(sys.argv) == 4 else DEFAULT_MANIFEST
    try:
        version = os.environ["SOFTWARE_VERSION"]
        architecture = os.environ["EXPECTED_ARCH"]
        variant = os.environ.get("PERF_VARIANT", "base")
    except KeyError as exc:
        fail(f"missing environment variable: {exc}")
        return 1
    try:
        reps = int(os.environ.get("PHP_REPS", "5"))
    except ValueError:
        fail("PHP_REPS must be an integer")
        return 1
    if reps < 1:
        fail("PHP_REPS must be positive")
        return 1
    if not runs_dir.is_dir():
        fail(f"runs directory does not exist: {runs_dir}")
        return 1

    try:
        rows = load_manifest(manifest_path)
        expected_scenarios = [row["scenario"] for row in rows]
        unexpected = sorted(
            entry.name
            for entry in runs_dir.iterdir()
            if entry.is_dir() and entry.name not in expected_scenarios
        )
        if unexpected:
            raise MatrixError(
                "runs directory contains scenarios that are not in the matrix: "
                + ", ".join(unexpected)
            )
        results: dict[str, Any] = {}
        scenarios_payload: list[dict[str, Any]] = []
        for row in rows:
            scenario = row["scenario"]
            scenario_dir = runs_dir / scenario
            if not scenario_dir.is_dir():
                raise MatrixError(f"missing scenario directory: {scenario_dir}")
            samples = load_samples(scenario_dir, reps, row)
            wall_values = [sample["wall_seconds"] for sample in samples]
            rss_values = [sample["max_rss_mib"] for sample in samples]
            wall_stats = summarize(wall_values)
            rss_stats = summarize(rss_values)
            results[scenario] = build_metric(
                scenario, row, wall_stats["median"], "s", "lower_is_better", wall_stats, wall_values
            )
            results[f"{scenario}_rss"] = build_metric(
                f"{scenario}_rss",
                row,
                rss_stats["median"],
                "MiB",
                "lower_is_better",
                rss_stats,
                rss_values,
            )
            scenarios_payload.append(
                {
                    "scenario": scenario,
                    "dimension": row["dimension"],
                    "runner": row["runner"],
                    "scale": row["scale"],
                    "workload": row["workload"],
                    "checks": [sample["checksum"] for sample in samples],
                }
            )
    except MatrixError as exc:
        fail(str(exc))
        return 1

    normalized: dict[str, Any] = {
        "benchmark": "php_workload_matrix",
        "software": "php",
        "version": version,
        "architecture": architecture,
        "variant": variant,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "variant": variant,
            "build_variant": {"variant": variant},
            "repetitions": reps,
            "warmups": 1,
            "offline": True,
            "interpreter": f"PHP {version} (CLI, Zend Engine, no FPM)",
            "build": {
                "configure": "--disable-all --enable-cli --disable-opcache-jit",
                "compiler": "gcc -O2 (PHP default release flags)",
                "opcache": "Zend OPcache embedded in the CLI binary, JIT disabled at configure time, opcache.enable_cli=0 for all scenarios",
                "runtime_flags": "-n (no php.ini), -d memory_limit=512M",
            },
            "matrix": expected_scenarios,
            "dimensions": sorted({row["dimension"] for row in rows}),
            "include_modules": 1000,
            "upstream_benchmarks": "Zend/bench.php and Zend/micro_bench.php from the official php-8.5.12.tar.gz source tree",
            "excluded_dimensions": [
                "OPcache CLI toggle: PHP 8.5 embeds OPcache in the CLI, and enabling "
                "opcache.file_cache_only in a local probe changed include time from "
                "about 0.61 s to 0.18 s only after several cache-warming runs, with the "
                "first warmed runs at 0.97-1.51 s; the variance exceeds the 5-sample "
                "budget of this matrix, so it is documented instead of measured",
                "composer install of a fixed project: composer and the dependency cache "
                "are not part of the offline pre-placed assets for this delivery",
            ],
        },
        "inputs": {
            "source": "https://www.php.net/distributions/php-8.5.12.tar.gz",
            "source_sha256": "81a0f450349e84b08eb43faa85f8a4c835684f3cc1c50471775d1317a046c525",
            "source_size": 24469403,
            "upstream_benchmark_provenance": "Zend/bench.php, Zend/micro_bench.php (same official tarball, tag php-8.5.12)",
        },
        "metric_contract": {
            "wall_time": {"unit": "s", "direction": "lower_is_better"},
            "peak_rss": {"unit": "MiB", "direction": "lower_is_better"},
            "statistic": "median of independent repetitions",
        },
        "scenarios": scenarios_payload,
        "results": results,
    }
    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(normalized, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(
        f"[php-parse] normalized {len(results)} metrics across {len(expected_scenarios)} scenarios"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
