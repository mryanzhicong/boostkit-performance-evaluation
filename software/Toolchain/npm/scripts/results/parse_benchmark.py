#!/usr/bin/env python3
"""Normalize the npm operation matrix from the recorded per-repetition samples.

Every scenario contributes two metrics: the wall-clock median of the measured npm
command (seconds, lower is better) and the median peak resident set size of the
npm process (MiB, lower is better).  Raw per-repetition logs and timing JSON
files stay in ``runs/<scenario>/`` as the primary evidence; this script only
aggregates them and fails when a declared scenario is incomplete, when a
repetition did not exit cleanly, or when the installed tree does not match the
size the build stage measured.
"""

from __future__ import annotations

import json
import math
import os
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

SCENARIOS = (
    "ci_clean_small",
    "ci_clean_medium",
    "ci_clean_large",
    "ci_upstream",
    "install_resolve_small",
    "install_noop_medium",
    "install_add_dep_medium",
    "query_prod_medium",
)


def fail(message: str) -> None:
    print(f"[npm-parse] ERROR: {message}", file=sys.stderr)


def load_metadata(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except OSError as exc:
        raise RuntimeError(f"cannot read fixture metadata {path}: {exc}") from exc
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"invalid JSON in fixture metadata {path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise RuntimeError("fixture metadata must be a JSON object")
    scenarios = payload.get("scenarios")
    if not isinstance(scenarios, dict) or not scenarios:
        raise RuntimeError("fixture metadata has no scenario table")
    for scenario in SCENARIOS:
        entry = scenarios.get(scenario)
        if not isinstance(entry, dict):
            raise RuntimeError(f"fixture metadata has no entry for scenario {scenario}")
        expected = entry.get("expected_packages")
        if isinstance(expected, bool) or not isinstance(expected, int) or expected <= 0:
            raise RuntimeError(
                f"fixture metadata has no positive expected_packages for {scenario}"
            )
    return payload


def load_samples(scenario_dir: Path, reps: int, expected_packages: int) -> list[dict[str, Any]]:
    samples: list[dict[str, Any]] = []
    for index in range(1, reps + 1):
        sample_path = scenario_dir / f"rep{index}.json"
        log_path = scenario_dir / f"rep{index}.log"
        if not sample_path.is_file():
            raise RuntimeError(f"missing repetition sample: {sample_path}")
        if not log_path.is_file():
            raise RuntimeError(f"missing repetition log: {log_path}")
        if log_path.stat().st_size == 0:
            raise RuntimeError(f"repetition log is empty: {log_path}")
        try:
            payload = json.loads(sample_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            raise RuntimeError(f"invalid repetition sample {sample_path}: {exc}") from exc
        if not isinstance(payload, dict):
            raise RuntimeError(f"repetition sample is not an object: {sample_path}")
        exit_code = payload.get("exit_code")
        if exit_code != 0:
            raise RuntimeError(
                f"repetition {sample_path.name} for {scenario_dir.name} failed "
                f"with exit code {exit_code}"
            )
        if payload.get("timed_out"):
            raise RuntimeError(f"repetition {sample_path.name} for {scenario_dir.name} timed out")
        wall = payload.get("wall_seconds")
        rss = payload.get("max_rss_mib")
        packages = payload.get("installed_packages")
        if isinstance(wall, bool) or not isinstance(wall, (int, float)):
            raise RuntimeError(f"repetition {sample_path.name} has no numeric wall time")
        if isinstance(rss, bool) or not isinstance(rss, (int, float)):
            raise RuntimeError(f"repetition {sample_path.name} has no numeric RSS")
        if not math.isfinite(float(wall)) or wall <= 0:
            raise RuntimeError(f"repetition {sample_path.name} wall time must be positive")
        if not math.isfinite(float(rss)) or rss <= 0:
            raise RuntimeError(f"repetition {sample_path.name} RSS must be positive")
        if isinstance(packages, bool) or not isinstance(packages, int) or packages <= 0:
            raise RuntimeError(f"repetition {sample_path.name} has no installed package count")
        if packages != expected_packages:
            raise RuntimeError(
                f"repetition {sample_path.name} for {scenario_dir.name} installed "
                f"{packages} packages, expected {expected_packages}"
            )
        samples.append(
            {
                "repetition": index,
                "wall_seconds": round(float(wall), 6),
                "max_rss_mib": round(float(rss), 3),
                "installed_packages": packages,
                "log": f"rep{index}.log",
            }
        )
    return samples


def summarize(values: list[float]) -> dict[str, float]:
    return {
        "median": round(float(statistics.median(values)), 6),
        "mean": round(float(statistics.fmean(values)), 6),
        "min": round(float(min(values)), 6),
        "max": round(float(max(values)), 6),
        "stdev": round(float(statistics.stdev(values)), 6) if len(values) > 1 else 0.0,
    }


def build_metric(
    name: str,
    scenario: str,
    fixture: str,
    installed_packages: int,
    command: str,
    value: float,
    unit: str,
    direction: str,
    statistics_payload: dict[str, float],
    samples: list[float],
) -> dict[str, Any]:
    return {
        "source_name": name,
        "scenario": scenario,
        "fixture": fixture,
        "installed_packages": installed_packages,
        "command": command,
        "value": value,
        "unit": unit,
        "direction": direction,
        **statistics_payload,
        "samples": samples,
    }


def scenario_command_text(scenario_dir: Path) -> str:
    command_file = scenario_dir / "command.txt"
    try:
        text = command_file.read_text(encoding="utf-8").strip()
    except OSError:
        return ""
    return text.replace("\n", " ")


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: parse_benchmark.py RUNS_DIRECTORY NORMALIZED_OUTPUT", file=sys.stderr)
        return 1
    runs_dir = Path(sys.argv[1])
    normalized_output = Path(sys.argv[2])
    try:
        version = os.environ["SOFTWARE_VERSION"]
        architecture = os.environ["EXPECTED_ARCH"]
        variant = os.environ.get("PERF_VARIANT", "base")
    except KeyError as exc:
        fail(f"missing environment variable: {exc}")
        return 1
    try:
        reps = int(os.environ.get("NPM_REPS", "5"))
    except ValueError:
        fail("NPM_REPS must be an integer")
        return 1
    if reps < 1:
        fail("NPM_REPS must be positive")
        return 1
    metadata_path_raw = os.environ.get("NPM_FIXTURE_METADATA", "")
    if not metadata_path_raw:
        fail("NPM_FIXTURE_METADATA is not set")
        return 1
    if not runs_dir.is_dir():
        fail(f"runs directory does not exist: {runs_dir}")
        return 1
    try:
        metadata = load_metadata(Path(metadata_path_raw))
    except RuntimeError as exc:
        fail(str(exc))
        return 1
    scenario_table = metadata["scenarios"]

    results: dict[str, Any] = {}
    scenario_parameters: dict[str, Any] = {}
    try:
        for scenario in SCENARIOS:
            scenario_dir = runs_dir / scenario
            if not scenario_dir.is_dir():
                raise RuntimeError(f"missing scenario directory: {scenario_dir}")
            expected_packages = int(scenario_table[scenario]["expected_packages"])
            fixture = str(scenario_table[scenario]["fixture"])
            samples = load_samples(scenario_dir, reps, expected_packages)
            wall_values = [sample["wall_seconds"] for sample in samples]
            rss_values = [sample["max_rss_mib"] for sample in samples]
            wall_stats = summarize(wall_values)
            rss_stats = summarize(rss_values)
            command = scenario_command_text(scenario_dir)
            results[scenario] = build_metric(
                scenario, scenario, fixture, expected_packages, command,
                wall_stats["median"], "s", "lower_is_better", wall_stats, wall_values,
            )
            results[f"{scenario}_rss"] = build_metric(
                f"{scenario}_rss", scenario, fixture, expected_packages, command,
                rss_stats["median"], "MiB", "lower_is_better", rss_stats, rss_values,
            )
            scenario_parameters[scenario] = {
                "fixture": fixture,
                "command": command,
            }
    except (RuntimeError, KeyError, TypeError) as exc:
        fail(str(exc))
        return 1

    # Parameters are hashed into the cross-architecture parameter signature, so
    # they must only contain values that are identical on every architecture.
    # The installed package count is not: platform specific optional
    # dependencies (native binaries for x64 vs arm64) change it, therefore it is
    # reported per metric as evidence instead of as a workload parameter.
    fixture_table_raw = metadata.get("fixtures", {})
    if not isinstance(fixture_table_raw, dict):
        raise RuntimeError("fixture metadata has an invalid fixtures table")
    fixture_table = {
        name: {
            key: entry[key]
            for key in (
                "direct_dependencies",
                "lockfile_version",
                "lockfile_packages",
                "lockfile_sha256",
                "committed_lockfile_sha256",
                "registry_origin",
            )
            if isinstance(entry, dict) and key in entry
        }
        for name, entry in fixture_table_raw.items()
    }
    normalized: dict[str, Any] = {
        "benchmark": "npm_operation_matrix",
        "software": "npm",
        "version": version,
        "architecture": architecture,
        "variant": variant,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "variant": variant,
            "repetitions": reps,
            "warmups": 1,
            "offline": True,
            "statistic": "median of independent repetitions",
            "measured_flags": ["--offline", "--ignore-scripts", "--no-audit", "--no-fund"],
            "npm_version": metadata.get("npm_version", version),
            "node_version": metadata.get("node_version", "unknown"),
            "npm_engines_node": metadata.get("npm_engines_node", "unknown"),
            "registry_for_cache_warmup": metadata.get("registry", "unknown"),
            "cache_layout": metadata.get("cache_layout", "unknown"),
            "extra_dependency": metadata.get("extra_dependency", "unknown"),
            "upstream_project": metadata.get("upstream_project", "unknown"),
            "fixtures": fixture_table,
            "scenarios": scenario_parameters,
        },
        "metric_contract": {
            "wall_time": {"unit": "s", "direction": "lower_is_better"},
            "peak_rss": {"unit": "MiB", "direction": "lower_is_better"},
            "statistic": "median of independent repetitions",
        },
        "results": results,
    }
    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(normalized, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(
        f"[npm-parse] normalized {len(results)} metrics across {len(SCENARIOS)} scenarios"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
